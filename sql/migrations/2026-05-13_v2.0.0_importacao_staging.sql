/*
    Projeto: QualidadeAmbiental_SQLServer
    Arquivo: 2026-05-13_v2.0.0_importacao_staging.sql
    Objetivo: criar pipeline enxuto de importacao com controle de lote,
              staging, validacao e carga final controlada.

    Observacoes:
    - Execute preferencialmente a primeira validacao no banco
      QualidadeAmbiental_RestoreTeste, preservando o banco principal
      QualidadeAmbiental.
    - Este script cria estrutura e procedures da fase v2.0.0.
    - Este script nao insere dados reais e nao altera dados oficiais sozinho.
    - A carga final so ocorre por execucao manual da procedure de carga com
      @ConfirmarCarga = 1.
    - Nao desabilita constraints, nao desabilita triggers e nao usa MERGE.
*/

USE QualidadeAmbiental_RestoreTeste;
GO

IF OBJECT_ID('dbo.Tbl_LotesImportacao', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_LotesImportacao
    (
        IdLoteImportacao INT IDENTITY(1,1) NOT NULL,
        NomeArquivoOrigem VARCHAR(255) NULL,
        DataInicio DATETIME2(3) NOT NULL
            CONSTRAINT DF_Tbl_LotesImportacao_DataInicio
            DEFAULT (SYSDATETIME()),
        DataFim DATETIME2(3) NULL,
        StatusLote VARCHAR(20) NOT NULL
            CONSTRAINT DF_Tbl_LotesImportacao_StatusLote
            DEFAULT ('ABERTO'),
        TotalLinhas INT NOT NULL
            CONSTRAINT DF_Tbl_LotesImportacao_TotalLinhas
            DEFAULT (0),
        TotalValidas INT NOT NULL
            CONSTRAINT DF_Tbl_LotesImportacao_TotalValidas
            DEFAULT (0),
        TotalInvalidas INT NOT NULL
            CONSTRAINT DF_Tbl_LotesImportacao_TotalInvalidas
            DEFAULT (0),
        TotalCarregadas INT NOT NULL
            CONSTRAINT DF_Tbl_LotesImportacao_TotalCarregadas
            DEFAULT (0),
        Observacao VARCHAR(255) NULL,

        CONSTRAINT PK_Tbl_LotesImportacao
            PRIMARY KEY (IdLoteImportacao),

        CONSTRAINT CK_Tbl_LotesImportacao_StatusLote
            CHECK (StatusLote IN ('ABERTO', 'VALIDADO', 'CARREGADO', 'CANCELADO')),

        CONSTRAINT CK_Tbl_LotesImportacao_TotaisNaoNegativos
            CHECK
            (
                TotalLinhas >= 0
                AND TotalValidas >= 0
                AND TotalInvalidas >= 0
                AND TotalCarregadas >= 0
            )
    );
END;
GO

IF OBJECT_ID('dbo.Stg_ResultadosAnaliseImportacao', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Stg_ResultadosAnaliseImportacao
    (
        IdStaging INT IDENTITY(1,1) NOT NULL,
        IdLoteImportacao INT NOT NULL,
        NumeroLinha INT NOT NULL,
        CodigoAmostra VARCHAR(50) NULL,
        NomeParametro VARCHAR(120) NULL,
        ValorResultadoTexto VARCHAR(50) NULL,
        UnidadeMedida VARCHAR(30) NULL,
        DataAnaliseTexto VARCHAR(30) NULL,
        MetodoAnalise VARCHAR(100) NULL,
        Observacao VARCHAR(255) NULL,
        StatusValidacao VARCHAR(20) NOT NULL
            CONSTRAINT DF_Stg_ResultadosAnaliseImportacao_StatusValidacao
            DEFAULT ('PENDENTE'),
        MensagemValidacao VARCHAR(1000) NULL,
        DataCarga DATETIME2(3) NOT NULL
            CONSTRAINT DF_Stg_ResultadosAnaliseImportacao_DataCarga
            DEFAULT (SYSDATETIME()),
        DataValidacao DATETIME2(3) NULL,
        DataCargaFinal DATETIME2(3) NULL,

        CONSTRAINT PK_Stg_ResultadosAnaliseImportacao
            PRIMARY KEY (IdStaging),

        CONSTRAINT FK_Stg_ResultadosAnaliseImportacao_Tbl_LotesImportacao
            FOREIGN KEY (IdLoteImportacao)
            REFERENCES dbo.Tbl_LotesImportacao (IdLoteImportacao),

        CONSTRAINT CK_Stg_ResultadosAnaliseImportacao_NumeroLinha
            CHECK (NumeroLinha > 0),

        CONSTRAINT CK_Stg_ResultadosAnaliseImportacao_StatusValidacao
            CHECK (StatusValidacao IN ('PENDENTE', 'VALIDO', 'INVALIDO', 'CARREGADO'))
    );
END;
GO

/*
    Indice minimo da staging.

    Justificativa: validacao, resumo do lote e carga final filtram
    continuamente por IdLoteImportacao e StatusValidacao.
*/
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Stg_ResultadosAnaliseImportacao')
      AND name = 'IX_Stg_ResultadosAnaliseImportacao_Lote_Status'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Stg_ResultadosAnaliseImportacao_Lote_Status
    ON dbo.Stg_ResultadosAnaliseImportacao
    (
        IdLoteImportacao,
        StatusValidacao
    );
END;
GO

/*
    Procedure: dbo.usp_ValidarStgResultadosAnalise

    Objetivo:
    Validar registros de staging por lote, acumulando mensagens e bloqueando
    carga de linhas inconsistentes.
*/
CREATE OR ALTER PROCEDURE dbo.usp_ValidarStgResultadosAnalise
    @IdLoteImportacao INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdLoteImportacao IS NULL
    BEGIN
        THROW 52001, 'IdLoteImportacao deve ser informado.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Tbl_LotesImportacao AS l
        WHERE l.IdLoteImportacao = @IdLoteImportacao
    )
    BEGIN
        THROW 52002, 'Lote de importacao nao encontrado.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.Tbl_LotesImportacao AS l
        WHERE l.IdLoteImportacao = @IdLoteImportacao
          AND l.StatusLote = 'CANCELADO'
    )
    BEGIN
        THROW 52003, 'Lote cancelado nao pode ser validado.', 1;
    END;

    UPDATE dbo.Stg_ResultadosAnaliseImportacao
    SET
        StatusValidacao = 'PENDENTE',
        MensagemValidacao = NULL,
        DataValidacao = NULL
    WHERE IdLoteImportacao = @IdLoteImportacao
      AND StatusValidacao IN ('PENDENTE', 'VALIDO', 'INVALIDO');

    ;WITH Base AS
    (
        SELECT
            s.IdStaging,
            s.IdLoteImportacao,
            s.CodigoAmostra,
            s.NomeParametro,
            s.ValorResultadoTexto,
            s.DataAnaliseTexto,
            NULLIF(LTRIM(RTRIM(s.CodigoAmostra)), '') AS CodigoAmostraTratado,
            NULLIF(LTRIM(RTRIM(s.NomeParametro)), '') AS NomeParametroTratado,
            NULLIF(LTRIM(RTRIM(s.ValorResultadoTexto)), '') AS ValorResultadoTratado,
            NULLIF(LTRIM(RTRIM(s.DataAnaliseTexto)), '') AS DataAnaliseTratada,
            TRY_CONVERT(DECIMAL(18,4), NULLIF(LTRIM(RTRIM(s.ValorResultadoTexto)), '')) AS ValorResultadoConvertido,
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(s.DataAnaliseTexto)), '')) AS DataAnaliseConvertida
        FROM dbo.Stg_ResultadosAnaliseImportacao AS s
        WHERE s.IdLoteImportacao = @IdLoteImportacao
          AND s.StatusValidacao <> 'CARREGADO'
    ),
    Relacionamentos AS
    (
        SELECT
            b.*,
            a.IdAmostra,
            p.IdParametro
        FROM Base AS b
        LEFT JOIN dbo.Tbl_Amostras AS a
            ON a.CodigoAmostra = b.CodigoAmostraTratado
        LEFT JOIN dbo.Tbl_Parametros AS p
            ON p.NomeParametro = b.NomeParametroTratado
    ),
    Duplicidades AS
    (
        SELECT
            r.*,
            COUNT(*) OVER
            (
                PARTITION BY
                    r.IdLoteImportacao,
                    r.CodigoAmostraTratado,
                    r.NomeParametroTratado
            ) AS TotalDuplicadosLote
        FROM Relacionamentos AS r
    ),
    Validacao AS
    (
        SELECT
            d.IdStaging,
            CONCAT
            (
                CASE WHEN d.CodigoAmostraTratado IS NULL
                    THEN 'CodigoAmostra obrigatorio; ' ELSE '' END,
                CASE WHEN d.NomeParametroTratado IS NULL
                    THEN 'NomeParametro obrigatorio; ' ELSE '' END,
                CASE WHEN d.ValorResultadoTratado IS NULL
                    THEN 'ValorResultadoTexto obrigatorio; ' ELSE '' END,
                CASE WHEN d.ValorResultadoTratado IS NOT NULL
                          AND d.ValorResultadoConvertido IS NULL
                    THEN 'ValorResultadoTexto invalido; ' ELSE '' END,
                CASE WHEN d.ValorResultadoConvertido < 0
                    THEN 'ValorResultadoTexto deve ser maior ou igual a zero; ' ELSE '' END,
                CASE WHEN d.DataAnaliseTratada IS NULL
                    THEN 'DataAnaliseTexto obrigatoria; ' ELSE '' END,
                CASE WHEN d.DataAnaliseTratada IS NOT NULL
                          AND d.DataAnaliseConvertida IS NULL
                    THEN 'DataAnaliseTexto invalida; ' ELSE '' END,
                CASE WHEN d.CodigoAmostraTratado IS NOT NULL
                          AND d.IdAmostra IS NULL
                    THEN 'CodigoAmostra inexistente; ' ELSE '' END,
                CASE WHEN d.NomeParametroTratado IS NOT NULL
                          AND d.IdParametro IS NULL
                    THEN 'NomeParametro inexistente; ' ELSE '' END,
                CASE WHEN d.CodigoAmostraTratado IS NOT NULL
                          AND d.NomeParametroTratado IS NOT NULL
                          AND d.TotalDuplicadosLote > 1
                    THEN 'Combinacao CodigoAmostra + NomeParametro duplicada no lote; ' ELSE '' END,
                CASE WHEN d.IdAmostra IS NOT NULL
                          AND d.IdParametro IS NOT NULL
                          AND EXISTS
                          (
                              SELECT 1
                              FROM dbo.Tbl_ResultadosAnalise AS r
                              WHERE r.IdAmostra = d.IdAmostra
                                AND r.IdParametro = d.IdParametro
                          )
                    THEN 'Combinacao CodigoAmostra + NomeParametro ja existe em Tbl_ResultadosAnalise; '
                    ELSE '' END
            ) AS MensagemErro
        FROM Duplicidades AS d
    )
    UPDATE s
    SET
        StatusValidacao = CASE
            WHEN v.MensagemErro = '' THEN 'VALIDO'
            ELSE 'INVALIDO'
        END,
        MensagemValidacao = NULLIF(LEFT(v.MensagemErro, 1000), ''),
        DataValidacao = SYSDATETIME()
    FROM dbo.Stg_ResultadosAnaliseImportacao AS s
    INNER JOIN Validacao AS v
        ON v.IdStaging = s.IdStaging;

    UPDATE l
    SET
        StatusLote = 'VALIDADO',
        TotalLinhas = x.TotalLinhas,
        TotalValidas = ISNULL(x.TotalValidas, 0),
        TotalInvalidas = ISNULL(x.TotalInvalidas, 0),
        TotalCarregadas = ISNULL(x.TotalCarregadas, 0)
    FROM dbo.Tbl_LotesImportacao AS l
    CROSS APPLY
    (
        SELECT
            COUNT(*) AS TotalLinhas,
            SUM(CASE WHEN s.StatusValidacao = 'VALIDO' THEN 1 ELSE 0 END) AS TotalValidas,
            SUM(CASE WHEN s.StatusValidacao = 'INVALIDO' THEN 1 ELSE 0 END) AS TotalInvalidas,
            SUM(CASE WHEN s.StatusValidacao = 'CARREGADO' THEN 1 ELSE 0 END) AS TotalCarregadas
        FROM dbo.Stg_ResultadosAnaliseImportacao AS s
        WHERE s.IdLoteImportacao = @IdLoteImportacao
    ) AS x
    WHERE l.IdLoteImportacao = @IdLoteImportacao;
END;
GO

/*
    Procedure: dbo.usp_CarregarResultadosAnaliseValidados

    Objetivo:
    Carregar registros VALIDO da staging para Tbl_ResultadosAnalise mediante
    confirmacao explicita e transacao.
*/
CREATE OR ALTER PROCEDURE dbo.usp_CarregarResultadosAnaliseValidados
    @IdLoteImportacao INT,
    @ConfirmarCarga BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @IdLoteImportacao IS NULL
    BEGIN
        THROW 52101, 'IdLoteImportacao deve ser informado.', 1;
    END;

    IF @ConfirmarCarga <> 1
    BEGIN
        THROW 52102, 'Carga final abortada. Informe @ConfirmarCarga = 1 para executar.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Tbl_LotesImportacao AS l
        WHERE l.IdLoteImportacao = @IdLoteImportacao
    )
    BEGIN
        THROW 52103, 'Lote de importacao nao encontrado.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.Tbl_LotesImportacao AS l
        WHERE l.IdLoteImportacao = @IdLoteImportacao
          AND l.StatusLote = 'CANCELADO'
    )
    BEGIN
        THROW 52104, 'Lote cancelado nao pode ser carregado.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.Stg_ResultadosAnaliseImportacao AS s
        WHERE s.IdLoteImportacao = @IdLoteImportacao
          AND s.StatusValidacao = 'INVALIDO'
    )
    BEGIN
        THROW 52105, 'Carga abortada. O lote possui registros INVALIDO.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Stg_ResultadosAnaliseImportacao AS s
        WHERE s.IdLoteImportacao = @IdLoteImportacao
          AND s.StatusValidacao = 'VALIDO'
    )
    BEGIN
        THROW 52106, 'Carga abortada. O lote nao possui registros VALIDO.', 1;
    END;

    BEGIN TRANSACTION;

    DECLARE @MaiorIdResultado INT;
    DECLARE @TotalPrevisto INT;
    DECLARE @TotalInserido INT;

    DECLARE @RegistrosCarga TABLE
    (
        IdStaging INT NOT NULL PRIMARY KEY,
        IdResultado INT NOT NULL,
        IdAmostra INT NOT NULL,
        IdParametro INT NOT NULL,
        ValorResultado DECIMAL(18,4) NOT NULL,
        UnidadeMedida VARCHAR(30) NULL,
        DataAnalise DATE NOT NULL,
        MetodoAnalise VARCHAR(100) NULL,
        Observacao VARCHAR(255) NULL
    );

    SELECT
        @MaiorIdResultado = ISNULL(MAX(r.IdResultado), 0)
    FROM dbo.Tbl_ResultadosAnalise AS r WITH (UPDLOCK, HOLDLOCK);

    INSERT INTO @RegistrosCarga
    (
        IdStaging,
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
        rv.IdStaging,
        @MaiorIdResultado + rv.NumeroSequencial,
        rv.IdAmostra,
        rv.IdParametro,
        rv.ValorResultado,
        rv.UnidadeMedida,
        rv.DataAnalise,
        rv.MetodoAnalise,
        rv.Observacao
    FROM
    (
        SELECT
            s.IdStaging,
            a.IdAmostra,
            p.IdParametro,
            TRY_CONVERT(DECIMAL(18,4), NULLIF(LTRIM(RTRIM(s.ValorResultadoTexto)), '')) AS ValorResultado,
            s.UnidadeMedida,
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(s.DataAnaliseTexto)), '')) AS DataAnalise,
            s.MetodoAnalise,
            s.Observacao,
            ROW_NUMBER() OVER (ORDER BY s.IdStaging) AS NumeroSequencial
        FROM dbo.Stg_ResultadosAnaliseImportacao AS s
        INNER JOIN dbo.Tbl_Amostras AS a
            ON a.CodigoAmostra = NULLIF(LTRIM(RTRIM(s.CodigoAmostra)), '')
        INNER JOIN dbo.Tbl_Parametros AS p
            ON p.NomeParametro = NULLIF(LTRIM(RTRIM(s.NomeParametro)), '')
        WHERE s.IdLoteImportacao = @IdLoteImportacao
          AND s.StatusValidacao = 'VALIDO'
    ) AS rv;

    SELECT
        @TotalPrevisto = COUNT(*)
    FROM @RegistrosCarga;

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
        rc.IdResultado,
        rc.IdAmostra,
        rc.IdParametro,
        rc.ValorResultado,
        rc.UnidadeMedida,
        rc.DataAnalise,
        rc.MetodoAnalise,
        rc.Observacao
    FROM @RegistrosCarga AS rc
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.Tbl_ResultadosAnalise AS r
        WHERE r.IdAmostra = rc.IdAmostra
          AND r.IdParametro = rc.IdParametro
    );

    SET @TotalInserido = @@ROWCOUNT;

    IF @TotalInserido = 0
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 52107, 'Carga abortada. Nenhum registro foi inserido.', 1;
    END;

    IF @TotalInserido <> @TotalPrevisto
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 52108, 'Carga abortada. A quantidade inserida difere dos registros validos previstos.', 1;
    END;

    UPDATE s
    SET
        StatusValidacao = 'CARREGADO',
        DataCargaFinal = SYSDATETIME()
    FROM dbo.Stg_ResultadosAnaliseImportacao AS s
    INNER JOIN @RegistrosCarga AS rc
        ON rc.IdStaging = s.IdStaging;

    UPDATE l
    SET
        StatusLote = 'CARREGADO',
        DataFim = SYSDATETIME(),
        TotalLinhas = x.TotalLinhas,
        TotalValidas = ISNULL(x.TotalValidas, 0),
        TotalInvalidas = ISNULL(x.TotalInvalidas, 0),
        TotalCarregadas = ISNULL(x.TotalCarregadas, 0)
    FROM dbo.Tbl_LotesImportacao AS l
    CROSS APPLY
    (
        SELECT
            COUNT(*) AS TotalLinhas,
            SUM(CASE WHEN s.StatusValidacao = 'VALIDO' THEN 1 ELSE 0 END) AS TotalValidas,
            SUM(CASE WHEN s.StatusValidacao = 'INVALIDO' THEN 1 ELSE 0 END) AS TotalInvalidas,
            SUM(CASE WHEN s.StatusValidacao = 'CARREGADO' THEN 1 ELSE 0 END) AS TotalCarregadas
        FROM dbo.Stg_ResultadosAnaliseImportacao AS s
        WHERE s.IdLoteImportacao = @IdLoteImportacao
    ) AS x
    WHERE l.IdLoteImportacao = @IdLoteImportacao;

    COMMIT TRANSACTION;
END;
GO

/*
    Exemplos opcionais para execucao manual no SSMS.

    Observacao tecnica: na carga didatica oficial da v1.0.0, as 6 amostras
    possuem os 12 parametros ja carregados. Para demonstrar uma linha VALIDO,
    escolha uma combinacao CodigoAmostra + NomeParametro que exista nos
    cadastros, mas ainda nao exista em dbo.Tbl_ResultadosAnalise no banco de
    teste utilizado.

    -- 1. Criar lote.
    INSERT INTO dbo.Tbl_LotesImportacao
    (
        NomeArquivoOrigem,
        Observacao
    )
    VALUES
    (
        'resultado_laboratorio_exemplo_v2.csv',
        'Lote didatico manual para validacao da v2.0.0.'
    );

    DECLARE @IdLoteImportacao INT = SCOPE_IDENTITY();

    -- 2. Inserir linhas brutas na staging.
    INSERT INTO dbo.Stg_ResultadosAnaliseImportacao
    (
        IdLoteImportacao,
        NumeroLinha,
        CodigoAmostra,
        NomeParametro,
        ValorResultadoTexto,
        UnidadeMedida,
        DataAnaliseTexto,
        MetodoAnalise,
        Observacao
    )
    VALUES
        -- Linha candidata a valida: ajuste para combinacao ainda nao carregada.
        (@IdLoteImportacao, 1, 'QA-2026-001', 'pH', '7.3500', NULL, '2026-04-10', 'Metodo externo didatico', 'Exemplo candidato a valido.'),

        -- CodigoAmostra inexistente.
        (@IdLoteImportacao, 2, 'QA-2026-999', 'Turbidez', '3.2000', 'NTU', '2026-04-10', 'Metodo externo didatico', 'Amostra inexistente.'),

        -- NomeParametro inexistente.
        (@IdLoteImportacao, 3, 'QA-2026-001', 'Parametro Inexistente', '1.0000', 'mg/L', '2026-04-10', 'Metodo externo didatico', 'Parametro inexistente.'),

        -- ValorResultadoTexto invalido.
        (@IdLoteImportacao, 4, 'QA-2026-001', 'DQO', 'abc', 'mg/L', '2026-04-10', 'Metodo externo didatico', 'Valor invalido.'),

        -- DataAnaliseTexto invalida.
        (@IdLoteImportacao, 5, 'QA-2026-001', 'DBO', '6.5000', 'mg/L', 'data-invalida', 'Metodo externo didatico', 'Data invalida.'),

        -- Duplicidade no lote.
        (@IdLoteImportacao, 6, 'QA-2026-002', 'Condutividade', '260.0000', 'uS/cm', '2026-04-10', 'Metodo externo didatico', 'Duplicidade 1.'),
        (@IdLoteImportacao, 7, 'QA-2026-002', 'Condutividade', '261.0000', 'uS/cm', '2026-04-10', 'Metodo externo didatico', 'Duplicidade 2.');

    -- 3. Validar lote.
    EXEC dbo.usp_ValidarStgResultadosAnalise
        @IdLoteImportacao = @IdLoteImportacao;

    -- 4. Consultar validos e invalidos.
    SELECT
        IdStaging,
        NumeroLinha,
        CodigoAmostra,
        NomeParametro,
        ValorResultadoTexto,
        DataAnaliseTexto,
        StatusValidacao,
        MensagemValidacao
    FROM dbo.Stg_ResultadosAnaliseImportacao
    WHERE IdLoteImportacao = @IdLoteImportacao
    ORDER BY
        NumeroLinha;

    SELECT
        IdLoteImportacao,
        StatusLote,
        TotalLinhas,
        TotalValidas,
        TotalInvalidas,
        TotalCarregadas
    FROM dbo.Tbl_LotesImportacao
    WHERE IdLoteImportacao = @IdLoteImportacao;

    -- 5. Carga final controlada. Execute somente apos revisar o lote.
    -- EXEC dbo.usp_CarregarResultadosAnaliseValidados
    --     @IdLoteImportacao = @IdLoteImportacao,
    --     @ConfirmarCarga = 1;

    -- 6. Consultas pos-carga.
    SELECT
        StatusValidacao,
        COUNT(*) AS TotalLinhas
    FROM dbo.Stg_ResultadosAnaliseImportacao
    WHERE IdLoteImportacao = @IdLoteImportacao
    GROUP BY
        StatusValidacao;

    SELECT TOP (20)
        IdResultado,
        IdAmostra,
        IdParametro,
        ValorResultado,
        UnidadeMedida,
        DataAnalise,
        MetodoAnalise,
        Observacao
    FROM dbo.Tbl_ResultadosAnalise
    ORDER BY
        IdResultado DESC;
*/

