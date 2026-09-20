extends RefCounted
class_name Sprites
## Authored pixel-art sprite data: each grid constant is consumed by
## PixelArt.make_texture()/make_sprite(). '.' is transparent.
## Palettes are functions (not consts) because they reference the
## Palette autoload, which is only guaranteed ready at runtime.

const PLAYER_SHIP: Array = [".......LL.............", ".........LL...........", "......LLLGGLLL........", ".....LGGGGGGGGLL......", "F.LLLGGGGGGGGCCCLLL...", "ffGGGGGGGGGGGCCCGGGLL.", "F.DDDGGGGGGGGGGGDDD...", ".....DGGGGGGGGDD......", "......DDDGGDDD........", ".......DDDD...........", ".......DD............."]
const FLYER: Array = ["................", "................", "..RRRPPPPPPRRR..", "RRRRRRRRRRRRRRRR", "RRRRRRRPPRRRRRRR", "..RRRRRRRRRRRR..", "...KKKKKKKKKK...", "................", "................"]
const TURRET: Array = [".....PK.....", ".....KK.....", ".....KK.....", "...RRRRRR...", "...RRRRRR...", ".KKRRRRRRKK.", ".BBBBBBBBBB.", ".BBBBBBBBBB.", ".BBBBBBBBBB."]
const FUEL_TANK: Array = ["..........", ".LLLLLLLL.", ".DYYYYYYL.", ".DYYYYYYL.", ".DYKKKKYL.", ".DYKKKKYL.", ".DYYYYYYL.", ".DYYYYYYL.", ".DDDDDDDD.", ".........."]
const MISSILE: Array = ["...T...", "..TTT..", "..MMM..", "..DDD..", "..MMM..", "..MMM..", "..MMM..", "..MMM..", "..MMM..", "..MMM..", "..MMM..", ".MMMMM.", "MMMMMMM", "..MTM.."]
const BASE_ROCKET: Array = ["....TTTTTTT.....", ".....TTTTT......", "......TTT.......", "...MMMMMMMMM....", "...MMMMMMMMM....", "...MMMMMMMMM....", "...MMMMMMMMM....", "...MMMMMMMMM....", "...MMMMMMMMM....", "...MMMMMMMMM....", "...KKKKKKKKK....", "...KKKKKKKKK....", "...MMMMMMMMM....", "...MMMMMMMMM....", "...MMMMMMMMM....", "...MMMMMMMMM....", "...MMMMMMMMM....", "...MMMMMMMMM....", "...KKKKKKKKK....", "...KKKKKKKKK....", "...MMMMMMMMM....", "...MMMMMMMMM....", "...MMMMMMMMM....", "...MMMMMMMMM....", "..MMMMMMMMMM.M..", "..MMMMMMMMMM.M..", "..M.MMMMMMM..M..", "..M.MMMMMMM..M..", ".MM.MMMMMMM..MM.", ".M..MMMMMMM...M."]
const BULLET: Array = ["BB", "BB"]
const BOMB: Array = [".O.", "OOO", ".O."]
const ENEMY_SHOT: Array = [".K.", "KKK", ".K."]

static func player_palette() -> Dictionary:
	return {"F": Palette.FLAME_ORANGE, "f": Palette.FLAME_YELLOW, "G": Palette.SHIP_GREEN, "L": Palette.SHIP_LIGHT, "D": Palette.SHIP_DARK, "C": Palette.COCKPIT}

static func flyer_palette() -> Dictionary:
	return {"R": Palette.ENEMY_PURPLE, "P": Palette.SAUCER_HL, "K": Palette.ENEMY_DARK}

static func turret_palette() -> Dictionary:
	return {"B": Palette.TURRET_BASE, "K": Palette.TURRET_BARREL, "R": Palette.ENEMY_RED, "P": Palette.TURRET_TIP}

static func fuel_tank_palette() -> Dictionary:
	return {"Y": Palette.TANK_YELLOW, "L": Palette.WHITE, "D": Palette.TANK_DARK, "K": Palette.ENEMY_DARK}

static func missile_palette() -> Dictionary:
	return {"M": Palette.MISSILE_BODY, "T": Palette.MISSILE_TIP, "D": Palette.GREY}

static func base_rocket_palette() -> Dictionary:
	return {"M": Palette.MISSILE_BODY, "T": Palette.MISSILE_TIP, "K": Palette.ENEMY_RED}

static func bullet_palette() -> Dictionary:
	return {"B": Palette.BULLET}

static func bomb_palette() -> Dictionary:
	return {"O": Palette.BOMB}

static func enemy_shot_palette() -> Dictionary:
	return {"K": Palette.ENEMY_RED}
