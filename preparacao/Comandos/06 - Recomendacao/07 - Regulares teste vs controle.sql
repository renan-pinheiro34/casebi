WITH mensal AS (
    SELECT
        d.driver_uuid,
        g.grupo,
        SUM(d.pedidos) FILTER (WHERE d.week::DATE <  DATE '2026-06-01') AS pedidos_baseline,
        SUM(d.pedidos) FILTER (WHERE d.week::DATE >= DATE '2026-06-01') AS pedidos_piloto
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    GROUP BY 1, 2
),
base AS (
    SELECT grupo, pedidos_piloto
    FROM mensal
    WHERE pedidos_baseline < 50
)
SELECT
    v.desafio,
    COUNT(*) FILTER (WHERE grupo = 'tratamento' AND pedidos_piloto >= v.desafio) AS teste,
    ROUND(100.0 * COUNT(*) FILTER (WHERE grupo = 'tratamento' AND pedidos_piloto >= v.desafio)
        / COUNT(*) FILTER (WHERE grupo = 'tratamento'), 1)                       AS pct_teste,
    COUNT(*) FILTER (WHERE grupo = 'controle'   AND pedidos_piloto >= v.desafio) AS controle,
    COUNT(*) FILTER (WHERE grupo = 'tratamento' AND pedidos_piloto >= v.desafio)
      - COUNT(*) FILTER (WHERE grupo = 'controle' AND pedidos_piloto >= v.desafio) AS drivers_incrementais
FROM base
CROSS JOIN (VALUES (20), (25), (30), (40), (50)) AS v(desafio)
GROUP BY v.desafio
ORDER BY v.desafio;
