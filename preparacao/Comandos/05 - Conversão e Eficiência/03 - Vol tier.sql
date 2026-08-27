WITH mensal AS (
    SELECT
        driver_uuid,
        SUM(pedidos) FILTER (WHERE week::DATE <  DATE '2026-06-01') AS pedidos_baseline,
        SUM(pedidos) FILTER (WHERE week::DATE >= DATE '2026-06-01') AS pedidos_piloto
    FROM dados_entregadores
    GROUP BY 1
),
faixas AS (
    SELECT
        g.grupo,
        CASE
            WHEN m.pedidos_baseline <= 29             THEN '1_ate_29'
            WHEN m.pedidos_baseline BETWEEN 30 AND 49 THEN '2_30_49'
            WHEN m.pedidos_baseline BETWEEN 50 AND 99 THEN '3_50_99'
            ELSE '4_100_mais'
        END AS faixa_baseline,
        CASE
            WHEN m.pedidos_piloto <= 29             THEN '1_ate_29'
            WHEN m.pedidos_piloto BETWEEN 30 AND 49 THEN '2_30_49'
            WHEN m.pedidos_piloto BETWEEN 50 AND 99 THEN '3_50_99'
            ELSE '4_100_mais'
        END AS faixa_piloto
    FROM mensal m
    JOIN grupos_entregadores g ON g.driver_uuid = m.driver_uuid
)
SELECT
    faixa_baseline,
    faixa_piloto,
    COUNT(*) FILTER (WHERE grupo = 'controle')   AS controle,
    COUNT(*) FILTER (WHERE grupo = 'tratamento') AS tratamento
FROM faixas
GROUP BY faixa_baseline, faixa_piloto
ORDER BY faixa_baseline, faixa_piloto;