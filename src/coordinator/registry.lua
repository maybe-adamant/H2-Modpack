-- =============================================================================
-- MODULE REGISTRY
-- =============================================================================
-- Central registry for all modpack modules. Each module self-registers by
-- calling Registry:register(definition). The coordinator uses this to drive
-- config defaults, UI rendering, hook registration, and apply cycles.
--
-- Hash order is determined by registration order within each category,
-- which is controlled by import order in modules/init.lua.
-- DO NOT reorder imports in init.lua — it will break existing hashes.
--
-- Module definition table:
--   id            (string)   Config key, e.g. "CorrosionFix"
--   name          (string)   Display name for UI
--   category      (string)   Config key, e.g. "BugFixes" (new categories auto-create tabs)
--   categoryLabel (string?)  Display name for the tab, e.g. "Bug Fixes" (first module wins)
--   group         (string)   UI collapsing header, e.g. "Weapons & Attacks"
--   tooltip       (string)   Hover text
--   default       (boolean)  Default config value
--   apply         (function) Called with (AddToBackup) when module is enabled
--   hooks         (table?)   Optional list of { target, fn } wraps
--   contextHooks  (table?)   Optional list of { register } for Context.Wrap hooks

local Registry = {}
Registry._modules = {}
Registry._byCategory = {}
Registry._order = {}
Registry._categoryCounters = {}
Registry._categoryOrder = {}   -- first-seen ordered list of category keys
Registry._categoryLabels = {   -- category key -> display label (built-in defaults)
    BugFixes = "Bug Fixes",
    RunModifiers = "Run Modifiers",
    QoLSettings = "QoL",
}
Registry._categorySet = {}     -- quick lookup to avoid duplicates in _categoryOrder

function Registry:register(def)
    assert(def.id, "Module must have an id")
    assert(def.category, "Module " .. def.id .. " must have a category")
    assert(not self._modules[def.id], "Duplicate module id: " .. def.id)

    -- Auto-assign order based on registration sequence per category
    local cat = def.category
    self._categoryCounters[cat] = (self._categoryCounters[cat] or 0) + 1
    def.order = self._categoryCounters[cat]

    -- Track category discovery order
    if not self._categorySet[cat] then
        self._categorySet[cat] = true
        table.insert(self._categoryOrder, cat)
    end

    -- First module to declare a categoryLabel for this category wins
    if def.categoryLabel and not self._categoryLabels[cat] then
        self._categoryLabels[cat] = def.categoryLabel
    end

    self._modules[def.id] = def

    -- Index by category (insertion order = hash order)
    self._byCategory[cat] = self._byCategory[cat] or {}
    table.insert(self._byCategory[cat], def)

    -- Track global insertion order
    table.insert(self._order, def)
end

function Registry:get(id)
    return self._modules[id]
end

function Registry:getAll()
    return self._order
end

function Registry:getByCategory(category)
    return self._byCategory[category] or {}
end

--- Returns categories in discovery order (= import order in init.lua).
--- Each entry: { key = "BugFixes", label = "Bug Fixes" }
function Registry:getCategories()
    local result = {}
    for _, cat in ipairs(self._categoryOrder) do
        table.insert(result, {
            key = cat,
            label = self._categoryLabels[cat] or cat,
        })
    end
    return result
end

--- Returns modules for a category in registration order (= hash order).
--- No sorting needed — registration order is canonical.
function Registry:getSorted(category)
    return self:getByCategory(category)
end

--- Build UI layout data from registry (replaces hand-maintained layouts in def.lua).
--- Groups modules by their `group` field, preserving registration order within groups.
function Registry:buildLayout(category)
    local mods = self:getByCategory(category)
    local groupOrder = {}
    local groups = {}

    for _, m in ipairs(mods) do
        local g = m.group or "General"
        if not groups[g] then
            groups[g] = { Header = g, Items = {} }
            table.insert(groupOrder, g)
        end
        table.insert(groups[g].Items, {
            Key = m.id,
            Name = m.name,
            Tooltip = m.tooltip or "",
        })
    end

    local layout = {}
    for _, g in ipairs(groupOrder) do
        table.insert(layout, groups[g])
    end
    return layout
end

--- Generate default config values for a category from module definitions.
function Registry:getDefaults(category)
    local defaults = {}
    for _, m in ipairs(self:getByCategory(category)) do
        defaults[m.id] = m.default
    end
    return defaults
end

--- Collect all modules that have hooks defined.
function Registry:getHookedModules()
    local hooked = {}
    for _, m in ipairs(self._order) do
        if m.hooks and #m.hooks > 0 then
            table.insert(hooked, m)
        end
    end
    return hooked
end

adamant_Modpack.Registry = Registry
