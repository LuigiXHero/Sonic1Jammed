; ---------------------------------------------------------------------------
; JAM: Handle spindash
; ---------------------------------------------------------------------------

;Sonic_Spindash:
		tst.b	ost_sonic_spindash(a0)			; JAM: Is Sonic spindashing?
		bne.s	Sonic_UpdateSpindash			; JAM: If not, branch
		cmpi.b	#id_Duck,ost_anim(a0)			; JAM: If Sonic ducking?
		bne.s	@end					; JAM: If not, branch
		move.b	v_joypad_press.w,d0			; JAM: Read controller
		andi.b	#btnABC,d0				; JAM: Have A, B, or C been pressed?
		beq.w	@end	 				; JAM: If not, branch
		
		move.b	#9,ost_anim(a0) 			; JAM: Set to spindash animation
		move.w	#sfx_spindash,d0			; JAM: Play spindash sound
		jsr	PlaySound1				; JAM
		
		addq.l	#4,sp 					; JAM: Cancel out rest of ground mode

		move.b	#1,ost_sonic_spindash(a0) 		; JAM: Set spindash flag
		move.w	#0,ost_sonic_spindash_charge(a0)	; JAM: Reset spindash counter
		move.b	#2,(spindash_obj+ost_anim).w		; JAM: Display spindash dust

		bsr.w	Sonic_LevelBound			; JAM: Check level boundaries
		bsr.w	Sonic_AnglePos				; JAM: Check ground collision

	@end:
		rts
		
; ---------------------------------------------------------------------------

Sonic_UpdateSpindash:
		move.b	v_joypad_hold.w,d0			; JAM: Read controller
		btst	#bitDn,d0				; JAM: Is down being held?
		bne.w	Sonic_ChargingSpindash 			; JAM: If so, branch

		; Unleash the charged spindash and start rolling
		move.b	#$E,ost_height(a0)			; JAM: Set to roll hitbox
		move.b	#7,ost_width(a0) 			; JAM
		move.b	#id_roll,ost_anim(a0)			; JAM: Set to rolling animation
		addq.w	#5,ost_y_pos(a0)			; JAM: Align with ground

		move.b	#0,ost_sonic_spindash(a0) 		; JAM: Clear spindash flag
		moveq	#0,d0					; JAM: Get charge speed
		move.b	ost_sonic_spindash_charge(a0),d0	; JAM
		add.w	d0,d0 					; JAM
		move.w	SpindashSpeeds(pc,d0.w),ost_inertia(a0)	; JAM

		move.w	ost_inertia(a0),d0			; JAM: Get horizontal scroll delay
		subi.w	#$800,d0				; JAM
		add.w	d0,d0					; JAM
		andi.w	#$1F00,d0				; JAM
		neg.w	d0					; JAM
		addi.w	#$2000,d0				; JAM
		move.w	d0,(hscroll_delay).w 			; JAM

		btst	#0,ost_status(a0)			; JAM: Is Sonic facing right?
		beq.s	@GotSpeed				; JAM: If so, branch
		neg.w	ost_inertia(a0)				; JAM: If not, move to the left

@GotSpeed:
		bset	#2,ost_status(a0)			; JAM: Set roll flag
		move.b	#0,(spindash_obj+ost_anim).w		; JAM: Disable spindash dust
		move.w	#sfx_dash,d0				; JAM: Play unleash sound
		jsr	PlaySound1 				; JAM
		bra.s	Sonic_SpindashUpdates			; JAM: Perform other object updates
		
; ---------------------------------------------------------------------------

SpindashSpeeds:
		dc.w  $800					; 0 - S l o w
		dc.w  $880					; 1 - Slow
		dc.w  $900					; 2 - Eh
		dc.w  $980					; 3 - Eh?
		dc.w  $A00					; 4 - Decent
		dc.w  $A80					; 5 - Better
		dc.w  $B00					; 6 - Oh
		dc.w  $B80					; 7 - This is nice
		dc.w  $C00					; 8 - LET'S GO

; ---------------------------------------------------------------------------

Sonic_ChargingSpindash:
		tst.w	ost_sonic_spindash_charge(a0)		; JAM: Are we at the slowest charge speed?
		beq.s	@CheckPress				; JAM: If so, branch
		move.w	ost_sonic_spindash_charge(a0),d0	; JAM: Decrease charge speed
		lsr.w	#5,d0					; JAM
		sub.w	d0,ost_sonic_spindash_charge(a0)	; JAM
		bcc.s	@CheckPress				; JAM: Branch if there was no underflow
		move.w	#0,ost_sonic_spindash_charge(a0)	; JAM: If there was, cap at 0
		
@CheckPress:
		move.b	v_joypad_press.w,d0			; JAM: Read controller
		andi.b	#btnABC,d0				; JAM: Have A, B, or C been pressed?
		beq.w	Sonic_SpindashUpdates			; JAM: If not, branch

		move.w	#9<<8,ost_anim(a0)			; JAM: Reset animation
		move.w	#sfx_spindash,d0			; JAM: Play charge sound
		jsr	PlaySound1				; JAM

		addi.w	#$200,ost_sonic_spindash_charge(a0)	; JAM: Increase charge speed
		cmpi.w	#$800,ost_sonic_spindash_charge(a0)	; JAM: Have we reached the max speed?
		blo.s	Sonic_SpindashUpdates			; JAM: If not, branch
		move.w	#$800,ost_sonic_spindash_charge(a0)	; JAM: If so, cap it

Sonic_SpindashUpdates:
		addq.l	#4,sp 					; JAM: Cancel out rest of ground mode
		cmpi.w	#(224/2)-16,(v_camera_y_shift).w	; JAM: Is the camera in the center?
		beq.s	loc_1AD8C				; JAM: If so, branch
		bcc.s	@MoveUp					; JAM: If it needs to be moved up, branch
		addq.w	#4,(v_camera_y_shift).w			; JAM: Move camera down double the speed (next instruction cancels half of it out)

@MoveUp:
		subq.w	#2,v_camera_y_shift.w 			; JAM: Move camera up

loc_1AD8C:
		bsr.w	Sonic_LevelBound			; JAM: Check level boundaries
		bsr.w	Sonic_AnglePos				; JAM: Check ground collision
		rts 
