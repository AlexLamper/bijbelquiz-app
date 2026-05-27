import { NextResponse, type NextRequest } from 'next/server';
import jwt from 'jsonwebtoken';
import mongoose from 'mongoose';
import connectDB from '../../../../lib/mongodb';
import { syncStorePremiumForAppUser } from '../../../../lib/revenuecat/syncStorePremium';
import { effectiveIsPremium } from '../../../../lib/userPremium';

export const runtime = 'nodejs';

/**
 * POST /api/mobile/sync-premium
 *
 * Client-triggered reconciliation. RevenueCat only sends a webhook for a NEW
 * transaction, so an already-owned purchase or a "Restore" never re-fires one.
 * The app calls this after purchase/restore (and on launch) to force the server
 * to re-read the live entitlement from RevenueCat and update Mongo, so premium
 * unlocks even when the original purchase webhook never landed.
 *
 * Auth: Bearer JWT — the same token your login routes issue (see apple-login),
 * carrying a `userId` claim equal to the Mongo User._id (== RevenueCat app_user_id).
 *
 * Requires REVENUECAT_REST_API_KEY (sk_...) so the live subscriber can be fetched.
 */
export async function POST(req: NextRequest) {
  const auth = req.headers.get('authorization') ?? '';
  const token = auth.startsWith('Bearer ') ? auth.slice('Bearer '.length) : '';
  if (!token) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const jwtSecret = process.env.JWT_SECRET;
  if (!jwtSecret) {
    console.error('JWT_SECRET is not set');
    return NextResponse.json({ error: 'Server configuration error' }, { status: 500 });
  }

  let userId: string;
  try {
    const payload = jwt.verify(token, jwtSecret) as { userId?: string };
    if (!payload.userId) throw new Error('missing userId claim');
    userId = payload.userId;
  } catch {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // Reconciliation needs the REST key; the webhook-event fallback can't help
  // here because no event is in flight for an already-owned purchase.
  if (!process.env.REVENUECAT_REST_API_KEY) {
    console.error('REVENUECAT_REST_API_KEY is not set; cannot reconcile premium');
    return NextResponse.json({ error: 'Server configuration error' }, { status: 500 });
  }

  await connectDB();

  try {
    await syncStorePremiumForAppUser(userId);
  } catch (e) {
    console.error('sync-premium reconciliation failed:', e);
    return NextResponse.json({ error: 'Sync failed' }, { status: 502 });
  }

  const db = mongoose.connection.db;
  if (!db) {
    return NextResponse.json({ error: 'MongoDB is not connected' }, { status: 500 });
  }

  const collectionName = process.env.MONGODB_USERS_COLLECTION ?? 'users';
  const row = await db.collection(collectionName).findOne<{
    premiumStripe?: boolean;
    premiumStore?: boolean;
    storePremiumExpiresAt?: Date | null;
  }>(
    { _id: new mongoose.Types.ObjectId(userId) },
    { projection: { premiumStripe: 1, premiumStore: 1, storePremiumExpiresAt: 1 } },
  );

  const isPremium = effectiveIsPremium({
    premiumStripe: Boolean(row?.premiumStripe),
    premiumStore: Boolean(row?.premiumStore),
  });

  return NextResponse.json({
    isPremium,
    premiumStore: Boolean(row?.premiumStore),
    storePremiumExpiresAt: row?.storePremiumExpiresAt ?? null,
  });
}
