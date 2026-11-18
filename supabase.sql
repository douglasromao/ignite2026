-- Paste into Supabase > SQL Editor and run once.
-- Before running: replace HOST_EMAIL below with the email of the host user you create in
-- Authentication > Users. Also turn OFF "Allow new users to sign up" in Authentication > Sign In / Providers.

create table public.state (
  id int primary key default 1 check (id = 1),           -- single row: the slide everyone is on
  slide int not null default 0 check (slide between 0 and 50)
);
insert into public.state default values;

create table public.responses (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  cid uuid not null,                                     -- random per browser, to merge a person's two submits
  answers jsonb not null check (pg_column_size(answers) < 500),
  scores jsonb not null check (pg_column_size(scores) < 500),
  level text not null check (length(level) < 30),
  name text check (length(name) <= 100),
  email text check (length(email) <= 200),
  company text check (length(company) <= 100),
  consent boolean not null default false,
  check (email is null or consent)                       -- no contact details without consent
);

alter table public.state enable row level security;
alter table public.responses enable row level security;

-- Everyone can see which slide is live; only the host can change it.
create policy "anyone reads state" on public.state for select using (true);
create policy "host moves slides" on public.state for update to authenticated
  using ((auth.jwt() ->> 'email') = 'HOST_EMAIL') with check ((auth.jwt() ->> 'email') = 'HOST_EMAIL');

-- Anyone can submit a response; only the host can read them.
create policy "anyone submits" on public.responses for insert to anon, authenticated with check (true);
create policy "host reads responses" on public.responses for select to authenticated
  using ((auth.jwt() ->> 'email') = 'HOST_EMAIL');

-- Push slide changes to connected phones.
alter publication supabase_realtime add table public.state;

-- Things the audience shares at the table: ideas, experiences, challenges. Only the host can read them.
create table public.shares (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  cid uuid not null,
  kind text not null check (kind in ('idea','experience','challenge')),
  text text not null check (length(text) between 1 and 500),
  name text check (length(name) <= 60)
);
alter table public.shares enable row level security;
create policy "anyone shares" on public.shares for insert to anon, authenticated with check (true);
create policy "host reads shares" on public.shares for select to authenticated
  using ((auth.jwt() ->> 'email') = 'HOST_EMAIL');


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
