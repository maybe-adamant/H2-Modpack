-- local modutil = rom.mods['SGG_Modding-ModUtil']
local Utils = adamant_Modpack

local hasForcedHammerThisRun = false

-- =============================================================================
-- BACKUP SYSTEM
-- =============================================================================
-- AddToBackup(tableRef, key1, key2, ...) captures each key's current value the
-- first time it is called for that (tableRef, key) pair. Subsequent calls are
-- no-ops, so the original vanilla value is always preserved.
-- Table values are deep-copied automatically.
local NIL = {}  -- sentinel: distinguishes "saved as nil" from "not yet registered"
local savedValues = {}

local function AddToBackup(tableRef, ...)
    savedValues[tableRef] = savedValues[tableRef] or {}
    local saved = savedValues[tableRef]
    for _, key in ipairs({...}) do
        if saved[key] == nil then
            local value = tableRef[key]
            saved[key] = (value == nil) and NIL or (type(value) == "table" and DeepCopyTable(value) or value)
        end
    end
end

local function RestoreBackups()
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

-- Data definitions loaded from def.lua
-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

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
    local currentWeapon = Utils.GetEquippedWeapon()

    local possibleAspects = Utils.WeaponAspectMapping[currentWeapon]

    if not possibleAspects then return "BaseStaffAspect" end

    for _, aspectName in ipairs(possibleAspects) do
        if HeroHasTrait(aspectName) then
            return aspectName
        end
    end

    return possibleAspects[1] 
end



local function DeepCompare(a, b)
    if a == b then return true end
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return false end

    for key, value in pairs(a) do
        if not DeepCompare(value, b[key]) then
            return false
        end
    end
    for key, value in pairs(b) do
        if a[key] == nil then
            return false
        end
    end
    return true
end

local function ListContainsEquivalent(list, template)
    if type(list) ~= "table" then return false end
    
    for _, entry in ipairs(list) do
        if DeepCompare(entry, template) then 
            return true 
        end
    end
    return false
end

function Utils.SafeArrayInsert(targetTable, arrayKey, value)
    if not targetTable then return end
    targetTable[arrayKey] = targetTable[arrayKey] or {}
    for _, existing in ipairs(targetTable[arrayKey]) do
        if existing == value then return end -- Prevent duplicates
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
            lookup[v] = true -- This naturally handles duplicates in valuesToRemove
        end
    end

    local array = targetTable[arrayKey]
    for i = #array, 1, -1 do
        if lookup[array[i]] then
            table.remove(array, i)
        end
    end
end

-- Modifies Trait blueprint
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

local function GetConfigHash()
    local flags = {}
    for _, category in ipairs(Utils.runModifierLayout) do
        for _, item in ipairs(category.Items) do
            table.insert(flags, config[item.Key] and 1 or 0)
        end
    end
    for _, category in ipairs(Utils.bugFixLayout) do
        for _, item in ipairs(category.Items) do
            table.insert(flags, config.BugFixes[item.Key] and 1 or 0)
        end
    end
    local hash = 0
    for i, bit in ipairs(flags) do
        hash = hash + bit * (2 ^ (i - 1))
    end
    return string.format("%06X", hash)
end

-- =============================================================================
-- MOD ENGINE HOOKS
-- =============================================================================
--Special wrap to reset the forced hammer flag at the start of each run and handle Selene Aspect's initial hex record
modutil.mod.Path.Wrap("StartNewRun", function(baseFunc, prevRun, args)

    hasForcedHammerThisRun = false

    local currentRun = baseFunc(prevRun, args)
    currentRun.ModpackHash = config.ModEnabled and GetConfigHash() or "OFF"
    Utils.PrintDebug("Current Modpack Config Hash: " .. tostring(currentRun.ModpackHash))

    if config.ModEnabled and config.BugFixes.SeleneFix then
        if HeroHasTrait("SuitHexAspect") then
            Utils.PrintDebug("Starting run with Selene Aspect - granting Selene's Boon")
            RecordUse( nil, "SpellDrop" )
        end
    end

    return currentRun
end)

--Special wrap to handle Aspect of selene with Moonbeam keepsake interaction for guaranteed Path of Stars on first boon drop
modutil.mod.Path.Wrap("SpawnRoomReward", function(base, eventSource, args)
    if config.ModEnabled and config.BugFixes.SeleneFix and HeroHasTrait("SuitHexAspect") and HeroHasTrait( "SpellTalentKeepsake" ) and game.CurrentRun.CurrentRoom.BiomeStartRoom then
        args = args or {}
        if args.WaitUntilPickup then
            args.RewardOverride = "TalentDrop" 
            args.LootName = nil           
            Utils.PrintDebug("Starting run with Selene Aspect and Moonbeam - granting Path of Stars Directly")
        end
    end
    return base(eventSource, args)
end)

