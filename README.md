# Programa Super — avaliação do piloto de incentivos

Avaliação do piloto rodado em Campinas-SP: **R$ 175 a cada 50 pedidos acumulados no mês, com teto de R$ 1.100**.

Baseline: 4 semanas de maio/2026. Piloto: 4 semanas de junho/2026.

---

## Resposta curta

**O piloto foi eficaz.** Gerou 76,4 mil horas incrementais de supply (+23,0%) a um
custo de R$ 24,53 por hora. O efeito foi imediato, sustentado nas quatro semanas, e
o grupo de controle permaneceu estável.

**Mas o desafio único não alcança a base e já estava cruzado no topo.** 100% dos
Ouros e Diamantes faziam mais de 50 pedidos antes do piloto começar; no Regular,
apenas 2,3%. O mesmo número é 385% do que o Regular entrega e 16% do que o
Diamante entrega.

**Duas recomendações**, uma para cada ponta:

| | Recomendação | Custo |
|---|---|---|
| **Super** | Mover o teto de 300 para 400 pedidos (R$ 1.100 → R$ 1.400) | +11% |
| **Regular** | Programa Impulso: escada de entrada em 20 / 30 / 40 pedidos | R$ 313 mil |

---

## Estrutura

```
dados/     bases originais do case (csv)
sql/       queries que sustentam cada número da apresentação
```

### Dados

| Arquivo | Linhas | Descrição |
|---|---|---|
| `dados_entregadores.csv` | 286.768 | Painel semanal por entregador: pedidos, supply hours, worked hours, rotas, ganhos |
| `grupos_entregadores.csv` | 28.678 | Alocação em teste ou controle |
| `tier_entregadores.csv` | 71.694 | Tier (Regular / Ouro / Diamante) por mês |

**Chave:** `driver_uuid`. **Granularidade:** semana em `dados_entregadores`,
mês em `tier_entregadores`.

### Queries

Numeradas na ordem da análise. Cada pasta corresponde a uma etapa do raciocínio.

```
sql/
├── 00_setup/                       criação das tabelas e carga
├── 01_validade/                    os grupos são comparáveis?
├── 02_performance/                 o piloto teve efeito?
├── 03_sustentacao/                 o efeito se manteve nas 4 semanas?
├── 04_conversao/                   a base converteu? para onde foi o custo?
└── 05_eficiencia_e_recomendacao/   SHi, CSHi e as duas propostas
```

---

## Metodologia

A métrica é **SHi** (supply hours incrementais), no padrão usado internamente:

```
contrafactual = n_teste × (supply hours por driver do controle, mesmo período)
SHi           = SH real do teste − contrafactual
%SHi          = SHi / contrafactual
CSHi          = custo / SHi
```

---

## Achados

### 1. O piloto funcionou

| Métrica | Teste | Contrafactual | Incremental |
|---|---|---|---|
| Supply hours | 408.635 | 332.223 | **76.413 (+23,0%)** |
| Pedidos | 907.259 | 714.345 | **192.914 (+27,0%)** |

Custo de R$ 1.874.375 → **CSHi de R$ 24,53 por hora**.

Cerca de 87% do ganho veio de mais horas ofertadas, não de mais produtividade por
hora. A utilização permaneceu estável em 69% e a taxa de rejeição subiu 0,26 pp.

### 2. A base se moveu, mas não converteu

511 entregadores a mais subiram de faixa de volume no grupo tratado. Apenas
**4 cruzaram os 50 pedidos**. A conversão ao desafio ficou em 16,72% no teste
contra 16,67% no controle — oito pessoas de diferença em 14.339.

O motivo aparece na distribuição: a base é bimodal. 82,5% faz até 29 pedidos por
mês e 15,6% faz mais de 100. Entre as duas populações há um vazio, e o desafio de
50 pedidos foi ancorado exatamente ali. **Na faixa de 50 a 59 pedidos havia uma
pessoa em 14.339 no baseline.**

### 3. O dinheiro seguiu o tier, não o esforço

