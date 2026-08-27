SELECT
    d.week::DATE AS semana,
    g.grupo,
    ROUND(AVG(d.pedidos), 2)                                  AS pedidos,
    ROUND(AVG(d.supply_hours)::NUMERIC, 2)                    AS sh,
    ROUND(AVG(d.worked_hours)::NUMERIC, 2)                    AS wh,
    ROUND(100.0 * SUM(d.rotas_rejeitadas)
        / NULLIF(SUM(d.rotas_totais), 0), 2)                  AS rejeite,
    ROUND(AVG(d.ganho_total::NUMERIC)
        / NULLIF(AVG(d.supply_hours)::NUMERIC, 0), 2)         AS ganho_por_hora,
    ROUND(AVG(d.ganho_promocao::NUMERIC), 2)                  AS promo
FROM dados_entregadores d
JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
GROUP BY 1, 2
ORDER BY 1, 2;

