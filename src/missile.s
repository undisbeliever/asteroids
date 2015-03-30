
.include "missile.h"
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"
.include "routines/metasprite.h"

.include "entity.h"
.include "physics.h"

MODULE Missile

.rodata
LABEL	EntityFunctionsTable
	.addr	.loword(Init)
	.addr	.loword(Process)
	.addr	.loword(Physics__ProcessEntity)
	.addr	.loword(CollisionNpc)
	.addr	.loword(CollisionPlayer)


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
	LDA	#1 << OAM_CHARATTR_PALETTE_SHIFT
	STA	z:EntityStruct::metaSpriteCharAttr

	RTS

.A16
.I16
ROUTINE CollisionPlayer
	RTS




.segment "BANK1"

InitProjectileBank 	= .bankbyte(*)		; ::DEBUG::


;; Missile initial data
LABEL InitData
	.addr	0				; nextEntity - keep blank.
	.addr	.loword(EntityFunctionsTable)

	.byte	$00, $00, $00			; xPos
	.byte	$00, $00, $00			; yPos

	.word	.loword(100)			; xVecl
	.word	.loword(-100)			; yVecl

	.word	MISSILE_SIZE			; width
	.word	MISSILE_SIZE			; height

	.addr	MetaSprite_Missile_8		; metaSpriteFrame
	.word	0				; charAttr

.include "tables/metasprite-missile.asm"


ENDMODULE

