
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"
.include "routines/metasprite.h"

.include "entity.h"
.include "asteroid.h"

MODULE Asteroid

.rodata
LABEL	EntityFunctionsTable
	.addr	.loword(Init)
	.addr	.loword(Process)
	.addr	.loword(CollisionPlayer)
	.addr	.loword(CollisionProjectile)
	.addr	.loword(Finalize)


.code

.A16
.I16
ROUTINE Init
	RTS


.A16
.I16
ROUTINE Process
	;; ::DEBUG physics::
	LDA	z:EntityStruct::xPos + 1
	INC
	STA	z:EntityStruct::xPos + 1

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

	.word	$00				; xVecl
	.word	$00				; yVecl

	.addr	Asteroid_Size_1			; sizePtr

	.addr	Asteroid_MetaSpriteFrame	; metaSpriteFrame
	.word	0				; charAttr


;; Asteroid size data
Asteroid_Size_1:
	.word	8				; width
	.word	8				; height
	.byte	1				; tileWidth 
	.byte	1				; tileHeight


; ::DEBUG Simple metasprite::
Asteroid_MetaSpriteFrame:
	.byte	1

	.byte	0	; xPos
	.byte	0	; yPos
	.word	0	; charAttr
	.byte	0	; size


ENDMODULE

