class Templates {
    class Vanilla_Base; //import Vanilla_Base from A3A to use with defining a new vanilla template

    class KSF : Vanilla_Base
    {
        basepath = QPATHTOFOLDER(Templates\Factions); //the path to the folder the template is located in, this translates to "\x\a3a_ksf\addons\templates\Templates\Factions"
        side = "Reb"; //the side the faction defaults to, one of the following: Inv, Occ, Reb, Civ
        flagTexture = "a3\data_f\flags\flag_fia_co.paa"; //path to an icon to be displayed in the selector
        name = "KSF"; //the name shown in the selector
        file = "KSF_Reb"; //the template file name, ".sqf" is appended automatically
        maps[] = {"altis", "tanoa", "sahra"}; //if this template should be prioritized on any maps (case sensetive to worldName)
        climate[] = {"arid", "tropical"}; //climate that the template is meant for
        shortName = "KSF"; //the name shown in the faction info title
        lore = "Klang Speshel Forces. A volunteer irregular detachment that favours hit-and-run ambushes and IEDs over set-piece battles. Dispersed into small cells across rural and urban terrain, they field converted civilian vehicles and technicals rather than armour, with a light mortar section and a mix of veteran and conscript shooters.";
    };
};
