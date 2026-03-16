local Registry = adamant_Modpack.Registry

Registry:register({
    id = "DisableArachnePity",
    name = "Disable Arachne Pity",
    category = "RunModifiers",
    group = "NPCs & Routing",
    tooltip = "Disables Arachne Pity entirely for Anyfear runs.",
    default = false,

    apply = function(AddToBackup)
        AddToBackup(RoomSetData.F.F_Story01, "ForceIfUnseenForRuns")
        RoomSetData.F.F_Story01.ForceIfUnseenForRuns = nil
    end,
})
