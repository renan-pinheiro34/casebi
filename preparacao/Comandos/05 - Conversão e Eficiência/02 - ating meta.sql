WITH mensal AS (
    SELECT d.driver_uuid, g.grupo, SUM(d.pedidos) AS pedidos_piloto
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    WHERE d.week::DATE >= DATE '2026-06-01'
    GROUP BY 1, 2
)
SELECT
    grupo,
    COUNT(*)                                                                  AS drivers,
    COUNT(*) FILTER (WHERE pedidos_piloto >= 50)                              AS atingiram_50,
    ROUND(100.0 * COUNT(*) FILTER (WHERE pedidos_piloto >= 50) / COUNT(*), 2) AS pct
FROM mensal
GROUP BY grupo
ORDER BY grupo;