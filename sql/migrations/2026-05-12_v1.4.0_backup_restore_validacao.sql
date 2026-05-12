/*
    Projeto: QualidadeAmbiental_SQLServer
    Arquivo: 2026-05-12_v1.4.0_backup_restore_validacao.sql
    Objetivo: criar roteiro operacional para backup completo, verificacao do
              backup, inspecao dos arquivos logicos, restore seguro em banco
              separado e validacao pos-recuperacao.

    Aviso de seguranca:
    - Este script NAO deve restaurar sobre o banco principal.
    - Banco origem: QualidadeAmbiental.
    - Banco destino: QualidadeAmbiental_RestoreTeste.
    - O arquivo .bak deve ficar fora do repositorio Git/GitHub.
    - O caminho do backup deve existir antes da execucao.
    - A pasta precisa ser acessivel pela conta do servico SQL Server.
    - O bloco RESTORE DATABASE esta comentado por padrao e deve ser ajustado
      manualmente apos conferir RESTORE FILELISTONLY.

    Caminho sugerido para backup:
    C:\SQLBackups\QualidadeAmbiental\
*/

USE master;
GO

SET NOCOUNT ON;
GO

DECLARE
    @BancoOrigem SYSNAME = N'QualidadeAmbiental',
    @BancoDestino SYSNAME = N'QualidadeAmbiental_RestoreTeste',
    @DiretorioBackup NVARCHAR(260) = N'C:\SQLBackups\QualidadeAmbiental\',
    @ArquivoBackup NVARCHAR(4000),
    @Comando NVARCHAR(MAX);

SET @ArquivoBackup =
    @DiretorioBackup
    + @BancoOrigem
    + N'_v1_4_0_full_'
    + CONVERT(CHAR(8), GETDATE(), 112)
    + N'.bak';

PRINT 'Banco origem: ' + @BancoOrigem;
PRINT 'Banco destino planejado: ' + @BancoDestino;
PRINT 'Arquivo de backup planejado: ' + @ArquivoBackup;
PRINT 'Verifique antes da execucao se a pasta existe e se a conta do servico SQL Server possui permissao.';
GO

/*
    Verificacoes iniciais.

    Observacao:
    - Este script nao tenta criar a pasta de backup via T-SQL.
    - Crie a pasta manualmente, se necessario.
    - Evita-se xp_cmdshell e qualquer dependencia operacional desnecessaria.
*/
DECLARE
    @BancoOrigem SYSNAME = N'QualidadeAmbiental',
    @BancoDestino SYSNAME = N'QualidadeAmbiental_RestoreTeste';

IF DB_ID(@BancoOrigem) IS NULL
BEGIN
    THROW 51401, 'Banco origem QualidadeAmbiental nao existe. Execute os scripts oficiais antes do backup.', 1;
END;

IF DB_ID(@BancoDestino) IS NOT NULL
BEGIN
    PRINT 'Aviso: o banco QualidadeAmbiental_RestoreTeste ja existe.';
    PRINT 'Nenhuma remocao automatica sera executada. Revise manualmente antes de restaurar novamente.';
END
ELSE
BEGIN
    PRINT 'Banco destino QualidadeAmbiental_RestoreTeste ainda nao existe. Isso e esperado antes do restore.';
END;
GO

/*
    Backup completo do banco principal.

    Ajuste @DiretorioBackup antes da execucao, se o caminho sugerido nao existir
    ou se a conta do servico SQL Server nao tiver permissao nessa pasta.
*/
DECLARE
    @BancoOrigem SYSNAME = N'QualidadeAmbiental',
    @DiretorioBackup NVARCHAR(260) = N'C:\SQLBackups\QualidadeAmbiental\',
    @ArquivoBackup NVARCHAR(4000),
    @Comando NVARCHAR(MAX);

SET @ArquivoBackup =
    @DiretorioBackup
    + @BancoOrigem
    + N'_v1_4_0_full_'
    + CONVERT(CHAR(8), GETDATE(), 112)
    + N'.bak';

