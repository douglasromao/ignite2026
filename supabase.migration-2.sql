-- Delta to run once in Supabase > SQL Editor (the main schema is already installed). Replace HOST_EMAIL with the host's email, as before.
-- Adds: host_notes (private speaker notes) and feedback. Live reactions use Realtime broadcast and need no table.

-- The host's private notes per slide. Only the host can read or write them.
create table public.host_notes (
  slide int primary key check (slide between 0 and 50),
  body text not null default '' check (length(body) <= 4000),
  updated_at timestamptz not null default now()
);
alter table public.host_notes enable row level security;
create policy "host reads notes" on public.host_notes for select to authenticated
  using ((auth.jwt() ->> 'email') = 'HOST_EMAIL');
create policy "host adds notes" on public.host_notes for insert to authenticated
  with check ((auth.jwt() ->> 'email') = 'HOST_EMAIL');
create policy "host edits notes" on public.host_notes for update to authenticated
  using ((auth.jwt() ->> 'email') = 'HOST_EMAIL') with check ((auth.jwt() ->> 'email') = 'HOST_EMAIL');

-- Feedback on the talk. Anyone can send it; only the host can read it.
create table public.feedback (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  cid uuid not null,
  rating int not null check (rating between 1 and 5),
  useful text check (length(useful) <= 500),
  change text check (length(change) <= 500)
);
alter table public.feedback enable row level security;
create policy "anyone gives feedback" on public.feedback for insert to anon, authenticated with check (true);
create policy "host reads feedback" on public.feedback for select to authenticated
  using ((auth.jwt() ->> 'email') = 'HOST_EMAIL');
