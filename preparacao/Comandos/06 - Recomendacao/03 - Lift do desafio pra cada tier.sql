WITH mensal AS (
    SELECT d.driver_uuid, SUM(d.pedidos) AS pedidos_baseline
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    WHERE g.grupo = 'tratamento' AND d.week::DATE < DATE '2026-06-01'
    GROUP BY 1
),
medianas AS (
    SELECT
        t.tier_simulation AS tier,
        PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY m.pedidos_baseline) AS mediana_maio
    FROM mensal m
    JOIN tier_entregadores t
      ON t.driver_uuid = m.driver_uuid AND t.mes::DATE = DATE '2026-06-01'
    GROUP BY 1
)
SELECT
    tier,
    mediana_maio,
    ROUND(100.0 *  50 / mediana_maio, 0) AS desafio_50_pct_do_que_faz,
    ROUND(100.0 * 300 / mediana_maio, 0) AS teto_300_pct_do_que_faz
FROM medianas
ORDER BY mediana_maio;