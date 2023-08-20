; -------------------------------------------------------------------------------
; Options/Level Select
; -------------------------------------------------------------------------------

	include	"_options/macro.asm"

; -------------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------------
	rsreset
OPT_SONIC1	rs.b 	1			; options_mode - Sonic 1
OPT_SONIC2	rs.b 	1			; options_mode - Sonic 2
OPT_OPTIONS	rs.b 	1			; options_mode - Options

OPT_LINE_LEN	EQU	$19			; Line length
OPT_OPT_LEN	EQU	8			; Option length

; -------------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------------

;options_sound			rs.b 1 ; $FFFFFF80 ; Sound test selection
;options_delay			rs.b 1 ; $FFFFFF81 ; Selection movement delay
;options_sel			rs.b 1 ; $FFFFFF82 ; Selection
;options_prev			rs.b 1 ; $FFFFFF83 ; Previous selection
;options_redraw			rs.b 1 ; $FFFFFF84 ; Redraw flag
;options_exit			rs.b 1 ; $FFFFFF85 ; Exit code

; -------------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------------

Options:
	clr.l	options_sound.w			; Reset variables
	clr.w	options_redraw.w
	;clr.b	options_exit.w

	st	options_redraw.w		; Force redraw
	move.b	#$81,options_sound.w		; Reset sound test selection

;	moveq	#pl_LvlSel,d0			; Play music
;	jsr	PlaySound_List.w

	moveq	#2,d0				; Load palette
	jsr	PalLoad_Now.w

	move	#$2700,sr			; Disable interrupts

	lea	v_hscrolltablebuffer.w,a1	; Clear scroll table
	moveq	#0,d0
	move.w	#224-1,d1

@ClearScroll:
	move.l	d0,(a1)+
	dbf	d1,@ClearScroll

	lea	vdp_data_port,a6		; Load font
	move.l	#$50000003,4(a6)
	lea	Art_Text,a5
	move.w	#(Art_Text_End-Art_Text)/2-1,d1

@LoadFont:
	move.w	(a5)+,(a6)
	dbf	d1,@LoadFont

	move.l	#$60000003,4(a6)		; Remove background
	move.w	#$1000/4-1,d1

@RemoveBG:
	move.l	d0,(a6)
	dbf	d1,@RemoveBG
	
	move.l	d0,v_scrposy_dup.w		; Reset vertical scroll

; -------------------------------------------------------------------------------

@Loop:
	move.b	#4,v_vbla_routine.w		; VSync
	;jsr	ProcessKosQueue.w
	jsr	WaitForVBlank.w
	;jsr	ProcessKosMQueue.w

	lea	vdp_data_port,a6		; VDP data port
	bsr.w	Options_GetData			; Get options data

; -------------------------------------------------------------------------------

@CheckCtrl:
	move.b	v_jpadpress1.w,d0		; Was up or down just pressed?
	andi.b	#3,d0
	bne.s	@MoveSelection			; If so, branch

	move.b	v_jpadhold1.w,d0		; Is up or down being held?
	andi.b	#3,d0
	beq.s	@LineChecks			; If not, branch
	subq.b	#1,options_delay.w		; Decrement delay counter
	bpl.s	@LineChecks			; If it hasn't run out, branch

@MoveSelection:
	move.b	#12-1,options_delay.w		; Reset delay counter
	btst	#0,d0				; Are we moving up?
	beq.s	@CheckDown			; If not, branch
	subq.b	#1,options_sel.w		; Move selection up
	bpl.s	@LineChecks			; If it hasn't gone past the top, branch
	move.b	(a5),options_sel.w		; Wrap back to the bottom
	bra.s	@LineChecks

@CheckDown:
	btst	#1,d0				; Are we moving down?
	beq.s	@LineChecks			; If not, branch
	addq.b	#1,options_sel.w		; Move selection down
	move.b	(a5),d0				; Has it gone past the bottom?
	cmp.b	options_sel.w,d0
	bcc.s	@LineChecks			; If not, branch
	clr.b	options_sel.w			; Wrap back to the top

; -------------------------------------------------------------------------------

@LineChecks:
	addq.w	#2,a5				; Skip past option count
	move.l	#$61900003,d6			; VDP command
	moveq	#0,d7				; Reset current option line being checked