--Wrap to handle guaranteed Aspect-specific hammers on first weapon upgrade drop, with full respect for all eligibility conditions and a failsafe fallback to vanilla generation if the desired hammer is ineligible for any reason. 
--Also locks out the mod for the rest of the run after triggering once to preserve balance of future drops.
modutil.mod.Path.Wrap("SetTraitsOnLoot", function(baseFunc, lootData, args)
    -- 1. Let the base game generate the 3 normal random options first
    baseFunc(lootData, args)

    if config.ModEnabled and lootData.Name == "WeaponUpgrade" and not hasForcedHammerThisRun then
        
        local currentWeapon = Utils.GetEquippedAspect()
        local desiredHammer = config.FirstHammers[currentWeapon]

        if desiredHammer and desiredHammer ~= "" then
            local traitData = TraitData[desiredHammer]
            
            -- The ultimate, native failsafe
            if traitData and IsTraitEligible(traitData, args) then
                
                -- It is perfectly compatible! Overwrite the menu.
                lootData.UpgradeOptions = {
                    { ItemName = desiredHammer, Type = "Trait" }
                }
            else
                Utils.PrintDebug("StartingHammer: " .. desiredHammer .. " is ineligible! Falling back to random.")
            end

        end
    end
end)

modutil.mod.Path.Wrap("AddTraitToHero", function(baseFunc, args)
    args = args or {}
    local traitName =  args.TraitData and args.TraitData.Name
    if not config.ModEnabled or not traitName then
        return baseFunc(args)
    end
    local currentWeapon = Utils.GetEquippedAspect()
    local desiredHammer = config.FirstHammers[currentWeapon]

    if desiredHammer == traitName then
        Utils.PrintDebug("AddTraitToHero: Granting guaranteed first hammer -> " .. tostring(traitName))
        -- Lock out the mod for the rest of the run so future hammers are natural
        hasForcedHammerThisRun = true
    end

    return baseFunc(args)
end)

--Wrap to handle RTA Mode and Surface Structure Fix by filtering out ineligible encounters from the spawn pool at the point of selection, ensuring all other systems that rely on LegalEncounters lists continue to function properly.
modutil.mod.Path.Wrap("ChooseEncounter", function(baseFunc, currentRun, room, args)
    if not config.ModEnabled then
        return baseFunc(currentRun, room, args)
    end
    local bannedEnc = nil
    if config.RTAMode then
        bannedEnc = {
            ArtemisCombatF = true, ArtemisCombatF2 = true, NemesisCombatF = true,      -- Erebus
            ArtemisCombatG = true, ArtemisCombatG2 = true, NemesisCombatG = true,      -- Oceanus
            NemesisCombatH = true,                                                      -- Fields
            NemesisCombatI = true,                                                      -- Tartarus
            ArtemisCombatN = true, ArtemisCombatN2 = true,                             -- Ephyra
            HeraclesCombatN = true, HeraclesCombatN2 = true,                           -- Ephyra
            IcarusCombatO = true, IcarusCombatO2 = true,                               -- Thessaly
            HeraclesCombatO = true, HeraclesCombatO2 = true,                           -- Thessaly
            AthenaCombatP = true, AthenaCombatP02 = true, IcarusCombatP = true,        -- Olympus
            HeraclesCombatP = true,                                                     -- Olympus
        }
    end
    if config.SurfaceStructureFix and bannedEnc == nil then            
        bannedEnc = {
            HeraclesCombatO = true, HeraclesCombatO2 = true,                           -- Thessaly
        }
    end
    if bannedEnc == nil then
        return baseFunc(currentRun, room, args)
    end

    args = args or {}
    local source = args.LegalEncounters or room.LegalEncounters
    if source then
        local filtered = {}
        for _, enc in pairs(source) do
            if not bannedEnc[enc] then
                table.insert(filtered, enc)
            end
        end
        args.LegalEncounters = filtered
    end

    return baseFunc(currentRun, room, args)

end)

