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
        -- rom.log.warning(argTable.Name)
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
        local hasChoice, _ = string.find(textLines.PrePortraitExitFunctionName, 'Choice')
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

local HAMMER_BITS = 5

local function PackChunks(chunks, chunk, bit)
    if bit > 0 then table.insert(chunks, chunk) end
    local parts = {}
    for _, c in ipairs(chunks) do
        table.insert(parts, EncodeBase62(c))
    end
    if #parts == 0 then return "0" end
    return table.concat(parts, ".")
end

local function GetConfigHash(source)
    local runMod = source and source.RunModifiers or config.RunModifiers
    local qol = source and source.QoLSettings or config.QoLSettings
    local bugs = source and source.BugFixes or config.BugFixes
    local hammers = source and source.FirstHammers or config.FirstHammers

    local chunks = {}
    local chunk = 0
    local bit = 0

    local function addBits(value, numBits)
        for b = 0, numBits - 1 do
            if math.floor(value / (2 ^ b)) % 2 == 1 then
                chunk = chunk + (2 ^ bit)
            end
            bit = bit + 1
            if bit >= CHUNK_BITS then
                table.insert(chunks, chunk)
                chunk = 0
                bit = 0
            end
        end
    end

    -- Boolean flags
    for _, category in ipairs(Utils.runModifierLayout) do
        for _, item in ipairs(category.Items) do
            addBits(runMod[item.Key] and 1 or 0, 1)
        end
    end
    for _, category in ipairs(Utils.qolSettingsLayout) do
        for _, item in ipairs(category.Items) do
            addBits(qol[item.Key] and 1 or 0, 1)
        end
    end
    for _, category in ipairs(Utils.bugFixLayout) do
        for _, item in ipairs(category.Items) do
            addBits(bugs[item.Key] and 1 or 0, 1)
        end
    end

    -- Flush partial bool chunk so boolHash is a clean prefix of fullHash
    if bit > 0 then
        table.insert(chunks, chunk)
        chunk = 0
        bit = 0
    end
    local boolHash = PackChunks(chunks, 0, 0)

    -- Hammer indices
    for _, aspectName in ipairs(Utils.aspectDrawOrder) do
        local data = Utils.hammerData[aspectName]
        local selected = hammers[aspectName] or ""
        local idx = 0
        if data then
            for i, val in ipairs(data.values) do
                if val == selected then
                    idx = i - 1
                    break
                end
            end
        end
        addBits(idx, HAMMER_BITS)
    end

    local fullHash = PackChunks(chunks, chunk, bit)
    return fullHash, boolHash
end

local function DecodeBase62(str)
    local n = 0
    for i = 1, #str do
        local c = string.sub(str, i, i)
        local idx = string.find(BASE62, c, 1, true)
        if not idx then return nil end
        n = n * 62 + (idx - 1)
    end
    return n
end

function Utils.ApplyConfigHash(hash, target)
    if not hash or hash == "" then return false end

    -- Split on "." into chunks and decode each from Base62
    local chunks = {}
    for part in string.gmatch(hash, "[^%.]+") do
        local decoded = DecodeBase62(part)
        if not decoded then return false end
        table.insert(chunks, decoded)
    end
    if #chunks == 0 then return false end

    local runMod = target and target.RunModifiers or config.RunModifiers
    local qol = target and target.QoLSettings or config.QoLSettings
    local bugs = target and target.BugFixes or config.BugFixes
    local hammers = target and target.FirstHammers or config.FirstHammers

    local chunkIdx = 1
    local chunk = chunks[1]
    local bit = 0

    local function readBits(numBits)
        local val = 0
        for b = 0, numBits - 1 do
            if chunkIdx <= #chunks then
                if math.floor(chunk / (2 ^ bit)) % 2 == 1 then
                    val = val + (2 ^ b)
                end
                bit = bit + 1
                if bit >= CHUNK_BITS then
                    chunkIdx = chunkIdx + 1
                    chunk = chunks[chunkIdx] or 0
                    bit = 0
                end
            end
        end
        return val
    end

    -- Boolean flags
    for _, category in ipairs(Utils.runModifierLayout) do
        for _, item in ipairs(category.Items) do
            runMod[item.Key] = readBits(1) == 1
        end
    end
    for _, category in ipairs(Utils.qolSettingsLayout) do
        for _, item in ipairs(category.Items) do
            qol[item.Key] = readBits(1) == 1
        end
    end
    for _, category in ipairs(Utils.bugFixLayout) do
        for _, item in ipairs(category.Items) do
            bugs[item.Key] = readBits(1) == 1
        end
    end

    -- Skip remaining bits in the last bool chunk (mirrors encoder flush)
    if bit > 0 then
        chunkIdx = chunkIdx + 1
        chunk = chunks[chunkIdx] or 0
        bit = 0
    end

    -- Hammer indices (only if hash has enough data)
    if chunkIdx <= #chunks then
        for _, aspectName in ipairs(Utils.aspectDrawOrder) do
            local data = Utils.hammerData[aspectName]
            local idx = readBits(HAMMER_BITS)
            if data and idx < #data.values then
                hammers[aspectName] = data.values[idx + 1]
            end
        end
    end

    if not target then
        Utils.UpdateHash()
    end
    return true
end

local _, initBoolHash = GetConfigHash()
local currentHash = config.ModEnabled and initBoolHash or ""
local displayedHash = nil

ScreenData.HUD.ComponentData.ModpackMark = {
    RightOffset = 20,
    Y = 200,
    TextArgs = {
        Text = "",
        Font = "MonospaceTypewriterBold",
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

function Utils.GetConfigHash(source)
    local fullHash, boolHash = GetConfigHash(source)
    return fullHash, boolHash
end

function Utils.UpdateHash()
    local _, boolHash = GetConfigHash()
    currentHash = boolHash
    UpdateModMark()
end

function Utils.SetModMarker(enabled)
    if enabled then
        local _, boolHash = GetConfigHash()
        currentHash = boolHash
    else
        currentHash = ""
    end
    displayedHash = nil
    UpdateModMark()
end


-- =============================================================================
-- KBM Pause Blocking
-- =============================================================================

modutil.mod.Path.Wrap("IsPauseBlocked", function(base)
    if not config.ModEnabled or not config.QoLSettings.KBMEscapeAlt then
        return base()
    end
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
    for screenName, screen in pairs( ActiveScreens ) do
        if excludedScreens[screenName] then
            return false
        end
        if screen.BlockPause then
            return true
        end
    end

	-- @deprecated Use BlockPause value in ScreenData for above
	local blockingScreens =
	{
		"Codex", "MetaUpgrade", "ShrineUpgrade", "MusicPlayer", 
        "QuestLog", "Mutator", "GhostAdmin", "AwardMenu", "RunClear", 
        "RunHistory", "GameStats", "TraitTrayScreen", "WeaponUpgradeScreen",
		"InventoryScreen", "MarketScreen", "WeaponShop",
		"DebugEnemySpawn", "DebugConversations",
	}
	for k, name in pairs( blockingScreens ) do
		if ActiveScreens[name] then
			return true
		end
	end

	return false

end)