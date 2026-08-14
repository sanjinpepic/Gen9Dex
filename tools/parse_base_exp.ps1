# Build-time-only tool, not shipped mod logic (same convention as
# generate_sprite_pack_data.ps1). Parses real PBS-format BaseExp data out
# of Pokemon_Stats/pokemon.txt (1025 base species) and
# pokemon_forms.txt (alternate forms, only the subset that carries its
# own distinct BaseExp field -- PBS omits it when a form's BaseExp is
# identical to its base species'), producing stats/base_exp_data.lua.
#
# Form id resolution, tiered, same "don't guess" discipline as this
# session's other cross-referencing passes:
#   - Mega evolutions: FormName's own "Mega <Species>[ X/Y/Z]" text is
#     pattern-matched directly to <SPECIES>_MEGA[_X/Y/Z].
#   - A small, explicit set of well-known non-Mega multi-form species
#     (Primal Kyogre/Groudon, Rotom's 5 appliances, Black/White Kyurem,
#     Zygarde 10%/Complete, Unbound Hoopa, Necrozma's 3 named forms,
#     Crowned Zacian/Zamazenta, Ice/Shadow Rider Calyrex) hand-mapped to
#     their real ids from confirmed Pokemon knowledge.
#   - Anything else (unnamed/ambiguous FormName entries -- Minior's 7
#     core colors, Palafin Hero, Wishiwashi School, Ash-Greninja,
#     Darmanitan's Zen forms, a few unnamed Kyurem/Necrozma sub-forms)
#     is explicitly skipped and reported, not guessed.
#
# Rerun this whenever Pokemon_Stats/pokemon.txt or pokemon_forms.txt
# changes, to regenerate stats/base_exp_data.lua.

$RepoRoot = "C:\Proyectos\DynamaxRecomp\GalarGmaxDex"
$baseSrc = "C:\Proyectos\DynamaxRecomp\Pokemon_Stats\pokemon.txt"
$formsSrc = "C:\Proyectos\DynamaxRecomp\Pokemon_Stats\pokemon_forms.txt"
$outPath = Join-Path $RepoRoot "stats\base_exp_data.lua"

# ---- Base species ----
$base = [ordered]@{}
$currentId = $null
foreach ($line in (Get-Content -LiteralPath $baseSrc -Encoding UTF8)) {
    if ($line -match '^\[([A-Za-z0-9_]+)\]$') { $currentId = $matches[1] }
    elseif ($currentId -and $line -match '^BaseExp\s*=\s*(\d+)') { $base[$currentId] = [int]$matches[1]; $currentId = $null }
    elseif ($line -match '^\[') { $currentId = $null }
}

# ---- Forms ----
$forms = New-Object System.Collections.Generic.List[object]
$curSpecies = $null; $curFormNum = $null; $curFormName = $null; $curBaseExp = $null
function FlushForm {
    if ($curSpecies -and $curBaseExp) {
        $forms.Add([PSCustomObject]@{ Species = $curSpecies; FormNum = $curFormNum; FormName = $curFormName; BaseExp = $curBaseExp })
    }
}
foreach ($line in (Get-Content -LiteralPath $formsSrc -Encoding UTF8)) {
    if ($line -match '^\[([A-Za-z0-9_]+),(\d+)\]$') {
        FlushForm
        $curSpecies = $matches[1]; $curFormNum = [int]$matches[2]; $curFormName = $null; $curBaseExp = $null
    } elseif ($curSpecies -and $line -match '^FormName\s*=\s*(.+)$') { $curFormName = $matches[1].Trim() }
    elseif ($curSpecies -and $line -match '^BaseExp\s*=\s*(\d+)') { $curBaseExp = [int]$matches[1] }
}
FlushForm

# ---- Mega / known-form id resolution ----
$formResolved = [ordered]@{}
$skipped = New-Object System.Collections.Generic.List[string]
$known = @{
    "KYOGRE_1" = "KYOGRE_PRIMAL"; "GROUDON_1" = "GROUDON_PRIMAL"
    "ROTOM_1" = "ROTOM_HEAT"; "ROTOM_2" = "ROTOM_WASH"; "ROTOM_3" = "ROTOM_FROST"
    "ROTOM_4" = "ROTOM_FAN"; "ROTOM_5" = "ROTOM_MOW"
    "KYUREM_1" = "KYUREM_WHITE"; "KYUREM_2" = "KYUREM_BLACK"
    "ZYGARDE_1" = "ZYGARDE_10"; "ZYGARDE_2" = "ZYGARDE_COMPLETE"
    "HOOPA_1" = "HOOPA_UNBOUND"
    "NECROZMA_1" = "NECROZMA_DUSK_MANE"; "NECROZMA_2" = "NECROZMA_DAWN_WINGS"
    "NECROZMA_3" = "NECROZMA_ULTRA"
    "ZACIAN_1" = "ZACIAN_CROWNED"; "ZAMAZENTA_1" = "ZAMAZENTA_CROWNED"
    "CALYREX_1" = "CALYREX_ICE"; "CALYREX_2" = "CALYREX_SHADOW"
}
foreach ($f in $forms) {
    $id = $null
    if ($f.FormName -match '^Mega .+? ([XYZ])$') { $id = "$($f.Species)_MEGA_$($matches[1].ToUpper())" }
    elseif ($f.FormName -match '^Mega ') { $id = "$($f.Species)_MEGA" }
    else {
        $key = "$($f.Species)_$($f.FormNum)"
        if ($known.ContainsKey($key)) { $id = $known[$key] }
    }
    if ($id) { $formResolved[$id] = $f.BaseExp }
    else { $skipped.Add("$($f.Species),$($f.FormNum) FormName='$($f.FormName)' BaseExp=$($f.BaseExp)") }
}

Write-Output "Base species: $($base.Count)"
Write-Output "Forms resolved: $($formResolved.Count)"
Write-Output "Forms skipped (uncertain, not guessed):"
$skipped | ForEach-Object { Write-Output "  SKIP: $_" }

# ---- Write Lua output ----
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("-- Real BaseExp data, parsed directly from Pokemon_Stats/pokemon.txt and")
[void]$sb.AppendLine("-- pokemon_forms.txt (real PBS-format reference data, user-supplied) --")
[void]$sb.AppendLine("-- NOT an approximation. Regenerate via tools/parse_base_exp.ps1 if the")
[void]$sb.AppendLine("-- source .txt files change. $($base.Count) base species direct from")
[void]$sb.AppendLine("-- pokemon.txt's own BaseExp field. $($formResolved.Count) alternate forms")
[void]$sb.AppendLine("-- (Mega evolutions pattern-matched from FormName; a small set of")
[void]$sb.AppendLine("-- well-known non-Mega multi-form species hand-mapped from confirmed real")
[void]$sb.AppendLine("-- ids -- see this generator script's own header for the exact list).")
[void]$sb.AppendLine("-- Ids the live species registry doesn't recognize are simply skipped at")
[void]$sb.AppendLine("-- consume time (stats/reapply_national_dex_stats.lua), not here.")
[void]$sb.AppendLine("return {")
foreach ($k in $base.Keys) { [void]$sb.AppendLine("  $k = $($base[$k]),") }
foreach ($k in $formResolved.Keys) { [void]$sb.AppendLine("  $k = $($formResolved[$k]),") }
[void]$sb.AppendLine("}")
[System.IO.File]::WriteAllText($outPath, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
Write-Output "Wrote $outPath"
