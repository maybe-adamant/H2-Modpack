# Hades 2 Utility & Bugfix Modpack

This mod provides an in-game ImGui menu to configure targeted gameplay adjustments, starting hammer selections, and various bug fixes. 

**Design Philosophy:** Keep the core game vanilla, but remove frustrating RNG, fix some bugs and unintuitive interactions, and provide QoL tools for a smoother routing experience. Inspired by the Hades 1 Speedrunning Modpack.

## Features at a Glance
* **Routing & RNG Control:** Guarantee your preferred starting hammer, force crucial NPC spawns (Medea/Arachne), and prevent Echo Scam in the Fields and more.
* **RTA Support:** Instantly disable all combat-pausing encounters, skip unskippable death/victory cutscenes, and verify run rules via an on-screen Rule Hash.
* **Bug Fixes:** Patches several ingame bugs and unintuitive interactions.
* **In-Game Configuration Menu:** Toggle every single fix and modifier individually via a safe, immediate-mode GUI without ever needing to restart your game or edit text files. 
* **Loadout Profiles:** Save, load, and share up to 10 custom configurations, or use the shipped default profiles (AnyFear, HighFear, RTA).
---

## Installation & Requirements

This mod requires several underlying frameworks (ModUtil, Chalk, ENVY, SJSON) to function. 

**The recommended way to install is via Thunderstore**, which will automatically download all required dependencies and place the files in the correct directories for you.

### Installation Steps
1. Download a Thunderstore-compatible mod manager, such as **r2modman** (Recommended) or the **Thunderstore App**.
2. Select **Hades II** as your game.
3. Search for **adamant-Modpack** in the "Online" tab and click **Download**. 
4. Launch the game directly through the mod manager to play with the mod enabled.

---

## How to Use

To access the configuration menu:
1. Press your Modding Framework UI hotkey (usually `~` or `F1`) to open the main framework menu.
2. Select **adamant-Modpack** from the list of loaded mods.
3. Click the **Modpack** entry in the ImGui menu bar at the top of the screen.
4. Click **Toggle Mod Menu** to open the configuration window.

### The Master Toggle
The **Enable Mod** checkbox at the top turns the entire modpack on or off. Disabling it automatically reverts all game data mutations back to vanilla immediately — no restart required.

### Configuration Tabs
1. **Quick Setup:** Load a saved profile to configure the modpack in one click. Toggle all bug fixes at once, and quickly select a hammer for your currently equipped aspect.
2. **Hammers:** Select a guaranteed first hammer for each weapon aspect. *Note: If your selected hammer is ineligible due to game conditions, the game will safely default to vanilla random selection.*
3. **Run Modifiers:** Toggle individual gameplay and routing adjustments.
4. **Bug Fixes:** Toggle individual engine and boon fixes independently.
5. **QoL:** Quality-of-life options for cutscenes, dialogue, and spawn behavior. *(Credit to PonyWarrior for their PonyQoL2 mod).*
6. **Profiles:** Manage your 10 saved configuration slots, import loadouts from other players, or restore the default shipped profiles.

### Applying Changes
All changes are staged as a draft. Click **Apply Changes** at the bottom of the window to activate them, or **Discard** to revert. The UI will warn you when you have unapplied changes.

### The Hash System (Sharing Loadouts)
Every combination of settings produces a unique shortcode. This is split into two parts:
* **The Base Rules (Green):** Encodes your run modifiers, bug fixes, and QoL settings (e.g., `1AfB0V.3`). This is displayed permanently on your HUD so run verifiers can instantly see your ruleset.
* **The Hammer Payload (Gray):** Encodes your specific starting hammers.

In the **Profiles** tab, you can copy your full Hash to share with other runners. If you import a hash, it will perfectly replicate their setup. *Tip: If you import a "Base Rules" hash that lacks a hammer payload, it will safely update your toggles while leaving your personal hammer choices untouched!*

---

## Detailed Feature List

