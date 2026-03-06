-- local modutil = rom.mods['SGG_Modding-ModUtil']
local Utils = adamant_RunDirector

local hasForcedHammerThisRun = false

-- =============================================================================
-- SHARED DATA ARRAYS
-- =============================================================================

Utils.hammerData = {
    WeaponStaffSwing = { 
        values = { "", "StaffDoubleAttackTrait", "StaffLongAttackTrait", "StaffDashAttackTrait", "StaffTripleShotTrait", "StaffJumpSpecialTrait", "StaffExAoETrait", "StaffAttackRecoveryTrait", "StaffFastSpecialTrait", "StaffExHealTrait", "StaffSecondStageTrait", "StaffPowershotTrait", "StaffOneWayAttackTrait", "StaffRaiseDeadBigTrait", "StaffRaiseDeadDoubleTrait", "StaffLoneShadeRespawnTrait", "StaffLoneShadeRallyTrait" } 
    },
    WeaponDagger = { 
        values = { "", "DaggerBlinkAoETrait", "DaggerSpecialJumpTrait", "DaggerSpecialLineTrait", "DaggerRapidAttackTrait", "DaggerSpecialConsecutiveTrait", "DaggerBackstabTrait", "DaggerSpecialReturnTrait", "DaggerSpecialFanTrait", "DaggerAttackFinisherTrait", "DaggerFinalHitTrait", "DaggerChargeStageSkipTrait", "DaggerDashAttackTripleTrait", "DaggerTripleBuffTrait", "DaggerTripleRepeatWomboTrait", "DaggerTripleHomingSpecialTrait" } 
    },
    WeaponAxe = { 
        values = { "", "AxeSpinSpeedTrait", "AxeChargedSpecialTrait", "AxeAttackRecoveryTrait", "AxeMassiveThirdStrikeTrait", "AxeThirdStrikeTrait", "AxeRangedWhirlwindTrait", "AxeFreeSpinTrait", "AxeArmorTrait", "AxeBlockEmpowerTrait", "AxeSecondStageTrait", "AxeDashAttackTrait", "AxeSturdyTrait", "AxeRallyFrenzyTrait", "AxeRallyFirstStrikeTrait" } 
    },
    WeaponTorch = { 
        values = { "", "TorchExSpecialCountTrait", "TorchSpecialSpeedTrait", "TorchAttackSpeedTrait", "TorchSpecialLineTrait", "TorchSpecialImpactTrait", "TorchMoveSpeedTrait", "TorchSplitAttackTrait", "TorchEnhancedAttackTrait", "TorchDiscountExAttackTrait", "TorchLongevityTrait", "TorchOrbitPointTrait", "TorchSpinAttackTrait", "TorchAutofireSprintTrait" } 
    },
    WeaponLob = { 
        values = { "", "LobAmmoTrait", "LobAmmoMagnetismTrait", "LobRushArmorTrait", "LobSpreadShotTrait", "LobSpecialSpeedTrait", "LobSturdySpecialTrait", "LobOneSideTrait", "LobInOutSpecialExTrait", "LobStraightShotTrait", "LobPulseAmmoTrait", "LobPulseAmmoCollectTrait", "LobGrowthTrait", "LobGunOverheatTrait", "LobGunBounceTrait", "LobGunSpecialBounceTrait", "LobGunAttackRangeTrait", "LobGunAttackDoublerTrait" } 
    },
    WeaponSuit = { 
        values = { "", "SuitArmorTrait", "SuitAttackSpeedTrait", "SuitAttackSizeTrait", "SuitAttackRangeTrait", "SuitFullChargeTrait", "SuitDashAttackTrait", "SuitSpecialJumpTrait", "SuitSpecialStartUpTrait", "SuitSpecialAutoTrait", "SuitSpecialBlockTrait", "SuitSpecialDiscountTrait", "SuitSpecialConsecutiveHitTrait", "SuitComboForwardRocketTrait", "SuitComboBlockBuffTrait", "SuitComboDoubleSpecialTrait", "SuitComboDashAttackTrait", "SuitPowershotTrait" } 
    },
}

Utils.weaponLabels = {
    WeaponStaffSwing = "Staff",
    WeaponDagger     = "Blades",
    WeaponAxe        = "Axe",
    WeaponTorch      = "Flames",
    WeaponLob        = "Skull",
    WeaponSuit       = "Coat"
}

Utils.weaponDrawOrder = {
    "WeaponStaffSwing", "WeaponDagger", "WeaponAxe", 
    "WeaponTorch", "WeaponLob", "WeaponSuit"
}

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

function Utils.GetEquippedWeapon()
    if not CurrentRun or not CurrentRun.Hero then return "WeaponStaffSwing" end
    for k, weaponName in ipairs(WeaponSets.HeroPrimaryWeapons) do
        if CurrentRun.Hero.Weapons[weaponName] then
            return weaponName
        end
    end
    return "WeaponStaffSwing"
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

-- =============================================================================
-- MOD LOGIC
-- =============================================================================
if config.ModEnabled then
    --[[
    if config.RTAMode then
        --Erebus
        -- Utils.SafeArrayRemove(EncounterSets, "FEncountersDefault", { "ArtemisCombatF", "ArtemisCombatF2", "NemesisCombatF" })
        -- --Oceanus
        -- Utils.SafeArrayRemove(EncounterSets, "GEncountersDefault", { "ArtemisCombatG", "ArtemisCombatG2", "NemesisCombatG" })
        -- --Fields
        -- Utils.SafeArrayRemove(EncounterSets, "HEncountersDefault", { "NemesisCombatH" })
        -- --Tartarus
        -- Utils.SafeArrayRemove(EncounterSets, "IEncountersDefault", { "NemesisCombatI"})
        -- Utils.SafeArrayRemove(EncounterSets, "IEncountersSmaller", { "NemesisCombatI"})

        -- --Ephyra
        -- Utils.SafeArrayRemove(EncounterSets, "NEncountersDefault", { "ArtemisCombatN", "ArtemisCombatN2", "HeraclesCombatN", "HeraclesCombatN2"})
        -- Utils.SafeArrayRemove(EncounterSets, "NEncountersSmaller", { "ArtemisCombatN", "ArtemisCombatN2", "HeraclesCombatN", "HeraclesCombatN2"})
        -- Utils.SafeArrayRemove(EncounterSets, "NEncountersBigger", { "ArtemisCombatN", "ArtemisCombatN2", "HeraclesCombatN", "HeraclesCombatN2"})
        -- --Thessaly
        -- Utils.SafeArrayRemove(EncounterSets, "OEncountersDefault", { "IcarusCombatO", "IcarusCombatO2" })
        -- Utils.SafeArrayRemove(EncounterSets, "OEncountersIntros", { "HeraclesCombatO", "HeraclesCombatO2" })
        -- --Olympus
        -- Utils.SafeArrayRemove(EncounterSets, "PEncountersDefault", { "AthenaCombatP", "AthenaCombatP02", "IcarusCombatP" })
        -- Utils.SafeArrayRemove(EncounterSets, "PEncountersIntros", { "HeraclesCombatP", "HeraclesCombatO2" })
    end
    --]]

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
    if config.MedeaPity then
        -- RoomSetData.F.F_Story01.ForceIfUnseenForRuns = nil

        RoomSetData.N.N_Story01.ForceAtBiomeDepthMin = 0
        RoomSetData.N.N_Story01.ForceAtBiomeDepthMax = 1
    end

    if config.ArachnePity then
        RoomSetData.F.F_Story01.ForceAtBiomeDepthMin = 4
        RoomSetData.F.F_Story01.ForceAtBiomeDepthMax = 8
    end

    if config.DisableArachnePity then
        RoomSetData.F.F_Story01.ForceIfUnseenForRuns = nil
    end

    if config.CharybdisBehaviorAdjustment then
        -- UnitSetData.Charybdis.CharybdisTentacle.AIStages[3].WaitDuration = 1.0
        for _, stage in ipairs(UnitSetData.Charybdis.CharybdisTentacle.AIStages) do
            if stage.FireWeapon == "CharybdisTentacleBurrow" and (stage.WaitDuration and stage.WaitDuration > 5.0) then
                stage.WaitDuration = 1.0 
                break
            end
        end
        WeaponData.CharybdisSpit3.AIData.FireTicks = 6
        WeaponDataEnemies.CharybdisSpit3.AIData.FireTicks = 6
        
    end

    if config.PreventEchoScam then
        local targetRoom = (math.random(1, 2) == 1) and "H_MiniBoss01" or "H_MiniBoss02"
        if RoomData and RoomData[targetRoom] and RoomData[targetRoom].GameStateRequirements then
            local newReq = {
                Path = { "CurrentRun", "BiomeDepthCache" },
                Comparison = "!=",
                Value = 3,
            }
            
            local reqs = RoomData[targetRoom].GameStateRequirements
            if not ListContainsEquivalent(reqs, newReq) then
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
        Utils.ApplyTraitChanges("ArmorPenaltyCurse", function(trait)
            if trait.OnEnemySpawnFunction then
                trait.OnEnemySpawnFunction.Args.SkipOnDamagedPowers = true
            end
        end) 
    end

    if config.BugFixes.GGGFix then
        Utils.ApplyTraitChanges("EchoRepeatKeepsakeBoon", function(trait)
            local reqs = trait.GameStateRequirements
            if reqs then
                for _, req in ipairs(reqs) do
                    if req.Path and req.Path[3] == "TraitDictionary" and req.HasNone then
                        req.HasNone = { "AthenaEncounterKeepsake", "FountainRarityKeepsake" }
                        break
                    end
                end
                
                local newReq = {
                    Path = { "CurrentRun", "Hero", "SlottedTraits", "Keepsake" },
                    IsNone = { "HadesAndPersephoneKeepsake", "EscalatingKeepsake" }
                }
                if not ListContainsEquivalent(reqs, newReq) then
                    table.insert(reqs, newReq)
                end
            end
        end)
    end

    if config.BugFixes.BraidFix then
        Utils.ApplyTraitChanges("TemporaryImprovedCastTrait", function(trait)
            if trait.AddOutgoingDamageModifiers then
                trait.AddOutgoingDamageModifiers.ValidProjectiles = WeaponSets.CastProjectileNames
                trait.AddOutgoingDamageModifiers.WeaponOrProjectileRequirement = true
            end
        end)
    end

    if config.BugFixes.MiniBossEncounterFix then
        EncounterData.MiniBossBoar.CountsForRoomEncounterDepth = true
        EncounterData.MiniBossCharybdis.CountsForRoomEncounterDepth = true
        EncounterData.MiniBossTalos.CountsForRoomEncounterDepth = true
        EncounterData.BossTyphonEye01.CountsForRoomEncounterDepth = true
        EncounterData.BossTyphonArm01.CountsForRoomEncounterDepth = true
    end

    if config.BugFixes.ExtraDoseFix then
        Utils.ApplyTraitChanges("DoubleStrikeChanceBoon", function(trait)
            if trait.PropertyChanges then
                if trait.PropertyChanges[1] then
                    Utils.SafeArrayInsert(trait.PropertyChanges[1], "WeaponNames", "WeaponSuit2")
                    Utils.SafeArrayInsert(trait.PropertyChanges[1], "WeaponNames", "WeaponSuitDash")
                end
                if trait.PropertyChanges[4] then
                    Utils.SafeArrayInsert(trait.PropertyChanges[4], "WeaponNames", "WeaponSuit2")
                    Utils.SafeArrayInsert(trait.PropertyChanges[4], "WeaponNames", "WeaponSuitDash")
                end
            end
        end)
    end

    if config.BugFixes.PoseidonWavesFix then
        Utils.ApplyTraitChanges("PoseidonSpecialBoon", function(trait)
            if trait.OnEnemyDamagedAction and trait.OnEnemyDamagedAction.Args then
                local args = trait.OnEnemyDamagedAction.Args
                if args.MultihitProjectileWhitelist and args.MultihitProjectileConditions then
                    Utils.SafeArrayInsert(args, "MultihitProjectileWhitelist", "ProjectileAxeSpecial")
                    args.MultihitProjectileConditions.ProjectileAxeSpecial = { Count = 4, Window = 0.3 }
                    args.MultihitProjectileConditions.ProjectileTorchOrbit = args.MultihitProjectileConditions.ProjectileTorchOrbit or {}
                    args.MultihitProjectileConditions.ProjectileTorchOrbit.Count = 4
                end
            end
        end)
    end

    if config.BugFixes.TidalRingFix then
        if ProjectileData and ProjectileData.PoseidonCastSplashSplinter then
            ProjectileData.PoseidonCastSplashSplinter.ImmunityDuration = 0
        end
    end

    if config.BugFixes.SeleneFix then
        if NamedRequirementsData and NamedRequirementsData.SpellDropRequirements then
            local spellLegal = NamedRequirementsData.SpellDropRequirements
            local newReq = {
                PathFalse = { "CurrentRun", "Hero", "TraitDictionary", "SuitHexAspect" }
            }
            if not ListContainsEquivalent(spellLegal, newReq) then
                table.insert(spellLegal, newReq)
            end
        end
    end

    if config.BugFixes.ShimmeringFix then
        Utils.ApplyTraitChanges("StaffJumpSpecialTrait", function(trait)
            if trait.AddOutgoingDamageModifiers then
                trait.AddOutgoingDamageModifiers.ProjectileName = nil
                trait.AddOutgoingDamageModifiers.ValidProjectiles = { "ProjectileStaffBall", "ProjectileStaffBallCharged" }
            end
            if trait.PropertyChanges then
                for _, propertyChange in ipairs( trait.PropertyChanges ) do
                    if propertyChange.WeaponName == "WeaponStaffBall" then
                        propertyChange.ProjectileNames = { "ProjectileStaffBall", "ProjectileStaffBallCharged" }
                    end
                end
            end
        end)
    end

    if config.BugFixes.StagedOmegaFix then
        WeaponData.WeaponDaggerThrow.MinWeaponChargeTime = 0.05
        -- WeaponData.WeaponDaggerThrow.RushOverride = nil

        WeaponData.WeaponAxeSpin.MinWeaponChargeTime = 0.05
    end

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

    if config.BugFixes.ETFix then
        Utils.ApplyTraitChanges("DoubleExManaBoon", function(trait)
            if trait.PropertyChanges then
                for _, propertyChange in ipairs(trait.PropertyChanges) do
                    if propertyChange.FalseTraitNames then
                        local isTargetBlock = false
                        for _, traitName in ipairs(propertyChange.FalseTraitNames) do
                            if traitName == "StaffOneWayAttackTrait" then
                                isTargetBlock = true
                                break
                            end
                        end
                        if isTargetBlock then
                            Utils.SafeArrayInsert(propertyChange, "FalseTraitNames", "StaffRaiseDeadAspect")
                            break 
                        end
                    end
                end
            end

            trait.OnWeaponFiredFunctions = 
            {
                ValidWeapons = { "WeaponStaffSwing5" },
                FunctionName = "CreateSecondAnubisWall",
                FunctionArgs = { Distance = 340 },
                ExcludeLinked = true,
            }
            -- trait.AutofireOmegaSpeedMultiplier = 
            -- { 
            --     BaseValue = 0.5, 
            --     SourceIsMultiplier = true 
            -- }
        end)
    end

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

    modutil.mod.Path.Wrap("CheckAxeCastArm", function(baseFunc, triggerArgs, args)
        if config.ModEnabled and config.BugFixes.SecondStageChannelingFix then
            if HeroHasTrait("ApolloExCastBoon") and HeroHasTrait("ApolloSecondStageCastBoon") then
                SessionMapState.SuperchargeCast = true
            end
        end
        baseFunc(triggerArgs, args)


    end)

    if config.BugFixes.SecondStageChannelingFix then
        PatchGloriousDisaster()
        ReplaceGigaMoonburst()
    end

    if config.BugFixes.OmegaCastEffectsFix then
        local missingCastProjectiles = 
        {
            "ApolloCastRapid",
            "AresProjectile",
            "ZeusApolloSynergyStrike",
            "DemeterCastStorm",
            "AthenaCastProjectile"
        }

        for _, projectileName in ipairs(missingCastProjectiles) do
            Utils.SafeArrayInsert(WeaponSets, "CastProjectileNames", projectileName)
        end
    end

    if config.BugFixes.CardioTorchFix then
        Utils.ApplyTraitChanges("HestiaManaBoon", function(trait)
            if trait.OnEnemyDamagedAction and trait.OnEnemyDamagedAction.Args then
                local args = trait.OnEnemyDamagedAction.Args

                -- 2. Safely add the Torch Special to the multihit whitelist using your helper
                Utils.SafeArrayInsert(args, "MultihitProjectileWhitelist", "ProjectileTorchOrbit")

                -- 3. Define the exact internal cooldown condition
                args.MultihitProjectileConditions = args.MultihitProjectileConditions or {}
                args.MultihitProjectileConditions["ProjectileTorchOrbit"] = { Cooldown = 0.01 } 
            end
        end)
    end

    if config.BugFixes.FamiliarDelayFix then
        local familiarLinkEvent = 
        {
            Threaded = true,
            FunctionName = "FamiliarSetup",
            Args = {},   -- no WaitForInput, no Wait
            GameStateRequirements = {
                { PathTrue = { "GameState", "EquippedFamiliar" } },
            },
        }

        RoomEventData.GlobalRoomStartEvents = RoomEventData.GlobalRoomStartEvents or {}
        if not ListContainsEquivalent(RoomEventData.GlobalRoomStartEvents, familiarLinkEvent) then
            table.insert(RoomEventData.GlobalRoomStartEvents, familiarLinkEvent)
        end    
        local unblocked = RoomEventData.GlobalRoomInputUnblockedEvents
        if unblocked then
            for i = #unblocked, 1, -1 do
                if type(unblocked[i]) == "table" and unblocked[i].FunctionName == "FamiliarSetup" then
                    table.remove(unblocked, i)
                end
            end
        end
    end

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

    
    SetupRunData()
