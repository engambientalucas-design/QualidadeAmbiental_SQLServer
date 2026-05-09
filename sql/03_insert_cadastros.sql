/*
    Projeto: QualidadeAmbiental_SQLServer
    Arquivo: 03_insert_cadastros.sql
    Objetivo: inserir dados de cadastro usados como base para amostras,
              resultados analiticos, limites didaticos e views do projeto.

    Observacoes:
    - Execute este script apos o arquivo 02_create_tables.sql.
    - Este script usa IDs explicitos para manter os dados previsiveis.
    - Este script nao insere amostras nem resultados analiticos.
    - Os limites de referencia sao didaticos e nao representam norma real.
*/

USE QualidadeAmbiental;
GO

INSERT INTO dbo.Tbl_Responsaveis
(
    IdResponsavel,
    NomeResponsavel,
    Cargo,
    Email,
    Telefone
)
SELECT
    v.IdResponsavel,
    v.NomeResponsavel,
    v.Cargo,
    v.Email,
    v.Telefone
FROM
(
    VALUES
        (1, 'Ana Ribeiro', 'Engenheira Ambiental', 'ana.ribeiro@exemplo.com', '(65) 3000-1001'),
        (2, 'Carlos Mendes', 'Analista de Laboratorio', 'carlos.mendes@exemplo.com', '(65) 3000-1002'),
        (3, 'Fernanda Lima', 'Tecnica de Coleta', 'fernanda.lima@exemplo.com', '(65) 3000-1003'),
        (4, 'Joao Pereira', 'Coordenador de Qualidade', 'joao.pereira@exemplo.com', '(65) 3000-1004')
) AS v
(
    IdResponsavel,
    NomeResponsavel,
    Cargo,
    Email,
    Telefone
)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Tbl_Responsaveis AS r
    WHERE r.IdResponsavel = v.IdResponsavel
);
GO

INSERT INTO dbo.Tbl_StatusAmostra
(
    IdStatus,
    NomeStatus,
    Descricao
)
SELECT
    v.IdStatus,
    v.NomeStatus,
    v.Descricao
FROM
(
    VALUES
        (1, 'Coletada', 'Amostra coletada em campo.'),
        (2, 'Em Analise', 'Amostra em processamento laboratorial.'),
        (3, 'Concluida', 'Amostra analisada e liberada.'),
        (4, 'Reprovada', 'Amostra invalidada por criterio tecnico.'),
        (5, 'Pendente', 'Amostra aguardando etapa operacional.')
) AS v
(
    IdStatus,
    NomeStatus,
    Descricao
)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Tbl_StatusAmostra AS s
    WHERE s.IdStatus = v.IdStatus
);
GO

INSERT INTO dbo.Tbl_TiposAmostra
(
    IdTipoAmostra,
    NomeTipoAmostra,
    Descricao
)
SELECT
    v.IdTipoAmostra,
    v.NomeTipoAmostra,
    v.Descricao
FROM
(
    VALUES
        (1, 'Agua Bruta', 'Amostra de agua antes do tratamento.'),
        (2, 'Agua Tratada', 'Amostra de agua apos tratamento.'),
        (3, 'Esgoto Bruto', 'Amostra de esgoto antes do tratamento.'),
        (4, 'Esgoto Tratado', 'Amostra de esgoto apos tratamento.'),
        (5, 'Corpo Hidrico', 'Amostra coletada diretamente em corpo hidrico.')
) AS v
(
    IdTipoAmostra,
    NomeTipoAmostra,
    Descricao
)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Tbl_TiposAmostra AS t
    WHERE t.IdTipoAmostra = v.IdTipoAmostra
);
GO

INSERT INTO dbo.Tbl_PontosColeta
(
    IdPontoColeta,
    NomePonto,
    TipoPonto,
    Municipio,
    Estado,
    Latitude,
    Longitude,
    Observacao
)
SELECT
    v.IdPontoColeta,
    v.NomePonto,
    v.TipoPonto,
    v.Municipio,
    v.Estado,
    v.Latitude,
    v.Longitude,
    v.Observacao
