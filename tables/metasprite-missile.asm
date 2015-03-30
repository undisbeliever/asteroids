;; Ship Meta-sprites

MISSILE_TILE_OFFSET = 256 + 8 * 16
MISSILE_PALETTE = 2
MISSILE_SIZE = 4

MISSILE_OFFSET = (MISSILE_SIZE - 8) / 2
N_MISSILE_FRAMES = 64

	.macro _MissileMetaSpriteLayout
		.local tile

		.repeat 2, hvflip
			.repeat 2, row
				.repeat 16, column
			.ident(.sprintf("MetaSprite_Missile_%d", hvflip * 32 + row * 16 + column)):
					tile .set MISSILE_TILE_OFFSET + row * 16 + column

					.byte	1

					.byte	.lobyte(MISSILE_OFFSET)
					.byte	.lobyte(MISSILE_OFFSET)
					.if hvflip = 1
						.word	(tile & $1FF) | (MISSILE_PALETTE << OAM_CHARATTR_PALETTE_SHIFT) | OAM_CHARATTR_H_FLIP_FLAG | OAM_CHARATTR_V_FLIP_FLAG
					.else
						.word	(tile & $1FF) | (MISSILE_PALETTE << OAM_CHARATTR_PALETTE_SHIFT)
					.endif
					.byte	$00
				.endrepeat
			.endrepeat
		.endrepeat
	.endmacro

	_MissileMetaSpriteLayout


; FrameTable
LABEL MetaSpriteFrameTable_Missile
	.repeat N_MISSILE_FRAMES, i
		.addr .ident(.sprintf("MetaSprite_Missile_%d", i))
	.endrepeat


; EntitySize data
LABEL Missile_Size
	.word	MISSILE_SIZE
	.word	MISSILE_SIZE
	.byte	(MISSILE_SIZE + 8) / 8
	.byte	(MISSILE_SIZE + 8) / 8

; vim: ft=asm:

