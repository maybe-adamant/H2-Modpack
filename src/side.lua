--============================================================================--
--Apollo Second Stage Cast Boon V2
--Glorious Disaster without second cast at all
--============================================================================--


ApolloSecondStageCastBoon_V2 = -- Apollo x Zeus
{
    InheritFrom = {"SynergyTrait"},
    Icon = "Boon_Zeus_41",
    GameStateRequirements =
    {
        {
            PathTrue = { "CurrentRun", "Hero", "TraitDictionary", "ApolloExCastBoon" },
        }
    },
    ReportedDifference = 30, -- display variable for charge difference
    
    ManaCostModifiers = 
    {
        WeaponNames = { "WeaponCast", "WeaponCastArm", "WeaponCastProjectileHades", "WeaponAnywhereCast", "WeaponCastProjectile", "WeaponCastLob" },
        ExWeapons = true,
        ManaCostAdd = 30,
    },

    OnEnemyDamagedAction = 
    {
        ValidProjectiles = { "ApolloCastRapid",},
        -- IsEx = true,
        FunctionName = "RecordSecondStageApolloCast",
        Args = 
        {
            ProjectileName = "ZeusApolloSynergyStrike",
            RequiredTrait = "ApolloExCastBoon",
            DamageMultiplier = 1
        },
    },
    StatLines =
    {
        "BoltDamageStatDisplay3",
    },
    ExtractValues =
    {
        {
            Key = "ReportedDifference",
            ExtractAs = "Cost",
            SkipAutoExtract = true,
        },
        {
            External = true,
            ExtractAs = "Damage",
            BaseType = "ProjectileBase",
            BaseName = "ZeusApolloSynergyStrike",
            BaseProperty = "Damage",
        },
        {
            ExtractAs = "Fuse",
            SkipAutoExtract = true,
            External = true,
            BaseType = "ProjectileBase",
            BaseName = "ApolloCast",
            BaseProperty = "Fuse",
            DecimalPlaces = 2,
        },
    },
    PackageName = "ZeusUpgrade",
},

modutil.mod.Path.Wrap ( "RecordSecondStageApolloCast", function(victim, functionArgs, triggerArgs )
	-- FIX: Initialize the table to prevent a silent crash if this function fires early
	SessionMapState.ValidSuperchargeCastIds = SessionMapState.ValidSuperchargeCastIds or {}

	if not SessionMapState.ValidSuperchargeCastIds[triggerArgs.ProjectileId] or ( functionArgs.RequiredTrait and not HeroHasTrait( functionArgs.RequiredTrait )) then
		return
	end
	thread( CreateZeusBolt, {
		TargetId = victim.ObjectId,
		WeaponName = "WeaponCast",
		ProjectileName = functionArgs.ProjectileName, 
		DamageMultiplier = functionArgs.DamageMultiplier,
		InitialDelay = 0,
		Delay = 0.1 })
end)

modutil.mod.Path.Wrap ("CheckArmedApolloCast", function( triggerArgs, functionArgs )
	if CurrentRun.CurrentRoom.Encounter and CurrentRun.CurrentRoom.Encounter.BossKillPresentation then
		return
	end

	if triggerArgs.name == functionArgs.ValidProjectileName and triggerArgs.Armed and triggerArgs.LocationX and triggerArgs.LocationY and triggerArgs.Detonated then
		if SessionMapState.InvalidRepeatCastIds[triggerArgs.ProjectileId] then
			return
		end
		local modifier = GetProjectileProperty({ ProjectileId = triggerArgs.ProjectileId, Property = "BlastRadiusModifier" })
		
		local dropLocation = SpawnObstacle({ Name = "InvisibleTarget", LocationX = triggerArgs.LocationX, LocationY = triggerArgs.LocationY  })
		local derivedValues = GetDerivedPropertyChangeValues({
			ProjectileName = functionArgs.ProjectileName,
			WeaponName = triggerArgs.WeaponName ,
			Type = "Projectile",
			MatchProjectileName = true,
		})
		local projectileId = CreateProjectileFromUnit({ Name = functionArgs.ProjectileName, Id = CurrentRun.Hero.ObjectId, DestinationId = dropLocation, FireFromTarget = true,
			BlastRadiusModifier = modifier, DamageMultiplier = functionArgs.DamageMultiplier, DataProperties = derivedValues.PropertyChanges, ThingProperties = derivedValues.ThingPropertyChanges })
		if triggerArgs.ProjectileId and SessionMapState.MarkedEnemies[triggerArgs.ProjectileId] then
			SessionMapState.MarkedEnemies[projectileId] = DeepCopyTable(SessionMapState.MarkedEnemies[triggerArgs.ProjectileId])
			SessionMapState.MarkedEnemies[triggerArgs.ProjectileId] = nil
		end

		-- FIX: Safely initialize the tracking table so indexing it doesn't cause a silent thread crash
		SessionMapState.ValidSuperchargeCastIds = SessionMapState.ValidSuperchargeCastIds or {}
		
		-- FIX: Safely check if the dying projectile was an EX cast, circumventing the race condition
		local isExCast = SessionMapState.SuperchargeCast or IsExWeapon(triggerArgs.WeaponName, {Combat = true}, triggerArgs) or triggerArgs.IsEx

		if HeroHasTrait("ApolloExCastBoon") and HeroHasTrait("ApolloSecondStageCastBoon_V2") and ( isExCast or ( HeroHasTrait("TransformExCastTalent") and not IsEmpty(MapState.TransformArgs)))then
			SessionMapState.ValidSuperchargeCastIds[ projectileId ] = true
			SessionMapState.SuperchargeCast = nil
		end
		Destroy({Id = dropLocation })	
	end
end)


