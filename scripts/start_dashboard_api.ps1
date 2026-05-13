param(
    [string]$Prefix = "http://127.0.0.1:5500/",
    [string]$ServerInstance = ".\SQLEXPRESS",
    [string]$Database = "QualidadeAmbiental",
    [int]$DefaultPageSize = 100
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RootPath = Resolve-Path (Join-Path $PSScriptRoot "..")
$DashboardPath = Join-Path $RootPath "dashboard_qualidade_ambiental.html"

function Write-JsonResponse {
    param(
        [System.Net.HttpListenerResponse]$Response,
        [object]$Data,
        [int]$StatusCode = 200
    )

    $Response.StatusCode = $StatusCode
    $Response.ContentType = "application/json; charset=utf-8"
    $json = $Data | ConvertTo-Json -Depth 8
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $Response.OutputStream.Write($bytes, 0, $bytes.Length)
}

function Write-TextResponse {
    param(
        [System.Net.HttpListenerResponse]$Response,
        [string]$Text,
        [string]$ContentType = "text/plain; charset=utf-8",
        [int]$StatusCode = 200
    )

    $Response.StatusCode = $StatusCode
    $Response.ContentType = $ContentType
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $Response.OutputStream.Write($bytes, 0, $bytes.Length)
}

function Get-QueryValue {
    param(
        [System.Collections.Specialized.NameValueCollection]$Query,
        [string]$Name,
        [string]$Default = ""
    )

    $value = $Query[$Name]
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $Default
    }

    return $value.Trim()
}

function Convert-ToSqlDateOrNull {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    $date = [datetime]::MinValue
    if ([datetime]::TryParse($Value, [ref]$date)) {
        return $date.ToString("yyyy-MM-dd")
    }

    return $null
}

function Test-SqlModule {
    return [bool](Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue)
}

function Invoke-DashboardQuery {
    param(
        [string]$Query,
        [hashtable]$Variables = @{}
    )

    if (-not (Test-SqlModule)) {
        throw "Invoke-Sqlcmd nao esta disponivel. Instale o modulo SqlServer ou execute a API em uma maquina com as ferramentas do SQL Server."
    }

    $parameters = @{
        ServerInstance = $ServerInstance
        Database = $Database
        Query = $Query
    }

    if ($Variables.Count -gt 0) {
        $parameters["Variable"] = $Variables
    }

    if ((Get-Command Invoke-Sqlcmd).Parameters.ContainsKey("TrustServerCertificate")) {
        $parameters["TrustServerCertificate"] = $true
    }

    Invoke-Sqlcmd @parameters
}

function Convert-DataRows {
    param([object[]]$Rows)

    if ($null -eq $Rows) {
        return @()
    }

    return @($Rows | ForEach-Object {
        $record = [ordered]@{}
        if ($_ -is [System.Data.DataRow]) {
            foreach ($column in $_.Table.Columns) {
                $record[$column.ColumnName] = Convert-JsonValue $_[$column.ColumnName]
            }
        }
        else {
            foreach ($property in $_.PSObject.Properties) {
                $record[$property.Name] = Convert-JsonValue $property.Value
            }
        }
        [pscustomobject]$record
    })
}

function Convert-JsonValue {
    param([object]$Value)

    if ($null -eq $Value -or $Value -is [System.DBNull]) {
        return $null
    }

    if ($Value -is [datetime]) {
        return $Value.ToString("yyyy-MM-dd")
    }

    return $Value
}

function Get-StatusPredicate {
    param([string]$Status)

    switch ($Status) {
        "nao-conforme" { return "AND ClassificacaoResultado IN ('Acima do limite maximo', 'Abaixo do limite minimo')" }
        "conforme" { return "AND ClassificacaoResultado = 'Conforme'" }
        "sem-limite" { return "AND ClassificacaoResultado = 'Sem limite de referencia'" }
        default { return "" }
    }
}

function Get-Resultados {
    param([System.Collections.Specialized.NameValueCollection]$Query)

    $page = 1
    [void][int]::TryParse((Get-QueryValue $Query "page" "1"), [ref]$page)
    if ($page -lt 1) { $page = 1 }

    $pageSize = $DefaultPageSize
    [void][int]::TryParse((Get-QueryValue $Query "pageSize" "$DefaultPageSize"), [ref]$pageSize)
    if ($pageSize -lt 1) { $pageSize = $DefaultPageSize }
    if ($pageSize -gt 500) { $pageSize = 500 }

    $offset = ($page - 1) * $pageSize
    $dataInicio = Convert-ToSqlDateOrNull (Get-QueryValue $Query "dataInicio")
    $dataFim = Convert-ToSqlDateOrNull (Get-QueryValue $Query "dataFim")
    $parametro = (Get-QueryValue $Query "parametro").Replace("'", "''")
    $ponto = (Get-QueryValue $Query "ponto").Replace("'", "''")
    $tipoAmostra = (Get-QueryValue $Query "tipoAmostra").Replace("'", "''")
    $status = Get-QueryValue $Query "status"
    $statusPredicate = Get-StatusPredicate $status

    $where = @("1 = 1")
    if ($dataInicio) { $where += "DataColeta >= '$dataInicio'" }
    if ($dataFim) { $where += "DataColeta <= '$dataFim'" }
    if ($parametro) { $where += "NomeParametro = '$parametro'" }
    if ($ponto) { $where += "NomePonto LIKE '%$ponto%'" }
    if ($tipoAmostra) { $where += "NomeTipoAmostra = '$tipoAmostra'" }

    $whereSql = ($where -join " AND ")

    $sql = @"
WITH Base AS
(
    SELECT
        IdResultado,
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
        DataAnalise,
        ValorMinimo,
        ValorMaximo,
        ClassificacaoResultado,
        PossuiLimiteReferencia,
        IndicadorNaoConforme
    FROM dbo.VW_ConformidadeResultados
    WHERE $whereSql
    $statusPredicate
)
SELECT *
FROM Base
ORDER BY DataColeta DESC, IdResultado DESC
OFFSET $offset ROWS FETCH NEXT $pageSize ROWS ONLY;
"@

    $countSql = @"
SELECT COUNT(1) AS Total
FROM dbo.VW_ConformidadeResultados
WHERE $whereSql
$statusPredicate;
"@

    $rows = Convert-DataRows (Invoke-DashboardQuery -Query $sql)
    $totalRow = Invoke-DashboardQuery -Query $countSql
    $total = if ($totalRow) { [int]$totalRow.Total } else { 0 }

    return [pscustomobject]@{
        data = $rows
        page = $page
        pageSize = $pageSize
        total = $total
    }
}

function Get-Kpis {
    $sql = @"
SELECT
    COUNT(1) AS TotalResultados,
    SUM(PossuiLimiteReferencia) AS ResultadosComLimite,
    SUM(CASE WHEN PossuiLimiteReferencia = 0 THEN 1 ELSE 0 END) AS ResultadosSemLimite,
    SUM(CASE WHEN IndicadorNaoConforme = 0 THEN 1 ELSE 0 END) AS ResultadosConformesComLimite,
    SUM(CASE WHEN IndicadorNaoConforme = 1 THEN 1 ELSE 0 END) AS ResultadosNaoConformesComLimite,
    CAST(
        100.0 * SUM(CASE WHEN IndicadorNaoConforme = 0 THEN 1 ELSE 0 END)
        / NULLIF(SUM(PossuiLimiteReferencia), 0)
        AS DECIMAL(6,2)
    ) AS PercentualConformidadeComLimite,
    MAX(DataColeta) AS UltimaDataColeta
FROM dbo.VW_ConformidadeResultados;
"@

    $rows = Convert-DataRows (Invoke-DashboardQuery -Query $sql)
    if (@($rows).Count -eq 0) {
        return [pscustomobject]@{}
    }

    return @($rows)[0]
}

function Get-DistinctValues {
    param(
        [ValidateSet("NomeParametro", "NomePonto")]
        [string]$ColumnName,
        [string]$Alias
    )

    $sql = "SELECT DISTINCT $ColumnName AS $Alias FROM dbo.VW_ConformidadeResultados WHERE $ColumnName IS NOT NULL ORDER BY $ColumnName;"
    return Convert-DataRows (Invoke-DashboardQuery -Query $sql)
}

if (-not (Test-Path $DashboardPath)) {
    throw "Dashboard nao encontrado em $DashboardPath"
}

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($Prefix)
$listener.Start()

Write-Host "Dashboard API ouvindo em $Prefix"
Write-Host "Banco alvo: $ServerInstance / $Database"
Write-Host "Pressione Ctrl+C para encerrar."

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        $path = $request.Url.AbsolutePath.TrimEnd("/")
        if ($path -eq "") { $path = "/" }

        try {
            switch ($path) {
                "/" {
                    $response.Redirect("/dashboard_qualidade_ambiental.html")
                }
                "/dashboard_qualidade_ambiental.html" {
                    $html = Get-Content $DashboardPath -Raw
                    Write-TextResponse -Response $response -Text $html -ContentType "text/html; charset=utf-8"
                }
                "/api/health" {
                    Write-JsonResponse -Response $response -Data ([pscustomobject]@{
                        ok = $true
                        database = $Database
                        serverInstance = $ServerInstance
                        invokeSqlcmdAvailable = Test-SqlModule
                    })
                }
                "/api/resultados" {
                    Write-JsonResponse -Response $response -Data (Get-Resultados -Query $request.QueryString)
                }
                "/api/kpis" {
                    Write-JsonResponse -Response $response -Data (Get-Kpis)
                }
                "/api/parametros" {
                    Write-JsonResponse -Response $response -Data (Get-DistinctValues -ColumnName "NomeParametro" -Alias "NomeParametro")
                }
                "/api/pontos" {
                    Write-JsonResponse -Response $response -Data (Get-DistinctValues -ColumnName "NomePonto" -Alias "NomePonto")
                }
                default {
                    Write-JsonResponse -Response $response -StatusCode 404 -Data ([pscustomobject]@{
                        ok = $false
                        error = "Rota nao encontrada."
                    })
                }
            }
        }
        catch {
            Write-JsonResponse -Response $response -StatusCode 500 -Data ([pscustomobject]@{
                ok = $false
                error = $_.Exception.Message
            })
        }
        finally {
            $response.OutputStream.Close()
        }
    }
}
finally {
    $listener.Stop()
    $listener.Close()
}
