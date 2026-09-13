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

window.SUPABASE_URL = 'https://ufqkiklkzmqdabhnnzvp.supabase.co';
window.SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVmcWtpa2xrem1xZGFiaG5uenZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkzMjQ4NjksImV4cCI6MjEwNDkwMDg2OX0.AmDhiCRCPsbAVRMuPZtO2e52Da3avFnQo9lg5Dq_H24';
