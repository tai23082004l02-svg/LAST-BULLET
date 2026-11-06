# Illustrated pets and weapons — v1.1.1

2026-11-06. Replaces flat geometric pet/weapon icons with two original image-generated transparent sprite atlases. Six unique pets: gold Bee, horseshoe Magnet, white medical bunny Medic, armored turtle Bulwark, ice fox Frostling, orange beetle Bomber. Twelve distinct weapon bodies preserve existing catalog order: assault rifle, arc, frost, flame, laser, shotgun, scout, rockets, bow, boomerang, grenade, venom.

Atlas source dimensions: pets 1536×1024, 3×2 cells; weapons 1254×1254, 4×4 cells (first three rows, fourth empty). Integer cell boundaries prevent fractional edge sampling. Extract alpha bounds, preserve aspect ratio, fit to 232px within transparent 256px texture with mipmaps and lazy shared cache. This avoids per-frame decoding/rasterization; original atlas images are retained once in memory. Source PNGs approximately 3.6MiB combined. Other equipment/skill/support vectors remain unchanged.

The same texture function feeds inventory tiles, detail pages, collection and in-world companion rendering. Larger art area, selected preview and more visible locked pet art; lock and ownership remain authoritative. Weapon projectile previews remain animated. No animation frames invented: sprites use existing hover/bob animation.

Validated Godot 4.6.3 import, illustrated_art (18 unique textures, transparent corners, fitted bounds, mipmaps and cache), polish, graphics, pets_practice, rpg_inventory, lobby, arsenal. Rendered VI/EN arsenal and VI pets at 360×800 with Xvfb/Mesa. Screens docs/previews/v1.1.1-*.png. No actual S23 Ultra FPS/thermal or APK claim. No gameplay/economy/save schema changes.
