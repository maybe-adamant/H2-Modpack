local Registry = adamant_Modpack.Registry

Registry:register({
    id = "StagedOmegaFix",
    name = "Axe and Blade Omega Channel Fix",
    category = "BugFixes",
    group = "Weapons & Attacks",
    tooltip = "Fixes Axe OAtk, Blade OSpec not benefiting correctly from channeling bonus.",
    default = true,

    apply = function(AddToBackup)
        AddToBackup(WeaponData.WeaponDaggerThrow, "MinWeaponChargeTime")
        AddToBackup(WeaponData.WeaponAxeSpin,     "MinWeaponChargeTime")
        WeaponData.WeaponDaggerThrow.MinWeaponChargeTime = 0.05
        WeaponData.WeaponAxeSpin.MinWeaponChargeTime = 0.05
    end,
})
