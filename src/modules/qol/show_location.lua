local Registry = adamant_Modpack.Registry

Registry:register({
    id = "AlwaysShowLocation",
    name = "Always Show Location Counter",
    category = "QoLSettings",
    group = "QoL",
    tooltip = "Always displays the current location in the UI.",
    default = true,
    -- Rendering handled by the HUD system in hud.lua (ShowHealthUI wrap)
})
