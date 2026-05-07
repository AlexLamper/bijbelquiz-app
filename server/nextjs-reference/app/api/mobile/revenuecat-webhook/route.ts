import { NextResponse, type NextRequest } from 'next/server';
import connectDB from '../../../../lib/mongodb';
import WebhookEvent from '../../../../lib/models/WebhookEvent';
import { syncStorePremiumForAppUser } from '../../../../lib/revenuecat/syncStorePremium';

export const runtime = 'nodejs';

/**
 * RevenueCat → Next.js webhook.
 *
 * Auth: set the same Authorization header value in RevenueCat dashboard and in
 * REVENUECAT_WEBHOOK_AUTHORIZATION (exact match).
 *
 * Sync: prefers REVENUECAT_REST_API_KEY + GET /v1/subscribers/{app_user_id}.
 */
export async function POST(req: NextRequest) {
  const expectedAuth = process.env.REVENUECAT_WEBHOOK_AUTHORIZATION;
  if (expectedAuth) {
    const auth = req.headers.get('authorization') ?? '';
    if (auth !== expectedAuth) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
  }

  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: 'Invalid JSON' }, { status: 400 });
  }

  const root = body as { event?: Record<string, unknown> };
  const event = (root.event ?? body) as {
    id?: string;
    type?: string;
    app_user_id?: string;
    entitlement_ids?: string[] | null;
    expiration_at_ms?: number | null;
  };

  const eventId = event.id;
  const appUserId = event.app_user_id;

  if (!eventId || !appUserId) {
    return NextResponse.json({ error: 'Missing event.id or app_user_id' }, { status: 400 });
  }

  await connectDB();

  try {
    await WebhookEvent.create({
      provider: 'revenuecat',
      eventId,
      payloadSummary: String(event.type ?? '').slice(0, 200),
    });
  } catch (e: unknown) {
    const code = (e as { code?: number }).code;
    if (code === 11000) {
      return NextResponse.json({ received: true, duplicate: true });
    }
    throw e;
  }

  await syncStorePremiumForAppUser(appUserId, event);

  return NextResponse.json({ received: true });
}
