; ===========================================================================
; ---------------------------------------------------------------------------
; JAM: Object 8D - spindash dust
; ---------------------------------------------------------------------------

Spindash_Dust:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Obj8D_Index(pc,d0.w),d1
		jmp	Obj8D_Index(pc,d1.w)
; ---------------------------------------------------------------------------

Obj8D_Index:
		dc.w Obj8D_Init-Obj8D_Index
		dc.w Obj8D_Main-Obj8D_Index
		dc.w Obj8D_Delete-Obj8D_Index
		dc.w Obj8D_CheckSkid-Obj8D_Index
; ---------------------------------------------------------------------------

Obj8D_Init:
		addq.b	#2,ost_routine(a0)
		move.l	#Map_obj8D,ost_mappings(a0)
		ori.b	#4,ost_render(a0)
		move.b	#1,ost_priority(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.w	#$7A0,ost_tile(a0)
		move.w	#v_ost_player,$3E(a0)
; ---------------------------------------------------------------------------

Obj8D_Main:
		movea.w	$3E(a0),a2	; a2=character
		moveq	#0,d0
		move.b	ost_anim(a0),d0	; use current animation as a secondary routine counter
		add.w	d0,d0
		move.w	Obj8D_DisplayModes(pc,d0.w),d1
		jmp	Obj8D_DisplayModes(pc,d1.w)
; ---------------------------------------------------------------------------

Obj8D_DisplayModes:
		dc.w Obj8D_Display-Obj8D_DisplayModes
		dc.w Obj8D_Display-Obj8D_DisplayModes
		dc.w Obj8D_MdSpindashDust-Obj8D_DisplayModes
		dc.w Obj8D_MdSkidDust-Obj8D_DisplayModes
; ---------------------------------------------------------------------------

Obj8D_MdSpindashDust:
		cmpi.b	#4,ost_routine(a2)
		bhs.s	Obj8D_ResetDisplayMode
		tst.b	ost_sonic_spindash(a2)
		beq.s	Obj8D_ResetDisplayMode
		move.w	ost_x_pos(a2),ost_x_pos(a0)
		move.w	ost_y_pos(a2),ost_y_pos(a0)
		move.b	ost_status(a2),ost_status(a0)
		andi.b	#1,ost_status(a0)
		tst.b	ost_anim_restart(a0)
		bne.s	Obj8D_Display
		andi.w	#$7FFF,ost_tile(a0)
		tst.w	ost_tile(a2)
		bpl.s	Obj8D_Display
		ori.w	#$8000,ost_tile(a0)
; ---------------------------------------------------------------------------

Obj8D_MdSkidDust:
Obj8D_Display:
		lea	Ani_Obj8D(pc),a1
		jsr	AnimateSprite
		bsr.w	Obj8D_LoadDustOrSplashArt
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

Obj8D_ResetDisplayMode:
		move.b	#0,ost_anim(a0)
		rts
; ---------------------------------------------------------------------------

Obj8D_Delete:
		jmp	DeleteObject
; ---------------------------------------------------------------------------

Obj8D_CheckSkid:
		movea.w	$3E(a0),a2	; a2=character
		cmpi.b	#$D,ost_anim(a2); SonAni_Stop
		beq.s	Obj8D_SkidDust
		move.b	#2,ost_routine(a0)
		move.b	#0,$32(a0)
		rts
; ---------------------------------------------------------------------------

Obj8D_SkidDust:
		subq.b	#1,$32(a0)
		bpl.s	Obj8D_LoadDustOrSplashArt
		move.b	#3,$32(a0)
		bsr.w	SingleObjLoad
		bne.s	Obj8D_LoadDustOrSplashArt
		move.b	ost_id(a0),ost_id(a1)	; load Obj8D
		move.w	ost_x_pos(a2),ost_x_pos(a1)
		move.w	ost_y_pos(a2),ost_y_pos(a1)
		addi.w	#$10,ost_y_pos(a1)
		move.b	#0,ost_status(a1)
		move.b	#3,ost_anim(a1)
		addq.b	#2,ost_routine(a1)
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	#1,ost_priority(a1)
		move.b	#4,ost_displaywidth(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.w	$3E(a0),$3E(a1)
		andi.w	#$7FFF,ost_tile(a1)
		tst.w	ost_tile(a2)
		bpl.s	Obj8D_LoadDustOrSplashArt
		ori.w	#$8000,ost_tile(a1)
; ---------------------------------------------------------------------------

Obj8D_LoadDustOrSplashArt:
		moveq	#0,d0
		move.b	ost_frame(a0),d0
		cmp.b	$30(a0),d0
		beq.s	locret_1DF36
		move.b	d0,$30(a0)
		lea	DPLC_Obj8D,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	locret_1DF36
		move.w	#$7A0*$20,d4

@Queue:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		addi.l	#Art_SpindashDust,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	QueueDMATransfer
		dbf	d5,@Queue

locret_1DF36:
		rts
; ---------------------------------------------------------------------------
	
Ani_obj8D:
	include	"Objects/Spindust [Animation].asm"
Map_obj8D:
	include	"Objects/Spindust [Mappings].asm"
DPLC_Obj8D:
	include	"Objects/SpinDust DPLC.asm"