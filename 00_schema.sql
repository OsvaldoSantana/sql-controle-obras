-- ============================================
-- 00_schema.sql
-- Estrutura do banco de dados
-- ============================================
-- Este arquivo define as tabelas utilizadas nas
-- consultas deste repositório. Os dados são simulados,
-- mas a estrutura reflete cenários reais de controle
-- de obras na construção civil.
-- ============================================

CREATE TABLE contratos (
    id SERIAL PRIMARY KEY,
    nome_contrato VARCHAR(200) NOT NULL,
    fornecedor VARCHAR(200) NOT NULL,
    valor_contrato NUMERIC(15,2) NOT NULL,
    data_inicio DATE,
    data_fim_prevista DATE,
    status VARCHAR(20) DEFAULT 'ativo'
        CHECK (status IN ('ativo', 'encerrado', 'suspenso'))
);

CREATE TABLE medicoes (
    id SERIAL PRIMARY KEY,
    contrato_id INTEGER REFERENCES contratos(id),
    periodo_referencia VARCHAR(7) NOT NULL, -- formato: 'YYYY-MM'
    descricao_servico VARCHAR(300),
    quantidade_medida NUMERIC(12,4),
    unidade VARCHAR(20),
    valor_unitario NUMERIC(12,4),
    valor_medido NUMERIC(15,2),
    data_medicao DATE DEFAULT CURRENT_DATE
);

CREATE TABLE cronograma (
    id SERIAL PRIMARY KEY,
    codigo_atividade VARCHAR(20) NOT NULL,
    descricao VARCHAR(300) NOT NULL,
    fase VARCHAR(100),
    data_inicio_prevista DATE,
    data_fim_prevista DATE,
    data_inicio_real DATE,
    data_fim_real DATE,
    percentual_concluido NUMERIC(5,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'nao_iniciada'
        CHECK (status IN ('nao_iniciada', 'em_andamento', 'concluida', 'cancelada')),
    predecessora_id INTEGER REFERENCES cronograma(id)
);

CREATE TABLE equipes (
    id SERIAL PRIMARY KEY,
    nome_equipe VARCHAR(100) NOT NULL,
    encarregado VARCHAR(150),
    frente_servico VARCHAR(100)
);

CREATE TABLE servicos (
    id SERIAL PRIMARY KEY,
    codigo_servico VARCHAR(20),
    descricao_servico VARCHAR(300) NOT NULL,
    unidade_medida VARCHAR(20) NOT NULL
);

CREATE TABLE apontamentos (
    id SERIAL PRIMARY KEY,
    equipe_id INTEGER REFERENCES equipes(id),
    servico_id INTEGER REFERENCES servicos(id),
    funcionario_id INTEGER,
    data_apontamento DATE NOT NULL,
    quantidade_executada NUMERIC(12,4) NOT NULL,
    observacao TEXT
);

CREATE TABLE orcamento_indices (
    id SERIAL PRIMARY KEY,
    servico_id INTEGER REFERENCES servicos(id),
    indice_produtividade_orcado NUMERIC(10,4),
    custo_unitario_orcado NUMERIC(12,4)
);

CREATE TABLE custos_reais (
    id SERIAL PRIMARY KEY,
    contrato_id INTEGER REFERENCES contratos(id),
    servico_id INTEGER REFERENCES servicos(id),
    data_lancamento DATE,
    valor_lancado NUMERIC(15,2),
    tipo VARCHAR(20) CHECK (tipo IN ('material', 'mao_de_obra', 'equipamento', 'outros'))
);
