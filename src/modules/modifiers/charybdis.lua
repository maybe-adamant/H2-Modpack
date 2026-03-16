local Registry = adamant_Modpack.Registry

Registry:register({
    id = "CharybdisBehaviorAdjustment",
    name = "Adjust Charybdis Behavior",
    category = "RunModifiers",
    group = "World & Combat Tweaks",
    tooltip = "At phase transition, Tentacles despawn in 1s (not 9s). Charybdis fires 6 spits instead of 8.",
    default = false,

    apply = function(AddToBackup)
        AddToBackup(UnitSetData.Charybdis.CharybdisTentacle.AIStages[3], "WaitDuration")
        AddToBackup(WeaponData.CharybdisSpit3.AIData, "FireTicks")
        AddToBackup(WeaponDataEnemies.CharybdisSpit3.AIData, "FireTicks")

        UnitSetData.Charybdis.CharybdisTentacle.AIStages[3].WaitDuration = 1.0
        WeaponData.CharybdisSpit3.AIData.FireTicks = 6
        WeaponDataEnemies.CharybdisSpit3.AIData.FireTicks = 6
    end,
})
