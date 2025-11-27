CREATE OR REPLACE TABLE games_sample AS
SELECT * FROM read_json('/Users/olehbondar/games_sample.json',  maximum_object_size=157286400);
CREATE OR REPLACE TABLE reviews_sample AS
SELECT * FROM read_json('/Users/olehbondar/reviews_sample.json',  maximum_object_size=157286400);

DESCRIBE games_sample;
DESCRIBE reviews_sample;

---

DROP TABLE IF EXISTS games_parsed;

CREATE TABLE games_parsed AS
WITH raw_unnest AS (
    SELECT UNNEST(games) AS g FROM games_sample
)
SELECT
    g.app_details.data.steam_appid AS app_id,
    g.app_details.data.name AS title,
    COALESCE(TRY_CAST(g.app_details.data.price_overview.final AS DOUBLE) / 100.0, 0.0) AS price,
    TRY_STRPTIME(g.app_details.data.release_date.date, '%b %d, %Y') AS release_date,
    g.app_details.data.genres AS genres,
    g.app_details.data.categories AS categories,
    g.app_details.data.developers AS developers
FROM raw_unnest
WHERE g.app_details.data.steam_appid IS NOT NULL
  AND g.app_details.data.name IS NOT NULL;

---

DROP TABLE IF EXISTS reviews_parsed;

CREATE TABLE reviews_parsed AS
WITH raw_games_list AS (
    SELECT UNNEST(reviews) AS g FROM reviews_sample
)
SELECT
    g.appid,
    r.recommendationid,
    r.voted_up,
    r.votes_up,
    r.votes_funny,
    r.comment_count,
    COALESCE(r.steam_purchase, false) AS steam_purchase,
    COALESCE(r.received_for_free, false) AS received_for_free,
    to_timestamp(r.timestamp_created) AS created_at,
    to_timestamp(r.timestamp_updated) AS updated_at,
    r.review AS review_text,
    r.author.num_games_owned,
    r.author.playtime_forever AS playtime_minutes
FROM raw_games_list,
     UNNEST(g.review_data.reviews) AS t(r)
WHERE r.recommendationid IS NOT NULL;

---

SELECT * FROM reviews_parsed
SELECT * FROM games_parsed