--Wrap to handle Anubis OAtk positioning when multiple fields are summoned
modutil.mod.Path.Wrap("CreateSecondAnubisWall", function( baseFunc, weaponData, args, triggerArgs )
    
    if not config.ModEnabled or not config.BugFixes.ETFix then
        return baseFunc(weaponData, args, triggerArgs)
    end

    local weaponName = "WeaponStaffSwing5"
    local projectileName = "ProjectileStaffWall"
    local derivedValues = GetDerivedPropertyChangeValues({
        ProjectileName = projectileName,
        WeaponName = weaponName,
        Type = "Projectile",
    })
    
    local angle = GetAngle({ Id = CurrentRun.Hero.ObjectId })
    local radAngle = math.rad(angle)
    
    local baseDistance = 520
    local gapDistance = args.Distance-520
    local isoRatio = 0.7 
    
    local baseX = math.cos(radAngle) * baseDistance
    local baseY = -math.sin(radAngle) * baseDistance * isoRatio
    
    local gapX = math.cos(radAngle) * gapDistance
    local gapY = -math.sin(radAngle) * gapDistance
    
    local fixedOffsetX = baseX + gapX
    local fixedOffsetY = baseY + gapY

    local projectileId = CreateProjectileFromUnit({ 
        WeaponName = weaponName, 
        Name = projectileName,
        OffsetX = fixedOffsetX,
        OffsetY = fixedOffsetY,
        Angle = angle,
        Id = CurrentRun.Hero.ObjectId, 
        DestinationId = MapState.FamiliarLocationId, 
        FireFromTarget = true, 
        DataProperties = derivedValues.PropertyChanges, 
        ThingProperties = derivedValues.ThingPropertyChanges, 
        ExcludeFromCap = true 
    })      
end)

--Wrap to make Aspect of Charon triggers Glorious Disaster
modutil.mod.Path.Wrap("CheckAxeCastArm", function(baseFunc, triggerArgs, args)
    if config.ModEnabled and config.BugFixes.SecondStageChannelingFix then
        if HeroHasTrait("ApolloExCastBoon") and HeroHasTrait("ApolloSecondStageCastBoon") then
            SessionMapState.SuperchargeCast = true
        end
    end
    baseFunc(triggerArgs, args)


end)


--Wrap to stop bosses from dropping gem rewards when using Grave Thirst
modutil.mod.Path.Wrap("UnusedWeaponBonusDropGems", function(baseFunc, source, args )
    if config.ModEnabled and config.SkipGemBossReward then
        Utils.PrintDebug("UnusedWeaponBonusDropGems called after boss. Skipping gem rewards.")
        return
    end
    return baseFunc(source, args)
end)


--Wrap to handle escalating skip chance for Dionysus Skip keepsake by applying the growth to the trait directly at 
--the point of use, ensuring it interacts properly with all systems that read the trait's values and allowing the 
--growth to be visible in tooltips and the like without needing to replicate the logic in multiple places.
modutil.mod.Path.Wrap("DionysusSkipTrait", function(baseFunc, args, traitData)
    baseFunc(args, traitData)
    if not config.ModEnabled or not config.EscalatingFigLeaf then return end

    for _, trait in ipairs(CurrentRun.Hero.Traits) do
        if trait.Name == "PersistentDionysusSkipKeepsake" then
            trait.InitialSkipEncounterChance = trait.SkipEncounterChance
            trait.SkipEncounterGrowthPerRoom = 0.13
            Utils.PrintDebug("Applied Dionysus Skip Chance Growth. Initial Chance: " .. tostring(trait.SkipEncounterChance) .. ", Growth per room: " .. tostring(trait.SkipEncounterGrowthPerRoom))
            break
        end
    end
end)

modutil.mod.Path.Wrap("EndEncounterEffects", function(baseFunc, currentRun, currentRoom, currentEncounter)
    baseFunc(currentRun, currentRoom, currentEncounter)
    if config.ModEnabled and config.EscalatingFigLeaf then
        if currentEncounter == currentRoom.Encounter or currentEncounter == MapState.EncounterOverride then
            if HeroHasTrait("PersistentDionysusSkipKeepsake") then
                local traitData = GetHeroTrait("PersistentDionysusSkipKeepsake")
                if traitData.SkipEncounterChance and traitData.SkipEncounterGrowthPerRoom then
                    Utils.PrintDebug("Increasing Dionysus Skip Chance by " .. tostring(traitData.SkipEncounterGrowthPerRoom) .. " for next encounter. Previous Chance: " .. tostring(traitData.SkipEncounterChance) .. ", New Chance: " .. tostring(math.min(1, traitData.SkipEncounterChance + traitData.SkipEncounterGrowthPerRoom)))
                    traitData.SkipEncounterChance = math.min(1, traitData.SkipEncounterChance + traitData.SkipEncounterGrowthPerRoom)
                end
            end
        end
    end
end)

