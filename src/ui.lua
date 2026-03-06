local ImGui = rom.ImGui
local Utils = adamant_Modpack

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
    ImGui.SameLine()
    ImGui.SetCursorPosX(150)
    ImGui.PushItemWidth(300)
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
    text          = {0.95, 0.95, 0.95, 1.0},  -- Crisp white
    textDisabled  = {0.45, 0.45, 0.50, 1.0},  -- Cool, silvery dark gray
    info          = {0.90, 0.75, 0.20, 1.0},  -- Bright Gold
    warning       = {0.85, 0.20, 0.25, 1.0},  -- Deep Red
}

local function DrawColoredText(color, text)
    ImGui.TextColored(color[1], color[2], color[3], color[4],text)
end

local function SetBugFixes(flag)
    for key in pairs(config.BugFixes) do
        config.BugFixes[key] = flag
    end
end

-- Smartly detects the current state based on gameplay config
local presetDefinitions = {
    AnyFear = {
        RTAMode = false,
        ForceMedea = true,
        ForceArachne = false,
        DisableArachnePity = true,
        CharybdisBehaviorAdjustment = true,
        PreventEchoScam = true,
        SurfaceStructureFix = true,
        DisableSeleneBeforeBoon = true
    },
    HighFear = {
        RTAMode = false,
        ForceMedea = true,
        ForceArachne = true,
        DisableArachnePity = false,
        CharybdisBehaviorAdjustment = true,
        PreventEchoScam = true,
        SurfaceStructureFix = true,
        DisableSeleneBeforeBoon = true
    },
    AllWeps = {
        RTAMode = true,
        ForceMedea = false,
        ForceArachne = false,
        DisableArachnePity = true,
        CharybdisBehaviorAdjustment = true,
        PreventEchoScam = true,
        SurfaceStructureFix = true,
        DisableSeleneBeforeBoon = true
    }
}

local function ApplyPreset(presetType)
    local settings = presetDefinitions[presetType]
    if settings then
        for key, value in pairs(settings) do
            config[key] = value
        end
    end
end

local function EvaluateCurrentPreset()
    for presetName, expectedSettings in pairs(presetDefinitions) do
        local isMatch = true
        
        for key, expectedValue in pairs(expectedSettings) do
            if config[key] ~= expectedValue then
                isMatch = false
                break 
            end
        end
        if isMatch then
            return presetName 
        end
    end
    
    return "Custom"
end

local function DrawMainWindow()
    local val, chg = ImGui.Checkbox("Enable Mod", config.ModEnabled)
    if chg then config.ModEnabled = val end
    if ImGui.IsItemHovered() then ImGui.SetTooltip("Toggle the entire modpack on or off.") end
    
    
    if not config.ModEnabled then    
        
        ImGui.Separator()
        DrawColoredText(colors.warning, "Mod is currently disabled.")
        return 
    end

    ImGui.Separator()

    DrawColoredText(colors.warning, "Note: Changing Presets/Checkboxes require going to main menu and return to fully apply.")
    
    ImGui.Separator()


    -- Evaluate the preset state every frame to ensure the UI never lies to the player
    local currentPreset = EvaluateCurrentPreset()

    -- ==========================================
    -- TAB BAR START
    -- ==========================================
    if ImGui.BeginTabBar("ModpackTabs") then
    
        -- TAB 1: PRESETS & LOADOUT
        if ImGui.BeginTabItem("Presets") then
            ImGui.Spacing()
            DrawColoredText(colors.text, "Select a preset to automatically configure the modpack:")
            ImGui.Spacing()

            if ImGui.RadioButton("Anyfear", currentPreset == "AnyFear") then
                ApplyPreset("AnyFear")
            end
            if ImGui.IsItemHovered() then ImGui.SetTooltip("RTA Disabled, Arachne Pity Disabled.") end

            if ImGui.RadioButton("HighFear", currentPreset == "HighFear") then
                ApplyPreset("HighFear")
            end
            if ImGui.IsItemHovered() then ImGui.SetTooltip("RTA Disabled, Arachne Spawn Forced.") end
            
            if ImGui.RadioButton("AllWeps", currentPreset == "AllWeps") then
                ApplyPreset("AllWeps")
            end
            if ImGui.IsItemHovered() then ImGui.SetTooltip("RTA Enabled, Medea/Arachne Not Forced, Arachne Pity Enabled.") end

            if ImGui.RadioButton("Custom", currentPreset == "Custom") then
                -- Does nothing on click, just acts as a visual indicator
            end
            if ImGui.IsItemHovered() then ImGui.SetTooltip("Active when run modifiers deviate from standard presets.") end

            ImGui.Separator()
            ImGui.Spacing()
            
            DrawColoredText(colors.info, "Toggle all bug fixes at once. Go to the Bug Fixes tab for individual control.")
            ImGui.Spacing()
            
            if ImGui.Button("Enable All Bug Fixes") then SetBugFixes(true) end
            ImGui.SameLine()
            if ImGui.Button("Disable All Bug Fixes") then SetBugFixes(false) end
            ImGui.Separator()
            ImGui.Spacing()

            -- DrawColoredText(colors.text, "Starting Hammers:")
            
            -- if currentPreset == "AllWeps" then
            --     DrawColoredText(colors.info, "Select the guaranteed first hammer for each weapon type.")
            --     ImGui.Spacing()
                
            --     for _, weaponKey in ipairs(Utils.weaponDrawOrder) do
            --         local displayName = Utils.weaponLabels[weaponKey] or weaponKey
            --         DrawHammerDropdown(weaponKey, displayName)
            --     end
            -- else
            --     DrawColoredText(colors.info, "Select the guaranteed first hammer for your equipped weapon.")
            --     ImGui.Spacing()
                
            --     local currentWeapon = Utils.GetEquippedWeapon()
            --     local weaponNameLabel = Utils.weaponLabels[currentWeapon] or "Unknown Weapon"
                
            --     if Utils.hammerData[currentWeapon] then
            --         DrawHammerDropdown(currentWeapon, "Equipped: " .. weaponNameLabel)
            --     end
            -- end

            
            DrawColoredText(colors.text, "Select the guaranteed first hammer for your equipped aspect.")
            ImGui.Spacing()
            
            local currentWeapon = Utils.GetEquippedAspect()
            local weaponNameLabel = Utils.aspectLabels[currentWeapon] or "Unknown Weapon"
            
            if Utils.hammerData[currentWeapon] then
                DrawHammerDropdown(currentWeapon, "Equipped: " .. weaponNameLabel)
            end
            


            ImGui.EndTabItem()
        end
        -- TAB 2: HAMMERS
        if ImGui.BeginTabItem("Hammers") then
            ImGui.Spacing()
            DrawColoredText(colors.info, "Select the guaranteed first hammer for each aspect.")
            ImGui.Spacing()
            
            for _, weaponKey in ipairs(Utils.weaponDrawOrder) do
                local weaponDisplayName = Utils.weaponLabels[weaponKey] or weaponKey
                
                if ImGui.CollapsingHeader(weaponDisplayName) then
                    
                    ImGui.Indent()
                    local aspects = Utils.WeaponAspectMapping[weaponKey]
                    if aspects then
                        for _, aspectKey in ipairs(aspects) do
                            local aspectDisplayName = Utils.aspectLabels[aspectKey] or aspectKey
                            DrawHammerDropdown(aspectKey, aspectDisplayName)
                        end
                    end
                    
                    ImGui.Unindent()
                end
            end            
            ImGui.Spacing()
            ImGui.EndTabItem()
        end

        -- TAB 3: RUN MODIFIERS
        if ImGui.BeginTabItem("Run Modifiers") then
            ImGui.Spacing()
            DrawColoredText(colors.warning, "Tweaking these settings will change your preset to 'Custom'.")
            ImGui.Spacing()
            
            local val, chg
            
            val, chg = ImGui.Checkbox("RTAMode", config.RTAMode)
            if chg then config.RTAMode = val end
            if ImGui.IsItemHovered() then ImGui.SetTooltip("Disables all combat pausing encounters for RTA runs.") end

            val, chg = ImGui.Checkbox("Force Medea Spawn", config.ForceMedea)
            if chg then config.ForceMedea = val end
            if ImGui.IsItemHovered() then ImGui.SetTooltip("Forces Medea to spawn to reduce death pity reset.") end

            val, chg = ImGui.Checkbox("Force Arachne Spawn", config.ForceArachne)
            if chg then config.ForceArachne = val end
            if ImGui.IsItemHovered() then ImGui.SetTooltip("Forces Arachne to spawn to reduce death pity reset.") end

            val, chg = ImGui.Checkbox("Disable Arachne Pity", config.DisableArachnePity)
            if chg then config.DisableArachnePity = val end
            if ImGui.IsItemHovered() then ImGui.SetTooltip("Disables Arachne Pity entirely for Anyfear runs.") end
            
            val, chg = ImGui.Checkbox("Adjust Charybdis Behavior", config.CharybdisBehaviorAdjustment)
            if chg then config.CharybdisBehaviorAdjustment = val end
            if ImGui.IsItemHovered() then ImGui.SetTooltip("At phase transition, Tentacles despawn in 1s (not 9s). Charybdis fires 6 spits instead of 8.") end

            val, chg = ImGui.Checkbox("Prevent Echo Scam", config.PreventEchoScam)
            if chg then config.PreventEchoScam = val end
            if ImGui.IsItemHovered() then ImGui.SetTooltip("Prevents Echo scam by preventing one miniboss at room 3.\nFields midshop restored as balance.") end

            val, chg = ImGui.Checkbox("Less Sucky Surface", config.SurfaceStructureFix)
            if chg then config.SurfaceStructureFix = val end
            if ImGui.IsItemHovered() then ImGui.SetTooltip("1. Thessaly Miniboss forced between rooms 2-4.\n2. Olympus midshop forced between rooms 5-7.\n3. Removes Boatacles.") end

            val, chg = ImGui.Checkbox("Disable Selene Before First Boon", config.DisableSeleneBeforeBoon)
            if chg then config.DisableSeleneBeforeBoon = val end
            if ImGui.IsItemHovered() then ImGui.SetTooltip("Prevents Selene from spawning before the first boon is obtained.") end

            ImGui.EndTabItem()
        end

        -- TAB 4: BUG FIXES
        if ImGui.BeginTabItem("Bug Fixes") then
            ImGui.Separator()
            ImGui.Spacing()

            local val, chg
            
            if ImGui.CollapsingHeader("Weapons & Attacks") then
                ImGui.Indent()
                val, chg = ImGui.Checkbox("Aspect of Selene Fix", config.BugFixes.SeleneFix)
                if chg then config.BugFixes.SeleneFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Aspect of Selene properly registers its hex so you get offered PoS directly.") end

                val, chg = ImGui.Checkbox("Extra Dose Fix", config.BugFixes.ExtraDoseFix)
                if chg then config.BugFixes.ExtraDoseFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes Extra Dose interaction with Coat 2nd punch and Dash strike.") end

                val, chg = ImGui.Checkbox("Staged Omega Fix", config.BugFixes.StagedOmegaFix)
                if chg then config.BugFixes.StagedOmegaFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes Omega Moves (Axe OAtk, Blade OSpec) not benefiting from channeling bonus.") end 

                val, chg = ImGui.Checkbox("Tidal Ring Fix", config.BugFixes.TidalRingFix)
                if chg then config.BugFixes.TidalRingFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes Tidal Ring not hitting the same mob twice with Circe staff.") end
                ImGui.Unindent()
            end

            if ImGui.CollapsingHeader("Boons & Hammers") then
                ImGui.Indent()
                val, chg = ImGui.Checkbox("Poseidon Waves Fix", config.BugFixes.PoseidonWavesFix)
                if chg then config.BugFixes.PoseidonWavesFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes Poseidon waves on Axe special and Hidden Helix Torch.") end

                val, chg = ImGui.Checkbox("Shimmering Moonshot Fix", config.BugFixes.ShimmeringFix)
                if chg then config.BugFixes.ShimmeringFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes Shimmering Moonshot not applying damage bonus to omega special.") end

                val, chg = ImGui.Checkbox("Second Stage Channeling Fix", config.BugFixes.SecondStageChannelingFix)
                if chg then config.BugFixes.SecondStageChannelingFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Removes 2nd stage channel of Glorious Disaster/Giga Moonburst, baking bonus into stage 1.") end

                val, chg = ImGui.Checkbox("Omega Cast Effects Fix", config.BugFixes.OmegaCastEffectsFix)
                if chg then config.BugFixes.OmegaCastEffectsFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes OCast moves (Prominence Flare) not counting as cast damage.") end

                val, chg = ImGui.Checkbox("Cardio Torch Fix", config.BugFixes.CardioTorchFix)
                if chg then config.BugFixes.CardioTorchFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes Cardio Gain interactions with Torch specials.") end

                val, chg = ImGui.Checkbox("Braid Fix", config.BugFixes.BraidFix)
                if chg then config.BugFixes.BraidFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes Braid of Atlas to properly buff casts.") end

                val, chg = ImGui.Checkbox("ET Fixes", config.BugFixes.ETFix)
                if chg then config.BugFixes.ETFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes ET working with Anubis by creating a 3rd OAtk field.\nFixes Anubis OAtk distance based on casting angle.") end 
                ImGui.Unindent()
            end

            if ImGui.CollapsingHeader("NPC & Encounters") then
                ImGui.Indent()
                val, chg = ImGui.Checkbox("Corrosion Fix", config.BugFixes.CorrosionFix)
                if chg then config.BugFixes.CorrosionFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes corrosion aggroing mobs on thessaly boats.") end

                val, chg = ImGui.Checkbox("Suffering Fix", config.BugFixes.SufferingFix)
                if chg then config.BugFixes.SufferingFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes Suffering on Sight not bypassing Wards vow when dealing damage.") end

                val, chg = ImGui.Checkbox("GGG Echo Fix", config.BugFixes.GGGFix)
                if chg then config.BugFixes.GGGFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Allows GGG to be offered in Jpom runs.") end

                val, chg = ImGui.Checkbox("Miniboss Encounter Fix", config.BugFixes.MiniBossEncounterFix)
                if chg then config.BugFixes.MiniBossEncounterFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes Miniboss top screen health bars not properly progressing biome depth.") end

                val, chg = ImGui.Checkbox("Familiar Delay Fix", config.BugFixes.FamiliarDelayFix)
                if chg then config.BugFixes.FamiliarDelayFix = val end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Fixes Familiars being summoned after a delay upon entering a room.") end

                ImGui.Unindent()
            end
            ImGui.EndTabItem()
        end
        
        ImGui.EndTabBar()
    end

    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Spacing()

    if ImGui.Button("Apply Changes (Experimental)") then
        -- Call whatever function you built to push the live changes here
        Utils.ApplyConfigChanges() 
    end
    
    -- Optional: Add a subtle confirmation message that appears after clicking
    if ImGui.IsItemHovered() then 
        ImGui.SetTooltip("Instantly apply all modified settings to your current run.") 
    end
    -- DrawColoredText(colors.warning, "Note: Changing Presets/Checkboxes require going to main menu and return to fully apply.")

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