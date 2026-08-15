# Build-time-only tool, not shipped mod logic (same convention as
# parse_base_exp.ps1/generate_overworld_walkcycle.ps1). Generates the real
# team rosters for the 8 Johto gym leaders, Elite Four (both rounds),
# Champion (both rounds), the 8 Kanto gym-leader rematch trainers, and Red
# -- explicit user spec, verbatim criteria per trainer below.
#
# Source of truth: Pokemon_Stats/pokemon.txt (real PBS-format reference
# data, the same file base_exp_data.lua was built from). Confirmed field
# order via a known species (Charizard: BaseStats = 78,84,78,100,109,85 =
# HP,Attack,Defense,Speed,SpAtk,SpDef -- matches real Charizard stats
# exactly). Evolution stage is DERIVED, not a PBS field: a species with no
# `Evolution =` line of its own cannot evolve further (final/single-stage);
# a species nothing else lists as an `Evolution =` target has nothing
# evolving into it (basic/single-stage). Four buckets:
#   single = no Evolution line AND nothing evolves into it (standalone,
#            e.g. Tauros) -- counts as "last stage" (fully evolved by
#            definition) for the "last stage priority" gyms.
#   basic  = no Evolution line into it, but IT has an Evolution line out
#   middle = something evolves into it, AND it has its own Evolution line
#            out -- the true "second stage" the Morty/Chuck gyms ask for.
#   final  = something evolves into it, and it has no Evolution line out
#
# Selection per trainer+round: candidates = species whose Types include
# the gym's type (dual-type matches on EITHER slot, no special-casing for
# a Dragon secondary -- "main type and sub type dragon are valid with any
# combination of non dragon" just means dual-typing works normally, a
# Flying/Dragon mon still qualifies for the Flying gym) AND BST within
# range AND (stage priority satisfied, if one applies). If fewer than 6
# candidates: first drop the stage filter (keep type+BST), then apply the
# user's own explicit fallback (-/+50 BST) with stage dropped too. "any
# type" (Red) skips the type filter entirely; no stage filter is applied
# to Red at all (not specified, and the BST floor of 600 already forces
# fully-evolved picks in practice).
#
# 6 species are chosen (no duplicates within a single roster) with a FIXED
# seed so re-running this script (e.g. after a PBS data update) reproduces
# the exact same rosters rather than reshuffling every time -- matching
# this whole tool suite's existing "deterministic, idempotent" convention.
# Levels are spread evenly across the trainer's level range (party slot 1
# = low end, slot 6 = the "ace" at the high end), the same shape every
# real Pokemon trainer team uses.
#
# Output: overworld/gym_trainer_teams.lua -- a flat data table (per
# trainer id, per round, 6 {species, level} entries) plus a per-species
# nature table (favorable nature = the mon's own highest non-HP base stat
# gets the "+", lowest non-HP base stat gets the "-", standard Nature
# table) -- consumed by the actual registration code, not itself mod logic.

$srcPath = "C:\Proyectos\DynamaxRecomp\Pokemon_Stats\pokemon.txt"
$outPath = "C:\Proyectos\DynamaxRecomp\GalarGmaxDex\overworld\gym_trainer_teams.lua"

# ---- Parse pokemon.txt ----
$species = [ordered]@{}   # id -> @{ Types=[...]; BST=int; BaseStats=[6 ints]; EvolvesTo=[...] }
$curId = $null
$curTypes = $null
$curStats = $null
$curEvo = @()

function Flush {
    param($id, $types, $stats, $evo)
    if ($id -and $types -and $stats) {
        $bst = ($stats | Measure-Object -Sum).Sum
        $species[$id] = [PSCustomObject]@{
            Types = $types; BaseStats = $stats; BST = $bst; EvolvesTo = $evo
        }
    }
}

foreach ($line in (Get-Content -LiteralPath $srcPath -Encoding UTF8)) {
    if ($line -match '^\[([A-Za-z0-9_]+)\]$') {
        Flush -id $curId -types $curTypes -stats $curStats -evo $curEvo
        $curId = $matches[1]; $curTypes = $null; $curStats = $null; $curEvo = @()
    } elseif ($curId -and $line -match '^Types\s*=\s*(.+)$') {
        $curTypes = $matches[1].Trim() -split ','
    } elseif ($curId -and $line -match '^BaseStats\s*=\s*(.+)$') {
        $curStats = ($matches[1].Trim() -split ',') | ForEach-Object { [int]$_ }
    } elseif ($curId -and $line -match '^Evolution\s*=\s*(.+)$') {
        # Format: TARGET,Method,Param[,TARGET2,Method2,Param2,...] -- every
        # 3rd token starting at index 0 is a target species id.
        $parts = $matches[1].Trim() -split ','
        for ($i = 0; $i -lt $parts.Length; $i += 3) {
            $curEvo += $parts[$i].Trim()
        }
    }
}
Flush -id $curId -types $curTypes -stats $curStats -evo $curEvo

Write-Output "Parsed $($species.Count) species"

# ---- Evolution stage classification ----
$evolvesInto = @{}   # target id -> true (something evolves into it)
foreach ($id in $species.Keys) {
    foreach ($t in $species[$id].EvolvesTo) {
        if ($species.Contains($t)) { $evolvesInto[$t] = $true }
    }
}
$stageOf = @{}
foreach ($id in $species.Keys) {
    $hasOut = $species[$id].EvolvesTo.Count -gt 0
    $hasIn = $evolvesInto.ContainsKey($id)
    if (-not $hasOut -and -not $hasIn) { $stageOf[$id] = "single" }
    elseif ($hasOut -and -not $hasIn) { $stageOf[$id] = "basic" }
    elseif ($hasOut -and $hasIn) { $stageOf[$id] = "middle" }
    else { $stageOf[$id] = "final" }
}

# ---- Nature table (standard: +stat/-stat pairs, 5 neutral omitted since
# a favorable pick always exists for any mon with a clear standout stat) ----
# stat keys: atk, def, spe, spa, spd (never hp -- no nature touches it)
$NATURE_FOR_PAIR = @{
    "atk|def" = "LONELY"; "atk|spe" = "BRAVE"; "atk|spa" = "ADAMANT"; "atk|spd" = "NAUGHTY"
    "def|atk" = "BOLD"; "def|spe" = "RELAXED"; "def|spa" = "IMPISH"; "def|spd" = "LAX"
    "spe|atk" = "TIMID"; "spe|def" = "HASTY"; "spe|spa" = "JOLLY"; "spe|spd" = "NAIVE"
    "spa|atk" = "MODEST"; "spa|def" = "MILD"; "spa|spe" = "QUIET"; "spa|spd" = "RASH"
    "spd|atk" = "CALM"; "spd|def" = "GENTLE"; "spd|spe" = "SASSY"; "spd|spa" = "CAREFUL"
}
function FavorableNature($baseStats) {
    # baseStats = [hp, atk, def, spe, spa, spd] (PBS order)
    $keys = @("atk", "def", "spe", "spa", "spd")
    $vals = @($baseStats[1], $baseStats[2], $baseStats[3], $baseStats[4], $baseStats[5])
    $hiIdx = 0; $loIdx = 0
    for ($i = 1; $i -lt $vals.Length; $i++) {
        if ($vals[$i] -gt $vals[$hiIdx]) { $hiIdx = $i }
        if ($vals[$i] -lt $vals[$loIdx]) { $loIdx = $i }
    }
    if ($hiIdx -eq $loIdx) { return "HARDY" } # perfectly flat -- neutral, no favorable pick exists
    $key = "$($keys[$hiIdx])|$($keys[$loIdx])"
    return $NATURE_FOR_PAIR[$key]
}

# ---- Trainer definitions ----
# type: nil means "any type" (Red). stageFilter: "middle" (second stage
# priority), "final" (last stage priority -- single also qualifies), or
# $null (no preference).
$TRAINERS = @(
    @{ Id = "FALKNER"; Type = "FLYING"; BstMin = 175; BstMax = 335; LvlMin = 17; LvlMax = 20; Stage = $null; Rounds = @(1) }
    @{ Id = "BUGSY"; Type = "BUG"; BstMin = 180; BstMax = 340; LvlMin = 20; LvlMax = 25; Stage = $null; Rounds = @(1) }
    @{ Id = "WHITNEY"; Type = "NORMAL"; BstMin = 190; BstMax = 350; LvlMin = 25; LvlMax = 30; Stage = $null; Rounds = @(1) }
    @{ Id = "MORTY"; Type = "GHOST"; BstMin = 200; BstMax = 400; LvlMin = 30; LvlMax = 35; Stage = "middle"; Rounds = @(1) }
    @{ Id = "CHUCK"; Type = "FIGHTING"; BstMin = 205; BstMax = 410; LvlMin = 35; LvlMax = 40; Stage = "middle"; Rounds = @(1) }
    @{ Id = "JASMINE"; Type = "STEEL"; BstMin = 210; BstMax = 420; LvlMin = 40; LvlMax = 50; Stage = "final"; Rounds = @(1) }
    @{ Id = "PRYCE"; Type = "ICE"; BstMin = 230; BstMax = 500; LvlMin = 50; LvlMax = 65; Stage = "final"; Rounds = @(1) }
    @{ Id = "CLAIR"; Type = "DRAGON"; BstMin = 240; BstMax = 600; LvlMin = 65; LvlMax = 70; Stage = "final"; Rounds = @(1) }

    @{ Id = "WILL"; Type = "PSYCHIC"; BstMin = 250; BstMax = 600; LvlMin = 80; LvlMax = 80; Stage = "final"; Rounds = @(1) }
    @{ Id = "KOGA"; Type = "POISON"; BstMin = 250; BstMax = 600; LvlMin = 80; LvlMax = 80; Stage = "final"; Rounds = @(1) }
    @{ Id = "BRUNO"; Type = "FIGHTING"; BstMin = 250; BstMax = 600; LvlMin = 80; LvlMax = 80; Stage = "final"; Rounds = @(1) }
    @{ Id = "KAREN"; Type = "DARK"; BstMin = 250; BstMax = 600; LvlMin = 80; LvlMax = 80; Stage = "final"; Rounds = @(1) }
    @{ Id = "CHAMPION"; Type = "DRAGON"; BstMin = 400; BstMax = 600; LvlMin = 85; LvlMax = 85; Stage = "final"; Rounds = @(1) }

    @{ Id = "LT_SURGE"; Type = "ELECTRIC"; BstMin = 250; BstMax = 600; LvlMin = 80; LvlMax = 80; Stage = "final"; Rounds = @(1) }
    @{ Id = "SABRINA"; Type = "PSYCHIC"; BstMin = 250; BstMax = 600; LvlMin = 80; LvlMax = 80; Stage = "final"; Rounds = @(1) }
    @{ Id = "ERIKA"; Type = "GRASS"; BstMin = 250; BstMax = 600; LvlMin = 80; LvlMax = 80; Stage = "final"; Rounds = @(1) }
    @{ Id = "JANINE"; Type = "POISON"; BstMin = 250; BstMax = 600; LvlMin = 80; LvlMax = 80; Stage = "final"; Rounds = @(1) }
    @{ Id = "MISTY"; Type = "WATER"; BstMin = 250; BstMax = 600; LvlMin = 80; LvlMax = 80; Stage = "final"; Rounds = @(1) }
    @{ Id = "BROCK"; Type = "ROCK"; BstMin = 250; BstMax = 600; LvlMin = 80; LvlMax = 80; Stage = "final"; Rounds = @(1) }
    @{ Id = "BLAINE"; Type = "FIRE"; BstMin = 250; BstMax = 600; LvlMin = 80; LvlMax = 80; Stage = "final"; Rounds = @(1) }
    @{ Id = "BLUE"; Type = "GROUND"; BstMin = 250; BstMax = 600; LvlMin = 80; LvlMax = 80; Stage = "final"; Rounds = @(1) }

    @{ Id = "RED"; Type = $null; BstMin = 600; BstMax = 800; LvlMin = 99; LvlMax = 99; Stage = $null; Rounds = @(1) }
)
# Round 2 (16 badges): same 4 E4 + Champion, stronger stats. Separate
# entries (Id + "_R2" internally) rather than mutating Rounds above, since
# round 2 has its own BST/level band, not just a level bump.
$TRAINERS += @(
    @{ Id = "WILL"; Type = "PSYCHIC"; BstMin = 500; BstMax = 800; LvlMin = 90; LvlMax = 90; Stage = "final"; Rounds = @(2) }
    @{ Id = "KOGA"; Type = "POISON"; BstMin = 500; BstMax = 800; LvlMin = 90; LvlMax = 90; Stage = "final"; Rounds = @(2) }
    @{ Id = "BRUNO"; Type = "FIGHTING"; BstMin = 500; BstMax = 800; LvlMin = 90; LvlMax = 90; Stage = "final"; Rounds = @(2) }
    @{ Id = "KAREN"; Type = "DARK"; BstMin = 500; BstMax = 800; LvlMin = 90; LvlMax = 90; Stage = "final"; Rounds = @(2) }
    @{ Id = "CHAMPION"; Type = "DRAGON"; BstMin = 500; BstMax = 800; LvlMin = 95; LvlMax = 95; Stage = "final"; Rounds = @(2) }
)

