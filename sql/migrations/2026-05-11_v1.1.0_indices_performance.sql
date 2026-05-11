/*
    Projeto: QualidadeAmbiental_SQLServer
    Arquivo: 2026-05-11_v1.1.0_indices_performance.sql
    Objetivo: criar indices nao clusterizados para apoiar consultas analiticas,
              joins e agrupamentos usados nas views oficiais.

    Observacoes:
    - Execute este script apos os scripts oficiais da versao v1.0.0.
    - Este script faz parte da evolucao v1.1.0: indices e performance.
    - Os indices foram definidos de forma conservadora, priorizando tabelas
      operacionais e colunas usadas em joins, filtros, agrupamentos e ordenacoes.
    - O volume atual de dados e didatico; o objetivo principal e demonstrar
      criterio tecnico de indexacao e preparar o modelo para crescimento.
*/

USE QualidadeAmbiental;
GO

/*
    Indice para apoiar consultas por data de coleta, tipo de amostra e ponto.

    Beneficia:
    - VW_ConformidadeMensal
    - VW_EficienciaRemocaoETE
    - analises por tipo de amostra
    - analises por ponto de coleta
    - listagens ordenadas por DataColeta
*/
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Tbl_Amostras')
      AND name = 'IX_Tbl_Amostras_DataColeta_Tipo_Ponto'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Tbl_Amostras_DataColeta_Tipo_Ponto
    ON dbo.Tbl_Amostras
    (
        DataColeta,
        IdTipoAmostra,
        IdPontoColeta
    )
    INCLUDE
    (
        CodigoAmostra,
        IdResponsavel,
        IdStatus
    );
END;
GO

/*
    Indice complementar ao unique existente em Tbl_ResultadosAnalise.

    O projeto ja possui UQ_Tbl_ResultadosAnalise_AmostraParametro
    em (IdAmostra, IdParametro), util quando a busca parte da amostra.

    Este indice inverte a ordem para favorecer analises que partem do parametro,
    como ranking de parametros criticos e eficiencia de remocao da ETE.
*/
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Tbl_ResultadosAnalise')
      AND name = 'IX_Tbl_ResultadosAnalise_Parametro_Amostra'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Tbl_ResultadosAnalise_Parametro_Amostra
    ON dbo.Tbl_ResultadosAnalise
    (
        IdParametro,
        IdAmostra
    )
    INCLUDE
    (
        ValorResultado,
        UnidadeMedida,
        DataAnalise,
        MetodoAnalise
    );
END;
GO

/*
    Verificacao dos indices criados nesta migration.
*/
SELECT
    OBJECT_NAME(i.object_id) AS NomeTabela,
    i.name AS NomeIndice,
    i.type_desc AS TipoIndice,
    i.is_unique AS EhUnico,
    i.is_disabled AS EstaDesabilitado
FROM sys.indexes AS i
WHERE i.object_id IN
(
    OBJECT_ID('dbo.Tbl_Amostras'),
    OBJECT_ID('dbo.Tbl_ResultadosAnalise')
)
AND i.name IN
(
    'IX_Tbl_Amostras_DataColeta_Tipo_Ponto',
    'IX_Tbl_ResultadosAnalise_Parametro_Amostra'
)
ORDER BY
    NomeTabela,
    NomeIndice;
GO

/*
    Detalhamento das colunas dos indices da v1.1.0.
*/
SELECT
    OBJECT_NAME(i.object_id) AS NomeTabela,
    i.name AS NomeIndice,
    c.name AS NomeColuna,
    ic.key_ordinal AS OrdemChave,
    ic.is_included_column AS EhColunaIncluida
FROM sys.indexes AS i
INNER JOIN sys.index_columns AS ic
    ON ic.object_id = i.object_id
    AND ic.index_id = i.index_id
INNER JOIN sys.columns AS c
    ON c.object_id = ic.object_id
    AND c.column_id = ic.column_id
WHERE i.object_id IN
(
    OBJECT_ID('dbo.Tbl_Amostras'),
    OBJECT_ID('dbo.Tbl_ResultadosAnalise')
)
AND i.name IN
(
    'IX_Tbl_Amostras_DataColeta_Tipo_Ponto',
    'IX_Tbl_ResultadosAnalise_Parametro_Amostra'
)
ORDER BY
    NomeTabela,
    NomeIndice,
    CASE WHEN ic.is_included_column = 0 THEN 0 ELSE 1 END,
    ic.key_ordinal,
    ic.index_column_id;
GO
