# Zbd Combat Lock
# Author: Cristian Privat - privat.tecnologia@gmail.com
# Copyright (c) 2026 Cristian Privat
# SPDX-License-Identifier: MIT
# License: MIT; see LICENSE in the project root.

# Collect only the standard Project Zomboid diagnostic files. Saves, settings
# and credentials are never copied.
$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$diagnostics = Join-Path $repositoryRoot "diagnostics"
$zomboidRoot = Join-Path $env:USERPROFILE "Zomboid"

# Keep diagnostics inside the repository where they are ignored by Git.
New-Item -ItemType Directory -Force -Path $diagnostics | Out-Null

# Some files exist only for hosted or cooperative sessions, so each source is
# optional.
foreach ($name in @("console.txt", "coop-console.txt", "logs.zip")) {
    $source = Join-Path $zomboidRoot $name
    if (Test-Path $source) {
        Copy-Item -Force $source $diagnostics
    }
}

Write-Host "Diagnosticos disponiveis em $diagnostics"
