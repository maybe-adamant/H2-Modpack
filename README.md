# Hades 2 Utility and Bugfix Modpack

This mod provides an in-game ImGui menu to configure targeted gameplay adjustments, starting hammer selection, and various bug fixes. All features can be toggled individually. Inspired by Hades 1 Speedrunning Modpack

Design philosphy is keep the game vanilla but remove some frustrating design choices.

## Features & Gameplay Adjustments

* **RTA Mode:** Disables all combat pausing encounters for RTA runs 
* **Starting Hammer Selection:** Allows the player to select a specific hammer for their equipped weapon via the in-game UI. The chosen hammer is guaranteed on the first hammer drop. If the selected hammer is ineligible due to weapon aspects or other conditions, the game defaults to vanilla random generation.
* **Medea Pity:** Forces Medea to spawn to reduce death resetting for pity.
* **Arachne Pity:** Forces Arachne to spawn to reduce death resetting for pity.
* **Disable Arachne Pity:** Disable Arachne pity completely for Anyfear runs
* **Charybdis Behavior Adjustment:** Modifies the Charybdis mini boss fight phase transition. Tentacles despawn for 1 second instead of 9 seconds, and spit attacks during transition are reduced from 8 to 6.
* **Echo scam gone:** You will no longer get Echo scammed. Mod will now prevent one of the minibosses at random from spawning at room 3 in the field and thus ensuring that Echo always appear.
* **Less Sucky Surface:** Three adjustments to the Surface:  
1-Thessaly minibosses are forced to appear between rooms 2 and 4 (consistent with other biomes).  
2-the Olympus mid-shop is forced to appear between rooms 5 and 7 (consistent with the Oceanus mid-shop).  
3-Hercales cannot spawn on Thessaly anymore.
* **Disable Selene Before First Boon:** Prevents Selene's Gift from spawning until the player has acquired at least one core Olympian boon or a hammer.

## Bug Fixes And Adjustment

* **Corrosion Fix:** Prevents Corrosion on Sight effect from unintentionally drawing aggression from enemies on Thessaly boats.
* **GGG Echo Fix:** Adjusts requirements to allow the GGG Echo boon to be offered if the player ever equiped Jpom or Eris Keepsake..
* **Braid of Atlas Fix:** Ensures that Braid cast damage modifier correctly applies to all cast projectiles.
* **Miniboss Encounter Fix:** All mini bosses with top screen health bars like Boar, Charybdis, Talos, and Typhon Eye/Arm encounters now correctly count toward room encounter depth.
* **Extra Dose Fix:** Extra Dose now works with the Coat second punch and dash strike.
* **Omega Cast Effects Fix:** Ensures specific Omega Cast moves (e.g., Prominence Flare, Glorious Disaster, Meat Grinder) are correctly classified as Cast damage to benefit from relevant damage modifiers.
* **Aspect of Selene Fix:** Correctly registers the Hex upon run start making the player eligible to receive Path of Stars upgrades right away. Also Sky Fall is always at full Moonglow (+2 Path of Stars point on first pick instead of 0)
* **Poseidon Waves Fix:** Poseidon wave effects correctly trigger on the Axe special and the Hidden Helix Torch.
* **Tidal Ring Fix:** Removes the immunity duration on Poseidon Cast Splash, allowing it to hit the same enemy multiple times with the Circe staff.
* **Shimmering Moonshot Fix:** Applies the intended damage bonus to Omega Special projectiles.
* **Staged Omega Fix:** Adjusts the minimum weapon charge time for Axe Omega Attack and Blade Omega Special to ensure they benefit from channeling bonuses (Furious Whirlwind and Sudden Flurry are somewhat good now)
* **Exceptional Talent Fix:** Fixes compatibility with Anubis Omega Attack by making ET generate another field closer to the player. Stacking it with Mirrored Ankh now creates three fields. 
* **Stacking Anubis OAtk Adjustment:** Attempted to fix how multiple Anubis OAtk fields are placed in general to make them look more consistent when placed horizontally and vertically.
* **Second Stage Channeling Fix:** Removes the secondary channeling requirement for Glorious Disaster and Giga Moonburst, baking the mana cost and damage bonuses directly into the primary stage charge. No localization changes yet (boon description remain unchanged might update it later)
* **Cardio Torch Fix:** Cardio gain now works properly on all Torch specials (It triggers multiple times on non hidden aspect Torches and it triggers properly on Supay).
* **Familiar Spawn Delay Fix:** Familiar now spawn as soon as you enter a room allowing Gale to block hits right away and maybe buffing Toula (might revert if that's the case)
* **Suffering on Sight Fix:** Suffering on Sight damage now bypasses wards similar to how Corrosion on Sight works.

