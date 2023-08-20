; ---------------------------------------------------------------------------
; Title	screen
; ---------------------------------------------------------------------------

GM_Title:
		play.b	1, bsr.w, cmd_Stop			; stop music
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut				; fade from previous gamemode to black
		disable_ints
		bsr.w	DacDriverLoad
		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)				; normal colour mode
		move.w	#$8200+(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)		; set background nametable address
		move.w	#$9001,(a6)				; 64x32 cell plane size
		move.w	#$9200,(a6)				; window vertical position 0 (i.e. disabled)
		move.w	#$8B03,(a6)				; single pixel line horizontal scrolling
		move.w	#$8720,(a6)				; set background colour (palette line 2, entry 0)
		clr.b	(f_water_pal_full).w
		bsr.w	ClearScreen

		lea	(v_ost_all).w,a1
		moveq	#0,d0
		move.w	#((sizeof_ost*countof_ost)/4)-1,d1

	@clear_ost:
		move.l	d0,(a1)+
		dbf	d1,@clear_ost				; fill OST ($D000-$EFFF) with 0

		locVRAM	0
		lea	(Nem_JapNames).l,a0			; load Japanese credits
		bsr.w	NemDec
		locVRAM	vram_title_credits			; $14C0
		lea	(Nem_CreditText).l,a0			; load alphabet
		bsr.w	NemDec
		lea	($FF0000).l,a1
		lea	(Eni_JapNames).l,a0			; load mappings for Japanese credits
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,vram_fg,0,0,$28,$1C	; copy Japanese credits mappings to fg nametable in VRAM

		lea	(v_pal_dry_next).w,a1
		moveq	#cBlack,d0
		move.w	#(sizeof_pal_all/4)-1,d1

	@clear_pal:
		move.l	d0,(a1)+
		dbf	d1,@clear_pal				; fill palette with 0 (black)

		moveq	#id_Pal_Sonic,d0			; load Sonic's palette
		bsr.w	PalLoad_Next				; palette will be shown after fading in
		move.b	#id_CreditsText,(v_ost_credits).w	; load "SONIC TEAM PRESENTS" object
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		bsr.w	PaletteFadeIn				; fade in to "SONIC TEAM PRESENTS" screen from black
		disable_ints

		locVRAM	vram_title
		lea	(Nem_TitleFg).l,a0			; load title screen gfx
		bsr.w	NemDec
		locVRAM	vram_title_sonic
		lea	(Nem_TitleSonic).l,a0			; load Sonic title screen gfx
		bsr.w	NemDec
		locVRAM	vram_title_tm
		lea	(Nem_TitleTM).l,a0			; load "TM" gfx
		bsr.w	NemDec
		lea	(vdp_data_port).l,a6
		locVRAM	vram_text2,4(a6)
		lea	(Art_Text2).l,a5			; load level select font
		move.w	#(sizeof_art_text2/2)-1,d1

	@load_text:
		move.w	(a5)+,(a6)
		dbf	d1,@load_text				; load level select font

		move.b	#0,(v_last_lamppost).w			; clear lamppost counter
		move.w	#0,(v_debug_active).w			; disable debug item placement mode
		move.w	#0,(v_demo_mode).w			; disable debug mode
		move.w	#0,(v_title_unused).w			; unused variable
		move.b 	#0,(v_titleprog).w 			; Clear Title Progression
		move.w	#id_GHZ_act1,(v_zone).w			; set level to GHZ act 1 (0000)
		move.w	#0,(v_palcycle_time).w			; disable palette cycling
		if Released=0
		move.w	#$0101,(f_levelselect_cheat).w
		move.w	#$0101,(f_debug_cheat).w
		endif
		bsr.w	LevelParameterLoad			; set level boundaries and Sonic's start position
		bsr.w	DeformLayers
		lea	(v_16x16_tiles).w,a1
		lea	(Blk16_GHZ).l,a0			; load GHZ 16x16 mappings
		move.w	#0,d0
		bsr.w	EniDec
		lea	(Blk256_GHZ).l,a0			; load GHZ 256x256 mappings
		lea	(v_256x256_tiles).l,a1
		bsr.w	KosDec
		bsr.w	LevelLayoutLoad				; load GHZ1 level layout including background
		bsr.w	PaletteFadeOut				; fade out "SONIC TEAM PRESENTS" screen to black
		disable_ints
		bsr.w	ClearScreen
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_bg1_x_pos).w,a3
		lea	(v_level_layout+level_max_width).w,a4	; background layout start address ($FFFFA440)
		move.w	#draw_bg,d2
		bsr.w	DrawChunks				; draw background
		lea	($FF0000).l,a1
		lea	(Eni_Title).l,a0			; load title screen mappings
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,vram_fg,3,4,$22,$16	; copy title screen mappings to fg nametable in VRAM

		locVRAM	0
		lea	(Nem_GHZ_1st).l,a0			; load GHZ patterns
		bsr.w	NemDec
		moveq	#id_Pal_Title,d0			; load title screen palette
		bsr.w	PalLoad_Next
		play.b	1, bsr.w, mus_TitleScreen		; play title screen music
		move.b	#0,(f_debug_enable).w			; disable debug mode
		move.w	#$178,(v_countdown).w			; run title screen for $178 frames
		lea	(v_ost_psb).w,a1
		moveq	#0,d0
		move.w	#7,d1					; should be $F; 7 only clears half the OST

	@clear_ost_psb:
		move.l	d0,(a1)+
		dbf	d1,@clear_ost_psb

		move.b	#id_TitleSonic,(v_ost_titlesonic).w	; load big Sonic object
		move.b	#id_PSBTM,(v_ost_psb).w			; load "PRESS START BUTTON" object
		clr.b	(v_ost_psb+ost_routine).w		; The 'Mega Games 10' version of Sonic 1 added this line, to fix the "PRESS START BUTTON" object not appearing

		if Revision=0
		else
			tst.b   (v_console_region).w		; is console Japanese?
			bpl.s   @isjap				; if yes, branch
		endc

		move.b	#id_PSBTM,(v_ost_tm).w			; load "TM" object
		move.b	#id_frame_psb_tm,(v_ost_tm+ost_frame).w
	@isjap:
		move.b	#id_PSBTM,(v_ost_titlemask).w		; load object which hides part of Sonic
		move.b	#id_frame_psb_mask,(v_ost_titlemask+ost_frame).w
		jsr	(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr	(BuildSprites).l
		moveq	#id_PLC_Main,d0				; load lamppost, HUD, lives, ring & points graphics
		bsr.w	NewPLC					; do it over the next few frames
		move.w	#0,(v_title_d_count).w			; reset d-pad counter
		move.w	#0,(v_title_c_count).w			; reset C button counter
		enable_display
		bsr.w	PaletteFadeIn				; fade in to title screen from black

; ---------------------------------------------------------------------------
; Title	screen main loop
; ---------------------------------------------------------------------------

Title_MainLoop:
		move.b	#id_VBlank_Title,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		jsr	(ExecuteObjects).l			; run all objects
		bsr.w	DeformLayers				; scroll background
		jsr	(BuildSprites).l			; create sprite table
		bsr.w	PCycle_Title				; animate water palette
		bsr.w	RunPLC					; trigger decompression of items in PLC buffer
		move.w	(v_ost_player+ost_x_pos).w,d0		; x pos of dummy object (there is no actual object loaded)
		addq.w	#2,d0
		move.w	d0,(v_ost_player+ost_x_pos).w		; move dummy 2px to the right
		cmpi.w	#$1C00,d0
		blo.s	Title_Cheat				; branch if dummy is still left of $1C00

		move.b	#id_Sega,(v_gamemode).w			; go to Sega screen (takes approx. 1 min for dummy to reach $1C00)
		rts	
; ===========================================================================

Title_Cheat:
		tst.b	(v_console_region).w			; check	if the machine is US/EU or Japanese
		bpl.s	@japanese				; if Japanese, branch

		lea	(LevSelCode_US).l,a0			; load US/EU code
		bra.s	@overseas

	@japanese:
		lea	(LevSelCode_J).l,a0			; load JP code

	@overseas:
		move.w	(v_title_d_count).w,d0			; get number of times d-pad has been pressed in correct order
		adda.w	d0,a0					; jump to relevant position in sequence
		move.b	(v_joypad_press_actual).w,d0		; get button press
		andi.b	#btnDir,d0				; read only UDLR buttons
		cmp.b	(a0),d0					; does button press match the cheat code?
		bne.s	@reset_cheat				; if not, branch
		addq.w	#1,(v_title_d_count).w			; next button press
		tst.b	d0					; is d-pad currently pressed?
		bne.s	@count_c				; if yes, branch

		lea	(f_levelselect_cheat).w,a0		; cheat flag array
		move.w	(v_title_c_count).w,d1			; d1 = number of times C was pressed
		lsr.w	#1,d1					; divide by 2
		andi.w	#3,d1					; read only bits 0/1
		beq.s	@levelselect_only			; branch if 0
		tst.b	(v_console_region).w
		bpl.s	@levelselect_only			; branch if region is Japanese
		moveq	#1,d1
		move.b	d1,1(a0,d1.w)				; enable debug mode (C is pressed 2 or more times)

	@levelselect_only:
		move.b	#1,(a0,d1.w)				; activate cheat: no C = level select; CC+ = slowmo (US/EU); CC = slowmo (JP); CCCC = debug (JP); CCCCCC = hidden credits (JP)
		play.b	1, bsr.w, sfx_Ring			; play ring sound when code is entered
		bra.s	@count_c
; ===========================================================================

@reset_cheat:
		tst.b	d0					; is d-pad currently pressed?
		beq.s	@count_c				; if not, branch
		cmpi.w	#9,(v_title_d_count).w
		beq.s	@count_c
		move.w	#0,(v_title_d_count).w			; reset UDLR counter

@count_c:
		move.b	(v_joypad_press_actual).w,d0
		andi.b	#btnC,d0				; is C button pressed?
		beq.s	@c_not_pressed				; if not, branch
		addq.w	#1,(v_title_c_count).w			; increment C counter

	@c_not_pressed:
		cmpi.b 	#1,(v_titleprog).w	; Check if we pressed start already
		beq.w 	@skipdemo 			; if yes, branch

		tst.w	(v_countdown).w				; has counter hit 0? (started at $178)
		beq.w	PlayDemo				; if yes, branch

@skipdemo:
		andi.b	#btnStart,(v_joypad_press_actual).w	; check if Start is pressed
		beq.w	Title_MainLoop				; if not, branch

		cmpi.b 	#1,(v_titleprog).w	; Check if we pressed start already
		beq.w 	Title_S2MenuStuff 			; if yes, branch

		move.b 	#1,(v_titleprog).w 		; set it
		clr.b	(v_ost_psb+ost_id).w 		; clear "PRESS START BUTTON" object
		move.b	#id_frame_psb_mask2,(v_ost_titlemask+ost_frame).w ; Fix this bitch
		move.b	#id_TitleMenu,(v_ost_titlemenu+ost_id).w 	; load S2 Menu
		bra.w	Title_MainLoop			; loop

Title_S2MenuStuff:
		moveq	#0,d0
		move.b	v_titlemenu.w,d0
		add.w	d0,d0
		add.w	d0,d0
		jmp	@TitleModes(pc,d0.w)

@TitleModes:
		bra.w	Title_StartGame			; 0
		bra.w	Title_Options			; 2

Title_StartGame:
		clr.w	v_zone.w			; set to GHZ
		bra.s 	Title_PressedStart

Title_Options:
		tst.b	(f_levselcheat).w		; check	if level select	code is	on
		beq.w	@DoMenu				; if not, goto options
		btst	#bitA,(v_joypad_hold_actual).w 	; check if A is held
		bne.w	Title_DoLevelSelect		; if yes, goto level select

@DoMenu:
		move.b	#1,options_mode.w
		bra.s	Title_DoLevelSelect2

Title_PressedStart:
		tst.b	(f_levelselect_cheat).w			; check if level select code is on
		beq.w	PlayLevel				; if not, play level
		btst	#bitA,(v_joypad_hold_actual).w		; check if A is pressed
		beq.w	PlayLevel				; if not, play level

Title_DoLevelSelect:
		clr.b	options_mode.w

Title_DoLevelSelect2:
		clr.b	(v_ost_titlemenu+ost_id).w 		; clear S2 menu object
		jsr 	ExecuteObjects
		jsr 	BuildSprites

		jmp	Options

; ===========================================================================

LevSel_Ending:
		move.b	#id_Ending,(v_gamemode).w		; set gamemode to $18 (Ending)
		move.w	#id_EndZ_good,(v_zone).w		; set level to 0600 (Ending)
		rts	
; ===========================================================================

LevSel_Credits:
		move.b	#id_Credits,(v_gamemode).w		; set gamemode to $1C (Credits)
		play.b	1, bsr.w, mus_Credits			; play credits music
		move.w	#0,(v_credits_num).w
		rts	
; ===========================================================================

LevSel_Level_SS:
		rts	
; ===========================================================================

LevSel_Level:
		andi.w	#$3FFF,d0
		move.w	d0,(v_zone).w				; set level number

PlayLevel:
		move.b	#id_Level,(v_gamemode).w		; set gamemode to $0C (level)
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.b	d0,(v_last_ss_levelid).w		; clear special stage number
		move.b	d0,(v_emeralds).w			; clear emeralds
		move.l	d0,(v_emerald_list).w			; clear emeralds
		move.l	d0,(v_emerald_list+4).w			; clear emeralds
		move.b	d0,(v_continues).w			; clear continues
		if Revision=0
		else
			move.l	#5000,(v_score_next_life).w	; extra life is awarded at 50000 points
		endc
		play.b	1, bsr.w, cmd_Fade			; fade out music
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select codes
; ---------------------------------------------------------------------------
LevSelCode_J:	if Revision=0
		dc.b btnUp,btnDn,btnL,btnR,0,$FF
		else
		dc.b btnUp,btnDn,btnDn,btnDn,btnL,btnR,0,$FF
		endc
		even

LevSelCode_US:	dc.b btnUp,btnDn,btnL,btnR,0,$FF
		even

; ---------------------------------------------------------------------------
; Demo mode
; ---------------------------------------------------------------------------

PlayDemo:
		move.w	#30,(v_countdown).w			; set delay to half a second

@loop_delay:
		move.b	#id_VBlank_Title,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bsr.w	DeformLayers
		bsr.w	PaletteCycle
		bsr.w	RunPLC
		move.w	(v_ost_player+ost_x_pos).w,d0		; dummy object x pos
		addq.w	#2,d0					; increment
		move.w	d0,(v_ost_player+ost_x_pos).w		; update
		cmpi.w	#$1C00,d0				; has dummy object reached $1C00?
		blo.s	@chk_start				; if not, branch
		move.b	#id_Sega,(v_gamemode).w			; goto Sega screen
		rts	
; ===========================================================================

@chk_start:
		andi.b	#btnStart,(v_joypad_press_actual).w	; is Start button pressed?
		bne.w	Title_PressedStart			; if yes, branch
		tst.w	(v_countdown).w				; has delay timer hit 0?
		bne.w	@loop_delay				; if not, branch

		play.b	1, bsr.w, cmd_Fade			; fade out music
		move.w	(v_demo_num).w,d0			; load demo number
		andi.w	#7,d0
		add.w	d0,d0
		move.w	DemoLevelArray(pc,d0.w),d0		; load level number for	demo
		move.w	d0,(v_zone).w
		addq.w	#1,(v_demo_num).w			; add 1 to demo number
		cmpi.w	#4,(v_demo_num).w			; is demo number less than 4?
		blo.s	@demo_0_to_3				; if yes, branch
		move.w	#0,(v_demo_num).w			; reset demo number to	0

	@demo_0_to_3:
		move.w	#1,(v_demo_mode).w			; turn demo mode on
		move.b	#id_Demo,(v_gamemode).w			; set screen mode to 08 (demo)
		cmpi.w	#id_Demo_SS,d0				; is level number 0600 (special	stage)?
		bne.s	@demo_level				; if not, branch
		move.b	#id_Special,(v_gamemode).w		; set screen mode to $10 (Special Stage)
		clr.w	(v_zone).w				; clear	level number
		clr.b	(v_last_ss_levelid).w			; clear special stage number

	@demo_level:
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		if Revision=0
		else
			move.l	#5000,(v_score_next_life).w	; extra life is awarded at 50000 points
		endc
		rts	

		include_demo_list				; Includes\Demo Pointers.asm
