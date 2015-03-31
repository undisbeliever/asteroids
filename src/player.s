
.include "player.h"
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"
.include "routines/block.h"
.include "routines/math.h"

.include "entity.h"
.include "missile.h"
.include "physics.h"
.include "tables.h"
.include "controler.h"

RATE_OF_FIRE = 5

;; Maximum velocity before "relativity" sets in
;; 1:7:8 fractional
MAX_VELOCITY = $01C0		; 1.75

;; Relativity factor.
;; 1:7:8 fractional
MAX_VELOCITY_RELATIVITY = $00F3	; 0.95

MODULE Player

.rodata
LABEL	EntityFunctionsTable
	.addr	.loword(Process)
	.addr	.loword(Physics__ProcessEntity)


.segment "SHADOW"
PlayerData:
	STRUCT	entity, EntityStruct

	UINT16	missileTimeout
	UINT16	score
	ADDR	rotationIndex

PlayerData_End:

	WORD	tmp

.code



ROUTINE	Init
	PHP
	REP	#$30
	SEP	#$20
.A8
.I16
	MemCopy	InitData, entity

	PLP
	RTS


; dp = Entity
.A16
.I16
ROUTINE Process
	; if Controler__current & CONTROLS_ROTATE_CW
	;	rotationIndex = (rotationIndex + 2) % 128
	; else if Controler__current & CONTROLS_ROTATE_CC
	;	rotationIndex = (rotationIndex + 2) % 128
	;
	; if Controler__current & CONTROLS_THRUST
	;	entity->xVecl += Sine[rotationIndex]
	;	entity->yVecl += Sine[(rotationIndex - 90deg) % 128]
	;
	;	entity->metasprite = MetaSpriteFrameTable_ShipThrust[rotationIndex]
	; else
	;	entity->metasprite = MetaSpriteFrameTable_Ship[rotationIndex]
	;
	; 
	; if entity->xVecl * entity->xVecl + entity->yVecl * entity->yVecl >= MAX_VELOCITY * 2
	;	entity->xVecl *= MAX_VELOCITY_RELATIVITY
	;	entity->yVecl *= MAX_VELOCITY_RELATIVITY
	;
	; if missileTimout == 0
	; 	missileTimeout = RATE_OF_FIRE
	;	if Controler__current & CONTROLS_FIRE
	;		Entity__CreateProjectile(
	;			Missile
	;			entity->xPos + SHIP_SIZE / 2,
	;			entity->yPos + SHIP_SIZE / 2
	;		)
	; else
	;	missileTimeout--

	.assert N_SHIP_FRAMES = 64, error, "Invalid N_ROTATIONS"

	LDA	Controler__current
	IF_BIT	#CONTROLS_ROTATE_CW
		LDA	rotationIndex
		INC
		INC
		AND	#$007F		; modulus 128
		STA	rotationIndex
	ELSE_BIT #CONTROLS_ROTATE_CC
		LDA	rotationIndex
		DEC
		DEC
		AND	#$007F		; modulus 128
		STA	rotationIndex
	ENDIF

	LDA	Controler__current
	IF_BIT	#CONTROLS_THRUST
		LDX	rotationIndex

		LDA	z:EntityStruct::xVecl
		ADD	f:Tables__Sine_Thrust, X
		STA	z:EntityStruct::xVecl

		TXA
		ADD	#16 * 2		; 90 degrees
		AND	#$007E		; modulus 128
		TAX

		LDA	z:EntityStruct::yVecl
		SUB	f:Tables__Sine_Thrust, X
		STA	z:EntityStruct::yVecl

		LDX	rotationIndex
		LDA	f:MetaSpriteFrameTable_ShipThrust, X
		STA	z:EntityStruct::metaSpriteFrame
	ELSE
		LDX	rotationIndex
		LDA	f:MetaSpriteFrameTable_Ship, X
		STA	z:EntityStruct::metaSpriteFrame
	ENDIF

	; Limit Velocity
	; ::SHOULDDO modify math module to use DP to access MUL/DIV registers::
	; ::SHOULDDO add fractional integer functions to math module::
	PHB
	PHK
	PLB

	SEP	#$20
.A8

	LDX	z:EntityStruct::xVecl
	TXY
	JSR	Math__Multiply_S16Y_S16X_S32XY
	LDY	Math__product32 + 1
	STY	tmp

	LDX	z:EntityStruct::yVecl
	TXY
	JSR	Math__Multiply_S16Y_S16X_S32XY

	REP	#$20
.A16

	LDA	Math__product32 + 1
	ADD	tmp
	CMP	#MAX_VELOCITY * MAX_VELOCITY / 256
	IF_GE
		SEP	#$20
.A8

		LDY	z:EntityStruct::xVecl
		LDX	#MAX_VELOCITY_RELATIVITY
		JSR	Math__Multiply_S16Y_S16X_S32XY
		LDY	Math__product32 + 1
		STY	z:EntityStruct::xVecl

		LDY	z:EntityStruct::yVecl
		LDX	#MAX_VELOCITY_RELATIVITY
		JSR	Math__Multiply_S16Y_S16X_S32XY
		LDY	Math__product32 + 1
		STY	z:EntityStruct::yVecl

		REP	#$20
.A16
	ENDIF

	PLB

	LDA	missileTimeout
	IF_ZERO
		LDA	Controler__current
		IF_BIT	#CONTROLS_FIRE
			LDA	#RATE_OF_FIRE
			STA	missileTimeout

			PHD

			LDA	z:EntityStruct::xPos + 1
			ADD	#SHIP_SIZE / 2
			TAX
			LDA	z:EntityStruct::yPos + 1
			ADD	#SHIP_SIZE / 2
			TAY
			LDA	#.loword(Missile__InitData)
			JSR	Entity__CreateProjectile

			PLD
		ENDIF
	ELSE
		DEC	missileTimeout
	ENDIF

	RTS


.segment "BANK1"


;; Player initial data
LABEL InitData
	.addr	0				; nextEntity - keep blank.
	.addr	.loword(EntityFunctionsTable)

	.byte	$00
	.word	(256 - SHIP_SIZE) / 2		; xPos
	.byte	$00
	.word	(224 - SHIP_SIZE) / 2		; yPos

	.word	0				; xVecl
	.word	0				; yVecl

	.word	SHIP_SIZE			; width
	.word	SHIP_SIZE			; height

	.addr	MetaSprite_Ship_0		; metaSpriteFrame
	.word	0				; charAttr

	;; Extra Variables
	.word	0				; missileTimeout
	.word	0				; score
	.addr	0				; rotationIndex

InitData_End:

.assert (InitData_End - InitData) = (PlayerData_End - PlayerData), error, "Invalid InitData size"



	.include "tables/metasprite-ship.asm"
ENDMODULE

