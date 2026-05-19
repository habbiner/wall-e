param(
    [Parameter(Mandatory = $true)]
    [string]$Key,
    [string]$Default = ""
)

$envPath = Join-Path $env:CONFIG 'match\.env'

if (-not (Test-Path $envPath)) {
    Write-Output $Default
    exit 0
}

foreach ($line in Get-Content $envPath -Encoding UTF8) {
    if ($line -match '^\s*#' -or $line -match '^\s*$') { continue }
    if ($line -match "^\s*$([regex]::Escape($Key))\s*=\s*(.*)$") {
        $value = $Matches[1].Trim().Trim('"').Trim("'")
        Write-Output $value
        exit 0
    }
}

Write-Output $Default