modutil.mod.Path.Wrap("StartRoom", function(baseFunc, currentRun, currentRoom)
    baseFunc(currentRun, currentRoom)
    if config.ModEnabled and config.EscalatingFigLeaf then
        if currentRoom.BiomeStartRoom then
            if HeroHasTrait("PersistentDionysusSkipKeepsake") then
                local traitData = GetHeroTrait("PersistentDionysusSkipKeepsake")
                if traitData.InitialSkipEncounterChance then
                    traitData.SkipEncounterChance = traitData.InitialSkipEncounterChance
                    Utils.PrintDebug("Resetting Dionysus Skip Chance to initial value: " .. tostring(traitData.SkipEncounterChance))
                end
            end
        end
    end
end)

--Wrap to make Suffering on Sight bypass Vow of Wards
modutil.mod.Path.Wrap("CheckSpawnCurseDamage", function(baseFunc, enemy, traitArgs)
    if not config.ModEnabled or not config.BugFixes.SufferingFix then
        return baseFunc(enemy, traitArgs)
    end

    if enemy.IsBoss or enemy.UseBossHealthBar or enemy.IgnoreCurseDamage or enemy.AlwaysTraitor then
        return
    end
    local damageAmount = 0
    for _, data in ipairs(traitArgs.DamageArgs) do
        if not data.Chance or RandomChance(data.Chance * GetTotalHeroTraitValue( "LuckMultiplier", { IsMultiplier = true })) then
            damageAmount = RandomInt( data.MinDamage, data.MaxDamage )
            break
        end
    end
    thread( DoCurseDamage, enemy, traitArgs, damageAmount, true )
end)

local function ReplaceGigaMoonburst()
    OverwriteTableKeys( TraitData, {
        StaffSecondStageTrait = 
        {
            InheritFrom = { "WeaponTrait", "StaffHammerTrait" },
            Icon = "Hammer_Staff_37",
            GameStateRequirements =
            {
                {
                    Path = { "CurrentRun", "Hero", "Weapons", },
                    HasAll = { "WeaponStaffSwing", },
                },
            },
            RarityLevels =
            {
                Common =
                {
                    Multiplier = 1.0,
                },
                Legendary = 
                {
                    Multiplier = 1.333,
                },
            },
            ManaCostModifiers = 
            {
                WeaponNames = {"WeaponStaffBall"},
                ExcludeLinked = true,
                ExWeapons = true,
                ManaCostAdd = 30,
                ReportValues = { ReportedManaCost = "ManaCostAdd" }
            },

            AddOutgoingDamageModifiers =
            {
                ValidProjectiles = { "ProjectileStaffBallCharged" },
                ValidWeaponMultiplier =
                {
                    BaseValue = 4.0,
                    SourceIsMultiplier = true,
                },
                ReportValues = { ReportedWeaponMultiplier = "ValidWeaponMultiplier"},
            },

            PropertyChanges =
            {
                {
                    WeaponName = "WeaponStaffBall",
                    ProjectileName = "ProjectileStaffBallCharged",
                    ProjectileProperties = 
                    {
                        DamageRadius = 550,
                        BlastSpeed = 2500,
                    },
                },
            },  

            ExtractValues =
            {
                {
                    Key = "ReportedManaCost",
                    ExtractAs = "ManaCost",
                },
                {
                    Key = "ReportedWeaponMultiplier",
                    ExtractAs = "DamageIncrease",
                    Format = "PercentDelta",
                },
            }
        }
    })

end

