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


local bugFixLayout = Utils.bugFixLayout
local runModifierLayout = Utils.runModifierLayout
local qolSettingsLayout = Utils.qolSettingsLayout
local NUM_PROFILES = Utils.NUM_PROFILES

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
-- STAGING TABLE (plain Lua — no chalk overhead)
-- =============================================================================
local staging = {
    RunModifiers = {},
    QoLSettings = {},
    BugFixes = {},
    FirstHammers = {},
}

local function ShallowCopy(src, dst)
    for k, v in pairs(src) do dst[k] = v end
end

local function SnapshotConfigToStaging()
    ShallowCopy(config.RunModifiers, staging.RunModifiers)
    ShallowCopy(config.QoLSettings, staging.QoLSettings)
    ShallowCopy(config.BugFixes, staging.BugFixes)
    ShallowCopy(config.FirstHammers, staging.FirstHammers)
end

local function CommitStagingToConfig()
    ShallowCopy(staging.RunModifiers, config.RunModifiers)
    ShallowCopy(staging.QoLSettings, config.QoLSettings)
    ShallowCopy(staging.BugFixes, config.BugFixes)
    ShallowCopy(staging.FirstHammers, config.FirstHammers)
end

-- Initialize staging from current config
SnapshotConfigToStaging()

-- =============================================================================
-- DIRTY STATE TRACKING
-- =============================================================================
local appliedHash = nil
local cachedHash = nil
local slotLabels = {}
local slotOccupied = {}
local slotLabelsDirty = true
local selectedProfileSlot = 1
local selectedProfileCombo = 0
local importHashBuffer = ""
local importFeedback = nil
local importFeedbackColor = nil
local excludeHammers = false

local cachedBoolHash = nil

local function GetCachedHash()
    if not cachedHash then
        cachedHash, cachedBoolHash = Utils.GetConfigHash(staging)
    end
    return cachedHash, cachedBoolHash
end

local function InvalidateCache()
    cachedHash = nil
    cachedBoolHash = nil
end

local function HasPendingChanges()
    return GetCachedHash() ~= appliedHash
end

local function RebuildSlotLabels()
    for i, p in ipairs(config.Profiles) do
        local hasName = p.Name ~= ""
        slotOccupied[i] = hasName
        if hasName then
            slotLabels[i] = i .. ": " .. p.Name
        else
            slotLabels[i] = i .. ": (empty)"
        end
    end
    slotLabelsDirty = false
end

local function ApplyChanges()
    CommitStagingToConfig()
    Utils.ApplyConfigChanges()
    appliedHash = GetCachedHash()
    Utils.UpdateHash()
end

local function DiscardChanges()
    SnapshotConfigToStaging()
    InvalidateCache()
end

-- Snapshot the initial state hash (staging == config at this point)
appliedHash = Utils.GetConfigHash(staging)

-- =============================================================================
-- PROFILE APPLICATION
-- =============================================================================

local function LoadProfile(hash)
    if Utils.ApplyConfigHash(hash, staging) then
        InvalidateCache()
        return true
    end
    return false
end

-- =============================================================================
-- BUG FIX MANAGEMENT
-- =============================================================================
local function SetBugFixes(flag)
    for key in pairs(staging.BugFixes) do
        staging.BugFixes[key] = flag
    end
    InvalidateCache()
end

