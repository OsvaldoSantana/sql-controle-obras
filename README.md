# SQL para Controle de Obras

Consultas SQL aplicadas ao planejamento e controle físico-financeiro de obras na construção civil.

## Contexto

Na construção civil, os dados de execução (medições, cronograma, produtividade, custos) muitas vezes ficam presos em planilhas desconectadas. Este repositório reúne consultas SQL que resolvem problemas reais de controle de obras.

## Consultas

| Arquivo | Problema que resolve |
|---|---|
| `01_medicoes_por_periodo.sql` | Consolidar medições por período e por contrato |
| `02_desvio_cronograma.sql` | Identificar atividades com desvio de prazo (previsto vs realizado) |
| `03_produtividade_equipes.sql` | Calcular produtividade por equipe/frente de serviço |
| `04_custo_unitario_real.sql` | Comparar custo unitário orçado vs executado |
| `05_indicadores_kpi.sql` | Gerar KPIs de acompanhamento físico-financeiro |

## Estrutura do banco de dados

As consultas assumem um banco relacional com as seguintes tabelas:

- `medicoes` — registros de medição por serviço e período
- `cronograma` — atividades planejadas com datas previstas e realizadas
- `equipes` — alocação de equipes por frente de serviço
- `orcamento` — composições de custo orçado
- `custos_reais` — lançamentos de custo executado

## Ferramentas

- PostgreSQL
- DBeaver (IDE)
- Dados simulados baseados em cenários reais de obra

## Sobre

Sou Engenheiro Civil com 7+ anos em planejamento e controle de obras. Estou aprendendo SQL para conectar dados de operação com indicadores de desempenho.

[LinkedIn](https://linkedin.com/in/osvaldo-santana-334792267)
