SELECT
    d.week::DATE AS semana,
    g.grupo,
    ROUND(AVG(d.pedidos), 3)                 AS pedidos,
    ROUND(AVG(d.supply_hours)::NUMERIC, 3)   AS supply_hours,
    ROUND(AVG(d.worked_hours)::NUMERIC, 3)   AS worked_hours,
    ROUND(AVG(d.ganho_promocao::NUMERIC), 2) AS promo
FROM dados_entregadores d
JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
GROUP BY 1, 2
ORDER BY 1, 2;