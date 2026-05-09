/*
    Projeto: QualidadeAmbiental_SQLServer
    Arquivo: 06_consultas_analiticas.sql
    Objetivo: reunir consultas de validacao, auditoria e analise dos dados
              ambientais carregados no banco QualidadeAmbiental.

    Observacoes:
    - Execute este script apos o arquivo 05_views_oficiais.sql.
    - Este script nao cria, altera ou remove objetos.
    - Todas as consultas abaixo sao apenas SELECT.
    - Os limites de referencia sao didaticos e nao representam norma real.
*/

USE QualidadeAmbiental;
GO

/*
    1. Validacao dos cadastros principais

    Resultados esperados:
    - TotalResponsaveis: 4
    - TotalStatus: 5
    - TotalTiposAmostra: 5
    - TotalPontosColeta: 6
    - TotalParametros: 12
    - TotalLimitesReferencia: 47
*/

SELECT 'Tbl_Responsaveis' AS Entidade, COUNT(*) AS TotalRegistros
FROM dbo.Tbl_Responsaveis
UNION ALL
SELECT 'Tbl_StatusAmostra', COUNT(*)
FROM dbo.Tbl_StatusAmostra
UNION ALL
SELECT 'Tbl_TiposAmostra', COUNT(*)
FROM dbo.Tbl_TiposAmostra
UNION ALL
SELECT 'Tbl_PontosColeta', COUNT(*)
FROM dbo.Tbl_PontosColeta
UNION ALL
SELECT 'Tbl_Parametros', COUNT(*)
FROM dbo.Tbl_Parametros
UNION ALL
SELECT 'Tbl_LimitesReferencia', COUNT(*)
FROM dbo.Tbl_LimitesReferencia;
GO

/*
    2. Validacao das amostras e resultados analiticos

    Resultados esperados:
    - TotalAmostras: 6
    - TotalResultadosAnaliticos: 72
*/

SELECT COUNT(*) AS TotalAmostras
FROM dbo.Tbl_Amostras;

SELECT COUNT(*) AS TotalResultadosAnaliticos
FROM dbo.Tbl_ResultadosAnalise;
GO

/*
    3. Validacao consolidada da conformidade

    Resultados esperados:
    - TotalResultadosAnaliticos: 72
    - ResultadosComLimite: 57
    - ResultadosSemLimite: 15
    - ConformesComLimite: 50
    - NaoConformesComLimite: 7
*/

SELECT
    COUNT(*) AS TotalResultadosAnaliticos,
    SUM(PossuiLimiteReferencia) AS ResultadosComLimite,
    SUM(CASE WHEN PossuiLimiteReferencia = 0 THEN 1 ELSE 0 END) AS ResultadosSemLimite,
    SUM(CASE WHEN IndicadorNaoConforme = 0 THEN 1 ELSE 0 END) AS ConformesComLimite,
    SUM(CASE WHEN IndicadorNaoConforme = 1 THEN 1 ELSE 0 END) AS NaoConformesComLimite
FROM dbo.VW_ConformidadeResultados;
GO

/*
    4. Distribuicao por classificacao oficial
*/

SELECT
    ClassificacaoResultado,
    COUNT(*) AS TotalResultados
FROM dbo.VW_ConformidadeResultados
GROUP BY
    ClassificacaoResultado
ORDER BY
    TotalResultados DESC,
    ClassificacaoResultado;
GO

/*
    5. Resultados fora do padrao
*/

SELECT
    IdResultado,
    CodigoAmostra,
    DataColeta,
    NomeTipoAmostra,
    NomePonto,
    NomeParametro,
    ValorResultado,
    UnidadeMedida,
    ValorMinimo,
    ValorMaximo,
    ClassificacaoResultado
FROM dbo.VW_ResultadosForaDoPadrao
ORDER BY
    DataColeta,
    CodigoAmostra,
    NomeParametro;
GO

/*
    6. Resultados sem limite de referencia
*/

SELECT
    IdResultado,
    CodigoAmostra,
    DataColeta,
    NomeTipoAmostra,
    NomePonto,
    NomeParametro,
    ValorResultado,
    UnidadeMedida,
    ClassificacaoResultado
FROM dbo.VW_ResultadosSemLimiteReferencia
ORDER BY
    DataColeta,
    CodigoAmostra,
    NomeParametro;
GO

/*
    7. Conformidade mensal
*/

SELECT
    AnoColeta,
    MesColeta,
    TotalResultados,
    ResultadosComLimite,
    ResultadosSemLimite,
    ResultadosConformesComLimite,
    ResultadosNaoConformesComLimite,
    PercentualConformidadeComLimite
