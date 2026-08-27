WITH base AS (
    SELECT d.driver_uuid, g.grupo, SUM(d.pedidos) / 4.0 AS base_semanal
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    WHERE d.week::DATE < DATE '2026-06-01'
    GROUP BY 1, 2
    HAVING SUM(d.pedidos) >= 50
)
SELECT
    d.week::DATE AS semana,
    b.grupo,
    COUNT(*)                                                                AS drivers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE d.pedidos < b.base_semanal * 0.9)
        / COUNT(*), 2)                                                      AS pct_caiu,
    ROUND(100.0 * COUNT(*) FILTER (WHERE d.pedidos BETWEEN b.base_semanal * 0.9
                                                      AND b.base_semanal * 1.1)
        / COUNT(*), 2)                                                      AS pct_manteve,
    ROUND(100.0 * COUNT(*) FILTER (WHERE d.pedidos > b.base_semanal * 1.1)
        / COUNT(*), 2)                                                      AS pct_aumentou,
    ROUND(AVG(d.pedidos), 2)                                                AS pedidos_medios
FROM base b
JOIN dados_entregadores d ON d.driver_uuid = b.driver_uuid
GROUP BY 1, 2
ORDER BY 1, 2;