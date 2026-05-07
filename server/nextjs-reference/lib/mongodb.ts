/**
 * Replace with your app's `connectDB` / `mongoose.connect` helper.
 */

import mongoose from 'mongoose';

const MONGODB_URI = process.env.MONGODB_URI ?? '';

if (!MONGODB_URI && process.env.NODE_ENV === 'production') {
  console.warn('MONGODB_URI is not set');
}

let cached = global as typeof globalThis & { mongooseConn?: typeof mongoose };

export default async function connectDB(): Promise<void> {
  if (mongoose.connection.readyState >= 1) return;
  if (!MONGODB_URI) {
    throw new Error('MONGODB_URI is not configured');
  }
  if (!cached.mongooseConn) {
    cached.mongooseConn = await mongoose.connect(MONGODB_URI);
  }
}
