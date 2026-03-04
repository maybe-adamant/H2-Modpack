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

local function DrawMainWindow()
    local val, chg = ImGui.Checkbox("Enable Mod", config.ModEnabled)
    if chg then config.ModEnabled = val end
    ImGui.Text("Note: Changes to checkboxes require you to go to main menu and return to fully apply.")
    
    ImGui.Separator()
    ImGui.Spacing()

    if not config.ModEnabled then
        ImGui.TextDisabled("Mod is currently disabled.")
        return 
    end

    local currentWeapon = Utils.GetEquippedWeapon()
    local weaponNameLabel = Utils.weaponLabels[currentWeapon] or "Unknown Weapon"


    if Utils.hammerData[currentWeapon] then
        DrawHammerDropdown(currentWeapon, "Equipped: " .. weaponNameLabel)
    end

    ImGui.Separator()
    local val, chg = ImGui.Checkbox("Force Medea pity/Disable Arachne pity", config.ArachneAndMedeaPity)
    if chg then config.ArachneAndMedeaPity = val end
    ImGui.Text("Forces Medea and disables Arachne pity.")

    -- ImGui.Separator()
    -- local val, chg = ImGui.Checkbox("Disable Charybdis", config.DisableCharybdis)
    -- if chg then config.DisableCharybdis = val end
    -- ImGui.Text("Replace Charybdis room with the pirate miniboss (miniboss chance unchanged).")
    
    -- ImGui.Separator()
    local val, chg = ImGui.Checkbox("Adjust Charybdis Behavior", config.CharybdisBehaviorAdjustment)
    if chg then config.CharybdisBehaviorAdjustment = val end
    ImGui.Text("At phase transition, Tentacles will despawn 1s instead of 9s and Charybdis will fire 6 spits down from 8.")

    -- ImGui.Separator()
    local val, chg = ImGui.Checkbox("Prevent Echo Scam", config.PreventEchoScam)
    if chg then config.PreventEchoScam = val end
    ImGui.Text("Prevents Echo scam from happening by preventing one of the mini boss from spawning at room 3")

    -- ImGui.Separator()
    local val, chg = ImGui.Checkbox("Disable Selene Before first boon", config.DisableSeleneBeforeBoon)
    if chg then config.DisableSeleneBeforeBoon = val end
    ImGui.Text("Prevents Selene from spawning before the first boon is obtained.")

    ImGui.Separator()

    local open = ImGui.CollapsingHeader("Bug fixes")
    ImGui.Indent()
    if open then    
        local val, chg = ImGui.Checkbox("Corrosion Fix", config.BugFixes.CorrosionFix)
        if chg then config.BugFixes.CorrosionFix = val end
        ImGui.TextDisabled("Fixes corrosion aggroing mobs on thessaly boats")

        local val, chg = ImGui.Checkbox("GGG Echo Fix", config.BugFixes.GGGFix)
        if chg then config.BugFixes.GGGFix = val end
        ImGui.TextDisabled("Allows GGG to be offered in Jpom runs")

        local val, chg = ImGui.Checkbox("Braid Fix", config.BugFixes.BraidFix)
        if chg then config.BugFixes.BraidFix = val end
        ImGui.TextDisabled("Fixes Braid of Atlas to properly buff casts ")

        local val, chg = ImGui.Checkbox("Aspect of Selene Fix", config.BugFixes.SeleneFix)
        if chg then config.BugFixes.SeleneFix = val end
        ImGui.TextDisabled("Makes Aspect of Selene properly registers its hex so that you get offered PoS directly")

        local val, chg = ImGui.Checkbox("Extra Dose Fix", config.BugFixes.ExtraDoseFix)
        if chg then config.BugFixes.ExtraDoseFix = val end
        ImGui.TextDisabled("Fixes Extra Dose interaction with Coat 2nd punch and Dash strike")

        local val, chg = ImGui.Checkbox("Poseidon Waves Fix", config.BugFixes.PoseidonWavesFix)
        if chg then config.BugFixes.PoseidonWavesFix = val end
        ImGui.TextDisabled("Fixes Poseidon waves on Axe special and Hidden Helix Torch")
        
        local val, chg = ImGui.Checkbox("Tidal Ring Fix", config.BugFixes.TidalRingFix)
        if chg then config.BugFixes.TidalRingFix = val end
        ImGui.TextDisabled("Fixes Tidal Ring not hitting the same mob twice with Circe staff")

        local val, chg = ImGui.Checkbox("Shimmering Moonshot Fix", config.BugFixes.ShimmeringFix)
        if chg then config.BugFixes.ShimmeringFix = val end
        ImGui.TextDisabled("Fixes Shimmering Moonshot not applying its damage bonus to omega special")

        local val, chg = ImGui.Checkbox("Staged Omega Fix", config.BugFixes.StagedOmegaFix)
        if chg then config.BugFixes.StagedOmegaFix = val end
        ImGui.TextDisabled("Fixes Some Omega Moves like Axe OAtk and Blade OSpec not benefiting from channeling bonus") 

        local val, chg = ImGui.Checkbox("ET Fixes", config.BugFixes.ETFix)
        if chg then config.BugFixes.ETFix = val end
        ImGui.TextDisabled("Fixes ET to work with Anubis by creating a third OAtk field") 
        ImGui.TextDisabled("Fixes ET to work with Supay by by doubling its OAtk firerate while active") 
    end
    ImGui.Unindent()    
    local open = ImGui.CollapsingHeader("More Bug fixes")
    ImGui.Indent()
    if open then  
        local val, chg = ImGui.Checkbox("Second Stage Channeling Fix", config.BugFixes.SecondStageChannelingFix)
        if chg then config.BugFixes.SecondStageChannelingFix = val end
        ImGui.TextDisabled("Removes the second stage channel of glorious disaster and Giga moonburst and bakes the bonus into the first stage")

        local val, chg = ImGui.Checkbox("Omega Cast Effects Fix", config.BugFixes.OmegaCastEffectsFix)
        if chg then config.BugFixes.OmegaCastEffectsFix = val end
        ImGui.TextDisabled("Fixes OCast moves like Prominence Flare not counting as cast damage and thus not benefiting from cast damage bonuses")

        local val, chg = ImGui.Checkbox("Cardio Torch Fix", config.BugFixes.CardioTorchFix)
        if chg then config.BugFixes.CardioTorchFix = val end
        ImGui.TextDisabled("Fixes Cardio Gain interactions with Torch specials")

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