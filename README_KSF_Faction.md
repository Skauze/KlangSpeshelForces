# A3A Extender - KSF Faction

An **Antistasi content addon** that adds one new selectable rebel faction:
the **KSF (Klang Speshel Forces)**.

It is built on the official
[A3AExtender](https://github.com/official-antistasi-community/A3AExtender)
framework, so it contains no Antistasi code of its own - it only ships the
addon header/config scaffolding and one faction template.

## Provenance

Derived from
[official-antistasi-community/A3AExtender](https://github.com/official-antistasi-community/A3AExtender)
(cloned at commit `f40c7af`). Changes against that baseline:

- renamed the mod folder/prefix `A3AE` -> `a3a_ksf`
- dropped the `maps` addon (a duplicate of Antistasi's own Altis map) and the
  example-only `functions` addon
- dropped the unregistered `Vanilla_AAF` / `Vanilla_CSAT2` example classes
- trimmed `Templates\Vanilla\` (unreferenced enemy templates)
- trimmed `Tools\` to `Tools\Builder\` (StreetArtist and DSSignFile are
  nav-grid and PBO-signing tools, unused when building a faction template)
- added the `KSF` faction template and this README

`Tools\Builder\hemtt.exe` is committed deliberately, so the project builds
with no extra tooling.

**No licence has been chosen.** Upstream A3AExtener ships no `LICENSE` file
either, so this repository is currently unlicensed - add one before you
publish it anywhere.


## Requirements

| | |
|---|---|
| Antistasi | required (this addon declares `requiredAddons[] = {"A3A_core"}`) |
| CBA | pulled in by Antistasi |
| Arma 3 Tools | **not required** - builds with the bundled HEMTT |
| Addon Builder | **not required** |

## Layout

```
a3a_ksf/
  mod.cpp                                  mod metadata (name/author/tooltip)
  meta/meta.cpp
  addons/
    core/                                  headers + CfgPatches
      Includes/script_mod.hpp
      Includes/mod_name.hpp                MODFOLDER / PREFIX = a3a_ksf
      $PBOPREFIX$                          x\a3a_ksf\addons\core
    templates/                             the actual content
      config.cpp                           CfgPatches + class A3A
      Templates.hpp                        -> includes Templates\Templates.hpp
      Templates/Templates.hpp              <-- the faction registration
      Templates/Factions/KSF_Reb.sqf        <-- the faction data
      Templates/Factions/KSF_Reb_Vehicle_Attributes.sqf
      Templates/#Examples/                  upstream reference examples
      $PBOPREFIX$                          x\a3a_ksf\addons\templates
```

Note: `$PBOPREFIX$` is a **file** sitting directly in each addon folder, not a
folder containing a file. That is what upstream A3AExtender ships, and what
armake reads.

The `maps` and `functions` addons that ship with the upstream example were
**removed**: `maps` is a duplicate of Antistasi's own Altis map (a conflict),
and `functions` only held upstream examples.

## Build

```powershell
& ".\Build.ps1"
```

or directly:

```powershell
& ".\Tools\Builder\buildAddons.ps1"
```

Output lands in `build\a3a_ksf\`:

```
build\a3a_ksf\mod.cpp
build\a3a_ksf\meta.cpp
build\a3a_ksf\addons\core.pbo
build\a3a_ksf\addons\templates.pbo
```

## Install

1. Copy the contents of `build\a3a_ksf\` into your Arma 3 `@A3AExtender`
   folder (the one that already holds `addons\A3A_core.pbo`).
   `@A3AExtender\addons\a3a_ksf_core.pbo`
   `@A3AExtender\addons\a3a_ksf_templates.pbo`
   `@A3AExtender\mod.cpp`
2. Launch Arma 3 with `-mod=@A3AExtender` (or add it to the mod list).

Load order is handled automatically: `a3a_ksf_core` requires `A3A_core`.

## Use in game

Start Antistasi, open the **faction selector** (the Antistasi slot-selection
screen) and pick **KSF** on the player side. It is prioritized on Altis,
Tanoa and Sahra, and limited to the `arid` and `tropical` climates.

## Weapons and explosives

Klang Speshel Forces stocks Russian-pattern weapons **in the arsenal**, i.e.
`_initialRebelEquipment` - the crate you resupply from at a KSF base. The
militia NPC unit loadouts are deliberately left alone, so this changes what
*you* can take, not what the AI spawns holding.

Gear is picked at runtime, so the same faction works with or without CUP:

| | with CUP | without CUP (vanilla fallback) |
|---|---|---|
| primary | `CUP_arifle_AK47` | `arifle_AKM_F` |
| sidearm | `CUP_hgun_Makarov` | `hgun_Rook40_F` |
| magazines | `CUP_30Rnd_762x39_AK47_bakelite_M`, `CUP_8Rnd_9x18_Makarov_M` | `30Rnd_762x39_Mag_F`, `30Rnd_9x21_Mag` |

Detection tests the weapon classes themselves
(`isClass (configFile >> "CfgWeapons" >> "CUP_arifle_AK47")`) rather than a
`CfgPatches` entry, because third-party patch names are not something this
addon can rely on. The consequence is that the arsenal is never empty-handed:
if CUP is missing you get the vanilla AKM/Rook-40 instead, not a blank crate.

Counts currently in the arsenal: 4 primaries, 4 sidearms, 48 primary
magazines, 12 sidearm magazines, 20 small urban IEDs, 20 small land IEDs,
6 large urban IEDs, 6 large land IEDs, 8 demo charges, 4 satchel charges.

Explosives use vanilla-remote-charge classnames (`DemoCharge_Remote_Mag`,
`SatchelCharge_Remote_Mag`) because ACE3 *re-declares* those classes rather
than replacing them, so the same classnames are correct either way.

When ACE3 is present the arsenal also carries `ACE_DeadManSwitch`,
`ACE_Clacker` and `ACE_DefusalKit`. The dead man's switch is a genuine
inventory item - an `ACE_ItemCore` the `DeadmanSwitch` trigger acts on - not a
radio or a scripted effect, so it can simply be picked up and carried.

### Why the ammo is not "infinite"

Antistasi templates cannot express infinite ammunition. In
`fn_loadout_addItems.sqf` a batch is only inserted when `_count > 0`, so
passing `-1` yields **zero** magazines, not unlimited ones. Ammunition is also
capped by the inventory/crafting system regardless, and the arsenal crate
refills on a timer. The counts are therefore high-but-finite; to change them
edit the `[_primary, 4]` / `[_primaryMags select 0, 48]` style entries in the
"Rebel Starting Gear" list in `KSF_Reb.sqf`.

## Editing the faction

Everything lives in two files:

**`Templates\Factions\KSF_Reb.sqf`** - vehicles, statics, uniforms, starting
gear, faces/voices, loadouts and the militia unit list.

**`Templates\Templates.hpp`** - how it is presented in the selector:

```cpp
class KSF : Vanilla_Base
{
    basepath = QPATHTOFOLDER(Templates\Factions);
    side = "Reb";
    flagTexture = "a3\data_f\flags\flag_fia_co.paa";
    name = "KSF";
    file = "KSF_Reb";
    maps[] = {"altis", "tanoa", "sahra"};
    climate[] = {"arid", "tropical"};
    shortName = "KSF";
    lore = "...";
};
```

Rename these in lockstep if you fork it:

* `PREFIX` / `MODFOLDER` in `addons\core\Includes\mod_name.hpp`
* both `$PBOPREFIX$` files
* the `#include "\x\a3a_ksf\..."` line in `addons\templates\script_component.hpp`
* the folder name `a3a_ksf` itself
* `file = "KSF_Reb"` must match the `.sqf` filename

The official `Install.ps1` does the folder/prefix half of this interactively
if you clone fresh.

## Things that will bite you

These are the real traps in the Antistasi template system - all of them are
already handled correctly in `KSF_Reb.sqf`, so keep them intact:

1. **Unit names are hardcoded.** The 15 `militia_*` unit names (`Petros`,
   `SquadLeader`, `Rifleman`, `staticCrew`, `Medic`, `Engineer`,
   `ExplosivesExpert`, `Grenadier`, `LAT`, `AT`, `AA`, `MachineGunner`,
   `Marksman`, `Sniper`, `Unarmed`) are mapped by role in Antistasi's
   `fn_compatibilityLoadFaction.sqf`. Rename one and that role silently
   falls back to the generic rebel soldier. There is no error message.

2. **Key names are plural.** `vehiclesBasic`, `staticMGs`, `staticMortars`,
   `vehiclesLightArmed` - not `vehicleBasic` / `staticMG` / `staticMortar`.
   The upstream `Templates\#Examples\RebelExample.sqf` skeleton is wrong here:
   the *active* keys are singular and only the trailing *comments* show the
   correct plural names. It is a documentation bug in the example, not in
   the engine. Ignore that file's key column and trust `Vanilla_Reb_FIA.sqf`.

3. **`mineAT` vs `minefieldAT` are different things.**
   `mineAT` / `mineAPERS` are `CfgMagazines` classes (what a rebel *places*).
   `minefieldAT` / `minefieldAPERS` are arrays of `CfgVehicles` prefab
   minefield objects (occupant side). Rebels use `mineAT`.

4. **Rebels and occupiers differ in shape for `static*`.** For `Reb`/`Civ`
   these are validated as *arrays*; for `Occ`/`Inv` as a *single class*.

5. **`basepath` + `\` + `file` + `.sqf`.** The path is joined with a Windows
   backslash, and `basepath` is relative to *your* PBO, so it must not
   inherit `Vanilla_Base`'s value.

6. **`Vanilla_Base` only supplies cosmetics.** It provides `logo`,
   `priority`, `equipFlags` and `basepath` defaults. It sets **no** defaults
   for `side`, `file`, `flagTexture` or `name` - you must declare those.

7. **You only need to declare what you change.** A template is layered on
   top of `RebelDefaults.sqf`, so any key you omit keeps its default. The
   KSF template still declares the full set for clarity, but a minimal
   template can be a dozen lines.

## The flag

KSF currently ships Antistasi's own FIA flag, because the flag triple is the
one part of a template that fails *silently* when wrong:

```sqf
["flag", "Flag_FIA_F"]           call _fnc_saveToTemplate;  // physical flag object
["flagTexture", "a3\data_f\flags\flag_fia_co.paa"] call _fnc_saveToTemplate;
["flagMarkerType", "flag_FIA"]   call _fnc_saveToTemplate;  // map marker
```

`Flag_FIA_F` / `flag_FIA` / `flag_fia_co.paa` are the exact triple used by
Antistasi's own `Vanilla_Reb_FIA.sqf`, so all three are known to resolve. A
marker type that does not exist simply does not draw, with no error in the
log.

To give KSF its own flag, put a `.paa` in your mod and change **all three**
lines plus `flagTexture` in `Templates\Templates.hpp` together. Copy
`a3\data_f\flags\flag_fia_co.paa` out of the game as a size/shape reference.

## Identity

```sqf
["faces",  ["PersianHead_A3_01","PersianHead_A3_02","PersianHead_A3_03",
            "PersianHead_A3_04_a","PersianHead_A3_04_sa"]] call _fnc_saveToTemplate;
["voices", ["Male01PER","Male02PER","Male03PER"]] call _fnc_saveToTemplate;
```

`PersianHead_A3_*` and `Male0*PER` are the vanilla Arab/Persian set - there
is no vanilla "Arabic" head or voice class, and Antistasi's own Arab faction
(Western Sahara's Tura) uses the same Persian heads with French voices.

There is also **no vanilla Arab name pool**. `CfgWorlds >> GenericNames` has
no Arabic class; Tura uses `lxWS_WSaharaMen`, which ships with the Western
Sahara mod. So `KSF_Reb.sqf` deliberately makes no `saveNames` call and
inherits `GreekMen` from `RebelDefaults.sqf`, which is guaranteed to resolve.
KSF soldiers therefore have Persian faces, Farsi voices and Greek names.

If the name mismatch bothers you, add your own pool and wire it up:

```cpp
// in your mod's config.cpp
class CfgWorlds {
    class GenericNames {
        class KSFNames {
            class FirstNames { amin = "Amin"; /* ... */ };
            class LastNames  { hussain = "Hussain"; /* ... */ };
        };
    };
};
```

```sqf
// then, in KSF_Reb.sqf
"KSFNames" call _ffnc_saveNames;
```

### `_fnc_saveNames` vs `_ffnc_saveNames`

Both spellings appear in Antistasi's own templates - the vanilla
`Vanilla_Reb_FIA.sqf` calls `_ffnc_saveNames` (three f's), while
`WS_Reb_TURA.sqf` calls `_fnc_saveNames`. `KSF_Reb.sqf` follows the vanilla
FIA spelling. This is moot until you add a `saveNames` call.