@LineLoop:
	move.l	d6,4(a6)			; Set VDP command
	move.b	options_redraw.w,d2		; Set force draw flag

	moveq	#0,d0				; Get option
	move.b	(a5)+,d0
	bmi.s	@ChecksDone			; If we are at the end, branch
	add.w	d0,d0				; Handle option line
	add.w	d0,d0
	lea	@OptionTypes(pc),a0
	jsr	(a0,d0.w)
	
	move.w	a5,d0				; Align address if needed
	btst	#0,d0
	beq.s	@NoAlign
	addq.w	#1,a5

@NoAlign:
	addi.l	#$800000,d6			; Next line
	addq.b	#1,d7
	bra.s	@LineLoop

@ChecksDone:
	tst.b	options_redraw.w		; Check if we should draw again
	sf	options_redraw.w		; Clear redraw flag
	beq.s	@CheckExit			; If we shouldn't redraw, branch
	bmi.s	@CheckExit
	bsr.w	Options_GetData			; Get options data
	bra.w	@LineChecks			; Redraw

@CheckExit:
	move.b	options_sel.w,options_prev.w	; Update selection
	
	moveq	#0,d0				; Are we exiting?
	move.b	options_exit.w,d0
	beq.w	@Loop				; If not, loop

; -------------------------------------------------------------------------------

	add.w	d0,d0				; Handle exit
	add.w	d0,d0
	jmp	@Exit-4(pc,d0.w)

; -------------------------------------------------------------------------------
; Exits
; -------------------------------------------------------------------------------

@Exit:
	bra.w	@LevelExit			; Level exit
	bra.w	@SpecialExit			; Special stage exit
	bra.w	@SoundTest			; Sound test
	bra.w	@OptionsExit			; Options exit

; -------------------------------------------------------------------------------
; Level exit
; -------------------------------------------------------------------------------

@LevelExit:
	jmp 	PlayLevel			; Go to character select

; -------------------------------------------------------------------------------
; Special stage exit
; -------------------------------------------------------------------------------

@SpecialExit:
	move.b	#$10,v_gamemode.w		; Set to special stage
	clr.w	v_zone.w			; Clear zone ID
	move.b	#3,v_lives.w			; Reset lives
	moveq	#0,d0
	move.w	d0,v_rings.w			; Reset rings
	move.l	d0,v_time.w			; Reset time
	move.l	d0,v_score.w			; Reset score
	move.l	#5000,v_scorelife.w		; 1UP is given at 50000 points
	rts

; -------------------------------------------------------------------------------
; Sound test
; -------------------------------------------------------------------------------

@SoundTest:
	move.b	options_sound.w,d0		; Play sound
	jsr	playsound1
	clr.b	options_exit.w			; Reset exit code
	bra.w	@Loop				; Go back to options

; -------------------------------------------------------------------------------
; Options exit
; -------------------------------------------------------------------------------

@OptionsExit:
	jmp	SaveSRAMData.w			; Save data and exit

; -------------------------------------------------------------------------------
; Option types
; -------------------------------------------------------------------------------

@OptionTypes:
	bra.w	Option_Bit			; Bit option
	bra.w	Option_Byte			; Byte option
	bra.w	Option_NumberByte		; Generic number option (byte)
	bra.w	Option_NumberWord		; Generic number option (word)
	bra.w	Option_Level			; Level option
	bra.w	Option_Exit			; Exit option

; -------------------------------------------------------------------------------
; Bit option
; -------------------------------------------------------------------------------

Option_Bit:
	moveq	#0,d1				; Get bit ID
	move.b	(a5)+,d1

	moveq	#-1,d0				; Get variable
	move.w	(a5)+,d0
	move.l	d0,a0

	cmp.b	options_sel.w,d7		; Is this the currently selected line?
	bne.s	@NoChange			; If not, branch
	
	move.b	v_jpadpress1.w,d0		; Was left or right was just pressed?
	andi.b	#$C,d0
	beq.s	@NoChange			; If not, branch
	bchg	d1,(a0)				; Swap flag
	moveq	#1,d2				; Redraw line

