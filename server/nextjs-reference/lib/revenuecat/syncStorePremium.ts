import mongoose from 'mongoose';
import { PREMIUM_ENTITLEMENT_ID } from '../userPremium';

type SubscriberEntitlement = {
  expires_date?: string | null;
  expires_date_ms?: number | null;
};

type SubscriberResponse = {
  subscriber?: {
    entitlements?: {
      active?: Record<string, SubscriberEntitlement | undefined>;
    };
  };
};

function parseExpires(ent: SubscriberEntitlement | undefined): Date | null {
  if (!ent) return null;
  if (ent.expires_date) {
    const d = new Date(ent.expires_date);
    return Number.isNaN(d.getTime()) ? null : d;
  }
  if (typeof ent.expires_date_ms === 'number') {
    return new Date(ent.expires_date_ms);
  }
  return null;
}

/**
 * Source of truth: RevenueCat REST subscriber object (recommended after webhooks).
 * https://www.revenuecat.com/docs/integrations/webhooks#syncing-subscription-status
 */
export async function fetchStorePremiumFromRevenueCatApi(
  appUserId: string,
): Promise<{ premiumStore: boolean; storePremiumExpiresAt: Date | null }> {
  const apiKey = process.env.REVENUECAT_REST_API_KEY;
  if (!apiKey) {
    throw new Error('REVENUECAT_REST_API_KEY is not set');
  }
  const url = `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`;
  const res = await fetch(url, {
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`RevenueCat API ${res.status}: ${text.slice(0, 500)}`);
  }

  const data = (await res.json()) as SubscriberResponse;
  const ent = data.subscriber?.entitlements?.active?.[PREMIUM_ENTITLEMENT_ID];
  const premiumStore = Boolean(ent);
  const storePremiumExpiresAt = premiumStore ? parseExpires(ent) : null;

  return { premiumStore, storePremiumExpiresAt };
}

type RevenueCatWebhookEvent = {
  id?: string;
  type?: string;
  app_user_id?: string;
  entitlement_ids?: string[] | null;
};

/**
 * Fallback when REST key is not configured (local dev only).
 * Conservative: only grant on clear purchase signals; revoke on EXPIRATION.
 */
export function inferStorePremiumFromWebhookEvent(
  event: RevenueCatWebhookEvent,
): { premiumStore: boolean | null; storePremiumExpiresAt: Date | null } {
  const type = event.type;
  const ids = event.entitlement_ids ?? [];
  const hasPremium = ids.includes(PREMIUM_ENTITLEMENT_ID);

  if (type === 'TEST') {
    return { premiumStore: null, storePremiumExpiresAt: null };
  }

  if (type === 'EXPIRATION') {
    return { premiumStore: false, storePremiumExpiresAt: null };
  }

  const grantTypes = new Set([
    'INITIAL_PURCHASE',
    'RENEWAL',
    'NON_RENEWING_PURCHASE',
    'UNCANCELLATION',
    'PRODUCT_CHANGE',
    'TEMPORARY_ENTITLEMENT_GRANT',
  ]);

  if (type && grantTypes.has(type) && hasPremium) {
    const ms = (event as { expiration_at_ms?: number | null }).expiration_at_ms;
    const storePremiumExpiresAt =
      typeof ms === 'number' && ms > 0 ? new Date(ms) : null;
    return { premiumStore: true, storePremiumExpiresAt };
  }

  return { premiumStore: null, storePremiumExpiresAt: null };
}

const DEFAULT_USERS_COLLECTION = 'users';

/**
 * Updates store premium fields and keeps legacy `isPremium` in sync when present:
 * `isPremium = premiumStripe || premiumStore`.
 */
export async function updateUserStorePremiumInMongo(
  appUserId: string,
  patch: { premiumStore: boolean; storePremiumExpiresAt: Date | null },
): Promise<void> {
  if (!mongoose.Types.ObjectId.isValid(appUserId)) {
    throw new Error(`Invalid app_user_id for Mongo lookup: ${appUserId}`);
  }

  const db = mongoose.connection.db;
  if (!db) {
    throw new Error('MongoDB is not connected');
  }

  const collectionName = process.env.MONGODB_USERS_COLLECTION ?? DEFAULT_USERS_COLLECTION;
  const coll = db.collection(collectionName);
  const oid = new mongoose.Types.ObjectId(appUserId);

  const updateResult = await coll.updateOne(
    { _id: oid },
    {
      $set: {
        premiumStore: patch.premiumStore,
        storePremiumExpiresAt: patch.storePremiumExpiresAt,
      },
    },
  );

  if (updateResult.matchedCount === 0) {
    throw new Error(`User not found for app_user_id: ${appUserId}`);
  }

  const row = await coll.findOne<{ premiumStripe?: boolean }>(
    { _id: oid },
    { projection: { premiumStripe: 1, isPremium: 1 } },
  );
  const premiumStripe = Boolean(row?.premiumStripe);
  const combined = premiumStripe || patch.premiumStore;

  await coll.updateOne({ _id: oid }, { $set: { isPremium: combined } });
}

export async function syncStorePremiumForAppUser(appUserId: string, webhookEvent?: RevenueCatWebhookEvent) {
  if (process.env.REVENUECAT_REST_API_KEY) {
    const patch = await fetchStorePremiumFromRevenueCatApi(appUserId);
    await updateUserStorePremiumInMongo(appUserId, patch);
    return;
  }

  if (webhookEvent) {
    const inferred = inferStorePremiumFromWebhookEvent(webhookEvent);
    if (inferred.premiumStore !== null) {
      await updateUserStorePremiumInMongo(appUserId, {
        premiumStore: inferred.premiumStore,
        storePremiumExpiresAt: inferred.storePremiumExpiresAt,
      });
    }
  }
}