local function PatchGloriousDisaster()
    -- Ensure TraitData and the target Boon exist before modifying to prevent crashes
    if TraitData == nil or TraitData.ApolloSecondStageCastBoon == nil then
        return
    end

    local extraManaCost = 30
    local baseWait = 0.8
    local baseCost = 15

    -- Set the display values and requirements
    TraitData.ApolloSecondStageCastBoon.ReportedDifference = extraManaCost
    TraitData.ApolloSecondStageCastBoon.WeaponDataOverrideTraitRequirement = "ApolloExCastBoon"

    -- Clear out the vanilla ChargeStageModifiers so they don't conflict with our overrides
    TraitData.ApolloSecondStageCastBoon.ChargeStageModifiers = nil

    -- Targeted Overwrite: Map out all Cast variants explicitly
    TraitData.ApolloSecondStageCastBoon.WeaponDataOverride = 
    {
        WeaponCastArm = {
            ManaCost = 0,
            OnChargeFunctionNames = { "DoWeaponCharge" },
            ChargeWeaponData = {
                OnStageReachedFunctionName = "CastChargeStage",
                EmptyChargeFunctionName = "EmptyCastCharge",
                OnNoManaForceRelease = "NoManaCastSecondStageForceRelease"
            },
            ChargeWeaponStages = {
                { ManaCost = baseCost + extraManaCost, Wait = baseWait },
                { RequiredTraitName = "ApolloExCastBoon", ManaCost = baseCost + extraManaCost, Wait = 0, ForceRelease = true, ResetIndicator = true }
            }
        },
        WeaponCast = {
            ChargeWeaponStages = {
                { ManaCost = baseCost + extraManaCost, Wait = baseWait, ChannelSlowEventOnStart = true },
                { RequiredTraitName = "ApolloExCastBoon", ManaCost = baseCost + extraManaCost, Wait = 0, ForceRelease = true, ResetIndicator = true, SuperCharge = true }
            }
        },
        WeaponCastProjectileHades = {
            ChargeWeaponStages = {
                { ManaCost = baseCost + extraManaCost, Wait = baseWait, ChannelSlowEventOnStart = true },
                { RequiredTraitName = "ApolloExCastBoon", ManaCost = baseCost + extraManaCost, Wait = 0, ForceRelease = true, ResetIndicator = true, SuperCharge = true }
            }
        },
        WeaponAnywhereCast = {
            ChargeWeaponStages = {
                { ManaCost = baseCost + extraManaCost, Wait = baseWait, ChannelSlowEventOnStart = true },
                { RequiredTraitName = "ApolloExCastBoon", ManaCost = baseCost + extraManaCost, Wait = 0, ForceRelease = true, ResetIndicator = true, SuperCharge = true }
            }
        },
        WeaponCastProjectile = {
            ChargeWeaponStages = {
                { ManaCost = baseCost + extraManaCost, Wait = baseWait, ChannelSlowEventOnStart = true },
                { RequiredTraitName = "ApolloExCastBoon", ManaCost = baseCost + extraManaCost, Wait = 0, ForceRelease = true, ResetIndicator = true, SuperCharge = true }
            }
        },
        WeaponCastLob = {
            ChargeWeaponStages = {
                { ManaCost = baseCost + extraManaCost, Wait = baseWait, ChannelSlowEventOnStart = true },
                { RequiredTraitName = "ApolloExCastBoon", ManaCost = baseCost + extraManaCost, Wait = 0, ForceRelease = true, ResetIndicator = true, SuperCharge = true }
            }
        }
    }
    TraitData.ApolloSecondStageCastBoon.PropertyChanges = TraitData.ApolloSecondStageCastBoon.PropertyChanges or {}
    local propertyList = TraitData.ApolloSecondStageCastBoon.PropertyChanges

    local forceRelease = {
        TraitName = "ApolloExCastBoon",
        WeaponName = "WeaponCastArm",
        WeaponProperty = "ForceMaxChargeRelease",
        ChangeValue = false,
    }

    local chargeTime = {
        TraitName = "ApolloExCastBoon",
        WeaponName = "WeaponCastArm",
        WeaponProperty = "ChargeTime",
        ChangeValue = baseWait, 
    }

    if not ListContainsEquivalent(propertyList, forceRelease) then
        table.insert(propertyList, forceRelease)
    end

    if not ListContainsEquivalent(propertyList, chargeTime) then
        table.insert(propertyList, chargeTime)
    end
end

