class_name Balance
extends RefCounted

const ARENA := Rect2(30, 165, 660, 855)
const PLAYER_SPEED := 290.0
const BULLET_SPEED := 560.0
const MAX_BULLET_SPEED := 950.0
const MAX_ENEMIES := 48
const DEFLECT_RADIUS := 105.0
const HIT_COOLDOWN := 0.22
const COMBO_WINDOW := 3.0
const UPGRADE_NAMES := ["Heavy Bullet", "Accelerator", "Magnetic Assist", "Time Warp", "Fire Trail"]
const UPGRADE_INFO := ["+1 impact damage", "+12% bullet speed", "Stronger idle steering", "Slow enemies after deflect", "Leave burning ground"]
