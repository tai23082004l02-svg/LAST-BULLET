> Historical design brief. v0.8.0 replaces permanent-bullet/Deflect gameplay with the user-approved auto-fire shooter. Read README.md and docs/SHOOTER.md for current rules. Original brief retained below.

# LAST BULLET — Codex Implementation Brief

**Studio:** ZORVYKA Games  
**Project:** LAST BULLET  
**Tagline:** One Shot. Endless Chaos.  
**Target:** Android-first, portrait (9:16), Godot 4.x, GDScript, 2D top-down arcade roguelite  
**Goal:** A small, genuinely playable prototype to test whether controlling one permanent ricocheting bullet is fun.

> **Instructions for Codex:** Implement the prototype, not just a design document. Create a complete Godot project with scenes, scripts, simple generated geometric visuals, controls, HUD, game loop, and README. Prioritize immediate playability, correctness, and clean extensibility. Do not spend time integrating ads, purchases, login, analytics, or online features yet. If the repository already contains a game, preserve it and create a separate `last-bullet/` project directory rather than overwriting anything.

## 1. Game Fantasy

The player is trapped in a compact arena filled with enemies. The player has **exactly one active physical bullet in the entire match**. That bullet never disappears: it bounces from arena walls, collides with enemies, and continues moving. The player moves to survive and can redirect the bullet using a skill-based deflection maneuver. Players pursue satisfying chain kills and a high score.

**Core loop:** Move -> dodge enemies -> observe bouncing bullet -> reposition for a deflect -> chain hits -> collect XP -> choose an upgrade -> survive escalating waves -> defeat a boss or die -> see results -> retry.

## 2. Non-Negotiable Rules

1. There must be **one and only one** active `Bullet` gameplay entity during a live run. Never spawn a duplicate for normal upgrades, boss mechanics, chain effects, or respawn.
2. The bullet persists when it hits enemies and boundaries. It changes direction according to deterministic collision rules, with a minimum speed to avoid stalling.
3. Enemy collision must be gated (per-target hit cooldown or separation/rearm logic) to prevent the same enemy receiving damage every physics frame while overlapping the bullet.
4. The bullet must not become permanently trapped in corners or repeated tiny ricochets; add a robust unstuck recovery that repositions/reorients the **same bullet** only when necessary.
5. A dead player ends the run; the bullet remains a single entity up to results transition. Restart resets state and starts a new run with one bullet.
6. All visuals must be legible on a small Android screen; use clear colors and shapes rather than depending on external art assets.

## 3. Camera & Screen

- Portrait 9:16, baseline 720x1280, canvas_items stretching and sensible UI anchors.
- One screen arena with visible boundaries, dark navy background, neon cyan bullet, mint-green player, coral-red enemies.
- Top bar: health, timer, wave, score, combo; XP bar and upgrade card overlay.
- Pause and results/retry screens.
- Use a Camera2D if useful but avoid complicated panning in the MVP.

## 4. Mobile Controls

- **Movement:** Virtual joystick in lower-left; touch dragging works; keep controls reachable with one thumb. Keyboard WASD/arrows for desktop testing.
- **Deflect:** Dedicated large button in lower-right, or keyboard Space for desktop.
- A deflect can succeed only when the bullet enters a clearly visualized radius around the player and the press is within a short timing window; on success, redirect toward the player's movement or aim direction (well-defined fallback if stationary). On failure, trigger short cooldown and feedback.
- Do not automatically punish the player with damage from their own bullet in MVP; bullet passes through player unless successfully deflected. This simplifies fairness and readability.
- If a single-thumb mode is attempted later, do it as an optional experiment, not the first implementation.

## 5. Bullet Physics & Combat

- Use `CharacterBody2D`, `Area2D`, `RayCast2D`, or a suitable Godot 4 physics pattern for a fast moving projectile. Prefer swept/ray-based collision handling to prevent tunneling at high speeds.
- Initial bullet shoots in a clear direction from the player at run start and remains active.
- Bounce off walls using contact normal and vector reflect (`Vector2.bounce(normal)` or equivalent), with slight positional separation after impact to avoid repeated collision at same coordinate.
- Enemy hit: deal bullet damage, register hit, update combo; bullet bounces or redirects in a predictable, fun way (start with reflection from enemy contact normal; tune during playtesting).
- Bullet base speed example: ~560 px/s in 720x1280 arena, configurable in one tuning resource/constants file.
- **Deflect** gives noticeable speed or damage boost for a brief duration, and redirects bullet to target the nearest enemy OR according to movement direction. Select one primary system and make it consistent; document choice in README.
- After ~5 seconds without damaging any enemy, activate *soft assist* (small steering force toward nearest enemy, capped to prevent impossible instant turns). Never teleport the bullet casually.
- If no enemies are alive, bullet continues bouncing while new wave starts.

## 6. Enemies & Waves

Implement **three simple enemy classes** using readable geometry:

- **Chaser** (circle): Moves directly toward player, basic health/speed.
- **Dasher** (triangle): Telegraphs a dash, then lunges; attack has cooldown.
- **Tank** (square): Slow and durable, encouraging multiple hits.