SET @Comando = N'
BACKUP DATABASE ' + QUOTENAME(@BancoOrigem) + N'
TO DISK = N''' + REPLACE(@ArquivoBackup, '''', '''''') + N'''
WITH
    INIT,
    CHECKSUM,
    STATS = 10;
';

PRINT 'Iniciando backup completo...';
EXEC sys.sp_executesql @Comando;
PRINT 'Backup completo finalizado.';
GO

/*
    Validacao do arquivo de backup.

    RESTORE VERIFYONLY valida se o backup pode ser lido pelo SQL Server.
    Isso nao substitui o teste real de restore.
*/
DECLARE
    @BancoOrigem SYSNAME = N'QualidadeAmbiental',
    @DiretorioBackup NVARCHAR(260) = N'C:\SQLBackups\QualidadeAmbiental\',
    @ArquivoBackup NVARCHAR(4000),
    @Comando NVARCHAR(MAX);

SET @ArquivoBackup =
    @DiretorioBackup
    + @BancoOrigem
    + N'_v1_4_0_full_'
    + CONVERT(CHAR(8), GETDATE(), 112)
    + N'.bak';

SET @Comando = N'
RESTORE VERIFYONLY
FROM DISK = N''' + REPLACE(@ArquivoBackup, '''', '''''') + N'''
WITH CHECKSUM;
';

PRINT 'Iniciando RESTORE VERIFYONLY...';
EXEC sys.sp_executesql @Comando;
PRINT 'RESTORE VERIFYONLY finalizado.';
GO

/*
    Inspecao dos arquivos logicos do backup.

    Use a saida de RESTORE FILELISTONLY para conferir os LogicalName antes de
    descomentar o RESTORE DATABASE.
*/
DECLARE
    @BancoOrigem SYSNAME = N'QualidadeAmbiental',
    @DiretorioBackup NVARCHAR(260) = N'C:\SQLBackups\QualidadeAmbiental\',
    @ArquivoBackup NVARCHAR(4000),
    @Comando NVARCHAR(MAX);

SET @ArquivoBackup =
    @DiretorioBackup
    + @BancoOrigem
    + N'_v1_4_0_full_'
    + CONVERT(CHAR(8), GETDATE(), 112)
    + N'.bak';

SET @Comando = N'
RESTORE FILELISTONLY
FROM DISK = N''' + REPLACE(@ArquivoBackup, '''', '''''') + N''';
';

PRINT 'Listando arquivos logicos do backup...';
EXEC sys.sp_executesql @Comando;
GO

/*
    Preparacao do restore.

    Se o banco QualidadeAmbiental_RestoreTeste ja existir, remova manualmente
    somente se voce tiver certeza de que ele pode ser descartado.

    Os comandos abaixo ficam comentados por seguranca.

    -- ATENCAO: trecho destrutivo. Nao executar sem revisao manual.
    -- USE master;
    -- ALTER DATABASE QualidadeAmbiental_RestoreTeste SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    -- DROP DATABASE QualidadeAmbiental_RestoreTeste;
*/

/*
    Restore em banco separado.

    Este bloco fica comentado por padrao porque depende de:
    - LogicalName retornado por RESTORE FILELISTONLY;
    - caminhos fisicos validos para MDF e LDF;
    - permissao da conta do servico SQL Server nas pastas de destino.

    Passos recomendados:
    1. Execute BACKUP DATABASE.
    2. Execute RESTORE VERIFYONLY.
    3. Execute RESTORE FILELISTONLY.
    4. Copie os LogicalName retornados para os campos MOVE abaixo.
    5. Ajuste os caminhos fisicos do MDF e LDF do banco restaurado.
    6. Descomente somente o bloco RESTORE DATABASE.

    Nao usar WITH REPLACE por padrao.
    Nao sobrescrever arquivos fisicos do banco principal.

    -- DECLARE
    --     @ArquivoBackup NVARCHAR(4000) = N'C:\SQLBackups\QualidadeAmbiental\QualidadeAmbiental_v1_4_0_full_20260512.bak';

    -- RESTORE DATABASE QualidadeAmbiental_RestoreTeste
    -- FROM DISK = @ArquivoBackup
    -- WITH
    --     MOVE N'QualidadeAmbiental' TO N'C:\SQLBackups\QualidadeAmbiental\RestoreTeste\QualidadeAmbiental_RestoreTeste.mdf',
    --     MOVE N'QualidadeAmbiental_log' TO N'C:\SQLBackups\QualidadeAmbiental\RestoreTeste\QualidadeAmbiental_RestoreTeste_log.ldf',
    --     CHECKSUM,
    --     STATS = 10;

    -- WITH REPLACE deve permanecer desativado por padrao.
    -- Use WITH REPLACE somente se souber exatamente qual banco/arquivo sera substituido.
*/

