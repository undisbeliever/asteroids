
.include "physics.h"
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"
.include "routines/block.h"

.include "entity.h"
.include "gameloop.h"

MODULE Physics

; dp = entity
.A16
.I16
ROUTINE ProcessEntity

	; ::KUDOS Khaz::
	; ::: http://forums.nesdev.com/viewtopic.php?f=12&t=12459&p=142645#p142674 ::
	CLC
	LDA	z:EntityStruct::xVecl
	IF_MINUS
		; xVecl is negative
		; Fastest case by 1 cycle if no underflow, otherwise slowest by 2 cycles

		ADC	z:EntityStruct::xPos
		STA	z:EntityStruct::xPos
		BCS	Process_End_XPos
			; 16 bit underflow - subtract by one
			SEP	#$20        ; 8 bit A
			DEC	z:EntityStruct::xPos + 2
			REP     #$20        ; 16 bit A again
	ELSE
		; else - sint16 is positive
		ADC	z:EntityStruct::xPos
		STA	z:EntityStruct::xPos
		BCC	Process_End_XPos
			; 16 bit overflow - add carry
			SEP	#$20        ; 8 bit A
			INC	z:EntityStruct::xPos + 2
			REP	#$20        ; 16 bit A again
Process_End_XPos:
	ENDIF

	LDA	z:EntityStruct::xPos + 1
	IF_MINUS
		ADD	#256 + SCREEN_WRAP_PADDING
		STA	z:EntityStruct::xPos + 1
	ELSE
		CMP	#256 + SCREEN_WRAP_PADDING
		IF_GE
			LDA	z:EntityStruct::xPos + 1
			SUB	#256 + SCREEN_WRAP_PADDING
			STA	z:EntityStruct::xPos + 1
		ENDIF
	ENDIF

	CLC
	LDA	z:EntityStruct::yVecl
	IF_MINUS
		; yVecl is negative
		; Fastest case by 1 cycle if no underflow, otherwise slowest by 2 cycles

		ADC	z:EntityStruct::yPos
		STA	z:EntityStruct::yPos
		BCS	Process_End_YPos
			; 16 bit underflow - subtract by one
			SEP	#$20        ; 8 bit A
			DEC	z:EntityStruct::yPos + 2
			REP     #$20        ; 16 bit A again
	ELSE
		; else - sint16 is positive
		ADC	z:EntityStruct::yPos
		STA	z:EntityStruct::yPos
		BCC	Process_End_YPos
			; 16 bit overflow - add carry
			SEP	#$20        ; 8 bit A
			INC	z:EntityStruct::yPos + 2
			REP	#$20        ; 16 bit A again
Process_End_YPos:
	ENDIF

	LDA	z:EntityStruct::yPos + 1
	IF_MINUS
		ADD	#224 + SCREEN_WRAP_PADDING
		STA	z:EntityStruct::yPos + 1
	ELSE
		CMP	#224 + SCREEN_WRAP_PADDING
		IF_GE
			SUB	#224 + SCREEN_WRAP_PADDING
			STA	z:EntityStruct::yPos + 1
		ENDIF
	ENDIF

	RTS

ENDMODULE