- Spawn along valid inner-edge positions, never on top of the player.
- Scale enemy spawn rates and health over time with a safe cap for performance.
- Enemy body contact damages player with invulnerability frames after a hit.
- Five-minute MVP survival target; allow continuing longer if fun.
- Boss at approximately 4 minutes: **Bullet Eater**, a large enemy that temporarily captures the *same bullet* and releases it on a telegraphed path; do **not** create a second bullet. If complex, ship simpler boss behavior first and mark Bullet Eater advanced mechanic as TODO.

## 7. Combo, XP & Upgrades

- Combo grows from consecutive bullet kills within a time window (e.g., 3 seconds), expires after a pause. Display a satisfying but non-obscuring combo popup at thresholds (5, 20, 50).
- Score comes from enemy kills + combo bonuses + survival time.
- Enemies drop XP pickups; player collects by proximity.
- Level-up pauses action and offers **3 randomly selected upgrades** from an initial pool of 5:
  1. Heavy Bullet: more bullet impact damage.
  2. Accelerator: slightly more bullet speed (with sensible speed cap).
  3. Magnetic Assist: stronger steering toward enemy when idle.
  4. Time Warp: brief slow motion after successful deflect (keep UI intuitive).
  5. Fire Trail: short-lived damage zone behind **the same bullet** (not additional bullets; throttle particle/effect count).
- Upgrades stack to controlled limits. Avoid runaway FPS/performance costs.
- Keep stats configurable.

## 8. Screens & User Flow

1. **Title:** LAST BULLET / Play / How to Play / Quit (desktop only where appropriate).
2. **How to Play:** Three short instructions, visually clean.
3. **In-game:** Immediate movement, single bullet, wave display, HP, score, XP, pause.
4. **Level-up:** Three selectable upgrade cards, game paused.
5. **Game over:** Survival time, highest combo, score, kills, Retry, Main Menu.
6. Optional save only for best score locally; do not build account systems yet.

## 9. Godot Architecture (suggested; adapt if a cleaner approach exists)

```text
last-bullet/
  project.godot
  README.md
  scenes/
    MainMenu.tscn
    Game.tscn
    Player.tscn
    Bullet.tscn
    Enemy.tscn
    HUD.tscn
    LevelUp.tscn
    GameOver.tscn
  scripts/
    game.gd
    player.gd
    bullet.gd
    enemy.gd
    wave_manager.gd
    hud.gd
    level_up.gd
    save_manager.gd
    game_balance.gd
  assets/                 # only if needed; primitive 2D is enough
```

Use signals for hit/kill/xp/level-up/game-over; prefer typed GDScript and avoid circular dependencies. Place all key balance values in an easy-to-edit file/resource. A single root `Game` owns the run state and bullet lifecycle. Ensure it cannot spawn duplicate bullets.

## 10. Implementation Phases — complete in order

**Phase A — Fun test (highest priority):** Playable arena, joystick + keyboard movement, exactly one ricocheting bullet, Chaser enemies, damage and death, reliable physics, restart. Check controls feel good before adding content.

**Phase B — Feedback loop:** Add waves, other enemy types, score, combo, XP, level-ups, upgrade effects and HUD.

**Phase C — Polish + Android:** Add menu, pause, results, small-screen layout, low-cost effects, Android orientation/export notes and best-score persistence. Add boss if feasible without compromising stability.

Codex should run Godot CLI import/headless project validation if Godot is available. If unavailable, explicitly state it could not run the engine and give exact steps for manual verification. Do not claim to have tested Android without running it.

## 11. Acceptance Criteria

- Project opens in Godot 4 without parse errors or missing assets.
- Desktop: move with WASD/arrows; deflect with Space.
- Android: virtual joystick and deflect button respond to touch; portrait HUD readable.
- Exactly one persistent bullet exists throughout a live run, including after upgrades and boss interactions.
- Bullet reflects reliably at boundaries, does not pass through normal walls at tuned speed, and does not freeze forever.
- Hits kill enemies, score and combo increment, XP and upgrades work.
- Player can lose, see results, and retry with clean reset.
- FPS remains reasonably stable with many enemies on ordinary phones (profile and cap counts where needed).
- README documents controls, main scenes, balance settings, how to run, how to export Android, known limitations, and what is deferred.

## 12. Explicitly Defer These Features

No AdMob/rewarded ads, in-app purchases, Google Sign-In, Firebase, Play Integrity, leaderboards, automatic farming, cloud save, anti-cheat backend, localization beyond simple prepared text keys, multiplayer, live events, or subscriptions. Add them only after the single-bullet core is validated by real players.

## 13. Developer Notes

- Treat all names, stats, values and durations above as **starting tuning suggestions**, not finished balance.
- Favor a small playable game over a large incomplete one.
- Do not silently change the one-bullet rule.
- If an idea proves technically difficult, implement the smallest stable version, document the compromise, and continue.
- Keep game distinct from Swarm Survivor and preserve any existing repository files.

**Start implementing now. When finished, summarize files created, launch instructions, the exact Godot version tested (if available), and remaining issues.**