-- =============================================================================
-- MOD LOGIC
-- =============================================================================
function Utils.ApplyConfigChanges()
    RestoreBackups()

    if not config.ModEnabled then
        SetupRunData()
        return
    end

    if config.ForceMedea then
        AddToBackup(RoomSetData.N.N_Story01, "ForceAtBiomeDepthMin", "ForceAtBiomeDepthMax")
        RoomSetData.N.N_Story01.ForceAtBiomeDepthMin = 0
        RoomSetData.N.N_Story01.ForceAtBiomeDepthMax = 1
    end

    if config.ForceArachne then
        AddToBackup(RoomSetData.F.F_Story01, "ForceAtBiomeDepthMin", "ForceAtBiomeDepthMax")
        RoomSetData.F.F_Story01.ForceAtBiomeDepthMin = 4
        RoomSetData.F.F_Story01.ForceAtBiomeDepthMax = 8
    end

    if config.DisableArachnePity then
        AddToBackup(RoomSetData.F.F_Story01, "ForceIfUnseenForRuns")
        RoomSetData.F.F_Story01.ForceIfUnseenForRuns = nil
    end

    if config.CharybdisBehaviorAdjustment then
        AddToBackup(UnitSetData.Charybdis.CharybdisTentacle.AIStages[3], "WaitDuration")
        AddToBackup(WeaponData.CharybdisSpit3.AIData, "FireTicks")
        AddToBackup(WeaponDataEnemies.CharybdisSpit3.AIData, "FireTicks")

        -- for _, stage in ipairs(UnitSetData.Charybdis.CharybdisTentacle.AIStages) do
        --     if stage.FireWeapon == "CharybdisTentacleBurrow" and (stage.WaitDuration and stage.WaitDuration > 5.0) then
        --         stage.WaitDuration = 1.0 
        --         break
        --     end
        -- end
        UnitSetData.Charybdis.CharybdisTentacle.AIStages[3].WaitDuration = 1.0
        WeaponData.CharybdisSpit3.AIData.FireTicks = 6
        WeaponDataEnemies.CharybdisSpit3.AIData.FireTicks = 6
        
    end

    if config.PreventEchoScam then
        AddToBackup(RoomData["H_MiniBoss01"], "GameStateRequirements")
        AddToBackup(RoomData["H_MiniBoss02"], "GameStateRequirements")
        local newReq = {
            Path = { "CurrentRun", "BiomeDepthCache" },
            Comparison = "!=",
            Value = 3,
        }
        for _, roomName in ipairs({ "H_MiniBoss01", "H_MiniBoss02" }) do
            local reqs = RoomData[roomName].GameStateRequirements
            if reqs and not ListContainsEquivalent(reqs, newReq) then
                table.insert(reqs, newReq)
            end
        end
        -- if RoomData and RoomData.H_Bridge01 and RoomData.H_Bridge01.ForcedRewards then
        --     for _, forcedReward in ipairs( RoomData.H_Bridge01.ForcedRewards ) do
        --         if forcedReward.Name == "Story" then 
        --             forcedReward.GameStateRequirements = forcedReward.GameStateRequirements or {}
        --             forcedReward.GameStateRequirements.ChanceToPlay = 0.92
        --             break
        --         end
        --     end    
        -- end
    end

    if config.SurfaceStructureFix then
        AddToBackup(RoomSetData.P.P_Shop01, "ForceAtBiomeDepthMin", "ForceAtBiomeDepthMax")
        AddToBackup(RoomSetData.O.O_MiniBoss01, "ForceAtBiomeDepthMin", "ForceAtBiomeDepthMax")
        AddToBackup(RoomSetData.O.O_MiniBoss02, "ForceAtBiomeDepthMin", "ForceAtBiomeDepthMax")
        AddToBackup(RoomData["O_MiniBoss01"], "GameStateRequirements")
        AddToBackup(RoomData["O_MiniBoss02"], "GameStateRequirements")
        --Olympus midshop
        RoomSetData.P.P_Shop01.ForceAtBiomeDepthMin = 5
        RoomSetData.P.P_Shop01.ForceAtBiomeDepthMax = 7

        --Thessaly Minibosses
        RoomSetData.O.O_MiniBoss01.ForceAtBiomeDepthMin = 2
        RoomSetData.O.O_MiniBoss01.ForceAtBiomeDepthMax = 4
        
        RoomSetData.O.O_MiniBoss02.ForceAtBiomeDepthMin = 2
        RoomSetData.O.O_MiniBoss02.ForceAtBiomeDepthMax = 4

        local miniBossRooms = { "O_MiniBoss01", "O_MiniBoss02" }

        for _, roomName in ipairs(miniBossRooms) do
            Utils.ApplyRoomChanges(roomName, function(room)
                if not room.GameStateRequirements then return end
                
                for _, req in ipairs(room.GameStateRequirements) do
                    if req.Path and req.Path[2] == "BiomeDepthCache" then
                        if req.Comparison == ">=" and req.Value == 3 then
                            req.Value = 2
                        elseif req.Comparison == "<=" and req.Value == 5 then
                            req.Value = 4
                        end
                    end
                end
            end)
        end
    end

    if config.DisableSeleneBeforeBoon then
        AddToBackup(NamedRequirementsData, "SpellDropRequirements")
        local additionalSpellReq = {
            Path = {"CurrentRun", "LootTypeHistory"},
            CountOf = {
                "AphroditeUpgrade", "ApolloUpgrade", "DemeterUpgrade",
                "HephaestusUpgrade", "HestiaUpgrade", "HeraUpgrade",
                "PoseidonUpgrade", "ZeusUpgrade", "AresUpgrade", "WeaponUpgrade"
            },
            Comparison = ">=",
            Value = 1
        }
        
        if NamedRequirementsData and NamedRequirementsData.SpellDropRequirements then
            local targetReqs = NamedRequirementsData.SpellDropRequirements
            if not ListContainsEquivalent(targetReqs, additionalSpellReq) then
                table.insert(targetReqs, additionalSpellReq)
            end
        end
    end

    -- =============================================================================
    -- BUG FIXES
    -- =============================================================================
    if config.BugFixes.CorrosionFix then
        AddToBackup(TraitData.ArmorPenaltyCurse.OnEnemySpawnFunction.Args, "SkipOnDamagedPowers")
        Utils.ApplyTraitChanges("ArmorPenaltyCurse", function(trait)
            trait.OnEnemySpawnFunction.Args.SkipOnDamagedPowers = true
        end)
    end

    if config.BugFixes.GGGFix then
        AddToBackup(TraitData.EchoRepeatKeepsakeBoon, "GameStateRequirements")
        Utils.ApplyTraitChanges("EchoRepeatKeepsakeBoon", function(trait)
            trait.GameStateRequirements[2].HasNone = { "AthenaEncounterKeepsake", "FountainRarityKeepsake" }
            table.insert(trait.GameStateRequirements, {
                Path = { "CurrentRun", "Hero", "SlottedTraits", "Keepsake" },
                IsNone = { "HadesAndPersephoneKeepsake", "EscalatingKeepsake" }
            })
        end)
    end

    if config.BugFixes.BraidFix then
        AddToBackup(TraitData.TemporaryImprovedCastTrait.AddOutgoingDamageModifiers, "ValidProjectiles", "WeaponOrProjectileRequirement")
        Utils.ApplyTraitChanges("TemporaryImprovedCastTrait", function(trait)
            trait.AddOutgoingDamageModifiers.ValidProjectiles = WeaponSets.CastProjectileNames
            trait.AddOutgoingDamageModifiers.WeaponOrProjectileRequirement = true
        end)
    end

    if config.BugFixes.MiniBossEncounterFix then
        AddToBackup(EncounterData.MiniBossBoar,      "CountsForRoomEncounterDepth")
        AddToBackup(EncounterData.MiniBossCharybdis, "CountsForRoomEncounterDepth")
        AddToBackup(EncounterData.MiniBossTalos,     "CountsForRoomEncounterDepth")
        AddToBackup(EncounterData.BossTyphonEye01,   "CountsForRoomEncounterDepth")
        AddToBackup(EncounterData.BossTyphonArm01,   "CountsForRoomEncounterDepth")
        EncounterData.MiniBossBoar.CountsForRoomEncounterDepth = true
        EncounterData.MiniBossCharybdis.CountsForRoomEncounterDepth = true
        EncounterData.MiniBossTalos.CountsForRoomEncounterDepth = true
        EncounterData.BossTyphonEye01.CountsForRoomEncounterDepth = true
        EncounterData.BossTyphonArm01.CountsForRoomEncounterDepth = true
    end

    if config.BugFixes.ExtraDoseFix then
        AddToBackup(TraitData.DoubleStrikeChanceBoon, "PropertyChanges")
        Utils.ApplyTraitChanges("DoubleStrikeChanceBoon", function(trait)
            table.insert(trait.PropertyChanges[1].WeaponNames, "WeaponSuit2")
            table.insert(trait.PropertyChanges[1].WeaponNames, "WeaponSuitDash")
            table.insert(trait.PropertyChanges[4].WeaponNames, "WeaponSuit2")
            table.insert(trait.PropertyChanges[4].WeaponNames, "WeaponSuitDash")
        end)
    end

    if config.BugFixes.PoseidonWavesFix then
        AddToBackup(TraitData.PoseidonSpecialBoon.OnEnemyDamagedAction.Args, "MultihitProjectileWhitelist", "MultihitProjectileConditions")
        Utils.ApplyTraitChanges("PoseidonSpecialBoon", function(trait)
            local args = trait.OnEnemyDamagedAction.Args
            table.insert(args.MultihitProjectileWhitelist, "ProjectileAxeSpecial")
            args.MultihitProjectileConditions.ProjectileAxeSpecial = { Count = 4, Window = 0.3 }
            args.MultihitProjectileConditions.ProjectileTorchOrbit.Count = 4
        end)
    end

    if config.BugFixes.TidalRingFix then
        AddToBackup(ProjectileData.PoseidonCastSplashSplinter, "ImmunityDuration")
        if ProjectileData and ProjectileData.PoseidonCastSplashSplinter then
            ProjectileData.PoseidonCastSplashSplinter.ImmunityDuration = 0
        end
    end

    if config.BugFixes.SeleneFix then
        AddToBackup(NamedRequirementsData, "SpellDropRequirements")
        table.insert(NamedRequirementsData.SpellDropRequirements, {
            PathFalse = { "CurrentRun", "Hero", "TraitDictionary", "SuitHexAspect" }
        })
    end

    if config.BugFixes.ShimmeringFix then
        AddToBackup(TraitData.StaffJumpSpecialTrait.AddOutgoingDamageModifiers, "ProjectileName", "ValidProjectiles")
        AddToBackup(TraitData.StaffJumpSpecialTrait, "PropertyChanges")
        Utils.ApplyTraitChanges("StaffJumpSpecialTrait", function(trait)
            trait.AddOutgoingDamageModifiers.ProjectileName = nil
            trait.AddOutgoingDamageModifiers.ValidProjectiles = { "ProjectileStaffBall", "ProjectileStaffBallCharged" }
            for _, propertyChange in ipairs(trait.PropertyChanges) do
                propertyChange.ProjectileNames = { "ProjectileStaffBall", "ProjectileStaffBallCharged" }
            end
        end)
    end


    if config.BugFixes.StagedOmegaFix then
        AddToBackup(WeaponData.WeaponDaggerThrow, "MinWeaponChargeTime")
        AddToBackup(WeaponData.WeaponAxeSpin,     "MinWeaponChargeTime")
        WeaponData.WeaponDaggerThrow.MinWeaponChargeTime = 0.05
        -- WeaponData.WeaponDaggerThrow.RushOverride = nil

        WeaponData.WeaponAxeSpin.MinWeaponChargeTime = 0.05
    end
    
    if config.BugFixes.ETFix then
        AddToBackup(TraitData, "DoubleExManaBoon")
        Utils.ApplyTraitChanges("DoubleExManaBoon", function(trait)
            for _, propertyChange in ipairs(trait.PropertyChanges or {}) do
                if Contains(propertyChange.FalseTraitNames, "StaffOneWayAttackTrait") then
                    Utils.SafeArrayInsert(propertyChange, "FalseTraitNames", "StaffRaiseDeadAspect")
                    break
                end
            end

            trait.OnWeaponFiredFunctions =
            {
                ValidWeapons = { "WeaponStaffSwing5" },
                FunctionName = "CreateSecondAnubisWall",
                FunctionArgs = { Distance = 340 },
                ExcludeLinked = true,
            }
        end)
    end

    if config.BugFixes.SecondStageChannelingFix then
        AddToBackup(TraitData, "ApolloSecondStageCastBoon")
        AddToBackup(TraitData, "StaffSecondStageTrait")
        PatchGloriousDisaster()
        ReplaceGigaMoonburst()
    end

    if config.BugFixes.OmegaCastEffectsFix then
        AddToBackup(WeaponSets, "CastProjectileNames")
        local missingCastProjectiles =
        {
            "ApolloCastRapid",
            "AresProjectile",
            "ZeusApolloSynergyStrike",
            "DemeterCastStorm",
            "AthenaCastProjectile",
        }
        for _, projectileName in ipairs(missingCastProjectiles) do
            table.insert(WeaponSets.CastProjectileNames, projectileName)
        end
    end

    if config.BugFixes.CardioTorchFix then
        AddToBackup(TraitData.HestiaManaBoon.OnEnemyDamagedAction.Args, "MultihitProjectileWhitelist", "MultihitProjectileConditions")
        Utils.ApplyTraitChanges("HestiaManaBoon", function(trait)
            local args = trait.OnEnemyDamagedAction.Args
            table.insert(args.MultihitProjectileWhitelist, "ProjectileTorchOrbit")
            args.MultihitProjectileConditions.ProjectileTorchOrbit = { Cooldown = 0.01 }
        end)
    end

    if config.BugFixes.FamiliarDelayFix then
        AddToBackup(RoomEventData, "GlobalRoomStartEvents")
        AddToBackup(RoomEventData, "GlobalRoomInputUnblockedEvents")
        table.insert(RoomEventData.GlobalRoomStartEvents, {
            Threaded = true,
            FunctionName = "FamiliarSetup",
            Args = {},   -- no WaitForInput, no Wait
            GameStateRequirements = {
                { PathTrue = { "GameState", "EquippedFamiliar" } },
            },
        })
        local unblocked = RoomEventData.GlobalRoomInputUnblockedEvents
        for i = #unblocked, 1, -1 do
            if unblocked[i].FunctionName == "FamiliarSetup" then
                table.remove(unblocked, i)
            end
        end
    end

    SetupRunData()
end

if config.ModEnabled then
    Utils.ApplyConfigChanges()
end 
