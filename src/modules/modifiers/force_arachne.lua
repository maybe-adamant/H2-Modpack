local Registry = adamant_Modpack.Registry

Registry:register({
    id = "ForceArachne",
    name = "Force Arachne Spawn",
    category = "RunModifiers",
    group = "NPCs & Routing",
    tooltip = "Forces Arachne to spawn to reduce death pity reset.",
    default = false,

    apply = function(AddToBackup)
        AddToBackup(RoomSetData.F.F_Story01, "ForceAtBiomeDepthMin", "ForceAtBiomeDepthMax")
        RoomSetData.F.F_Story01.ForceAtBiomeDepthMin = 4
        RoomSetData.F.F_Story01.ForceAtBiomeDepthMax = 8
    end,
})
