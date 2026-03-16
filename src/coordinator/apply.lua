-- =============================================================================
-- APPLY ORCHESTRATOR
-- =============================================================================
-- Drives the config application cycle: restore backups, then call apply()
-- on each enabled module.

local Utils = adamant_Modpack
local Registry = Utils.Registry
local Backup = Utils.Backup

function Utils.ApplyConfigChanges()
    Backup.Restore()

    if not config.ModEnabled then
        SetupRunData()
        return
    end

    local AddToBackup = Backup.Add

    for _, mod in ipairs(Registry:getAll()) do
        local cat = config[mod.category]
        if cat and cat[mod.id] and mod.apply then
            mod.apply(AddToBackup)
        end
    end

    SetupRunData()
end
