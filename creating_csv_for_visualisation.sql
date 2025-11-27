COPY (
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
ORDER BY avg_price_usd DESC
    ) TO 'steam_prices.csv';