
.include "missile.h"
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"

.include "entity.h"
.include "player.h"
.include "physics.h"
.include "tables.h"

MODULE Missile

MISSILE_FRAMES = 60	; 1.0 seconds

.rodata
LABEL	EntityFunctionsTable
	.addr	.loword(Init)
	.addr	.loword(Process)
	.addr	.loword(Physics__ProcessEntity)
	.addr	.loword(CollisionNpc)


.struct MissileStruct
	entity	.tag EntityStruct

	timeout	.word
.endstruct

.assert .sizeof(MissileStruct) <= PROJECTILE_ENTITY_MALLOC, error, "PROJECTILE_ENTITY_MALLOC too small"


.code

.A16
.I16
ROUTINE Init
	; entity->metaspriteFrame = MetaSpriteFrameTable_Missile[player.rotationIndex]
	; entity->xVecl = Tables__Sine_Missile[player.rotationIndex]
	; entity->yVecl = Tables__Sine_Missile[player.rotationIndex - 90deg]

	LDX	Player__rotationIndex

	LDA	f:MetaSpriteFrameTable_Missile, X
	STA	z:EntityStruct::metaSpriteFrame

	LDA	f:Tables__Sine_Missile, X
	ADD	Player__entity + EntityStruct::xVecl
	STA	z:EntityStruct::xVecl

	TXA
	SUB	#16 * 2		; 90 degrees
	AND	#$007E		; modulus 128
	TAX

	LDA	f:Tables__Sine_Missile, X
	ADD	Player__entity + EntityStruct::yVecl
	STA	z:EntityStruct::yVecl

	RTS


.A16
.I16
ROUTINE Process
	DEC	z:MissileStruct::timeout
	IF_ZERO
		STZ	z:EntityStruct::functionsTable
	ENDIF

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

	.word	MISSILE_FRAMES			; timeout


	.include "tables/metasprite-missile.asm"

ENDMODULE

