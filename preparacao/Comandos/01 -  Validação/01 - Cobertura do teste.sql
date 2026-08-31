SELECT
    COALESCE(g.grupo, 'fora_teste') AS grupo,
    COUNT(DISTINCT d.driver_uuid)         AS drivers,
    ROUND(100.0 * COUNT(DISTINCT d.driver_uuid)
        / SUM(COUNT(DISTINCT d.driver_uuid)) OVER (), 1) AS pct
FROM dados_entregadores d
LEFT JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
GROUP BY 1
ORDER BY 2 DESC;
