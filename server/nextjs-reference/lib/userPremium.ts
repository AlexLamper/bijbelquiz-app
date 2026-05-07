/**
 * Single MongoDB user with two independent premium sources.
 * Stripe (web) updates `premiumStripe`; RevenueCat (App Store / Play) updates `premiumStore`.
 */

export const PREMIUM_ENTITLEMENT_ID =
  process.env.REVENUECAT_PREMIUM_ENTITLEMENT_ID ?? 'premium';

export type PremiumFields = {
  premiumStripe: boolean;
  premiumStore: boolean;
  storePremiumExpiresAt?: Date | null;
};

export function effectiveIsPremium(user: PremiumFields): boolean {
  return Boolean(user.premiumStripe || user.premiumStore);
}

/** Fields to merge into your User schema / API JSON serializer */
export function premiumProjectionForApi(user: PremiumFields & { isPremium?: boolean }) {
  const isPremium = effectiveIsPremium(user);
  return {
    isPremium,
    premiumStripe: user.premiumStripe,
    premiumStore: user.premiumStore,
    storePremiumExpiresAt: user.storePremiumExpiresAt ?? null,
  };
}
