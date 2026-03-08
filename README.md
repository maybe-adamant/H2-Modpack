# Hades 2 Utility and Bugfix Modpack

This mod provides an in-game ImGui menu to configure targeted gameplay adjustments, starting hammer selection, and various bug fixes. All features can be toggled individually. Inspired by Hades 1 Speedrunning Modpack.

Design philosophy is keep the game vanilla but remove some frustrating design choices.

## How to Use

Open the mod menu from the **Modpack** entry in the ImGui menu bar and click **Toggle Mod Menu**.

### Master Toggle
The **Enable Mod** checkbox at the top enables or disables the entire modpack. Disabling it automatically reverts all game data mutations — no restart needed.

### Tabs

1. **Quick Setup** — Pick a preset to configure the modpack in one click:
   - **AnyFear** — RTA disabled, Arachne pity disabled. For anyfear routing.
   - **HighFear** — RTA disabled, Arachne spawn forced. For highfear routing.
   - **AllWeps** — RTA enabled, all-weapons routing.
   - The dropdown auto-detects your current settings. If you manually tweak individual options it shows **Custom**.
   - Also includes quick toggles for all bug fixes (Enable All / Disable All) and a hammer selector for your currently equipped aspect.

2. **Hammers** — Select a guaranteed first hammer for each weapon aspect. Organized by weapon, with collapsible sections per aspect. If the selected hammer is ineligible due to weapon aspects or other conditions, the game defaults to vanilla random selection.

3. **Run Modifiers** — Toggle individual gameplay adjustments (see below). Settings grouped under collapsible headers.

4. **Bug Fixes** — Toggle individual bug fixes (see below). Each fix can be enabled or disabled independently.

### Applying Changes
Most settings require clicking the **Apply Changes** button (pinned to the bottom of the window) to take effect. The UI shows a warning when you have unapplied changes. Toggling a setting back to its applied state clears the warning automatically.

Live settings like **RTA Mode** and **Suffering Fix** take effect immediately without needing Apply.

## Run Modifiers

### NPCs & Routing
* **Force Medea Spawn:** Forces Medea to spawn to reduce death resetting for pity.
* **Force Arachne Spawn:** Forces Arachne to spawn to reduce death resetting for pity.
* **Disable Arachne Pity:** Disables Arachne pity completely for Anyfear runs.
* **Prevent Echo Scam:** Blocks both minibosses from spawning at room 3 in the Fields, ensuring Echo always appears.
* **Disable Selene Before First Boon:** Prevents Selene's Gift from spawning until the player has acquired at least one core Olympian boon or a hammer.

### World & Combat Tweaks
* **RTA Mode:** Disables all combat pausing encounters for RTA runs.
* **Less Sucky Surface:** Three adjustments:
  1. Thessaly minibosses forced between rooms 2–4 (consistent with other biomes).
  2. Olympus mid-shop forced between rooms 5–7 (consistent with Oceanus mid-shop).
  3. Hercules cannot spawn on Thessaly anymore.
* **Charybdis Behavior Adjustment:** Tentacles despawn in 1 second instead of 9 seconds at phase transition. Spit attacks reduced from 8 to 6.

## Bug Fixes

### Weapons & Attacks
* **Aspect of Selene Fix:** Correctly registers the Hex upon run start for immediate Path of Stars eligibility. Sky Fall always at full Moonglow.
* **Extra Dose Fix:** Extra Dose now works with Coat second punch and dash strike.
* **Staged Omega Fix:** Adjusts minimum weapon charge time for Axe Omega Attack and Blade Omega Special to benefit from channeling bonuses.
* **Tidal Ring Fix:** Removes immunity duration on Poseidon Cast Splash, allowing multiple hits with Circe staff.

### Boons & Hammers
* **Poseidon Waves Fix:** Poseidon wave effects correctly trigger on Axe special and Hidden Helix Torch.
* **Shimmering Moonshot Fix:** Applies intended damage bonus to Omega Special projectiles.
* **Second Stage Channeling Fix:** Removes secondary channeling for Glorious Disaster and Giga Moonburst, baking mana cost and damage bonuses into the primary stage. Glorious Disaster now works similar to other OCast expiring boons.
* **Omega Cast Effects Fix:** Omega Cast moves (Prominence Flare, Glorious Disaster, Meat Grinder) correctly classified as Cast damage.
* **Cardio Torch Fix:** Cardio gain works properly on all Torch specials (triggers multiple times on non-hidden aspect Torches and properly on Supay).
* **Braid of Atlas Fix:** Braid cast damage modifier correctly applies to all cast projectiles.
* **ET Fixes:** Fixes ET compatibility with Anubis Omega Attack by generating a closer field. Also fixes Anubis OAtk field distance based on casting angle.

### NPC & Encounters
* **Corrosion Fix:** Prevents Corrosion on Sight from aggroing enemies on Thessaly boats.
* **Suffering on Sight Fix:** Suffering on Sight damage now bypasses wards (consistent with Corrosion on Sight).
* **GGG Echo Fix:** Allows GGG to be offered in Jpom runs.
* **Miniboss Encounter Fix:** All mini bosses with top screen health bars (Boar, Charybdis, Talos, Typhon Eye/Arm) correctly count toward room encounter depth.
* **Familiar Spawn Delay Fix:** Familiars spawn immediately upon entering a room.
