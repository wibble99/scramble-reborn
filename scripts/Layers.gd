extends RefCounted
class_name Layers
## Shared collision bitmasks. Everything uses plain Area2D overlap
## detection (no rigid-body physics) - the "attacker" side sets
## monitoring=true with a mask covering its targets, the "target" side
## just needs monitorable=true on the matching layer.

const PLAYER := 1
const PLAYER_BULLET := 2
const PLAYER_BOMB := 4
const ENEMY_AIR := 8
const ENEMY_GROUND := 16
const ENEMY_SHOT := 32
const TERRAIN := 64
