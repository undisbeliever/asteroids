;; Gameloop module, links the the various modules together.

.ifndef ::__PLAYER_H_
::__PLAYER_H_ = 1

.setcpu "65816"
.include "includes/import_export.inc"
.include "entity.h"

IMPORT_MODULE Player
	STRUCT	entity, EntityStruct

	;; Initializes the player
	;; REQUIRE: DB access shadow RAM
	ROUTINE	Init
ENDMODULE

.endif ; __PLAYER_H_

; vim: ft=asm:

