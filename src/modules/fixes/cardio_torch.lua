local Registry = adamant_Modpack.Registry

Registry:register({
    id = "CardioTorchFix",
    name = "Cardio Torch Fix",
    category = "BugFixes",
    group = "Boons & Hammers",
    tooltip = "Fixes Cardio Gain interactions with Torch specials.",
    default = true,

    apply = function(AddToBackup)
        if not TraitData.HestiaManaBoon then return end
        AddToBackup(TraitData.HestiaManaBoon.OnEnemyDamagedAction.Args, "MultihitProjectileWhitelist", "MultihitProjectileConditions")
        local args = TraitData.HestiaManaBoon.OnEnemyDamagedAction.Args
        table.insert(args.MultihitProjectileWhitelist, "ProjectileTorchOrbit")
        args.MultihitProjectileConditions.ProjectileTorchOrbit = { Cooldown = 0.01 }
    end,
})
