-- ============================================
-- 01_medicoes_por_periodo.sql
-- Consolidar medições por período e contrato
-- ============================================
-- Contexto: Em obras com múltiplos contratos e frentes de serviço,
-- a medição mensal precisa ser consolidada para gerar o valor de
-- desembolso e comparar com o orçamento previsto.
--
-- Problema que resolve: Agrupar medições por contrato e período,
-- calcular totais acumulados e identificar contratos sem medição.
-- ============================================

-- 1. Medições do mês agrupadas por contrato
SELECT
    c.nome_contrato,
    c.fornecedor,
    m.periodo_referencia,
    COUNT(m.id) AS qtd_itens_medidos,
    SUM(m.valor_medido) AS valor_total_medido,
    SUM(m.quantidade_medida) AS quantidade_total
FROM medicoes m
INNER JOIN contratos c ON m.contrato_id = c.id
WHERE m.periodo_referencia = '2026-03'
GROUP BY c.nome_contrato, c.fornecedor, m.periodo_referencia
ORDER BY valor_total_medido DESC;


-- 2. Acumulado de medições por contrato (toda a obra)
SELECT
    c.nome_contrato,
    c.valor_contrato,
    SUM(m.valor_medido) AS valor_acumulado_medido,
    ROUND(
        (SUM(m.valor_medido) / c.valor_contrato) * 100, 2
    ) AS percentual_executado,
    c.valor_contrato - SUM(m.valor_medido) AS saldo_a_medir
FROM medicoes m
INNER JOIN contratos c ON m.contrato_id = c.id
GROUP BY c.nome_contrato, c.valor_contrato
ORDER BY percentual_executado DESC;


-- 3. Contratos SEM medição no período (possível atraso)
SELECT
    c.nome_contrato,
    c.fornecedor,
    c.data_inicio,
    c.data_fim_prevista
FROM contratos c
LEFT JOIN medicoes m
    ON c.id = m.contrato_id
    AND m.periodo_referencia = '2026-03'
WHERE m.id IS NULL
    AND c.status = 'ativo'
ORDER BY c.data_fim_prevista;
