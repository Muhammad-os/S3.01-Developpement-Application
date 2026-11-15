-- schema_v2.sql
-- SAÉ 3.01 livrable 5 — PostgreSQL v11 ou plus pour utiliser INCLUDE, extensions pg_trgm et unaccent
-- FORTES CHANCES DE CHANGEMENT DU CODE

-- Partie 1: Extensions et fonction f_unaccent
-- Partie 2: Tables avec PK, NOT NULL et CHECK
-- Partie 3: Clés étrangères
-- Partie 4: Index

-- Partie 1: Extensions et fonction f_unaccent
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE OR REPLACE FUNCTION public.f_unaccent(text)
RETURNS text LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT AS
$$ SELECT public.unaccent('public.unaccent', $1) $$;

-- Partie 2: Tables avec PK, NOT NULL et CHECK

CREATE TABLE genre (genre_id serial PRIMARY KEY, name text NOT NULL UNIQUE);
CREATE TABLE profession (profession_id serial PRIMARY KEY, name text NOT NULL UNIQUE);

CREATE TABLE title_basics (
  tconst text PRIMARY KEY,
  title_type text NOT NULL,
  primary_title text NOT NULL,
  original_title text,
  is_adult boolean NOT NULL,
  start_year integer,
  end_year integer,
  runtime_minutes integer,
  CONSTRAINT ck_tb_tconst CHECK (tconst ~ '^tt[0-9]+$'),
  CONSTRAINT ck_tb_start CHECK (start_year BETWEEN 1800 AND 2100),
  CONSTRAINT ck_tb_end CHECK (end_year   BETWEEN 1800 AND 2100),
  CONSTRAINT ck_tb_order CHECK (start_year IS NULL OR end_year IS NULL OR end_year >= start_year),
  CONSTRAINT ck_tb_runtime CHECK (runtime_minutes > 0)
);

CREATE TABLE name_basics (
  nconst text PRIMARY KEY,
  primary_name text NOT NULL,
  birth_year integer,
  death_year integer,
  CONSTRAINT ck_nb_nconst CHECK (nconst ~ '^nm[0-9]+$'),
  CONSTRAINT ck_nb_birth CHECK (birth_year BETWEEN 1000 AND 2100),
  CONSTRAINT ck_nb_death CHECK (death_year BETWEEN 1000 AND 2100),
  CONSTRAINT ck_nb_order CHECK (birth_year IS NULL OR death_year IS NULL OR death_year >= birth_year)
);

-- Listes éclatées
CREATE TABLE title_genre (tconst text NOT NULL, genre_id integer NOT NULL, PRIMARY KEY (tconst, genre_id));

CREATE TABLE title_director (tconst text NOT NULL, nconst text NOT NULL, PRIMARY KEY (tconst, nconst));

CREATE TABLE title_writer (tconst text NOT NULL, nconst text NOT NULL, PRIMARY KEY (tconst, nconst));

CREATE TABLE name_profession (nconst text NOT NULL, profession_id integer NOT NULL, PRIMARY KEY (nconst, profession_id));

-- Rôles et notes
CREATE TABLE title_principals (
  tconst text NOT NULL,
  ordering integer NOT NULL,
  nconst text NOT NULL,
  category text NOT NULL,
  job text,
  characters text,   -- tableau JSON brut conservé tel quel (valeur atomique non exploitée)
  PRIMARY KEY (tconst, ordering),
  CONSTRAINT ck_pr_ordering CHECK (ordering > 0)
);

CREATE TABLE title_ratings (
  tconst text PRIMARY KEY,
  average_rating numeric(3,1) NOT NULL,
  num_votes integer NOT NULL,
  CONSTRAINT ck_rt_rating CHECK (average_rating BETWEEN 0 AND 10),
  CONSTRAINT ck_rt_votes  CHECK (num_votes >= 0)
);

-- Titres alternatifs
CREATE TABLE title_akas (
  title_id text NOT NULL,
  ordering integer NOT NULL,
  title text NOT NULL,
  region text,
  language text,
  is_original_title boolean,
  PRIMARY KEY (title_id, ordering),
  CONSTRAINT ck_aka_ordering CHECK (ordering > 0)
);

-- Séries / épisodes
CREATE TABLE title_episode (
  tconst text PRIMARY KEY,
  parent_tconst text NOT NULL,
  season_number integer,
  episode_number integer,
  CONSTRAINT ck_ep_self   CHECK (parent_tconst <> tconst),
  CONSTRAINT ck_ep_season CHECK (season_number  >= 0),
  CONSTRAINT ck_ep_number CHECK (episode_number >= 0)
);

