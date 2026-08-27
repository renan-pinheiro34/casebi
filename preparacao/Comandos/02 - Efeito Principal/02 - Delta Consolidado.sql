-- Q04. DiD consolidado
WITH base AS (
    SELECT
        g.grupo,
        CASE WHEN d.week::DATE < DATE '2026-06-01' THEN 'baseline' ELSE 'piloto' END AS fase,
        AVG(d.pedidos)                 AS pedidos,
        AVG(d.supply_hours)::NUMERIC   AS sh,
        AVG(d.worked_hours)::NUMERIC   AS wh,
        AVG(d.ganho_total::NUMERIC) / AVG(d.supply_hours)::NUMERIC AS ganho_hora
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    GROUP BY 1, 2
)
SELECT
    grupo,
    ROUND(MAX(pedidos)    FILTER (WHERE fase='piloto') - MAX(pedidos)    FILTER (WHERE fase='baseline'), 2) AS delta_pedidos,
    ROUND(MAX(sh)         FILTER (WHERE fase='piloto') - MAX(sh)         FILTER (WHERE fase='baseline'), 2) AS delta_sh,
    ROUND(MAX(wh)         FILTER (WHERE fase='piloto') - MAX(wh)         FILTER (WHERE fase='baseline'), 2) AS delta_wh,
    ROUND(MAX(ganho_hora) FILTER (WHERE fase='piloto') - MAX(ganho_hora) FILTER (WHERE fase='baseline'), 2) AS delta_ganho_hora
FROM base
GROUP BY grupo ORDER BY grupo;