-- Tables intermediaires pour les fichiers IMDb
-- Les colonnes sont en TEXT pour faciliter le chargement

CREATE UNLOGGED TABLE IF NOT EXISTS import_title_basics (
    tconst TEXT,
    title_type TEXT,
    primary_title TEXT,
    original_title TEXT,
    is_adult TEXT,
    start_year TEXT,
    end_year TEXT,
    runtime_minutes TEXT,
    genres TEXT
);

CREATE UNLOGGED TABLE IF NOT EXISTS import_name_basics (
    nconst TEXT,
    primary_name TEXT,
    birth_year TEXT,
    death_year TEXT,
    primary_profession TEXT,
    known_for_titles TEXT
);

CREATE UNLOGGED TABLE IF NOT EXISTS import_title_principals (
    tconst TEXT,
    ordering TEXT,
    nconst TEXT,
    category TEXT,
    job TEXT,
    characters TEXT
);

CREATE UNLOGGED TABLE IF NOT EXISTS import_title_crew (
    tconst TEXT,
    directors TEXT,
    writers TEXT
);

CREATE UNLOGGED TABLE IF NOT EXISTS import_title_ratings (
    tconst TEXT,
    average_rating TEXT,
    num_votes TEXT
);

CREATE UNLOGGED TABLE IF NOT EXISTS import_title_episode (
    tconst TEXT,
    parent_tconst TEXT,
    season_number TEXT,
    episode_number TEXT
);

CREATE UNLOGGED TABLE IF NOT EXISTS import_title_akas (
    title_id TEXT,
    ordering TEXT,
    title TEXT,
    region TEXT,
    language TEXT,
    types TEXT,
    attributes TEXT,
    is_original_title TEXT
);

-- Vider les tables intermediaires avant chaque importation
TRUNCATE TABLE
    import_title_basics,
    import_name_basics,
    import_title_principals,
    import_title_crew,
    import_title_ratings,
    import_title_episode,
    import_title_akas;