/*
    Validacoes pos-restore.

    As validacoes abaixo ficam ativas, mas primeiro verificam se o banco destino
    existe. Se QualidadeAmbiental_RestoreTeste ainda nao tiver sido restaurado,
    o script exibe uma mensagem orientativa e nao consulta objetos internos.
*/
DECLARE
    @BancoDestino SYSNAME = N'QualidadeAmbiental_RestoreTeste',
    @Comando NVARCHAR(MAX);

IF DB_ID(@BancoDestino) IS NULL
BEGIN
    PRINT 'Banco QualidadeAmbiental_RestoreTeste ainda nao existe.';
    PRINT 'Execute o restore manual comentado no script antes das validacoes pos-restore.';
END
ELSE
BEGIN
    PRINT 'Banco restaurado encontrado. Iniciando validacoes pos-restore.';

    SELECT
        name AS NomeBanco,
        create_date AS DataCriacao,
        state_desc AS EstadoBanco
    FROM sys.databases
    WHERE name = @BancoDestino;

    SET @Comando = N'
    USE ' + QUOTENAME(@BancoDestino) + N';

    SELECT
        ''Tabelas principais'' AS GrupoValidacao,
        v.NomeTabela,
        CASE WHEN t.object_id IS NULL THEN ''Ausente'' ELSE ''OK'' END AS Situacao
    FROM
    (
        VALUES
            (''Tbl_Responsaveis''),
            (''Tbl_StatusAmostra''),
            (''Tbl_TiposAmostra''),
            (''Tbl_PontosColeta''),
            (''Tbl_Parametros''),
            (''Tbl_Amostras''),
            (''Tbl_ResultadosAnalise''),
            (''Tbl_LimitesReferencia'')
    ) AS v(NomeTabela)
    LEFT JOIN sys.tables AS t
        ON t.name = v.NomeTabela
    ORDER BY
        v.NomeTabela;

    SELECT
        ''Views oficiais'' AS GrupoValidacao,
        v.NomeView,
        CASE WHEN vw.object_id IS NULL THEN ''Ausente'' ELSE ''OK'' END AS Situacao
    FROM
    (
        VALUES
            (''VW_ConformidadeResultados''),
            (''VW_ResultadosForaDoPadrao''),
            (''VW_ResultadosSemLimiteReferencia''),
            (''VW_ConformidadeMensal''),
            (''VW_RankingParametrosCriticos''),
            (''VW_EficienciaRemocaoETE'')
    ) AS v(NomeView)
    LEFT JOIN sys.views AS vw
        ON vw.name = v.NomeView
    ORDER BY
        v.NomeView;

    SELECT
        ''Procedures v1.2.0'' AS GrupoValidacao,
        v.NomeProcedure,
        CASE WHEN p.object_id IS NULL THEN ''Ausente'' ELSE ''OK'' END AS Situacao
    FROM
    (
        VALUES
            (''usp_ConformidadePorPeriodo''),
            (''usp_ResultadosForaPadrao''),
            (''usp_RankingParametrosCriticos'')
    ) AS v(NomeProcedure)
    LEFT JOIN sys.procedures AS p
        ON p.name = v.NomeProcedure
    ORDER BY
        v.NomeProcedure;

    SELECT
        ''Auditoria v1.3.0'' AS GrupoValidacao,
        ''Tbl_AuditoriaAlteracoes'' AS NomeObjeto,
        CASE WHEN OBJECT_ID(''dbo.Tbl_AuditoriaAlteracoes'', ''U'') IS NULL THEN ''Ausente'' ELSE ''OK'' END AS Situacao;

    SELECT
        ''Triggers auditoria v1.3.0'' AS GrupoValidacao,
        v.NomeTrigger,
        CASE
            WHEN tr.object_id IS NULL THEN ''Ausente''
            WHEN tr.is_disabled = 1 THEN ''Desabilitada''
            ELSE ''OK''
        END AS Situacao
    FROM
    (
        VALUES
            (''TRG_Tbl_ResultadosAnalise_Auditoria''),
            (''TRG_Tbl_LimitesReferencia_Auditoria''),
            (''TRG_Tbl_Amostras_Auditoria'')
    ) AS v(NomeTrigger)
    LEFT JOIN sys.triggers AS tr
        ON tr.name = v.NomeTrigger
    ORDER BY
        v.NomeTrigger;

    SELECT
        ''Indices v1.1.0'' AS GrupoValidacao,
        v.NomeIndice,
        CASE
            WHEN i.object_id IS NULL THEN ''Ausente''
            WHEN i.is_disabled = 1 THEN ''Desabilitado''
            ELSE ''OK''
        END AS Situacao
    FROM
    (
        VALUES
            (''IX_Tbl_Amostras_DataColeta_Tipo_Ponto''),
            (''IX_Tbl_ResultadosAnalise_Parametro_Amostra'')
    ) AS v(NomeIndice)
    LEFT JOIN sys.indexes AS i
        ON i.name = v.NomeIndice
    ORDER BY
        v.NomeIndice;

    SELECT
        ''Indicadores pos-restore'' AS GrupoValidacao,
        COUNT(*) AS TotalResultadosAnaliticos,
        SUM(PossuiLimiteReferencia) AS ResultadosComLimite,
        SUM(CASE WHEN PossuiLimiteReferencia = 0 THEN 1 ELSE 0 END) AS ResultadosSemLimite,
        SUM(CASE WHEN IndicadorNaoConforme = 0 THEN 1 ELSE 0 END) AS ConformesComLimite,
        SUM(CASE WHEN IndicadorNaoConforme = 1 THEN 1 ELSE 0 END) AS NaoConformesComLimite,
        CASE
            WHEN COUNT(*) = 72
             AND SUM(PossuiLimiteReferencia) = 57
             AND SUM(CASE WHEN PossuiLimiteReferencia = 0 THEN 1 ELSE 0 END) = 15
             AND SUM(CASE WHEN IndicadorNaoConforme = 0 THEN 1 ELSE 0 END) = 50
             AND SUM(CASE WHEN IndicadorNaoConforme = 1 THEN 1 ELSE 0 END) = 7
            THEN ''OK''
            ELSE ''DIVERGENTE''
        END AS Situacao
    FROM dbo.VW_ConformidadeResultados;
    ';

    EXEC sys.sp_executesql @Comando;
END;
GO

/*
    Evidencias visuais esperadas para a v1.4.0:

    1. Backup executado com sucesso.
    2. RESTORE VERIFYONLY executado com sucesso.
    3. RESTORE FILELISTONLY exibindo LogicalName dos arquivos.
    4. RESTORE DATABASE executado manualmente apos ajustes.
    5. Banco QualidadeAmbiental_RestoreTeste visivel no SSMS.
    6. Tabelas principais restauradas.
    7. Views oficiais restauradas.
    8. Procedures v1.2.0 restauradas.
    9. Indices v1.1.0 restaurados.
    10. Tabela e triggers de auditoria v1.3.0 restauradas.
    11. Indicadores pos-restore confirmando 72 / 57 / 15 / 50 / 7.
*/
