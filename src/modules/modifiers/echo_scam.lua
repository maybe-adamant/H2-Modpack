local Utils = adamant_Modpack
local Registry = Utils.Registry

Registry:register({
    id = "PreventEchoScam",
    name = "Prevent Echo Scam",
    category = "RunModifiers",
    group = "NPCs & Routing",
    tooltip = "Prevents Echo scam by blocking both minibosses from spawning at room 3.",
    default = false,

    apply = function(AddToBackup)
        AddToBackup(RoomData["H_MiniBoss01"], "GameStateRequirements")
        AddToBackup(RoomData["H_MiniBoss02"], "GameStateRequirements")
        local newReq = {
            Path = { "CurrentRun", "BiomeDepthCache" },
            Comparison = "!=",
            Value = 3,
        }
        for _, roomName in ipairs({ "H_MiniBoss01", "H_MiniBoss02" }) do
            local reqs = RoomData[roomName].GameStateRequirements
            if reqs and not Utils.ListContainsEquivalent(reqs, newReq) then
                table.insert(reqs, newReq)
            end
        end
    end,
})
