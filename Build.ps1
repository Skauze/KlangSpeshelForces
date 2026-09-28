param (
    # Skip the Arma 3 Tools config validation step. It is a pre-pack gate, not
    # a build dependency - use this if you are knowingly shipping a config that
    # BI's own CfgConvert rejects.
    [switch]$SkipValidate,
    [string]$ArmaToolsPath = $env:ARMATOOLS
)

$root = $PSScriptRoot

if (-not $SkipValidate) {
    "`n=== Validating config with Arma 3 Tools (CfgConvert) ==="
    $validateArgs = @{ RepoRoot = $root }
    if ($ArmaToolsPath) { $validateArgs["ArmaToolsPath"] = $ArmaToolsPath }
    & "$root\Tools\Validate.ps1" @validateArgs
    if ($LASTEXITCODE -ne 0) {
        "`nVALIDATION FAILED - skipping pack."
        "Re-run with -SkipValidate to bypass this gate."
        exit 1
    }
    "`n"
}

Invoke-Expression "& '$root\Tools\Builder\buildAddons.ps1'"
