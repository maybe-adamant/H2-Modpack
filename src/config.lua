---@meta adamant-config-Modpack
return {
    
    -- FirstHammers = {
    --     WeaponStaffSwing = "",
    --     WeaponDagger     = "",
    --     WeaponAxe        = "",
    --     WeaponTorch      = "",
    --     WeaponLob        = "",
    --     WeaponSuit       = "",
    -- },

    FirstHammers =
    {
        BaseStaffAspect             = "",
        StaffClearCastAspect        = "",
        StaffSelfHitAspect          = "",
        StaffRaiseDeadAspect        = "",

        DaggerBackstabAspect        = "",
        DaggerHomingThrowAspect     = "",
        DaggerBlockAspect           = "",
        DaggerTripleAspect          = "",

        LobAmmoBoostAspect          = "",
        LobCloseAttackAspect        = "",
        LobImpulseAspect            = "",
        LobGunAspect                = "",

        AxeRecoveryAspect           = "",
        AxeArmCastAspect            = "",
        AxePerfectCriticalAspect    = "",
        AxeRallyAspect              = "",

        TorchSpecialDurationAspect  = "",
        TorchSprintRecallAspect     = "",
        TorchDetonateAspect         = "",
        TorchAutofireAspect         = "",

        BaseSuitAspect              = "",
        SuitMarkCritAspect          = "",
        SuitHexAspect               = "",
        SuitComboAspect             = "",
    },


    ModEnabled = true,
    DebugMode = true,

    QoLSettings = {
        AlwaysShowLocation = true,
        AutoSkipDialogue = false,
        RunEndCutscene = true,
        DeathCutScene = true,
        SpawnInTrainingGrounds = true,
        KBMEscapeAlt = true,
    },

    
    RunModifiers = {
        RTAMode = false,
        SkipGemBossReward = false,

        EscalatingFigLeaf = false,
        ForceMedea = false,
        ForceArachne = false,
        DisableArachnePity = false,
        CharybdisBehaviorAdjustment = false,
        PreventEchoScam = false,
        SurfaceStructureFix = false,
        DisableSeleneBeforeBoon = false,
    },

    
    BugFixes = {
        CorrosionFix = true,
        GGGFix = true,
        BraidFix = true,
        MiniBossEncounterFix  = true,
        ExtraDoseFix = true,
        PoseidonWavesFix = true,
        SeleneFix = true,
        TidalRingFix = true,
        ShimmeringFix = true,
        StagedOmegaFix = true,

        ETFix = true,
        SecondStageChannelingFix = true,
        OmegaCastEffectsFix = true,
        CardioTorchFix = true,
        FamiliarDelayFix = true,
        SufferingFix = true,
    },


    Profiles =
    {
        { Name = "AnyFear",     Hash = "1AfB0V.3", Tooltip = "RTA Disabled. Arachne Pity Disabled" },
        { Name = "HighFear",    Hash = "1AfB0t.3", Tooltip = "RTA Disabled. Arachne Spawn Forced" },
        { Name = "RTA",         Hash = "1AfB20.3", Tooltip = "RTA Enabled. Arachne Pity Enabled. Medea/Arachne Spawns Not Forced" },
        { Name = "",            Hash = "", Tooltip = "" },
        { Name = "",            Hash = "", Tooltip = "" },
        { Name = "",            Hash = "", Tooltip = "" },
        { Name = "",            Hash = "", Tooltip = "" },
        { Name = "",            Hash = "", Tooltip = "" },
        { Name = "",            Hash = "", Tooltip = "" },
        { Name = "",            Hash = "", Tooltip = "" },
    },
}
