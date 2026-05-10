/**
 * POST /api/mobile/apple-login
 *
 * Verifies an Apple identity token from Sign in with Apple and returns
 * a session token for the app.
 *
 * Required environment variables:
 *   APPLE_CLIENT_IDS  – comma-separated allowed Apple client IDs
 *                       (e.g. "com.example.bijbelquiz,com.example.bijbelquiz.signin")
 *                       APPLE_CLIENT_ID is still supported for backwards compatibility.
 *   JWT_SECRET        – secret used to sign your own session tokens
 *   MONGODB_URI       – MongoDB connection string
 *
 * Apple's note: email + name are only sent on the VERY FIRST sign-in.
 * Subsequent sign-ins omit them. Store the Apple user ID (sub) in your
 * User document the first time so you can look the user up on repeat logins.
 *
 * Copy this file to your Next.js app at:
 *   app/api/mobile/apple-login/route.ts
 *
 * Install dependencies (if not already present):
 *   npm install apple-signin-auth jsonwebtoken mongoose
 *   npm install -D @types/jsonwebtoken
 */

import { NextRequest, NextResponse } from 'next/server';
import appleSignin from 'apple-signin-auth';
import jwt from 'jsonwebtoken';
import { connectDB } from '@/lib/mongodb';
import mongoose from 'mongoose';

// ---------------------------------------------------------------------------
// Minimal User model – merge these fields into your existing User schema
// ---------------------------------------------------------------------------
interface IUser {
  _id: string;
  name: string;
  email: string;
  appleId?: string;       // Apple's unique user identifier (the JWT `sub` claim)
  emailVerified?: boolean;
  isPremium?: boolean;
}

// Use your real User model here; this is a fallback for reference purposes.
const UserModel =
  (mongoose.models.User as mongoose.Model<IUser>) ||
  mongoose.model<IUser>(
    'User',
    new mongoose.Schema({
      name: { type: String, default: '' },
      email: { type: String, required: true, unique: true },
      appleId: { type: String, unique: true, sparse: true },
      emailVerified: { type: Boolean, default: true },
      isPremium: { type: Boolean, default: false },
    }),
  );

// ---------------------------------------------------------------------------
// Route handler
// ---------------------------------------------------------------------------
export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { identityToken, authorizationCode, givenName, familyName, email } =
      body as {
        identityToken: string;
        authorizationCode: string;
        givenName?: string;
        familyName?: string;
        email?: string;
      };

    if (!identityToken) {
      return NextResponse.json(
        { error: 'identityToken is required' },
        { status: 400 },
      );
    }

    // -----------------------------------------------------------------------
    // 1. Verify the identity token with Apple's public JWKS
    // -----------------------------------------------------------------------
    const rawClientIds =
      process.env.APPLE_CLIENT_IDS ?? process.env.APPLE_CLIENT_ID ?? '';
    const clientIds = rawClientIds
      .split(',')
      .map((v) => v.trim())
      .filter(Boolean);

    if (clientIds.length == 0) {
      console.error('APPLE_CLIENT_IDS / APPLE_CLIENT_ID is not set');
      return NextResponse.json(
        { error: 'Server configuration error' },
        { status: 500 },
      );
    }

    let applePayload: {
      sub: string;
      email?: string;
      email_verified?: boolean | string;
    } | null = null;

    let tokenVerified = false;
    let verificationError: unknown = null;
    for (const audience of clientIds) {
      try {
        applePayload = await appleSignin.verifyIdToken(identityToken, {
          audience,
          // Ignore expiration during development if needed:
          // ignoreExpiration: true,
        });
        tokenVerified = true;
        break;
      } catch (err) {
        verificationError = err;
      }
    }

    if (!tokenVerified || !applePayload) {
      console.error('Apple token verification failed:', verificationError);
      return NextResponse.json(
        { error: 'Invalid Apple identity token' },
        { status: 401 },
      );
    }

    const appleUserId = applePayload.sub; // Stable unique identifier for this Apple user
    // Apple only provides email on first sign-in; fall back to what the app sent.
    const userEmail = applePayload.email ?? email;

    if (!appleUserId) {
      return NextResponse.json(
        { error: 'Could not extract user identity from Apple token' },
        { status: 401 },
      );
    }

    // -----------------------------------------------------------------------
    // 2. Find or create the user in MongoDB
    // -----------------------------------------------------------------------
    await connectDB();

    let user = await UserModel.findOne({ appleId: appleUserId });

    if (!user) {
      // First login: try to find by email if Apple provided one
      if (userEmail) {
        user = await UserModel.findOne({ email: userEmail });
      }

      if (user) {
        // Link Apple ID to existing email-based account
        user.appleId = appleUserId;
        await user.save();
      } else {
        // Brand-new user – create their account
        if (!userEmail) {
          return NextResponse.json(
            {
              error:
                'No email address available. Please allow email access when signing in with Apple.',
            },
            { status: 422 },
          );
        }

        const displayName =
          [givenName, familyName].filter(Boolean).join(' ').trim() ||
          userEmail.split('@')[0];

        user = await UserModel.create({
          name: displayName,
          email: userEmail,
          appleId: appleUserId,
          emailVerified: true,
        });
      }
    }

    // -----------------------------------------------------------------------
    // 3. Issue a session token
    // -----------------------------------------------------------------------
    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      console.error('JWT_SECRET is not set');
      return NextResponse.json(
        { error: 'Server configuration error' },
        { status: 500 },
      );
    }

    const token = jwt.sign(
      { userId: user._id.toString() },
      jwtSecret,
      { expiresIn: '90d' },
    );

    return NextResponse.json({
      token,
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
        isPremium: user.isPremium ?? false,
      },
    });
  } catch (err) {
    console.error('Apple login error:', err);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 },
    );
  }
}
