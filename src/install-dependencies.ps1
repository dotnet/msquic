Set-StrictMode -Version 'Latest'
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Root directory of the project.
$RootDir = Split-Path $PSScriptRoot -Parent
$NuGetPath = Join-Path $RootDir "nuget"

# Well-known location for clog packages.
$ClogVersion = "0.2.0"
$ClogDownloadUrl = "https://github.com/microsoft/CLOG/releases/download/v$ClogVersion"
$toolsLocation = "$RootDir\src\msquic\artifacts\dotnet-tools"

function Install-ClogTool {
    param($ToolName)
    New-Item -Path $NuGetPath -ItemType Directory -Force | Out-Null
    $NuGetName = "$ToolName.$ClogVersion.nupkg"
    $NuGetFile = Join-Path $NuGetPath $NuGetName
    try {
        if (!(Test-Path $NuGetFile)) {
            Write-Host "Downloading $ClogDownloadUrl/$NuGetName"
            Invoke-WebRequest -Uri "$ClogDownloadUrl/$NuGetName" -OutFile $NuGetFile
        }
        Write-Host "Installing: $NuGetName"
        dotnet tool update --global --add-source $NuGetPath $ToolName
    } catch {
        if ($FailOnError) {
            Write-Error $_
        }
        $err = $_
        $MessagesAtEnd.Add("$ToolName could not be installed. Building with logs will not work")
        $MessagesAtEnd.Add($err.ToString())
    }
}

Install-ClogTool "Microsoft.Logging.CLOG"
if ($IsWindows) {
    Install-ClogTool "Microsoft.Logging.CLOG2Text.Windows"
} elseif ($IsLinux) {
    Install-ClogTool "Microsoft.Logging.CLOG2Text.Lttng"
}

echo "##vso[task.prependpath]$toolsLocation"
