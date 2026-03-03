// src/lib/admin-clients.ts
// Server-only — never import from client components.
// Provides a Firebase Admin App and Supabase service-role client.

import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getAuth }                        from 'firebase-admin/auth';
import { createClient }                   from '@supabase/supabase-js';

// ── Firebase Admin ──────────────────────────────────────────────────────────
function getFirebaseAdmin() {
  if (getApps().length > 0) return getApps()[0];

  return initializeApp({
    credential: cert({
      projectId:   process.env.FIREBASE_PROJECT_ID!,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL!,
      privateKey:  process.env.FIREBASE_PRIVATE_KEY!.replace(/\\n/g, '\n'),
    }),
  });
}

export const adminAuth = () => getAuth(getFirebaseAdmin());

// ── Supabase Service-Role Client ─────────────────────────────────────────────
// Never exposed to the browser. Used for all admin data operations.
export const adminDb = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  { auth: { persistSession: false } }
);
