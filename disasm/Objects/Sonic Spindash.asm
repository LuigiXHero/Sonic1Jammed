; ---------------------------------------------------------------------------
; JAM: Handle spindash
; ---------------------------------------------------------------------------

;Sonic_Spindash:
		tst.b	ost_sonic_spindash(a0)			; Is Spindashing?
		bne.s	Sonic_UpdateSpindash			; if not, branch
		cmpi.b	#id_Duck,ost_anim(a0)			; How about ducking?
		bne.s	locret_1AC8C				; if not, branch
		move.b	v_joypad_press.w,d0			; read controller
		andi.b	#btnABC,d0				; if it's pressing A, B, or C?
		beq.w	locret_1AC8C 				; than don't branch
		move.b	#9,ost_anim(a0) 			; Set animation to funny spindash animation
		move.w	#sfx_spindash,d0			; oh and play the sound also
		jsr	PlaySound1				; lets go
		addq.l	#4,sp 					; increment stack ptr
		move.b	#1,ost_sonic_spindash(a0) 		; set the flag
		move.w	#0,ost_sonic_spindash_charge(a0)	; and clear this one
		move.b	#2,spindash_obj+ost_anim.w		; Lets go dust
		bsr.w	Sonic_LevelBound			; gotta do our usual
		bsr.w	Sonic_AnglePos				; like pros

locret_1AC8C:
		rts						; rip
; ---------------------------------------------------------------------------

Sonic_UpdateSpindash:
		move.b	v_joypad_hold.w,d0			; Get controller inputs again
		btst	#bitDn,d0				; and if it's down
		bne.w	Sonic_ChargingSpindash 			; then we keep charging

		; unleash the charged spindash and start rolling quickly:
		move.b	#$E,ost_height(a0)			; Set height to 7
		move.b	#7,ost_width(a0) 			; set width to 3?
		move.b	#id_roll,ost_anim(a0)			; set animation to roll
		addq.w	#5,ost_y_pos(a0)			; add the difference between Sonic's rolling and standing heights
		move.b	#0,ost_sonic_spindash(a0) 		; clear spindash flag
		moveq	#0,d0					; and d0
		move.b	ost_sonic_spindash_charge(a0),d0	; store our charge
		add.w	d0,d0 					; double it for the table
		move.w	SpindashSpeeds(pc,d0.w),ost_inertia(a0)	; and vroom
		move.w	ost_inertia(a0),d0			; we also do some storage
		subi.w	#$800,d0				; subtract $800
		add.w	d0,d0					; double it
		andi.w	#$1F00,d0				; mask it against $1F00
		neg.w	d0					; negate it
		addi.w	#$2000,d0				; add $2000 to it
		move.w	d0,hscroll_delay.w 			; and add it to horizonal delay
		btst	#0,ost_status(a0)			; facing right?
		beq.s	@GotSpeed				; if yes, cool then lets go
		neg.w	ost_inertia(a0)				; flip first then go

@GotSpeed:
		bset	#2,ost_status(a0)			; set air flag
		move.b	#0,spindash_obj+ost_anim.w		; stop dust
		move.w	#sfx_dash,d0				; spindash zoom sound
		jsr	PlaySound1 				; and play it
		bra.s	Obj01_Spindash_ResetScr			; reset screen
; ---------------------------------------------------------------------------

SpindashSpeeds:
		dc.w  $800	; 0 - S l o w
		dc.w  $880	; 1 - Slow
		dc.w  $900	; 2 - eh
		dc.w  $980	; 3 - eh?
		dc.w  $A00	; 4 - decent
		dc.w  $A80	; 5 - better
		dc.w  $B00	; 6 - oh
		dc.w  $B80	; 7 - this is nice
		dc.w  $C00	; 8 - LETS GO
; ---------------------------------------------------------------------------

Sonic_ChargingSpindash:			; If still charging the dash...
		tst.w	ost_sonic_spindash_charge(a0)		; check our charge count
		beq.s	@CheckPress				; if none, branch
		move.w	ost_sonic_spindash_charge(a0),d0	; otherwise store it
		lsr.w	#5,d0					; divide it by 32
		sub.w	d0,ost_sonic_spindash_charge(a0)	; then we subtract it from the original
		bcc.s	@CheckPress				; Is it equal or higher than our current charge?
		move.w	#0,ost_sonic_spindash_charge(a0)	; if so, clear it
		
@CheckPress:
		move.b	v_joypad_press.w,d0			; Get inputs
		andi.b	#btnABC,d0				; and if they're a, b, or c
		beq.w	Obj01_Spindash_ResetScr			; if not, branch
		move.w	#9<<8,ost_anim(a0)			; reset animation
		move.w	#sfx_spindash,d0			; play charge sound
		jsr	PlaySound1				; do it
		addi.w	#$200,ost_sonic_spindash_charge(a0)	; add a charge
		cmpi.w	#$800,ost_sonic_spindash_charge(a0)	; see if it's too much
		blo.s	Obj01_Spindash_ResetScr			; if not, branch
		move.w	#$800,ost_sonic_spindash_charge(a0)	; cap it

Obj01_Spindash_ResetScr:
		addq.l	#4,sp 					; increase stack ptr
		cmpi.w	#(224/2)-16,v_camera_y_shift.w		; check if y shift is done moving
		beq.s	loc_1AD8C				; if yes, branch
		bhs.s	@MoveUp					; Also make sure it's not too far up
		addq.w	#4,v_camera_y_shift.w			; if it is move it down

@MoveUp:
		subq.w	#2,v_camera_y_shift.w 			; else go up

loc_1AD8C:
		bsr.w	Sonic_LevelBound			; do the usual
		bsr.w	Sonic_AnglePos				; thing you do
		rts 						; time to leave
