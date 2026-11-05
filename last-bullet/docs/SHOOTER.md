# v0.8 shooter implementation

The approved change replaces permanent-bullet Deflect combat with auto-aim/auto-fire and double-tap robot skills. Seven weapon profiles and seven skills live in scripts/combat.gd. No Deflect/capture/return-strike path remains in live combat; scripts/bullet.gd now holds static cosmetic preview helpers only.

## Simulation and bounds
Friendly shots have finite range/lifetime, swept enemy/wall collision, ordered contacts, finite piercing/chaining and per-shot hit IDs. Target selection chooses the nearest visible enemy in weapon range. Chain targeting respects walls. Cobalt skill missiles turn at a capped rate and splash locally. Enemy shots use swept player/wall collision; their red/orange appearance distinguishes them from friendly rounds. Enemy ranged units and bosses have a short charge ring before firing.

Combat uses one bounded renderer/controller, no per-shot nodes: at most 160 friendly shots, 180 hostile shots and 32 flashes. Enemy count and existing particle/pickup bounds remain. Paused/upgrade/result states do not advance shots, timers or damage; new runs clear arrays. Physics timestep tests check collision over larger steps. This is boundedness evidence, not a phone FPS benchmark.

## Tuning
Base intervals Aegis/Volt/Frost/Ember/Nova/Cobalt/Scout: .38/.18/.52/.12/.85/.8/.26 seconds. Base single-shot damage: 1.4/.65/1.7/.42/3.5/1/.9. Shotgun has five base pellets; laser has three extra penetrations; Volt has one base chain; Frost chills; Ember applies burn. Weapon ranges: 620/560/620/230/720/440/720 logical pixels. Skills have 10/9/10/9/12/10/6-second base cooldowns. These are initial playtest values, not a balance guarantee.

Upgrades: +22% base damage per level, +16% fire-rate denominator, extra pellets/lanes, +8 percentage points crit chance (1.8x), burn damage/sec for two seconds, extra pierce, chain to another visible enemy within 260 pixels, -10% skill cooldown per level. Caps 5/5/3/5/5/3/3/3. Fire ticks every .5s; repeated burn refreshes duration without stacking weaker damage. Aegis shield lasts 3s or 3 blocks. Scout dashes in 12 obstacle-resolved steps with .65s invulnerability. Skills respect paused states and cooldowns; admin can disable cooldown locally.

## Progression migration
Save files and inventory/campaign/summon keys remain. save_profile first loads existing config so legacy and unknown fields survive. New scores use record/shooter_score and shooter_blitz; old score/blitz fields stay untouched. profile/combat_version=2 records the new schema. Old admin free_deflect is read only as a fallback for free_skill. No currency conversion, new starter ticket grant or inventory reset occurs.

Missions are kills 15, skills used 3 and kill-chain 10, each paying 15 gold+1 ticket once/run. Stars: victory, HP>=3, finish no later than 60 seconds after the scheduled boss arrival. Existing stars/unlocks remain valid. Boss capture is gone; normal bullets and skills can kill all bosses. Existing reward/result guards retain once-only x2 and profile isolation. No ads, payments or backend added.

## Validation
Current automated suites: shooting, shooter_campaign, shooter_stress, admin_mobile, robots, summon, graphics, lobby, results, upgrade_ui. Historical Deflect-only tests moved to tests/legacy with .gdignore and are not counted as passing. Shooter stress simulates 630s across seven max-upgrade robots plus 90s Blitz; campaign exercises all five active timelines and bosses. See TEST_RESULTS.md for scope/limitations.

## Double-tap skill controls (latest)

Skill button removed. Two short taps in the same blank area activate the skill on second release, <=330ms apart and <=48 logical pixels apart; each contact <=220ms and <12px movement. Long holds, canceled touches, drags (including drag returning to origin), distant/slow pairs, simultaneous fingers and GUI contacts do not qualify. A second finger can double-tap while another continues dragging movement. Emulated mouse events from touch are ignored; desktop real mouse taps and Space remain supported.

Only unhandled blank-area presses become tap candidates; global input observes movement/releases to cancel gestures even when they end over GUI. Pause/menu/upgrade/run transitions clear candidates so stale taps cannot carry over. Existing skill cooldown and state guards are authoritative. A passive status label shows cooldown, consumes no input, and hides outside active gameplay.

New tests/double_tap.gd covers recognition, cooldown, drag/jitter/hold/cancel/time/distance rejection, simultaneous vs sequential taps, continuous movement plus second-finger skill, UI/state boundaries and emulated input. Also rechecked shooting, admin_mobile, upgrade_ui, graphics and lobby. Rendered hidden-button layout at 360×800. Physical Android gesture feel still awaits user confirmation.
