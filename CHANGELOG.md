# Changelog

## [Unreleased]

## [1.2.1] - 2026-03-12

### Changed

- Updated readme/tooltips for better readability and more through explanations

## [1.2.0] - 2026-03-12

### Changed

- **Profile system overhaul** — Replaced the old hardcoded preset system (AnyFear/HighFear/RTA defined in code) with a fully user-driven profile manager. Users can now save, load, name, and share their own configurations without editing any files.
- **Draft/commit model** — All setting changes are now staged as a draft. Nothing takes effect until the user clicks **Apply Changes**. A **Discard** button reverts to the last applied state. This replaces the old behavior where some settings applied immediately and others required Apply.
- **Config hash now includes hammer selections** — The hash encoding has been extended to capture both boolean settings and first hammer choices. The HUD marker continues to show only the short boolean hash for readability.

### Added

- **Profiles tab** — New dedicated tab for profile management:
  - Export/Import with Copy and Paste buttons for fully mouse-driven workflow
  - 10 saveable profile slots with custom names and tooltips
  - Restore Default Profiles button to reset slots to shipped defaults
  - "Exclude Hammers" checkbox on Copy to share toggle-only codes
- **Quick Setup tab** — Dropdown lists only populated profiles. Select and click Load to apply a saved profile in one click.
- **Two-tone hash display** — Export view shows boolean settings in green and hammer payload in gray, making it clear which part of the code is which.
- Mod marker now appears on game load (previously only showed after first Apply).

### Removed

- Hardcoded preset definitions — replaced by user-managed profiles.
- Auto-detection of "Custom" preset state — replaced by simple hash comparison.
- Per-setting live apply behavior — all settings now go through the draft/commit flow.

## [1.1.0] - 2026-03-11

### Added

- QoL option to allow KBM players to pause the game during boon/pom/hex selection menu, PoS menus, and during death sequences.

## [1.0.13] - 2026-03-10

### Added

- Several QoL options, including: Death Cutscene skip, Spawn in Training Grounds directly, Auto Skip Dialogue.
- Credit to PonyWarrior for their PonyQoL2 mod.

### Fixed

- Mod Marker implementation significantly improved and made independent of other game systems. now toggles when the mod is enabled/disabled
- Mod now fully applies its config when enabled and revert all changes when disabled.

## [1.0.12] - 2026-03-09

### Fixed

- Implemented the Familiar Delay Fix in a less aggressive way to prevent a case where Raki attacked Chronos adds before the fight even started.
- Fixed an issue causing Location string to render offscreen from the Modded mark

## [1.0.11] - 2026-03-08

### Added

- Modded Stamp to screen while running the mod to clarify that the run is modded as well as a hash code showing mod config
- Mod UI Theme
- Added an option to make Fig Leaf increment based on biome depth instead of a fixed percentage
- Added an option to disable gem drops from bosses when using Grave Thirst

### Fixed

- Fixed a bug where passing a hammer room disabled the first hammer forcing
- Preset dropdown fix
- Preset description more clarified

## [1.0.10] - 2026-03-07

### Added

- Improved UI handling
- Performance Optimization
- Code restructing for expandability

## [1.0.9] - 2026-03-06

### Added

- Hammer selection now per aspect not just per weapon
- Overhaul of the UI for better UX
- Adding Backup/Restore system allowing changing configuration without returning to main men (BETA)

### Fixed

- Tightened the hammer selection logic to ensure it is only reset when the player actually receives the hammer.

## [1.0.8] - 2026-03-06

### Added

- Glorious Disaster now working with Aspect of Charon  

### Fixed

- Encounter banning for RTA and Surface fixes  

## [1.0.7] - 2026-03-05

- Fixing RTA Mode missing two encounter sets

## [1.0.6] - 2026-03-05

- Removed Field Mid shop chance. Now Echo is 100%  
- Adding RTA support by disabling all combat pausing encounters

## [1.0.5] - 2026-03-05

- Changing Echo chance to 0.75 instead of 50/50 with the shop  
- Remove Arachne pity changes because some people use it and some people don't so no need to change it  

## [1.0.4] - 2026-03-04

- Adding Familiar delay fix  
- Adding Suffering on Sight Fix  
- General Surface adjustments  

## [1.0.2] - 2026-03-03

- Adding echo scam fix (experimental)  
- Fix Charybdis behavior adjustment caused mod to crash 

## [1.0.1] - 2026-03-03

- remove experimental code that made it to release

## [1.0.0] - 2026-03-03

- Initial release

<!-- Versions -->

[unreleased]: https://github.com/maybe-adamant/H2-Modpack/compare/1.2.1...HEAD
[1.2.1]: https://github.com/maybe-adamant/H2-Modpack/compare/1.2.0...1.2.1
[1.2.0]: https://github.com/maybe-adamant/H2-Modpack/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.13...1.1.0
[1.0.13]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.12...1.0.13
[1.0.12]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.11...1.0.12
[1.0.11]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.10...1.0.11
[1.0.10]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.9...1.0.10
[1.0.9]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.8...1.0.9
[1.0.8]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.7...1.0.8
[1.0.7]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.6...1.0.7
[1.0.6]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.6...1.0.6
[1.0.6]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.5...1.0.6
[1.0.5]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.4...1.0.5
[1.0.4]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.2...1.0.4
[1.0.2]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/maybe-adamant/H2-Modpack/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/maybe-adamant/H2-Modpack/releases/tag/1.0.0
