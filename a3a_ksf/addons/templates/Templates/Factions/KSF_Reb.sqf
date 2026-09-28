///////////////////////////
//   Rebel Information   //
///////////////////////////

["name", "KSF"] call _fnc_saveToTemplate;

// The physical flag object and the map marker type are the two settings that
// must match real marker classes or the marker silently fails to spawn.
// Flag_FIA_F / flag_FIA / flag_fia_co.paa are the triple used by Antistasi's
// own vanilla FIA template, so all three are known to resolve. Change all
// three together if you give KSF its own flag.
["flag", "Flag_FIA_F"] call _fnc_saveToTemplate;
["flagTexture", "a3\data_f\flags\flag_fia_co.paa"] call _fnc_saveToTemplate;
["flagMarkerType", "flag_FIA"] call _fnc_saveToTemplate;

["vehiclesBasic", ["I_G_Quadbike_01_F"]] call _fnc_saveToTemplate;
private _vehiclesLightUnarmed = ["I_G_Offroad_01_F"];
private _vehiclesLightArmed = ["I_G_Offroad_01_armed_F"];
["vehiclesTruck", ["I_G_Van_01_transport_F"]] call _fnc_saveToTemplate;
private _vehiclesAT = ["I_G_Offroad_01_AT_F"];
private _vehicleAA = [];

["vehiclesBoat", ["I_C_Boat_Transport_01_F"]] call _fnc_saveToTemplate;

["vehiclesPlane", ["I_C_Plane_Civil_01_F"]] call _fnc_saveToTemplate;

private _vehiclesCivCar = ["C_Offroad_01_F", "C_Hatchback_01_F", "C_SUV_01_F"];
private _vehiclesCivTruck = ["C_Van_01_transport_F", "C_Van_02_transport_F", "C_Van_02_vehicle_F"];
private _vehiclesCivHeli = ["C_Heli_Light_01_civil_F"];
private _vehiclesCivBoat = ["C_Boat_Civil_01_F", "C_Rubberboat"];

["staticMGs", ["I_G_HMG_02_high_F", "I_G_HMG_02_F"]] call _fnc_saveToTemplate;
["staticAT", ["I_static_AT_F"]] call _fnc_saveToTemplate;
private _staticAA = ["I_static_AA_F"];
private _staticMortars = ["I_G_Mortar_01_F"];
["staticMortarMagHE", "8Rnd_82mm_Mo_shells"] call _fnc_saveToTemplate;
["staticMortarMagSmoke", "8Rnd_82mm_Mo_Smoke_white"] call _fnc_saveToTemplate;
["staticMortarMagFlare", "8Rnd_82mm_Mo_Flare_white"] call _fnc_saveToTemplate;

["mineAT", "ATMine_Range_Mag"] call _fnc_saveToTemplate;
["mineAPERS", "APERSMine_Range_Mag"] call _fnc_saveToTemplate;

["breachingExplosivesAPC", [["DemoCharge_Remote_Mag", 1]]] call _fnc_saveToTemplate;
["breachingExplosivesTank", [["SatchelCharge_Remote_Mag", 1], ["DemoCharge_Remote_Mag", 2]]] call _fnc_saveToTemplate;

if ("expansion" in A3A_enabledDLC) then {
    _vehiclesCivCar append ["C_Offroad_02_unarmed_F"];
    _vehiclesLightUnarmed append ["I_C_Offroad_02_unarmed_F"];
    _vehiclesLightArmed append ["I_C_Offroad_02_LMG_F"];
    _vehiclesAT append ["I_C_Offroad_02_AT_F"];
};

if ("rf" in A3A_enabledDLC) then {
    _vehiclesCivCar append ["C_Pickup_rf", "C_Pickup_covered_rf"];
    _vehiclesLightUnarmed append ["I_G_Pickup_rf", "I_G_Pickup_covered_rf"];
    _vehiclesLightArmed append ["I_G_Pickup_mmg_rf", "I_G_Pickup_hmg_rf"];
    _staticMortars append ["I_G_CommandoMortar_rf"];
    _vehiclesCivHeli append ["C_Heli_EC_01A_civ_RF"];
};

if ("ws" in A3A_enabledDLC) then {
    _vehicleAA append ["I_Tura_Truck_02_aa_lxWS"];
    _staticAA insert [0, ["I_Tura_ZU23_lxWS"]];
    _vehiclesLightUnarmed insert [1, ["I_G_Offroad_01_armor_base_lxWS"]];
    _vehiclesLightArmed insert [1, ["I_G_Offroad_01_armor_armed_lxWS"]];
    _vehiclesAT insert [1, ["I_G_Offroad_01_armor_AT_lxWS"]];
};

["vehiclesCivHeli", _vehiclesCivHeli] call _fnc_saveToTemplate;
["staticMortars", _staticMortars] call _fnc_saveToTemplate;
["vehiclesCivCar", _vehiclesCivCar] call _fnc_saveToTemplate;
["vehiclesLightUnarmed", _vehiclesLightUnarmed] call _fnc_saveToTemplate;
["vehiclesLightArmed", _vehiclesLightArmed] call _fnc_saveToTemplate;
["vehiclesAT", _vehiclesAT] call _fnc_saveToTemplate;
["vehiclesAA", _vehicleAA] call _fnc_saveToTemplate;
["staticAA", _staticAA] call _fnc_saveToTemplate;

#include "KSF_Reb_Vehicle_Attributes.sqf"

/////////////////////////////////////
//  Weapons / Explosives selection  //
/////////////////////////////////////

// A template CANNOT express "infinite" ammunition. fn_loadout_addItems.sqf
// only inserts a batch when _count > 0, so a negative or -1 count resolves to
// zero magazines rather than "unlimited". Ammo is also bounded by the
// inventory/crafting system, so the counts used in the unit templates below
// are deliberately high-but-finite. Change the numbers on the
// ["primary", N] / ["handgun", N] lines to retune them.

// CUP is preferred. When it is absent we fall back to Russian-pattern
// weapons that ship with vanilla Arma 3, so the faction is never unarmed.
// Detection tests the weapon classes themselves rather than a CfgPatches
// entry - third-party patch names are not something we can rely on.
private _hasCUP = isClass (configFile >> "CfgWeapons" >> "CUP_arifle_AK47")
              && isClass (configFile >> "CfgWeapons" >> "CUP_hgun_Makarov");
private _hasACE = isClass (configFile >> "CfgWeapons" >> "ACE_DeadManSwitch");

private _primary;
private _primaryMags;
private _sidearm;
private _sidearmMags;

if (_hasCUP) then {
    _primary     = "CUP_arifle_AK47";
    _primaryMags = ["CUP_30Rnd_762x39_AK47_bakelite_M"];
    _sidearm     = "CUP_hgun_Makarov";
    _sidearmMags = ["CUP_8Rnd_9x18_Makarov_M"];
} else {
    _primary     = "arifle_AKM_F";
    _primaryMags = ["30Rnd_762x39_Mag_F"];
    _sidearm     = "hgun_Rook40_F";
    _sidearmMags = ["30Rnd_9x21_Mag"];
};

///////////////////////////
//  Rebel Starting Gear  //
///////////////////////////

private _initialRebelEquipment = [
"hgun_Pistol_heavy_02_F","hgun_P07_F",
"SMG_01_F","hgun_PDW2000_F","SMG_02_F",
"6Rnd_45ACP_Cylinder","16Rnd_9x21_Mag","30Rnd_45ACP_Mag_SMG_01","30Rnd_9x21_Mag_SMG_02","MiniGrenade","SmokeShell",
["IEDUrbanSmall_Remote_Mag", 20], ["IEDLandSmall_Remote_Mag", 20], ["IEDUrbanBig_Remote_Mag", 6], ["IEDLandBig_Remote_Mag", 6],
"B_FieldPack_oli","B_FieldPack_blk","B_FieldPack_ocamo","B_FieldPack_oucamo","B_FieldPack_cbr","B_FieldPack_khk",
"V_Chestrig_blk","V_Chestrig_rgr","V_Chestrig_khk","V_Chestrig_oli","V_BandollierB_blk","V_BandollierB_cbr","V_BandollierB_rgr",
"V_BandollierB_khk","V_BandollierB_oli","V_Rangemaster_belt",
"Binocular","hgun_Pistol_Signal_F","6Rnd_GreenSignal_F","6Rnd_RedSignal_F",
"acc_flashlight","acc_flashlight_smg_01","acc_flashlight_pistol"];

if ("expansion" in A3A_enabledDLC) then {
    _initialRebelEquipment append [["launch_RPG7_F", 10], ["RPG7_F", 25], "SMG_05_F", "hgun_Pistol_01_F", "10Rnd_9x21_Mag"];
} else {
    _initialRebelEquipment append [["launch_RPG32_F", 5], ["RPG32_F", 15]];
};
if ("enoch" in A3A_enabledDLC) then {
    _initialRebelEquipment append ["sgun_HunterShotgun_01_F", "sgun_HunterShotgun_01_sawedoff_F", "2Rnd_12Gauge_Pellets", "2Rnd_12Gauge_Slug"];
};

if (A3A_hasTFAR) then {_initialRebelEquipment append ["tf_microdagr","tf_anprc154"]};
if (A3A_hasTFAR && startWithLongRangeRadio) then {_initialRebelEquipment append ["tf_anprc155"]};
if (A3A_hasTFARBeta) then {_initialRebelEquipment append ["TFAR_microdagr","TFAR_anprc154"]};
if (A3A_hasTFARBeta && startWithLongRangeRadio) then {_initialRebelEquipment append ["TFAR_anprc155"]};

// Primary and sidearm, plus magazines, so the KSF arsenal is usable as-is.
_initialRebelEquipment append [
    [_primary, 4],
    [_sidearm, 4],
    [_primaryMags select 0, 48],
    [_sidearmMags select 0, 12]
];

// Explosives. ACE3 re-declares the vanilla charge classes rather than
// replacing them, so these classnames are correct with or without ACE.
_initialRebelEquipment append [
    ["DemoCharge_Remote_Mag", 8],
    ["SatchelCharge_Remote_Mag", 4]
];

// ACE3 only. Dead man's switch is a real inventory item (an ACE_ItemCore that
// the DeadmanSwitch trigger acts on), not a radio or a scripted effect.
if (_hasACE) then {
    _initialRebelEquipment append [
        ["ACE_DeadManSwitch", 2],
        ["ACE_Clacker", 4],
        ["ACE_DefusalKit", 2]
    ];
};

_initialRebelEquipment append ["Chemlight_blue","Chemlight_green","Chemlight_red","Chemlight_yellow"];
["initialRebelEquipment", _initialRebelEquipment] call _fnc_saveToTemplate;

private _rebUniforms = [
    "U_IG_Guerilla1_1",
    "U_IG_Guerilla2_1",
    "U_IG_Guerilla2_2",
    "U_IG_Guerilla2_3",
    "U_IG_Guerilla3_1",
    "U_IG_leader",
    "U_IG_Guerrilla_6_1",
    "U_I_G_resistanceLeader_F",
    "U_I_L_Uniform_01_deserter_F"
];

private _dlcUniforms = [];

if ("enoch" in A3A_enabledDLC) then {
    _dlcUniforms append [
        "U_I_L_Uniform_01_camo_F"
    ];
};

if ("expansion" in A3A_enabledDLC) then {
    _dlcUniforms append [
        "U_I_C_Soldier_Bandit_1_F",
        "U_I_C_Soldier_Bandit_2_F",
        "U_I_C_Soldier_Bandit_3_F",
        "U_I_C_Soldier_Bandit_4_F",
        "U_I_C_Soldier_Bandit_5_F",
        "U_I_C_Soldier_Para_2_F",
        "U_I_C_Soldier_Para_3_F",
        "U_I_C_Soldier_Camo_F"
    ];
};

if ("rf" in A3A_enabledDLC) then {
    _dlcUniforms append [
        "U_IG_Guerrilla_RF",
        "U_IG_leader_RF"
    ];
};

["uniforms", _rebUniforms + _dlcUniforms] call _fnc_saveToTemplate;

["headgear", [
    "H_Booniehat_khk_hs",
    "H_Booniehat_tan",
    "H_Cap_tan",
    "H_Cap_oli_hs",
    "H_Cap_blk",
    "H_ShemagOpen_tan",
    "H_Shemag_olive_hs",
    "H_Bandanna_khk_hs",
    "H_Bandanna_sand",
    "H_Bandanna_cbr"
]] call _fnc_saveToTemplate;

/////////////////////
///  Identities   ///
/////////////////////

// Vanilla-only Arab/Persian identity set. There is no vanilla "ArabicMen"
// GenericNames class - Arma 3 has no Arab name pool - so the firstNames /
// lastNames inherited from RebelDefaults.sqf (GreekMen) are left in place.
// Add your own CfgWorlds >> GenericNames class and a
// "<yourclass>" call _ffnc_saveNames; line here if you want matching names.
["faces", ["PersianHead_A3_01","PersianHead_A3_02","PersianHead_A3_03",
"PersianHead_A3_04_a","PersianHead_A3_04_sa"]] call _fnc_saveToTemplate;
["voices", ["Male01PER","Male02PER","Male03PER"]] call _fnc_saveToTemplate;

//////////////////////////
//       Loadouts       //
//////////////////////////

private _loadoutData = call _fnc_createLoadoutData;
_loadoutData set ["maps", ["ItemMap"]];
_loadoutData set ["watches", ["ItemWatch"]];
_loadoutData set ["compasses", ["ItemCompass"]];
_loadoutData set ["binoculars", ["Binocular"]];

_loadoutData set ["uniforms", _rebUniforms];

