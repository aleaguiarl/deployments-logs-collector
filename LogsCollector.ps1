<#
.SYNOPSIS
    Script para coletar logs dos pods de um deployment no Kubernetes.

.DESCRIPTION
    Este script coleta logs dos pods associados a um deployment específico em um cluster Kubernetes. 
    Os logs podem ser filtrados por duração e armazenados em diretórios organizados por contexto, 
    namespace e caso (opcional). O contexto do Kubernetes é obrigatório e deve ser especificado 
    como parâmetro.

.PARAMETER Deployment
    Nome do deployment para o qual os logs serão coletados.

.PARAMETER Since
    Período de tempo para os logs, por exemplo, '24h' ou '15m'.

.PARAMETER Namespace
    Namespace onde o deployment está localizado.

.PARAMETER Context
    Contexto do Kubernetes a ser usado. Caso o valor 'aws' seja fornecido, o script utilizará o 
    contexto AWS configurado internamente.

.PARAMETER Case
    Nome do estudo de caso para organizar os logs em um diretório específico (opcional). 
    Se não fornecido, os logs serão armazenados em um diretório padrão baseado no deployment e na data.

.EXAMPLE
    .\LogsCollector.ps1 -dp meu-deployment -s 12h -ns prod -ctx aws
    Coleta logs dos pods do deployment 'meu-deployment' no namespace 'prod', utilizando o 
    contexto AWS configurado internamente, com logs dos últimos 12 horas.

.EXAMPLE
    .\LogsCollector.ps1 -dp app-api -s 1h -ns dev -ctx gke -cs ApiLogs
    Coleta logs dos pods do deployment 'app-api' no namespace 'dev', utilizando o contexto 'gke',
    com logs da última 1 hora e os organiza em uma pasta '[DEV]ApiLogs'.
#>

param(
    [Parameter(Mandatory=$true)]
    [Alias("dp")]
    [string]$Deployment,

    [Parameter(Mandatory=$true)]
    [Alias("s")]
    [string]$Since,

    [Parameter(Mandatory=$true)]
    [Alias("ns")]
    [string]$Namespace,

    [Parameter(Mandatory=$true)]
    [Alias("ctx")]
    [string]$Context,

    # Creates a folder with the name of the study-case to places the logs inside. If no study-case name is provided, the logs will be placed in the current folder.
    [Parameter(Mandatory=$false)]
    [Alias("cs")]
    [string]$Case
)

Write-Host "
+=============================================================+
| _                     ____      _ _           _             |
|| |    ___   __ _ ___ / ___|___ | | | ___  ___| |_ ___  _ __ |
|| |   / _ \ / _` / __| |   / _ \| | |/ _ \/ __| __/ _ \| '__||
|| |__| (_) | (_| \__ | |__| (_) | | |  __| (__| || (_) | |   |
||_____\___/ \__, |___/\____\___/|_|_|\___|\___|\__\___/|_|   |
|            |___/                                            |
+=============================================================+
"

$AwsContext = "arn:aws:eks:sa-east-1:381492245517:cluster/prd-sgiot"

$Today = Get-Date -Format "yyyy-MM-dd"
$TodayTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

if ($Context -eq "aws") {
    $Pods = kubectl get pods -n $Namespace --context=$AwsContext -l app=$Deployment -o jsonpath="{.items[*].metadata.name}"
} else {
    $Pods = kubectl get pods -n $Namespace --context=$Context -l app=$Deployment -o jsonpath="{.items[*].metadata.name}"
}

if (-not $Pods) {
    Write-Host "No pods found for deployment '$Deployment' in namespace '$Namespace'."
    exit 1
}

if (-not $Case) {
    $LogDir = ".\logs_${Deployment}_${Today}"
} elseif ($Context -eq "aws"){
    $LogDir = ".\[SGIOT AWS]${Case}\logs_${Deployment}_${Today}"
} else {
    $NamespaceUpper = $Namespace.ToUpper()
    $LogDir = ".\[${NamespaceUpper}]${Case}\logs_${Deployment}_${Today}"
}

if (-not (Test-Path -LiteralPath $LogDir)) {
    Write-Host "Directory does not exist. Creating..."
    New-Item -ItemType Directory -Path $LogDir | Out-Null
    Write-Host "Directory created at: $LogDir"
} else {
    Write-Host "Directory already exists at: $LogDir"
}

foreach ($Pod in $Pods.Split(" ")) {
    $LogFile = "$LogDir\$Pod-$TodayTime.log"
    Write-Host "------------------------------------------------------------" -ForegroundColor Blue
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")]Collecting logs for pod '$Pod'..."
    if ($Context -eq "aws") {
        kubectl logs $Pod -n $Namespace --since=$Since > "$LogDir\[SGIOT AWS]$Pod-$TodayTime.log"
    } else {
        kubectl logs $Pod -n $Namespace --context=$Context --since=$Since > "$LogDir\[${NamespaceUpper}]$Pod-$TodayTime.log"
    }
    
    Write-Host "Logs saved to $LogFile"
}

Write-Host "------------------------------------------------------------" -ForegroundColor Blue
Write-Host "All logs collected in $LogDir"
