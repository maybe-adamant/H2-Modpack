-- =============================================================================
-- MODULE LOADER
-- =============================================================================
-- Imports all module files. The registry must be available before this runs.
-- To add a new module: create a file in the appropriate subdirectory and add
-- an import line here. That's it -- the module self-registers via Registry.
--
-- ORDER MATTERS FOR HASH COMPATIBILITY:
--   1. Category SECTION order determines hash category order (do not reorder sections)
--   2. Import order WITHIN a section determines module bit order (append new modules at end)
--   3. New categories should be added AFTER existing sections

-- Run Modifiers
import 'modules/modifiers/force_medea.lua'
import 'modules/modifiers/force_arachne.lua'
import 'modules/modifiers/disable_arachne_pity.lua'
import 'modules/modifiers/echo_scam.lua'
import 'modules/modifiers/disable_selene_before_boon.lua'
import 'modules/modifiers/rta_mode.lua'
import 'modules/modifiers/skip_gem_boss.lua'
import 'modules/modifiers/escalating_fig_leaf.lua'
import 'modules/modifiers/surface_structure.lua'
import 'modules/modifiers/charybdis.lua'

-- QoL
import 'modules/qol/show_location.lua'
import 'modules/qol/skip_dialogue.lua'
import 'modules/qol/skip_run_end_cutscene.lua'
import 'modules/qol/skip_death_cutscene.lua'
import 'modules/qol/spawn_location.lua'
import 'modules/qol/kbm_escape.lua'
import 'modules/qol/victory_screen.lua'

-- Bug Fixes
import 'modules/fixes/corrosion.lua'
import 'modules/fixes/ggg.lua'
import 'modules/fixes/braid.lua'
import 'modules/fixes/miniboss_encounter.lua'
import 'modules/fixes/extra_dose.lua'
import 'modules/fixes/poseidon_waves.lua'
import 'modules/fixes/tidal_ring.lua'
import 'modules/fixes/shimmering.lua'
import 'modules/fixes/staged_omega.lua'
import 'modules/fixes/omega_cast.lua'
import 'modules/fixes/cardio_torch.lua'
import 'modules/fixes/familiar_delay.lua'
import 'modules/fixes/suffering.lua'
import 'modules/fixes/selene.lua'
import 'modules/fixes/et_fix.lua'
import 'modules/fixes/second_stage_channeling.lua'

-- Special modules (not in boolean hash)
import 'modules/hammers.lua'
