-- =============================================================================
-- SHARED UTILITY FUNCTIONS
-- =============================================================================
-- Helper functions used across modules. Loaded before any modules.

local Utils = adamant_Modpack

function Utils.GetEquippedWeapon()
    if not CurrentRun or not CurrentRun.Hero then return "WeaponStaffSwing" end
    for _, weaponName in ipairs(WeaponSets.HeroPrimaryWeapons) do
        if CurrentRun.Hero.Weapons[weaponName] then
            return weaponName
        end
    end
    return "WeaponStaffSwing"
end

function Utils.PrintDebug(...)
    if config.DebugMode then
        print(...)
    end
end

function Utils.GetEquippedAspect()
    local currentWeapon = CurrentRun and CurrentRun.Hero
                        and CurrentRun.Hero.SlottedTraits and CurrentRun.Hero.SlottedTraits.Aspect or "BaseStaffAspect"
    return currentWeapon
end

function Utils.SafeArrayInsert(targetTable, arrayKey, value)
    if not targetTable then return end
    targetTable[arrayKey] = targetTable[arrayKey] or {}
    for _, existing in ipairs(targetTable[arrayKey]) do
        if existing == value then return end
    end
    table.insert(targetTable[arrayKey], value)
end

function Utils.SafeArrayRemove(targetTable, arrayKey, valuesToRemove)
    if not targetTable or not targetTable[arrayKey] then return end

    local lookup = {}
    if type(valuesToRemove) ~= "table" then
        lookup[valuesToRemove] = true
    else
        for _, v in ipairs(valuesToRemove) do
            lookup[v] = true
        end
    end

    local array = targetTable[arrayKey]
    for i = #array, 1, -1 do
        if lookup[array[i]] then
            table.remove(array, i)
        end
    end
end

function Utils.ApplyTraitChanges(traitName, changeCallback)
    if TraitData[traitName] then
        changeCallback(TraitData[traitName])
    end
end

function Utils.ApplyRoomChanges(roomName, changeCallback)
    if RoomData[roomName] then
        changeCallback(RoomData[roomName])
    end
end

-- Deep comparison for tables (used by echo_scam, selene, etc.)
local function DeepCompare(a, b)
    if a == b then return true end
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return false end
    for key, value in pairs(a) do
        if not DeepCompare(value, b[key]) then return false end
    end
    for key in pairs(b) do
        if a[key] == nil then return false end
    end
    return true
end

function Utils.ListContainsEquivalent(list, template)
    if type(list) ~= "table" then return false end
    for _, entry in ipairs(list) do
        if DeepCompare(entry, template) then return true end
    end
    return false
end
