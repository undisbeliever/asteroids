
.include "asteroid.h"
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"
.include "routines/metasprite.h"

.include "entity.h"
.include "physics.h"

MODULE Asteroid

.rodata
LABEL	EntityFunctionsTable
	.addr	.loword(Init)
	.addr	.loword(Process)
	.addr	.loword(Physics__ProcessEntity)
	.addr	.loword(CollisionPlayer)
	.addr	.loword(CollisionProjectile)


.code

.A16
.I16
ROUTINE Init
	RTS


.A16
.I16
ROUTINE Process
	LDA	z:EntityStruct::xPos + 1
	CMP	#26
	IF_EQ
		; ::DEBUG Check it doesn't crash::
		; Create a new simple asteroid
		LDA	#.loword(Asteroid__InitData)
		LDX	#0
		LDY	z:EntityStruct::yPos + 1
		JSR	Entity__CreateNpc
	ELSE
		CMP	#220
		IF_GE
			STZ	z:EntityStruct::functionsTable
		ENDIF
	ENDIF

	RTS


.A16
.I16
ROUTINE CollisionPlayer
ROUTINE CollisionProjectile
ROUTINE Finalize
	RTS




.segment "BANK1"

EntitySizeStructBank	= .bankbyte(*)		; ::DEBUG::
InitNpcBank 		= .bankbyte(*)		; ::DEBUG::
MetaSpriteLayoutBank	= .bankbyte(*)		; ::DEBUG::


;; Asteroid initial data
LABEL InitData
	.addr	0				; nextEntity - keep blank.
	.addr	.loword(EntityFunctionsTable)

	.byte	$00, $00, $00			; xPos
	.byte	$00, $00, $00			; yPos

	.word	.loword(256)			; xVecl
	.word	.loword(0)			; yVecl

	.addr	SmallAsteroid_Size		; sizePtr

	.addr	MetaSprite_SmallAsteroid_2	; metaSpriteFrame
	.word	0				; charAttr

.include "tables/metasprite-asteroid.asm"

ENDMODULE

