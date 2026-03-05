local ImGui = rom.ImGui
local Utils = adamant_RunDirector

local hasLocalizedLabels = false

-- =============================================================================
-- LOCALIZATION BUILDER
-- =============================================================================

local function BuildLocalizedLabels()
    for weaponKey, data in pairs(Utils.hammerData) do
        data.labels = {}
        for i, internalString in ipairs(data.values) do
            if internalString == "" then
                data.labels[i] = "None (Random)"
            else
                local localizedName = GetDisplayName({Text = internalString}) 
                data.labels[i] = localizedName or internalString
            end
        end
    end
    hasLocalizedLabels = true
end

-- =============================================================================
-- UI RENDERING
-- =============================================================================

local function DrawHammerDropdown(weaponKey, displayLabel)
    local data = Utils.hammerData[weaponKey]
    if not data then return end 

    if not hasLocalizedLabels then
        BuildLocalizedLabels()
    end

    local currentId = config.FirstHammers[weaponKey] or ""
    local currentIndex = 1
    for i, val in ipairs(data.values) do
        if val == currentId then
            currentIndex = i
            break
        end
    end
    
    local currentPreview = data.labels[currentIndex] or "None (Random)"

    ImGui.PushID(weaponKey) 
    ImGui.Text(displayLabel)
    
    ImGui.PushItemWidth(250)
    if ImGui.BeginCombo("##HammerCombo", currentPreview) then
        for i, txt in ipairs(data.labels) do
            local isSelected = (i == currentIndex)
            if ImGui.Selectable(txt, isSelected) then
                if i ~= currentIndex then
                    config.FirstHammers[weaponKey] = data.values[i] 
                end
            end
        end
        ImGui.EndCombo()
    end
    ImGui.PopItemWidth()
    ImGui.PopID()
end


local colors = {
    text          = {0.95, 0.95, 0.95, 1.0}, 
    textDisabled  = {0.70, 0.70, 0.70, 1.0}, 
    info          = {0.7, 0.7, 0.07, 0.95}, 
    warning       = {0.9, 0.2, 0.0, 1.0},
}

local function DrawColoredText(color, text)
    ImGui.TextColored(color[1], color[2], color[3], color[4],text)
end