FROM dbo.VW_ConformidadeMensal
ORDER BY
    AnoColeta,
    MesColeta;
GO

/*
    8. Ranking de parametros criticos
*/

SELECT
    IdParametro,
    NomeParametro,
    Categoria,
    TotalResultados,
    ResultadosComLimite,
    ResultadosSemLimite,
    TotalNaoConformidades,
    PercentualNaoConformidadeComLimite
FROM dbo.VW_RankingParametrosCriticos
ORDER BY
    TotalNaoConformidades DESC,
    PercentualNaoConformidadeComLimite DESC,
    NomeParametro;
GO

/*
    9. Eficiencia de remocao da ETE

    A view compara Esgoto Bruto e Esgoto Tratado pelo mesmo parametro
    e pela mesma data de coleta.
*/

SELECT
    IdParametro,
    NomeParametro,
    UnidadeMedida,
    DataColetaComparacao,
    ValorEsgotoBruto,
    ValorEsgotoTratado,
    PercentualRemocao,
    CodigoAmostraEntrada,
    CodigoAmostraSaida,
    TotalResultadosEntrada,
    TotalResultadosSaida
FROM dbo.VW_EficienciaRemocaoETE
ORDER BY
    NomeParametro;
GO

/*
    10. Analise por tipo de amostra
*/

SELECT
    NomeTipoAmostra,
    COUNT(*) AS TotalResultados,
    SUM(PossuiLimiteReferencia) AS ResultadosComLimite,
    SUM(CASE WHEN PossuiLimiteReferencia = 0 THEN 1 ELSE 0 END) AS ResultadosSemLimite,
    SUM(CASE WHEN IndicadorNaoConforme = 0 THEN 1 ELSE 0 END) AS ConformesComLimite,
    SUM(CASE WHEN IndicadorNaoConforme = 1 THEN 1 ELSE 0 END) AS NaoConformesComLimite
FROM dbo.VW_ConformidadeResultados
GROUP BY
    NomeTipoAmostra
ORDER BY
    NomeTipoAmostra;
GO

/*
    11. Analise por ponto de coleta
*/

SELECT
    NomePonto,
    TipoPonto,
    Municipio,
    Estado,
    COUNT(*) AS TotalResultados,
    SUM(CASE WHEN IndicadorNaoConforme = 1 THEN 1 ELSE 0 END) AS NaoConformesComLimite
FROM dbo.VW_ConformidadeResultados
GROUP BY
    NomePonto,
    TipoPonto,
    Municipio,
    Estado
ORDER BY
    NaoConformesComLimite DESC,
    NomePonto;
GO

/*
    12. Checklist final de validacao

    A coluna Situacao deve retornar OK para todos os itens.
*/

SELECT
    'Total de resultados analiticos' AS Validacao,
    72 AS ValorEsperado,
    COUNT(*) AS ValorEncontrado,
    CASE WHEN COUNT(*) = 72 THEN 'OK' ELSE 'DIVERGENTE' END AS Situacao
FROM dbo.VW_ConformidadeResultados
UNION ALL
SELECT
    'Resultados com limite',
    57,
    SUM(PossuiLimiteReferencia),
    CASE WHEN SUM(PossuiLimiteReferencia) = 57 THEN 'OK' ELSE 'DIVERGENTE' END
FROM dbo.VW_ConformidadeResultados
UNION ALL
SELECT
    'Resultados sem limite',
    15,
    SUM(CASE WHEN PossuiLimiteReferencia = 0 THEN 1 ELSE 0 END),
    CASE
        WHEN SUM(CASE WHEN PossuiLimiteReferencia = 0 THEN 1 ELSE 0 END) = 15
        THEN 'OK'
        ELSE 'DIVERGENTE'
    END
FROM dbo.VW_ConformidadeResultados
UNION ALL
SELECT
    'Conformes com limite',
    50,
    SUM(CASE WHEN IndicadorNaoConforme = 0 THEN 1 ELSE 0 END),
    CASE
        WHEN SUM(CASE WHEN IndicadorNaoConforme = 0 THEN 1 ELSE 0 END) = 50
        THEN 'OK'
        ELSE 'DIVERGENTE'
    END
FROM dbo.VW_ConformidadeResultados
UNION ALL
SELECT
    'Nao conformes com limite',
    7,
    SUM(CASE WHEN IndicadorNaoConforme = 1 THEN 1 ELSE 0 END),
    CASE
        WHEN SUM(CASE WHEN IndicadorNaoConforme = 1 THEN 1 ELSE 0 END) = 7
        THEN 'OK'
        ELSE 'DIVERGENTE'
    END
FROM dbo.VW_ConformidadeResultados;
GO
