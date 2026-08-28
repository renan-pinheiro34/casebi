WITH piloto AS (
    SELECT
        g.grupo,
        COUNT(DISTINCT d.driver_uuid) AS drivers,
        SUM(d.supply_hours)::NUMERIC  AS sh
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    WHERE d.week::DATE >= DATE '2026-06-01'
    GROUP BY 1
),
premios AS (
    SELECT LEAST(FLOOR(SUM(d.pedidos) / 50) * 175, 1100)::NUMERIC AS premio
    FROM dados_entregadores d
    JOIN grupos_entregadores g ON g.driver_uuid = d.driver_uuid
    WHERE d.week::DATE >= DATE '2026-06-01' AND g.grupo = 'tratamento'
    GROUP BY d.driver_uuid
),
calc AS (
    SELECT
        t.drivers                              AS n_teste,
        t.sh                                   AS sh_teste,
        c.sh / c.drivers                       AS sh_por_driver_controle,
        (c.sh / c.drivers) * t.drivers         AS contrafactual,
        t.sh - (c.sh / c.drivers) * t.drivers  AS shi
    FROM (SELECT * FROM piloto WHERE grupo = 'tratamento') t
    CROSS JOIN (SELECT * FROM piloto WHERE grupo = 'controle') c
)
SELECT
    n_teste,
    ROUND(sh_teste, 1)                     AS sh_teste,
    ROUND(sh_por_driver_controle, 2)       AS sh_por_driver_controle,
    ROUND(contrafactual, 1)                AS contrafactual,
    ROUND(shi, 1)                          AS shi,
    ROUND(100 * shi / contrafactual, 1)    AS pct_shi,
    ROUND((SELECT SUM(premio) FROM premios), 0)       AS custo,
    ROUND((SELECT SUM(premio) FROM premios) / shi, 2) AS cshi
FROM calc;