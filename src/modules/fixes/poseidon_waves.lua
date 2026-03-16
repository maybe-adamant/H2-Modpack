local Registry = adamant_Modpack.Registry

Registry:register({
    id = "PoseidonWavesFix",
    name = "Poseidon Waves Fix",
    category = "BugFixes",
    group = "Boons & Hammers",
    tooltip = "Fixes Poseidon waves on Axe special and Hidden Helix Torch.",
    default = true,

    apply = function(AddToBackup)
        if not TraitData.PoseidonSpecialBoon then return end
        AddToBackup(TraitData.PoseidonSpecialBoon.OnEnemyDamagedAction.Args, "MultihitProjectileWhitelist", "MultihitProjectileConditions")
        local args = TraitData.PoseidonSpecialBoon.OnEnemyDamagedAction.Args
        table.insert(args.MultihitProjectileWhitelist, "ProjectileAxeSpecial")
        args.MultihitProjectileConditions.ProjectileAxeSpecial = { Count = 4, Window = 0.3 }
        args.MultihitProjectileConditions.ProjectileTorchOrbit.Count = 4
    end,
})
