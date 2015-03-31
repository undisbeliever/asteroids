.ifndef ::_TABLES_H_
::_TABLES_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"

IMPORT_MODULE Tables

	LABEL	Sine_Thrust
	LABEL	Sine_Missile

ENDMODULE

.endif ; ::_TABLES_H_

; vim: set ft=asm:

