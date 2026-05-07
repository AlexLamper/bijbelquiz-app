import mongoose from 'mongoose';
import { effectiveIsPremium } from '../userPremium';

const DEFAULT_USERS_COLLECTION = 'users';

/**
 * Call from your Stripe webhook when subscription becomes active / inactive.
 * Only mutates `premiumStripe` and legacy `isPremium` (OR with existing `premiumStore`).
 */
export async function setPremiumFromStripe(
  mongoUserId: string,
  premiumStripe: boolean,
): Promise<void> {
  if (!mongoose.Types.ObjectId.isValid(mongoUserId)) {
    throw new Error(`Invalid mongo user id: ${mongoUserId}`);
  }

  const db = mongoose.connection.db;
  if (!db) {
    throw new Error('MongoDB is not connected');
  }

  const collectionName = process.env.MONGODB_USERS_COLLECTION ?? DEFAULT_USERS_COLLECTION;
  const coll = db.collection(collectionName);
  const oid = new mongoose.Types.ObjectId(mongoUserId);

  const row = await coll.findOne<{ premiumStore?: boolean }>(
    { _id: oid },
    { projection: { premiumStore: 1 } },
  );
  if (!row) {
    throw new Error(`User not found: ${mongoUserId}`);
  }

  const combined = effectiveIsPremium({
    premiumStripe,
    premiumStore: Boolean(row.premiumStore),
  });

  await coll.updateOne(
    { _id: oid },
    { $set: { premiumStripe, isPremium: combined } },
  );
}
