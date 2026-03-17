-- =============================================================================
-- ADAMANT MODULE TEMPLATE
-- =============================================================================
-- Copy this file as src/main.lua in a new mod folder.
-- Fill in the MODULE DEFINITION and MODULE LOGIC sections below.
-- Everything above the line is boilerplate — don't modify it.
--
-- The mod works standalone (toggled by its own config.Enabled).
-- When adamant-core is installed, it discovers this mod via public.definition
-- and can orchestrate enable/disable, UI, hash, and profiles.

-- =============================================================================
-- BOILERPLATE (do not modify)
-- =============================================================================

local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']

config = chalk.auto('config.lua')
public.config = config

-- Backup system: call backup(table, "key") before mutating game data.
-- restore() reverts all backed-up values to their original state.
local NIL = {}
local backups = {}

local function backup(tbl, key)
    if not backups[tbl] then backups[tbl] = {} end
    if backups[tbl][key] == nil then
        local v = tbl[key]
        backups[tbl][key] = v == nil and NIL or (type(v) == "table" and DeepCopyTable(v) or v)
    end
end

local function restore()
    for tbl, keys in pairs(backups) do
        for key, v in pairs(keys) do
            tbl[key] = v == NIL and nil or (type(v) == "table" and DeepCopyTable(v) or v)
        end
    end
end

local function isEnabled()
    return config.Enabled
end

-- =============================================================================
-- MODULE DEFINITION (fill this in)
-- =============================================================================

public.definition = {
    id       = "",           -- Unique config key, e.g. "CorrosionFix"
    name     = "",           -- Display name, e.g. "Corrosion Fix"
    category = "",           -- "BugFixes" | "RunModifiers" | "QoLSettings" | your own
    group    = "",           -- UI group header, e.g. "NPC & Encounters"
    tooltip  = "",           -- Hover text describing what this does
    default  = true,         -- Default enabled state
}

-- =============================================================================
-- MODULE LOGIC (fill this in)
-- =============================================================================

-- Called when the mod is enabled. Mutate game data here.
-- Use backup(table, "key") BEFORE changing any value.
local function apply()
    -- Example:
    -- backup(TraitData.SomeTrait, "SomeProperty")
    -- TraitData.SomeTrait.SomeProperty = newValue
end

-- Called when the mod is disabled. Undo everything.
local function disable()
    restore()
end

-- Register hooks here. Each hook wraps a game function.
-- The enable check is your responsibility in standalone mode.
local function registerHooks()
    -- Example:
    -- modutil.mod.Path.Wrap("SomeGameFunction", function(baseFunc, ...)
    --     if not isEnabled() then return baseFunc(...) end
    --     -- your logic here
    --     return baseFunc(...)
    -- end)
end

-- =============================================================================
-- PUBLIC API (do not modify)
-- =============================================================================

public.definition.enable = function()
    apply()
end

public.definition.disable = function()
    disable()
end

-- =============================================================================
-- LIFECYCLE (do not modify)
-- =============================================================================

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if config.Enabled then apply() end
    end)
end)

-- =============================================================================
-- STANDALONE UI (do not modify)
-- =============================================================================
-- When adamant-core is NOT installed, renders a minimal ImGui toggle.
-- When adamant-core IS installed, the core handles UI — this is skipped.

rom.gui.add_to_menu_bar(function()
    if mods['adamant-Core'] then return end
    if rom.ImGui.BeginMenu("adamant") then
        local val, chg = rom.ImGui.Checkbox(public.definition.name, config.Enabled)
        if chg then
            config.Enabled = val
            if val then apply() else disable() end
        end
        if rom.ImGui.IsItemHovered() and public.definition.tooltip ~= "" then
            rom.ImGui.SetTooltip(public.definition.tooltip)
        end
        rom.ImGui.EndMenu()
    end
end)
