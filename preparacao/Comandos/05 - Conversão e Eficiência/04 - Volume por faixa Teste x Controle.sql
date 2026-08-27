WITH mensal AS (
    SELECT d.driver_uuid, g.grupo, SUM(d.pedidos) AS pedidos_baseline
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    WHERE d.week::DATE < DATE '2026-06-01'
    GROUP BY 1, 2
)
SELECT
    percentil,
    pedidos_baseline,
    ROUND((50.0 / GREATEST(pedidos_baseline, 1) - 1) * 100, 0) AS lift_necessario_pct
FROM (
    SELECT
        p AS percentil,
        PERCENTILE_DISC(p) WITHIN GROUP (ORDER BY pedidos_baseline) AS pedidos_baseline
    FROM mensal, (VALUES (0.50), (0.60), (0.70), (0.75), (0.80), (0.82), (0.85)) AS v(p)
    WHERE grupo = 'tratamento'
    GROUP BY p
) q
ORDER BY percentil;