@NoChange:
	moveq	#OPT_LINE_LEN-OPT_OPT_LEN-1,d0	; Draw option
	bsr.w	Options_DrawText

	btst	d1,(a0)				; Is the flag set?
	bne.s	@DrawOption			; If so, branch
	addq.w	#OPT_OPT_LEN,a5			; Skip over set text

@DrawOption:
	moveq	#OPT_OPT_LEN-1,d0		; Draw selection
	bsr.w	Options_DrawText

	btst	d1,(a0)				; Is the flag set?
	beq.s	@End				; If not, branch
	addq.w	#OPT_OPT_LEN,a5			; Skip over unset text

@End:
	rts

; -------------------------------------------------------------------------------
; Byte option
; -------------------------------------------------------------------------------

Option_Byte:
	moveq	#0,d1				; Get pointer to end of line
	move.b	(a5)+,d1

	moveq	#-1,d0				; Get variable
	move.w	(a5)+,d0
	move.l	d0,a0

	bsr.w	Options_SelectNumByte		; Handle selection

	moveq	#OPT_LINE_LEN-OPT_OPT_LEN-1,d0	; Draw option
	bsr.w	Options_DrawText
	
	lea	(a5,d1.w),a4			; Get end of line
	
	moveq	#0,d0				; Draw selection
	move.b	(a0),d0
	sub.b	(-(OPT_LINE_LEN-OPT_OPT_LEN+2))(a5),d0
	mulu.w	#OPT_OPT_LEN,d0
	lea	(a5,d0.w),a5
	moveq	#OPT_OPT_LEN-1,d0
	bsr.w	Options_DrawText

	movea.l	a4,a5				; Go to end of line
	rts

; -------------------------------------------------------------------------------
; Generic number option (byte)
; -------------------------------------------------------------------------------

Option_NumberByte:
	move.b	(a5)+,d0			; Get exit code

	cmp.b	options_sel.w,d7		; Is this the currently selected line?
	bne.s	@NoExit				; If not, branch
	
	move.b	v_jpadpress1.w,d1		; Get buttons for exiting with
	andi.b	#$F0,d1				; Should we set the exit code?
	beq.s	@NoExit				; If not, branch

	move.b	d0,options_exit.w		; Set exit code

@NoExit:
	moveq	#-1,d0				; Get variable
	move.w	(a5)+,d0
	move.l	d0,a0

	bsr.w	Options_SelectNumByte		; Handle selection

	moveq	#OPT_LINE_LEN-OPT_OPT_LEN-1,d0	; Draw option
	bsr.w	Options_DrawText

	move.b	(a0),d1				; Draw number
	moveq	#2-1,d5
	bra.w	Options_DrawNumber

; -------------------------------------------------------------------------------
; Generic number option (word)
; -------------------------------------------------------------------------------

Option_NumberWord:
	move.b	(a5)+,d0			; Get exit code

	cmp.b	options_sel.w,d7		; Is this the currently selected line?
	bne.s	@NoExit				; If not, branch
	
	move.b	v_jpadpress1.w,d1		; Get buttons for exiting with
	andi.b	#$F0,d1
	cmpi.b	#3,d0				; Is this a sound test option?
	bne.s	@NotSoundTest			; If not, branch
	andi.b	#$B0,d1				; Omit the A button for the sound test option

@NotSoundTest:
	tst.b	d1				; Should we set the exit code?
	beq.s	@NoExit				; If not, branch

	move.b	d0,options_exit.w		; Set exit code

@NoExit:
	moveq	#-1,d0				; Get variable
	move.w	(a5)+,d0
	move.l	d0,a0

	bsr.w	Options_SelectNumWord		; Handle selection

	moveq	#OPT_LINE_LEN-OPT_OPT_LEN-1,d0	; Draw option
	bsr.w	Options_DrawText

	move.w	(a0),d1				; Draw number
	moveq	#4-1,d5
	bra.w	Options_DrawNumber

; -------------------------------------------------------------------------------
; Level option
; -------------------------------------------------------------------------------

