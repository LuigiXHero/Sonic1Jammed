; ---------------------------------------------------------------------------
; Object XX - Sonic 2 Menu from title screen
; ---------------------------------------------------------------------------

TM_Max				EQU	1

TitleMenu:
	moveq	#0,d0
	move.b	ost_routine(a0),d0
	move.w	TitleMenu_Index(pc,d0.w),d1
	jsr	TitleMenu_Index(pc,d1.w)
	bra.w	DisplaySprite
; ===========================================================================
; off_13612: TitleMenu_States:
TitleMenu_Index:
	dc.w	TitleMenu_Init-TitleMenu_Index	; 0
        dc.w	TitleMenu_Main-TitleMenu_Index	; 2
        dc.w	TitleMenu_Return-TitleMenu_Index	; 4
; ===========================================================================
; loc_13616:
TitleMenu_Init:
	addq.b	#2,ost_routine(a0) ; => TitleMenu_Main
	move.w	#$128,ost_x_pos(a0)
	move.w	#$14C,ost_y_screen(a0)
	move.l	#Map_Menu,ost_mappings(a0)
	move.w	#$0680,ost_tile(a0)
	andi.b	#1,(v_titlemenu).w
	move.b	(v_titlemenu).w,ost_frame(a0)

; loc_13644:
TitleMenu_Main:
	moveq	#0,d2
	move.b	(v_titlemenu).w,d2
	move.b	(v_jpadpress1).w,d1
	or.b	(v_jpadpress1).w,d1
	btst	#bitUp,d1
	beq.s	@checkdown
	subq.b	#1,d2
	bcc.s	@moveSound
	move.b	#0,d2
	bra.s 	@checkdown

@moveSound:
	andi.b	#btnUp|btnDn,d1
	beq.s	@checkdown
	move.w	#sfx_Ring,d0				; play ring sound
	jsr	(PlaySound1).l

@checkdown:
	btst	#bitDn,d1
	beq.s	@move
	addq.b	#1,d2
	cmpi.b	#TM_Max+1,d2
	blo.s	@moveSound2
	moveq	#TM_Max,d2
	bra.s 	@move

@moveSound2:
	andi.b	#btnUp|btnDn,d1
	beq.s	@move
	move.w	#sfx_Ring,d0				; play ring sound
	jsr	(PlaySound1).l

@move:
	move.b	d2,ost_frame(a0)
	move.b	d2,(v_titlemenu).w
	;andi.b	#btnUp|btnDn,d1
	;beq.s	TitleMenu_return				; rts
	;sfx 	sfx_beep

TitleMenu_return:
	rts

	; Goto Title_S2MenuStuff for the actual stuff in Sonic1.asm

; -----------------------------------------------------------------------------
; Sprite Mappings - Sonic 2 Menu
; -----------------------------------------------------------------------------
Map_Menu:
	include "Objects\Title Menu [Mappings].asm"

; ---------------------------------------------------------------------------
