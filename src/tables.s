
.include "tables.h"
.include "routines/metasprite.h"
.include "entity.h"

MODULE Tables

.rodata
	.include "tables/sine.inc"


.segment "BANK1"
	InitNpcBank 		= .bankbyte(*)
	InitProjectileBank 	= .bankbyte(*)

	MetaSpriteLayoutBank	= .bankbyte(*)


ENDMODULE

