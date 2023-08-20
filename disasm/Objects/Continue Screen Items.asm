; ---------------------------------------------------------------------------
; Object 80 - Continue screen elements

; spawned by:
;	GM_Continue - routine 0 (oval & text); routine 4 (mini Sonic)
; ---------------------------------------------------------------------------

ContScrItem:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	CSI_Index(pc,d0.w),d1
		jmp	CSI_Index(pc,d1.w)
; ===========================================================================
CSI_Index:	index *,,2
		ptr CSI_Main
		ptr CSI_Display
		ptr CSI_MakeMiniSonic
		ptr CSI_ChkDel
; ===========================================================================

CSI_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto CSI_Display next
		move.l	#Map_ContScr,ost_mappings(a0)
		move.w	#(vram_cont_sonic/sizeof_cell)+tile_hi,ost_tile(a0)
		move.b	#render_abs,ost_render(a0)
		move.b	#$3C,ost_displaywidth(a0)
		move.w	#$120,ost_x_pos(a0)
		move.w	#$C0,ost_y_screen(a0)
		move.w	#0,(v_rings).w				; clear rings

CSI_Display:	; Routine 2
		jmp	(DisplaySprite).l
; ===========================================================================

	CSI_MiniSonicPos:
		dc.w $116, $12A, $102, $13E, $EE, $152, $DA, $166, $C6
		dc.w $17A, $B2,	$18E, $9E, $1A2, $8A

CSI_MakeMiniSonic:
		; Routine 4
		movea.l	a0,a1
		lea	(CSI_MiniSonicPos).l,a2
		moveq	#0,d1
		move.b	(v_continues).w,d1
		subq.b	#2,d1
		bcc.s	@more_than_1
		jmp	(DeleteObject).l			; cancel if you have 0-1 continues

	@more_than_1:
		moveq	#1,d3
		cmpi.b	#14,d1					; do you have fewer than 16 continues
		bcs.s	@fewer_than_16				; if yes, branch

		moveq	#0,d3
		moveq	#14,d1					; cap at 15 mini-Sonics

	@fewer_than_16:
		move.b	d1,d2
		andi.b	#1,d2

CSI_MiniSonicLoop:
		move.b	#id_ContScrItem,ost_id(a1)		; load mini-Sonic object
		move.w	(a2)+,ost_x_pos(a1)			; use above data for x-axis position
		tst.b	d2					; do you have an even number of continues?
		beq.s	@is_even				; if yes, branch
		subi.w	#$A,ost_x_pos(a1)			; shift mini-Sonics slightly to the right

	@is_even:
		move.w	#$D0,ost_y_screen(a1)
		move.b	#id_frame_cont_mini1_6,ost_frame(a1)
		move.b	#id_CSI_ChkDel,ost_routine(a1)
		move.l	#Map_ContScr,ost_mappings(a1)
		move.w	#(vram_cont_minisonic/sizeof_cell)+tile_hi,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		lea	sizeof_ost(a1),a1
		dbf	d1,CSI_MiniSonicLoop			; repeat for number of continues

		lea	-sizeof_ost(a1),a1
		move.b	d3,ost_subtype(a1)

CSI_ChkDel:	; Routine 6
		tst.b	ost_subtype(a0)				; do you have 16 or more continues?
		beq.s	CSI_Animate				; if yes, branch
		cmpi.b	#id_CSon_Run,(v_ost_player+ost_routine).w ; is Sonic running?
		bcs.s	CSI_Animate				; if not, branch
		move.b	(v_vblank_counter_byte).w,d0
		andi.b	#1,d0
		bne.s	CSI_Animate
		tst.w	(v_ost_player+ost_x_vel).w		; is Sonic running?
		bne.s	CSI_Delete				; if yes, goto delete
		rts	

CSI_Animate:
		move.b	(v_vblank_counter_byte).w,d0
		andi.b	#$F,d0
		bne.s	@no_frame_chg
		bchg	#0,ost_frame(a0)			; animate every 16 frames

	@no_frame_chg:
		jmp	(DisplaySprite).l
; ===========================================================================

CSI_Delete:
		jmp	(DeleteObject).l
