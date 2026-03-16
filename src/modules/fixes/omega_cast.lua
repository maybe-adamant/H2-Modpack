local Registry = adamant_Modpack.Registry

Registry:register({
    id = "OmegaCastEffectsFix",
    name = "Omega Cast Effects Fix",
    category = "BugFixes",
    group = "Boons & Hammers",
    tooltip = "Fixes OCast moves not counting as cast damage.",
    default = true,

    apply = function(AddToBackup)
        AddToBackup(WeaponSets, "CastProjectileNames")
        local missingCastProjectiles = {
            "ApolloCastRapid",
            "AresProjectile",
            "ZeusApolloSynergyStrike",
            "DemeterCastStorm",
            "AthenaCastProjectile",
        }
        for _, projectileName in ipairs(missingCastProjectiles) do
            table.insert(WeaponSets.CastProjectileNames, projectileName)
        end
    end,
})
