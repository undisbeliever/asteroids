;; Gameloop module, links the the various modules together.

.ifndef ::__ASTEROID_H_
::__ASTEROID_H_ = 1

.setcpu "65816"
.include "includes/import_export.inc"

IMPORT_MODULE Asteroid

	LABEL InitData

ENDMODULE

.endif ; __ASTEROID_H_

; vim: ft=asm:

