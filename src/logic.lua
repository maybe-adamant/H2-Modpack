local modutil = rom.mods['SGG_Modding-ModUtil']
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

-- =============================================================================
-- MOD ENGINE HOOKS
-- =============================================================================

modutil.mod.Path.Wrap("StartNewRun", function(baseFunc, currentRun, args)
    hasForcedHammerThisRun = false
    return baseFunc(currentRun, args)
end)

modutil.mod.Path.Wrap("SetTraitsOnLoot", function(baseFunc, lootData, args)
    baseFunc(lootData, args)

    if config.ModEnabled and lootData.Name == "WeaponUpgrade" and not hasForcedHammerThisRun then
        
        local currentWeapon = Utils.GetEquippedWeapon()
        local desiredHammer = config.FirstHammers[currentWeapon]

        if desiredHammer and desiredHammer ~= "" then
            lootData.UpgradeOptions = {
                { ItemName = desiredHammer, Type = "Trait" }
            }
            hasForcedHammerThisRun = true
        end
    end
end)