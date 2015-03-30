
.include "player.h"
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"
.include "routines/block.h"

.include "entity.h"
.include "physics.h"

MODULE Player

.rodata
LABEL	EntityFunctionsTable
	.addr	.loword(Process)
	.addr	.loword(Physics__ProcessEntity)


.segment "SHADOW"
	STRUCT	entity, EntityStruct

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


.A16
.I16
ROUTINE Process
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

InitData_End:

.include "tables/metasprite-ship.asm"



ENDMODULE

