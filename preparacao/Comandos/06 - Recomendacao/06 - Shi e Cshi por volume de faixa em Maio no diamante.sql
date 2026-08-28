WITH mensal AS (
    SELECT
        d.driver_uuid,
        g.grupo,
        SUM(d.pedidos)      FILTER (WHERE d.week::DATE <  DATE '2026-06-01') AS pedidos_baseline,
        SUM(d.pedidos)      FILTER (WHERE d.week::DATE >= DATE '2026-06-01') AS pedidos_piloto,
        SUM(d.supply_hours) FILTER (WHERE d.week::DATE >= DATE '2026-06-01') AS sh_piloto
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    GROUP BY 1, 2
),
faixas AS (
    SELECT
        m.grupo,
        m.sh_piloto::NUMERIC AS sh,
        CASE
            WHEN m.pedidos_baseline < 250 THEN '150-249'
            WHEN m.pedidos_baseline < 350 THEN '250-349'
            ELSE                               '350+'
        END AS faixa,
        CASE
            WHEN m.pedidos_baseline < 250 THEN 1
            WHEN m.pedidos_baseline < 350 THEN 2
            ELSE                               3
        END AS ordem,
        CASE WHEN m.grupo = 'tratamento'
             THEN LEAST(FLOOR(m.pedidos_piloto / 50) * 175, 1100)::NUMERIC
             ELSE 0 END AS premio
    FROM mensal m
    JOIN tier_entregadores t
      ON t.driver_uuid = m.driver_uuid AND t.mes::DATE = DATE '2026-06-01'
    WHERE t.tier_simulation = 'Diamante'
      AND m.pedidos_baseline >= 150
),
agg AS (
    SELECT
        faixa, ordem,
        COUNT(*) FILTER (WHERE grupo = 'tratamento') AS n_teste,
        COUNT(*) FILTER (WHERE grupo = 'controle')   AS n_ctrl,
        SUM(sh)  FILTER (WHERE grupo = 'tratamento') AS sh_teste,
        SUM(sh)  FILTER (WHERE grupo = 'controle')   AS sh_ctrl,
        SUM(premio)                                  AS custo
    FROM faixas
    GROUP BY faixa, ordem
)
SELECT
    faixa,
    n_teste                                                            AS drivers,
    ROUND(100 * (sh_teste - (sh_ctrl / n_ctrl) * n_teste)
        / ((sh_ctrl / n_ctrl) * n_teste), 1)                           AS pct_shi,
    ROUND(custo / NULLIF(sh_teste - (sh_ctrl / n_ctrl) * n_teste, 0), 2) AS cshi
FROM agg
ORDER BY ordem;