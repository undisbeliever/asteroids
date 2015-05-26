;; Ship Meta-sprites

ASTEROID_TILE_OFFSET = 256
ASTEROID_PALETTE = 1

; Collision size
LARGE_SIZE = 28
MEDIUM_SIZE = 12
SMALL_SIZE = 6

LARGE_OFFSET = (LARGE_SIZE - 32) / 2
MEDIUM_OFFSET = (MEDIUM_SIZE - 16) / 2
SMALL_OFFSET = (SMALL_SIZE - 16) / 2 


.macro MetaSpriteObject xOffset, yOffset, tile, objSize
	.byte	.lobyte(xOffset)
	.byte	.lobyte(yOffset)
	.word	((tile + ASTEROID_TILE_OFFSET) & $1FF) | (ASTEROID_PALETTE << OAM_CHARATTR_PALETTE_SHIFT)
	.if objSize = 0
		.byte	$00
	.else
		.byte	$FF
	.endif
.endmacro

.macro _LargeAsteroidMetaSprite startTile
	.byte	4
	MetaSpriteObject LARGE_OFFSET + 0 , LARGE_OFFSET + 0 , startTile + 0 , 1
	MetaSpriteObject LARGE_OFFSET + 16, LARGE_OFFSET + 0 , startTile + 2 , 1
	MetaSpriteObject LARGE_OFFSET + 0 , LARGE_OFFSET + 16, startTile + 32, 1
	MetaSpriteObject LARGE_OFFSET + 16, LARGE_OFFSET + 16, startTile + 34, 1
.endmacro

.macro _MediumAsteroidMetaSprite startTile
	.byte	1
	MetaSpriteObject MEDIUM_OFFSET, MEDIUM_OFFSET, startTile, 1
.endmacro

.macro _SmallAsteroidMetaSprite startTile
	.byte	1
	MetaSpriteObject SMALL_OFFSET, SMALL_OFFSET, startTile, 0
.endmacro

; Large
.repeat 4, l
.ident(.sprintf("MetaSprite_LargeAsteroid_%d", l)):
	_LargeAsteroidMetaSprite 4 * l
.endrepeat

; Medium
.repeat 2, row
	.repeat 6, column
.ident(.sprintf("MetaSprite_MediumAsteroid_%d", row * 6 + column)):
		_MediumAsteroidMetaSprite (2 + row) * 32 + column * 2
	.endrepeat
.endrepeat

; Small
.repeat 4, row
	.repeat 4, column
.ident(.sprintf("MetaSprite_SmallAsteroid_%d", row * 4 + column)):
		_SmallAsteroidMetaSprite (4 + row) * 16 + column + 12
	.endrepeat
.endrepeat


; Metasprite layout addresses
LABEL MetaSpriteFrameTable_LargeAsteroid
	.repeat 4, i
		.addr .ident(.sprintf("MetaSprite_LargeAsteroid_%d", i))
	.endrepeat

LABEL MetaSpriteFrameTable_MediumAsteroid
	.repeat 12, i
		.addr .ident(.sprintf("MetaSprite_MediumAsteroid_%d", i))
	.endrepeat

LABEL MetaSpriteFrameTable_SmallAsteroid
	.repeat 16, i
		.addr .ident(.sprintf("MetaSprite_SmallAsteroid_%d", i))
	.endrepeat

N_LARGE_ASTEROIDS = 4
N_MEDIUM_ASTEROIDS = 12
N_SMALL_ASTEROIDS = 16


; vim: ft=asm:

