local Registry = adamant_Modpack.Registry

Registry:register({
    id = "ExtraDoseFix",
    name = "Extra Dose Fix",
    category = "BugFixes",
    group = "Weapons & Attacks",
    tooltip = "Fixes Extra Dose interaction with Coat 2nd punch and Dash strike.",
    default = true,

    apply = function(AddToBackup)
        if not TraitData.DoubleStrikeChanceBoon then return end
        AddToBackup(TraitData.DoubleStrikeChanceBoon, "PropertyChanges")
        table.insert(TraitData.DoubleStrikeChanceBoon.PropertyChanges[1].WeaponNames, "WeaponSuit2")
        table.insert(TraitData.DoubleStrikeChanceBoon.PropertyChanges[1].WeaponNames, "WeaponSuitDash")
        table.insert(TraitData.DoubleStrikeChanceBoon.PropertyChanges[4].WeaponNames, "WeaponSuit2")
        table.insert(TraitData.DoubleStrikeChanceBoon.PropertyChanges[4].WeaponNames, "WeaponSuitDash")
    end,
})