local function DrawMainWindow()
    local val, chg = ImGui.Checkbox("Enable Mod", config.ModEnabled)
    if chg then config.ModEnabled = val end
    DrawColoredText(colors.warning, "Note: Changes to checkboxes require you to go to main menu and return to fully apply.")
    
    ImGui.Separator()
    ImGui.Spacing()

    if not config.ModEnabled then
        DrawColoredText(colors.warning, "Mod is currently disabled.")
        return 
    end

    local currentWeapon = Utils.GetEquippedWeapon()
    local weaponNameLabel = Utils.weaponLabels[currentWeapon] or "Unknown Weapon"


    if Utils.hammerData[currentWeapon] then
        DrawHammerDropdown(currentWeapon, "Equipped: " .. weaponNameLabel)
    end

    ImGui.Separator()
    local val, chg = ImGui.Checkbox("RTAMode", config.RTAMode)
    if chg then config.RTAMode = val end
    DrawColoredText(colors.info, "Disables all combat pausing encounters for RTA runs.")

    ImGui.Separator()
    local open = ImGui.CollapsingHeader("Gameplay Changes")
    ImGui.Indent()
    if open then

        local val, chg = ImGui.Checkbox("Force Medea pity", config.MedeaPity)
        if chg then config.MedeaPity = val end
        DrawColoredText(colors.info, "Forces Medea to spawn to reduce death pity reset")

        local val, chg = ImGui.Checkbox("Force Arachne pity", config.ArachnePity)
        if chg then config.ArachnePity = val end
        DrawColoredText(colors.info, "Forces Arachne to spawn to reduce death pity reset")

        local val, chg = ImGui.Checkbox("Disable Arachne Pity", config.DisableArachnePity)
        if chg then config.DisableArachnePity = val end
        DrawColoredText(colors.info, "Disables Arachne Pity entirely for Anyfear runs")

        
        local val, chg = ImGui.Checkbox("Adjust Charybdis Behavior", config.CharybdisBehaviorAdjustment)
        if chg then config.CharybdisBehaviorAdjustment = val end
        DrawColoredText(colors.info, "At phase transition, Tentacles will despawn 1s instead of 9s and Charybdis will fire 6 spits down from 8.")

        local val, chg = ImGui.Checkbox("Prevent Echo Scam", config.PreventEchoScam)
        if chg then config.PreventEchoScam = val end
        DrawColoredText(colors.info, "Prevents Echo scam from happening by preventing one of the mini boss from spawning at room 3")
        DrawColoredText(colors.info, "To balance, Fields midshop has been restored and can appear instead of Echo")

        local val, chg = ImGui.Checkbox("Less Sucky Surface", config.SurfaceStructureFix)
        if chg then config.SurfaceStructureFix = val end
        DrawColoredText(colors.info, "1-Thessaly Miniboss are forced between rooms 2-4 similar to other biomes")
        DrawColoredText(colors.info, "2-Olympus midshop is now forced between rooms 5-7 similar to Oceanus midshop")
        DrawColoredText(colors.info, "3-Removes Boatacles")

        local val, chg = ImGui.Checkbox("Disable Selene Before first boon", config.DisableSeleneBeforeBoon)
        if chg then config.DisableSeleneBeforeBoon = val end
        DrawColoredText(colors.info, "Prevents Selene from spawning before the first boon is obtained.")
    end
    ImGui.Unindent()


    ImGui.Separator()

    local open = ImGui.CollapsingHeader("Bug fixes")
    ImGui.Indent()
    if open then    
        local val, chg = ImGui.Checkbox("Corrosion Fix", config.BugFixes.CorrosionFix)
        if chg then config.BugFixes.CorrosionFix = val end
        DrawColoredText(colors.info, "Fixes corrosion aggroing mobs on thessaly boats")

        local val, chg = ImGui.Checkbox("GGG Echo Fix", config.BugFixes.GGGFix)
        if chg then config.BugFixes.GGGFix = val end
        DrawColoredText(colors.info, "Allows GGG to be offered in Jpom runs")

        local val, chg = ImGui.Checkbox("Braid Fix", config.BugFixes.BraidFix)
        if chg then config.BugFixes.BraidFix = val end
        DrawColoredText(colors.info, "Fixes Braid of Atlas to properly buff casts ")

        local val, chg = ImGui.Checkbox("Miniboss Encounter Fix", config.BugFixes.MiniBossEncounterFix)
        if chg then config.BugFixes.MiniBossEncounterFix = val end
        DrawColoredText(colors.info, "Fixes Miniboss with top screen health bars which didnt properly progress biome depth")

        local val, chg = ImGui.Checkbox("Aspect of Selene Fix", config.BugFixes.SeleneFix)
        if chg then config.BugFixes.SeleneFix = val end
        DrawColoredText(colors.info, "Makes Aspect of Selene properly registers its hex so that you get offered PoS directly")

        local val, chg = ImGui.Checkbox("Extra Dose Fix", config.BugFixes.ExtraDoseFix)
        if chg then config.BugFixes.ExtraDoseFix = val end
        DrawColoredText(colors.info, "Fixes Extra Dose interaction with Coat 2nd punch and Dash strike")

        local val, chg = ImGui.Checkbox("Poseidon Waves Fix", config.BugFixes.PoseidonWavesFix)
        if chg then config.BugFixes.PoseidonWavesFix = val end
        DrawColoredText(colors.info, "Fixes Poseidon waves on Axe special and Hidden Helix Torch")
        
        local val, chg = ImGui.Checkbox("Tidal Ring Fix", config.BugFixes.TidalRingFix)
        if chg then config.BugFixes.TidalRingFix = val end
        DrawColoredText(colors.info, "Fixes Tidal Ring not hitting the same mob twice with Circe staff")

        local val, chg = ImGui.Checkbox("Shimmering Moonshot Fix", config.BugFixes.ShimmeringFix)
        if chg then config.BugFixes.ShimmeringFix = val end
        DrawColoredText(colors.info, "Fixes Shimmering Moonshot not applying its damage bonus to omega special")

        local val, chg = ImGui.Checkbox("Staged Omega Fix", config.BugFixes.StagedOmegaFix)
        if chg then config.BugFixes.StagedOmegaFix = val end
        DrawColoredText(colors.info, "Fixes Some Omega Moves like Axe OAtk and Blade OSpec not benefiting from channeling bonus") 
        

    end
    ImGui.Unindent()    
    local open = ImGui.CollapsingHeader("More Bug fixes")
    ImGui.Indent()
    if open then  
        local val, chg = ImGui.Checkbox("ET Fixes", config.BugFixes.ETFix)
        if chg then config.BugFixes.ETFix = val end
        DrawColoredText(colors.info, "Fixes ET to work with Anubis by creating a third OAtk field") 
        DrawColoredText(colors.info, "Fixes multiple Anubis O Atk looking at different distance depending on casting angle")

        local val, chg = ImGui.Checkbox("Second Stage Channeling Fix", config.BugFixes.SecondStageChannelingFix)
        if chg then config.BugFixes.SecondStageChannelingFix = val end
        DrawColoredText(colors.info, "Removes the second stage channel of glorious disaster and Giga moonburst and bakes the bonus into the first stage")

        local val, chg = ImGui.Checkbox("Omega Cast Effects Fix", config.BugFixes.OmegaCastEffectsFix)
        if chg then config.BugFixes.OmegaCastEffectsFix = val end
        DrawColoredText(colors.info, "Fixes OCast moves like Prominence Flare not counting as cast damage and thus not benefiting from cast damage bonuses")

        local val, chg = ImGui.Checkbox("Cardio Torch Fix", config.BugFixes.CardioTorchFix)
        if chg then config.BugFixes.CardioTorchFix = val end
        DrawColoredText(colors.info, "Fixes Cardio Gain interactions with Torch specials")

        local val, chg = ImGui.Checkbox("Familiar Delay Fix", config.BugFixes.FamiliarDelayFix)
        if chg then config.BugFixes.FamiliarDelayFix = val end
        DrawColoredText(colors.info, "Fixes Familiars being summoned after a delay when you enter a room")

        local val, chg = ImGui.Checkbox("Suffering Fix", config.BugFixes.SufferingFix)
        if chg then config.BugFixes.SufferingFix = val end
        DrawColoredText(colors.info, "Fixes Suffering on Sight not bypassing Wards vow when dealing its damage")

    end
    ImGui.Unindent()
end

-- =============================================================================
-- REGISTRATION
-- =============================================================================


rom.gui.add_imgui(function()
    if ImGui.Begin("Modpack") then
        DrawMainWindow()
        ImGui.End()
    end
end)


rom.gui.add_to_menu_bar(function()
    if ImGui.BeginMenu("Modpack") then
        DrawMainWindow()
        ImGui.EndMenu()
    end
end)