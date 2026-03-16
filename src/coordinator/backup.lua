-- =============================================================================
-- BACKUP / RESTORE SYSTEM
-- =============================================================================
-- Captures original game values before modification so they can be restored
-- when config changes. AddToBackup is idempotent: only the first call for a
-- given (tableRef, key) pair saves the value.

local NIL = {}  -- sentinel: distinguishes "saved as nil" from "not yet saved"
local savedValues = {}

local Backup = {}

function Backup.Add(tableRef, ...)
    savedValues[tableRef] = savedValues[tableRef] or {}
    local saved = savedValues[tableRef]
    for _, key in ipairs({...}) do
        if saved[key] == nil then
            local value = tableRef[key]
            saved[key] = (value == nil) and NIL or (type(value) == "table" and DeepCopyTable(value) or value)
        end
    end
end

function Backup.Restore()
    for tableRef, keys in pairs(savedValues) do
        for key, value in pairs(keys) do
            if value == NIL then
                tableRef[key] = nil
            elseif type(value) == "table" then
                tableRef[key] = DeepCopyTable(value)
            else
                tableRef[key] = value
            end
        end
    end
end

adamant_Modpack.Backup = Backup
