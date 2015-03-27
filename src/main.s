; Initialisation code

.define VERSION 1
.define REGION NTSC
.define ROM_NAME "ASTEROIDS"

.include "includes/sfc_header.inc"
.include "includes/import_export.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"
.include "routines/screen.h"
.include "gameloop.h"


;; Initialisation Routine
ROUTINE Main
	REP	#$10
	SEP	#$20
.A8
.I16

	; ::TODO Setup Sound Engine::

	LDA	#NMITIMEN_VBLANK_FLAG | NMITIMEN_AUTOJOY_FLAG
	STA	NMITIMEN

	JSR	GameLoop__Init

	LDA	#$0F
	STA	INIDISP

	JSR	GameLoop__PlayGame




.segment "COPYRIGHT"
		;1234567890123456789012345678901
	.byte	"Asteroids for SNES             ", 10
	.byte	"(c) 2015, The Undisbeliever    ", 10
	.byte	"MIT Licensed                   ", 10
	.byte	"One Game Per Month Challange   ", 10
