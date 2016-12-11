
.include "entity.h"
.include "includes/synthetic.inc"
.include "includes/structure.inc"
.include "includes/registers.inc"



MODULE Entity


.segment "SHADOW"
	ADDR	firstActiveNpc
	ADDR	firstFreeNpc

	ADDR	firstActiveProjectile
	ADDR	firstFreeProjectile

	;; Object pool of NPCs.
	;; Must be in shadow, accessed via direct page.
	BYTE	npcPool, N_ACTIVE_NPCS * NPC_ENTITY_MALLOC

	;; Must be in shadow, accessed via direct page.
	BYTE	projectilePool, N_PROJECTILES * PROJECTILE_ENTITY_MALLOC

	WORD	previousEntity
	ADDR	projectileTmp
	WORD	tmp
.code

.assert .sizeof(EntityStruct) <= NPC_ENTITY_MALLOC, error, "NPC_ENTITY_MALLOC too small"
.assert .sizeof(EntityStruct) <= PROJECTILE_ENTITY_MALLOC, error, "PROJECTILE_ENTITY_MALLOC too small"



ROUTINE Init
	; firstActiveNpc = NULL
	; firstFreeNpc = projectiles
	; for dp in npcPool to npcPool[N_ACTIVE_NPCS - 2]
	;	dp->functionsTable = NULL
	;	dp->nextEntity = &dp + NPC_ENTITY_MALLOC
	; npcs[N_ACTIVE_ENEMIES - 1] = NULL
	;
	; firstActiveProjectile = NULL
	; firstFreeProjectile = projectiles
	; for dp in projectilePool to projectilePool[N_PROJECTILES - 2]
	;	dp->functionsTable = NULL
	;	dp->nextEntity = &dp + ENEMY_NPC_MALLOC
	; projectiles[N_PROJECTILES - 1] = NULL

	PHP
	PHD
	REP	#$30
.A16
.I16
	STZ	firstActiveNpc
	LDA	#npcPool
	STA	firstFreeNpc
	REPEAT
		TCD

		STZ	z:EntityStruct::functionsTable
		ADD	#NPC_ENTITY_MALLOC
		STA	z:EntityStruct::nextEntity

		CMP	#npcPool + npcPool__size - NPC_ENTITY_MALLOC
	UNTIL_GE

	; Last one terminates the list
	STZ	npcPool + (N_ACTIVE_NPCS - 1) * NPC_ENTITY_MALLOC


	STZ	firstActiveProjectile
	LDA	#projectilePool
	STA	firstFreeProjectile
	REPEAT
		TCD

		STZ	z:EntityStruct::functionsTable
		ADD	#PROJECTILE_ENTITY_MALLOC
		STA	z:EntityStruct::nextEntity

		CMP	#projectilePool + projectilePool__size - PROJECTILE_ENTITY_MALLOC
	UNTIL_GE

	; Last one terminates the list
	STZ	projectilePool + (N_PROJECTILES - 1) * PROJECTILE_ENTITY_MALLOC

	PLD
	PLP
	RTS





; INPUT: X = xpos, Y = ypos, A = address in InitBank of data, DB=$7E
; OUT: dp = entity created
; PARAM: firstFiree/firstActive = free/active linked list head.
;	InitBank the bank of entity states
;	InitRoutine the routine in the functions table to call
.macro _CreateLinkedList firstFree, firstActive, InitBank, size, InitRoutine
	; tmp = A
	; if firstFree != 0
	;	dp = firstFree
	;
	;	next = z:EntityStruct::nextEntity
	;	xPos = X
	;	yPos = Y
	;
	;	MemCopy(InitBank[tmp], dp, size)
	;
	;	dp->xPos + 1 = xPos
	;	dp->yPos + 1 = yPos
	;
	;	firstFree = dp->next
	;	dp->nextEntity = firstActive
	;	firstActive = dp

	STA	tmp

	LDA	firstFree
	IF_NOT_ZERO
		PHD
		TCD

		PHY
		PHX

		TAY

		LDA	z:EntityStruct::nextEntity	; moved here to save a PHA
		STA	firstFree

		LDX	tmp
		LDA	#size - 1

		PHB
		MVN	$7E, InitBank
		PLB

		PLA
		STA	z:EntityStruct::xPos + 1
		PLA
		STA	z:EntityStruct::yPos + 1

		LDA	firstActive
		STA	z:EntityStruct::nextEntity

		TDC
		STA	firstActive

		LDX	z:EntityStruct::functionsTable
		JSR	(InitRoutine, X)

		TDC
		TAY

		PLD
		RTS
	ENDIF

	LDY	#0
	RTS
.endmacro

.A16
.I16
ROUTINE CreateNpc
	_CreateLinkedList firstFreeNpc, firstActiveNpc, InitNpcBank, NPC_ENTITY_MALLOC, NpcEntityFunctionsTable::Init



.A16
.I16
ROUTINE CreateProjectile
	_CreateLinkedList firstFreeProjectile, firstActiveProjectile, InitProjectileBank, PROJECTILE_ENTITY_MALLOC, ProjectileEntityFunctionsTable::Init


.rodata

ENDMODULE

