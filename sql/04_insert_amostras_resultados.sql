/*
    Projeto: QualidadeAmbiental_SQLServer
    Arquivo: 04_insert_amostras_resultados.sql
    Objetivo: inserir amostras e resultados analiticos didaticos do projeto.

    Observacoes:
    - Execute este script apos o arquivo 03_insert_cadastros.sql.
    - Este script usa IDs explicitos para manter os dados previsiveis.
    - Sao inseridas 6 amostras e 72 resultados analiticos.
    - A distribuicao foi planejada para validar:
        Total de resultados analiticos: 72
        Resultados com limite: 57
        Resultados sem limite: 15
        Conformes com limite: 50
        Nao conformes com limite: 7
*/

USE QualidadeAmbiental;
GO

INSERT INTO dbo.Tbl_Amostras
(
    IdAmostra,
    CodigoAmostra,
    IdPontoColeta,
    IdTipoAmostra,
    IdResponsavel,
    IdStatus,
    DataColeta,
    HoraColeta,
    Observacao
)
SELECT
    v.IdAmostra,
    v.CodigoAmostra,
    v.IdPontoColeta,
    v.IdTipoAmostra,
    v.IdResponsavel,
    v.IdStatus,
    v.DataColeta,
    v.HoraColeta,
    v.Observacao
FROM
(
    VALUES
        (1, 'QA-2026-001', 1, 1, 3, 3, CONVERT(DATE, '2026-04-01'), CONVERT(TIME(0), '08:10'), 'Amostra didatica de agua bruta.'),
        (2, 'QA-2026-002', 2, 2, 2, 3, CONVERT(DATE, '2026-04-01'), CONVERT(TIME(0), '09:00'), 'Amostra didatica de agua tratada.'),
        (3, 'QA-2026-003', 3, 3, 3, 3, CONVERT(DATE, '2026-04-02'), CONVERT(TIME(0), '07:45'), 'Amostra didatica de esgoto bruto.'),
        (4, 'QA-2026-004', 4, 4, 2, 3, CONVERT(DATE, '2026-04-02'), CONVERT(TIME(0), '10:30'), 'Amostra didatica de esgoto tratado.'),
        (5, 'QA-2026-005', 5, 5, 1, 3, CONVERT(DATE, '2026-04-03'), CONVERT(TIME(0), '08:40'), 'Amostra didatica de corpo hidrico.'),
        (6, 'QA-2026-006', 6, 2, 4, 3, CONVERT(DATE, '2026-04-03'), CONVERT(TIME(0), '11:15'), 'Segunda amostra didatica de agua tratada.')
) AS v
(
    IdAmostra,
    CodigoAmostra,
    IdPontoColeta,
    IdTipoAmostra,
    IdResponsavel,
    IdStatus,
    DataColeta,
    HoraColeta,
    Observacao
)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Tbl_Amostras AS a
    WHERE a.IdAmostra = v.IdAmostra
);
GO

INSERT INTO dbo.Tbl_ResultadosAnalise
(
    IdResultado,
    IdAmostra,
    IdParametro,
    ValorResultado,
    UnidadeMedida,
    DataAnalise,
    MetodoAnalise,
    Observacao
)
SELECT
    v.IdResultado,
    v.IdAmostra,
    v.IdParametro,
    v.ValorResultado,
    v.UnidadeMedida,
    v.DataAnalise,
    v.MetodoAnalise,
    v.Observacao
FROM
(
    VALUES
        (1, 1, 1, 7.2000, NULL, CONVERT(DATE, '2026-04-04'), 'Metodo didatico', 'Conforme.'),
        (2, 1, 2, 120.0000, 'NTU', CONVERT(DATE, '2026-04-04'), 'Metodo didatico', 'Nao conforme: acima do limite maximo.'),
        (3, 1, 3, 5.8000, 'mg/L', CONVERT(DATE, '2026-04-04'), 'Metodo didatico', 'Conforme.'),
        (4, 1, 4, 8.0000, 'mg/L', CONVERT(DATE, '2026-04-04'), 'Metodo didatico', 'Conforme.'),
        (5, 1, 5, 25.0000, 'mg/L', CONVERT(DATE, '2026-04-04'), 'Metodo didatico', 'Conforme.'),
        (6, 1, 6, 500.0000, 'NMP/100mL', CONVERT(DATE, '2026-04-04'), 'Metodo didatico', 'Sem limite de referencia.'),
        (7, 1, 7, 27.0000, 'C', CONVERT(DATE, '2026-04-04'), 'Metodo didatico', 'Conforme.'),
        (8, 1, 8, 420.0000, 'uS/cm', CONVERT(DATE, '2026-04-04'), 'Metodo didatico', 'Conforme.'),
        (9, 1, 9, 300.0000, 'mg/L', CONVERT(DATE, '2026-04-04'), 'Metodo didatico', 'Conforme.'),
        (10, 1, 10, 2.0000, 'mg/L', CONVERT(DATE, '2026-04-04'), 'Metodo didatico', 'Conforme.'),
        (11, 1, 11, 0.1200, 'mg/L', CONVERT(DATE, '2026-04-04'), 'Metodo didatico', 'Sem limite de referencia.'),
        (12, 1, 12, 0.3000, 'mg/L', CONVERT(DATE, '2026-04-04'), 'Metodo didatico', 'Sem limite de referencia.'),

        (13, 2, 1, 7.4000, NULL, CONVERT(DATE, '2026-04-05'), 'Metodo didatico', 'Conforme.'),
        (14, 2, 2, 2.0000, 'NTU', CONVERT(DATE, '2026-04-05'), 'Metodo didatico', 'Conforme.'),
        (15, 2, 3, 6.5000, 'mg/L', CONVERT(DATE, '2026-04-05'), 'Metodo didatico', 'Sem limite de referencia.'),
        (16, 2, 4, 3.0000, 'mg/L', CONVERT(DATE, '2026-04-05'), 'Metodo didatico', 'Sem limite de referencia.'),
        (17, 2, 5, 10.0000, 'mg/L', CONVERT(DATE, '2026-04-05'), 'Metodo didatico', 'Conforme.'),
        (18, 2, 6, 0.0000, 'NMP/100mL', CONVERT(DATE, '2026-04-05'), 'Metodo didatico', 'Conforme.'),
        (19, 2, 7, 25.0000, 'C', CONVERT(DATE, '2026-04-05'), 'Metodo didatico', 'Conforme.'),
        (20, 2, 8, 250.0000, 'uS/cm', CONVERT(DATE, '2026-04-05'), 'Metodo didatico', 'Conforme.'),
        (21, 2, 9, 180.0000, 'mg/L', CONVERT(DATE, '2026-04-05'), 'Metodo didatico', 'Conforme.'),
        (22, 2, 10, 0.8000, 'mg/L', CONVERT(DATE, '2026-04-05'), 'Metodo didatico', 'Conforme.'),
        (23, 2, 11, 0.0500, 'mg/L', CONVERT(DATE, '2026-04-05'), 'Metodo didatico', 'Conforme.'),
        (24, 2, 12, 0.1000, 'mg/L', CONVERT(DATE, '2026-04-05'), 'Metodo didatico', 'Nao conforme: abaixo do limite minimo.'),

        (25, 3, 1, 7.1000, NULL, CONVERT(DATE, '2026-04-06'), 'Metodo didatico', 'Conforme.'),
        (26, 3, 2, 180.0000, 'NTU', CONVERT(DATE, '2026-04-06'), 'Metodo didatico', 'Sem limite de referencia.'),
        (27, 3, 3, 1.0000, 'mg/L', CONVERT(DATE, '2026-04-06'), 'Metodo didatico', 'Sem limite de referencia.'),
        (28, 3, 4, 420.0000, 'mg/L', CONVERT(DATE, '2026-04-06'), 'Metodo didatico', 'Nao conforme: acima do limite maximo.'),
        (29, 3, 5, 600.0000, 'mg/L', CONVERT(DATE, '2026-04-06'), 'Metodo didatico', 'Conforme.'),
        (30, 3, 6, 100000.0000, 'NMP/100mL', CONVERT(DATE, '2026-04-06'), 'Metodo didatico', 'Sem limite de referencia.'),
        (31, 3, 7, 29.0000, 'C', CONVERT(DATE, '2026-04-06'), 'Metodo didatico', 'Conforme.'),
        (32, 3, 8, 1800.0000, 'uS/cm', CONVERT(DATE, '2026-04-06'), 'Metodo didatico', 'Conforme.'),
        (33, 3, 9, 900.0000, 'mg/L', CONVERT(DATE, '2026-04-06'), 'Metodo didatico', 'Conforme.'),
        (34, 3, 10, 60.0000, 'mg/L', CONVERT(DATE, '2026-04-06'), 'Metodo didatico', 'Conforme.'),
        (35, 3, 11, 10.0000, 'mg/L', CONVERT(DATE, '2026-04-06'), 'Metodo didatico', 'Conforme.'),
        (36, 3, 12, 0.0000, 'mg/L', CONVERT(DATE, '2026-04-06'), 'Metodo didatico', 'Sem limite de referencia.'),

        (37, 4, 1, 7.3000, NULL, CONVERT(DATE, '2026-04-07'), 'Metodo didatico', 'Conforme.'),
        (38, 4, 2, 40.0000, 'NTU', CONVERT(DATE, '2026-04-07'), 'Metodo didatico', 'Conforme.'),
        (39, 4, 3, 1.5000, 'mg/L', CONVERT(DATE, '2026-04-07'), 'Metodo didatico', 'Nao conforme: abaixo do limite minimo.'),
        (40, 4, 4, 45.0000, 'mg/L', CONVERT(DATE, '2026-04-07'), 'Metodo didatico', 'Conforme.'),
        (41, 4, 5, 120.0000, 'mg/L', CONVERT(DATE, '2026-04-07'), 'Metodo didatico', 'Conforme.'),
        (42, 4, 6, 800.0000, 'NMP/100mL', CONVERT(DATE, '2026-04-07'), 'Metodo didatico', 'Conforme.'),
        (43, 4, 7, 28.0000, 'C', CONVERT(DATE, '2026-04-07'), 'Metodo didatico', 'Conforme.'),
        (44, 4, 8, 1200.0000, 'uS/cm', CONVERT(DATE, '2026-04-07'), 'Metodo didatico', 'Sem limite de referencia.'),
        (45, 4, 9, 350.0000, 'mg/L', CONVERT(DATE, '2026-04-07'), 'Metodo didatico', 'Conforme.'),
        (46, 4, 10, 12.0000, 'mg/L', CONVERT(DATE, '2026-04-07'), 'Metodo didatico', 'Conforme.'),
        (47, 4, 11, 2.0000, 'mg/L', CONVERT(DATE, '2026-04-07'), 'Metodo didatico', 'Conforme.'),
        (48, 4, 12, 0.0000, 'mg/L', CONVERT(DATE, '2026-04-07'), 'Metodo didatico', 'Sem limite de referencia.'),

        (49, 5, 1, 7.0000, NULL, CONVERT(DATE, '2026-04-08'), 'Metodo didatico', 'Conforme.'),
        (50, 5, 2, 25.0000, 'NTU', CONVERT(DATE, '2026-04-08'), 'Metodo didatico', 'Conforme.'),
        (51, 5, 3, 6.0000, 'mg/L', CONVERT(DATE, '2026-04-08'), 'Metodo didatico', 'Conforme.'),
        (52, 5, 4, 3.0000, 'mg/L', CONVERT(DATE, '2026-04-08'), 'Metodo didatico', 'Conforme.'),
        (53, 5, 5, 12.0000, 'mg/L', CONVERT(DATE, '2026-04-08'), 'Metodo didatico', 'Conforme.'),
        (54, 5, 6, 1500.0000, 'NMP/100mL', CONVERT(DATE, '2026-04-08'), 'Metodo didatico', 'Nao conforme: acima do limite maximo.'),
        (55, 5, 7, 26.0000, 'C', CONVERT(DATE, '2026-04-08'), 'Metodo didatico', 'Conforme.'),
        (56, 5, 8, 400.0000, 'uS/cm', CONVERT(DATE, '2026-04-08'), 'Metodo didatico', 'Conforme.'),
        (57, 5, 9, 250.0000, 'mg/L', CONVERT(DATE, '2026-04-08'), 'Metodo didatico', 'Conforme.'),
        (58, 5, 10, 1.2000, 'mg/L', CONVERT(DATE, '2026-04-08'), 'Metodo didatico', 'Sem limite de referencia.'),
        (59, 5, 11, 0.0800, 'mg/L', CONVERT(DATE, '2026-04-08'), 'Metodo didatico', 'Conforme.'),
        (60, 5, 12, 0.0000, 'mg/L', CONVERT(DATE, '2026-04-08'), 'Metodo didatico', 'Sem limite de referencia.'),

        (61, 6, 1, 7.6000, NULL, CONVERT(DATE, '2026-04-09'), 'Metodo didatico', 'Conforme.'),
        (62, 6, 2, 8.0000, 'NTU', CONVERT(DATE, '2026-04-09'), 'Metodo didatico', 'Nao conforme: acima do limite maximo.'),
        (63, 6, 3, 6.8000, 'mg/L', CONVERT(DATE, '2026-04-09'), 'Metodo didatico', 'Sem limite de referencia.'),
        (64, 6, 4, 2.0000, 'mg/L', CONVERT(DATE, '2026-04-09'), 'Metodo didatico', 'Sem limite de referencia.'),
        (65, 6, 5, 12.0000, 'mg/L', CONVERT(DATE, '2026-04-09'), 'Metodo didatico', 'Conforme.'),
        (66, 6, 6, 0.0000, 'NMP/100mL', CONVERT(DATE, '2026-04-09'), 'Metodo didatico', 'Conforme.'),
        (67, 6, 7, 24.0000, 'C', CONVERT(DATE, '2026-04-09'), 'Metodo didatico', 'Conforme.'),
        (68, 6, 8, 320.0000, 'uS/cm', CONVERT(DATE, '2026-04-09'), 'Metodo didatico', 'Conforme.'),
        (69, 6, 9, 210.0000, 'mg/L', CONVERT(DATE, '2026-04-09'), 'Metodo didatico', 'Conforme.'),
        (70, 6, 10, 0.9000, 'mg/L', CONVERT(DATE, '2026-04-09'), 'Metodo didatico', 'Conforme.'),
        (71, 6, 11, 0.2000, 'mg/L', CONVERT(DATE, '2026-04-09'), 'Metodo didatico', 'Nao conforme: acima do limite maximo.'),
        (72, 6, 12, 0.8000, 'mg/L', CONVERT(DATE, '2026-04-09'), 'Metodo didatico', 'Conforme.')
) AS v
(
    IdResultado,
    IdAmostra,
    IdParametro,
    ValorResultado,
    UnidadeMedida,
    DataAnalise,
    MetodoAnalise,
    Observacao
)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Tbl_ResultadosAnalise AS r
    WHERE r.IdResultado = v.IdResultado
);
GO
