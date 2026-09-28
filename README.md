# CASE!

A personal productivity and organizing web app: dashboard, to-do, calendar, notes, folders, moodboards, timer, ambience, themes, and settings.

## Current status: Phase 4, Batch 1 (Supabase accounts + roles)

- Single-file vanilla HTML/CSS/JavaScript app (`index.html`). No framework, no build step.
- **Sign-in:** preview-only until the Supabase Project URL and publishable key are added to `AUTH_CONFIG` in `index.html`. With them, CASE! uses real Supabase Auth (email + password, confirmation and reset emails).
- **Admin roles:** in Supabase mode, roles come from the `profiles` table and are protected by Row Level Security. The development test list only works in preview mode.
- **Data:** still saved in the browser only (kept separate per account in Supabase mode). Cloud sync is the next step (Batch 2).
- `supabase/schema.sql` is the database setup, run once in the Supabase SQL Editor. It contains no keys.

## Running it

- Locally: open `index.html` in a browser.
- Deployed: Vercel serves `index.html` as a static site. No build command or settings are needed.

## Security note

Never commit API keys, passwords, service-role keys, or `.env` files to this repository.
