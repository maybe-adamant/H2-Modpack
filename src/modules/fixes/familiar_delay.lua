local Registry = adamant_Modpack.Registry

Registry:register({
    id = "FamiliarDelayFix",
    name = "Familiar Delay Fix",
    category = "BugFixes",
    group = "NPC & Encounters",
    tooltip = "Fixes Familiars being summoned after a delay upon entering a room.\nGale can block hits right away and Toula spawn more convenient",
    default = true,

    apply = function(AddToBackup)
        local unblocked = RoomEventData.GlobalRoomInputUnblockedEvents
        for _, event in ipairs(unblocked) do
            if event.FunctionName == "FamiliarSetup" then
                AddToBackup(event, "Args")
                event.Args = {}
                break
            end
        end
    end,
})
