-- Enable Row Level Security
alter table public.workout_sessions enable row level security;
alter table public.health_metrics enable row level security;
alter table public.articles enable row level security;

-- Workout Sessions policies (owner-only)
drop policy if exists "Users can view own workout sessions" on public.workout_sessions;
create policy "Users can view own workout sessions" on public.workout_sessions
  for select using (auth.uid() = user_id);

drop policy if exists "Users can insert own workout sessions" on public.workout_sessions;
create policy "Users can insert own workout sessions" on public.workout_sessions
  for insert with check (auth.uid() = user_id);

drop policy if exists "Users can update own workout sessions" on public.workout_sessions;
create policy "Users can update own workout sessions" on public.workout_sessions
  for update using (auth.uid() = user_id);

drop policy if exists "Users can delete own workout sessions" on public.workout_sessions;
create policy "Users can delete own workout sessions" on public.workout_sessions
  for delete using (auth.uid() = user_id);

-- Health Metrics policies (owner-only)
drop policy if exists "Users can view own health metrics" on public.health_metrics;
create policy "Users can view own health metrics" on public.health_metrics
  for select using (auth.uid() = user_id);

drop policy if exists "Users can insert own health metrics" on public.health_metrics;
create policy "Users can insert own health metrics" on public.health_metrics
  for insert with check (auth.uid() = user_id);

drop policy if exists "Users can update own health metrics" on public.health_metrics;
create policy "Users can update own health metrics" on public.health_metrics
  for update using (auth.uid() = user_id);

drop policy if exists "Users can delete own health metrics" on public.health_metrics;
create policy "Users can delete own health metrics" on public.health_metrics
  for delete using (auth.uid() = user_id);

-- Articles: public read, admin write
drop policy if exists "Anyone can view published articles" on public.articles;
create policy "Anyone can view published articles" on public.articles
  for select using (is_published = true);

-- For write access, use service role or add an 'is_admin' claim-based policy
-- Example (optional): allow users with JWT claim role = 'admin'
-- create policy "Admins can manage articles" on public.articles
--   for all using (auth.jwt() ->> 'role' = 'admin') with check (auth.jwt() ->> 'role' = 'admin');
