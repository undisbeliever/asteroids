;; A generic entity state manager and renderer.
;;
;; It provides:
;;	* Dynamic memory allocation
;;	* collision detection
;;	* ::TODO Physics::
;;	* ::TODO out of scope detection::
;;
;; This module manages entities in 3 seperate lists:
;;	* Player
;;	* NPCs
;;	* Projectiles
;;
;; For speed purposes the system will only check for collisions between:
;;	* The Player and Projectiles
;;	* The Player and NPCs
;;	* The NPCs and Projectiles.
;;
;;
;; Memory Management
;; =================
;;
;; The NPC and Projectiles memory is managed by this module.
;; An entity can be created with the `Entity__CreateNpc` and
;; `Entity__CreateProjectile` routines, will copy an existing Entity state
;; from ROM into Shadow RAM and call the Entity's Init fuction.
;;
;; The player Entity must be in a fixed location in RAM as there is only one of it.
;;
;; To free an Entity from memory, you only need to set the `functionsTable` to
;; NULL (0). On the Render sweep, the module will free it from memory.
;;
;; `NPC_ENTITY_MALLOC` and `PROJECTILE_ENTITY_MALLOC` are allocated for each
;; Npc/Projctile no matter their type. The unused bytes are free to be used
;; by the Entity's virtal functions. Implementations of the entity MUST
;; NOT overflow their memory.
;;
;; The memory is managed by using two linked lists and moving the entity from the free
;; list into the active list on createion, and moving the entity from active to free on
;; cleanup.

.ifndef ::__ENTITY_H_
::__ENTITY_H_ = 1

.setcpu "65816"
.include "includes/import_export.inc"
.include "includes/structure.inc"
.include "routines/metasprite.h"

;; Number of bytes allocated to an npc.
;; ::TODO move into config.h::
NPC_ENTITY_MALLOC = 40

;; Number of npcs to allocate in shadow
;; ::TODO move into config.h::
N_ACTIVE_NPCS = 100

;; Number of bytes allocated per player projectile.
;; ::TODO move into config.h::
PROJECTILE_ENTITY_MALLOC = 20

;; Number of player projectiles
;; ::TODO move into config.h::
N_PROJECTILES = 4

;; A table of functions used to handle behaviour of the npcs.
.struct NpcEntityFunctionsTable
	;; Called when npc is created.
	;; REQUIRES: 16 bit A, 16 bit Index, DB=$7E
	;; INPUT: dp = EntityStruct address
	Init			.addr

	;; Called once per frame, before physics
	;; Should modify xVecl, yVecl, metaSpriteFrame
	;; May set the Entity's `functionsTable` to NULL to delete the entity.
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT: dp = EntityStruct address
	Process			.addr

	;; Called when the player collides with the npc
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT:
	;;	dp: EntityStruct NPC address
	CollisionPlayer		.addr

	;; Called when an npc collides with a projectile
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT:
	;;	dp: EntityStruct address of npc
	;;	y: EntityStruct projectile address
	CollisionProjectile	.addr

	;; Called when the entity is dead.
	;; REQUIRES: 8 bit A, 16 bit Index
	;; INPUT: dp: EntityStruct address
	Finalize		.addr
.endstruct

;; A table of functions used to handle behaviour of the projectiles
.struct ProjectileEntityFunctionsTable
	;; Called when projectile is created.
	;; REQUIRES: 16 bit A, 16 bit Index, DB=$7E
	;; INPUT: dp = EntityStruct address
	Init			.addr

	;; Called once per frame, before physics
	;; Should modify xVecl, yVecl, metaSpriteFrame
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT: dp = EntityStruct address
	Process			.addr

	;; Called when the projectile collides with a npc
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT:
	;;	dp: Npc address
	;; 	Y: Projectile address
	CollisionNpc		.addr

	;; Called when the npc collides with the player
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT:
	;; 	dp: Projectile address
	CollisionPlayer		.addr

	;; Called when the entity is dead.
	;; REQUIRES: 8 bit A, 16 bit Index
	;; INPUT: dp: Projectile address
	Finalize		.addr
.endstruct

;; A struct that holds the size data of the entity
;;
;; Both variables are 16 bit as the calculations are done in 16 bit mode for
;; speed purposes.
.struct EntitySizeStruct
	width			.word
	height			.word

	tileWidth		.byte
	tileHeight		.byte
.endstruct

.global EntitySizeStructBank:zp
.global InitNpcBank:zp
.global InitProjectileBank:zp

;; Common variables for all of the Entities.
;;
;; In actuality NPC_ENTITY_MALLOC bytes are allocated to RAM per NpcEntity and
;; can be used by the functions in `NpcEntityFunctionsTable` to save entity state.
.struct EntityStruct
	;; Next entity in the linked list.
	;; If 0 then this is the last entity in the linked list.
	nextEntity		.addr

	;; location of the NpcEntityFunctionsTable/ProjectileEntityFunctionsTable for this entity.
	;; if 0 then the entity is considered inactive and will be removed from
	;; the linked list.
	functionsTable		.addr

	;; xPos - 16:8 unsigned fixed point
	xPos			.res 3
	;; yPos - 16:8 unsigned fixed point
	yPos			.res 3

	;; xVecl - 1:7:8 signed fixed point
	xVecl			.res 2
	;; xVecl - 1:7:8 signed fixed point
	yVecl			.res 2

	;; pointer to EntitySizeStruct located within EntitySizeStructBank
	sizePtr			.addr

	;; pointer to the MetaSpriteData within `MetaSpriteLayoutBank`
	metaSpriteFrame		.addr
	;; The CharAttr offset of the MetaSprite data.
	metaSpriteCharAttr	.word
.endstruct


IMPORT_MODULE Entity
	;; First npc in the active linked list.
	ADDR	firstActiveNpc
	;; First npc in the free linked list
	ADDR	firstFreeNpc

	;; First prjectile in the active linked list.
	ADDR	firstActiveProjectile
	;; First prjectile in the free linked list
	ADDR	firstFreeProjectile

	;; Stores projectile variable in _Entity__CheckNpcProjectileCollisions.
	ADDR	projectileTmp

	;; The prvious item in the linked list.
	;; Used by render to free memory in a mark and sweek style list deletion.
	ADDR	previousEntity

	;; Initializes the npc and projectile object pool.
	;;
	;; This MUST be called before using the Entity fuinctions.
	;;
	;; REQUIRES: DB shadow or $7E
	ROUTINE	Init

	;; Creates a new npc in the object pool.
	;;
	;; Copies an init state of the object from from `InitNpcBank` to
	;; WRAM.
	;;
	;; Then sets the entities X.Y position.
	;;
	;; Then calls the npc's Init function after data init.
	;;
	;; REQUIRES: 16 bit A, 16 bit Index, DB shadow or $7E
	;; INPUT:
	;;	A: Address of a blank npc within bank `InitNpcBank`
	;;	X: xPosition
	;;	Y: yPosition
	;; OUTPUT:
	;;	DB: $7E
	;;	Y: the address of the allocated npc (NULL if not possible).
	;;	z flag set if NPC could not be created
	ROUTINE CreateNpc

	;; Creates a new projectile in the object pool.
	;;
	;; Copies a init state of the object from from `InitNpcBank` to
	;; WRAM.
	;;
	;; Then sets the entities X & Y position.
	;;
	;; Then calls the projectile's Init function after data init.
	;;
	;; REQUIRES: 16 bit A, 16 bit Index, DB shadow or $7E
	;; INPUT:
	;;	A: Address of a blank projectile within bank `InitProjectileBank`
	;;	X: xPosition
	;;	Y: yPosition
	;; OUTPUT:
	;;	DB: $7E
	;;	Y: the address of the allocated npc (NULL if not possible).
	;;	z flag set if NPC could not be created
	ROUTINE CreateProjectile

	;; Processes all of the NPCs and Projectiles.
	;;
	;; REQUIRES: 16 bit A, 16 bit Index, DB $7E
	;; PARAM:
	;;	player - the memory location of the player's struct
	.macro Entity__Process player
		; for dp in firstActiveProjectile linked list
		;	if dp->functionsTable
		;		dp->functionsTable->Process(dp)
		;		if dp->functionsTable
		;			// ::TODO physics::
		;			Entity__CheckEntityPlayerCollision(dp, player, PlayerProjectileCollisionRoutine, ProjectileEntityFunctionsTable::CollisionPlayer)
		;
		; for dp in firstActiveNpc linked list
		;	if dp->functionsTable == NULL
		;		continue
		;	dp->functionsTable->Process(dp)
		;
		;	if dp->functionsTable == NULL
		;		continue
		;
		;	// ::TODO physics::
		;
		;	Entity__CheckEntityPlayerCollision(dp, player, PlayerNpcCollisionRoutine, NpcEntityFunctionsTable::CollisionPlayer)
		;
		;	if dp->functionsTable
		;		_Entity__CheckNpcProjectileCollisions(dp, ProjectileEntityFunctionsTable::CollisionNpc, NpcEntityFunctionsTable::CollisionProjectile)

		.local EnterLoop

		.A16
		.I16

		LDA	Entity__firstActiveProjectile
		IF_NOT_ZERO
			REPEAT
				TCD

				LDX	z:EntityStruct::functionsTable
				IF_NOT_ZERO
					JSR	(ProjectileEntityFunctionsTable::Process, X)

					LDX	z:EntityStruct::functionsTable
					IF_NOT_ZERO
						; ::TODO physics::

						Entity__CheckEntityPlayerCollision player, ProjectileEntityFunctionsTable::CollisionPlayer
					ENDIF

				ENDIF

				LDA	z:EntityStruct::nextEntity
			UNTIL_ZERO
		ENDIF


		LDA	Entity__firstActiveNpc
		BRA	EnterLoop

		REPEAT
			LDA	z:EntityStruct::nextEntity
