local Registry = adamant_Modpack.Registry

Registry:register({
    id = "CorrosionFix",
    name = "Corrosion Fix",
    category = "BugFixes",
    group = "NPC & Encounters",
    tooltip = "Fixes corrosion aggroing mobs on thessaly boats.",
    default = true,

    apply = function(AddToBackup)
        if not TraitData.ArmorPenaltyCurse then return end
        AddToBackup(TraitData.ArmorPenaltyCurse.OnEnemySpawnFunction.Args, "SkipOnDamagedPowers")
        TraitData.ArmorPenaltyCurse.OnEnemySpawnFunction.Args.SkipOnDamagedPowers = true
    end,
})