/*
    Validacoes estruturais da migration v2.0.0.
*/
SELECT
    t.name AS NomeTabela,
    t.create_date AS DataCriacao,
    t.modify_date AS DataAlteracao
FROM sys.tables AS t
WHERE t.object_id IN
(
    OBJECT_ID('dbo.Tbl_LotesImportacao'),
    OBJECT_ID('dbo.Stg_ResultadosAnaliseImportacao')
)
ORDER BY
    t.name;
GO

SELECT
    p.name AS NomeProcedure,
    p.type_desc AS TipoObjeto,
    p.create_date AS DataCriacao,
    p.modify_date AS DataAlteracao
FROM sys.procedures AS p
WHERE p.schema_id = SCHEMA_ID('dbo')
  AND p.name IN
  (
      'usp_ValidarStgResultadosAnalise',
      'usp_CarregarResultadosAnaliseValidados'
  )
ORDER BY
    p.name;
GO

SELECT
    OBJECT_NAME(i.object_id) AS NomeTabela,
    i.name AS NomeIndice,
    i.type_desc AS TipoIndice,
    i.is_unique AS EhUnico,
    i.is_disabled AS EstaDesabilitado
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID('dbo.Stg_ResultadosAnaliseImportacao')
  AND i.name = 'IX_Stg_ResultadosAnaliseImportacao_Lote_Status';
GO

SELECT
    OBJECT_NAME(c.parent_object_id) AS NomeTabela,
    c.name AS NomeConstraint,
    c.type_desc AS TipoConstraint,
    c.is_disabled AS EstaDesabilitada
FROM sys.check_constraints AS c
WHERE c.parent_object_id IN
(
    OBJECT_ID('dbo.Tbl_LotesImportacao'),
    OBJECT_ID('dbo.Stg_ResultadosAnaliseImportacao')
)
UNION ALL
SELECT
    OBJECT_NAME(f.parent_object_id) AS NomeTabela,
    f.name AS NomeConstraint,
    f.type_desc AS TipoConstraint,
    f.is_disabled AS EstaDesabilitada
FROM sys.foreign_keys AS f
WHERE f.parent_object_id = OBJECT_ID('dbo.Stg_ResultadosAnaliseImportacao')
ORDER BY
    NomeTabela,
    NomeConstraint;
GO
