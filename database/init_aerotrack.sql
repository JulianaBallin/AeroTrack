-- Estrutura do banco de dados do projeto AeroTrack
-- Trabalho final do Modulo 6 (Apache Hop), Projeto 4: Monitoramento de Qualidade do Ar

-- Tabela de dados tratados e detalhados (uma linha por leitura horaria da estacao).
-- A restricao UNIQUE em data_hora permite que o processo seja reexecutado sem duplicar
-- registros: a pipeline de carga usa Insert/Update por data_hora.
CREATE TABLE IF NOT EXISTS leituras_qualidade_ar (
    id BIGSERIAL PRIMARY KEY,
    data_hora TIMESTAMP NOT NULL,
    data_referencia DATE NOT NULL,
    ano INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    dia INTEGER NOT NULL,
    hora INTEGER NOT NULL,
    dia_semana VARCHAR(15) NOT NULL,
    turno VARCHAR(12) NOT NULL,
    co_gt NUMERIC(6,2),
    pt08_s1_co NUMERIC(8,2),
    nmhc_gt NUMERIC(8,2),
    c6h6_gt NUMERIC(8,2),
    pt08_s2_nmhc NUMERIC(8,2),
    nox_gt NUMERIC(8,2),
    pt08_s3_nox NUMERIC(8,2),
    no2_gt NUMERIC(8,2),
    pt08_s4_no2 NUMERIC(8,2),
    pt08_s5_o3 NUMERIC(8,2),
    temperatura NUMERIC(6,2),
    umidade_relativa NUMERIC(6,2),
    umidade_absoluta NUMERIC(8,4),
    co_nivel VARCHAR(10) NOT NULL,
    no2_nivel VARCHAR(10) NOT NULL,
    condicao_critica VARCHAR(3) NOT NULL DEFAULT 'NAO',
    carregado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_leituras_qualidade_ar_data_hora UNIQUE (data_hora),
    CONSTRAINT ck_condicao_critica CHECK (condicao_critica IN ('SIM', 'NAO'))
);

CREATE INDEX IF NOT EXISTS idx_leituras_data_referencia ON leituras_qualidade_ar (data_referencia);
CREATE INDEX IF NOT EXISTS idx_leituras_ano_mes ON leituras_qualidade_ar (ano, mes);

-- Tabela de registros descartados pela pipeline de tratamento (leituras em que
-- todos os poluentes de referencia estavam ausentes na fonte). Mantida para
-- comprovar a etapa obrigatoria de separacao de registros invalidos.
CREATE TABLE IF NOT EXISTS leituras_rejeitadas (
    id BIGSERIAL PRIMARY KEY,
    data_hora_texto VARCHAR(30),
    motivo VARCHAR(120) NOT NULL,
    co_gt NUMERIC(6,2),
    nox_gt NUMERIC(8,2),
    no2_gt NUMERIC(6,2),
    processado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de resumo diario. Alimentada pela pipeline de consolidacao a partir de
-- leituras_qualidade_ar. A chave primaria em data_referencia garante que uma nova
-- execucao apenas atualiza o dia, sem duplicar linhas.
CREATE TABLE IF NOT EXISTS resumo_diario_qualidade_ar (
    data_referencia DATE PRIMARY KEY,
    total_leituras INTEGER NOT NULL,
    registros_invalidos INTEGER NOT NULL,
    co_medio NUMERIC(6,2),
    co_maximo NUMERIC(6,2),
    no2_medio NUMERIC(6,2),
    no2_maximo NUMERIC(6,2),
    nox_medio NUMERIC(8,2),
    benzeno_medio NUMERIC(8,2),
    temperatura_media NUMERIC(6,2),
    umidade_media NUMERIC(6,2),
    horas_condicao_critica INTEGER NOT NULL,
    percentual_horas_criticas NUMERIC(6,2) NOT NULL,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de resumo mensal, usada para a evolucao temporal exibida no dashboard.
CREATE TABLE IF NOT EXISTS resumo_mensal_qualidade_ar (
    ano INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    total_leituras INTEGER NOT NULL,
    co_medio NUMERIC(6,2),
    no2_medio NUMERIC(6,2),
    nox_medio NUMERIC(8,2),
    temperatura_media NUMERIC(6,2),
    umidade_media NUMERIC(6,2),
    horas_condicao_critica INTEGER NOT NULL,
    percentual_horas_criticas NUMERIC(6,2) NOT NULL,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ano, mes)
);

-- Visao com os indicadores gerais do periodo inteiro, usada pelos cartoes do dashboard.
CREATE OR REPLACE VIEW vw_indicadores_gerais AS
SELECT
    COUNT(*) AS total_leituras,
    SUM(CASE WHEN condicao_critica = 'SIM' THEN 1 ELSE 0 END) AS total_horas_criticas,
    ROUND(100.0 * SUM(CASE WHEN condicao_critica = 'SIM' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS percentual_horas_criticas,
    ROUND(AVG(co_gt)::numeric, 2) AS co_medio_geral,
    ROUND(MAX(co_gt)::numeric, 2) AS co_maximo_geral,
    ROUND(AVG(no2_gt)::numeric, 2) AS no2_medio_geral,
    ROUND(MAX(no2_gt)::numeric, 2) AS no2_maximo_geral,
    ROUND(AVG(nox_gt)::numeric, 2) AS nox_medio_geral,
    ROUND(AVG(temperatura)::numeric, 2) AS temperatura_media_geral,
    ROUND(AVG(umidade_relativa)::numeric, 2) AS umidade_media_geral
FROM leituras_qualidade_ar;

-- Ranking dos 10 dias com piores condicoes registradas (maior media de CO).
CREATE OR REPLACE VIEW vw_ranking_piores_dias AS
SELECT
    data_referencia,
    co_medio,
    no2_medio,
    horas_condicao_critica,
    percentual_horas_criticas
FROM resumo_diario_qualidade_ar
ORDER BY co_medio DESC NULLS LAST
LIMIT 10;
