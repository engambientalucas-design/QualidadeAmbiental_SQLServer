/*
    Projeto: QualidadeAmbiental_SQLServer
    Arquivo: 2026-05-12_v1.3.0_auditoria_historico.sql
    Objetivo: criar estrutura enxuta de auditoria para registrar alteracoes
              em tabelas criticas do projeto.

    Observacoes:
    - Execute este script apos os scripts oficiais da versao v1.0.0.
    - As migrations v1.1.0 e v1.2.0 sao recomendadas antes desta fase.
    - A auditoria registra INSERT, UPDATE e DELETE executados apos a criacao
      das triggers.
    - A auditoria nao substitui backup, restore ou controle de acesso.
    - Os limites de referencia sao didaticos e nao representam norma real.
*/

USE QualidadeAmbiental;
GO

/*
    Tabela unica de auditoria.

    A estrutura generica evita criar uma tabela historica por entidade e
    permite rastrear alteracoes nas tabelas aprovadas para a v1.3.0.
*/
IF OBJECT_ID('dbo.Tbl_AuditoriaAlteracoes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_AuditoriaAlteracoes
    (
        IdAuditoria BIGINT IDENTITY(1,1) NOT NULL,
        NomeTabela SYSNAME NOT NULL,
        IdRegistroAfetado VARCHAR(100) NOT NULL,
        Operacao VARCHAR(10) NOT NULL,
        DataHoraOperacao DATETIME2(3) NOT NULL
            CONSTRAINT DF_Tbl_AuditoriaAlteracoes_DataHoraOperacao
            DEFAULT (SYSDATETIME()),
        UsuarioSQL SYSNAME NOT NULL
            CONSTRAINT DF_Tbl_AuditoriaAlteracoes_UsuarioSQL
            DEFAULT (SUSER_SNAME()),
        HostName NVARCHAR(128) NULL,
        Aplicacao NVARCHAR(128) NULL,
        ValoresAnteriores NVARCHAR(MAX) NULL,
        ValoresNovos NVARCHAR(MAX) NULL,
        Observacao VARCHAR(255) NULL,

        CONSTRAINT PK_Tbl_AuditoriaAlteracoes
            PRIMARY KEY (IdAuditoria),

        CONSTRAINT CK_Tbl_AuditoriaAlteracoes_Operacao
            CHECK (Operacao IN ('INSERT', 'UPDATE', 'DELETE'))
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Tbl_AuditoriaAlteracoes')
      AND name = 'IX_Tbl_AuditoriaAlteracoes_Tabela_Registro_Data'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Tbl_AuditoriaAlteracoes_Tabela_Registro_Data
    ON dbo.Tbl_AuditoriaAlteracoes
    (
        NomeTabela,
        IdRegistroAfetado,
        DataHoraOperacao
    );
END;
GO

/*
    Trigger: dbo.TRG_Tbl_ResultadosAnalise_Auditoria

    Tabela auditada:
    - dbo.Tbl_ResultadosAnalise

    Motivo:
    Alteracoes em resultados analiticos afetam conformidade, ranking,
    resultados fora do padrao e indicadores finais.
*/
CREATE OR ALTER TRIGGER dbo.TRG_Tbl_ResultadosAnalise_Auditoria
ON dbo.Tbl_ResultadosAnalise
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted)
       AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Tbl_AuditoriaAlteracoes
        (
            NomeTabela,
            IdRegistroAfetado,
            Operacao,
            DataHoraOperacao,
            UsuarioSQL,
            HostName,
            Aplicacao,
            ValoresAnteriores,
            ValoresNovos,
            Observacao
        )
        SELECT
            'Tbl_ResultadosAnalise',
            CONVERT(VARCHAR(100), i.IdResultado),
            'INSERT',
            SYSDATETIME(),
            SUSER_SNAME(),
            HOST_NAME(),
            APP_NAME(),
            NULL,
            (
                SELECT
                    i.IdResultado,
                    i.IdAmostra,
                    i.IdParametro,
                    i.ValorResultado,
                    i.UnidadeMedida,
                    i.DataAnalise,
                    i.MetodoAnalise,
                    i.Observacao
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            'Auditoria automatica v1.3.0.'
        FROM inserted AS i;
    END;

    IF EXISTS (SELECT 1 FROM inserted)
       AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Tbl_AuditoriaAlteracoes
        (
            NomeTabela,
            IdRegistroAfetado,
            Operacao,
            DataHoraOperacao,
            UsuarioSQL,
            HostName,
            Aplicacao,
            ValoresAnteriores,
            ValoresNovos,
            Observacao
        )
        SELECT
            'Tbl_ResultadosAnalise',
            CONVERT(VARCHAR(100), i.IdResultado),
            'UPDATE',
            SYSDATETIME(),
            SUSER_SNAME(),
            HOST_NAME(),
            APP_NAME(),
            (
                SELECT
                    d.IdResultado,
                    d.IdAmostra,
                    d.IdParametro,
                    d.ValorResultado,
                    d.UnidadeMedida,
                    d.DataAnalise,
                    d.MetodoAnalise,
                    d.Observacao
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            (
                SELECT
                    i.IdResultado,
                    i.IdAmostra,
                    i.IdParametro,
                    i.ValorResultado,
                    i.UnidadeMedida,
                    i.DataAnalise,
                    i.MetodoAnalise,
                    i.Observacao
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            'Auditoria automatica v1.3.0.'
        FROM inserted AS i
        INNER JOIN deleted AS d
            ON d.IdResultado = i.IdResultado;
    END;

    IF NOT EXISTS (SELECT 1 FROM inserted)
       AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Tbl_AuditoriaAlteracoes
        (
            NomeTabela,
            IdRegistroAfetado,
            Operacao,
            DataHoraOperacao,
            UsuarioSQL,
            HostName,
            Aplicacao,
            ValoresAnteriores,
            ValoresNovos,
            Observacao
        )
        SELECT
            'Tbl_ResultadosAnalise',
            CONVERT(VARCHAR(100), d.IdResultado),
            'DELETE',
            SYSDATETIME(),
            SUSER_SNAME(),
            HOST_NAME(),
            APP_NAME(),
            (
                SELECT
                    d.IdResultado,
                    d.IdAmostra,
                    d.IdParametro,
                    d.ValorResultado,
                    d.UnidadeMedida,
                    d.DataAnalise,
                    d.MetodoAnalise,
                    d.Observacao
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            NULL,
            'Auditoria automatica v1.3.0.'
        FROM deleted AS d;
    END;
END;
GO

/*
    Trigger: dbo.TRG_Tbl_LimitesReferencia_Auditoria

    Tabela auditada:
    - dbo.Tbl_LimitesReferencia

    Motivo:
    Alteracoes em limites podem reinterpretar resultados ja carregados.
*/
CREATE OR ALTER TRIGGER dbo.TRG_Tbl_LimitesReferencia_Auditoria
ON dbo.Tbl_LimitesReferencia
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted)
       AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Tbl_AuditoriaAlteracoes
        (
            NomeTabela,
            IdRegistroAfetado,
            Operacao,
            DataHoraOperacao,
            UsuarioSQL,
            HostName,
            Aplicacao,
            ValoresAnteriores,
            ValoresNovos,
            Observacao
        )
        SELECT
            'Tbl_LimitesReferencia',
            CONVERT(VARCHAR(100), i.IdLimite),
            'INSERT',
            SYSDATETIME(),
            SUSER_SNAME(),
            HOST_NAME(),
            APP_NAME(),
            NULL,
            (
                SELECT
                    i.IdLimite,
                    i.IdParametro,
                    i.IdTipoAmostra,
                    i.ValorMinimo,
                    i.ValorMaximo,
                    i.UnidadeMedida,
                    i.ReferenciaNormativa,
                    i.Observacao
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            'Auditoria automatica v1.3.0.'
        FROM inserted AS i;
    END;

    IF EXISTS (SELECT 1 FROM inserted)
       AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Tbl_AuditoriaAlteracoes
        (
            NomeTabela,
            IdRegistroAfetado,
            Operacao,
            DataHoraOperacao,
            UsuarioSQL,
            HostName,
            Aplicacao,
            ValoresAnteriores,
            ValoresNovos,
            Observacao
        )
        SELECT
            'Tbl_LimitesReferencia',
            CONVERT(VARCHAR(100), i.IdLimite),
            'UPDATE',
            SYSDATETIME(),
            SUSER_SNAME(),
            HOST_NAME(),
            APP_NAME(),
            (
                SELECT
                    d.IdLimite,
                    d.IdParametro,
                    d.IdTipoAmostra,
                    d.ValorMinimo,
                    d.ValorMaximo,
                    d.UnidadeMedida,
                    d.ReferenciaNormativa,
                    d.Observacao
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            (
                SELECT
                    i.IdLimite,
                    i.IdParametro,
                    i.IdTipoAmostra,
                    i.ValorMinimo,
                    i.ValorMaximo,
                    i.UnidadeMedida,
                    i.ReferenciaNormativa,
                    i.Observacao
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            'Auditoria automatica v1.3.0.'
        FROM inserted AS i
        INNER JOIN deleted AS d
            ON d.IdLimite = i.IdLimite;
    END;

    IF NOT EXISTS (SELECT 1 FROM inserted)
       AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Tbl_AuditoriaAlteracoes
        (
            NomeTabela,
            IdRegistroAfetado,
            Operacao,
            DataHoraOperacao,
            UsuarioSQL,
            HostName,
            Aplicacao,
            ValoresAnteriores,
            ValoresNovos,
            Observacao
        )
        SELECT
            'Tbl_LimitesReferencia',
            CONVERT(VARCHAR(100), d.IdLimite),
            'DELETE',
            SYSDATETIME(),
            SUSER_SNAME(),
            HOST_NAME(),
            APP_NAME(),
            (
                SELECT
                    d.IdLimite,
                    d.IdParametro,
                    d.IdTipoAmostra,
                    d.ValorMinimo,
                    d.ValorMaximo,
                    d.UnidadeMedida,
                    d.ReferenciaNormativa,
                    d.Observacao
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            NULL,
            'Auditoria automatica v1.3.0.'
        FROM deleted AS d;
    END;
END;
GO

/*
    Trigger: dbo.TRG_Tbl_Amostras_Auditoria

    Tabela auditada:
    - dbo.Tbl_Amostras

    Motivo:
    Alteracoes em amostras afetam periodo, ponto de coleta, tipo de amostra
    e matriz de limites aplicada nas views oficiais.
*/
CREATE OR ALTER TRIGGER dbo.TRG_Tbl_Amostras_Auditoria
ON dbo.Tbl_Amostras
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted)
       AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Tbl_AuditoriaAlteracoes
        (
            NomeTabela,
            IdRegistroAfetado,
            Operacao,
            DataHoraOperacao,
            UsuarioSQL,
            HostName,
            Aplicacao,
            ValoresAnteriores,
            ValoresNovos,
            Observacao
        )
        SELECT
            'Tbl_Amostras',
            CONVERT(VARCHAR(100), i.IdAmostra),
            'INSERT',
            SYSDATETIME(),
            SUSER_SNAME(),
            HOST_NAME(),
            APP_NAME(),
            NULL,
            (
                SELECT
                    i.IdAmostra,
                    i.CodigoAmostra,
                    i.IdPontoColeta,
                    i.IdTipoAmostra,
                    i.IdResponsavel,
                    i.IdStatus,
                    i.DataColeta,
                    i.HoraColeta,
                    i.Observacao
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            'Auditoria automatica v1.3.0.'
        FROM inserted AS i;
    END;

    IF EXISTS (SELECT 1 FROM inserted)
       AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Tbl_AuditoriaAlteracoes
        (
            NomeTabela,
            IdRegistroAfetado,
            Operacao,
            DataHoraOperacao,
            UsuarioSQL,
            HostName,
            Aplicacao,
            ValoresAnteriores,
            ValoresNovos,
            Observacao
        )
        SELECT
            'Tbl_Amostras',
            CONVERT(VARCHAR(100), i.IdAmostra),
            'UPDATE',
            SYSDATETIME(),
            SUSER_SNAME(),
            HOST_NAME(),
            APP_NAME(),
            (
                SELECT
                    d.IdAmostra,
                    d.CodigoAmostra,
                    d.IdPontoColeta,
                    d.IdTipoAmostra,
                    d.IdResponsavel,
                    d.IdStatus,
                    d.DataColeta,
                    d.HoraColeta,
                    d.Observacao
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            (
                SELECT
                    i.IdAmostra,
                    i.CodigoAmostra,
                    i.IdPontoColeta,
                    i.IdTipoAmostra,
                    i.IdResponsavel,
                    i.IdStatus,
                    i.DataColeta,
                    i.HoraColeta,
                    i.Observacao
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            'Auditoria automatica v1.3.0.'
        FROM inserted AS i
        INNER JOIN deleted AS d
            ON d.IdAmostra = i.IdAmostra;
    END;

    IF NOT EXISTS (SELECT 1 FROM inserted)
       AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Tbl_AuditoriaAlteracoes
        (
            NomeTabela,
            IdRegistroAfetado,
            Operacao,
            DataHoraOperacao,
            UsuarioSQL,
            HostName,
            Aplicacao,
            ValoresAnteriores,
            ValoresNovos,
            Observacao
        )
        SELECT
            'Tbl_Amostras',
            CONVERT(VARCHAR(100), d.IdAmostra),
            'DELETE',
            SYSDATETIME(),
            SUSER_SNAME(),
            HOST_NAME(),
            APP_NAME(),
            (
                SELECT
                    d.IdAmostra,
                    d.CodigoAmostra,
                    d.IdPontoColeta,
                    d.IdTipoAmostra,
                    d.IdResponsavel,
                    d.IdStatus,
                    d.DataColeta,
                    d.HoraColeta,
                    d.Observacao
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ),
            NULL,
            'Auditoria automatica v1.3.0.'
        FROM deleted AS d;
    END;
END;
GO

/*
    Validacao estrutural da migration v1.3.0.
*/
SELECT
    t.name AS NomeTabela,
    t.create_date AS DataCriacao,
    t.modify_date AS DataAlteracao
FROM sys.tables AS t
WHERE t.object_id = OBJECT_ID('dbo.Tbl_AuditoriaAlteracoes');
GO

SELECT
    tr.name AS NomeTrigger,
    OBJECT_NAME(tr.parent_id) AS TabelaAuditada,
    tr.is_disabled AS EstaDesabilitada,
    tr.create_date AS DataCriacao,
    tr.modify_date AS DataAlteracao
FROM sys.triggers AS tr
WHERE tr.name IN
(
    'TRG_Tbl_ResultadosAnalise_Auditoria',
    'TRG_Tbl_LimitesReferencia_Auditoria',
    'TRG_Tbl_Amostras_Auditoria'
)
ORDER BY
    TabelaAuditada,
    NomeTrigger;
GO

/*
    Exemplos para execucao manual no SSMS.

    Execute um exemplo por vez apos a migration, conforme a evidencia visual
    que sera capturada. Os exemplos permanecem comentados para separar a criacao
    dos objetos dos testes de auditoria.

    Na validacao inicial da v1.3.0, teste apenas UPDATEs controlados.
    Nao teste DELETE nesta primeira validacao, para nao comprometer os dados
    didaticos nem os indicadores finais do projeto.

    Antes de cada UPDATE, consulte o valor original de Observacao.
    A reversao deve usar o valor original observado antes do teste, e nao um
    valor fixo escrito no script.

    -- Exemplo 1: UPDATE controlado em resultado analitico.

    -- 1. Visualizar valor original antes do teste.
    SELECT
        IdResultado,
        Observacao
    FROM dbo.Tbl_ResultadosAnalise
    WHERE IdResultado = 1;

    -- 2. Executar UPDATE controlado.
    UPDATE dbo.Tbl_ResultadosAnalise
    SET Observacao = CONCAT(ISNULL(Observacao, ''), ' Auditoria v1.3.0.')
    WHERE IdResultado = 1;

    -- 3. Conferir registro de auditoria gerado.
    SELECT TOP (10)
        IdAuditoria,
        NomeTabela,
        IdRegistroAfetado,
        Operacao,
        DataHoraOperacao,
        UsuarioSQL,
        HostName,
        Aplicacao,
        ValoresAnteriores,
        ValoresNovos
    FROM dbo.Tbl_AuditoriaAlteracoes
    ORDER BY
        IdAuditoria DESC;

    -- 4. Reverter manualmente usando o valor original observado no passo 1.
    -- Exemplo:
    -- UPDATE dbo.Tbl_ResultadosAnalise
    -- SET Observacao = '<valor original observado>'
    -- WHERE IdResultado = 1;

    -- Exemplo 2: UPDATE controlado em limite de referencia.

    -- 1. Visualizar valor original antes do teste.
    SELECT
        IdLimite,
        Observacao
    FROM dbo.Tbl_LimitesReferencia
    WHERE IdLimite = 1;

    -- 2. Executar UPDATE controlado.
    UPDATE dbo.Tbl_LimitesReferencia
    SET Observacao = 'Teste controlado de auditoria v1.3.0.'
    WHERE IdLimite = 1;

    -- 3. Conferir registro de auditoria gerado.
    SELECT TOP (10)
        IdAuditoria,
        NomeTabela,
        IdRegistroAfetado,
        Operacao,
        DataHoraOperacao,
        UsuarioSQL,
        HostName,
        Aplicacao,
        ValoresAnteriores,
        ValoresNovos
    FROM dbo.Tbl_AuditoriaAlteracoes
    ORDER BY
        IdAuditoria DESC;

    -- 4. Reverter manualmente usando o valor original observado no passo 1.
    -- Exemplo:
    -- UPDATE dbo.Tbl_LimitesReferencia
    -- SET Observacao = '<valor original observado>'
    -- WHERE IdLimite = 1;

    -- Exemplo 3: UPDATE controlado em amostra.

    -- 1. Visualizar valor original antes do teste.
    SELECT
        IdAmostra,
        Observacao
    FROM dbo.Tbl_Amostras
    WHERE IdAmostra = 1;

    -- 2. Executar UPDATE controlado.
    UPDATE dbo.Tbl_Amostras
    SET Observacao = 'Teste controlado de auditoria v1.3.0.'
    WHERE IdAmostra = 1;

    -- 3. Conferir registro de auditoria gerado.
    SELECT TOP (10)
        IdAuditoria,
        NomeTabela,
        IdRegistroAfetado,
        Operacao,
        DataHoraOperacao,
        UsuarioSQL,
        HostName,
        Aplicacao,
        ValoresAnteriores,
        ValoresNovos
    FROM dbo.Tbl_AuditoriaAlteracoes
    ORDER BY
        IdAuditoria DESC;

    -- 4. Reverter manualmente usando o valor original observado no passo 1.
    -- Exemplo:
    -- UPDATE dbo.Tbl_Amostras
    -- SET Observacao = '<valor original observado>'
    -- WHERE IdAmostra = 1;
*/
