WITH mensal AS (
    SELECT
        d.driver_uuid, g.grupo,
        SUM(d.pedidos) FILTER (WHERE d.week::DATE <  DATE '2026-06-01') AS pedidos_baseline,
        SUM(d.pedidos) FILTER (WHERE d.week::DATE >= DATE '2026-06-01') AS pedidos_piloto
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    GROUP BY 1, 2
)
SELECT
    CASE WHEN pedidos_baseline >= 50 THEN 'ja_fazia_50' ELSE 'fazia_menos_50' END AS bucket,
    COUNT(*) FILTER (WHERE grupo = 'tratamento')                                  AS drivers,
    ROUND(AVG(pedidos_piloto - pedidos_baseline) FILTER (WHERE grupo = 'tratamento')
        - AVG(pedidos_piloto - pedidos_baseline) FILTER (WHERE grupo = 'controle'), 1) AS delta_por_driver,
    ROUND((AVG(pedidos_piloto - pedidos_baseline) FILTER (WHERE grupo = 'tratamento')
         - AVG(pedidos_piloto - pedidos_baseline) FILTER (WHERE grupo = 'controle'))
        * COUNT(*) FILTER (WHERE grupo = 'tratamento'), 0)                        AS pedidos,
    SUM(LEAST(FLOOR(pedidos_piloto / 50) * 175, 1100))
        FILTER (WHERE grupo = 'tratamento')                                       AS custo
FROM mensal
GROUP BY 1
ORDER BY 1;