/**
 * EXAMPLE — merge into your real `app/api/stripe/webhook/route.ts`.
 *
 * Replace any logic that did:
 *   User.findByIdAndUpdate(id, { isPremium: true/false })
 * with `setPremiumFromStripe` so App Store / Play purchases (`premiumStore`)
 * are not wiped when Stripe events fire.
 */

import { NextResponse, type NextRequest } from 'next/server';
import connectDB from '../../../../lib/mongodb';
import { setPremiumFromStripe } from '../../../../lib/stripe/setPremiumFromStripe';

export const runtime = 'nodejs';

// import Stripe from 'stripe';
// const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

export async function POST(_req: NextRequest) {
  await connectDB();

  // 1. Verify Stripe signature on raw body (your existing code).
  // 2. Parse event.type (e.g. customer.subscription.updated).
  // 3. Resolve mongoUserId from customer.metadata or your StripeCustomer mapping.

  const mongoUserId = 'REPLACE_WITH_RESOLVED_OBJECT_ID';
  const subscriptionActive = false;

  await setPremiumFromStripe(mongoUserId, subscriptionActive);

  return NextResponse.json({ received: true });
}
