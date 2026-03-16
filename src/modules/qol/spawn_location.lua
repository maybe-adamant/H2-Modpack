local Registry = adamant_Modpack.Registry

Registry:register({
    id = "SpawnInTrainingGrounds",
    name = "Spawn in Training Grounds",
    category = "QoLSettings",
    group = "QoL",
    tooltip = "Spawns you in the Training Grounds instead of the House of Hades. Useful for testing and practicing.",
    default = true,

    contextHooks = {
        {
            register = function(moduleRef)
                modutil.mod.Path.Context.Wrap("KillHero", function(base, victim, triggerArgs)
                    modutil.mod.Path.Wrap("LoadMap", function(base, argTable)
                        if not config.ModEnabled or not config.QoLSettings[moduleRef.id] then
                            base(argTable)
                            return
                        end
                        if argTable.Name == "Hub_Main" then
                            argTable.Name = "Hub_PreRun"
                        end
                        base(argTable)
                    end)
                end)
            end,
        },
    },
})
