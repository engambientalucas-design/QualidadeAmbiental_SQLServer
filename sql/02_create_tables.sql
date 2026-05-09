/*
    Projeto: QualidadeAmbiental_SQLServer
    Arquivo: 02_create_tables.sql
    Objetivo: criar as tabelas principais, chaves primarias, chaves estrangeiras
              e constraints basicas do banco QualidadeAmbiental.

    Observacoes:
    - Execute este script apos o arquivo 01_create_database.sql.
    - Este script cria somente estrutura de tabelas e relacionamentos.
    - Este script nao insere dados.
    - As tabelas sao criadas apenas se ainda nao existirem.
*/

USE QualidadeAmbiental;
GO

IF OBJECT_ID('dbo.Tbl_Responsaveis', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_Responsaveis
    (
        IdResponsavel INT NOT NULL,
        NomeResponsavel VARCHAR(150) NOT NULL,
        Cargo VARCHAR(100) NULL,
        Email VARCHAR(150) NULL,
        Telefone VARCHAR(30) NULL,

        CONSTRAINT PK_Tbl_Responsaveis
            PRIMARY KEY (IdResponsavel)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_StatusAmostra', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_StatusAmostra
    (
        IdStatus INT NOT NULL,
        NomeStatus VARCHAR(50) NOT NULL,
        Descricao VARCHAR(200) NULL,

        CONSTRAINT PK_Tbl_StatusAmostra
            PRIMARY KEY (IdStatus),

        CONSTRAINT UQ_Tbl_StatusAmostra_NomeStatus
            UNIQUE (NomeStatus)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_TiposAmostra', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_TiposAmostra
    (
        IdTipoAmostra INT NOT NULL,
        NomeTipoAmostra VARCHAR(80) NOT NULL,
        Descricao VARCHAR(200) NULL,

        CONSTRAINT PK_Tbl_TiposAmostra
            PRIMARY KEY (IdTipoAmostra),

        CONSTRAINT UQ_Tbl_TiposAmostra_NomeTipoAmostra
            UNIQUE (NomeTipoAmostra)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_PontosColeta', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_PontosColeta
    (
        IdPontoColeta INT NOT NULL,
        NomePonto VARCHAR(100) NOT NULL,
        TipoPonto VARCHAR(80) NOT NULL,
        Municipio VARCHAR(100) NOT NULL,
        Estado CHAR(2) NOT NULL,
        Latitude DECIMAL(9,6) NULL,
        Longitude DECIMAL(9,6) NULL,
        Observacao VARCHAR(255) NULL,

        CONSTRAINT PK_Tbl_PontosColeta
            PRIMARY KEY (IdPontoColeta),

        CONSTRAINT UQ_Tbl_PontosColeta_NomeMunicipioEstado
            UNIQUE (NomePonto, Municipio, Estado),

        CONSTRAINT CK_Tbl_PontosColeta_Latitude
            CHECK (Latitude IS NULL OR Latitude BETWEEN -90 AND 90),

        CONSTRAINT CK_Tbl_PontosColeta_Longitude
            CHECK (Longitude IS NULL OR Longitude BETWEEN -180 AND 180)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_Parametros', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_Parametros
    (
        IdParametro INT NOT NULL,
        NomeParametro VARCHAR(120) NOT NULL,
        UnidadeMedida VARCHAR(30) NULL,
        Categoria VARCHAR(80) NULL,
        Descricao VARCHAR(255) NULL,
        Ativo BIT NOT NULL
            CONSTRAINT DF_Tbl_Parametros_Ativo DEFAULT (1),

        CONSTRAINT PK_Tbl_Parametros
            PRIMARY KEY (IdParametro),

        CONSTRAINT UQ_Tbl_Parametros_NomeParametro
            UNIQUE (NomeParametro)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_Amostras', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_Amostras
    (
        IdAmostra INT NOT NULL,
        CodigoAmostra VARCHAR(50) NOT NULL,
        IdPontoColeta INT NOT NULL,
        IdTipoAmostra INT NOT NULL,
        IdResponsavel INT NOT NULL,
        IdStatus INT NOT NULL,
        DataColeta DATE NOT NULL,
        HoraColeta TIME(0) NULL,
        Observacao VARCHAR(255) NULL,

        CONSTRAINT PK_Tbl_Amostras
            PRIMARY KEY (IdAmostra),

        CONSTRAINT UQ_Tbl_Amostras_CodigoAmostra
            UNIQUE (CodigoAmostra),

        CONSTRAINT FK_Tbl_Amostras_Tbl_PontosColeta
            FOREIGN KEY (IdPontoColeta)
            REFERENCES dbo.Tbl_PontosColeta (IdPontoColeta),

        CONSTRAINT FK_Tbl_Amostras_Tbl_TiposAmostra
            FOREIGN KEY (IdTipoAmostra)
            REFERENCES dbo.Tbl_TiposAmostra (IdTipoAmostra),

        CONSTRAINT FK_Tbl_Amostras_Tbl_Responsaveis
            FOREIGN KEY (IdResponsavel)
            REFERENCES dbo.Tbl_Responsaveis (IdResponsavel),

        CONSTRAINT FK_Tbl_Amostras_Tbl_StatusAmostra
            FOREIGN KEY (IdStatus)
            REFERENCES dbo.Tbl_StatusAmostra (IdStatus)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_ResultadosAnalise', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_ResultadosAnalise
    (
        IdResultado INT NOT NULL,
        IdAmostra INT NOT NULL,
        IdParametro INT NOT NULL,
        ValorResultado DECIMAL(18,4) NOT NULL,
        UnidadeMedida VARCHAR(30) NULL,
        DataAnalise DATE NOT NULL,
        MetodoAnalise VARCHAR(100) NULL,
        Observacao VARCHAR(255) NULL,

        CONSTRAINT PK_Tbl_ResultadosAnalise
            PRIMARY KEY (IdResultado),

        CONSTRAINT UQ_Tbl_ResultadosAnalise_AmostraParametro
            UNIQUE (IdAmostra, IdParametro),

        CONSTRAINT FK_Tbl_ResultadosAnalise_Tbl_Amostras
            FOREIGN KEY (IdAmostra)
            REFERENCES dbo.Tbl_Amostras (IdAmostra),

        CONSTRAINT FK_Tbl_ResultadosAnalise_Tbl_Parametros
            FOREIGN KEY (IdParametro)
            REFERENCES dbo.Tbl_Parametros (IdParametro)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_LimitesReferencia', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_LimitesReferencia
    (
        IdLimite INT NOT NULL,
        IdParametro INT NOT NULL,
        IdTipoAmostra INT NOT NULL,
        ValorMinimo DECIMAL(18,4) NULL,
        ValorMaximo DECIMAL(18,4) NULL,
        UnidadeMedida VARCHAR(30) NULL,
        ReferenciaNormativa VARCHAR(150) NULL,
        Observacao VARCHAR(255) NULL,

        CONSTRAINT PK_Tbl_LimitesReferencia
            PRIMARY KEY (IdLimite),

        CONSTRAINT UQ_Tbl_LimitesReferencia_ParametroTipoAmostra
            UNIQUE (IdParametro, IdTipoAmostra),

        CONSTRAINT FK_Tbl_LimitesReferencia_Tbl_Parametros
            FOREIGN KEY (IdParametro)
            REFERENCES dbo.Tbl_Parametros (IdParametro),

        CONSTRAINT FK_Tbl_LimitesReferencia_Tbl_TiposAmostra
            FOREIGN KEY (IdTipoAmostra)
            REFERENCES dbo.Tbl_TiposAmostra (IdTipoAmostra),

        CONSTRAINT CK_Tbl_LimitesReferencia_LimiteInformado
            CHECK (ValorMinimo IS NOT NULL OR ValorMaximo IS NOT NULL),

        CONSTRAINT CK_Tbl_LimitesReferencia_MinimoMenorOuIgualMaximo
            CHECK (
                ValorMinimo IS NULL
                OR ValorMaximo IS NULL
                OR ValorMinimo <= ValorMaximo
            )
    );
END;
GO
