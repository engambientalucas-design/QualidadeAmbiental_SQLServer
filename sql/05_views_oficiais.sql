/*
    Projeto: QualidadeAmbiental_SQLServer
    Arquivo: 05_views_oficiais.sql
    Objetivo: criar as views oficiais de analise, conformidade e indicadores
              ambientais do banco QualidadeAmbiental.

    Observacoes:
    - Execute este script apos o arquivo 04_insert_amostras_resultados.sql.
    - As views de conformidade usam LEFT JOIN com Tbl_LimitesReferencia.
    - O LEFT JOIN preserva resultados analiticos sem limite cadastrado.
    - Os limites de referencia sao didaticos e nao representam norma real.
*/

USE QualidadeAmbiental;
GO

CREATE OR ALTER VIEW dbo.VW_ConformidadeResultados
AS
SELECT
    r.IdResultado,
    r.IdAmostra,
    a.CodigoAmostra,
    a.DataColeta,
    a.HoraColeta,
    a.IdTipoAmostra,
    ta.NomeTipoAmostra,
    a.IdPontoColeta,
    pc.NomePonto,
    pc.TipoPonto,
    pc.Municipio,
    pc.Estado,
    a.IdResponsavel,
    resp.NomeResponsavel,
    a.IdStatus,
    st.NomeStatus,
    r.IdParametro,
    p.NomeParametro,
    p.Categoria,
    r.ValorResultado,
    COALESCE(r.UnidadeMedida, p.UnidadeMedida, lr.UnidadeMedida) AS UnidadeMedida,
    r.DataAnalise,
    r.MetodoAnalise,
    lr.IdLimite,
    lr.ValorMinimo,
    lr.ValorMaximo,
    lr.ReferenciaNormativa,
    CASE
        WHEN lr.IdLimite IS NULL THEN 'Sem limite de referencia'
        WHEN lr.ValorMaximo IS NOT NULL
             AND r.ValorResultado > lr.ValorMaximo THEN 'Acima do limite maximo'
        WHEN lr.ValorMinimo IS NOT NULL
             AND r.ValorResultado < lr.ValorMinimo THEN 'Abaixo do limite minimo'
        ELSE 'Conforme'
    END AS ClassificacaoResultado,
    CASE
        WHEN lr.IdLimite IS NULL THEN 0
        ELSE 1
    END AS PossuiLimiteReferencia,
    CASE
        WHEN lr.IdLimite IS NULL THEN NULL
        WHEN lr.ValorMaximo IS NOT NULL
             AND r.ValorResultado > lr.ValorMaximo THEN 1
        WHEN lr.ValorMinimo IS NOT NULL
             AND r.ValorResultado < lr.ValorMinimo THEN 1
        ELSE 0
    END AS IndicadorNaoConforme
FROM dbo.Tbl_ResultadosAnalise AS r
INNER JOIN dbo.Tbl_Amostras AS a
    ON a.IdAmostra = r.IdAmostra
INNER JOIN dbo.Tbl_TiposAmostra AS ta
    ON ta.IdTipoAmostra = a.IdTipoAmostra
INNER JOIN dbo.Tbl_PontosColeta AS pc
    ON pc.IdPontoColeta = a.IdPontoColeta
INNER JOIN dbo.Tbl_Responsaveis AS resp
    ON resp.IdResponsavel = a.IdResponsavel
INNER JOIN dbo.Tbl_StatusAmostra AS st
    ON st.IdStatus = a.IdStatus
INNER JOIN dbo.Tbl_Parametros AS p
    ON p.IdParametro = r.IdParametro
LEFT JOIN dbo.Tbl_LimitesReferencia AS lr
    ON lr.IdParametro = r.IdParametro
    AND lr.IdTipoAmostra = a.IdTipoAmostra;
GO

CREATE OR ALTER VIEW dbo.VW_ResultadosForaDoPadrao
AS
SELECT
    IdResultado,
    IdAmostra,
    CodigoAmostra,
    DataColeta,
    NomeTipoAmostra,
    NomePonto,
    Municipio,
    Estado,
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
);
GO

CREATE OR ALTER VIEW dbo.VW_ResultadosSemLimiteReferencia
AS
SELECT
    IdResultado,
    IdAmostra,
    CodigoAmostra,
    DataColeta,
    NomeTipoAmostra,
    NomePonto,
    Municipio,
    Estado,
    NomeParametro,
    Categoria,
    ValorResultado,
    UnidadeMedida,
    ClassificacaoResultado
FROM dbo.VW_ConformidadeResultados
WHERE ClassificacaoResultado = 'Sem limite de referencia';
GO

CREATE OR ALTER VIEW dbo.VW_ConformidadeMensal
AS
SELECT
    YEAR(DataColeta) AS AnoColeta,
    MONTH(DataColeta) AS MesColeta,
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
GROUP BY
    YEAR(DataColeta),
    MONTH(DataColeta);
GO

CREATE OR ALTER VIEW dbo.VW_RankingParametrosCriticos
AS
SELECT
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
GROUP BY
    IdParametro,
    NomeParametro,
    Categoria;
GO

CREATE OR ALTER VIEW dbo.VW_EficienciaRemocaoETE
AS
WITH EsgotoBruto AS
(
    SELECT
        IdParametro,
        NomeParametro,
        UnidadeMedida,
        DataColeta,
        AVG(ValorResultado) AS ValorEsgotoBruto,
        MAX(CodigoAmostra) AS CodigoAmostra,
        COUNT(*) AS TotalResultadosEntrada
    FROM dbo.VW_ConformidadeResultados
    WHERE NomeTipoAmostra = 'Esgoto Bruto'
      AND NomeParametro IN
      (
          'DBO',
          'DQO',
          'Solidos Totais',
          'Nitrogenio Amoniacal',
          'Fosforo Total'
      )
    GROUP BY
        IdParametro,
        NomeParametro,
        UnidadeMedida,
        DataColeta
),
EsgotoTratado AS
(
    SELECT
        IdParametro,
        NomeParametro,
        UnidadeMedida,
        DataColeta,
        AVG(ValorResultado) AS ValorEsgotoTratado,
        MAX(CodigoAmostra) AS CodigoAmostra,
        COUNT(*) AS TotalResultadosSaida
    FROM dbo.VW_ConformidadeResultados
    WHERE NomeTipoAmostra = 'Esgoto Tratado'
      AND NomeParametro IN
      (
          'DBO',
          'DQO',
          'Solidos Totais',
          'Nitrogenio Amoniacal',
          'Fosforo Total'
      )
    GROUP BY
        IdParametro,
        NomeParametro,
        UnidadeMedida,
        DataColeta
)
SELECT
    bruto.IdParametro,
    bruto.NomeParametro,
    bruto.UnidadeMedida,
    bruto.DataColeta AS DataColetaComparacao,
    bruto.ValorEsgotoBruto,
    tratado.ValorEsgotoTratado,
    CAST(
        100.0
        * (bruto.ValorEsgotoBruto - tratado.ValorEsgotoTratado)
        / NULLIF(bruto.ValorEsgotoBruto, 0)
        AS DECIMAL(8,2)
    ) AS PercentualRemocao,
    bruto.CodigoAmostra AS CodigoAmostraEntrada,
    tratado.CodigoAmostra AS CodigoAmostraSaida,
    bruto.TotalResultadosEntrada,
    tratado.TotalResultadosSaida
FROM EsgotoBruto AS bruto
INNER JOIN EsgotoTratado AS tratado
    ON tratado.IdParametro = bruto.IdParametro
    AND tratado.DataColeta = bruto.DataColeta;
GO
