
.ifndef ::_CONTROLER_H_
::_CONTROLER_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

CONTROLS_ROTATE_CW	= JOY_R | JOY_RIGHT
CONTROLS_ROTATE_CC	= JOY_L | JOY_LEFT
CONTROLS_THRUST		= JOY_B | JOY_A | JOY_UP
CONTROLS_FIRE		= JOY_Y | JOY_X


IMPORT_MODULE Controler
	;; New buttons pressed on current frame.
	WORD	pressed

	;; The state of the current frame
	WORD	current

	;; Updates the control variables
	;; REQUIRE: 8 bit A, 16 bit Index, DB access registers, AUTOJOY enabled
	ROUTINE Update

ENDMODULE

.endif ; ::_CONTROLER_H_

; vim: set ft=asm:

