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
    local masterVal, masterChg = ImGui.Checkbox("Enable First Hammer Selector", config.ModEnabled)
    if masterChg then config.ModEnabled = masterVal end
    
    ImGui.Separator()
    ImGui.Spacing()

    if not config.ModEnabled then
        ImGui.TextDisabled("Mod is currently disabled.")
        return 
    end

    local currentWeapon = Utils.GetEquippedWeapon()
    local weaponNameLabel = Utils.weaponLabels[currentWeapon] or "Unknown Weapon"

    ImGui.Text("Select the hammer you want to see in the run.")
    ImGui.TextDisabled("Leave as 'None' to rely on standard game RNG.")
    ImGui.Spacing()

    if Utils.hammerData[currentWeapon] then
        DrawHammerDropdown(currentWeapon, "Equipped: " .. weaponNameLabel)
    end
end

-- =============================================================================
-- REGISTRATION
-- =============================================================================


rom.gui.add_imgui(function()
    if ImGui.Begin("Starting Hammer") then
        DrawMainWindow()
        ImGui.End()
    end
end)


rom.gui.add_to_menu_bar(function()
    if ImGui.BeginMenu("Starting Hammer") then
        DrawMainWindow()
        ImGui.EndMenu()
    end
end)