FROM
(
    VALUES
        (1, 'Captacao Rio Norte', 'Captacao superficial', 'Cuiaba', 'MT', -15.598900, -56.094900, 'Ponto didatico de agua bruta.'),
        (2, 'Saida ETA Central', 'Saida de tratamento', 'Cuiaba', 'MT', -15.601200, -56.101000, 'Ponto didatico de agua tratada.'),
        (3, 'Entrada ETE Sul', 'Entrada de tratamento', 'Varzea Grande', 'MT', -15.646100, -56.132500, 'Ponto didatico de esgoto bruto.'),
        (4, 'Saida ETE Sul', 'Saida de tratamento', 'Varzea Grande', 'MT', -15.648300, -56.129800, 'Ponto didatico de esgoto tratado.'),
        (5, 'Rio Coxipo Montante', 'Corpo hidrico', 'Cuiaba', 'MT', -15.625500, -56.057700, 'Ponto didatico em corpo hidrico.'),
        (6, 'Reservatorio Bairro Leste', 'Reservatorio', 'Cuiaba', 'MT', -15.584000, -56.072000, 'Ponto didatico de distribuicao de agua tratada.')
) AS v
(
    IdPontoColeta,
    NomePonto,
    TipoPonto,
    Municipio,
    Estado,
    Latitude,
    Longitude,
    Observacao
)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Tbl_PontosColeta AS p
    WHERE p.IdPontoColeta = v.IdPontoColeta
);
GO

INSERT INTO dbo.Tbl_Parametros
(
    IdParametro,
    NomeParametro,
    UnidadeMedida,
    Categoria,
    Descricao,
    Ativo
)
SELECT
    v.IdParametro,
    v.NomeParametro,
    v.UnidadeMedida,
    v.Categoria,
    v.Descricao,
    v.Ativo
FROM
(
    VALUES
        (1, 'pH', NULL, 'Fisico-quimico', 'Potencial hidrogenionico da amostra.', 1),
        (2, 'Turbidez', 'NTU', 'Fisico-quimico', 'Indicador de particulas em suspensao.', 1),
        (3, 'Oxigenio Dissolvido', 'mg/L', 'Fisico-quimico', 'Concentracao de oxigenio dissolvido.', 1),
        (4, 'DBO', 'mg/L', 'Materia organica', 'Demanda bioquimica de oxigenio.', 1),
        (5, 'DQO', 'mg/L', 'Materia organica', 'Demanda quimica de oxigenio.', 1),
        (6, 'Coliformes Termotolerantes', 'NMP/100mL', 'Microbiologico', 'Indicador microbiologico didatico.', 1),
        (7, 'Temperatura', 'C', 'Fisico-quimico', 'Temperatura medida na amostra.', 1),
        (8, 'Condutividade', 'uS/cm', 'Fisico-quimico', 'Indicador indireto de sais dissolvidos.', 1),
        (9, 'Solidos Totais', 'mg/L', 'Solidos', 'Concentracao de solidos totais.', 1),
        (10, 'Nitrogenio Amoniacal', 'mg/L', 'Nutrientes', 'Concentracao de nitrogenio amoniacal.', 1),
        (11, 'Fosforo Total', 'mg/L', 'Nutrientes', 'Concentracao de fosforo total.', 1),
        (12, 'Cloro Residual Livre', 'mg/L', 'Desinfeccao', 'Cloro residual livre em agua tratada.', 1)
) AS v
(
    IdParametro,
    NomeParametro,
    UnidadeMedida,
    Categoria,
    Descricao,
    Ativo
)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Tbl_Parametros AS p
    WHERE p.IdParametro = v.IdParametro
);
GO

/*
    Matriz didatica de limites:
    - Tipo 1: Agua Bruta      -> 9 parametros com limite.
    - Tipo 2: Agua Tratada    -> 10 parametros com limite.
    - Tipo 3: Esgoto Bruto    -> 8 parametros com limite.
    - Tipo 4: Esgoto Tratado  -> 10 parametros com limite.
    - Tipo 5: Corpo Hidrico   -> 10 parametros com limite.

    Essa distribuicao foi planejada para permitir que o script de resultados
    gere futuramente 57 resultados com limite e 15 sem limite, considerando
    6 amostras com 12 parametros cada.
*/

