local Registry = adamant_Modpack.Registry

local function ShowDepthCounter()
    local screen = { Name = "RoomCount", Components = {} }
    screen.ComponentData = {
        RoomCount = DeepCopyTable(ScreenData.TraitTrayScreen.ComponentData.RoomCount)
    }
    CreateScreenFromData(screen, screen.ComponentData)
end

Registry:register({
    id = "AlwaysShowLocation",
    name = "Always Show Location Counter",
    category = "QoLSettings",
    group = "QoL",
    tooltip = "Always displays the current location in the UI.",
    default = true,

    hooks = {
        {
            target = "ShowHealthUI",
            fn = function(baseFunc)
                baseFunc()
                ShowDepthCounter()
            end,
        },
    },
})
