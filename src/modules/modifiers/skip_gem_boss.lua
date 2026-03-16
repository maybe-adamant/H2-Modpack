local Utils = adamant_Modpack
local Registry = Utils.Registry

Registry:register({
    id = "SkipGemBossReward",
    name = "Skip Gem Boss Reward",
    category = "RunModifiers",
    group = "World & Combat Tweaks",
    tooltip = "Bosses no longer drop gem rewards when using Grave Thirst.",
    default = false,

    hooks = {
        {
            target = "UnusedWeaponBonusDropGems",
            fn = function(baseFunc, source, args)
                Utils.PrintDebug("UnusedWeaponBonusDropGems called after boss. Skipping gem rewards.")
                return
            end,
        },
    },
})
