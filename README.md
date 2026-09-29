# CASE!

A personal productivity and organizing web app: dashboard, to-do, calendar, notes, folders, moodboards, timer, ambience, themes, and settings.

## Current status: Phase 4, Batch 2 (Supabase cloud sync)

- Single-file vanilla HTML/CSS/JavaScript app (`index.html`). No framework, no build step.
- **Sign-in:** real Supabase Auth (email + password, confirmation and reset emails). Preview mode returns only if the Supabase settings in `AUTH_CONFIG` are emptied.
- **Admin roles:** from the `profiles` table, protected by Row Level Security.
- **Data:** synced to Supabase (`user_data` table, one row per data key per person). Each browser also keeps an offline copy per account. Newest save wins per key.
- **Not yet:** images/files in Supabase Storage, site-wide admin data, importing old preview data (`case:v1:` is left untouched).
- Database setup, run once each in the Supabase SQL Editor, in order: `supabase/schema.sql` (Batch 1), then `supabase/batch2-user-data.sql` (Batch 2). Neither contains keys.

## Running it

- Locally: open `index.html` in a browser.
- Deployed: Vercel serves `index.html` as a static site. No build command or settings are needed.

## Security note

Never commit API keys, passwords, service-role keys, or `.env` files to this repository.
