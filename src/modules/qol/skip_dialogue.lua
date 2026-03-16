local Registry = adamant_Modpack.Registry

Registry:register({
    id = "AutoSkipDialogue",
    name = "Auto Skip Dialogue",
    category = "QoLSettings",
    group = "QoL",
    tooltip = "Automatically skips dialogue prompts during gameplay.",
    default = false,

    hooks = {
        {
            target = "PlayTextLines",
            fn = function(base, source, textLines, args)
                -- Not in a run
                if CurrentRun.Hero.IsDead then
                    return base(source, textLines, args)
                end

                if not textLines then return end

                -- Don't skip main story conversations (wants-to-talk icon)
                if textLines.StatusAnimation == 'StatusIconWantsToTalk' then
                    return base(source, textLines, args)
                end

                -- Don't skip NPC choice dialogues
                if textLines.PrePortraitExitFunctionName then
                    local hasChoice = string.find(textLines.PrePortraitExitFunctionName, 'Choice')
                    if hasChoice then
                        return base(source, textLines, args)
                    end
                end

                return
            end,
        },
    },
})