| Tier | Drivers | % da base | SHi | %SHi | Custo | % do custo | CSHi |
|---|---|---|---|---|---|---|---|
| Regular | 12.237 | 85,3% | 25.830 | 18,4% | R$ 223.125 | 11,9% | **R$ 8,64** |
| Ouro | 1.337 | 9,3% | 24.523 | **24,7%** | R$ 867.650 | 46,3% | R$ 35,38 |
| Diamante | 765 | 5,3% | 20.010 | 20,2% | R$ 783.600 | 41,8% | **R$ 39,16** |

Ouro e Diamante são 15% da base tratada e consomem 88% do orçamento. O Regular é
85% da base, consome 12% — e entrega 37% do SHi total.

O CSHi baixo do Regular não é eficiência de desenho: é ausência de desenho. 12.237
pessoas dividiram R$ 223 mil, enquanto 765 Diamantes dividiram R$ 784 mil.

### 4. O teto está abaixo da mediana do Diamante

| Tier | Mediana maio | Mediana junho | Já fazia 50+ em maio |
|---|---|---|---|
| Regular | 13 | 17 | **2,3%** |
| Ouro | 161 | 201 | **100%** |
| Diamante | **308** | 393 | **100%** |

O teto de R$ 1.100 é atingido com 300 pedidos. A mediana do Diamante em maio era
308 — **para metade deles, os seis blocos já estavam garantidos antes do mês
começar**.

902 entregadores (37,6% dos premiados) ultrapassam o teto e ficam sem incentivo
marginal pelo resto do mês. Desses, **609 são Diamante**.

E a resposta cai conforme a distância até o teto aumenta:

| Diamante, volume em maio | Drivers | %SHi | CSHi |
|---|---|---|---|
| 150–249 | 194 | 26,7% | R$ 36,76 |
| 250–349 | 279 | 24,8% | R$ 34,88 |
| **350+** | 277 | **15,7%** | **R$ 42,53** |

---

## Recomendações

### Super — mover o teto de 300 para 400 pedidos

| Teto | Prêmio máx | Custo | vs. hoje | Ainda no teto |
|---|---|---|---|---|
| 300 (hoje) | R$ 1.100 | R$ 1,84 mi | — | 902 |
| **400** | **R$ 1.400** | **R$ 2,04 mi** | **+11%** | **468** |
| 500 | R$ 1.750 | R$ 2,14 mi | +16% | 230 |
| 600 | R$ 2.100 | R$ 2,18 mi | +19% | 108 |

Um parâmetro só, e **ninguém perde nada** — a regra abaixo de 300 pedidos
permanece idêntica. O teto volta a ficar acima da mediana do Diamante em junho,
que foi 393.

**Por que 400 e não mais:** acima disso o SHi disponível é pequeno (5.419 horas) e
cada extensão adicional compra menos hora de menos gente, num grupo cuja
elasticidade já é a menor da base (15,7% em quem fazia 350+ em maio). Há também um
limite físico: divulgar um teto de 600 pedidos pressupõe uma média de 150 pedidos
semanais por entregador.

**Ponto de equilíbrio:** o custo adicional é R$ 198 mil. Para manter o CSHi de
R$ 24,53, esse valor precisaria comprar cerca de 8.076 horas incrementais.
Distribuído entre os 468 que ficariam no novo teto, são **1,4 hora por semana por
entregador**.

### Regular — Programa Impulso

Escada de entrada mantendo R$ 3,50 por pedido, o mesmo preço unitário do Super:

| Degrau | Pedidos/mês | Prêmio | Alcançam | Controle | Incrementais |
|---|---|---|---|---|---|
| **Starter** | 20 | R$ 70 | 4.021 | 1.551 | **+2.470** |
| Bronze | 30 | R$ 110 | 682 | 131 | +551 |
| Prata | 40 | R$ 150 | 100 | 10 | +90 |
| → Super | 50 | R$ 175 | 9 | 3 | +6 |

**Custo: R$ 312.750** — 17% do orçamento atual do Super, para alcançar 4.021
pessoas em vez de 9.

A justificativa é comportamento já documentado: 2.470 pessoas a mais chegaram a
20 pedidos **sabendo que não ganhariam nada**. A escada apenas coloca o prêmio
onde o movimento acontece, e cria degraus intermediários até o Super.
