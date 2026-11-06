# One-room 3D trial — v1.3.0

User approved one test room, not conversion of all content. Open THỬ3D at the top-right of the lobby title or Modes→PHÒNG THỬ3D. It can also be run directly as prototype3d/Room.tscn in Godot4.6.3.

## What is playable
One original mint robot and a teal rifle, one red Sentinel enemy type, three waves of3/4/4. Real3D camera, lit geometry, floor/gate/walls/two covers. Run/idle/aim/recoil use rigid articulated joint transforms. Enemies approach/strafe, telegraph a target ring before firing orange orbs. Cover blocks both sides' shots. You have5HP; retry on defeat, room completion after11kills. No progression/reward/economy integration.

Drag any blank screen area to move; a tap alone does not move. Release to auto-fire at a nearby visible enemy. Optional moving-fire button is local to trial. Double tap same area for a3.1-unit pulse (8-second cooldown); second-finger taps may activate while first drags. Special UI buttons excluded. PC: WASD/arrows, Space skill, Esc pause. Pause/return/retry controls; Android back returns, focus loss pauses. Original2D controls/settings remain unchanged.

## Rendering and scope
This is an original geometric art prototype, not Habby assets or finished production models. robot.gd builds shared low-segment sphere/cylinder/box meshes with solid-color metallic materials and emission accents; leg/arm pivots animate rigid parts. There is no skinned character mesh/Skeleton3D animation export yet. The rifle moves with the robot, recoils and emits from its muzzle toward the target. True3D geometry is used rather than a sprite pretending to be3D.

Camera is orthographic with adaptive size to keep room width visible on tall phones. Fixed lighting, contact-shadow meshes and emissive accents; no dynamic shadow map, SSAO, SSR, glow postprocess, animation texture frames or added high-resolution3D textures. Compatibility renderer/project.godot remains untouched. Shared primitive mesh cache/ring mesh and material reuse;48shot and24ring caps, max4enemies. High:2x MSAA/full internal SubViewport; Low: no MSAA/half each viewport axis (one-quarter pixel count), not a guaranteed FPS multiplier. Pause/result uses UPDATE_ONCE; restart resumes drawing.

The existing2D scene remains loaded and disabled while trial is a sibling scene with own World3D. This protects profiles and return behavior, but keeps2D textures resident; measuring this hybrid build does not directly compare total memory of finished2D vs3D versions. No phone FPS, battery, temperature or final visual-quality claims. A production conversion would require proper art/rigging/LOD, profiling and separate asset-loading strategy after approval.

## Preservation and testing
Trial does not call save_profile, grant rewards, spend resources, alter selected hero/weapon, unlock campaign or replace checkpoint. It freezes2D gameplay/input/UI and restores it on return; frees its own audio/viewport/world/nodes. Normal/admin states untouched. Trial preferences are not persisted. Standard VI/EN engine translation inherited from host language settings.

Godot4.6.3 import clean. Nine suites pass: prototype3d, lobby, admin_mobile, shop, checkpoint_rewards, shooter_campaign, arsenal, held_weapon, graphics. New prototype suite validates input thresholds/GUI/second-finger skill, pause/quality, swept bullet collision/cover, resource caps, deterministic full3-wave bot victory, failure/retry, repeated return cleanup, and exact profile file hash before/after. This is simulation validation, not device performance testing.

Screens: previews/v1.3-3d-*.png. previews/v1.3-3d-preview.mp4 is8seconds of scripted movement/shooting rendered offline at15frames per simulated second; it is not recorded S23 Ultra FPS footage. On phone test High vs Low, control feel, framing, warm-up and battery before deciding the next direction.
