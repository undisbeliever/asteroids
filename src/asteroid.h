
.ifndef ::__ASTEROID_H_
::__ASTEROID_H_ = 1

.setcpu "65816"
.include "includes/import_export.inc"

IMPORT_MODULE Asteroid

	;; Spawn a randomly placed Large Asteroid.
	ROUTINE	SpawnLargeAsteroid

ENDMODULE

.endif ; __ASTEROID_H_

; vim: ft=asm:

