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

-- | upvote ___


CREATE TABLE IF NOT EXISTS public.issue_upvotes (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  issue_id    UUID NOT NULL REFERENCES public.issues(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES public.users(id)  ON DELETE CASCADE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  -- Unique constraint: one vote per user per issue
  CONSTRAINT unique_user_issue_upvote UNIQUE (user_id, issue_id)
);


ALTER TABLE public.issue_upvotes ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Users can read upvotes"
  ON public.issue_upvotes FOR SELECT
  TO authenticated
  USING (true);


CREATE POLICY "Users can insert own upvote"
  ON public.issue_upvotes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can only delete their own vote
CREATE POLICY "Users can delete own upvote"
  ON public.issue_upvotes FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);


-- ============================================================
ALTER TABLE public.issues
  ADD COLUMN IF NOT EXISTS upvotes INTEGER NOT NULL DEFAULT 0;

-- 4. RPC: increment_upvote — atomic +1 on issues.upvotes
-- ============================================================
CREATE OR REPLACE FUNCTION public.increment_upvote(issue_id UUID)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
AS $$
  UPDATE public.issues
  SET upvotes = upvotes + 1
  WHERE id = issue_id;
$$;

-- 5. RPC: decrement_upvote — atomic -1 (never below 0)
-- ============================================================
CREATE OR REPLACE FUNCTION public.decrement_upvote(issue_id UUID)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
AS $$
  UPDATE public.issues
  SET upvotes = GREATEST(upvotes - 1, 0)
  WHERE id = issue_id;
$$;

-- 6. Index for fast lookup of user votes
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_issue_upvotes_user_id
  ON public.issue_upvotes(user_id);

CREATE INDEX IF NOT EXISTS idx_issue_upvotes_issue_id
  ON public.issue_upvotes(issue_id);

-- 7. Index for fast admin sort by upvotes
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_issues_upvotes_desc
  ON public.issues(upvotes DESC);
