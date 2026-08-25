WITH f AS (
    SELECT
        g.grupo,
        CASE WHEN d.week::DATE < DATE '2026-06-01'
             THEN 'baseline' ELSE 'piloto' END AS fase,
        AVG(d.pedidos)                    AS ped,
        AVG(d.worked_hours)::NUMERIC      AS wh
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    GROUP BY 1, 2
)
SELECT
    grupo,
    ROUND(MAX(ped) FILTER (WHERE fase='baseline'), 3)               AS ped_base,
    ROUND(MAX(ped) FILTER (WHERE fase='piloto'), 3)                 AS ped_piloto,
    ROUND(MAX(wh)  FILTER (WHERE fase='baseline'), 3)               AS wh_base,
    ROUND(MAX(wh)  FILTER (WHERE fase='piloto'), 3)                 AS wh_piloto,
    ROUND((MAX(wh) FILTER (WHERE fase='piloto')
         - MAX(wh) FILTER (WHERE fase='baseline'))
        * (MAX(ped) FILTER (WHERE fase='baseline')
         / MAX(wh)  FILTER (WHERE fase='baseline')), 3)             AS efeito_horas,
    ROUND((MAX(ped) FILTER (WHERE fase='piloto')
         - MAX(ped) FILTER (WHERE fase='baseline'))
        - (MAX(wh) FILTER (WHERE fase='piloto')
         - MAX(wh) FILTER (WHERE fase='baseline'))
        * (MAX(ped) FILTER (WHERE fase='baseline')
         / MAX(wh)  FILTER (WHERE fase='baseline')), 3)             AS efeito_produtividade
FROM f
GROUP BY grupo
ORDER BY grupo;