--============================================================================
--Fully Dynamic Apollo-Zeus Synergy Table Builder
--============================================================================

local function PatchApolloZeusSynergy()
    -- Ensure TraitData and WeaponData exist before modifying
    if TraitData == nil or TraitData.ApolloSecondStageCastBoon == nil or WeaponData == nil then
        return
    end

    local synergyBoon = TraitData.ApolloSecondStageCastBoon
    local targetWeapons = { "WeaponCastProjectileHades", "WeaponAnywhereCast", "WeaponCastProjectile", "WeaponCastLob" }
    local dynamicOverrides = {}
    local extraManaCost = 30

    -- Handle the arming weapon (WeaponCastArm) separately
    local baseArmCost = 15
    local baseArmWait = 0.8
    if WeaponData.WeaponCastArm and WeaponData.WeaponCastArm.ChargeWeaponStages and WeaponData.WeaponCastArm.ChargeWeaponStages[1] then
        baseArmCost = WeaponData.WeaponCastArm.ChargeWeaponStages[1].ManaCost or baseArmCost
        baseArmWait = WeaponData.WeaponCastArm.ChargeWeaponStages[1].Wait or baseArmWait
    end

    dynamicOverrides.WeaponCastArm = {
        ManaCost = 0,
        OnChargeFunctionNames = { "DoWeaponCharge" },
        ChargeWeaponData = {
            OnStageReachedFunctionName = "CastChargeStage",
            EmptyChargeFunctionName = "EmptyCastCharge",
            OnNoManaForceRelease = "NoManaCastSecondStageForceRelease"
        },
        ChargeWeaponStages = {
            { 
                ManaCost = baseArmCost + extraManaCost, 
                Wait = baseArmWait 
            },
            { 
                RequiredTraitName = "ApolloExCastBoon", 
                ManaCost = baseArmCost + extraManaCost, 
                Wait = 0, 
                ForceRelease = true, 
                ResetIndicator = true 
            }
        }
    }

    -- Loop through the projectile weapons and build them dynamically
    for _, weaponName in ipairs(targetWeapons) do
        local baseWait = 0.8
        local baseCost = 15
        
        if WeaponData[weaponName] and WeaponData[weaponName].ChargeWeaponStages and WeaponData[weaponName].ChargeWeaponStages[1] then
            baseWait = WeaponData[weaponName].ChargeWeaponStages[1].Wait or baseWait
            baseCost = WeaponData[weaponName].ChargeWeaponStages[1].ManaCost or baseCost
        end

        dynamicOverrides[weaponName] = {
            ChargeWeaponStages = {
                { 
                    ManaCost = baseCost + extraManaCost, 
                    Wait = baseWait, 
                    ChannelSlowEventOnStart = true 
                },
                { 
                    RequiredTraitName = "ApolloExCastBoon", 
                    ManaCost = baseCost + extraManaCost, 
                    Wait = 0, 
                    ForceRelease = true, 
                    ResetIndicator = true, 
                    SuperCharge = true 
                }
            }
        }
    end

    -- Apply the dynamic table to the trait
    synergyBoon.ReportedDifference = extraManaCost
    synergyBoon.WeaponDataOverrideTraitRequirement = "ApolloExCastBoon"
    synergyBoon.WeaponDataOverride = dynamicOverrides

    synergyBoon.ChargeStageModifiers = nil
    
    -- Ensure property changes sync with the dynamic arm wait time
    synergyBoon.PropertyChanges = {
        {
            TraitName = "ApolloExCastBoon",
            WeaponName = "WeaponCastArm",
            WeaponProperty = "ForceMaxChargeRelease",
            ChangeValue = false,
        },
        {
            TraitName = "ApolloExCastBoon",
            WeaponName = "WeaponCastArm",
            WeaponProperty = "ChargeTime",
            ChangeValue = baseArmWait, 
        }
    }
end
