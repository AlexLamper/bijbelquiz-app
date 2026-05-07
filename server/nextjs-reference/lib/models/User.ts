/**
 * Merge into your existing Mongoose User schema (do not register a second "User" model).
 *
 * @example
 * import { userPremiumSchemaFields, attachPremiumPreSave } from '@/lib/models/User';
 * UserSchema.add(userPremiumSchemaFields);
 * attachPremiumPreSave(UserSchema);
 */

import type { Schema } from 'mongoose';
import { effectiveIsPremium } from '../userPremium';

export const userPremiumSchemaFields = {
  premiumStripe: { type: Boolean, default: false },
  premiumStore: { type: Boolean, default: false },
  storePremiumExpiresAt: { type: Date, default: null },
};

/**
 * Keeps legacy `isPremium` in sync for any code that still reads a single flag.
 * Omit this if you removed `isPremium` and only expose `effectiveIsPremium` in API routes.
 */
export function attachPremiumPreSave(userSchema: Schema) {
  userSchema.pre('save', function syncLegacyIsPremium(next) {
    const doc = this as Record<string, unknown>;
    if (this.schema.path('isPremium')) {
      (doc as { isPremium?: boolean }).isPremium = effectiveIsPremium({
        premiumStripe: Boolean(doc.premiumStripe),
        premiumStore: Boolean(doc.premiumStore),
      });
    }
    next();
  });
}
