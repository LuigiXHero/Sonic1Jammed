; ---------------------------------------------------------------------------
; Object 67 - disc that	you run	around (SBZ)

; spawned by:
;	ObjPos_SBZ2 - subtype $40
; ---------------------------------------------------------------------------

RunningDisc:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Disc_Index(pc,d0.w),d1
		jmp	Disc_Index(pc,d1.w)
; ===========================================================================
Disc_Index:	index *,,2
		ptr Disc_Main
		ptr Disc_Action

ost_disc_y_start:	equ $30					; original y-axis position (2 bytes)
ost_disc_x_start:	equ $32					; original x-axis position (2 bytes)
ost_disc_inner_radius:	equ $34					; distance of small circle from centre
ost_disc_rotation:	equ $36					; rate/direction of small circle rotation (2 bytes)
ost_disc_outer_radius:	equ $38					; distance of Sonic from centre
ost_disc_init_flag:	equ $3A					; set when Sonic lands on the disc
; ===========================================================================

Disc_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Disc_Action next
		move.l	#Map_Disc,ost_mappings(a0)
		move.w	#tile_Nem_SbzDisc+tile_pal3+tile_hi,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		move.w	ost_x_pos(a0),ost_disc_x_start(a0)
		move.w	ost_y_pos(a0),ost_disc_y_start(a0)
		move.b	#$18,ost_disc_inner_radius(a0)
		move.b	#$48,ost_disc_outer_radius(a0)
		move.b	ost_subtype(a0),d1			; get object type
		andi.b	#$F,d1					; read only the	low nybble
		beq.s	@typeis0				; branch if 0
		move.b	#$10,ost_disc_inner_radius(a0)		; unused smaller disc
		move.b	#$38,ost_disc_outer_radius(a0)

	@typeis0:
		move.b	ost_subtype(a0),d1			; get object type
		andi.b	#$F0,d1					; read only the	high nybble
		ext.w	d1
		asl.w	#3,d1					; multiply by 8
		move.w	d1,ost_disc_rotation(a0)		; set rotation speed (only $200 is used)
		move.b	ost_status(a0),d0			; get object status
		ror.b	#2,d0					; move x/yflip bits to top
		andi.b	#(status_xflip+status_yflip)<<6,d0	; read only those
		move.b	d0,ost_angle(a0)			; use as starting angle

Disc_Action:	; Routine 2
		bsr.w	Disc_Detect
		bsr.w	Disc_MoveSpot
		bra.w	Disc_ChkDel

; ---------------------------------------------------------------------------
; Subroutine to detect collision with disc and set Sonic's inertia
; ---------------------------------------------------------------------------

Disc_Detect:
		moveq	#0,d2
		move.b	ost_disc_outer_radius(a0),d2
		move.w	d2,d3
		add.w	d3,d3
		lea	(v_ost_player).w,a1
		move.w	ost_x_pos(a1),d0
		sub.w	ost_disc_x_start(a0),d0
		add.w	d2,d0
		cmp.w	d3,d0
		bcc.s	@not_on_disc
		move.w	ost_y_pos(a1),d1
		sub.w	ost_disc_y_start(a0),d1
		add.w	d2,d1
		cmp.w	d3,d1
		bcc.s	@not_on_disc				; branch if Sonic is outside the range of the disc
		btst	#status_air_bit,ost_status(a1)		; is Sonic in the air?
		beq.s	Disc_Inertia				; if not, branch
		clr.b	ost_disc_init_flag(a0)
		rts	
; ===========================================================================

@not_on_disc:
		tst.b	ost_disc_init_flag(a0)			; was Sonic on the disc last frame?
		beq.s	@skip_clear				; if not, branch
		clr.b	ost_sonic_sbz_disc(a1)
		clr.b	ost_disc_init_flag(a0)

	@skip_clear:
		rts	
; ===========================================================================

Disc_Inertia:
		tst.b	ost_disc_init_flag(a0)			; was Sonic on the disc last frame?
		bne.s	@skip_init				; if yes, branch
		move.b	#1,ost_disc_init_flag(a0)		; set flag for Sonic being on the disc
		btst	#status_jump_bit,ost_status(a1)		; is Sonic jumping?
		bne.s	@jumping				; if yes, branch
		clr.b	ost_anim(a1)				; use walking animation

	@jumping:
		bclr	#status_pushing_bit,ost_status(a1)
		move.b	#id_Run,ost_anim_restart(a1)		; use running animation
		move.b	#1,ost_sonic_sbz_disc(a1)		; keep Sonic stuck to disc until he jumps

	@skip_init:
		move.w	ost_inertia(a1),d0
		tst.w	ost_disc_rotation(a0)			; check rotation direction (only $200 is used)
		bpl.s	Disc_Inertia_Clockwise			; branch if positive

		cmpi.w	#-$400,d0
		ble.s	@chk_max_neg
		move.w	#-$400,ost_inertia(a1)			; set minimum inertia on disc
		rts	
; ===========================================================================

@chk_max_neg:
		cmpi.w	#-$F00,d0
		bge.s	@exit
		move.w	#-$F00,ost_inertia(a1)			; set maximum inertia on disc

	@exit:
		rts	
; ===========================================================================

Disc_Inertia_Clockwise:
		cmpi.w	#$400,d0
		bge.s	@chk_max
		move.w	#$400,ost_inertia(a1)			; set minimum inertia on disc
		rts	
; ===========================================================================

@chk_max:
		cmpi.w	#$F00,d0
		ble.s	@exit
		move.w	#$F00,ost_inertia(a1)			; set maximum inertia on disc

	@exit:
		rts	
; ===========================================================================

Disc_MoveSpot:
		move.w	ost_disc_rotation(a0),d0		; get rotation rate (only $200 is used)
		add.w	d0,ost_angle(a0)			; update angle
		move.b	ost_angle(a0),d0
		jsr	(CalcSine).l				; convert to sine/cosine
		move.w	ost_disc_y_start(a0),d2
		move.w	ost_disc_x_start(a0),d3
		moveq	#0,d4
		move.b	ost_disc_inner_radius(a0),d4
		lsl.w	#8,d4
		move.l	d4,d5
		muls.w	d0,d4
		swap	d4
		muls.w	d1,d5
		swap	d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,ost_y_pos(a0)			; update position
		move.w	d5,ost_x_pos(a0)
		rts	
; ===========================================================================

Disc_ChkDel:
		out_of_range.s	@delete,ost_disc_x_start(a0)
		jmp	(DisplaySprite).l

	@delete:
		jmp	(DeleteObject).l