EnterLoop:
			IF_ZERO
				; ::MAYDO WHILEL structures::
				JMP	BREAK_LABEL
			ENDIF

			TCD

			LDX	z:EntityStruct::functionsTable
			BEQ	CONTINUE_LABEL

			JSR	(NpcEntityFunctionsTable::Process, X)

			LDX	z:EntityStruct::functionsTable
			BEQ	CONTINUE_LABEL

			; ::TODO physics::

			Entity__CheckEntityPlayerCollision player, NpcEntityFunctionsTable::CollisionPlayer
			LDX	z:EntityStruct::functionsTable
			BEQ	CONTINUE_LABEL

			_Entity__CheckNpcProjectileCollisions z:0, ProjectileEntityFunctionsTable::CollisionNpc, NpcEntityFunctionsTable::CollisionProjectile
		FOREVER
	.endmacro

	;; Renders the entities as meta-sprites and free up the linked lists.
	;;
	;; The entity will be removed from the active list if its functionsTable is NULL (0).
	;;
	;; The entitis are cleared by this routine as it could be problematic to clear them
	;; using the Process loop.
	;;
	;; REQUIRES: 16 bit A, 16 bit Index, DB=$7E
	.macro Entity__Render player, screenXpos, screenYpos
		.A16
		.I16

		_Entity__Render_List Entity__firstActiveProjectile, Entity__firstFreeProjectile, screenXpos, screenYpos
		_Entity__Render_List Entity__firstActiveNpc, Entity__firstFreeNpc, screenXpos, screenYpos
	.endmacro

	.macro _Entity__Render_List firstActive, firstFree, screenXpos, screenYpos
		; previousEntity = NULL
		; dp = firstActive
		; while dp != NULL
		;	if dp->functionsTable != 0
		;		// ::TODO animation::
		;
		;		MetaSprite__xPos = int(dp->xPos) - screenXpos
		;		MetaSprite__yPos = int(dp->yPos) - screenYpos
		;		// ::TODO check if outside playfield::
		;
		;		MetaSprite__ProcessMetaSprite_Y(dp->metaSpriteFrame, dp->metaSpriteCharAttr)
		;
		;		previousEntity = dp
		;		dp = dp->nextEntity
		;	else
		;		tmpNext = dp->nextEntity
		;
		;		if previousEntity
		;			previousEntity->nextEntity = dp->nextEntity
		;		else
		;			firstActive = dp->nextEntity
		;
		;		dp->nextEntity = firstFree
		;		firstFree = dp
		;		dp = y

		LDA	firstActive
		IF_NOT_ZERO
			STZ	Entity__previousEntity

			REPEAT
				TCD

				LDX	z:EntityStruct::functionsTable
				IF_NOT_ZERO
					; ::TODO animation::

					LDA	z:EntityStruct::xPos + 1
					SUB	screenXpos
					STA	MetaSprite__xPos

					LDA	z:EntityStruct::yPos + 1
					SUB	screenYpos
					STA	MetaSprite__yPos

					; ::TODO check if outside playfield::


					; ::TODO replace with macro (xPos, yPos, frame, charattr are paraeters::
					; ::TODO use DB = MetaSpriteLayoutBank, saves (n_entities + 4*obj - 7) cycles::
					; ::: Will require MetaSpriteLayoutBank & $7F <= $3F::
					LDX	z:EntityStruct::metaSpriteFrame
					LDY	z:EntityStruct::metaSpriteCharAttr

					SEP	#$20
					JSR	MetaSprite__ProcessMetaSprite_Y
					REP	#$20

					TDC
					STA	Entity__previousEntity
					LDA	z:EntityStruct::nextEntity
				ELSE
					; Remove the entity from the list
					; Move into free list.
					LDA	z:EntityStruct::nextEntity
					TAY

					LDX	Entity__previousEntity
					IF_ZERO
						STA	firstActive
					ELSE
						STA	a:EntityStruct::nextEntity, X
					ENDIF

					LDA	firstFree
					STA	z:EntityStruct::nextEntity
					TDC
					STA	firstFree

					TYA
				ENDIF
			UNTIL_ZERO
		ENDIF
	.endmacro


	;; Preforms a bounding box collision between the current entity (dp) and the player.
	;;
	;; If there is a collision, it will call CollisionRoutine THEN Entity Collision routine.
	;;
	;; This macro ignores the fractional part of xPos/yPos
	;;
	;; REQUIRES: 16 bit A, 16 bit Index, DB=$7E
	;; PARAM:
	;;	player: the address of the player's EntityStruct.
	;;	EntityCollisionRoutine: the routine in the Entity's finction table to call if there is a collision
	;; INPUT:
	;;	DP: address of npc
	.macro Entity__CheckEntityPlayerCollision player, EntityCollisionRoutine

		; Research
		; --------
		; The following is the fastest I can think of.
		; for simple 1 dimensional ideas (16 bit A, DP.l != 0):
		;	a.x in range(b.x, b.x + b.width) | b.x in range(a.x, a.x + a.width) = 36 cycles
		;	abs(a.x - b.x) < (a.width + b.width) / 2 = 43 cycles
		;	a.x < b.x ? (a.x + a.width >= b.x) : (b.x + b.width >= a.x) = 25-33 cycles


		; 	if npc->xPos < player.xPos
		;		if npc->x + npc->size->width < player.xPos
		;			goto NoCollision
		; 	else
		;		if player.xPos + player.size->width < npc->xPos
		;			goto NoCollision
		;
		; 	if npc->y < player.y
		;		if npc->yPos + npc->size->height < player.yPos
		;			goto NoCollision
		; 	else
		;		if player.yPos + player.size->height < npc->yPos
		;			goto NoCollision
		;
		; 	CollisionRoutine(npc)
		;	if npc->functionsTable
		;		npc->functionsTable->CollisionPlayer(npc)
		;	else
		;		return
		;

		;; ::TODO assert .asize = 16::
		.A16
		.I16

		.local NoCollision

		LDA	z:EntityStruct::xPos + 1
		CMP	a:player + EntityStruct::xPos + 1
		IF_LT
			; carry clear, A = npc->x
			LDX	z:EntityStruct::sizePtr
			ADC	f:EntitySizeStructBank << 16 + EntitySizeStruct::width, X
			CMP	a:player + EntityStruct::xPos + 1
			BLT	NoCollision
		ELSE
			LDX	a:player + EntityStruct::sizePtr
			LDA	a:player + EntityStruct::xPos + 1
			CLC
			ADC	f:EntitySizeStructBank << 16 + EntitySizeStruct::width, X
			CMP	z:EntityStruct::xPos + 1
			BLT	NoCollision
		ENDIF

		LDA	z:EntityStruct::yPos + 1
		CMP	player + EntityStruct::yPos + 1
		IF_LT
			LDX	z:EntityStruct::sizePtr
			; carry clear, A = npc->y
			ADC	f:EntitySizeStructBank << 16 + EntitySizeStruct::height, X
			CMP	a:player + EntityStruct::yPos + 1
			BLT	NoCollision
		ELSE
			LDX	a:player + EntityStruct::sizePtr
			LDA	a:player + EntityStruct::xPos + 1
			CLC
			ADC	f:EntitySizeStructBank << 16 + EntitySizeStruct::height, X
			CMP	z:EntityStruct::yPos + 1
			BLT	NoCollision
		ENDIF

		LDX	z:EntityStruct::functionsTable
		JSR	(EntityCollisionRoutine, X)

	NoCollision:
	.endmacro



	;; Preforms a bounding box collision between the current entity (player or entity)
	;; in dp and all of the projectiles.
	;;
	;; If there is a collision, it will call the projectile's `ProjctileCollisionRoutine`.
	;;
	;; This macro ignores the fractional part of xPos/yPos
	;;
	;; REQUIRES: 16 bit A, 16 bit Index, DB=$7E
	;; PARAM:
	;;	entityOffset: The offset of the entities EntityStruct data.
	;;	CollisionRoutine: The collision routine to call in `ProjectileEntityFunctionsTable`
	;; INPUT:
	;;	DP: the address of the EntityStruct.
	.macro _Entity__CheckNpcProjectileCollisions entityOffset, ProjctileCollisionRoutine, EntityCollisionRoutine
		; for y = firstActiveProjectile; y != NULL; y = projectiles[y]->nextEntity
		;	if projectiles[y]->functionsTable
		;		if npc->xPos < projectile[y]->xPos
		;			if npc->x + npc->size->width < projectile[y]->xPos
		;				continue
		; 		else
		;			if projectile[y]->xPos + projectile[y]->size->width < npc->xPos
		;				continue
		;
		;		if npc->y < projectile[y]->y
		;			if npc->yPos + npc->size->height < projectile[y]->yPos
		;				continue
		;		else
		;			if projectile[y]->yPos + projectile[y]->size->height < npc->yPos
		;			continue
		;
		;		projectile[y]->functionsTable->CollisionNpc(npc, y)
		;		if !npc->functionsTable
		;			break
		;		else
		;			npc->functionsTable->CollisionProjectile(npc, y)

		.local ContinueProjectileLoop

		; do projectile collision test
		LDY	Entity__firstActiveProjectile
		IF_NOT_ZERO
			REPEAT
				LDA	a:EntityStruct::functionsTable, Y
				IF_NOT_ZERO
					LDA	entityOffset + EntityStruct::xPos + 1
					CMP	a:EntityStruct::xPos + 1, Y
					IF_LT
						; carry clear, A = npc->x
						LDX	entityOffset + EntityStruct::sizePtr
						ADC	f:EntitySizeStructBank << 16 + EntitySizeStruct::width, X
						CMP	a:EntityStruct::xPos + 1, Y
						BLT	ContinueProjectileLoop
					ELSE
						LDX	a:EntityStruct::sizePtr, Y
						LDA	a:EntityStruct::xPos + 1, Y
						CLC
						ADC	f:EntitySizeStructBank << 16 + EntitySizeStruct::width, X
						CMP	entityOffset + EntityStruct::xPos + 1
						BLT	ContinueProjectileLoop
					ENDIF

					LDA	entityOffset + EntityStruct::yPos + 1
					CMP	a:EntityStruct::yPos + 1, Y
					IF_LT
						LDX	entityOffset + EntityStruct::sizePtr
						; carry clear, A = npc->y
						ADC	f:EntitySizeStructBank << 16 + EntitySizeStruct::height, X
						CMP	a:EntityStruct::yPos + 1, Y
						BLT	ContinueProjectileLoop
					ELSE
						LDX	a:EntityStruct::sizePtr, Y
						LDA	a:EntityStruct::xPos + 1, Y
						CLC
						ADC	f:EntitySizeStructBank << 16 + EntitySizeStruct::height, X
						CMP	entityOffset + EntityStruct::yPos + 1
						BLT	ContinueProjectileLoop
					ENDIF

					STY	Entity__projectileTmp

					LDX	a:EntityStruct::functionsTable, Y
					JSR	(ProjctileCollisionRoutine, X)

					LDY	Entity__projectileTmp

					LDX	z:EntityStruct::functionsTable
					BEQ	BREAK_LABEL
						JSR	(EntityCollisionRoutine, X)

					LDY	Entity__projectileTmp
				ENDIF

			ContinueProjectileLoop:

				LDX	a:EntityStruct::nextEntity, Y
				TXY
			UNTIL_ZERO
		ENDIF
	.endmacro




ENDMODULE

.endif ; __ENTITY_H_

; vim: ft=asm:
