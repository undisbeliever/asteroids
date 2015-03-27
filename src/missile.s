
.include "missile.h"
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"
.include "routines/metasprite.h"

.include "entity.h"

MODULE Missile

.rodata
LABEL	EntityFunctionsTable
	.addr	.loword(Init)
	.addr	.loword(Process)
	.addr	.loword(CollisionNpc)
	.addr	.loword(CollisionPlayer)
	.addr	.loword(Finalize)


.code

.A16
.I16
ROUTINE Init
	RTS


.A16
.I16
ROUTINE Process
	RTS


.A16
.I16
ROUTINE CollisionNpc
	; ::DEBUG collision test - set NPC palette to 2::
	LDA	#2 << OAM_CHARATTR_PALETTE_SHIFT
	STA	z:EntityStruct::metaSpriteCharAttr

	RTS

.A16
.I16
ROUTINE CollisionPlayer
ROUTINE Finalize
	RTS




.segment "BANK1"

InitProjectileBank 	= .bankbyte(*)		; ::DEBUG::


;; Missile initial data
LABEL InitData
	.addr	0				; nextEntity - keep blank.
	.addr	.loword(EntityFunctionsTable)

	.byte	$00, $00, $00			; xPos
	.byte	$00, $00, $00			; yPos

	.word	$00				; xVecl
	.word	$00				; yVecl

	.addr	Missile_Size_1			; sizePtr

	.addr	Missile_MetaSpriteFrame		; metaSpriteFrame
	.word	0				; charAttr


;; Missile size data
Missile_Size_1:
	.word	8				; width
	.word	8				; height
	.byte	1				; tileWidth 
	.byte	1				; tileHeight


; ::DEBUG Simple metasprite::
Missile_MetaSpriteFrame:
	.byte	1

	.byte	0				; xPos
	.byte	0				; yPos
	.word	1 << OAM_CHARATTR_PALETTE_SHIFT	; charAttr
	.byte	0				; size


ENDMODULE