# ---- Selection ----
$rand = New-Object System.Random(20260814)  # fixed seed, deterministic re-runs

function CandidatesFor($type, $bstMin, $bstMax, $stage) {
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($id in $species.Keys) {
        $s = $species[$id]
        if ($type -and -not ($s.Types -contains $type)) { continue }
        if ($s.BST -lt $bstMin -or $s.BST -gt $bstMax) { continue }
        if ($stage) {
            if ($stage -eq "final") {
                if ($stageOf[$id] -ne "final" -and $stageOf[$id] -ne "single") { continue }
            } else {
                if ($stageOf[$id] -ne $stage) { continue }
            }
        }
        $out.Add($id)
    }
    return $out
}

function PickTeam($t) {
    $pool = CandidatesFor -type $t.Type -bstMin $t.BstMin -bstMax $t.BstMax -stage $t.Stage
    $relaxNote = "strict"
    if ($pool.Count -lt 6) {
        $pool = CandidatesFor -type $t.Type -bstMin $t.BstMin -bstMax $t.BstMax -stage $null
        $relaxNote = "dropped stage filter"
    }
    if ($pool.Count -lt 6) {
        $pool = CandidatesFor -type $t.Type -bstMin ($t.BstMin - 50) -bstMax ($t.BstMax + 50) -stage $null
        $relaxNote = "dropped stage + BST -/+50"
    }
    if ($pool.Count -lt 6) {
        Write-Host "WARNING: $($t.Id) only found $($pool.Count) candidates even after relaxation"
    }
    # shuffle (Fisher-Yates, seeded) then take first 6 (or fewer if pool is short)
    $arr = @($pool)
    for ($i = $arr.Length - 1; $i -gt 0; $i--) {
        $j = $rand.Next(0, $i + 1)
        $tmp = $arr[$i]; $arr[$i] = $arr[$j]; $arr[$j] = $tmp
    }
    $take = [Math]::Min(6, $arr.Length)
    $picked = $arr[0..($take - 1)]
    if ($relaxNote -ne "strict") {
        Write-Host "  $($t.Id) round$($t.Rounds[0]): $relaxNote ($($pool.Count) candidates)"
    }
    return $picked
}

$results = [ordered]@{}
foreach ($t in $TRAINERS) {
    $picked = PickTeam $t
    $n = $picked.Count
    $slots = @()
    for ($i = 0; $i -lt $n; $i++) {
        $lvl = if ($n -eq 1) { $t.LvlMax } else {
            [int][Math]::Round($t.LvlMin + ($t.LvlMax - $t.LvlMin) * $i / ($n - 1))
        }
        $slots += [PSCustomObject]@{ Species = $picked[$i]; Level = $lvl }
    }
    $key = "$($t.Id)_R$($t.Rounds[0])"
    $results[$key] = $slots
}

# ---- Natures for every picked species (dedup across trainers) ----
$natureFor = [ordered]@{}
foreach ($key in $results.Keys) {
    foreach ($slot in $results[$key]) {
        if (-not $natureFor.Contains($slot.Species)) {
            $natureFor[$slot.Species] = FavorableNature $species[$slot.Species].BaseStats
        }
    }
}

# ---- Write Lua output ----
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("-- Generated by tools/generate_gym_trainer_teams.ps1 from Pokemon_Stats/")
[void]$sb.AppendLine("-- pokemon.txt (real PBS reference data). NOT hand-written -- rerun the")
[void]$sb.AppendLine("-- generator (fixed seed, deterministic) if the source PBS data changes.")
[void]$sb.AppendLine("-- Round 1 keys: <TRAINER>_R1. Round 2 (Elite Four + Champion only): _R2.")
[void]$sb.AppendLine("return {")
[void]$sb.AppendLine("  teams = {")
foreach ($key in $results.Keys) {
    [void]$sb.AppendLine("    $key = {")
    foreach ($slot in $results[$key]) {
        [void]$sb.AppendLine("      { species = `"$($slot.Species)`", level = $($slot.Level) },")
    }
    [void]$sb.AppendLine("    },")
}
[void]$sb.AppendLine("  },")
[void]$sb.AppendLine("  natures = {")
foreach ($id in $natureFor.Keys) {
    [void]$sb.AppendLine("    $id = `"$($natureFor[$id])`",")
}
[void]$sb.AppendLine("  },")
[void]$sb.AppendLine("}")
[System.IO.File]::WriteAllText($outPath, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
Write-Output "Wrote $outPath"
Write-Output "Teams: $($results.Count), unique species: $($natureFor.Count)"
