local Registry = adamant_Modpack.Registry

Registry:register({
    id = "DeathCutScene",
    name = "Skip Death Cutscene",
    category = "QoLSettings",
    group = "QoL",
    tooltip = "Skip the death cutscene. The death screen will still appear, but you will be immediately returned to the main menu.",
    default = true,

    contextHooks = {
        {
            register = function(moduleRef)
                modutil.mod.Path.Context.Wrap("DeathPresentation", function()
                    modutil.mod.Path.Wrap("wait", function(base, duration, tag, persist)
                        if not config.ModEnabled or not config.QoLSettings[moduleRef.id] then
                            return base(duration, tag, persist)
                        end
                        return
                    end)
                end)
            end,
        },
    },
})
