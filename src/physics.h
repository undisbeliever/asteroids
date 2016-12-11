
.ifndef ::__PHYSICS_H_
::__PHYSICS_H_ = 1

.setcpu "65816"
.include "includes/import_export.inc"


IMPORT_MODULE Physics
	;; Processes and Entities Physics
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT: dp = Entity
	ROUTINE ProcessEntity
ENDMODULE

.endif ; __PHYSICS_H_

; vim: ft=asm:

