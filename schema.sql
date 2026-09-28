-- =====================================================================
-- CASE! — Supabase database setup, Phase 4 / Batch 1 (accounts + roles)
--
-- HOW TO USE: Supabase Dashboard → SQL Editor → New query → paste this
-- whole file → Run. It is safe to run more than once.
--
-- This file contains NO keys and NO passwords. It is safe to keep in GitHub.
-- The CASE! web page never runs this; only you run it, in the dashboard.
-- (Batch 2 will add the table for your synced data.)
-- =====================================================================

-- 1) One profile per account, holding the role. Everyone starts as 'user'.
create table if not exists public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  email        text,
  display_name text,
  role         text not null default 'user' check (role in ('user', 'admin')),
  created_at   timestamptz not null default now()
);

-- 2) Turn on Row Level Security: with no matching rule, nobody gets anything.
alter table public.profiles enable row level security;

-- 3) Create the profile automatically when someone signs up (always as 'user').
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email) values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Accounts created before this script ran also get a profile.
insert into public.profiles (id, email)
select id, email from auth.users
on conflict (id) do nothing;

-- 4) Server-side admin check, usable inside security rules.
--    "security definer" lets it read roles without being blocked by the rules
--    below (and prevents the rules from looping forever).
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'admin'
  );
$$;
revoke all on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

-- 5) Security rules (policies) for profiles.
drop policy if exists "profiles: read own, admins read all" on public.profiles;
create policy "profiles: read own, admins read all"
  on public.profiles for select
  to authenticated
  using (id = (select auth.uid()) or public.is_admin());

drop policy if exists "profiles: update own" on public.profiles;
create policy "profiles: update own"
  on public.profiles for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- No insert or delete rules on purpose: only the sign-up trigger creates
-- profiles, and deleting an account removes its profile automatically.

-- 6) Column permissions: from the app, people may change ONLY display_name.
--    They can never change role, email, or id — not even on their own row.
revoke all on public.profiles from anon;
revoke insert, update, delete on public.profiles from authenticated;
grant select on public.profiles to authenticated;
grant update (display_name) on public.profiles to authenticated;

-- =====================================================================
-- MAKE YOURSELF ADMIN (run separately, AFTER you have signed up in CASE!
-- and confirmed your email). Replace the email with yours, then Run:
--
--   update public.profiles set role = 'admin' where email = 'you@example.com';
--
-- The SQL Editor runs with owner rights, which is why it can change roles
-- while the app (and everyone using it) cannot.
-- =====================================================================
