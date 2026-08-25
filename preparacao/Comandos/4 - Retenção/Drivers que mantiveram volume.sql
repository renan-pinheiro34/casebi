WITH base AS (
    SELECT d.driver_uuid, g.grupo, AVG(d.pedidos) AS ped_base
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    WHERE d.week::DATE < DATE '2026-06-01'
    GROUP BY 1, 2
),
piloto AS (
    SELECT
        b.driver_uuid,
        b.grupo,
        BOOL_AND(d.pedidos >= b.ped_base) AS manteve_todas
    FROM base b
    JOIN dados_entregadores d ON d.driver_uuid = b.driver_uuid
    WHERE d.week::DATE >= DATE '2026-06-01'
    GROUP BY 1, 2
)
SELECT
    grupo,
    COUNT(*)                                                        AS n,
    COUNT(*) FILTER (WHERE manteve_todas)                           AS manteve,
    ROUND(100.0 * COUNT(*) FILTER (WHERE manteve_todas) / COUNT(*), 2) AS pct
FROM piloto
GROUP BY grupo
ORDER BY grupo;