;; Ship Meta-sprites

SHIP_TILE_OFFSET = 0
SHIP_PALETTE = 0
SHIP_SIZE = 10

SHIP_OFFSET = (SHIP_SIZE - 16) / 2
N_SHIP_FRAMES = 64

	.macro _ShipMetaSpriteLayout name, startTile
		.local tile

		.repeat 2, hvflip
			.repeat 4, row
				.repeat 8, column
			.ident(.sprintf("MetaSprite_%s_%d", name, hvflip * 32 + row * 8 + column)):
					tile .set startTile + row * 32 + column * 2

					.byte	1

					.byte	.lobyte(SHIP_OFFSET)
					.byte	.lobyte(SHIP_OFFSET)
					.if hvflip = 1
						.word	(tile & $1FF) | (SHIP_PALETTE << OAM_CHARATTR_PALETTE_SHIFT) | OAM_CHARATTR_H_FLIP_FLAG | OAM_CHARATTR_V_FLIP_FLAG
					.else
						.word	(tile & $1FF) | (SHIP_PALETTE << OAM_CHARATTR_PALETTE_SHIFT)
					.endif
					.byte	$FF
				.endrepeat
			.endrepeat
		.endrepeat
	.endmacro

	_ShipMetaSpriteLayout "Ship", SHIP_TILE_OFFSET
	_ShipMetaSpriteLayout "ShipThrust", SHIP_TILE_OFFSET + 128


; FrameTable
LABEL MetaSpriteFrameTable_Ship
	.repeat N_SHIP_FRAMES, i
		.addr .ident(.sprintf("MetaSprite_Ship_%d", i))
	.endrepeat

LABEL MetaSpriteFrameTable_ShipThrust
	.repeat N_SHIP_FRAMES, i
		.addr .ident(.sprintf("MetaSprite_ShipThrust_%d", i))
	.endrepeat

; EntitySize data
LABEL Ship_Size
	.word	SHIP_SIZE
	.word	SHIP_SIZE
	.byte	SHIP_SIZE / 8
	.byte	SHIP_SIZE / 8

; vim: ft=asm:

