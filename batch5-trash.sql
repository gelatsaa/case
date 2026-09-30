-- =====================================================================
-- CASE! — Batch 5: allow the "trash" data key (Recently deleted)
--
-- WHAT IT DOES: replaces the Batch 2 allow-list rule on public.user_data
-- with the same rule plus one new key name, "trash". Nothing else.
--   * No rows are changed, moved, or deleted.
--   * RLS policies, put_user_data(), Storage, profiles, and Admin are untouched.
--   * Every existing row already satisfies the new rule (it only allows more).
-- Run BEFORE deploying the Batch 5 index.html. Safe to run more than once.
-- Contains no keys or passwords.
-- =====================================================================
begin;

alter table public.user_data
  drop constraint if exists user_data_key_allowed;

alter table public.user_data
  add constraint user_data_key_allowed check (
    key ~ '^(profile|todos|notes|events|files|boards|settings|notifs|admin|trash|board_[a-z0-9]{1,40})$'
  );

commit;
