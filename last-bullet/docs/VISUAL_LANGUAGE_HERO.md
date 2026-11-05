# v1.1.0 — Visuals, languages and hero growth

Completed 2026-11-05. This is a finite completed release, not an open-ended background task.

## Player-facing changes
- 41 original shaded vector icons: 12 weapons, 12 equipment templates, six pets, seven skills, four support items. Existing robot/enemy atlases retained. Weapon/pet appearances are reused in previews and combat. Ice, fire, electricity and laser projectiles plus seven skill effects have distinct shapes. Floating damage text expires after 0.65 seconds, capped at 20 and disabled by reduced effects.
- Arsenal uses a three-column catalog; Summon places rates/pity/resources and one/ten pulls together; Inventory uses illustrated two-column routes. Equipment has four slot tiles, rarity sorting and 12 entries per page. Existing bottom navigation, scrolling and safe layout remain.
- Settings → TIẾNG VIỆT / ENGLISH switches immediately, including formatted values. Default Vietnamese; choice persists in a separate language config shared by normal/admin. Names remain proper names. Custom Translation resources are removed on tree exit; no per-frame UI traversal.
- Hero Training in Inventory: each owned hero levels independently from 1 to 20, +2% damage per additional level, +1 HP at levels 5/10/15/20. Upgrade from level L costs 100×L gold and 2+floor(L/3) cores. Admin is free. Training applies next run; it does not silently change a current build.
- Boss/sweep loot grants one hero core (Normal) or two (Hard), plus two for a first-clear reward. Repair kit drops independently at 25%, one per successful roll. Receipts prevent paying completed clear rewards again. Supplies page explains sources.
- Two initial repair kits only when the save key is missing; an explicit stored zero remains zero. At supply/event rooms, one kit heals up to three HP, then checkpoints immediately. Not usable in combat or at full HP.
- Normal/elite rooms spawn groups of three/two every 2.8/2.4 seconds with original quota/live caps. Hard HP multiplier reduced from 1.65 to 1.45, retaining faster shots/extra fan patterns. Ember basic damage 0.50; Cobalt 0.80. Permanent hero growth is modest and gear/hero progression remains separate.

## Preservation and engineering
No ads, fake ads, purchases or extra summon costs. Preserve 12 free weapons, seven robots, all existing gear/pet/summon/pity/stars/checkpoints, hidden double-tap skill, drag-anywhere movement and stop-to-fire default. New save fields are additive; regular/admin files remain separate. Language preference is shared intentionally. Art textures are generated lazily, cached at 256px with mipmaps; offscreen scrolling thumbnails stop animation updates. Inventory is paged rather than instantiating 500 animated cards.

## Validation
Godot 4.6.3 import and 18 automated suites. New polish suite checks both-language templates/persistence, all 41 texture caches, hero costs/caps/stats/save, repair-kit guards/checkpoint/zero persistence, hero-core loot and damage-number cap/expiry/reduced-effects. Major-menu audit found zero Vietnamese leftovers in English. Rendered both languages at 360×800 with Xvfb/Mesa, including arsenal, summon, inventory, training, pets and admin equipment. Screens: docs/previews/v1.1-*.png.

Physical S23 Ultra FPS/heat/battery, gesture feel, APK export and long-term progression balance remain user playtests. Automated simulation is not a device benchmark.
