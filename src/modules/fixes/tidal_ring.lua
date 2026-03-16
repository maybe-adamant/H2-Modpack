local Registry = adamant_Modpack.Registry

Registry:register({
    id = "TidalRingFix",
    name = "Tidal Ring Fix",
    category = "BugFixes",
    group = "Weapons & Attacks",
    tooltip = "Fixes Tidal Ring not hitting the same mob twice with Circe.",
    default = true,

    apply = function(AddToBackup)
        if not ProjectileData or not ProjectileData.PoseidonCastSplashSplinter then return end
        AddToBackup(ProjectileData.PoseidonCastSplashSplinter, "ImmunityDuration")
        ProjectileData.PoseidonCastSplashSplinter.ImmunityDuration = 0
    end,
})
