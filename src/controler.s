
.include "controler.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

MODULE Controler

.segment "SHADOW"
	WORD	pressed
	WORD	current

	WORD	invertedPrevious

.code

.A8
.I16
ROUTINE Update
	; repeat
	; until HVJOY & HVJOY_AUTOJOY == 0
	;
	; current = JOY1
	; pressed = JOY1 & invertedPrevious
	; invertedPrevious = current ^ 0xFFFF

	LDA	#HVJOY_AUTOJOY
	REPEAT
		BIT	HVJOY
	UNTIL_ZERO

	REP	#$30
.A16
	LDA	JOY1
	STA	current
	AND	invertedPrevious
	STA	pressed

	LDA	current
	EOR	#$FFFF
	STA	invertedPrevious

	SEP	#$20
.A8
	RTS


ENDMODULE

