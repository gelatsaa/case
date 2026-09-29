-- =====================================================================
-- CASE! — Supabase database setup, Phase 4 / Batch 2 (cloud sync)
--
-- HOW TO USE: Supabase Dashboard → SQL Editor → New query → paste this
-- whole file → Run. Safe to run more than once. Run schema.sql (Batch 1)
-- first — this file expects it to exist already.
--
-- Contains NO keys and NO passwords. Safe to keep in GitHub.
-- =====================================================================

-- 1) One row per "store key" per person: profile, todos, notes, events,
--    files, boards, settings, notifs, admin, and one board_<id> per moodboard.
create table if not exists public.user_data (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  key        text        not null,
  value      jsonb       not null,
  t          bigint      not null,          -- when it was saved (ms), set by CASE!
  updated_at timestamptz not null default now(),
  primary key (user_id, key),
  -- only CASE!'s real key names are accepted
  constraint user_data_key_allowed check (
    key ~ '^(profile|todos|notes|events|files|boards|settings|notifs|admin|board_[a-z0-9]{1,40})$'),
  constraint user_data_t_positive check (t > 0),
  -- about 4 MB of data per key (a very full moodboard); bigger saves are refused
  constraint user_data_size check (octet_length(value::text) <= 4194304)
);

-- 2) Row Level Security: nobody sees or touches a row unless a rule allows it.
alter table public.user_data enable row level security;

drop policy if exists "user_data: read own" on public.user_data;
create policy "user_data: read own"
  on public.user_data for select
  to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "user_data: delete own" on public.user_data;
create policy "user_data: delete own"
  on public.user_data for delete
  to authenticated
  using (user_id = (select auth.uid()));

-- 3) Table permissions. People can READ and DELETE their own rows directly.
--    They can NOT insert or update directly: every save must go through the
--    put_user_data() function below, which applies the safety checks.
revoke all on public.user_data from anon, authenticated;
grant select, delete on public.user_data to authenticated;

-- 4) The one way to save: only replaces the cloud copy with a NEWER one.
--    - The owner is always the signed-in person (auth.uid()), never a value
--      sent by the browser, so nobody can write into someone else's data.
--    - An older save (an old tab, a device coming back online) is ignored,
--      and the function reports the newer time the cloud already has.
--    - A timestamp more than 10 minutes in the future is rejected: that
--      means the device's clock is wrong, and letting it through would make
--      its saves "win" forever.
create or replace function public.put_user_data(p_key text, p_value jsonb, p_t bigint)
returns table (applied boolean, t bigint)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid    uuid   := auth.uid();
  v_now_ms bigint := (extract(epoch from clock_timestamp()) * 1000)::bigint;
begin
  if v_uid is null then
    raise exception 'CASE_AUTH: not signed in' using errcode = '42501';
  end if;
  if p_value is null then
    raise exception 'CASE_VALUE: empty value' using errcode = '22004';
  end if;
  if p_t is null or p_t <= 0 or p_t > v_now_ms + 600000 then
    raise exception 'CASE_CLOCK: timestamp out of range' using errcode = '22023';
  end if;

  insert into public.user_data as d (user_id, key, value, t, updated_at)
  values (v_uid, p_key, p_value, p_t, now())
  on conflict (user_id, key) do update
    set value = excluded.value, t = excluded.t, updated_at = now()
    where d.t < excluded.t;

  if found then
    return query select true, p_t;
  else
    return query select false, d.t from public.user_data d
      where d.user_id = v_uid and d.key = p_key;
  end if;
end;
$$;

revoke all on function public.put_user_data(text, jsonb, bigint) from public, anon;
grant execute on function public.put_user_data(text, jsonb, bigint) to authenticated;

-- =====================================================================
-- OPTIONAL CHECK (run separately): see what's stored, newest first.
--   select user_id, key, t, updated_at, octet_length(value::text) as bytes
--   from public.user_data order by updated_at desc;
-- =====================================================================
