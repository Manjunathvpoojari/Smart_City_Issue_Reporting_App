-- ============================================================
-- SmartCity App - Supabase Database Setup
-- Run this entire file in Supabase SQL Editor
-- https://supabase.com → your project → SQL Editor
-- ============================================================

-- ── 1. USERS TABLE ──────────────────────────────────────────
create table if not exists public.users (
  id          uuid primary key references auth.users(id) on delete cascade,
  name        text not null default '',
  email       text not null default '',
  role        text not null default 'citizen' check (role in ('citizen', 'admin')),
  fcm_token   text,
  created_at  timestamptz not null default now()
);

-- ── 2. ISSUES TABLE ─────────────────────────────────────────
create table if not exists public.issues (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.users(id) on delete cascade,
  title        text not null,
  description  text not null,
  category     text not null default 'Other'
                 check (category in ('Pothole','Drainage','Garbage','Street Light','Encroachment','Water Leakage','Other')),
  image_url    text,
  latitude     float8 not null,
  longitude    float8 not null,
  status       text not null default 'Pending'
                 check (status in ('Pending','In Progress','Resolved')),
  admin_note   text,
  upvotes      int not null default 0,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- ── 3. STATUS HISTORY TABLE ──────────────────────────────────
create table if not exists public.status_history (
  id          uuid primary key default gen_random_uuid(),
  issue_id    uuid not null references public.issues(id) on delete cascade,
  old_status  text not null,
  new_status  text not null,
  changed_by  uuid not null references public.users(id),
  changed_at  timestamptz not null default now()
);

-- ── 4. ENABLE REALTIME ───────────────────────────────────────
alter publication supabase_realtime add table public.issues;
alter publication supabase_realtime add table public.status_history;

-- ── 5. STORAGE BUCKET ────────────────────────────────────────
insert into storage.buckets (id, name, public)
values ('issue-images', 'issue-images', true)
on conflict do nothing;

-- ── 6. ROW LEVEL SECURITY (RLS) ─────────────────────────────
alter table public.users enable row level security;
alter table public.issues enable row level security;
alter table public.status_history enable row level security;

-- Users: can read/update own profile
create policy "Users can read own profile"
  on public.users for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.users for update
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.users for insert
  with check (auth.uid() = id);

-- Admins can read all users
create policy "Admins can read all users"
  on public.users for select
  using (
    exists (
      select 1 from public.users
      where id = auth.uid() and role = 'admin'
    )
  );

-- Issues: citizens can insert their own
create policy "Citizens can insert issues"
  on public.issues for insert
  with check (auth.uid() = user_id);

-- Issues: everyone (authenticated) can read all issues (for public map)
create policy "Authenticated users can read all issues"
  on public.issues for select
  using (auth.role() = 'authenticated');

-- Issues: only admins can update
create policy "Admins can update issues"
  on public.issues for update
  using (
    exists (
      select 1 from public.users
      where id = auth.uid() and role = 'admin'
    )
  );

-- Status history: authenticated can read
create policy "Authenticated users can read status history"
  on public.status_history for select
  using (auth.role() = 'authenticated');

-- Status history: only admins can insert
create policy "Admins can insert status history"
  on public.status_history for insert
  with check (
    exists (
      select 1 from public.users
      where id = auth.uid() and role = 'admin'
    )
  );

-- Storage: anyone can read issue images (public bucket)
create policy "Public read issue images"
  on storage.objects for select
  using (bucket_id = 'issue-images');

-- Storage: authenticated users can upload
create policy "Authenticated users can upload issue images"
  on storage.objects for insert
  with check (
    bucket_id = 'issue-images'
    and auth.role() = 'authenticated'
  );

-- ── 7. AUTO-UPDATE updated_at TRIGGER ───────────────────────
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger issues_updated_at
  before update on public.issues
  for each row execute procedure public.handle_updated_at();

-- ── 8. AUTO-CREATE USER PROFILE ON SIGNUP ───────────────────
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, name, email, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    coalesce(new.email, ''),
    'citizen'
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── 9. MAKE A USER ADMIN (run manually after signup) ────────
-- Replace 'user@example.com' with the admin's email
-- update public.users set role = 'admin' where email = 'user@example.com';

-- ── DONE ─────────────────────────────────────────────────────
-- Your database is ready!
-- Next steps:
-- 1. Go to Supabase → Authentication → Providers → Enable Google
-- 2. Add your Google OAuth credentials
-- 3. Set redirect URL: io.supabase.smartcity://login-callback
-- 4. Run the app and test sign in