Option_Level:
	addq.w	#1,a5				; Align address

	move.w	(a5)+,d0			; Get level ID
	
	cmp.b	options_sel.w,d7		; Is this the currently selected line?
	bne.s	@NoExit				; If not, branch
	
	move.b	v_jpadpress1.w,d1		; Should we enter the level?
	andi.b	#$F0,d1
	beq.s	@NoExit				; If not, branch
	
	move.w	d0,v_zone.w			; Set level
	move.b	#1,options_exit.w		; Set to exit

@NoExit:
	moveq	#OPT_LINE_LEN-1,d0		; Draw option
	bra.w	Options_DrawText

; -------------------------------------------------------------------------------
; Exit option
; -------------------------------------------------------------------------------

Option_Exit:
	addq.w	#1,a5				; Align address

	cmp.b	options_sel.w,d7		; Is this the currently selected line?
	bne.s	@NoExit				; If not, branch
	
	move.b	v_jpadpress1.w,d1		; Should we enter the level?
	andi.b	#$F0,d1
	beq.s	@NoExit				; If not, branch

	move.b	#4,options_exit.w		; Set to exit

@NoExit:
	moveq	#OPT_LINE_LEN-1,d0		; Draw option
	bra.w	Options_DrawText
	
; -------------------------------------------------------------------------------
; Get options data
; -------------------------------------------------------------------------------
; RETURNS:
;	a5.l	- Pointer to options data
; -------------------------------------------------------------------------------

Options_GetData:
	moveq	#0,d0			; clear d0
	move.b 	(options_mode).w,d0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	@array(pc,d0.w),a5
	rts

@array:
	dc.l 	LevSelData		; options_mode = 0 - Level Select
	dc.l 	OptionsData		; options_mode = 1 - Options Menu
	dc.l 	OptionsData		; options_mode = 1 - Options Menu

; -------------------------------------------------------------------------------
; Handle number option selection (byte)
; -------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Variable
;	a5.l	- Options data
; -------------------------------------------------------------------------------

