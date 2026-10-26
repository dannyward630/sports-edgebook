-- Initial schema for Sports Edgebook.
-- Every table carries user_id and is protected by Row Level Security: each user only sees their own rows.
-- Columns marked "future" stay empty in the MVP and are filled by the results/odds API integration (phase 5).

create table public.leagues (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  name text not null,
  country text,
  source text not null default 'manual' check (source in ('manual', 'api_football')),
  external_id text, -- future
  created_at timestamptz not null default now(),
  unique (user_id, source, external_id)
);

create table public.teams (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  name text not null,
  league_id uuid references public.leagues on delete set null,
  source text not null default 'manual' check (source in ('manual', 'api_football')),
  external_id text, -- future
  created_at timestamptz not null default now(),
  unique (user_id, source, external_id)
);

-- Alternative spellings ("Benfica", "SL Benfica") so manual names can be matched to API names later.
create table public.team_aliases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  team_id uuid not null references public.teams on delete cascade,
  alias text not null,
  unique (user_id, alias)
);

create table public.events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  kickoff_at timestamptz not null,
  league_id uuid references public.leagues on delete set null,
  home_team_id uuid not null references public.teams on delete restrict,
  away_team_id uuid not null references public.teams on delete restrict,
  home_score smallint,
  away_score smallint,
  source text not null default 'manual' check (source in ('manual', 'api_football')),
  external_id text, -- future
  created_at timestamptz not null default now(),
  unique (user_id, source, external_id),
  check (home_team_id <> away_team_id)
);

create table public.markets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  category text not null, -- 1X2, Golos, Cantos, Cartões, BTTS, Handicap...
  name text not null,
  unique (user_id, category, name)
);

create table public.predictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  event_id uuid not null references public.events on delete cascade,
  market_id uuid not null references public.markets on delete restrict,
  selection text not null,
  line numeric(6, 2),
  odd numeric(8, 3) not null check (odd > 1),
  confidence smallint not null check (confidence between 1 and 5),
  -- Probability of the confidence level at the time of logging, so recalibration never rewrites history.
  probability numeric(4, 3) not null check (probability > 0 and probability < 1),
  is_punter boolean not null default false,
  stake_units numeric(6, 2) check (stake_units > 0),
  bookmaker text,
  status text not null default 'pending' check (status in ('pending', 'won', 'lost', 'void')),
  closing_odd numeric(8, 3) check (closing_odd > 1),
  reference_odd numeric(8, 3) check (reference_odd > 1), -- future
  reference_bookmaker text, -- future
  reference_odd_at timestamptz, -- future
  notes text,
  created_at timestamptz not null default now(),
  settled_at timestamptz,
  check (not is_punter or stake_units is not null)
);

create table public.multiples (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  origin text not null check (origin in ('manual', 'generated')),
  generator_mode text check (
    generator_mode in ('confidence', 'value', 'highest_odds', 'lowest_odds', 'random', 'target_odd')
  ),
  generator_params jsonb,
  total_odd numeric(10, 3) not null check (total_odd > 1),
  stake_units numeric(6, 2) check (stake_units > 0),
  is_placed boolean not null default false,
  status text not null default 'pending' check (status in ('pending', 'won', 'lost', 'void')),
  created_at timestamptz not null default now(),
  settled_at timestamptz,
  check (not is_placed or stake_units is not null)
);

create table public.multiple_legs (
  multiple_id uuid not null references public.multiples on delete cascade,
  prediction_id uuid not null references public.predictions on delete restrict,
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  odd_at_selection numeric(8, 3) not null check (odd_at_selection > 1),
  primary key (multiple_id, prediction_id)
);

create table public.user_settings (
  user_id uuid primary key default auth.uid() references auth.users on delete cascade,
  unit_value numeric(10, 2) not null default 10 check (unit_value > 0),
  currency text not null default 'EUR',
  starting_bankroll_units numeric(10, 2),
  confidence_anchors jsonb not null default '{"1": 0.40, "2": 0.55, "3": 0.65, "4": 0.75, "5": 0.85}',
  odds_bands numeric[] not null default '{1.50, 1.80, 2.20, 3.00, 5.00}'
);

create index on public.predictions (user_id, created_at desc);
create index on public.predictions (event_id);
create index on public.events (user_id, kickoff_at);

do $$
declare
  t text;
begin
  foreach t in array array[
    'leagues', 'teams', 'team_aliases', 'events', 'markets',
    'predictions', 'multiples', 'multiple_legs', 'user_settings'
  ]
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format(
      'create policy "owner can do everything" on public.%I for all to authenticated '
      'using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))',
      t
    );
  end loop;
end
$$;
