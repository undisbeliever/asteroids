
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

MODULE GameLoop


.segment "SHADOW"
	UINT16	score

	UINT16	tmp
.code

.A8
.I16
ROUTINE Init
	STZ	score

	JSR	SetupScreen
	JSR	Entity__Init

	MetaSprite_Init

	Text_LoadFont FontTiles, GAMELOOP_BG3_TILES, GAMELOOP_BG3_MAP
	Text_SetInterface Text8x8__SingleSpacingInterface, 0
	Text_SetupWindow 2, 2, 7, 3, Text__WINDOW_NO_BORDER
	Text_SetStringBasic

	REP	#$20
.A16
.I16
	JSR	Player__Init
	JSR	Asteroid__SpawnLargeAsteroid
	JSR	Asteroid__SpawnLargeAsteroid

	SEP	#$20
.A8
	RTS



.A8
.I16
ROUTINE PlayGame
	REPEAT
		JSR	Screen__WaitFrame
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
		Text_SetCursor 0, 0
		Text_PrintDecimal score, 4

		JSR	MetaSprite__FinalizeLoop
	FOREVER

	RTS



;; Draws an Entity on the screen
;; REQUIRES: 16 bit A, 16 bit Index, DB=$7E
;; INPUT: dp = EntityStruct
.A16
.I16
ROUTINE	DrawEntity
	; MetaSprite__ProcessMetaSprite_Y(dp->metaSpriteFrame, dp->metaSpriteCharAttr)

	LDA	z:EntityStruct::xPos + 1
	STA	MetaSprite__xPos

	LDA	z:EntityStruct::yPos + 1
	STA	MetaSprite__yPos

	; ::TODO check if outside screen region::

	; ::SHOULD replace with macro (xPos, yPos, frame, charattr are paraeters::
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
	.incbin	"resources/ship.4bpp"
	.incbin	"resources/asteroids.4bpp"
	.incbin	"resources/missile.4bpp"
ObjectTiles_End:

ObjectPalette:
	.incbin	"resources/ship.clr"
	.incbin	"resources/asteroids.clr"
	.incbin	"resources/missile.clr"
ObjectPalette_End:

FontTiles:
	.incbin	"snesdev-common/resources/font8x8-bold-transparent.2bpp"
FontTiles_End:

FontPalette:
	.word	$0000, $7FFF, $6b3a, $4e73
FontPalette_End:

ENDMODULE

