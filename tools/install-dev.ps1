# Zbd Combat Lock
# Author: Cristian Privat - privat.tecnologia@gmail.com
# Copyright (c) 2026 Cristian Privat
# SPDX-License-Identifier: MIT
# License: MIT; see LICENSE in the project root.

[CmdletBinding()]
param(
    # Copy the mod instead of creating a development junction.
    [switch]$Copy
)

# Stop immediately if a filesystem operation fails.
$ErrorActionPreference = "Stop"

# Resolve every path from this script so it can be run from any directory.
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repositoryRoot "mod"
$modsRoot = Join-Path $env:USERPROFILE "Zomboid\mods"
$destination = Join-Path $modsRoot "ZbdCombatLock"

# Project Zomboid creates this folder normally, but a fresh profile may not
# have it yet.
New-Item -ItemType Directory -Force -Path $modsRoot | Out-Null

# Replace only this mod's exact destination. No saves or other mods are touched.
if (Test-Path $destination) {
    Remove-Item -Recurse -Force $destination
}

# Copy mode is useful for a portable snapshot. The default junction mode keeps
# the installed mod synchronized with edits in the repository.
if ($Copy) {
    Copy-Item -Recurse -Force $source $destination
    Write-Host "Mod copiado para $destination"
    exit 0
}

New-Item -ItemType Junction -Path $destination -Target $source | Out-Null
Write-Host "Juncao criada: $destination -> $source"
