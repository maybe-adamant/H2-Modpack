local Registry = adamant_Modpack.Registry

Registry:register({
    id = "BraidFix",
    name = "Braid Fix",
    category = "BugFixes",
    group = "Boons & Hammers",
    tooltip = "Fixes Braid of Atlas to properly buff casts.",
    default = true,

    apply = function(AddToBackup)
        if not TraitData.TemporaryImprovedCastTrait then return end
        AddToBackup(TraitData.TemporaryImprovedCastTrait.AddOutgoingDamageModifiers, "ValidProjectiles", "WeaponOrProjectileRequirement")
        TraitData.TemporaryImprovedCastTrait.AddOutgoingDamageModifiers.ValidProjectiles = WeaponSets.CastProjectileNames
        TraitData.TemporaryImprovedCastTrait.AddOutgoingDamageModifiers.WeaponOrProjectileRequirement = true
    end,
})
