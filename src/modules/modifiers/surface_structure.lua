local Utils = adamant_Modpack
local Registry = Utils.Registry

local bannedEncounters = {
    HeraclesCombatO = true, HeraclesCombatO2 = true,  -- Thessaly
}

Registry:register({
    id = "SurfaceStructureFix",
    name = "Less Sucky Surface",
    category = "RunModifiers",
    group = "World & Combat Tweaks",
    tooltip = "1. Thessaly Miniboss forced between rooms 2-4.\n2. Olympus midshop forced between rooms 5-7.\n3. Removes Boatacles.",
    default = false,

    apply = function(AddToBackup)
        AddToBackup(RoomSetData.P.P_Shop01, "ForceAtBiomeDepthMin", "ForceAtBiomeDepthMax")
        AddToBackup(RoomSetData.O.O_MiniBoss01, "ForceAtBiomeDepthMin", "ForceAtBiomeDepthMax")
        AddToBackup(RoomSetData.O.O_MiniBoss02, "ForceAtBiomeDepthMin", "ForceAtBiomeDepthMax")
        AddToBackup(RoomData["O_MiniBoss01"], "GameStateRequirements")
        AddToBackup(RoomData["O_MiniBoss02"], "GameStateRequirements")

        -- Olympus midshop
        RoomSetData.P.P_Shop01.ForceAtBiomeDepthMin = 5
        RoomSetData.P.P_Shop01.ForceAtBiomeDepthMax = 7

        -- Thessaly Minibosses
        RoomSetData.O.O_MiniBoss01.ForceAtBiomeDepthMin = 2
        RoomSetData.O.O_MiniBoss01.ForceAtBiomeDepthMax = 4
        RoomSetData.O.O_MiniBoss02.ForceAtBiomeDepthMin = 2
        RoomSetData.O.O_MiniBoss02.ForceAtBiomeDepthMax = 4

        for _, roomName in ipairs({ "O_MiniBoss01", "O_MiniBoss02" }) do
            Utils.ApplyRoomChanges(roomName, function(room)
                if not room.GameStateRequirements then return end
                for _, req in ipairs(room.GameStateRequirements) do
                    if req.Path and req.Path[2] == "BiomeDepthCache" then
                        if req.Comparison == ">=" and req.Value == 3 then
                            req.Value = 2
                        elseif req.Comparison == "<=" and req.Value == 5 then
                            req.Value = 4
                        end
                    end
                end
            end)
        end
    end,

    hooks = {
        {
            target = "ChooseEncounter",
            fn = function(baseFunc, currentRun, room, args)
                args = args or {}
                local source = args.LegalEncounters or room.LegalEncounters
                if source then
                    local filtered = {}
                    for _, enc in pairs(source) do
                        if not bannedEncounters[enc] then
                            table.insert(filtered, enc)
                        end
                    end
                    args.LegalEncounters = filtered
                end
                return baseFunc(currentRun, room, args)
            end,
        },
    },
})
