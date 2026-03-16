-- =============================================================================
-- HAMMERS MODULE (special: dropdown per aspect, not a boolean toggle)
-- =============================================================================
-- This module is NOT registered in the standard Registry because it uses
-- per-aspect dropdown config rather than a boolean toggle. The UI, hash system,
-- and coordinator handle it as a special case.
--
-- Owns all weapon/aspect/hammer data and the runtime hooks for forcing hammers.

local Utils = adamant_Modpack

-- =============================================================================
-- WEAPON & ASPECT DATA
-- =============================================================================

Utils.hammerData = {
	WeaponStaffSwing = {
		values = {
			"",
			"StaffDoubleAttackTrait",
			"StaffLongAttackTrait",
			"StaffDashAttackTrait",
			"StaffTripleShotTrait",
			"StaffJumpSpecialTrait",
			"StaffExAoETrait",
			"StaffAttackRecoveryTrait",
			"StaffFastSpecialTrait",
			"StaffExHealTrait",
			"StaffSecondStageTrait",
			"StaffPowershotTrait",
			"StaffOneWayAttackTrait",
			"StaffRaiseDeadBigTrait",
			"StaffRaiseDeadDoubleTrait",
			"StaffLoneShadeRespawnTrait",
			"StaffLoneShadeRallyTrait",
		},
	},
	WeaponDagger = {
		values = {
			"",
			"DaggerBlinkAoETrait",
			"DaggerSpecialJumpTrait",
			"DaggerSpecialLineTrait",
			"DaggerRapidAttackTrait",
			"DaggerSpecialConsecutiveTrait",
			"DaggerBackstabTrait",
			"DaggerSpecialReturnTrait",
			"DaggerSpecialFanTrait",
			"DaggerAttackFinisherTrait",
			"DaggerFinalHitTrait",
			"DaggerChargeStageSkipTrait",
			"DaggerDashAttackTripleTrait",
			"DaggerTripleBuffTrait",
			"DaggerTripleRepeatWomboTrait",
			"DaggerTripleHomingSpecialTrait",
		},
	},
	WeaponAxe = {
		values = {
			"",
			"AxeSpinSpeedTrait",
			"AxeChargedSpecialTrait",
			"AxeAttackRecoveryTrait",
			"AxeMassiveThirdStrikeTrait",
			"AxeThirdStrikeTrait",
			"AxeRangedWhirlwindTrait",
			"AxeFreeSpinTrait",
			"AxeArmorTrait",
			"AxeBlockEmpowerTrait",
			"AxeSecondStageTrait",
			"AxeDashAttackTrait",
			"AxeSturdyTrait",
			"AxeRallyFrenzyTrait",
			"AxeRallyFirstStrikeTrait",
		},
	},
	WeaponTorch = {
		values = {
			"",
			"TorchExSpecialCountTrait",
			"TorchSpecialSpeedTrait",
			"TorchAttackSpeedTrait",
			"TorchSpecialLineTrait",
			"TorchSpecialImpactTrait",
			"TorchMoveSpeedTrait",
			"TorchSplitAttackTrait",
			"TorchEnhancedAttackTrait",
			"TorchDiscountExAttackTrait",
			"TorchLongevityTrait",
			"TorchOrbitPointTrait",
			"TorchSpinAttackTrait",
			"TorchAutofireSprintTrait",
		},
	},
	WeaponLob = {
		values = {
			"",
			"LobAmmoTrait",
			"LobAmmoMagnetismTrait",
			"LobRushArmorTrait",
			"LobSpreadShotTrait",
			"LobSpecialSpeedTrait",
			"LobSturdySpecialTrait",
			"LobOneSideTrait",
			"LobInOutSpecialExTrait",
			"LobStraightShotTrait",
			"LobPulseAmmoTrait",
			"LobPulseAmmoCollectTrait",
			"LobGrowthTrait",
			"LobGunOverheatTrait",
			"LobGunBounceTrait",
			"LobGunSpecialBounceTrait",
			"LobGunAttackRangeTrait",
			"LobGunAttackDoublerTrait",
		},
	},
	WeaponSuit = {
		values = {
			"",
			"SuitArmorTrait",
			"SuitAttackSpeedTrait",
			"SuitAttackSizeTrait",
			"SuitAttackRangeTrait",
			"SuitFullChargeTrait",
			"SuitDashAttackTrait",
			"SuitSpecialJumpTrait",
			"SuitSpecialStartUpTrait",
			"SuitSpecialAutoTrait",
			"SuitSpecialBlockTrait",
			"SuitSpecialDiscountTrait",
			"SuitSpecialConsecutiveHitTrait",
			"SuitComboForwardRocketTrait",
			"SuitComboBlockBuffTrait",
			"SuitComboDoubleSpecialTrait",
			"SuitComboDashAttackTrait",
			"SuitPowershotTrait",
		},
	},
}

Utils.weaponLabels = {
	WeaponStaffSwing = "Staff",
	WeaponDagger = "Blades",
	WeaponAxe = "Axe",
	WeaponTorch = "Torch",
	WeaponLob = "Skull",
	WeaponSuit = "Coat",
}

Utils.weaponDrawOrder = {
	"WeaponStaffSwing",
	"WeaponDagger",
	"WeaponAxe",
	"WeaponTorch",
	"WeaponLob",
	"WeaponSuit",
}

Utils.aspectLabels = {
	BaseStaffAspect = "Mel Staff",
	StaffClearCastAspect = "Circe",
	StaffSelfHitAspect = "Momus",
	StaffRaiseDeadAspect = "Anubis",

	DaggerBackstabAspect = "Mel Blades",
	DaggerHomingThrowAspect = "Pan",
	DaggerBlockAspect = "Artemis",
	DaggerTripleAspect = "The Morrigan",

	LobAmmoBoostAspect = "Mel Skull",
	LobCloseAttackAspect = "Medea",
	LobImpulseAspect = "Persephone",
	LobGunAspect = "Hel",

	AxeRecoveryAspect = "Mel Axe",
	AxeArmCastAspect = "Charon",
	AxePerfectCriticalAspect = "Thanatos",
	AxeRallyAspect = "Nergal",

	TorchSpecialDurationAspect = "Mel Torch",
	TorchSprintRecallAspect = "Eos",
	TorchDetonateAspect = "Moros",
	TorchAutofireAspect = "Supay",

	BaseSuitAspect = "Mel Coat",
	SuitMarkCritAspect = "Nyx",
	SuitHexAspect = "Selene",
	SuitComboAspect = "Shiva",
}

Utils.WeaponAspectMapping = {
	WeaponStaffSwing = { "BaseStaffAspect", "StaffClearCastAspect", "StaffSelfHitAspect", "StaffRaiseDeadAspect" },
	WeaponDagger = { "DaggerBackstabAspect", "DaggerHomingThrowAspect", "DaggerBlockAspect", "DaggerTripleAspect" },
	WeaponAxe = { "AxeRecoveryAspect", "AxeArmCastAspect", "AxePerfectCriticalAspect", "AxeRallyAspect" },
	WeaponTorch = {
		"TorchSpecialDurationAspect",
		"TorchSprintRecallAspect",
		"TorchDetonateAspect",
		"TorchAutofireAspect",
	},
	WeaponLob = { "LobAmmoBoostAspect", "LobCloseAttackAspect", "LobImpulseAspect", "LobGunAspect" },
	WeaponSuit = { "BaseSuitAspect", "SuitMarkCritAspect", "SuitHexAspect", "SuitComboAspect" },
}

-- Propagate base weapon hammer data to each aspect
for weaponName, aspects in pairs(Utils.WeaponAspectMapping) do
	local baseWeaponData = Utils.hammerData[weaponName]
	for _, aspectName in ipairs(aspects) do
		Utils.hammerData[aspectName] = baseWeaponData
	end
end

-- Build a flat ordered list of all aspects (used by hash system)
Utils.aspectDrawOrder = {}
for _, weaponName in ipairs(Utils.weaponDrawOrder) do
	local aspects = Utils.WeaponAspectMapping[weaponName]
	if aspects then
		for _, aspectName in ipairs(aspects) do
			table.insert(Utils.aspectDrawOrder, aspectName)
		end
	end
end

-- =============================================================================
-- HOOKS
-- =============================================================================

local hasForcedHammerThisRun = false

function Utils.RegisterHammerHooks()
    -- Reset forced hammer flag at start of each run
    modutil.mod.Path.Wrap("StartNewRun", function(baseFunc, prevRun, args)
        hasForcedHammerThisRun = false
        return baseFunc(prevRun, args)
    end)

    -- Force the configured hammer as the only option on first weapon upgrade
    modutil.mod.Path.Wrap("SetTraitsOnLoot", function(baseFunc, lootData, args)
        baseFunc(lootData, args)

        if config.ModEnabled and lootData.Name == "WeaponUpgrade" and not hasForcedHammerThisRun then
            local currentWeapon = Utils.GetEquippedAspect()
            local desiredHammer = config.FirstHammers[currentWeapon]

            if desiredHammer and desiredHammer ~= "" then
                local traitData = TraitData[desiredHammer]
                if traitData and IsTraitEligible(traitData, args) then
                    lootData.UpgradeOptions = {
                        { ItemName = desiredHammer, Type = "Trait" }
                    }
                else
                    Utils.PrintDebug("StartingHammer: " .. desiredHammer .. " is ineligible! Falling back to random.")
                end
            end
        end
    end)

    -- Lock out the mod after granting the forced hammer
    modutil.mod.Path.Wrap("AddTraitToHero", function(baseFunc, args)
        args = args or {}
        local traitName = args.TraitData and args.TraitData.Name
        if not config.ModEnabled or not traitName then
            return baseFunc(args)
        end
        local currentWeapon = Utils.GetEquippedAspect()
        local desiredHammer = config.FirstHammers[currentWeapon]

        if desiredHammer == traitName then
            Utils.PrintDebug("AddTraitToHero: Granting guaranteed first hammer -> " .. tostring(traitName))
            hasForcedHammerThisRun = true
        end

        return baseFunc(args)
    end)
end
