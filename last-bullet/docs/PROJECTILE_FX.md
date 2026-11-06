# Projectile visuals — v1.1.2

All12 primaries now use scripts/projectile_art.gd in real combat and arsenal preview. Assault/pellets/scout use different metallic/energy tracer lengths; arc has animated zigzags; frost a faceted ice shard with crystals; flame layered amber/orange fire; laser a three-layer long violet streak; rockets have metal body, orange nose and flickering exhaust; bow has arrowhead/fletching/green trail; boomerang rotates three blades; grenade has shell/band/fuse; venom has green globule/bubble trail. These are cosmetic stylizations, not changes to collision radius or range.

Muzzle flash uses aim direction. Actual enemy and wall contacts create style-specific sparks/crystal fragments/electric arcs/poison bubbles. Splash damage radius/gameplay unchanged; the existing splash ring remains. Arsenal displays shared projectiles, muzzle and impact animation without spawning actual combat shots.

No physics bodies, timers, per-particle nodes, trail history or texture uploads added. Existing160 friendly/180 hostile/32 flash caps remain. Drawing never consumes gameplay RNG. Low-effects reduces glow/spark layers while retaining weapon shape/core and enemy bullet distinction; pause/reset lifecycle retained. No camera shake or full-screen flashes added.

Validation: Godot4.6.3 import; eight suites projectile_fx, arsenal, arsenal_stress, shooting, shooter_stress, graphics, polish, pets_practice. projectile_fx verifies each12 real fire/impact route, pause freeze,32-cap/reset. Rendered all12 in full and reduced modes and actual arsenal via Xvfb/Mesa; fixed degenerate muzzle polygon discovered in visual pass. Screens previews/v1.1.2-projectiles.png, v1.1.2-projectiles-reduced.png, v1.1.2-arsenal.png. No physical S23 Ultra performance claim.
