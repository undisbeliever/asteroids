
.include "asteroid.h"
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"
.include "routines/random.h"
.include "routines/metasprite.h"

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
	WORD	_spawnSmallerAsteroidsAddr

.code


ROUTINE	SpawnLargeAsteroid
	; x = (Rnd(128) + (256 - 128 / 2) - LARGE_SIZE / 2) % 256
	; y = Rnd(224)
	; Entity__CreateNpc(LargeAsteroid_InitData, x, y)

	PHP

	REP	#$30
	SEP	#$20
.A8
.I16
	JSR	Random__Rnd

	LDXY	Random__Seed

	REP	#$30
.A16
	LDA	Random__Seed + 2
	AND	#$007F
	ADD	#256 - 128 / 2 - LARGE_SIZE / 2
	AND	#$00FF
	PHA

	SEP	#$20
.A8
	LDY	#224
	JSR	Random__Rnd_U16Y

	REP	#$30
.A16
	; Y from Random__Rnd_U16Y
	PLX
	LDA	#.loword(LargeAsteroid_InitData)
	JSR	Entity__CreateNpc

	PLP
	RTS


.A16
.I16
ROUTINE Init_Large
	LDY	#N_LARGE_ASTEROIDS
	LDX	#.loword(MetaSpriteFrameTable_LargeAsteroid)
	LDA	#LARGE_MAX_VELOCITY
	JMP	SetRandomFrameAndVelocity


.A16
.I16
ROUTINE Init_Medium
	LDY	#N_MEDIUM_ASTEROIDS
	LDX	#.loword(MetaSpriteFrameTable_MediumAsteroid)
	LDA	#MEDIUM_MAX_VELOCITY
	JMP	SetRandomFrameAndVelocity


.A16
.I16
ROUTINE Init_Small
	LDY	#N_SMALL_ASTEROIDS
	LDX	#.loword(MetaSpriteFrameTable_SmallAsteroid)
	LDA	#SMALL_MAX_VELOCITY
	JMP	SetRandomFrameAndVelocity


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
	STA	_spawnSmallerAsteroidsAddr

	.repeat 3
		PHD
			LDX	z:EntityStruct::xPos + 1
			LDY	z:EntityStruct::yPos + 1
			LDA	_spawnSmallerAsteroidsAddr
			JSR	Entity__CreateNpc
		PLD
	.endrepeat

	RTS


;; IN:
;;	A - max velocity per dimension
;;	X - MetaSpriteFrameTable
;;	Y - Number of MetaSprite Frames
;;	dp - Asteroid EntityStruct
.A16
.I16
ROUTINE SetRandomFrameAndVelocity
	; tmp = A
	; Y = Rnd(Y) * 2
	; dp->metaSpriteFrame = MetaSpriteLayoutBank[y + x]
	; dp->xVecl = Rnd(tmp * 2) - tmp
	; dp->yVecl = Rnd(tmp * 2) - tmp

	STA	tmp
	STX	tmp2

	SEP	#$20
.A8
	JSR	Random__Rnd_U16Y
	REP	#$20
.A16

	TYA
	ASL
	ADD	tmp2
	TAX
	LDA	f:MetaSpriteLayoutBank << 16, X
	STA	z:EntityStruct::metaSpriteFrame


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

	RTS


.segment "BANK1"

;; Asteroid initial data
LABEL LargeAsteroid_InitData
	.addr	0				; nextEntity - keep blank.
	.addr	.loword(LargeAsteroidFunctionsTable)

	.byte	$00, $00, $00			; xPos
	.byte	$00, $00, $00			; yPos

	.word	$0000				; xVecl
	.word	$0000				; yVecl

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

	.word	$0000				; xVecl
	.word	$0000				; yVecl

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

	.word	$0000				; xVecl
	.word	$0000				; yVecl

	.word	SMALL_SIZE			; width
	.word	SMALL_SIZE			; height

	.addr	MetaSprite_SmallAsteroid_0	; metaSpriteFrame
	.word	0				; charAttr


	.include "tables/metasprite-asteroid.asm"

ENDMODULE

