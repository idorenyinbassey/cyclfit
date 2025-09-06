-- Cyclfit Supabase schema

-- Workout Sessions (server copy for sync)
create table if not exists public.workout_sessions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  start_time timestamptz not null,
  end_time timestamptz,
  distance real default 0,
  duration integer default 0,
  average_speed real default 0,
  max_speed real default 0,
  calories real default 0,
  elevation real default 0,
  average_heart_rate integer,
  max_heart_rate integer,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Health Metrics
create table if not exists public.health_metrics (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  metric_type text not null,
  value real not null,
  secondary_value real,
  unit text not null,
  notes text,
  recorded_at timestamptz not null,
  created_at timestamptz default now()
);

-- Articles (for blog)
create table if not exists public.articles (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  content text not null,
  excerpt text,
  author text not null,
  category text not null,
  featured_image_url text,
  tags text[],
  is_published boolean default false,
  publish_date timestamptz not null,
  read_time integer,
  view_count integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Helpful indexes
create index if not exists idx_workout_sessions_user_time
  on public.workout_sessions(user_id, start_time desc);
create index if not exists idx_health_metrics_user_time
  on public.health_metrics(user_id, recorded_at desc);
create index if not exists idx_articles_publish
  on public.articles(is_published, publish_date desc);
