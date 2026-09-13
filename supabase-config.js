// Supabase connection details for the Property Inspection Tracker.
// This file is separate from the app pages on purpose — future updates to
// the app never touch this file, so you set this up once.
//
// Where to find these values: Supabase dashboard > Project Settings > API
//   - "Project URL"        -> window.SUPABASE_URL
//   - "anon public" key    -> window.SUPABASE_ANON_KEY
//
// The anon key is safe to expose in client-side code — it's designed for
// this. Actual data security is enforced by the Row Level Security policies
// in schema.sql, not by keeping this key secret.

window.SUPABASE_URL = 'PASTE_YOUR_SUPABASE_PROJECT_URL_HERE';
window.SUPABASE_ANON_KEY = 'PASTE_YOUR_SUPABASE_ANON_KEY_HERE';
