/*
    Projeto: QualidadeAmbiental_SQLServer
    Arquivo: 2026-05-12_v1.2.0_stored_procedures.sql
    Objetivo: criar stored procedures analiticas parametrizadas para apoiar
              consultas recorrentes, validacoes de entrada e evidencias no SSMS.

    Observacoes:
    - Execute este script apos os scripts oficiais da versao v1.0.0.
    - A migration v1.1.0 de indices e recomendada antes desta fase.
    - As procedures sao analiticas e somente leitura.
    - As regras de conformidade continuam centralizadas nas views oficiais.
    - Os limites de referencia sao didaticos e nao representam norma real.
*/

USE QualidadeAmbiental;
GO

/*
    Procedure: dbo.usp_ConformidadePorPeriodo

    Objetivo:
    Consolidar indicadores de conformidade para um periodo e filtros opcionais.

    Fonte principal:
    - dbo.VW_ConformidadeResultados
*/
CREATE OR ALTER PROCEDURE dbo.usp_ConformidadePorPeriodo
    @DataInicio DATE = NULL,
    @DataFim DATE = NULL,
    @IdTipoAmostra INT = NULL,
    @IdPontoColeta INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @DataInicio IS NOT NULL
       AND @DataFim IS NOT NULL
       AND @DataInicio > @DataFim
    BEGIN
        THROW 51001, 'DataInicio nao pode ser maior que DataFim.', 1;
    END;

    SELECT
        @DataInicio AS DataInicioFiltro,
        @DataFim AS DataFimFiltro,
        @IdTipoAmostra AS IdTipoAmostraFiltro,
        @IdPontoColeta AS IdPontoColetaFiltro,
        COUNT(*) AS TotalResultados,
        SUM(PossuiLimiteReferencia) AS ResultadosComLimite,
        SUM(CASE WHEN PossuiLimiteReferencia = 0 THEN 1 ELSE 0 END) AS ResultadosSemLimite,
        SUM(CASE WHEN IndicadorNaoConforme = 0 THEN 1 ELSE 0 END) AS ResultadosConformesComLimite,
        SUM(CASE WHEN IndicadorNaoConforme = 1 THEN 1 ELSE 0 END) AS ResultadosNaoConformesComLimite,
        CAST(
            100.0
            * SUM(CASE WHEN IndicadorNaoConforme = 0 THEN 1 ELSE 0 END)
            / NULLIF(SUM(PossuiLimiteReferencia), 0)
            AS DECIMAL(6,2)
        ) AS PercentualConformidadeComLimite
    FROM dbo.VW_ConformidadeResultados
    WHERE (@DataInicio IS NULL OR DataColeta >= @DataInicio)
      AND (@DataFim IS NULL OR DataColeta <= @DataFim)
      AND (@IdTipoAmostra IS NULL OR IdTipoAmostra = @IdTipoAmostra)
      AND (@IdPontoColeta IS NULL OR IdPontoColeta = @IdPontoColeta);
END;
GO

/*
    Procedure: dbo.usp_ResultadosForaPadrao

    Objetivo:
    Listar resultados acima ou abaixo dos limites didaticos, com filtros opcionais.

    Fonte principal:
    - dbo.VW_ConformidadeResultados
*/
CREATE OR ALTER PROCEDURE dbo.usp_ResultadosForaPadrao
    @DataInicio DATE = NULL,
    @DataFim DATE = NULL,
    @IdPontoColeta INT = NULL,
    @IdTipoAmostra INT = NULL,
    @IdParametro INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @DataInicio IS NOT NULL
       AND @DataFim IS NOT NULL
       AND @DataInicio > @DataFim
    BEGIN
        THROW 51002, 'DataInicio nao pode ser maior que DataFim.', 1;
    END;

    SELECT
        IdResultado,
        IdAmostra,
        CodigoAmostra,
        DataColeta,
        IdTipoAmostra,
        NomeTipoAmostra,
        IdPontoColeta,
        NomePonto,
        Municipio,
        Estado,
        IdParametro,
        NomeParametro,
        Categoria,
        ValorResultado,
        UnidadeMedida,
        ValorMinimo,
        ValorMaximo,
        ClassificacaoResultado
    FROM dbo.VW_ConformidadeResultados
    WHERE ClassificacaoResultado IN
    (
        'Acima do limite maximo',
        'Abaixo do limite minimo'
    )
      AND (@DataInicio IS NULL OR DataColeta >= @DataInicio)
      AND (@DataFim IS NULL OR DataColeta <= @DataFim)
      AND (@IdPontoColeta IS NULL OR IdPontoColeta = @IdPontoColeta)
      AND (@IdTipoAmostra IS NULL OR IdTipoAmostra = @IdTipoAmostra)
      AND (@IdParametro IS NULL OR IdParametro = @IdParametro)
    ORDER BY
        DataColeta,
        CodigoAmostra,
        NomeParametro;
