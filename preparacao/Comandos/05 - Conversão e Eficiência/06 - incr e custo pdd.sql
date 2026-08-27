WITH mensal AS (
    SELECT
        d.driver_uuid, g.grupo,
        SUM(d.pedidos) FILTER (WHERE d.week::DATE <  DATE '2026-06-01') AS pedidos_baseline,
        SUM(d.pedidos) FILTER (WHERE d.week::DATE >= DATE '2026-06-01') AS pedidos_piloto
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    GROUP BY 1, 2
),
consolidado AS (
    SELECT
        COUNT(*) FILTER (WHERE grupo = 'tratamento')                          AS drivers,
        COUNT(*) FILTER (WHERE grupo = 'tratamento' AND pedidos_piloto >= 50) AS premiados,
        ROUND(((AVG(pedidos_piloto - pedidos_baseline) FILTER (WHERE grupo = 'tratamento')
              - AVG(pedidos_piloto - pedidos_baseline) FILTER (WHERE grupo = 'controle'))
            * COUNT(*) FILTER (WHERE grupo = 'tratamento'))::NUMERIC, 0)      AS pedidos_incrementais,
        SUM(LEAST(FLOOR(pedidos_piloto / 50) * 175, 1100)::NUMERIC)
            FILTER (WHERE grupo = 'tratamento')                               AS custo_total
    FROM mensal
)
SELECT
    drivers,
    premiados,
    ROUND(100.0 * premiados / drivers, 2)                 AS pct_premiados,
    pedidos_incrementais,
    custo_total,
    ROUND(custo_total / pedidos_incrementais, 2)          AS custo_por_pedido
FROM consolidado;
