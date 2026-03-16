local Registry = adamant_Modpack.Registry

Registry:register({
    id = "GGGFix",
    name = "GGG Echo Fix",
    category = "BugFixes",
    group = "NPC & Encounters",
    tooltip = "Allows GGG to be offered in Jpom runs.",
    default = true,

    apply = function(AddToBackup)
        if not TraitData.EchoRepeatKeepsakeBoon then return end
        AddToBackup(TraitData.EchoRepeatKeepsakeBoon, "GameStateRequirements")
        TraitData.EchoRepeatKeepsakeBoon.GameStateRequirements[2].HasNone = { "AthenaEncounterKeepsake", "FountainRarityKeepsake" }
        table.insert(TraitData.EchoRepeatKeepsakeBoon.GameStateRequirements, {
            Path = { "CurrentRun", "Hero", "SlottedTraits", "Keepsake" },
            IsNone = { "HadesAndPersephoneKeepsake", "EscalatingKeepsake" }
        })
    end,
})
