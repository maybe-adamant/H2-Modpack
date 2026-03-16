-- =============================================================================
-- HOOK COORDINATOR
-- =============================================================================
-- Registers all module hooks with modutil. Called once during on_ready.

local Utils = adamant_Modpack
local Registry = Utils.Registry

local Hooks = {}

--- Look up the config value for a module based on its category and id.
local function IsModuleEnabled(mod)
    if not config.ModEnabled then return false end
    local cat = config[mod.category]
    if not cat then return false end
    return cat[mod.id] == true
end

--- Register all per-module hooks. Each hook wrap checks config before executing.
function Hooks.RegisterModuleHooks()
    for _, mod in ipairs(Registry:getHookedModules()) do
        for _, hook in ipairs(mod.hooks) do
            local moduleRef = mod
            local hookFn = hook.fn
            modutil.mod.Path.Wrap(hook.target, function(baseFunc, ...)
                if not IsModuleEnabled(moduleRef) then
                    return baseFunc(...)
                end
                return hookFn(baseFunc, ...)
            end)
        end
    end
end

--- Register context wraps (hooks that use modutil.mod.Path.Context.Wrap).
--- These are declared as contextHooks on modules.
function Hooks.RegisterContextHooks()
    for _, mod in ipairs(Registry:getAll()) do
        if mod.contextHooks then
            for _, hook in ipairs(mod.contextHooks) do
                hook.register(mod)
            end
        end
    end
end

--- Main entry point: register all hooks.
function Hooks.RegisterAll()
    Hooks.RegisterModuleHooks()
    Hooks.RegisterContextHooks()
end

adamant_Modpack.Hooks = Hooks
