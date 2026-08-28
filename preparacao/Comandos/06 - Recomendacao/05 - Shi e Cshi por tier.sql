WITH piloto AS (
    SELECT
        d.driver_uuid,
        g.grupo,
        SUM(d.pedidos)                AS pedidos,
        SUM(d.supply_hours)::NUMERIC  AS sh
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    WHERE d.week::DATE >= DATE '2026-06-01'
    GROUP BY 1, 2
),
com_tier AS (
    SELECT
        p.grupo,
        p.sh,
        t.tier_simulation AS tier,
        CASE WHEN p.grupo = 'tratamento'
             THEN LEAST(FLOOR(p.pedidos / 50) * 175, 1100)::NUMERIC
             ELSE 0 END AS premio
    FROM piloto p
    JOIN tier_entregadores t
      ON t.driver_uuid = p.driver_uuid AND t.mes::DATE = DATE '2026-06-01'
),
agg AS (
    SELECT
        tier,
        COUNT(*) FILTER (WHERE grupo = 'tratamento') AS n_teste,
        COUNT(*) FILTER (WHERE grupo = 'controle')   AS n_ctrl,
        SUM(sh)  FILTER (WHERE grupo = 'tratamento') AS sh_teste,
        SUM(sh)  FILTER (WHERE grupo = 'controle')   AS sh_ctrl,
        SUM(premio)                                  AS custo
    FROM com_tier
    GROUP BY tier
),
calc AS (
    SELECT
        tier, n_teste, custo,
        (sh_ctrl / n_ctrl) * n_teste             AS contrafactual,
        sh_teste - (sh_ctrl / n_ctrl) * n_teste  AS shi
    FROM agg
)
SELECT
    tier,
    n_teste                                              AS drivers,
    ROUND(100.0 * n_teste / SUM(n_teste) OVER (), 1)     AS pct_da_base,
    ROUND(shi, 0)                                        AS shi,
    ROUND(100 * shi / contrafactual, 1)                  AS pct_shi,
    ROUND(100 * shi / SUM(shi) OVER (), 1)               AS pct_do_shi,
    ROUND(custo, 0)                                      AS custo,
    ROUND(100 * custo / SUM(custo) OVER (), 1)           AS pct_do_custo,
    ROUND(custo / NULLIF(shi, 0), 2)                     AS cshi
FROM calc
ORDER BY drivers DESC;
