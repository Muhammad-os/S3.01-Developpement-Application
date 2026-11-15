
-- Transformation des donnees IMDb
-- Compatible avec le schema SQL du groupe

-- 1. Vider les tables definitives
TRUNCATE TABLE
    acted_in, title_genre, title_director,
    title_writer, name_profession,
    title_principals, title_ratings,
    title_akas, title_episode,
    genre, profession, title_basics, name_basics
RESTART IDENTITY;


-- 2. Importer les titres
WITH donnees AS (
    SELECT *,
        CASE WHEN start_year ~ '^[0-9]{4}$'
             THEN start_year::integer END AS annee_debut,
        CASE WHEN end_year ~ '^[0-9]{4}$'
             THEN end_year::integer END AS annee_fin,
        CASE WHEN runtime_minutes ~ '^[0-9]{1,8}$'
             THEN runtime_minutes::integer END AS duree
    FROM import_title_basics
)
INSERT INTO title_basics (
    tconst, title_type, primary_title, original_title,
    is_adult, start_year, end_year, runtime_minutes
)
SELECT
    tconst, title_type, primary_title, original_title,
    (is_adult = '1'),
    CASE WHEN annee_debut BETWEEN 1800 AND 2100
         THEN annee_debut END,
    CASE WHEN annee_fin BETWEEN 1800 AND 2100
          AND (annee_debut IS NULL
               OR annee_debut NOT BETWEEN 1800 AND 2100
               OR annee_fin >= annee_debut)
         THEN annee_fin END,
    CASE WHEN duree > 0 THEN duree END
FROM donnees
WHERE tconst ~ '^tt[0-9]+$'
  AND title_type IS NOT NULL
  AND primary_title IS NOT NULL
  AND is_adult IN ('0', '1');


-- 3. Importer les personnes
WITH donnees AS (
    SELECT *,
        CASE WHEN birth_year ~ '^[0-9]{4}$'
             THEN birth_year::integer END AS naissance,
        CASE WHEN death_year ~ '^[0-9]{4}$'
             THEN death_year::integer END AS deces
    FROM import_name_basics
)
INSERT INTO name_basics (
    nconst, primary_name, birth_year, death_year
)
SELECT
    nconst, primary_name,
    CASE WHEN naissance BETWEEN 1000 AND 2100
         THEN naissance END,
    CASE WHEN deces BETWEEN 1000 AND 2100
          AND (naissance IS NULL
               OR naissance NOT BETWEEN 1000 AND 2100
               OR deces >= naissance)
         THEN deces END
FROM donnees
WHERE nconst ~ '^nm[0-9]+$'
  AND primary_name IS NOT NULL;


-- 4. Importer les genres
INSERT INTO genre (name)
SELECT DISTINCT TRIM(g.valeur)
FROM import_title_basics b
JOIN title_basics t ON t.tconst = b.tconst
CROSS JOIN LATERAL
    unnest(string_to_array(b.genres, ',')) AS g(valeur)
WHERE TRIM(g.valeur) <> '';

INSERT INTO title_genre (tconst, genre_id)
SELECT DISTINCT t.tconst, g.genre_id
FROM import_title_basics b
JOIN title_basics t ON t.tconst = b.tconst
CROSS JOIN LATERAL
    unnest(string_to_array(b.genres, ',')) AS x(valeur)
JOIN genre g ON g.name = TRIM(x.valeur);


-- 5. Importer les professions
INSERT INTO profession (name)
SELECT DISTINCT TRIM(p.valeur)
FROM import_name_basics b
JOIN name_basics n ON n.nconst = b.nconst
CROSS JOIN LATERAL
    unnest(string_to_array(b.primary_profession, ',')) AS p(valeur)
WHERE TRIM(p.valeur) <> '';

INSERT INTO name_profession (nconst, profession_id)
SELECT DISTINCT n.nconst, p.profession_id
FROM import_name_basics b
JOIN name_basics n ON n.nconst = b.nconst
CROSS JOIN LATERAL
    unnest(string_to_array(b.primary_profession, ',')) AS x(valeur)
JOIN profession p ON p.name = TRIM(x.valeur);


-- 6. Importer les realisateurs
INSERT INTO title_director (tconst, nconst)
SELECT DISTINCT t.tconst, n.nconst
FROM import_title_crew c
JOIN title_basics t ON t.tconst = c.tconst
CROSS JOIN LATERAL
    unnest(string_to_array(c.directors, ',')) AS x(valeur)
JOIN name_basics n ON n.nconst = TRIM(x.valeur);


-- 7. Importer les scenaristes
INSERT INTO title_writer (tconst, nconst)
SELECT DISTINCT t.tconst, n.nconst
FROM import_title_crew c
JOIN title_basics t ON t.tconst = c.tconst
CROSS JOIN LATERAL
    unnest(string_to_array(c.writers, ',')) AS x(valeur)
JOIN name_basics n ON n.nconst = TRIM(x.valeur);


-- 8. Importer les participations
INSERT INTO title_principals (
    tconst, ordering, nconst, category, job, characters
)
SELECT
    p.tconst, p.ordering::integer, p.nconst,
    p.category, p.job, p.characters
FROM import_title_principals p
JOIN title_basics t ON t.tconst = p.tconst
JOIN name_basics n ON n.nconst = p.nconst
WHERE p.ordering ~ '^[1-9][0-9]{0,7}$'
  AND p.category IS NOT NULL;


-- 9. Importer les notes
WITH donnees AS (
    SELECT tconst,
        CASE WHEN average_rating ~ '^([0-9]|10)([.][0-9])?$'
             THEN average_rating::numeric END AS note,
        CASE WHEN num_votes ~ '^[0-9]{1,9}$'
             THEN num_votes::integer END AS votes
    FROM import_title_ratings
)
INSERT INTO title_ratings (
    tconst, average_rating, num_votes
)
SELECT d.tconst, d.note, d.votes
FROM donnees d
JOIN title_basics t ON t.tconst = d.tconst
WHERE d.note BETWEEN 0 AND 10
  AND d.votes >= 0;


-- 10. Importer les episodes
INSERT INTO title_episode (
    tconst, parent_tconst, season_number, episode_number
)
SELECT
    e.tconst, e.parent_tconst,
    CASE WHEN e.season_number ~ '^[0-9]{1,8}$'
         THEN e.season_number::integer END,
    CASE WHEN e.episode_number ~ '^[0-9]{1,8}$'
         THEN e.episode_number::integer END
FROM import_title_episode e
JOIN title_basics t ON t.tconst = e.tconst
JOIN title_basics parent ON parent.tconst = e.parent_tconst
WHERE e.tconst <> e.parent_tconst;


-- 11. Importer les titres alternatifs
INSERT INTO title_akas (
    title_id, ordering, title, region,
    language, is_original_title
)
SELECT
    a.title_id, a.ordering::integer, a.title,
    a.region, a.language,
    CASE WHEN a.is_original_title IN ('0', '1')
         THEN a.is_original_title::boolean END
FROM import_title_akas a
JOIN title_basics t ON t.tconst = a.title_id
WHERE a.ordering ~ '^[1-9][0-9]{0,7}$'
  AND a.title IS NOT NULL;

-- 12. Construre la relation "a joue dans"
INSERT INTO acted_in (nconst, tconst)
SELECT DISTINCT p.nconst, p.tconst
FROM title_principals p
JOIN title_basics t ON t.tconst = p.tconst
WHERE p.category IN ('actor', 'actress')
  AND t.title_type <> 'tvEpisode';

