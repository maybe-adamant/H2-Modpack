local Registry = adamant_Modpack.Registry

local bannedEncounters = {
    ArtemisCombatF = true,  ArtemisCombatF2 = true,  NemesisCombatF = true,       -- Erebus
    ArtemisCombatG = true,  ArtemisCombatG2 = true,  NemesisCombatG = true,       -- Oceanus
    NemesisCombatH = true,                                                         -- Fields
    NemesisCombatI = true,                                                         -- Tartarus
    ArtemisCombatN = true,  ArtemisCombatN2 = true,                               -- Ephyra
    HeraclesCombatN = true, HeraclesCombatN2 = true,                              -- Ephyra
    IcarusCombatO = true,   IcarusCombatO2 = true,                                -- Thessaly
    HeraclesCombatO = true, HeraclesCombatO2 = true,                              -- Thessaly
    AthenaCombatP = true,   AthenaCombatP02 = true,  IcarusCombatP = true,        -- Olympus
    HeraclesCombatP = true,                                                        -- Olympus
}

Registry:register({
    id = "RTAMode",
    name = "RTA Mode",
    category = "RunModifiers",
    group = "World & Combat Tweaks",
    tooltip = "Disables all combat pausing encounters for RTA runs.",
    default = false,

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
