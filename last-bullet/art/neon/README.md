# Neon Arcade visual pack — v0.4.0

Original AI-generated art created for this project after approval of the Neon Arcade robot concept. PNG originals are preserved; sprite selection is performed through Godot AtlasTexture regions, without rewriting the source sheet.

- `robots.png`: 1774×887 RGBA, eight illustrated assets in 4×2 order: hero, Chaser, Dasher, Tank, Shield Guard, Zone Caster, Bullet Eater, reflector pillar.
- `arena.png`: 1086×1448 navy metal floor/frame.
- `icon.png`: 1254×1254 app icon based on the mint hero. Imported at 256px to keep its runtime footprint small; original file remains available for future export preparation. Android adaptive foreground/background layers are not configured yet.
- `neon_art.gd`: explicit atlas regions with transparent gutters, shared region cache, stylized text/panels/buttons, icon drawing and shadows/glows.
- `.png.import`: mipmaps for scaled robot/floor art and alpha-edge fixing. Render filter is linear with mipmaps.

Visuals are decorative. Physics radii and one-bullet ownership remain in the gameplay scripts. Hero limbs, enemy claws, glow and trails can extend outside their collision circles.

Animations are time-based procedural idle/hover/lean, spawn scale, hit flash and per-state overlays; no directional multi-frame walk sheets are claimed. Player/bullet/enemy movement uses Godot physics interpolation. Shield facing, dash/zone telegraphs and boss exposure are linked to real gameplay state.

FX use one bounded renderer (80 events normally, 24 reduced), not extra physical bullets. Rendering targets Godot Compatibility without full-screen postprocessing. Device profiling remains necessary before mobile release.

Preview screenshots and the 8-second scripted Godot motion recording are under `../../docs/previews/`.

## v0.5.0 player roster
`heroes.png` is a new 1536×1024 RGBA sheet, 3×2: Volt, Frost, Ember, Nova, Cobalt, Scout. AI-generated to match Aegis; original pixels preserved. `robot_roster.gd` defines shared atlas regions, display names/colors, normal unlock prices and cosmetic descriptions. Admin unlocks all seven pilots. Player visuals use the selected atlas region with the same pose animation and physics body.
