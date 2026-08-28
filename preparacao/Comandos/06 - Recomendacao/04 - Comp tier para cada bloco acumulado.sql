WITH mensal AS (
    SELECT d.driver_uuid, SUM(d.pedidos) AS pedidos_piloto
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    WHERE g.grupo = 'tratamento' AND d.week::DATE >= DATE '2026-06-01'
    GROUP BY 1
),
blocos AS (
    SELECT
        LEAST(FLOOR(m.pedidos_piloto / 50), 6)::INT AS blocos,
        t.tier_simulation                           AS tier
    FROM mensal m
    JOIN tier_entregadores t
      ON t.driver_uuid = m.driver_uuid AND t.mes::DATE = DATE '2026-06-01'
)
SELECT
    blocos,
    COUNT(*)                                                               AS drivers,
    COUNT(*) FILTER (WHERE tier = 'Regular')                               AS regular,
    COUNT(*) FILTER (WHERE tier = 'Ouro')                                  AS ouro,
    COUNT(*) FILTER (WHERE tier = 'Diamante')                              AS diamante,
    ROUND(100.0 * COUNT(*) FILTER (WHERE tier = 'Ouro')     / COUNT(*), 1) AS pct_ouro,
    ROUND(100.0 * COUNT(*) FILTER (WHERE tier = 'Diamante') / COUNT(*), 1) AS pct_diamante,
    COUNT(*) * LEAST(blocos * 175, 1100)                                   AS custo
FROM blocos
GROUP BY blocos
ORDER BY blocos;