local function GetBugFixStatus()
    local hasEnabled = false
    local hasDisabled = false

    for key, state in pairs(staging.BugFixes) do
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

    local currentId = staging.FirstHammers[weaponKey] or ""
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
                    staging.FirstHammers[weaponKey] = data.values[i]
                    InvalidateCache()
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
                    InvalidateCache()
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
        ApplyChanges()
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

    local winW = ui.GetWindowWidth()

    if ui.BeginTabBar("ModpackTabs") then
        -- TAB 1: PROFILES & LOADOUT
        if ui.BeginTabItem("Quick Setup") then
            ui.Spacing()
            DrawColoredText(colors.info, "Select a profile to automatically configure the modpack:")
            ui.Spacing()

            if slotLabelsDirty then RebuildSlotLabels() end

            -- Combo preview: show matching profile name or "Select..."
            local comboPreview = "Select..."
            if selectedProfileCombo > 0 and selectedProfileCombo <= NUM_PROFILES and slotOccupied[selectedProfileCombo] then
                comboPreview = slotLabels[selectedProfileCombo]
            end

            ui.PushItemWidth(winW * 0.45)
            if ui.BeginCombo("Profile", comboPreview) then
                for i = 1, NUM_PROFILES do
                    if slotOccupied[i] then
                        ui.PushID(i)
                        if ui.Selectable(slotLabels[i], i == selectedProfileCombo) then
                            selectedProfileCombo = i
                        end
                        if ui.IsItemHovered() then
                            local tip = config.Profiles[i].Tooltip
                            if tip and tip ~= "" then
                                ui.SetTooltip(tip)
                            end
                        end
                        ui.PopID()
                    end
                end
                ui.EndCombo()
            end
            ui.PopItemWidth()

            ui.SameLine()
            local sel = selectedProfileCombo
            if sel > 0 and sel <= NUM_PROFILES then
                local hash = config.Profiles[sel].Hash
                if hash and hash ~= "" then
                    if ui.Button("Load") then
                        LoadProfile(hash)
                    end
                end
            end

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
            DrawCheckboxGroup(runModifierLayout, staging.RunModifiers)
            ui.EndTabItem()
        end

        -- TAB 4: BUG FIXES
        if ui.BeginTabItem("Bug Fixes") then
            ui.Spacing()
            DrawCheckboxGroup(bugFixLayout, staging.BugFixes)
            ui.EndTabItem()
        end

        if ui.BeginTabItem("QoL") then
            ui.Spacing()
            DrawCheckboxGroup(qolSettingsLayout, staging.QoLSettings)
            ui.EndTabItem()
        end
        
        if ui.BeginTabItem("Profiles") then
            ui.Spacing()

            -- Export
            PushTextColor(colors.info)
            ui.CollapsingHeader("Export / Import", ImGuiTreeNodeFlags.DefaultOpen)
            ui.PopStyleColor()
            ui.Indent()

            local currentHash, boolHash = GetCachedHash()
            ui.Text("Current Hash:")
            ui.SameLine()
            DrawColoredText(colors.success, boolHash)
            local hammerPayload = string.sub(currentHash, #boolHash + 1)
            if hammerPayload ~= "" then
                ui.SameLine()
                DrawColoredText(colors.textDisabled, hammerPayload)
            end
            ui.SameLine()
            if ui.Button("Copy") then
                ui.SetClipboardText(excludeHammers and boolHash or currentHash)
                importFeedback = "Copied to clipboard!"
                importFeedbackColor = colors.success
            end
            ui.SameLine()
            local val, chg = ui.Checkbox("Exclude Hammers", excludeHammers)
            if chg then excludeHammers = val end

            ui.Spacing()
            ui.Text("Import Hash:")
            ui.SameLine()
            ui.PushItemWidth(winW * 0.4)
            local newText, changed = ui.InputText("##ImportHash", importHashBuffer, 256)
            if changed then importHashBuffer = newText end
            ui.PopItemWidth()
            ui.SameLine()
            if ui.Button("Paste") then
                local clip = ui.GetClipboardText()
                if clip then importHashBuffer = clip end
            end
            ui.SameLine()
            if ui.Button("Import") then
                if LoadProfile(importHashBuffer) then
                    importFeedback = "Imported successfully!"
                    importFeedbackColor = colors.success
                else
                    importFeedback = "Invalid hash."
                    importFeedbackColor = colors.error
                end
            end
            if importFeedback then
                ui.SameLine()
                DrawColoredText(importFeedbackColor, importFeedback)
            end

            ui.Unindent()
            ui.Spacing()
            ui.Separator()
            ui.Spacing()

            -- Profile Slot Selector
            PushTextColor(colors.info)
            ui.CollapsingHeader("Saved Profiles", ImGuiTreeNodeFlags.DefaultOpen)
            ui.PopStyleColor()
            ui.Indent()

            if slotLabelsDirty then RebuildSlotLabels() end

            ui.PushItemWidth(winW * 0.3)
            if ui.BeginCombo("Slot", slotLabels[selectedProfileSlot]) then
                for i, label in ipairs(slotLabels) do
                    if ui.Selectable(label, i == selectedProfileSlot) then
                        selectedProfileSlot = i
                    end
                end
                ui.EndCombo()
            end
            ui.PopItemWidth()

            ui.Spacing()

            local profile = config.Profiles[selectedProfileSlot]
            local hasData = profile.Hash ~= ""

            -- Name
            ui.Text("Name:")
            ui.SameLine()
            ui.PushItemWidth(winW * 0.2)
            local newName, nameChanged = ui.InputText("##SlotName", profile.Name, 64)
            if nameChanged then profile.Name = newName; slotLabelsDirty = true end
            ui.PopItemWidth()

            -- Tooltip
            ui.Text("Tooltip:")
            ui.SameLine()
            ui.PushItemWidth(winW * 0.8)
            local newTooltip, tooltipChanged = ui.InputText("##SlotTooltip", profile.Tooltip, 256)
            if tooltipChanged then profile.Tooltip = newTooltip end
            ui.PopItemWidth()

            -- Hash display
            if hasData then
                ui.Text("Hash:")
                ui.SameLine()
                DrawColoredText(colors.textDisabled, profile.Hash)
            end

            ui.Spacing()

            -- Action buttons
            if ui.Button("Save Current") then
                profile.Hash = GetCachedHash()
                if profile.Name == "" then
                    profile.Name = "Profile " .. selectedProfileSlot
                end
                slotLabelsDirty = true
            end

            if hasData then
                ui.SameLine()
                if ui.Button("Load") then
                    LoadProfile(profile.Hash)
                end
                ui.SameLine()
                if ui.Button("Clear") then
                    profile.Name = ""
                    profile.Hash = ""
                    profile.Tooltip = ""
                    slotLabelsDirty = true
                end
            end

            ui.Unindent()
            ui.Spacing()
            ui.Separator()
            ui.Spacing()

            if ui.Button("Restore Default Profiles") then
                local defaults = Utils.defaultProfiles
                for i = 1, NUM_PROFILES do
                    local p = config.Profiles[i]
                    local d = defaults[i]
                    if d then
                        p.Name = d.Name
                        p.Hash = d.Hash
                        p.Tooltip = d.Tooltip
                    else
                        p.Name = ""
                        p.Hash = ""
                        p.Tooltip = ""
                    end
                end
                slotLabelsDirty = true
            end
            if ui.IsItemHovered() then
                ui.SetTooltip("Reset all profile slots to the shipped defaults.")
            end

            ui.Spacing()
            ui.EndTabItem()
        end

        ui.EndTabBar()
    end

    ui.EndChild()

    -- ==========================================
    -- STICKY FOOTER
    -- ==========================================
    ui.Separator()

    local pending = HasPendingChanges()

    if pending then
        if ui.Button("Apply Changes") then
            ApplyChanges()
        end
        ui.SameLine()
        if ui.Button("Discard") then
            DiscardChanges()
        end
        ui.SameLine()
        DrawColoredText(colors.warning, "Unapplied changes")
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
