-- ============================================
-- 03_produtividade_equipes.sql
-- Calcular produtividade por equipe e frente
-- ============================================
-- Contexto: O controle de produtividade é essencial para
-- validar cronograma, prever desvios e dimensionar equipes.
-- Sem esse dado, o planejamento opera no escuro.
--
-- Problema que resolve: Medir produtividade real por equipe,
-- comparar com índices orçados e identificar frentes abaixo
-- do esperado.
-- ============================================

-- 1. Produtividade diária por equipe e serviço
SELECT
    e.nome_equipe,
    s.descricao_servico,
    s.unidade_medida,
    ap.data_apontamento,
    SUM(ap.quantidade_executada) AS producao_dia,
    COUNT(DISTINCT ap.funcionario_id) AS efetivo_dia,
    ROUND(
        SUM(ap.quantidade_executada) / NULLIF(COUNT(DISTINCT ap.funcionario_id), 0), 2
    ) AS produtividade_por_pessoa
FROM apontamentos ap
INNER JOIN equipes e ON ap.equipe_id = e.id
INNER JOIN servicos s ON ap.servico_id = s.id
GROUP BY e.nome_equipe, s.descricao_servico, s.unidade_medida, ap.data_apontamento
ORDER BY ap.data_apontamento DESC, e.nome_equipe;


-- 2. Produtividade média semanal vs índice orçado
SELECT
    e.nome_equipe,
    s.descricao_servico,
    s.unidade_medida,
    DATE_TRUNC('week', ap.data_apontamento) AS semana,
    ROUND(AVG(ap.quantidade_executada), 2) AS media_producao_dia,
    o.indice_produtividade_orcado,
    ROUND(
        (AVG(ap.quantidade_executada) / NULLIF(o.indice_produtividade_orcado, 0)) * 100, 1
    ) AS percentual_vs_orcado,
    CASE
        WHEN AVG(ap.quantidade_executada) >= o.indice_produtividade_orcado
            THEN 'ACIMA DO ORCADO'
        WHEN AVG(ap.quantidade_executada) >= o.indice_produtividade_orcado * 0.8
            THEN 'DENTRO DA FAIXA'
        ELSE 'ABAIXO - ACAO NECESSARIA'
    END AS status_produtividade
FROM apontamentos ap
INNER JOIN equipes e ON ap.equipe_id = e.id
INNER JOIN servicos s ON ap.servico_id = s.id
INNER JOIN orcamento_indices o ON s.id = o.servico_id
GROUP BY e.nome_equipe, s.descricao_servico, s.unidade_medida,
         DATE_TRUNC('week', ap.data_apontamento), o.indice_produtividade_orcado
ORDER BY percentual_vs_orcado ASC;


-- 3. Ranking de equipes por produtividade no período
SELECT
    e.nome_equipe,
    COUNT(DISTINCT ap.data_apontamento) AS dias_trabalhados,
    SUM(ap.quantidade_executada) AS producao_total,
    ROUND(
        SUM(ap.quantidade_executada) / NULLIF(COUNT(DISTINCT ap.data_apontamento), 0), 2
    ) AS media_diaria,
    RANK() OVER (ORDER BY SUM(ap.quantidade_executada) DESC) AS ranking
FROM apontamentos ap
INNER JOIN equipes e ON ap.equipe_id = e.id
WHERE ap.data_apontamento BETWEEN '2026-03-01' AND '2026-03-31'
GROUP BY e.nome_equipe
ORDER BY ranking;
