local Registry = adamant_Modpack.Registry

Registry:register({
    id = "KBMEscapeAlt",
    name = "Fixing Escape Behavior for KBM",
    category = "QoLSettings",
    group = "QoL",
    tooltip = "KBM Escape will now work during boon/pom Selection, Hex selection, PoS menu, and during death sequences.",
    default = true,

    hooks = {
        {
            target = "IsPauseBlocked",
            fn = function(base)
                if SessionMapState.HandlingDeath then
                    return false
                end
                if SessionMapState.BlockPause then
                    return true
                end

                if CurrentRun ~= nil then
                    if CurrentRun.Hero.FishingStarted then
                        return true
                    end
                end

                local excludedScreens = { UpgradeChoice = true, SpellScreen = true, TalentScreen = true }
                for screenName, screen in pairs(ActiveScreens) do
                    if excludedScreens[screenName] then
                        return false
                    end
                    if screen.BlockPause then
                        return true
                    end
                end

                local blockingScreens = {
                    "Codex", "MetaUpgrade", "ShrineUpgrade", "MusicPlayer",
                    "QuestLog", "Mutator", "GhostAdmin", "AwardMenu", "RunClear",
                    "RunHistory", "GameStats", "TraitTrayScreen", "WeaponUpgradeScreen",
                    "InventoryScreen", "MarketScreen", "WeaponShop",
                    "DebugEnemySpawn", "DebugConversations",
                }
                for _, name in pairs(blockingScreens) do
                    if ActiveScreens[name] then
                        return true
                    end
                end

                return false
            end,
        },
    },
})
