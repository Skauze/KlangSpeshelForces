["attributesVehicles", [
    ["I_G_Offroad_01_armed_F", ["rebCost", 900], ["threat", 60]],
    ["I_G_Offroad_01_AT_F", ["rebCost", 1500], ["threat", 60]],
    ["I_C_Boat_Transport_01_F", ["rebCost", 150]],
    ["C_Heli_Light_01_civil_F", ["rebCost", 8000]]
]] call _fnc_saveToTemplate;

// Western Sahara Vehicles
if (isClass (configFile >> "CfgPatches" >> "Vehicles_F_lxWS")) then {
    (["attributesVehicles"] call _fnc_getFromTemplate) append [
        ["I_G_Offroad_01_armor_base_lxWS", ["rebCost", 400], ["threat", 20]],
        ["I_G_Offroad_01_armor_armed_lxWS", ["rebCost", 900], ["threat", 60]],
        ["I_G_Offroad_01_armor_AT_lxWS", ["rebCost", 1500], ["threat", 60]]
    ];
};

// Reaction Forces Vehicles
if (isClass (configFile >> "CfgPatches" >> "RF_Vehicles")) then {
    (["attributesVehicles"] call _fnc_getFromTemplate) append [
        ["C_Pickup_rf", ["rebCost", 400]],
        ["C_Pickup_covered_rf", ["rebCost", 400]],
        ["I_G_Pickup_hmg_rf", ["rebCost", 900]]
    ];
};