Options_SelectNumByte:
	cmp.b	options_sel.w,d7		; Is this the currently selected line?
	bne.s	@NoChange			; If not, branch

	btst	#2,v_jpadpress1.w		; Was left pressed?
	beq.s	@NoLeft				; If not, branch
	
	subq.b	#1,(a0)				; Decrement option
	move.b	1(a5),d0			; Are we past the maximum? (If we underflow from
	cmp.b	(a0),d0				; 0 to $FF, we'll wanna jump to the maximum)
	bcs.s	@CapLeft			; If so, branch
	move.b	(a5),d0				; Have we gone past the minimum?
	cmp.b	(a0),d0
	bls.s	@Redraw				; If not, branch

@CapLeft:
	move.b	1(a5),(a0)			; Wrap to the maximum
	bra.s	@Redraw				; Redraw

@NoLeft:
	btst	#3,v_jpadpress1.w		; Was right pressed?
	beq.s	@NoChange			; If not, branch
	
	addq.b	#1,(a0)				; Increment option

@CheckMax:
	move.b	(a5),d0				; Are we past the minimum? (If we overflow from
	cmp.b	(a0),d0				; ($FF to 0, we'll wanna jump to the minimum)
	bcc.s	@CapRight			; If so, branch
	move.b	1(a5),d0			; Have we gone past the maximum?
	cmp.b	(a0),d0
	bcc.s	@Redraw				; If not, branch

@CapRight:
	move.b	(a5),(a0)			; Wrap to the minimum

@Redraw:
	moveq	#1,d2				; Redraw line

@NoChange:
	addq.w	#2,a5				; Move over minimum and maximum values
	rts

; -------------------------------------------------------------------------------
; Handle number option selection (word)
; -------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Variable
;	a5.l	- Options data
; -------------------------------------------------------------------------------

Options_SelectNumWord:
	cmp.b	options_sel.w,d7		; Is this the currently selected line?
	bne.s	@NoChange			; If not, branch

	cmpi.w	#$303,-4(a5)			; Is this a sound test option?
	bne.s	@NotSoundTest			; If not, branch

	btst	#6,v_jpadpress1.w		; Was A pressed?
	beq.s	@NotSoundTest			; If not, branch
	addi.w	#$10,(a0)			; Increment option by $10
	bra.s	@CheckMax			; Check maximum boundary
	
@NotSoundTest:
	btst	#2,v_jpadpress1.w		; Was left pressed?
	beq.s	@NoLeft				; If not, branch
	
	subq.w	#1,(a0)				; Decrement option
	move.w	2(a5),d0			; Are we past the maximum? (If we underflow from
	cmp.w	(a0),d0				; 0 to $FF, we'll wanna jump to the maximum)
	bcs.s	@CapLeft			; If so, branch
	move.w	(a5),d0				; Have we gone past the minimum?
	cmp.w	(a0),d0
	bls.s	@Redraw				; If not, branch

@CapLeft:
	move.w	2(a5),(a0)			; Wrap to the maximum
	bra.s	@Redraw				; Redraw

@NoLeft:
	btst	#3,v_jpadpress1.w		; Was right pressed?
	beq.s	@NoChange			; If not, branch
	
	addq.w	#1,(a0)				; Increment option

@CheckMax:
	move.w	(a5),d0				; Are we past the minimum? (If we overflow from
	cmp.w	(a0),d0				; ($FF to 0, we'll wanna jump to the minimum)
	bcc.s	@CapRight			; If so, branch
	move.w	2(a5),d0			; Have we gone past the maximum?
	cmp.w	(a0),d0
	bcc.s	@Redraw				; If not, branch

@CapRight:
	move.w	(a5),(a0)			; Wrap to the minimum

@Redraw:
	moveq	#1,d2				; Redraw line

@NoChange:
	addq.w	#4,a5				; Move over minimum and maximum values
	rts

; -------------------------------------------------------------------------------
; Check selection for drawing
; -------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w	- Text length - 1
;	d2.b	- Force draw flag
;	d7.b	- Line ID
;	a5.l	- Options data
; RETURNS:
;	d4.w	- Base tile ID
; -------------------------------------------------------------------------------

Options_CheckSel:
	move.w	#$E680,d4			; Unselected color
	
	tst.b	d2				; Are we forcing a redraw?
	bne.s	@ForcedDraw			; If so, branch

	cmp.b	options_sel.w,d7		; Is this the currently selected line?
	bne.s	@NotCurLine			; If not, branch
	cmp.b	options_prev.w,d7		; Was the selection changed to this line?
	beq.s	@DontDraw			; If not, branch
	bra.s	@Selected			; Draw

@NotCurLine:
	cmp.b	options_prev.w,d7		; Was the selection changed from this line?
	beq.s	@Draw				; If not, branch

@ForcedDraw:
	cmp.b	options_sel.w,d7		; Is this the currently selected line?
	bne.s	@Draw				; If not, branch

@Selected:
	move.w	#$C680,d4			; Selected color

@Draw:
	rts

@DontDraw:
	add.w	d0,a5				; Skip over text
	addq.w	#1,a5

	addq.w	#4,sp				; Skip returning to drawing routine
	rts

; -------------------------------------------------------------------------------
; Draw text
; -------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w	- Text length - 1
;	d2.b	- Force draw flag
;	d7.b	- Line ID
;	a5.l	- Options data
;	a6.l	- VDP data port
; -------------------------------------------------------------------------------

Options_DrawText:
	bsr.w	Options_CheckSel		; Check selection

@Draw:
	moveq	#0,d3				; Draw character
	move.b	(a5)+,d3
	add.w	d4,d3
	move.w	d3,(a6)
	dbf	d0,@Draw			; Loop until finished
	rts

; -------------------------------------------------------------------------------
; Draw number
; -------------------------------------------------------------------------------
; PARAMETERS:
;	d1.l	- Number to draw
;	d2.b	- Force draw flag
;	d5.w	- Number of digits - 1
;	d7.b	- Line ID
;	a5.l	- Options data
;	a6.l	- VDP data port
; -------------------------------------------------------------------------------

Options_DrawNumber:
	moveq	#-1,d0				; Check selection
	bsr.w	Options_CheckSel

@Draw:
	move.l	d1,d3				; Copy number

	move.w	d5,d2				; Get number of times to shift
	add.w	d2,d2
	add.w	d2,d2

	lsr.l	d2,d3				; Get digit
	andi.w	#$F,d3
	move.b	@Digits(pc,d3.w),d3

	add.w	d4,d3				; Draw digit
	move.w	d3,(a6)
	dbf	d5,@Draw			; Loop until finished
	rts

; -------------------------------------------------------------------------------

@Digits:
	OPT_TEXT 16,"0123456789ABCDEF"

; -------------------------------------------------------------------------------
; Level select data
; -------------------------------------------------------------------------------

LevSelData:
	OPT_START
	OPT_LEVEL	id_GHZ,	id_Act1,	"GREEN HILL ZONE    ACT 1"
	OPT_LEVEL	id_GHZ,	id_Act2,	"                   ACT 2"
	OPT_LEVEL	id_GHZ,	id_Act3,	"                   ACT 3"
	OPT_LEVEL	id_MZ,	id_Act1,	"MARBLE ZONE        ACT 1"
	OPT_LEVEL	id_MZ,	id_Act2,	"                   ACT 2"
	OPT_LEVEL	id_MZ,	id_Act3,	"                   ACT 3"
	OPT_LEVEL	id_SYZ,	id_Act1,	"SPRING YARD ZONE   ACT 1"
	OPT_LEVEL	id_SYZ,	id_Act2,	"                   ACT 2"
	OPT_LEVEL	id_SYZ,	id_Act3,	"                   ACT 3"
	OPT_LEVEL	id_LZ,	id_Act1,	"LABYRINTH ZONE     ACT 1"
	OPT_LEVEL	id_LZ,	id_Act2,	"                   ACT 2"
	OPT_LEVEL	id_LZ,	id_Act3,	"                   ACT 3"
	OPT_LEVEL	id_SLZ,	id_Act1,	"STAR LIGHT ZONE    ACT 1"
	OPT_LEVEL	id_SLZ,	id_Act2,	"                   ACT 2"
	OPT_LEVEL	id_SLZ,	id_Act3,	"                   ACT 3"
	OPT_LEVEL	id_SBZ,	id_Act1,	"SCRAP BRAIN ZONE   ACT 1"
	OPT_LEVEL	id_SBZ,	id_Act2,	"                   ACT 2"
	OPT_LEVEL	id_LZ,	id_Act4,	"                   ACT 3"
	OPT_LEVEL	id_SBZ,	id_Act3,	"FINAL ZONE"
	OPT_NUM_BYTE	v_lastspecial, 0, Emerald_Max-1, 2,		&
				"SPECIAL STAGE"
	OPT_NUM_BYTE	options_sound, $81, SFXoff+SFXcount-1, 3,	&
				"SOUND TEST"
	OPT_BYTE	v_difficulty, 0, 4,				&
			"DIFFICULTY",		"ORIGINAL", "EASY", "NORMAL", "REV00", "REV01"
	OPT_BIT 	v_options, bit_EasyOrder,			&
			"EASY LEVEL ORDER",		"ON", "OFF"
	OPT_END
			even

; -------------------------------------------------------------------------------
; Options data
; -------------------------------------------------------------------------------

OptionsData:
	OPT_START
	OPT_BYTE	v_difficulty, 0, 4,				&
			"DIFFICULTY",		"ORIGINAL", "EASY", "NORMAL", "REV00", "REV01"
	OPT_BIT 	v_options, bit_EasyOrder,			&
			"EASY LEVEL ORDER",		"ON", "OFF"
	OPT_BIT 	v_options, bit_Spindash,			&
			"SPINDASH",		"OFF", "ON"
	OPT_BIT		v_options, bit_TimeOver,			&
			"TIMEOVER",		"OFF", "ON"
	OPT_BIT		v_options, bit_SpikeBug,			&
			"SPIKE BEHAVIOR",	"ORIGINAL", "JAM"
	OPT_NUM_BYTE	options_sound, $81, SFXoff+SFXcount-1, 3,	&
				"SOUND TEST"
	OPT_EXIT	"SAVE AND EXIT"
	OPT_NOTE	""
	OPT_NOTE	"ORIGINAL IS JUST"
	OPT_NOTE	"REVISION 1 WITH A FIX FOR"
	OPT_NOTE	"SLZ2 TOP PATH TO PREVENT"
	OPT_NOTE	"JUMPING OVER THE LEVEL"
	OPT_END
			even

; -------------------------------------------------------------------------------
