extends Node
## Global retro colour palette shared by every procedurally generated sprite.
## Kept deliberately small and saturated to match late-1970s arcade hardware
## (a handful of RGB colours, no gradients, no anti-aliasing).

const BLACK := Color8(0, 0, 0, 0)
const VOID := Color8(6, 6, 14)
const WHITE := Color8(240, 240, 240)
const GREY := Color8(120, 120, 130)
const DARK_GREY := Color8(60, 60, 68)

const SHIP_GREEN := Color8(57, 255, 106)
const SHIP_LIGHT := Color8(180, 255, 210)
const SHIP_DARK := Color8(20, 140, 60)
const COCKPIT := Color8(120, 220, 255)

const FLAME_ORANGE := Color8(255, 140, 40)
const FLAME_YELLOW := Color8(255, 215, 60)

const BULLET := Color8(255, 240, 120)
const BOMB := Color8(255, 120, 60)

const ENEMY_RED := Color8(255, 70, 70)
const ENEMY_PURPLE := Color8(200, 80, 220)
const ENEMY_DARK := Color8(120, 30, 40)

const MISSILE_BODY := Color8(230, 230, 240)
const MISSILE_TIP := Color8(255, 70, 70)

const TANK_YELLOW := Color8(255, 200, 40)
const TANK_DARK := Color8(160, 110, 10)

const TERRAIN_ROCK := Color8(150, 90, 40)
const TERRAIN_ROCK_DARK := Color8(95, 55, 25)
const TERRAIN_ROCK_LIGHT := Color8(200, 140, 70)
const TERRAIN_CAVE := Color8(70, 40, 90)
const TERRAIN_CAVE_DARK := Color8(40, 20, 55)

const EXPLOSION_1 := Color8(255, 240, 120)
const EXPLOSION_2 := Color8(255, 140, 40)
const EXPLOSION_3 := Color8(255, 60, 60)

const STAR := Color8(200, 200, 220)

const HUD_TEXT := Color8(57, 255, 106)
const HUD_WARN := Color8(255, 70, 70)
const HUD_GOLD := Color8(255, 215, 60)

const SAUCER_HL := Color8(230, 200, 255)
const TURRET_BASE := Color8(100, 100, 110)
const TURRET_BARREL := Color8(40, 40, 46)
const TURRET_TIP := Color8(255, 220, 120)
