/*
    Projeto: QualidadeAmbiental_SQLServer
    Arquivo: 01_create_database.sql
    Objetivo: criar o banco de dados QualidadeAmbiental, caso ele ainda nao exista.

    Observacoes:
    - Este script deve ser executado no SQL Server Management Studio antes dos demais scripts.
    - O contexto inicial master e usado por padrao para comandos de criacao de banco.
    - A verificacao com DB_ID evita erro caso o banco ja tenha sido criado anteriormente.
    - Este arquivo nao cria tabelas, relacionamentos ou dados. Esses objetos ficam nos proximos scripts.
*/

USE master;
GO

IF DB_ID('QualidadeAmbiental') IS NULL
BEGIN
    CREATE DATABASE QualidadeAmbiental;
    PRINT 'Banco de dados QualidadeAmbiental criado com sucesso.';
END
ELSE
BEGIN
    PRINT 'Banco de dados QualidadeAmbiental ja existe. Nenhuma acao foi executada.';
END;
GO

USE QualidadeAmbiental;
GO
