local Registry = adamant_Modpack.Registry

Registry:register({
    id = "ShimmeringFix",
    name = "Shimmering Moonshot Fix",
    category = "BugFixes",
    group = "Boons & Hammers",
    tooltip = "Fixes Shimmering Moonshot not applying damage bonus to omega special.",
    default = true,

    apply = function(AddToBackup)
        if not TraitData.StaffJumpSpecialTrait then return end
        AddToBackup(TraitData.StaffJumpSpecialTrait.AddOutgoingDamageModifiers, "ProjectileName", "ValidProjectiles")
        AddToBackup(TraitData.StaffJumpSpecialTrait, "PropertyChanges")
        TraitData.StaffJumpSpecialTrait.AddOutgoingDamageModifiers.ProjectileName = nil
        TraitData.StaffJumpSpecialTrait.AddOutgoingDamageModifiers.ValidProjectiles = { "ProjectileStaffBall", "ProjectileStaffBallCharged" }
        for _, propertyChange in ipairs(TraitData.StaffJumpSpecialTrait.PropertyChanges) do
            propertyChange.ProjectileNames = { "ProjectileStaffBall", "ProjectileStaffBallCharged" }
        end
    end,
})
