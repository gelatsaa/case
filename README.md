# CASE!

A personal productivity and organizing web app: dashboard, to-do, calendar, notes, folders, moodboards, timer, ambience, themes, and settings.

## Current status: Phase 4, Batch 5 (Recently deleted, Quick Find, Restore) + Auth 1

- Single-file vanilla HTML/CSS/JavaScript app (`index.html`). No framework, no build step.
- **Sign-in:** real Supabase Auth (email + password): sign up with email confirmation (and resend), sign in, reset password, change password in Settings, sign out on this device or on all devices. Continue with Google is on (provider configured in Supabase). Apple is still switched off. Google/Apple-only accounts can add a password in Settings.
- **Data:** synced to Supabase (`user_data`), with an offline copy per account in each browser.
- **Files & images:** private Supabase Storage bucket `case-user-files`, one folder per account, readable only by its owner through short-lived signed links. 20 MB per file; images, PDF, video, CSV, Markdown, JSON, text (no SVG). Folders supports upload, drag-and-drop, open, download, and delete. Removed files are cleaned up the next time CASE! opens, only if nothing still uses them.
- **Recently deleted:** deletes go to Settings → Recently deleted for 30 days (Undo right after deleting; Restore or Delete forever later). "Delete all CASE! data" stays permanent.
- **Quick Find:** ⌘K (Mac) / Ctrl+K (Windows/Linux), or Search in the sidebar — searches tasks, notes, events, folders, files, links, and moodboards.
- **Restore from a CASE! export:** Settings → Privacy & data. Adds only missing items; never overwrites; only your own files can be relinked.
- **Legacy import:** Settings → Privacy & data offers an opt-in, additive import of old preview (`case:v1:`) data, after a backup. The old data is never changed.
- **Admin:** roles, announcements, releases, maintenance — server-enforced (RLS + admin-only functions).
- Database setup, run once each in the Supabase SQL Editor, in order: `schema.sql`, `batch2-user-data.sql`, `batch3-admin.sql`, `batch3b-releases.sql`, `batch4-storage.sql`, `batch5-trash.sql`. None contain keys.

## Running it

- Locally: open `index.html` in a browser.
- Deployed: Vercel serves `index.html` as a static site. No build command or settings are needed.

## Security note

Never commit API keys, passwords, service-role keys, or `.env` files to this repository.
