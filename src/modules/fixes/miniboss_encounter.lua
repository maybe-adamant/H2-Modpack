local Registry = adamant_Modpack.Registry

Registry:register({
    id = "MiniBossEncounterFix",
    name = "Miniboss Encounter Fix",
    category = "BugFixes",
    group = "NPC & Encounters",
    tooltip = "Fixes Miniboss with top screen health bars not properly progressing biome depth\nBosses like Boar, Charybdis, Talos.",
    default = true,

    apply = function(AddToBackup)
        AddToBackup(EncounterData.MiniBossBoar,      "CountsForRoomEncounterDepth")
        AddToBackup(EncounterData.MiniBossCharybdis, "CountsForRoomEncounterDepth")
        AddToBackup(EncounterData.MiniBossTalos,     "CountsForRoomEncounterDepth")
        AddToBackup(EncounterData.BossTyphonEye01,   "CountsForRoomEncounterDepth")
        AddToBackup(EncounterData.BossTyphonArm01,   "CountsForRoomEncounterDepth")
        EncounterData.MiniBossBoar.CountsForRoomEncounterDepth = true
        EncounterData.MiniBossCharybdis.CountsForRoomEncounterDepth = true
        EncounterData.MiniBossTalos.CountsForRoomEncounterDepth = true
        EncounterData.BossTyphonEye01.CountsForRoomEncounterDepth = true
        EncounterData.BossTyphonArm01.CountsForRoomEncounterDepth = true
    end,
})
