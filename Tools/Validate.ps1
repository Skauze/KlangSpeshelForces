<#
    Official Arma 3 Tools validation for the KSF addon.

    The addon is built with the bundled HEMTT, which is enough to pack a PBO
    but is a third-party toolchain. This step runs the config through BI's own
    CfgConvert so config errors (bad includes, macro expansion, unbalanced
    braces) surface independently of HEMTT.

    Two things worth knowing, both learned the hard way:

    1. CfgConvert REQUIRES the -dst flag. Without it the exe exits 0 and
       writes a well-formed but EMPTY config.bin (26 bytes), which looks
       like success. Every conversion here is therefore round-tripped back
       to text and checked for expected content, so a silent no-op is a
       failure rather than a false pass.

    2. CfgConvert resolves \x\foo as "x\foo" relative to the current
       directory. To validate an addon that is not installed into the game
       we stage a temp tree containing an "x" folder holding the addon, plus
       a copy of the addon root so relative #includes resolve.

    Nothing here is required to build. If Arma 3 Tools is not installed the
    step SKIPs cleanly, unless -Strict is passed.
#>
param (
    [string]$ArmaToolsPath = $env:ARMATOOLS,
    [switch]$Strict,
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

function Find-ArmaTools {
    $candidates = @(
        $ArmaToolsPath,
        $env:ARMATOOLS,
        "C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools",
        "C:\Program Files\Steam\steamapps\common\Arma 3 Tools",
        "C:\Program Files\Arma 3 Tools",
        "C:\Program Files (x86)\Bohemia Interactive\Arma 3 Tools"
    )
    foreach ($c in $candidates) {
        if ($c -and (Test-Path (Join-Path $c "CfgConvert\CfgConvert.exe"))) {
            return $c
        }
    }
    return $null
}

$tools = Find-ArmaTools
if (-not $tools) {
    "VALIDATE: SKIP - Arma 3 Tools not found (set `$env:ARMATOOLS to enable)."
    if ($Strict) { exit 1 }
    exit 0
}

$cfgConvert = Join-Path $tools "CfgConvert\CfgConvert.exe"
"Arma 3 Tools: $tools"

# Addon folder => strings that must survive the round-trip. This is what
# turns "CfgConvert exited 0" into an actual assertion.
$expect = @{
    "templates" = @("class KSF: Vanilla_Base", "a3a_ksf_core", "KSF_Reb", "Templates\Factions")
    "core"      = @("class a3a_ksf_core", "A3A_core")
}

$failures = @()
$addons = Get-ChildItem (Join-Path $RepoRoot "a3a_ksf\addons") -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName "config.cpp") }

foreach ($addon in $addons) {
    "`nVALIDATE: $($addon.Name)"

    $stage = Join-Path ([System.IO.Path]::GetTempPath()) "ksf_validate_$($addon.Name)_$PID"
    if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }

    $pushed = $false
    try {
        # Mirror for \x\a3a_ksf\... includes.
        New-Item -Path (Join-Path $stage "x") -ItemType Directory -Force > $null
        Copy-Item (Join-Path $RepoRoot "a3a_ksf") (Join-Path $stage "x\a3a_ksf") -Recurse
        # Addon root, recursively, so config.cpp and its relative includes resolve.
        Copy-Item (Join-Path $addon.FullName "*") $stage -Recurse

        $bin = Join-Path $stage "config.bin"
        $txt = Join-Path $stage "config_roundtrip.txt"
        Remove-Item $bin, $txt -ErrorAction SilentlyContinue

        # CfgConvert resolves \x\... relative to the current directory, so the
        # conversion has to run from inside the staged tree.
        Push-Location $stage
        $pushed = $true

        $out = & $cfgConvert -bin -dst $bin "config.cpp" 2>&1
        $code = $LASTEXITCODE
        $out | ForEach-Object { "  cfgConvert: $_" }
        "  exit=$code"

        if (-not (Test-Path $bin)) {
            $failures += "$($addon.Name): CfgConvert produced no config.bin"
            continue
        }

        $size = (Get-Item $bin).Length
        "  config.bin: $size bytes"
        # An empty config.bin is 26 bytes. At or below that means the
        # conversion silently did nothing, which must not read as success.
        if ($size -le 26) {
            $failures += "$($addon.Name): config.bin is empty ($size bytes) - conversion silently no-op'd"
            continue
        }

        & $cfgConvert -txt -dst $txt $bin 2>&1 | Out-Null
        if (-not (Test-Path $txt)) {
            $failures += "$($addon.Name): could not round-trip config.bin back to text"
            continue
        }

        $content = Get-Content $txt -Raw
        $wanted = $expect[$addon.Name]
        if (-not $wanted) {
            $failures += "$($addon.Name): no expectations defined for this addon"
            continue
        }

        $missing = @($wanted | Where-Object { -not $content.Contains($_) })
        if ($missing.Count -gt 0) {
            foreach ($m in $missing) { "  MISSING: $m" }
            $failures += "$($addon.Name): round-tripped config is missing $($missing.Count) expected string(s)"
        } else {
            "  OK: all $($wanted.Count) expected strings present"
        }
    } catch {
        $failures += "$($addon.Name): $($_.Exception.Message)"
    } finally {
        if ($pushed) { Pop-Location -ErrorAction SilentlyContinue }
        if (Test-Path $stage) { Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

"`n" + ("-" * 60)
if ($failures.Count -gt 0) {
    "VALIDATE: FAIL ($($failures.Count))"
    $failures | ForEach-Object { "  - $_" }
    exit 1
}
"VALIDATE: PASS - $($addons.Count) addon(s) validated with CfgConvert"
exit 0
