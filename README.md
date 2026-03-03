# Hades 2 Utility and Bugfix Modpack

This mod provides an in-game ImGui menu to configure targeted gameplay adjustments, starting hammer selection, and various bug fixes. All features can be toggled individually. Inspired by Hades 1 Speedrunning Modpack

## Features & Gameplay Adjustments

* **Starting Hammer Selection:** Allows the player to select a specific hammer for their equipped weapon via the in-game UI. The chosen hammer is guaranteed on the first hammer drop. If the selected hammer is ineligible due to weapon aspects or other conditions, the game defaults to vanilla random generation.
* **Arachne and Medea Pity:** Forces the Medea pity mechanic and disables the Arachne pity mechanic.
* **Charybdis Behavior Adjustment:** Modifies the Charybdis mini boss fight phase transition. Tentacles despawn for 1 second instead of 9 seconds, and spit attacks during transition are reduced from 8 to 6.
* **Disable Selene Before First Boon:** Prevents Selene's Gift from spawning until the player has acquired at least one core Olympian boon or a hammer.

## Bug Fixes

**General Combat & Mechanics**
* **Corrosion Fix:** Prevents Corrosion on Sight effect from unintentionally drawing aggression from enemies on Thessaly boats.
* **GGG Echo Fix:** Adjusts requirements to allow the GGG Echo boon to be offered if the player ever equiped Jpom or Eris Keepsake..
* **Braid of Atlas Fix:** Ensures the temporary damage modifier correctly applies to all cast projectiles.
* **Extra Dose Fix:** Extra Dose now works with the Coat second punch and dash strike.
* **Omega Cast Effects Fix:** Ensures specific Omega Cast moves (e.g., Prominence Flare, Glorious Disaster, Meat Grinder) are correctly classified as Cast damage to benefit from relevant damage modifiers.
* **Aspect of Selene Fix:** Correctly registers the Hex upon run start making the player eligible to receive Path of Stars upgrades right away. Also Sky Fall is always at full Moonglow (+5 Path of Stars point on first pick)

**Boons & Upgrades**
* **Poseidon Waves Fix:** Poseidon wave effects correctly trigger on the Axe special and the Hidden Helix Torch.
* **Tidal Ring Fix:** Removes the immunity duration on Poseidon Cast Splash, allowing it to hit the same enemy multiple times with the Circe staff.
* **Shimmering Moonshot Fix:** Applies the intended damage bonus to Omega Special projectiles.
* **Staged Omega Fix:** Adjusts the minimum weapon charge time for Axe Omega Attack and Blade Omega Special to ensure they benefit from channeling bonuses (Furious Whirlwind and Sudden Flurry are somewhat good now)
* **Exceptional Talent Fix:** Fixes compatibility with Anubis Omega Attack by making ET generate another field closer to the player. Stacking it with Mirrored Ankh now creates three fields. Also compatibility fix with Supay Omega Attack by making ET doubles the firing rate of the Omega Attack.
* **Second Stage Channeling Fix:** Removes the secondary channeling requirement for Glorious Disaster and Giga Moonburst, baking the mana cost and damage bonuses directly into the primary stage charge. No localization changes yet (might update it later)
* **Cardio Torch Fix:** Cardio gain now works properly on all Torch specials (It triggers multiple times on non hidden aspect Torches and it triggers properly on Supay).