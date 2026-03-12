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

-- Build a flat ordered list of all aspects
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
-- UI LAYOUT DEFINITIONS
-- =============================================================================

Utils.bugFixLayout = {
	{
		Header = "Weapons & Attacks",
		Items = {
			{
				Key = "SeleneFix",
				Name = "Aspect of Selene Fix",
				Tooltip = "Aspect of Selene properly registers its hex so you get offered PoS directly. Skyfall is full moonglow",
				RequiresApply = true,
			},
			{
				Key = "ExtraDoseFix",
				Name = "Extra Dose Fix",
				Tooltip = "Fixes Extra Dose interaction with Coat 2nd punch and Dash strike.",
				RequiresApply = true,
			},
			{
				Key = "StagedOmegaFix",
				Name = "Staged Omega Fix",
				Tooltip = "Fixes Axe OAtk, Blade OSpec not benefiting correctly from channeling bonus.",
				RequiresApply = true,
			},
			{
				Key = "TidalRingFix",
				Name = "Tidal Ring Fix",
				Tooltip = "Fixes Tidal Ring not hitting the same mob twice with Circe.",
				RequiresApply = true,
			},
		},
	},
	{
		Header = "Boons & Hammers",
		Items = {
			{
				Key = "PoseidonWavesFix",
				Name = "Poseidon Waves Fix",
				Tooltip = "Fixes Poseidon waves on Axe special and Hidden Helix Torch.",
				RequiresApply = true,
			},
			{
				Key = "ShimmeringFix",
				Name = "Shimmering Moonshot Fix",
				Tooltip = "Fixes Shimmering Moonshot not applying damage bonus to omega special.",
				RequiresApply = true,
			},
			{
				Key = "SecondStageChannelingFix",
				Name = "Second Stage Channeling Fix",
				Tooltip = "Removes 2nd stage channel of Glorious Disaster/Giga Moonburst, baking bonus into stage 1.",
				RequiresApply = true,
			},
			{
				Key = "OmegaCastEffectsFix",
				Name = "Omega Cast Effects Fix",
				Tooltip = "Fixes OCast moves not counting as cast damage.",
				RequiresApply = true,
			},
			{
				Key = "CardioTorchFix",
				Name = "Cardio Torch Fix",
				Tooltip = "Fixes Cardio Gain interactions with Torch specials.",
				RequiresApply = true,
			},
			{
				Key = "BraidFix",
				Name = "Braid Fix",
				Tooltip = "Fixes Braid of Atlas to properly buff casts.",
				RequiresApply = true,
			},
			{
				Key = "ETFix",
				Name = "ET Fixes",
				Tooltip = "Fixes ET working with Anubis by creating a 3rd OAtk field.\nFixes Anubis OAtk distance based on casting angle.",
				RequiresApply = true,
			},
		},
	},
	{
		Header = "NPC & Encounters",
		Items = {
			{
				Key = "CorrosionFix",
				Name = "Corrosion Fix",
				Tooltip = "Fixes corrosion aggroing mobs on thessaly boats.",
				RequiresApply = true,
			},
			{
				Key = "SufferingFix",
				Name = "Suffering Fix",
				Tooltip = "Fixes Suffering on Sight not bypassing Wards vow when dealing damage.",
			},
			{
				Key = "GGGFix",
				Name = "GGG Echo Fix",
				Tooltip = "Allows GGG to be offered in Jpom runs.",
				RequiresApply = true,
			},
			{
				Key = "MiniBossEncounterFix",
				Name = "Miniboss Encounter Fix",
				Tooltip = "Fixes Miniboss with top screen health bars not properly progressing biome depth\nBosses like Boar, Charybdis, Talos.",
				RequiresApply = true,
			},
			{
				Key = "FamiliarDelayFix",
				Name = "Familiar Delay Fix",
				Tooltip = "Fixes Familiars being summoned after a delay upon entering a room.\nGale can block hits right away and Toula spawn more convenient",
				RequiresApply = true,
			},
		},
	},
}

Utils.runModifierLayout = {
	{
		Header = "NPCs & Routing",
		Items = {
			{
				Key = "ForceMedea",
				Name = "Force Medea Spawn",
				Tooltip = "Forces Medea to spawn to reduce death pity reset.",
				RequiresApply = true,
			},
			{
				Key = "ForceArachne",
				Name = "Force Arachne Spawn",
				Tooltip = "Forces Arachne to spawn to reduce death pity reset.",
				RequiresApply = true,
			},
			{
				Key = "DisableArachnePity",
				Name = "Disable Arachne Pity",
				Tooltip = "Disables Arachne Pity entirely for Anyfear runs.",
				RequiresApply = true,
			},
			{
				Key = "PreventEchoScam",
				Name = "Prevent Echo Scam",
				Tooltip = "Prevents Echo scam by blocking both minibosses from spawning at room 3.",
				RequiresApply = true,
			},
			{
				Key = "DisableSeleneBeforeBoon",
				Name = "Disable Selene Before First Boon",
				Tooltip = "Prevents Selene from spawning before the first boon is obtained.",
				RequiresApply = true,
			},
		},
	},
	{
		Header = "World & Combat Tweaks",
		Items = {
			{
				Key = "RTAMode",
				Name = "RTA Mode",
				Tooltip = "Disables all combat pausing encounters for RTA runs.",
			},
			{
				Key = "SkipGemBossReward",
				Name = "Skip Gem Boss Reward",
				Tooltip = "Bosses no longer drop gem rewards when using Grave Thrist.",
			},
			{
				Key = "EscalatingFigLeaf",
				Name = "Incrementing Fig Leaf",
				Tooltip = "Dionysus Skip Chance starts at default value and increases by 13% after every encounter, resetting on biome start.",
			},
			{
				Key = "SurfaceStructureFix",
				Name = "Less Sucky Surface",
				Tooltip = "1. Thessaly Miniboss forced between rooms 2-4.\n2. Olympus midshop forced between rooms 5-7.\n3. Removes Boatacles.",
				RequiresApply = true,
			},
			{
				Key = "CharybdisBehaviorAdjustment",
				Name = "Adjust Charybdis Behavior",
				Tooltip = "At phase transition, Tentacles despawn in 1s (not 9s). Charybdis fires 6 spits instead of 8.",
				RequiresApply = true,
			},
		},
	},
}
Utils.qolSettingsLayout = {
	{
		Header = "QoL",
		Items = {
			{
				Key = "AlwaysShowLocation",
				Name = "Always Show Location Counter",
				Tooltip = "Always displays the current location in the UI.",
			},
			{
				Key = "AutoSkipDialogue",
				Name = "Auto Skip Dialogue",
				Tooltip = "Automatically skips dialogue prompts during gameplay.",
			},
			{
				Key = "RunEndCutscene",
				Name = "Skip End Run Cutscene",
				Tooltip = "Skip the end-of-run cutscene. The victory screen will still appear, but you will be immediately returned to the main menu.",
			},
			{
				Key = "DeathCutScene",
				Name = "Skip Death Cutscene",
				Tooltip = "Skip the death cutscene. The death screen will still appear, but you will be immediately returned to the main menu.",
			},
			{
				Key = "SpawnInTrainingGrounds",
				Name = "Spawn in Training Grounds",
				Tooltip = "Spawns you in the Training Grounds instead of the House of Hades. Useful for testing and practicing.",
			},
			{
				Key = "KBMEscapeAlt",
				Name = "Fixing Escape Behavior for KBM",
				Tooltip = "KBM Escape will now work during boon/pom Selection, Hex selection, PoS menu, and during death sequences.",}
		},
	},

}

-- =============================================================================
-- DEFAULT PROFILES (shipped with mod — user can reset to these)
-- =============================================================================
Utils.NUM_PROFILES = 10

Utils.defaultProfiles = {
	{ Name = "AnyFear", 	Hash = "1AfB0V.3", Tooltip = "RTA Disabled. Arachne Pity Disabled" },
	{ Name = "HighFear", 	Hash = "1AfB0t.3", Tooltip = "RTA Disabled. Arachne Spawn Forced" },
	{ Name = "RTA", 		Hash = "1AfB20.3", Tooltip = "RTA Enabled. Arachne Pity Enabled. Medea/Arachne Spawns Not Forced" },
}
