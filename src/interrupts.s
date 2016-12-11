; Inturrupt Handlers

.include "includes/registers.inc"

.include "routines/block.h"
.include "routines/screen.h"
.include "routines/random.h"
.include "routines/metasprite.h"
.include "routines/text.h"

.include "controler.h"

;; Blank Handlers
ROUTINE IrqHandler
	RTI

ROUTINE CopHandler
	RTI

ROUTINE VBlank
	; Save state
	REP #$30
	PHA
	PHB
	PHD
	PHX
	PHY

	PHK
	PLB

	SEP #$20
.A8
.I16
	; Reset NMI Flag.
	LDA	RDNMI

	Screen_VBlank
	MetaSprite_VBlank
	Text_VBlank

	JSR	Controler__Update

	; Load State
	REP	#$30
	PLY
	PLX
	PLD
	PLB
	PLA

	RTI

