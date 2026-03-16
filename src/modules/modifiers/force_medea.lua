local Registry = adamant_Modpack.Registry

Registry:register({
    id = "ForceMedea",
    name = "Force Medea Spawn",
    category = "RunModifiers",
    group = "NPCs & Routing",
    tooltip = "Forces Medea to spawn to reduce death pity reset.",
    default = false,

    apply = function(AddToBackup)
        AddToBackup(RoomSetData.N.N_Story01, "ForceAtBiomeDepthMin", "ForceAtBiomeDepthMax")
        RoomSetData.N.N_Story01.ForceAtBiomeDepthMin = 0
        RoomSetData.N.N_Story01.ForceAtBiomeDepthMax = 1
    end,
})
