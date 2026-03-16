local Utils = adamant_Modpack
local Registry = Utils.Registry

Registry:register({
    id = "ETFix",
    name = "ET Fixes",
    category = "BugFixes",
    group = "Boons & Hammers",
    tooltip = "Fixes ET working with Anubis by creating a 3rd OAtk field.\nFixes Anubis OAtk distance based on casting angle.",
    default = true,

    apply = function(AddToBackup)
        if not TraitData.DoubleExManaBoon then return end
        AddToBackup(TraitData, "DoubleExManaBoon")

        for _, propertyChange in ipairs(TraitData.DoubleExManaBoon.PropertyChanges or {}) do
            if Contains(propertyChange.FalseTraitNames, "StaffOneWayAttackTrait") then
                Utils.SafeArrayInsert(propertyChange, "FalseTraitNames", "StaffRaiseDeadAspect")
                break
            end
        end
        TraitData.DoubleExManaBoon.OnWeaponFiredFunctions = {
            ValidWeapons = { "WeaponStaffSwing5" },
            FunctionName = "CreateSecondAnubisWall",
            FunctionArgs = { Distance = 340 },
            ExcludeLinked = true,
        }
    end,

    hooks = {
        {
            target = "CreateSecondAnubisWall",
            fn = function(baseFunc, weaponData, args, triggerArgs)
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
                local gapDistance = args.Distance - 520
                local isoRatio = 0.7

                local baseX = math.cos(radAngle) * baseDistance
                local baseY = -math.sin(radAngle) * baseDistance * isoRatio

                local gapX = math.cos(radAngle) * gapDistance
                local gapY = -math.sin(radAngle) * gapDistance

                local fixedOffsetX = baseX + gapX
                local fixedOffsetY = baseY + gapY

                CreateProjectileFromUnit({
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
                    ExcludeFromCap = true,
                })
            end,
        },
    },
})
