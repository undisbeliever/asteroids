
.include "gameloop.h"
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"
.include "routines/block.h"
.include "routines/screen.h"
.include "routines/metasprite.h"
.include "routines/text.h"
.include "routines/text8x8.h"

.include "entity.h"
.include "player.h"
.include "asteroid.h"
.include "missile.h"
.include "controler.h"

MODULE GameLoop


.segment "SHADOW"
	UINT16	score
	WORD	asteroidsToSpawn
	WORD	playerStillAlive

	UINT16	tmp
.code

.A8
.I16
ROUTINE Init
	JSR	SetupScreen

	MetaSprite_Init

	Text_LoadFont FontTiles, GAMELOOP_BG3_TILES, GAMELOOP_BG3_MAP

	Text_SelectWindow 0
	Text_SetInterface Text8x8__SingleSpacingInterface, 0
	Text_SetupWindow 2, 2, 7, 2, Text__WINDOW_NO_BORDER
	Text_SetStringBasic

	Text_SelectWindow 1
	Text_SetInterface Text8x8__SingleSpacingInterface, 0
	Text_SetupWindow 10, 14, 22, 14, Text__WINDOW_NO_BORDER
	Text_SetStringBasic

	LDA	#2
	STA	asteroidsToSpawn
	STZ	asteroidsToSpawn + 1

	.assert * = SetupGameField, lderror, "Bad Flow"



;; Spawns the player and `asteroidsToSpawn` large asteroids.
.A8
.I16
ROUTINE SetupGameField
	REP	#$30
.A16
	JSR	Entity__Init

	LDA	asteroidsToSpawn
	CMP	#7
	IF_GE
		; The system experiences slowdown at 65 NPCs
		; Limit the number of asteroids in play.
		LDA	#7
	ENDIF

	REPEAT
		PHA
		JSR	Asteroid__SpawnLargeAsteroid
		PLA
		DEC
	UNTIL_ZERO

	JSR	Player__Init

	SEP	#$20
.A8
	RTS



.A8
.I16
ROUTINE PlayGame
	; asteroidsToSpawn = 2
	; score = 0
	; playerStillAlive = true
	; SetupGameField()
	;
	; Text__SelectWindow(0)
	;
	; repeat
	;	Screen__WaitFrame()
	;	ProcessFrame()
	;	Text__SetCursor(0, 0)
	;	Text__Print(score)
	;
	;	if Entity__firstActiveNpc == NULL
	;		asteroidsToSpawn++
	;		SetupGameField()
	; until playerStillAlive == false

	LDA	#2
	STA	asteroidsToSpawn
	STZ	asteroidsToSpawn + 1

	STZ	score

	LDA	#$FF
	STA	playerStillAlive

	JSR	SetupGameField

	Text_SelectWindow 0

	REPEAT
		JSR	Screen__WaitFrame
		JSR	ProcessFrame

		Text_SetCursor 0, 0
		Text_PrintDecimal score, 4

		LDX	Entity__firstActiveNpc
		IF_ZERO
			; run out of enemies, spawn more
			INC	asteroidsToSpawn
			JSR	SetupGameField
		ENDIF

		LDA	playerStillAlive
	UNTIL_ZERO

	RTS


.A8
.I16
ROUTINE AttractMode
	; Player__InitDummy()
	; Text__SelectWindow(1)
	; Text__Print("PRESS START")
	;
	; repeat
	;	Screen__WaitFrame()
	;	ProcessFrame()
	;
	; until Controler__pressed & JOY_START
	; Text__ClearWindow()

	JSR	Player__InitDummy

	Text_SelectWindow 1
	Text_PrintString "PRESS  START"

	REPEAT
		JSR	Screen__WaitFrame
		JSR	ProcessFrame

		LDA	Controler__pressed + 1
		AND	#JOYH_START
	UNTIL_NOT_ZERO

	JSR	Text__ClearWindow

	RTS



;; Processes a single frame of a game loop
.A8
.I16
ROUTINE	ProcessFrame
	JSR	MetaSprite__InitLoop

LABEL GameLoop
	REP	#$30
.A16
.I16
	Entity__Process Player__entity
	Entity__Render Player__entity, DrawEntity

	; Reset DP
	LDA	#0
	TCD

	SEP	#$20
.A8
	JMP	MetaSprite__FinalizeLoop



;; Draws an Entity on the screen
;; REQUIRES: 16 bit A, 16 bit Index, DB=$7E
;; INPUT: dp = EntityStruct
.A16
.I16
ROUTINE	DrawEntity
	; MetaSprite__ProcessMetaSprite_Y(dp->metaSpriteFrame, dp->metaSpriteCharAttr)

	LDA	z:EntityStruct::xPos + 1
	SUB	#SCREEN_WRAP_PADDING
	STA	MetaSprite__xPos

	LDA	z:EntityStruct::yPos + 1
	SUB	#SCREEN_WRAP_PADDING
	STA	MetaSprite__yPos

	; ::SHOULDDO use DB = MetaSpriteLayoutBank, saves (n_entities + 4*obj - 7) cycles::
	; ::: Will require MetaSpriteLayoutBank & $7F <= $3F::
	LDX	z:EntityStruct::metaSpriteFrame
	LDY	z:EntityStruct::metaSpriteCharAttr

	SEP	#$20
	JSR	MetaSprite__ProcessMetaSprite_Y
	REP	#$30

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

	Screen_SetVramBaseAndSize	GAMELOOP

	TransferToVramLocation	FontTiles,	GAMELOOP_BG3_TILES
	TransferToCgramLocation	FontPalette,	2 * 8 * 4

	TransferToVramLocation	ObjectTiles,	GAMELOOP_OAM_TILES
	TransferToCgramLocation	ObjectPalette,	128

	LDA	#TM_BG3 | TM_OBJ
	STA	TM

	RTS


.rodata

.segment "BANK2"
ObjectTiles:
	.incbin	"resources/tiles4bpp/ship.4bpp"
	.incbin	"resources/tiles4bpp/asteroids.4bpp"
	.incbin	"resources/tiles4bpp/missile.4bpp"
ObjectTiles_End:

ObjectPalette:
	.incbin	"resources/tiles4bpp/ship.clr"
	.incbin	"resources/tiles4bpp/asteroids.clr"
	.incbin	"resources/tiles4bpp/missile.clr"
ObjectPalette_End:

FontTiles:
	.incbin	"resources/tiles2bpp/font8x8-bold-transparent.2bpp"
FontTiles_End:

FontPalette:
	.word	$0000, $7FFF, $6b3a, $4e73
FontPalette_End:

ENDMODULE

