;; Gameloop module, links the the various modules together.

.ifndef ::__MISSILE_H_
::__MISSILE_H_ = 1

.setcpu "65816"
.include "includes/import_export.inc"

IMPORT_MODULE Missile

	LABEL InitData

ENDMODULE

.endif ; __MISSILE_H_

; vim: ft=asm:

