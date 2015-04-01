;; Gameloop module, links the the various modules together.

.ifndef ::__PLAYER_H_
::__PLAYER_H_ = 1

.setcpu "65816"
.include "includes/import_export.inc"
.include "entity.h"

IMPORT_MODULE Player
	STRUCT	entity, EntityStruct
	UINT16	score
	ADDR	rotationIndex

	;; Initializes the player
	;; REQUIRE: DB access shadow RAM
	ROUTINE	Init

	;; Initializes a dummy player that is offscreen.
	ROUTINE	InitDummy
ENDMODULE

.endif ; __PLAYER_H_

; vim: ft=asm:

