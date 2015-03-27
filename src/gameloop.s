
.include "gameloop.h"
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"
.include "routines/block.h"
.include "routines/screen.h"
.include "routines/metasprite.h"
.include "entity.h"
.include "player.h"
.include "asteroid.h"
.include "missile.h"

MODULE GameLoop


.segment "SHADOW"
	UINT16	screenXpos
	UINT16	screenYpos

	UINT16	tmp
.code

.A8
.I16
ROUTINE Init
	PHB

	JSR	SetupScreen
	JSR	Entity__Init

	MetaSprite_Init

	REP	#$20
.A16
.I16
	; ::DEBUG projectile to test collisions::
	LDX	#(256 - 8) / 2
	LDY	#(224 - 8) / 2
	LDA	#.loword(Missile__InitData)
	JSR	Entity__CreateProjectile

	; ::DEBUG create many NPCs::
	LDA	#10 - 1
	STA	tmp

	REPEAT
		; ::DEBUG Check it doesn't crash::
		; ::CREATE a simple asteroid::
		LDA	tmp
		ASL
		ASL
		ASL
		ADD	tmp
		ASL
		ADC	#25
		TAY

		LDX	#0
		LDA	#.loword(Asteroid__InitData)
		JSR	Entity__CreateNpc

		DEC	tmp
	UNTIL_MINUS


	SEP	#$20
.A8
	PLB
	RTS



.A8
.I16
ROUTINE PlayGame
	REPEAT
		JSR	Screen__WaitFrame
		JSR	MetaSprite__InitLoop

LABEL GameLoop
		PHB
			LDA	#$7E
			PHA
			PLB

			REP	#$30
.A16
.I16
			Entity__Process Player__entity
			Entity__Render Player__entity, screenXpos, screenYpos
		PLB

		SEP	#$20
.A8
		JSR	MetaSprite__FinalizeLoop
	FOREVER

	RTS


.A8
.I16
ROUTINE SetupScreen
	LDA	#INIDISP_FORCE
	STA	INIDISP

	LDA	#GAMELOOP_SCREEN_MODE
	STA	BGMODE

	STZ	BG1HOFS
	STZ	BG1HOFS

	Screen_SetVramBaseAndSize GAMELOOP
	TransferToVramLocation	BlackSpriteTile, GAMELOOP_OAM_TILES

	; ::DEBUG 3 seperate palettes to show the sprites::
	LDA	#$8F + 0*16
	STA	CGADD
	LDA	#$25
	STA	CGDATA
	STA	CGDATA
	LDA	#$8F + 1*16
	STA	CGADD
	LDA	#$18
	STA	CGDATA
	STA	CGDATA
	LDA	#$8F + 2*16
	STA	CGADD
	LDA	#$34
	STA	CGDATA
	STA	CGDATA


	LDA	#TM_OBJ
	STA	TM

	RTS


.rodata
LABEL BlackSpriteTile
	.repeat 32
		.byte $FF
	.endrepeat

BlackSpriteTile_End:

ENDMODULE

