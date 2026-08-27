-- Q10. Composição de tier em junho
SELECT
    g.grupo,
    COUNT(*) FILTER (WHERE t.tier_simulation = 'Diamante') AS diamante,
    COUNT(*) FILTER (WHERE t.tier_simulation = 'Ouro')     AS ouro,
    COUNT(*) FILTER (WHERE t.tier_simulation = 'Regular')  AS regular,
    ROUND(100.0 * COUNT(*) FILTER (WHERE t.tier_simulation <> 'Regular')
        / COUNT(*), 2)                                     AS pct_super
FROM tier_entregadores t
JOIN grupos_entregadores g ON g.driver_uuid = t.driver_uuid
WHERE t.mes::DATE = DATE '2026-06-01'
GROUP BY g.grupo;