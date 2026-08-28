WITH mensal AS (
    SELECT
        d.driver_uuid,
        SUM(d.pedidos) FILTER (WHERE d.week::DATE <  DATE '2026-06-01') AS pedidos_baseline,
        SUM(d.pedidos) FILTER (WHERE d.week::DATE >= DATE '2026-06-01') AS pedidos_piloto
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    WHERE g.grupo = 'tratamento'
    GROUP BY 1
)
SELECT
    t.tier_simulation                                                AS tier,
    COUNT(*)                                                         AS drivers,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY m.pedidos_baseline)  AS mediana_maio,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY m.pedidos_piloto)    AS mediana_junho,
    ROUND(100.0 * COUNT(*) FILTER (WHERE m.pedidos_baseline >= 50)
        / COUNT(*), 1)                                               AS pct_ja_fazia_50
FROM mensal m
JOIN tier_entregadores t
  ON t.driver_uuid = m.driver_uuid AND t.mes::DATE = DATE '2026-06-01'
GROUP BY t.tier_simulation
ORDER BY mediana_maio;