end
-- =============================================================================
-- MOD ENGINE HOOKS
-- =============================================================================
--Special wrap to reset the forced hammer flag at the start of each run and handle Selene Aspect's initial hex record
modutil.mod.Path.Wrap("StartNewRun", function(baseFunc, prevRun, args)
    hasForcedHammerThisRun = false

    local currentRun = baseFunc(prevRun, args)

    if config.ModEnabled and config.BugFixes.SeleneFix then
        if HeroHasTrait("SuitHexAspect") then
            if config.DebugMode then
                print("Starting run with Selene Aspect - granting Selene's Boon")
            end
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
            
            if config.DebugMode then
                print("Starting run with Selene Aspect and Moonbeam - granting Path of Stars Directly")
            end
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
        
        local currentWeapon = Utils.GetEquippedWeapon()
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
                if config.DebugMode then
                    print("StartingHammer: " .. desiredHammer .. " is ineligible! Falling back to random.")
                end
            end
            
            -- Lock out the mod for the rest of the run so future hammers are natural
            hasForcedHammerThisRun = true
        end
    end
end)

--Removing Poseiidon Waves from interacting with cardio gain
-- modutil.mod.Path.Wrap("CheckManaOnHit", function(baseFunc, victim, functionArgs, triggerArgs)
--     if not config.BugFixes.CardioTorchFix then
--         return baseFunc(victim, functionArgs, triggerArgs)
--     end
--     if functionArgs.IsNotEx and IsExWeapon( triggerArgs.SourceWeapon, {Combat = true}, triggerArgs ) then
-- 		return
-- 	end	
-- 	local validWeapons = ConcatTableValues( ShallowCopyTable(functionArgs.ValidWeapons), AddLinkedWeapons( functionArgs.ValidWeapons))
-- 	local passesHitCheck = functionArgs.FirstHitOnly == nil or (functionArgs.FirstHitOnly and not ProjectileHasUnitHit( triggerArgs.ProjectileId, "ManaOnHit" ))
	
-- 	if triggerArgs.SourceProjectile ~= nil and functionArgs.MultihitProjectileWhitelistLookup and functionArgs.MultihitProjectileWhitelistLookup[triggerArgs.SourceProjectile] and functionArgs.MultihitProjectileConditions[triggerArgs.SourceProjectile] then
-- 		local conditions = functionArgs.MultihitProjectileConditions[triggerArgs.SourceProjectile]
-- 		passesHitCheck = true
-- 		if conditions.Cooldown then
-- 			passesHitCheck = false
-- 		end
-- 	end
-- 	if Contains( validWeapons, triggerArgs.SourceWeapon ) and passesHitCheck then
-- 		ProjectileRecordUnitHit( triggerArgs.ProjectileId, "ManaOnHit")
-- 		ManaDelta(functionArgs.ManaGain)
-- 	end

-- end)