INSERT INTO dbo.Tbl_LimitesReferencia
(
    IdLimite,
    IdParametro,
    IdTipoAmostra,
    ValorMinimo,
    ValorMaximo,
    UnidadeMedida,
    ReferenciaNormativa,
    Observacao
)
SELECT
    v.IdLimite,
    v.IdParametro,
    v.IdTipoAmostra,
    v.ValorMinimo,
    v.ValorMaximo,
    v.UnidadeMedida,
    v.ReferenciaNormativa,
    v.Observacao
FROM
(
    VALUES
        (1, 1, 1, 6.0000, 9.0000, NULL, 'Limite didatico do projeto', 'Agua bruta.'),
        (2, 2, 1, NULL, 100.0000, 'NTU', 'Limite didatico do projeto', 'Agua bruta.'),
        (3, 3, 1, 4.0000, NULL, 'mg/L', 'Limite didatico do projeto', 'Agua bruta.'),
        (4, 4, 1, NULL, 10.0000, 'mg/L', 'Limite didatico do projeto', 'Agua bruta.'),
        (5, 5, 1, NULL, 30.0000, 'mg/L', 'Limite didatico do projeto', 'Agua bruta.'),
        (6, 7, 1, 15.0000, 35.0000, 'C', 'Limite didatico do projeto', 'Agua bruta.'),
        (7, 8, 1, NULL, 750.0000, 'uS/cm', 'Limite didatico do projeto', 'Agua bruta.'),
        (8, 9, 1, NULL, 500.0000, 'mg/L', 'Limite didatico do projeto', 'Agua bruta.'),
        (9, 10, 1, NULL, 3.7000, 'mg/L', 'Limite didatico do projeto', 'Agua bruta.'),

        (10, 1, 2, 6.0000, 9.5000, NULL, 'Limite didatico do projeto', 'Agua tratada.'),
        (11, 2, 2, NULL, 5.0000, 'NTU', 'Limite didatico do projeto', 'Agua tratada.'),
        (12, 5, 2, NULL, 20.0000, 'mg/L', 'Limite didatico do projeto', 'Agua tratada.'),
        (13, 6, 2, NULL, 1.0000, 'NMP/100mL', 'Limite didatico do projeto', 'Agua tratada.'),
        (14, 7, 2, 15.0000, 35.0000, 'C', 'Limite didatico do projeto', 'Agua tratada.'),
        (15, 8, 2, NULL, 500.0000, 'uS/cm', 'Limite didatico do projeto', 'Agua tratada.'),
        (16, 9, 2, NULL, 500.0000, 'mg/L', 'Limite didatico do projeto', 'Agua tratada.'),
        (17, 10, 2, NULL, 1.5000, 'mg/L', 'Limite didatico do projeto', 'Agua tratada.'),
        (18, 11, 2, NULL, 0.1000, 'mg/L', 'Limite didatico do projeto', 'Agua tratada.'),
        (19, 12, 2, 0.2000, 2.0000, 'mg/L', 'Limite didatico do projeto', 'Agua tratada.'),

        (20, 1, 3, 6.0000, 9.0000, NULL, 'Limite didatico do projeto', 'Esgoto bruto.'),
        (21, 4, 3, NULL, 350.0000, 'mg/L', 'Limite didatico do projeto', 'Esgoto bruto.'),
        (22, 5, 3, NULL, 700.0000, 'mg/L', 'Limite didatico do projeto', 'Esgoto bruto.'),
        (23, 7, 3, 15.0000, 40.0000, 'C', 'Limite didatico do projeto', 'Esgoto bruto.'),
        (24, 8, 3, NULL, 2500.0000, 'uS/cm', 'Limite didatico do projeto', 'Esgoto bruto.'),
        (25, 9, 3, NULL, 1200.0000, 'mg/L', 'Limite didatico do projeto', 'Esgoto bruto.'),
        (26, 10, 3, NULL, 80.0000, 'mg/L', 'Limite didatico do projeto', 'Esgoto bruto.'),
        (27, 11, 3, NULL, 15.0000, 'mg/L', 'Limite didatico do projeto', 'Esgoto bruto.'),

        (28, 1, 4, 6.0000, 9.0000, NULL, 'Limite didatico do projeto', 'Esgoto tratado.'),
        (29, 2, 4, NULL, 100.0000, 'NTU', 'Limite didatico do projeto', 'Esgoto tratado.'),
        (30, 3, 4, 2.0000, NULL, 'mg/L', 'Limite didatico do projeto', 'Esgoto tratado.'),
        (31, 4, 4, NULL, 60.0000, 'mg/L', 'Limite didatico do projeto', 'Esgoto tratado.'),
        (32, 5, 4, NULL, 180.0000, 'mg/L', 'Limite didatico do projeto', 'Esgoto tratado.'),
        (33, 6, 4, NULL, 1000.0000, 'NMP/100mL', 'Limite didatico do projeto', 'Esgoto tratado.'),
        (34, 7, 4, 15.0000, 40.0000, 'C', 'Limite didatico do projeto', 'Esgoto tratado.'),
        (35, 9, 4, NULL, 500.0000, 'mg/L', 'Limite didatico do projeto', 'Esgoto tratado.'),
        (36, 10, 4, NULL, 20.0000, 'mg/L', 'Limite didatico do projeto', 'Esgoto tratado.'),
        (37, 11, 4, NULL, 4.0000, 'mg/L', 'Limite didatico do projeto', 'Esgoto tratado.'),

        (38, 1, 5, 6.0000, 9.0000, NULL, 'Limite didatico do projeto', 'Corpo hidrico.'),
        (39, 2, 5, NULL, 40.0000, 'NTU', 'Limite didatico do projeto', 'Corpo hidrico.'),
        (40, 3, 5, 5.0000, NULL, 'mg/L', 'Limite didatico do projeto', 'Corpo hidrico.'),
        (41, 4, 5, NULL, 5.0000, 'mg/L', 'Limite didatico do projeto', 'Corpo hidrico.'),
        (42, 5, 5, NULL, 20.0000, 'mg/L', 'Limite didatico do projeto', 'Corpo hidrico.'),
        (43, 6, 5, NULL, 1000.0000, 'NMP/100mL', 'Limite didatico do projeto', 'Corpo hidrico.'),
        (44, 7, 5, 15.0000, 35.0000, 'C', 'Limite didatico do projeto', 'Corpo hidrico.'),
        (45, 8, 5, NULL, 750.0000, 'uS/cm', 'Limite didatico do projeto', 'Corpo hidrico.'),
        (46, 9, 5, NULL, 500.0000, 'mg/L', 'Limite didatico do projeto', 'Corpo hidrico.'),
        (47, 11, 5, NULL, 0.1500, 'mg/L', 'Limite didatico do projeto', 'Corpo hidrico.')
) AS v
(
    IdLimite,
    IdParametro,
    IdTipoAmostra,
    ValorMinimo,
    ValorMaximo,
    UnidadeMedida,
    ReferenciaNormativa,
    Observacao
)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Tbl_LimitesReferencia AS l
    WHERE l.IdLimite = v.IdLimite
);
GO

/*
    Validacoes esperadas apos a execucao deste script:
    - TotalResponsaveis: 4
    - TotalStatus: 5
    - TotalTiposAmostra: 5
    - TotalPontosColeta: 6
    - TotalParametros: 12
    - TotalLimitesReferencia: 47
*/

SELECT COUNT(*) AS TotalResponsaveis
FROM dbo.Tbl_Responsaveis;

SELECT COUNT(*) AS TotalStatus
FROM dbo.Tbl_StatusAmostra;

SELECT COUNT(*) AS TotalTiposAmostra
FROM dbo.Tbl_TiposAmostra;

SELECT COUNT(*) AS TotalPontosColeta
FROM dbo.Tbl_PontosColeta;

SELECT COUNT(*) AS TotalParametros
FROM dbo.Tbl_Parametros;

SELECT COUNT(*) AS TotalLimitesReferencia
FROM dbo.Tbl_LimitesReferencia;
GO
