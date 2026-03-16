local Utils = adamant_Modpack
local Registry = Utils.Registry

Registry:register({
    id = "DisableSeleneBeforeBoon",
    name = "Disable Selene Before First Boon",
    category = "RunModifiers",
    group = "NPCs & Routing",
    tooltip = "Prevents Selene from spawning before the first boon is obtained.",
    default = false,

    apply = function(AddToBackup)
        AddToBackup(NamedRequirementsData, "SpellDropRequirements")
        local additionalSpellReq = {
            Path = { "CurrentRun", "LootTypeHistory" },
            CountOf = {
                "AphroditeUpgrade", "ApolloUpgrade", "DemeterUpgrade",
                "HephaestusUpgrade", "HestiaUpgrade", "HeraUpgrade",
                "PoseidonUpgrade", "ZeusUpgrade", "AresUpgrade", "WeaponUpgrade"
            },
            Comparison = ">=",
            Value = 1
        }

        if NamedRequirementsData and NamedRequirementsData.SpellDropRequirements then
            local targetReqs = NamedRequirementsData.SpellDropRequirements
            if not Utils.ListContainsEquivalent(targetReqs, additionalSpellReq) then
                table.insert(targetReqs, additionalSpellReq)
            end
        end
    end,
})
