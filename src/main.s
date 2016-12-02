; Initialisation code

.include "includes/import_export.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"
.include "routines/random.h"
.include "routines/screen.h"
.include "gameloop.h"


;; Initialisation Routine
ROUTINE Main
	REP	#$10
	SEP	#$20
.A8
.I16

	LDA	#NMITIMEN_VBLANK_FLAG | NMITIMEN_AUTOJOY_FLAG
	STA	NMITIMEN

	LDXY	#$C97B39A8		; source: random.org
	STXY	Random__seed

	LDA	#MEMSEL_FASTROM
	STA	MEMSEL

	JSR	GameLoop__Init

	LDA	#$0F
	STA	INIDISP

	REPEAT
		JSR	GameLoop__AttractMode

		JSR	GameLoop__PlayGame
	FOREVER


.segment "COPYRIGHT"
		;1234567890123456789012345678901
	.byte	"Asteroids for SNES             ", 10
	.byte	"(c) 2015, The Undisbeliever    ", 10
	.byte	"MIT Licensed                   ", 10
	.byte	"One Game Per Month Challange   ", 10

