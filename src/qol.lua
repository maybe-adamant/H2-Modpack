local Utils = adamant_Modpack

-- =============================================================================
-- Cutscene & Dialogue Skipping
-- =============================================================================
modutil.mod.Path.Wrap("EndEarlyAccessPresentation", function(baseFunc)
    if not config.ModEnabled or not config.QoLSettings.RunEndCutscene then
        return baseFunc()
    end

    AddInputBlock({ Name = "EndEarlyAccessPresentation" })
    SetPlayerInvulnerable("EndEarlyAccessPresentation")

    CurrentRun.Hero.Mute = true
    CurrentRun.ActiveBiomeTimer = false
    ToggleCombatControl(CombatControlsDefaults, false, "EarlyAccessPresentation")

    wait(0.1)
    StopAmbientSound({ All = true })
    SetAudioEffectState({ Name = "Reverb", Value = 1.5 })
    EndAmbience(0.5)
    EndAllBiomeStates()
    FadeOut({ Duration = 0.375, Color = Color.Black })

    -- first production / early access
    EndBiomeRecords()
    RecordRunCleared()

    -- destroy the player / back to DeathArea
    SetPlayerVulnerable("EndEarlyAccessPresentation")
    RemoveInputBlock({ Name = "EndEarlyAccessPresentation" })
    ToggleCombatControl(CombatControlsDefaults, true, "EarlyAccessPresentation")

    CurrentRun.Hero.Mute = false
    thread(Kill, CurrentRun.Hero)
    wait(0.15)

    FadeIn({ Duration = 0.5 })
end)

modutil.mod.Path.Context.Wrap("DeathPresentation", function()
    modutil.mod.Path.Wrap("wait", function(base, duration, tag, persist)
        if not config.ModEnabled or not config.QoLSettings.DeathCutScene then
            return base(duration, tag, persist)
        end
        return
    end)
end)

modutil.mod.Path.Context.Wrap("KillHero", function(base, victim, triggerArgs)
    modutil.mod.Path.Wrap("LoadMap", function(base, argTable)
        if not config.ModEnabled or not config.QoLSettings.SpawnInTrainingGrounds then
            base(argTable)
            return
        end
        rom.log.warning(argTable.Name)
        if argTable.Name == "Hub_Main" then -- Realistically we don't want to accidentally break any other cutscenes (mini mel)
            argTable.Name = "Hub_PreRun"
        end
        base(argTable)
    end)
end)

modutil.mod.Path.Wrap("PlayTextLines", function(base, source, textLines, args)
    if not config.ModEnabled or not config.QoLSettings.AutoSkipDialogue then
        return base(source, textLines, args)
    end
    -- current not in a Run
    if CurrentRun.Hero.IsDead then
        return base(source, textLines, args)
    end

    -- some encounters have ```textLines`` empty
    -- like after Hecate boss fight
    if not textLines then
        return
    end

    -- TODO: maybe this could be a var in config, 
    -- like if its a mainStory line u dont wanna skip
    -- but in general i think ppl wanna trigger main lines
    if textLines.StatusAnimation == 'StatusIconWantsToTalk' then
        return base(source, textLines, args)
    end

    if textLines.PrePortraitExitFunctionName then
        -- special NPCs has a choice exit function
        hasChoice, _ = string.find(textLines.PrePortraitExitFunctionName, 'Choice')
        if hasChoice then
            return base(source, textLines, args)
        end
    end
    
    -- skips text lines for everyone else
    return

end)


-- =============================================================================
-- Modded Mark Application
-- =============================================================================
local BASE62 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
local CHUNK_BITS = 30 -- safe margin under 32-bit integer limit

local function EncodeBase62(n)
    if n == 0 then return "0" end
    local result = ""
    while n > 0 do
        local idx = (n % 62) + 1
        result = string.sub(BASE62, idx, idx) .. result
        n = math.floor(n / 62)
    end
    return result
end

local function GetConfigHash()
    local chunks = {}
    local chunk = 0
    local bit = 0
    local function addFlag(enabled)
        if enabled then chunk = chunk + (2 ^ bit) end
        bit = bit + 1
        if bit >= CHUNK_BITS then
            table.insert(chunks, chunk)
            chunk = 0
            bit = 0
        end
    end
    for _, category in ipairs(Utils.runModifierLayout) do
        for _, item in ipairs(category.Items) do
            addFlag(config.RunModifiers[item.Key])
        end
    end
    for _, category in ipairs(Utils.qolSettingsLayout) do
        for _, item in ipairs(category.Items) do
            addFlag(config.QoLSettings[item.Key])
        end
    end
    for _, category in ipairs(Utils.bugFixLayout) do
        for _, item in ipairs(category.Items) do
            addFlag(config.BugFixes[item.Key])
        end
    end
    if bit > 0 then table.insert(chunks, chunk) end

    local parts = {}
    for _, c in ipairs(chunks) do
        table.insert(parts, EncodeBase62(c))
    end
    if #parts == 0 then return "0" end
    return table.concat(parts, ".")
end

local currentHash = config.ModEnabled and GetConfigHash() or ""
local displayedHash = nil

-- Inject mod mark into the HUD so it is created/destroyed automatically on every room load
ScreenData.HUD.ComponentData.ModpackMark = {
    RightOffset = 20,
    Y = 200,
    TextArgs = {
        Text = "",
        Font = "P22UndergroundSCMedium",
        FontSize = 18,
        Color = Color.White,
        ShadowRed = 0.1, ShadowBlue = 0.1, ShadowGreen = 0.1,
        OutlineColor = {0.113, 0.113, 0.113, 1}, OutlineThickness = 2,
        ShadowAlpha = 1.0, ShadowBlur = 1, ShadowOffset = {0, 4},
        Justification = "Right",
        VerticalJustification = "Top",
        DataProperties = { OpacityWithOwner = true },
    },
}


local function UpdateModMark()
    if not HUDScreen or not HUDScreen.Components.ModpackMark then return end
    if currentHash == displayedHash then return end

    if currentHash == "" then
        ModifyTextBox({ Id = HUDScreen.Components.ModpackMark.Id, ClearText = true })
    else
        ModifyTextBox({ Id = HUDScreen.Components.ModpackMark.Id, Text = currentHash })
    end
    displayedHash = currentHash
end

local function ShowDepthCounter()
    local screen = { Name = "RoomCount", Components = {} }
    screen.ComponentData = {
        RoomCount = DeepCopyTable(ScreenData.TraitTrayScreen.ComponentData.RoomCount)
    }
    CreateScreenFromData(screen, screen.ComponentData)
end

modutil.mod.Path.Wrap("ShowHealthUI", function(base)
    base()
    if config.ModEnabled then
        displayedHash = nil  -- HUD was recreated, force update
        UpdateModMark()
        if config.QoLSettings.AlwaysShowLocation then
            ShowDepthCounter()
        end
    end
end)

function Utils.UpdateHash()
    currentHash = GetConfigHash()
    UpdateModMark()
end

function Utils.SetModMarker(enabled)
    currentHash = enabled and GetConfigHash() or ""
    print("Modpack " .. (enabled and "enabled" or "disabled") .. ". Current config hash: " .. currentHash)
    displayedHash = nil
    UpdateModMark()
end

