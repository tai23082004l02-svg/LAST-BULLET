# Equipped weapons during combat — v1.1.3

Robot now visibly carries its chosen arsenal weapon. Hero-default selection uses the corresponding original robot weapon; free primary overrides remain independent of robot skill. Shared art/arsenal textures are reused; no extra character atlases or per-frame texture creation.

Carry drawing lives in player_visual.gd. Weapon rotates with actual aim, mirrors its local vertical axis for left aim to preserve upright artwork, and appears behind robot when aimed upward / in front otherwise. Arm/grip overlays attach it to the body; widths56–72 logical pixels by family. Recoil1.8–5 pixels settles with time, freezes with visual clock while paused, resets on new run. Body hit flash remains readable. Original aim indicator line removed.

Combat fire triggers recoil and sets muzzle flash at transformed barrel including recoil. Actual projectile origin/collision remains at player center: this is deliberately a visual attachment so nearby hits, pillars, range and damage do not change. No new input, gun costs, aim assist changes, save fields or project.godot modification. Existing double-tap skill and drag-anywhere controls stay.

Validated Godot4.6.3 import and seven suites: held_weapon, arsenal, projectile_fx, graphics, arsenal_stress, shooting, admin_mobile. held_weapon covers seven defaults/twelve equips, eight aim directions, real muzzle coordinate alignment, bounded pose, recoil freeze/reset and unchanged shot origin. Rendered12 poses and actual gameplay at360×800, Xvfb/Mesa. Screens previews/v1.1.3-held-weapons.png and v1.1.3-gameplay.png. Physical phone feel/FPS remains unverified.
