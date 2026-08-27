SELECT
    g.grupo,
    COUNT(*)                                                  AS drivers,
    COUNT(*) FILTER (WHERE t.tier_simulation <> 'Regular')    AS super,
    ROUND(100.0 * COUNT(*) FILTER (WHERE t.tier_simulation <> 'Regular')
        / COUNT(*), 2)                                        AS pct_super
FROM tier_entregadores t
JOIN grupos_entregadores g ON g.driver_uuid = t.driver_uuid
WHERE t.mes::DATE = DATE '2026-06-01'
GROUP BY g.grupo
ORDER BY g.grupo;