// Weapon entry format is
//   [weapon, muzzle, pointer, optic, primaryMags[], secondaryMags[], bipod]
// Only the classnames vary - the selected CUP-or-vanilla pair is built earlier
// in this file, so this stays correct whether or not CUP is loaded.
_loadoutData set ["rifles", [[_primary, "", "", "", _primaryMags, [], ""]]];
_loadoutData set ["sidearms", [[_sidearm, "", "", "", _sidearmMags, [], ""]]];
_loadoutData set ["carbines", [[_primary, "", "", "", _primaryMags, [], ""]]];
_loadoutData set ["SMGs", [[_primary, "", "", "", _primaryMags, [], ""]]];
// Contact (enoch) asset - must stay gated to match the starting gear above.
if ("enoch" in A3A_enabledDLC) then {
    _loadoutData set ["shotguns", ["sgun_HunterShotgun_01_F"]];
};

_loadoutData set ["lightExplosives", ["DemoCharge_Remote_Mag"]];
_loadoutData set ["heavyExplosives", ["SatchelCharge_Remote_Mag"]];
_loadoutData set ["ATMines", ["ATMine_Range_Mag"]];
_loadoutData set ["APMines", ["APERSMine_Range_Mag"]];
if (_hasACE) then {
    _loadoutData set ["items_squadLeader_extras", ["ACE_Clacker", "ACE_DeadManSwitch", "ACE_DefusalKit"]];
    _loadoutData set ["items_explosivesExpert_extras", ["ACE_Clacker", "ACE_DeadManSwitch", "ACE_DefusalKit"]];
} else {
    _loadoutData set ["items_squadLeader_extras", []];
    _loadoutData set ["items_explosivesExpert_extras", []];
};

_loadoutData set ["glasses", ["G_Shades_Black", "G_Shades_Blue", "G_Shades_Green", "G_Shades_Red", "G_Aviator", "G_Spectacles", "G_Spectacles_Tinted", "G_Sport_BlackWhite", "G_Sport_Blackyellow", "G_Sport_Greenblack", "G_Sport_Checkered", "G_Sport_Red", "G_Squares", "G_Squares_Tinted"]];
_loadoutData set ["goggles", ["G_Lowprofile"]];
_loadoutData set ["facemask", ["G_Bandanna_blk", "G_Bandanna_oli", "G_Bandanna_khk", "G_Bandanna_tan", "G_Bandanna_beast", "G_Bandanna_shades", "G_Bandanna_sport", "G_Bandanna_aviator"]];

_loadoutData set ["items_medical_basic", ["BASIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_standard", ["STANDARD"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_medic", ["MEDIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_miscEssentials", [] call A3A_fnc_itemset_miscEssentials];

////////////////////////
//  Rebel Unit Types  //
////////////////////////

private _squadLeaderTemplate = {
    ["uniforms"] call _fnc_setUniform;
    [selectRandomWeighted [[], 1.25, "glasses", 1, "goggles", 0.75, "facemask", 1]] call _fnc_setFacewear;

    ["rifles"] call _fnc_setPrimary;
    ["primary", 12] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 6] call _fnc_addMagazines;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["items_squadLeader_extras"] call _fnc_addItemSet;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["binoculars"] call _fnc_addBinoculars;
};

private _riflemanTemplate = {
    ["uniforms"] call _fnc_setUniform;
    [selectRandomWeighted [[], 1.25, "glasses", 1, "goggles", 0.75, "facemask", 1]] call _fnc_setFacewear;

    ["rifles"] call _fnc_setPrimary;
    ["primary", 12] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 6] call _fnc_addMagazines;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
};

// The names below must stay exactly as written. Antistasi hardcodes the
// militia_* role mapping for the independent side; renaming one of these
// makes the game silently fall back to the generic a3a_unit_reb.
private _prefix = "militia";
private _unitTypes = [
    ["Petros", _squadLeaderTemplate],
    ["SquadLeader", _squadLeaderTemplate],
    ["Rifleman", _riflemanTemplate],
    ["staticCrew", _riflemanTemplate],
    ["Medic", _riflemanTemplate, [["medic", true]]],
    ["Engineer", _riflemanTemplate, [["engineer", true]]],
    ["ExplosivesExpert", _riflemanTemplate, [["explosiveSpecialist", true]]],
    ["Grenadier", _riflemanTemplate],
    ["LAT", _riflemanTemplate],
    ["AT", _riflemanTemplate],
    ["AA", _riflemanTemplate],
    ["MachineGunner", _riflemanTemplate],
    ["Marksman", _riflemanTemplate],
    ["Sniper", _riflemanTemplate],
    ["Unarmed", _riflemanTemplate]
];

[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;
