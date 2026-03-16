local Utils = adamant_Modpack
local Registry = Utils.Registry

Registry:register({
    id = "SeleneFix",
    name = "Aspect of Selene Fix",
    category = "BugFixes",
    group = "Weapons & Attacks",
    tooltip = "Aspect of Selene properly registers its hex so you get offered PoS directly. Skyfall is full moonglow",
    default = true,

    apply = function(AddToBackup)
        AddToBackup(NamedRequirementsData, "SpellDropRequirements")
        local seleneReq = {
            PathFalse = { "CurrentRun", "Hero", "TraitDictionary", "SuitHexAspect" }
        }
        if not Utils.ListContainsEquivalent(NamedRequirementsData.SpellDropRequirements, seleneReq) then
            table.insert(NamedRequirementsData.SpellDropRequirements, seleneReq)
        end
    end,

    hooks = {
        {
            target = "StartNewRun",
            fn = function(baseFunc, prevRun, args)
                local currentRun = baseFunc(prevRun, args)
                if HeroHasTrait("SuitHexAspect") then
                    Utils.PrintDebug("Starting run with Selene Aspect - granting Selene's Boon")
                    RecordUse(nil, "SpellDrop")
                end
                return currentRun
            end,
        },
        {
            target = "SpawnRoomReward",
            fn = function(base, eventSource, args)
                if HeroHasTrait("SuitHexAspect") and HeroHasTrait("SpellTalentKeepsake") and game.CurrentRun.CurrentRoom.BiomeStartRoom then
                    args = args or {}
                    if args.WaitUntilPickup then
                        args.RewardOverride = "TalentDrop"
                        args.LootName = nil
                        Utils.PrintDebug("Starting run with Selene Aspect and Moonbeam - granting Path of Stars Directly")
                    end
                end
                return base(eventSource, args)
            end,
        },
    },
})
