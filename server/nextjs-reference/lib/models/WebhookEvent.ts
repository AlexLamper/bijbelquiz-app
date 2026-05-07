/**
 * Idempotent webhook processing (RevenueCat may deliver duplicates).
 */

import mongoose, { Schema } from 'mongoose';

const WebhookEventSchema = new Schema(
  {
    provider: { type: String, required: true, enum: ['revenuecat'] },
    eventId: { type: String, required: true },
    /** Optional: trim in prod if you want smaller DB */
    payloadSummary: { type: String, default: '' },
  },
  { timestamps: true },
);

WebhookEventSchema.index({ provider: 1, eventId: 1 }, { unique: true });

export type WebhookEventDocument = mongoose.InferSchemaType<typeof WebhookEventSchema> & {
  _id: mongoose.Types.ObjectId;
};

export default mongoose.models.WebhookEvent ??
  mongoose.model('WebhookEvent', WebhookEventSchema);
