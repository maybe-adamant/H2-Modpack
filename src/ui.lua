local ui = rom.ImGui
local uiCol = rom.ImGuiCol

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

local colors = {
    -- Semantic colors (for DrawColoredText)
    text          = {0.92, 0.90, 0.95, 1.0},  -- Lavender white
    textDisabled  = {0.45, 0.40, 0.55, 1.0},  -- Muted purple-gray
    info          = {0.90, 0.75, 0.20, 1.0},  -- Bright Gold
    warning       = {0.85, 0.20, 0.25, 1.0},  -- Deep Red
    success       = {0.30, 0.85, 0.55, 1.0},  -- Emerald green (softer against purple)
    error         = {0.90, 0.35, 0.50, 1.0},  -- Rose-pink (distinct from warning, fits purple)
    mixed         = {0.30, 0.70, 0.90, 1.0},  -- Sky Blue

    -- Theme colors (for PushTheme)
    windowBg      = {0.08, 0.06, 0.12, 0.95}, -- Deep violet-black
    childBg       = {0.10, 0.08, 0.15, 0.90}, -- Slightly lighter violet

    header        = {0.28, 0.18, 0.45, 1.0},  -- Rich purple
    headerHover   = {0.38, 0.25, 0.58, 1.0},  -- Lighter purple
    headerActive  = {0.45, 0.30, 0.65, 1.0},  -- Bright purple

    button        = {0.30, 0.20, 0.48, 1.0},  -- Purple button
    buttonHover   = {0.40, 0.28, 0.60, 1.0},  -- Lighter on hover
    buttonActive  = {0.50, 0.35, 0.70, 1.0},  -- Brightest on click

    frameBg       = {0.14, 0.10, 0.22, 1.0},  -- Dark purple input bg
    frameBgHover  = {0.20, 0.15, 0.30, 1.0},  -- Slightly lit
    frameBgActive = {0.25, 0.18, 0.38, 1.0},  -- Active input
    checkMark     = {0.75, 0.55, 1.00, 1.0},  -- Bright lilac checkmark

    tab           = {0.18, 0.12, 0.28, 1.0},  -- Inactive tab
    tabHover      = {0.35, 0.22, 0.52, 1.0},  -- Hovered tab
    tabActive     = {0.40, 0.28, 0.60, 1.0},  -- Selected tab

    separator     = {0.30, 0.20, 0.45, 0.6},  -- Soft purple line
    border        = {0.25, 0.18, 0.38, 0.5},  -- Subtle purple border
}

local ImGuiTreeNodeFlags = {
    None = 0,
    Selected = 1,
    Framed = 2,
    AllowItemOverlap = 4,
    NoTreePushOnOpen = 8,
    NoAutoArrowOnOpen = 16,
    DefaultOpen = 32,
    OpenOnDoubleClick = 64
}


local presetOrder = Utils.presetOrder
local presetDefinitions = Utils.presetDefinitions
local bugFixLayout = Utils.bugFixLayout
local runModifierLayout = Utils.runModifierLayout
local qolSettingsLayout = Utils.qolSettingsLayout

local function DrawColoredText(color, text)
    ui.TextColored(color[1], color[2], color[3], color[4], text)
end

local function PushTextColor(color)
    ui.PushStyleColor(uiCol.Text, color[1], color[2], color[3], color[4])
end

local THEME_COLOR_COUNT = 20
local function PushTheme()
    local push = ui.PushStyleColor

    push(uiCol.Text,            table.unpack(colors.text))
    push(uiCol.TextDisabled,    table.unpack(colors.textDisabled))
    push(uiCol.WindowBg,        table.unpack(colors.windowBg))
    push(uiCol.ChildBg,         table.unpack(colors.childBg))

    push(uiCol.Header,          table.unpack(colors.header))
    push(uiCol.HeaderHovered,   table.unpack(colors.headerHover))
    push(uiCol.HeaderActive,    table.unpack(colors.headerActive))

    push(uiCol.Button,          table.unpack(colors.button))
    push(uiCol.ButtonHovered,   table.unpack(colors.buttonHover))
    push(uiCol.ButtonActive,    table.unpack(colors.buttonActive))

    push(uiCol.FrameBg,         table.unpack(colors.frameBg))
    push(uiCol.FrameBgHovered,  table.unpack(colors.frameBgHover))
    push(uiCol.FrameBgActive,   table.unpack(colors.frameBgActive))
    push(uiCol.CheckMark,       table.unpack(colors.checkMark))

    push(uiCol.Tab,             table.unpack(colors.tab))
    push(uiCol.TabHovered,      table.unpack(colors.tabHover))
    push(uiCol.TabActive,       table.unpack(colors.tabActive))

    push(uiCol.Separator,       table.unpack(colors.separator))
    push(uiCol.Border,          table.unpack(colors.border))
    push(uiCol.TitleBgActive,   table.unpack(colors.header))
end

local function PopTheme()
    ui.PopStyleColor(THEME_COLOR_COUNT)
end

-- =============================================================================
-- DIRTY STATE TRACKING
-- =============================================================================
local appliedSnapshot = {}
local hasPendingChanges = false
local cachedPreset = nil

local function InvalidatePresetCache()
    cachedPreset = nil
end

local function GetLayoutConfig(layout)
    if layout == bugFixLayout then return config.BugFixes end
    if layout == runModifierLayout then return config.RunModifiers end
    if layout == qolSettingsLayout then return config.QoLSettings end
    return config
end

local function SnapshotAppliedState()
    appliedSnapshot = {}
    for _, layout in ipairs({ runModifierLayout, bugFixLayout, qolSettingsLayout }) do
        local targetConfig = GetLayoutConfig(layout)
        for _, category in ipairs(layout) do
            for _, item in ipairs(category.Items) do
                if item.RequiresApply then
                    appliedSnapshot[layout] = appliedSnapshot[layout] or {}
                    appliedSnapshot[layout][item.Key] = targetConfig[item.Key]
                end
            end
        end
    end
end

local function CheckForPendingChanges()
    for _, layout in ipairs({ runModifierLayout, bugFixLayout, qolSettingsLayout }) do
        local snap = appliedSnapshot[layout]
        if not snap then return true end
        local targetConfig = GetLayoutConfig(layout)
        for key, savedVal in pairs(snap) do
            if targetConfig[key] ~= savedVal then
                return true
            end
        end
    end
    return false
end

-- Take initial snapshot so toggling back to starting state shows clean
SnapshotAppliedState()

-- =============================================================================
-- PRESET EVALUATION & APPLICATION
-- =============================================================================

local function ApplyPreset(presetType)
    local settings = presetDefinitions[presetType]
    if settings then
        for key, value in pairs(settings) do
            if key ~= "tooltip" then
                if type(value) == "table" and type(config[key]) == "table" then
                    for k, v in pairs(value) do
                        config[key][k] = v
                    end
                else
                    config[key] = value
                end
            end
        end
        InvalidatePresetCache()
        hasPendingChanges = CheckForPendingChanges()
    end
end

local function EvaluateCurrentPreset()
    if cachedPreset ~= nil then return cachedPreset end

    local result = "Custom"
    for _, presetName in ipairs(presetOrder) do
        local expectedSettings = presetDefinitions[presetName]
        local isMatch = true

        for key, expectedValue in pairs(expectedSettings) do
            if key ~= "tooltip" then
                if type(expectedValue) == "table" and type(config[key]) == "table" then
                    for k, v in pairs(expectedValue) do
                        if config[key][k] ~= v then
                            isMatch = false
                            break
                        end
                    end
                elseif config[key] ~= expectedValue then
                    isMatch = false
                end
            end
            if not isMatch then break end
        end
        if isMatch then
            result = presetName
            break
        end
    end

    cachedPreset = result
    Utils.UpdateHash()
    return cachedPreset
end

-- =============================================================================
-- BUG FIX MANAGEMENT
-- =============================================================================
local function SetBugFixes(flag)
    for key in pairs(config.BugFixes) do
        config.BugFixes[key] = flag
    end
    InvalidatePresetCache()
    hasPendingChanges = CheckForPendingChanges()
end

local function GetBugFixStatus()
    local hasEnabled = false
    local hasDisabled = false

    for key, state in pairs(config.BugFixes) do
        if state then
            hasEnabled = true
        else
            hasDisabled = true
        end
    end

    if hasEnabled and not hasDisabled then
        return "All Enabled", colors.success
    elseif hasDisabled and not hasEnabled then
        return "All Disabled", colors.error
    else
        return "Mixed Configuration", colors.mixed
    end
end

-- =============================================================================
-- HAMMER SELECTION
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

    ui.PushID(weaponKey)
    ui.Text(displayLabel)
    ui.SameLine()
    ui.SetCursorPosX(ui.GetWindowWidth() * 0.25)
    ui.PushItemWidth(ui.GetWindowWidth() * 0.4)
    if ui.BeginCombo("##HammerCombo", currentPreview) then
        for i, txt in ipairs(data.labels) do
            local isSelected = (i == currentIndex)
            if ui.Selectable(txt, isSelected) then
                if i ~= currentIndex then
                    config.FirstHammers[weaponKey] = data.values[i]
                end
            end
        end
        ui.EndCombo()
    end
    ui.PopItemWidth()
    ui.PopID()
end

-- =============================================================================
-- GENERIC TAB CONTENT RENDERER
-- =============================================================================
local function DrawCheckboxGroup(layoutData, targetConfig)
    for _, category in ipairs(layoutData) do
        PushTextColor(colors.info)
        local collapsingHeader = ui.CollapsingHeader(category.Header, ImGuiTreeNodeFlags.DefaultOpen)
        ui.PopStyleColor()
        if collapsingHeader then
            ui.Indent()

            for _, itemData in ipairs(category.Items) do
                local currentVal = targetConfig[itemData.Key]
                local val, chg = ui.Checkbox(itemData.Name, currentVal)

                if chg then
                    targetConfig[itemData.Key] = val
                    InvalidatePresetCache()
                    if itemData.RequiresApply then
                        hasPendingChanges = CheckForPendingChanges()
                    end
                end

                if ui.IsItemHovered() and itemData.Tooltip and itemData.Tooltip ~= "" then
                    ui.SetTooltip(itemData.Tooltip)
                end
            end

            ui.Unindent()
        end
        ui.Spacing()
    end
end

local function DrawMainWindow()
    local val, chg = ui.Checkbox("Enable Mod", config.ModEnabled)
    if chg then
        config.ModEnabled = val
        Utils.ApplyConfigChanges()
        SnapshotAppliedState()
        hasPendingChanges = false
        Utils.SetModMarker(val)
    end
    if ui.IsItemHovered() then ui.SetTooltip("Toggle the entire modpack on or off.") end

    if not config.ModEnabled then
        ui.Separator()
        DrawColoredText(colors.warning, "Mod is currently disabled. All changes have been reverted.")
        return
    end


    ui.Spacing()
    ui.Separator()

    ui.BeginChild("TabContentRegion", 0, -35, false)


    local currentPreset = EvaluateCurrentPreset()
    if ui.BeginTabBar("ModpackTabs") then
        -- TAB 1: PRESETS & LOADOUT
        if ui.BeginTabItem("Quick Setup") then
            ui.Spacing()
            DrawColoredText(colors.info, "Select a preset to automatically configure the modpack:")
            ui.Spacing()

            
            ui.PushItemWidth(ui.GetWindowWidth() * 0.45)
            if ui.BeginCombo("Active Preset", currentPreset) then
                for _, presetName in ipairs(presetOrder) do
                    if ui.Selectable(presetName, currentPreset == presetName) and presetName ~= currentPreset then
                        ApplyPreset(presetName)
                    end
                    if ui.IsItemHovered() then
                        ui.SetTooltip(presetDefinitions[presetName].tooltip)
                    end
                end

                if currentPreset == "Custom" then
                    ui.Separator()
                    ui.Selectable("Custom", true)
                    if ui.IsItemHovered() then
                        ui.SetTooltip("Active because you manually modified individual settings.")
                    end
                end
                ui.EndCombo()
            end
            ui.PopItemWidth()

            ui.Separator()
            ui.Spacing()

            DrawColoredText(colors.info, "Toggle all bug fixes at once. Go to the Bug Fixes tab for individual control.")
            local statusText, statusColor = GetBugFixStatus()

            DrawColoredText(colors.text, "Current Status: ")
            ui.SameLine()
            DrawColoredText(statusColor, statusText)
            ui.Spacing()

            if ui.Button("Enable All") then SetBugFixes(true) end
            ui.SameLine()
            if ui.Button("Disable All") then SetBugFixes(false) end

            ui.Separator()
            ui.Spacing()

            DrawColoredText(colors.info, "Quick Hammer Select for your current aspect.")
            ui.Spacing()

            local currentWeapon = Utils.GetEquippedAspect()
            local weaponNameLabel = Utils.aspectLabels[currentWeapon] or "Unknown Weapon"

            if Utils.hammerData[currentWeapon] then
                DrawHammerDropdown(currentWeapon, "Equipped: " .. weaponNameLabel)
            end

            ui.EndTabItem()
        end

        -- TAB 2: HAMMERS
        if ui.BeginTabItem("Hammers") then
            ui.Spacing()
            DrawColoredText(colors.info, "Select the guaranteed first hammer for each aspect.")
            ui.Spacing()

            for _, weaponKey in ipairs(Utils.weaponDrawOrder) do
                local weaponDisplayName = Utils.weaponLabels[weaponKey] or weaponKey

                if ui.CollapsingHeader(weaponDisplayName) then
                    ui.Indent()
                    local aspects = Utils.WeaponAspectMapping[weaponKey]
                    if aspects then
                        for _, aspectKey in ipairs(aspects) do
                            local aspectDisplayName = Utils.aspectLabels[aspectKey] or aspectKey
                            DrawHammerDropdown(aspectKey, aspectDisplayName)
                        end
                    end
                    ui.Unindent()
                end
            end
            ui.Spacing()
            ui.EndTabItem()
        end

        -- TAB 3: RUN MODIFIERS
        if ui.BeginTabItem("Run Modifiers") then
            ui.Spacing()
            DrawCheckboxGroup(runModifierLayout, config.RunModifiers)
            ui.EndTabItem()
        end

        -- TAB 4: BUG FIXES
        if ui.BeginTabItem("Bug Fixes") then
            ui.Spacing()
            DrawCheckboxGroup(bugFixLayout, config.BugFixes)
            ui.EndTabItem()
        end

        if ui.BeginTabItem("QoL Settings") then
            ui.Spacing()
            
            DrawCheckboxGroup(qolSettingsLayout, config.QoLSettings)

            -- local val, chg 

            -- val, chg = ui.Checkbox("Debug Mode", config.DebugMode)
            -- if chg then config.DebugMode = val end
            ui.EndTabItem()
        end

        ui.EndTabBar()
    end

    ui.EndChild()

    -- ==========================================
    -- STICKY FOOTER
    -- ==========================================
    ui.Separator()

    if ui.Button("Apply Changes") then
        Utils.ApplyConfigChanges()
        SnapshotAppliedState()
        hasPendingChanges = false
    end

    ui.SameLine()

    if hasPendingChanges then
        DrawColoredText(colors.warning, "Unapplied changes — press Apply to take effect.")
    else
        DrawColoredText(colors.textDisabled, "All changes applied.")
    end
end
-- =============================================================================
-- REGISTRATION
-- =============================================================================

local showModWindow = false

rom.gui.add_imgui(function()
    if showModWindow then
        PushTheme()
        if ui.Begin("Speedrun Modpack", true) then
            DrawMainWindow()
            ui.End()
        else
            showModWindow = false
        end
        PopTheme()
    end
end)

rom.gui.add_to_menu_bar(function()
    if ui.BeginMenu("Modpack") then
        if ui.MenuItem("Toggle Mod Menu") then
            showModWindow = not showModWindow
        end
        ui.EndMenu()
    end
end)
