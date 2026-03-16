local Registry = adamant_Modpack.Registry

Registry:register({
    id = "SufferingFix",
    name = "Suffering Fix",
    category = "BugFixes",
    group = "NPC & Encounters",
    tooltip = "Fixes Suffering on Sight not bypassing Wards vow when dealing damage.",
    default = true,

    hooks = {
        {
            target = "CheckSpawnCurseDamage",
            fn = function(baseFunc, enemy, traitArgs)
                if enemy.IsBoss or enemy.UseBossHealthBar or enemy.IgnoreCurseDamage or enemy.AlwaysTraitor then
                    return
                end
                local damageAmount = 0
                for _, data in ipairs(traitArgs.DamageArgs) do
                    if not data.Chance or RandomChance(data.Chance * GetTotalHeroTraitValue("LuckMultiplier", { IsMultiplier = true })) then
                        damageAmount = RandomInt(data.MinDamage, data.MaxDamage)
                        break
                    end
                end
                thread(DoCurseDamage, enemy, traitArgs, damageAmount, true)
            end,
        },
    },
})
