
.include "asteroid.h"
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"
.include "routines/random.h"

.include "entity.h"
.include "physics.h"
.include "player.h"

MODULE Asteroid

;; Maximum velocity in a single dimension (used for init)
;; 1:7:8 fixed point integer
LARGE_MAX_VELOCITY  = $0080	; 0.50
MEDIUM_MAX_VELOCITY = $00C0	; 0.75
SMALL_MAX_VELOCITY  = $00C0	; 0.75


.rodata
LABEL	LargeAsteroidFunctionsTable
	.addr	.loword(Init_Large)
	.addr	.loword(Process)
	.addr	.loword(Physics__ProcessEntity)
	.addr	.loword(CollisionPlayer)
	.addr	.loword(CollisionProjectile)

LABEL	MediumAsteroidFunctionsTable
	.addr	.loword(Init_Medium)
	.addr	.loword(Process)
	.addr	.loword(Physics__ProcessEntity)
	.addr	.loword(CollisionPlayer)
	.addr	.loword(CollisionProjectile)

LABEL	SmallAsteroidFunctionsTable
	.addr	.loword(Init_Small)
	.addr	.loword(Process)
	.addr	.loword(Physics__ProcessEntity)
	.addr	.loword(CollisionPlayer)
	.addr	.loword(CollisionProjectile)


.segment "SHADOW"
	WORD	tmp
	WORD	tmp2

.code

.A16
.I16
ROUTINE Init_Large
	LDA	#LARGE_MAX_VELOCITY
	JMP	SetRandomVelocity


.A16
.I16
ROUTINE Init_Medium
	LDA	#MEDIUM_MAX_VELOCITY
	JMP	SetRandomVelocity


.A16
.I16
ROUTINE Init_Small
	LDA	#SMALL_MAX_VELOCITY
	JMP	SetRandomVelocity


.A16
.I16
ROUTINE Process
	RTS


.A16
.I16
ROUTINE CollisionPlayer
	; ::DEBUG notification::
	REPEAT
	FOREVER

	BRA	DestroyAsteroidWithShip



; y = missile EntityStruct
; dp = Asteroid EntityStruct
.A16
.I16
ROUTINE CollisionProjectile
	; Remove missile
	LDA	#0
	STA	a:EntityStruct::functionsTable, Y

	; ::TODO increase score::

DestroyAsteroidWithShip:

	; ::SOUND explosion::

	LDA	z:EntityStruct::width
	CMP	#LARGE_SIZE
	IF_EQ
		; Move spawn point to center of asteroid
		LDA	z:EntityStruct::xPos + 1
		ADD	#LARGE_SIZE / 2
		STA	z:EntityStruct::xPos + 1

		LDA	z:EntityStruct::yPos + 1
		ADD	#LARGE_SIZE / 2
		STA	z:EntityStruct::yPos + 1

		LDA	#.loword(MediumAsteroid_InitData)
		JSR	SpawnSmallerAsteroids
	ELSE
		CMP	#MEDIUM_SIZE
		IF_EQ
			; Move spawn point to center of asteroid
			LDA	z:EntityStruct::xPos + 1
			ADD	#MEDIUM_SIZE / 2
			STA	z:EntityStruct::xPos + 1

			LDA	z:EntityStruct::yPos + 1
			ADD	#MEDIUM_SIZE / 2
			STA	z:EntityStruct::yPos + 1

			LDA	#.loword(SmallAsteroid_InitData)
			JSR	SpawnSmallerAsteroids
		ENDIF
	ENDIF

	STZ	z:EntityStruct::functionsTable

	RTS


; dp = Asteroid EntityStruct
.A16
.I16
ROUTINE SpawnSmallerAsteroids
	STA	tmp2

	.repeat 3
		PHD
			LDX	z:EntityStruct::xPos + 1
			LDY	z:EntityStruct::yPos + 1
			LDA	tmp2
			JSR	Entity__CreateNpc
		PLD
	.endrepeat

	RTS


.A16
.I16
ROUTINE SetRandomVelocity
	STA	tmp

	PHB

	; ::SHOULDDO modify math module to use DP to access MUL/DIV registers::
	PHK
	PLB

	LDA	tmp
	ASL
	TAY

	SEP	#$20
.A8
	PHY
	JSR	Random__Rnd_U16Y

	REP	#$20
.A16

	TYA
	SUB	tmp
	STA	z:EntityStruct::xVecl


	SEP	#$20
.A8

	PLY
	JSR	Random__Rnd_U16Y

	REP	#$20
.A16

	TYA
	SUB	tmp
	STA	z:EntityStruct::yVecl

	PLB
	RTS


.segment "BANK1"

;; Asteroid initial data
LABEL InitData
LABEL LargeAsteroid_InitData
	.addr	0				; nextEntity - keep blank.
	.addr	.loword(LargeAsteroidFunctionsTable)

	.byte	$00, $00, $00			; xPos
	.byte	$00, $00, $00			; yPos

	.word	.loword(0)			; xVecl
	.word	.loword(0)			; yVecl

	.word	LARGE_SIZE			; width
	.word	LARGE_SIZE			; height

	.addr	MetaSprite_LargeAsteroid_0	; metaSpriteFrame
	.word	0				; charAttr


;; Asteroid initial data
LABEL MediumAsteroid_InitData
	.addr	0				; nextEntity - keep blank.
	.addr	.loword(MediumAsteroidFunctionsTable)

	.byte	$00, $00, $00			; xPos
	.byte	$00, $00, $00			; yPos

	.word	.loword(256)			; xVecl
	.word	.loword(0)			; yVecl

	.word	MEDIUM_SIZE			; width
	.word	MEDIUM_SIZE			; height

	.addr	MetaSprite_MediumAsteroid_0	; metaSpriteFrame
	.word	0				; charAttr



;; Asteroid initial data
LABEL SmallAsteroid_InitData
	.addr	0				; nextEntity - keep blank.
	.addr	.loword(SmallAsteroidFunctionsTable)

	.byte	$00, $00, $00			; xPos
	.byte	$00, $00, $00			; yPos

	.word	.loword(256)			; xVecl
	.word	.loword(0)			; yVecl

	.word	SMALL_SIZE			; width
	.word	SMALL_SIZE			; height

	.addr	MetaSprite_SmallAsteroid_0	; metaSpriteFrame
	.word	0				; charAttr


	.include "tables/metasprite-asteroid.asm"

ENDMODULE

