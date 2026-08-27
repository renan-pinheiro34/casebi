WITH pool AS (
    SELECT d.driver_uuid, g.grupo
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    WHERE d.week::DATE < DATE '2026-06-01'
    GROUP BY 1, 2
    HAVING SUM(d.pedidos) >= 50
),
referencia AS (
    SELECT d.driver_uuid, AVG(d.pedidos) AS media_semanal_baseline
    FROM dados_entregadores d
    JOIN pool p ON p.driver_uuid = d.driver_uuid
    WHERE d.week::DATE < DATE '2026-06-01'
    GROUP BY 1
),
status AS (
    SELECT
        d.week::DATE AS data,
        p.grupo,
        d.driver_uuid,
        d.pedidos,
        CASE
            WHEN d.pedidos < r.media_semanal_baseline * 0.9 THEN 'caiu'
            WHEN d.pedidos > r.media_semanal_baseline * 1.1 THEN 'aumentou'
            ELSE 'manteve'
        END AS situacao
    FROM dados_entregadores d
    JOIN pool p        ON p.driver_uuid = d.driver_uuid
    JOIN referencia r  ON r.driver_uuid = d.driver_uuid
)
SELECT
    data,
    grupo,
    COUNT(*)                                                                  AS drivers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE situacao = 'caiu')     / COUNT(*), 2) AS pct_caiu,
    ROUND(100.0 * COUNT(*) FILTER (WHERE situacao = 'manteve')  / COUNT(*), 2) AS pct_manteve,
    ROUND(100.0 * COUNT(*) FILTER (WHERE situacao = 'aumentou') / COUNT(*), 2) AS pct_aumentou,
    ROUND(AVG(pedidos)::NUMERIC, 2)                                           AS pedidos_medios
FROM status
GROUP BY data, grupo
ORDER BY data, grupo;