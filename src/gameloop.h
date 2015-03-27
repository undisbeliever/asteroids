;; Gameloop module, links the the various modules together.

.ifndef ::__GAMELOOP_H_
::__GAMELOOP_H_ = 1

.setcpu "65816"
.include "includes/import_export.inc"
.include "includes/registers.inc"


;; VRAM Map
;; WORD ADDRESSES
GAMELOOP_SCREEN_MODE	= BGMODE_MODE1

GAMELOOP_BG1_MAP	= $0000
GAMELOOP_BG1_TILES	= $5000
GAMELOOP_OAM_TILES	= $6000

GAMELOOP_BG1_SIZE	= BGXSC_SIZE_32X32

GAMELOOP_OAM_SIZE	= OBSEL_SIZE_8_16
GAMELOOP_OAM_NAME	= 0


IMPORT_MODULE GameLoop

	;; Initializes the system
	;; REQUIRES: 8 bit A, 16 bit Index
	ROUTINE Init

	;; Processes the game loop
	;; REQUIRES: 8 bit A, 16 bit Index
	ROUTINE PlayGame

ENDMODULE

.endif ; __GAMELOOP_H_

; vim: ft=asm:

