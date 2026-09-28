# CASE!

A personal productivity and organizing web app: dashboard, to-do, calendar, notes, folders, moodboards, timer, ambience, themes, and settings.

## Current status: Phase 3 baseline (September 2026)

- Single-file vanilla HTML/CSS/JavaScript app (`index.html`). No framework, no build step.
- **Sign-in is preview-only.** It is not real authentication. Passwords are never checked or stored.
- **No backend is connected.** When CASE! runs on its own (for example on Vercel), data is saved only in the visitor's browser (localStorage).
- The Admin area is a development-only preview. Its access check runs in the browser and is **not** security.
- Planned next: Supabase (real authentication, database, file storage, server-side admin roles).

## Running it

- Locally: open `index.html` in a browser.
- Deployed: Vercel serves `index.html` as a static site. No build command or settings are needed.

## Security note

Never commit API keys, passwords, service-role keys, or `.env` files to this repository.