### Run Modifiers
**NPCs & Routing**
* **Force Medea / Arachne Spawn:** Forces these NPCs to spawn to reduce death-resetting for pity.
* **Disable Arachne Pity:** Disables Arachne pity completely for AnyFear runs.
* **Prevent Echo Scam:** Blocks both minibosses from spawning at Room 3 in the Fields, ensuring Echo always appears.
* **Disable Selene Before First Boon:** Prevents Selene's Gift from spawning until you have acquired at least one core Olympian boon or a hammer.

**World & Combat Tweaks**
* **RTA Mode:** Disables all combat-pausing encounters for RTA runs (Arachne cocoon room and good nem unchanged)
* **Skip Gem Boss Reward:** Bosses no longer drop gem rewards when using Grave Thirst.
* **Incrementing Fig Leaf:** Fig leaf chance starts at the default value (37%) and increases by 13% after every encounter, resetting at the start of each biome.
* **Surface Biome Restructure:** Thessaly minibosses are forced between rooms 2–4. Olympus mid-shop is forced between rooms 5–7. Heracles can no longer spawn on Thessaly.
* **Charybdis Behavior Adjustment:** Tentacles despawn for 1 second (instead of 9s) at phase transition. Spit attacks reduced from 8 to 6.

### Bug Fixes
**Weapons & Attacks**
* **Aspect of Selene Fix:** Correctly registers the Hex upon run start for immediate Path of Stars eligibility. Sky Fall always starts at full Moonglow.
* **Extra Dose Fix:** Now works with the Coat's second punch and dash strike.
* **Axe and Blade Omega Channel Fix:** Adjusts minimum weapon charge time for Axe Omega Attack and Blade Omega Special to properly benefit from channeling bonuses (Effectively makes channeling speed scale way better)
* **Tidal Ring Fix:** Removes immunity duration on Poseidon Cast Splash, allowing multiple hits with Circe staff.

**Boons & Hammers**
* **Poseidon Waves Fix:** Correctly triggers on all of Axe special three hits and Hidden Helix Torch.
* **Shimmering Moonshot Fix:** Applies intended damage bonus to Omega Special projectiles.
* **Remove Second Channeling:** Removes secondary channeling for Glorious Disaster and Giga Moonburst, baking mana cost and damage bonuses into the primary stage. Also Charon now procs Glorious Disaster.
* **Omega Cast Effects Fix:** Prominence Flare, Glorious Disaster, and Meat Grinder are correctly classified as Cast damage.
* **Cardio Torch Fix:** Cardio gain works properly on all Torch specials.
* **Braid of Atlas Fix:** Braid cast damage modifier correctly applies to all cast projectiles not just buffing OCast.
* **ET Fixes:** Fixes ET compatibility with Anubis Omega Attack by generating a closer field. Fixes Anubis OAtk field distance based on casting angle.

**NPC & Encounters**
* **Corrosion / Suffering Fix:** Prevents Corrosion on Sight from aggroing enemies on Thessaly boats. Suffering on Sight damage now bypasses wards.
* **GGG Echo Fix:** Allows GGG to be offered in Jpom runs.
* **Miniboss Encounter Fix:** Boar, Charybdis, Talos, and Summit minibosses correctly count toward room encounter depth.
* **Familiar Spawn Delay Fix:** Familiars spawn immediately upon entering a room.

### Quality of Life (QoL)
* **Always Show Location Counter:** Permanently displays the room depth counter on the HUD.
* **Auto Skip Dialogue:** Automatically skips dialogue prompts during gameplay.
* **Skip Cutscenes:** Skips the End-of-Run and Death cutscenes.
* **Spawn in Training Grounds:** Spawns you directly in the Training Grounds after death instead of the Crossroads.
* **Fixing Escape Behavior for KBM:** Keyboard & Mouse `Escape` key will now work properly during boon/pom selection, Hex selection, Path of Stars, and death sequences.

---

## Support & Known Issues
If you encounter any bugs, crashes, or unintended behavior, please open an issue on the [GitHub Repository](https://github.com/maybe-adamant/H2-Modpack) or reach out to me on discord (maybe.adamant).