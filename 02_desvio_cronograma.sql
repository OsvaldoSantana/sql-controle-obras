-- ============================================
-- 02_desvio_cronograma.sql
-- Identificar atividades com desvio de prazo
-- ============================================
-- Contexto: O acompanhamento de cronograma precisa comparar
-- datas previstas com datas realizadas para identificar
-- atividades atrasadas ANTES que o atraso se propague.
--
-- Problema que resolve: Calcular desvio em dias, classificar
-- por criticidade e gerar visão gerencial de aderência ao prazo.
-- ============================================

-- 1. Desvio por atividade (previsto vs realizado)
SELECT
    a.codigo_atividade,
    a.descricao,
    a.fase,
    a.data_inicio_prevista,
    a.data_inicio_real,
    a.data_fim_prevista,
    a.data_fim_real,
    -- Desvio de início (positivo = atrasou)
    COALESCE(a.data_inicio_real, CURRENT_DATE) - a.data_inicio_prevista
        AS desvio_inicio_dias,
    -- Desvio de término (positivo = atrasou)
    COALESCE(a.data_fim_real, CURRENT_DATE) - a.data_fim_prevista
        AS desvio_fim_dias,
    -- Classificação de criticidade
    CASE
        WHEN COALESCE(a.data_fim_real, CURRENT_DATE) - a.data_fim_prevista > 15
            THEN 'CRITICO'
        WHEN COALESCE(a.data_fim_real, CURRENT_DATE) - a.data_fim_prevista > 7
            THEN 'ATENCAO'
        WHEN COALESCE(a.data_fim_real, CURRENT_DATE) - a.data_fim_prevista > 0
            THEN 'LEVE'
        ELSE 'NO PRAZO'
    END AS criticidade
FROM cronograma a
WHERE a.status IN ('em_andamento', 'concluida')
ORDER BY desvio_fim_dias DESC;


-- 2. Resumo de aderência ao cronograma por fase
SELECT
    a.fase,
    COUNT(*) AS total_atividades,
    SUM(CASE
        WHEN COALESCE(a.data_fim_real, CURRENT_DATE) <= a.data_fim_prevista
        THEN 1 ELSE 0
    END) AS no_prazo,
    SUM(CASE
        WHEN COALESCE(a.data_fim_real, CURRENT_DATE) > a.data_fim_prevista
        THEN 1 ELSE 0
    END) AS atrasadas,
    ROUND(
        SUM(CASE
            WHEN COALESCE(a.data_fim_real, CURRENT_DATE) <= a.data_fim_prevista
            THEN 1 ELSE 0
        END)::NUMERIC / COUNT(*) * 100, 1
    ) AS percentual_aderencia
FROM cronograma a
WHERE a.status IN ('em_andamento', 'concluida')
GROUP BY a.fase
ORDER BY percentual_aderencia ASC;


-- 3. Atividades em andamento com maior risco de atraso
-- (previstas para terminar nos próximos 7 dias mas com pouco avanço)
SELECT
    a.codigo_atividade,
    a.descricao,
    a.fase,
    a.data_fim_prevista,
    a.percentual_concluido,
    a.data_fim_prevista - CURRENT_DATE AS dias_restantes,
    CASE
        WHEN a.percentual_concluido < 50 AND (a.data_fim_prevista - CURRENT_DATE) <= 7
            THEN 'RISCO ALTO - menos de 50% com 7 dias ou menos'
        WHEN a.percentual_concluido < 80 AND (a.data_fim_prevista - CURRENT_DATE) <= 3
            THEN 'RISCO ALTO - menos de 80% com 3 dias ou menos'
        ELSE 'MONITORAR'
    END AS alerta
FROM cronograma a
WHERE a.status = 'em_andamento'
    AND a.data_fim_prevista BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
    AND a.percentual_concluido < 80
ORDER BY dias_restantes ASC, a.percentual_concluido ASC;
