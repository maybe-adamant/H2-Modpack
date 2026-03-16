local Utils = adamant_Modpack
local Registry = Utils.Registry

Registry:register({
    id = "EscalatingFigLeaf",
    name = "Incrementing Fig Leaf",
    category = "RunModifiers",
    group = "World & Combat Tweaks",
    tooltip = "Dionysus Skip Chance starts at default value and increases by 13% after every encounter, resetting on biome start.",
    default = false,

    hooks = {
        {
            target = "DionysusSkipTrait",
            fn = function(baseFunc, args, traitData)
                baseFunc(args, traitData)
                for _, trait in ipairs(CurrentRun.Hero.Traits) do
                    if trait.Name == "PersistentDionysusSkipKeepsake" then
                        trait.InitialSkipEncounterChance = trait.SkipEncounterChance
                        trait.SkipEncounterGrowthPerRoom = 0.13
                        Utils.PrintDebug("Applied Dionysus Skip Chance Growth. Initial Chance: " .. tostring(trait.SkipEncounterChance) .. ", Growth per room: " .. tostring(trait.SkipEncounterGrowthPerRoom))
                        break
                    end
                end
            end,
        },
        {
            target = "EndEncounterEffects",
            fn = function(baseFunc, currentRun, currentRoom, currentEncounter)
                baseFunc(currentRun, currentRoom, currentEncounter)
                if currentEncounter == currentRoom.Encounter or currentEncounter == MapState.EncounterOverride then
                    if HeroHasTrait("PersistentDionysusSkipKeepsake") then
                        local traitData = GetHeroTrait("PersistentDionysusSkipKeepsake")
                        if traitData.SkipEncounterChance and traitData.SkipEncounterGrowthPerRoom then
                            Utils.PrintDebug("Increasing Dionysus Skip Chance by " .. tostring(traitData.SkipEncounterGrowthPerRoom) .. " for next encounter. Previous Chance: " .. tostring(traitData.SkipEncounterChance) .. ", New Chance: " .. tostring(math.min(1, traitData.SkipEncounterChance + traitData.SkipEncounterGrowthPerRoom)))
                            traitData.SkipEncounterChance = math.min(1, traitData.SkipEncounterChance + traitData.SkipEncounterGrowthPerRoom)
                        end
                    end
                end
            end,
        },
        {
            target = "StartRoom",
            fn = function(baseFunc, currentRun, currentRoom)
                baseFunc(currentRun, currentRoom)
                if currentRoom.BiomeStartRoom then
                    if HeroHasTrait("PersistentDionysusSkipKeepsake") then
                        local traitData = GetHeroTrait("PersistentDionysusSkipKeepsake")
                        if traitData.InitialSkipEncounterChance then
                            traitData.SkipEncounterChance = traitData.InitialSkipEncounterChance
                            Utils.PrintDebug("Resetting Dionysus Skip Chance to initial value: " .. tostring(traitData.SkipEncounterChance))
                        end
                    end
                end
            end,
        },
    },
})
