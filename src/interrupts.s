; Inturrupt Handlers

.include "includes/registers.inc"

.include "routines/block.h"
.include "routines/screen.h"
.include "routines/random.h"
.include "routines/metasprite.h"

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

	SEP #$20
.A8
.I16
	; Reset NMI Flag.
	LDA	RDNMI

	Screen_VBlank
	MetaSprite_VBlank

	JSR	Random__AddJoypadEntropy
	JSR	Controler__Update

	; Load State
	REP	#$30
	PLY
	PLX
	PLD
	PLB
	PLA
	
	RTI

