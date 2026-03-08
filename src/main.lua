---@meta _
adamant_Modpack = adamant_Modpack or {}
local Utils = adamant_Modpack

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@diagnostic disable: lowercase-global
---@module 'SGG_Modding-ENVY-auto'
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = PLUGIN

---@module 'SGG_Modding-Hades2GameDef-Globals'
game = rom.game

---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]

---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']


---@module 'SGG_Modding-SJSON'
sjson = mods['SGG_Modding-SJSON']

---@module 'adamant-config-Modpack'
config = chalk.auto('config.lua')
public.config = config

local function ApplyModdedMark()
    local file = rom.path.combine(rom.paths.Content, 'Game/Text/en/HelpText.en.sjson')
    sjson.hook(file, function(data)
        for _, v in ipairs(data.Texts) do
            if v.Id == 'UI_RoomCount' then
                v.DisplayName = v.DisplayName .. "\n\n\n\n\nModded Run"
                break
            end
        end
    end)
end
local function on_ready()
    import_as_fallback(rom.game)

    ApplyModdedMark()
    import("def.lua")
    import("logic.lua")
end

local function on_reload()
    import_as_fallback(rom.game)
    import("def.lua")
    import("ui.lua")
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(on_ready, on_reload)
end)
