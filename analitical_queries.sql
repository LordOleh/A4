SELECT
    g.title,
    COUNT(r.recommendationid) AS review_count
FROM games_parsed g
         JOIN reviews_parsed r ON g.app_id = r.appid
GROUP BY g.title
ORDER BY review_count DESC
LIMIT 20;

--This query joins the game metadata with the reviews
--table to count the total number of reviews per title.

SELECT
    EXTRACT(YEAR FROM release_date) AS release_year,
    COUNT(*) AS game_count
FROM games_parsed
WHERE release_date IS NOT NULL AND release_date <= '2025-12-31'
GROUP BY release_year
ORDER BY release_year DESC;

--By extracting the year from the parsed date field, we see the temporal distribution of releases.
--This typically reveals a sharp trend toward recent years (2020–2025), reflecting the exponential growth of Steam's catalog.

SELECT
    CASE
        WHEN genre_item.description IN ('Симуляторы', 'Simulação', 'Simülasyon') THEN 'Simulation'
        WHEN genre_item.description IN ('Инди', 'Indépendant') THEN 'Indie'
        WHEN genre_item.description IN ('Экшены', 'Acción', 'Ação', 'Aksiyon') THEN 'Action'
        WHEN genre_item.description IN ('Aventura') THEN 'Adventure'
        WHEN genre_item.description IN ('Strateji') THEN 'Strategy'
        WHEN genre_item.description IN ('Multijogador Massivo') THEN 'Massively Multiplayer'
        ELSE genre_item.description
        END AS normalized_genre,
    COUNT(*) AS games_in_genre,
    ROUND(AVG(price), 2) AS avg_price_usd
FROM games_parsed,
     UNNEST(genres) AS t(genre_item)
WHERE price > 0
GROUP BY normalized_genre
ORDER BY avg_price_usd DESC;

--This query normalizes multilingual genre names to calculate the average price per category.
--The results highlight that professional tools ("Animation & Modeling" at ~$46) and complex genres
--like "Simulation" and "Strategy" (~$21) command significantly higher prices
--compared to popular genres like "Action", "Indie", and "Casual", which average under $10.

SELECT
    cat_item.description AS category_tag,
    COUNT(*) AS frequency
FROM games_parsed,
     UNNEST(categories) AS t(cat_item)
GROUP BY category_tag
ORDER BY frequency DESC
LIMIT 10;

--This analysis counts the frequency of tags (like "Single-player" or "Full controller support") across all games.
--It confirms that despite the buzz around multiplayer,
--single-player experiences remain the most common foundation of the library.

SELECT
    voted_up AS is_positive_review,
    COUNT(*) AS total_reviews,
    CAST(AVG(playtime_minutes) / 60 AS INT) AS avg_hours_played
FROM reviews_parsed
GROUP BY voted_up;

--This compares the average playtime of users who left positive reviews versus those who left negative ones.
--Interestingly, it often reveals that negative reviewers still invest significant time (e.g., 20+ hours)
--into a game before deciding they don't like it.