END;
GO

/*
    Procedure: dbo.usp_RankingParametrosCriticos

    Objetivo:
    Gerar ranking de parametros criticos por nao conformidade, com TOP N e
    filtros opcionais.

    Fonte principal:
    - dbo.VW_ConformidadeResultados
*/
CREATE OR ALTER PROCEDURE dbo.usp_RankingParametrosCriticos
    @TopN INT = NULL,
    @DataInicio DATE = NULL,
    @DataFim DATE = NULL,
    @IdTipoAmostra INT = NULL,
    @IdPontoColeta INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @DataInicio IS NOT NULL
       AND @DataFim IS NOT NULL
       AND @DataInicio > @DataFim
    BEGIN
        THROW 51003, 'DataInicio nao pode ser maior que DataFim.', 1;
    END;

    IF @TopN IS NOT NULL
       AND @TopN <= 0
    BEGIN
        THROW 51004, 'TopN deve ser maior que zero quando informado.', 1;
    END;

    DECLARE @QuantidadeLinhas INT = ISNULL(@TopN, 2147483647);

    SELECT TOP (@QuantidadeLinhas)
        IdParametro,
        NomeParametro,
        Categoria,
        COUNT(*) AS TotalResultados,
        SUM(PossuiLimiteReferencia) AS ResultadosComLimite,
        SUM(CASE WHEN PossuiLimiteReferencia = 0 THEN 1 ELSE 0 END) AS ResultadosSemLimite,
        SUM(CASE WHEN IndicadorNaoConforme = 1 THEN 1 ELSE 0 END) AS TotalNaoConformidades,
        CAST(
            100.0
            * SUM(CASE WHEN IndicadorNaoConforme = 1 THEN 1 ELSE 0 END)
            / NULLIF(SUM(PossuiLimiteReferencia), 0)
            AS DECIMAL(6,2)
        ) AS PercentualNaoConformidadeComLimite
    FROM dbo.VW_ConformidadeResultados
    WHERE (@DataInicio IS NULL OR DataColeta >= @DataInicio)
      AND (@DataFim IS NULL OR DataColeta <= @DataFim)
      AND (@IdTipoAmostra IS NULL OR IdTipoAmostra = @IdTipoAmostra)
      AND (@IdPontoColeta IS NULL OR IdPontoColeta = @IdPontoColeta)
    GROUP BY
        IdParametro,
        NomeParametro,
        Categoria
    ORDER BY
        TotalNaoConformidades DESC,
        PercentualNaoConformidadeComLimite DESC,
        NomeParametro;
END;
GO

/*
    Validacao das procedures criadas nesta migration.
*/
SELECT
    SCHEMA_NAME(p.schema_id) AS NomeSchema,
    p.name AS NomeProcedure,
    p.type_desc AS TipoObjeto,
    p.create_date AS DataCriacao,
    p.modify_date AS DataAlteracao
FROM sys.procedures AS p
WHERE p.schema_id = SCHEMA_ID('dbo')
  AND p.name IN
  (
      'usp_ConformidadePorPeriodo',
      'usp_ResultadosForaPadrao',
      'usp_RankingParametrosCriticos'
  )
ORDER BY
    p.name;
GO

/*
    Exemplos para execucao manual no SSMS.

    Execute um exemplo por vez apos a migration, conforme a evidencia visual
    que sera capturada. Os EXECs permanecem comentados para separar a criacao
    dos objetos da geracao manual de relatorios e testes.

    -- Periodo valido: conformidade consolidada.
    EXEC dbo.usp_ConformidadePorPeriodo
        @DataInicio = '2026-01-01',
        @DataFim = '2026-12-31';

    -- Periodo valido: resultados fora do padrao.
    EXEC dbo.usp_ResultadosForaPadrao
        @DataInicio = '2026-01-01',
        @DataFim = '2026-12-31';

    -- TopN valido e periodo valido: ranking de parametros criticos.
    EXEC dbo.usp_RankingParametrosCriticos
        @TopN = 5,
        @DataInicio = '2026-01-01',
        @DataFim = '2026-12-31';

    -- Erro esperado: DataInicio maior que DataFim.
    EXEC dbo.usp_ConformidadePorPeriodo
        @DataInicio = '2026-12-31',
        @DataFim = '2026-01-01';

    -- Erro esperado: TopN menor ou igual a zero.
    EXEC dbo.usp_RankingParametrosCriticos
        @TopN = 0;
*/