-- Table dérivée de title_principals
-- pour le graphe « a joué dans »
CREATE TABLE acted_in (
  nconst text NOT NULL,
  tconst text NOT NULL,
  PRIMARY KEY (nconst, tconst)
);

-- Partie 3: Clés étrangères
ALTER TABLE title_genre ADD CONSTRAINT fk_tg_title FOREIGN KEY (tconst)   REFERENCES title_basics(tconst) ON DELETE CASCADE;
ALTER TABLE title_genre ADD CONSTRAINT fk_tg_genre FOREIGN KEY (genre_id) REFERENCES genre(genre_id);

ALTER TABLE title_director ADD CONSTRAINT fk_td_title FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;
ALTER TABLE title_director ADD CONSTRAINT fk_td_name  FOREIGN KEY (nconst) REFERENCES name_basics(nconst) ON DELETE CASCADE;

ALTER TABLE title_writer ADD CONSTRAINT fk_tw_title FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;
ALTER TABLE title_writer ADD CONSTRAINT fk_tw_name  FOREIGN KEY (nconst) REFERENCES name_basics(nconst) ON DELETE CASCADE;

ALTER TABLE name_profession ADD CONSTRAINT fk_np_name FOREIGN KEY (nconst)        REFERENCES name_basics(nconst) ON DELETE CASCADE;
ALTER TABLE name_profession ADD CONSTRAINT fk_np_prof FOREIGN KEY (profession_id) REFERENCES profession(profession_id);

ALTER TABLE title_principals ADD CONSTRAINT fk_pr_title FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;
ALTER TABLE title_principals ADD CONSTRAINT fk_pr_name  FOREIGN KEY (nconst) REFERENCES name_basics(nconst)  ON DELETE CASCADE;

ALTER TABLE title_ratings ADD CONSTRAINT fk_rating_title FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

ALTER TABLE title_akas ADD CONSTRAINT fk_aka_title FOREIGN KEY (title_id) REFERENCES title_basics(tconst) ON DELETE CASCADE;

ALTER TABLE title_episode ADD CONSTRAINT fk_ep_title  FOREIGN KEY (tconst)        REFERENCES title_basics(tconst) ON DELETE CASCADE;
ALTER TABLE title_episode ADD CONSTRAINT fk_ep_parent FOREIGN KEY (parent_tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

ALTER TABLE acted_in ADD CONSTRAINT fk_acted_name  FOREIGN KEY (nconst) REFERENCES name_basics(nconst) ON DELETE CASCADE;
ALTER TABLE acted_in ADD CONSTRAINT fk_acted_title FOREIGN KEY (tconst) REFERENCES title_basics(tconst) ON DELETE CASCADE;

-- Partie 4: Index
CREATE INDEX idx_title_start_year ON title_basics (start_year);
CREATE INDEX idx_name_birth_year ON name_basics (birth_year);
CREATE INDEX idx_ratings_votes ON title_ratings (num_votes DESC);
CREATE INDEX idx_episode_parent ON title_episode (parent_tconst, season_number, episode_number);

CREATE INDEX idx_title_genre_genre ON title_genre (genre_id, tconst);
CREATE INDEX idx_title_director_nconst ON title_director (nconst, tconst);
CREATE INDEX idx_title_writer_nconst ON title_writer (nconst, tconst);
CREATE INDEX idx_name_profession_prof ON name_profession (profession_id, nconst);

CREATE INDEX idx_principals_nconst ON title_principals (nconst) INCLUDE (tconst, category);

CREATE INDEX idx_acted_in_title ON acted_in (tconst, nconst);

-- Index trigrammes pour la recherche approximative. Insensible aux accents et à la casse.
-- Les requêtes doivent reprendre exactement l'expression indexée
SET maintenance_work_mem = '1GB';   -- on peut l'adapter à la RAM

CREATE INDEX idx_name_trgm ON name_basics
  USING gin (public.f_unaccent(primary_name) gin_trgm_ops);

CREATE INDEX idx_title_trgm ON title_basics
  USING gin (public.f_unaccent(primary_title) gin_trgm_ops)
  WHERE title_type <> 'tvEpisode';

CREATE INDEX idx_akas_title_trgm ON title_akas
  USING gin (public.f_unaccent(title) gin_trgm_ops)
  WHERE region = 'FR' OR language = 'fr';

RESET maintenance_work_mem;