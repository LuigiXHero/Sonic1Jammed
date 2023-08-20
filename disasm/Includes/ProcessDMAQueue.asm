; ---------------------------------------------------------------------------
; Subroutine for queueing VDP commands (seems to only queue transfers to VRAM),
; to be issued the next time ProcessDMAQueue is called.
; Can be called a maximum of 18 times before the buffer needs to be cleared
; by issuing the commands (this subroutine DOES check for overflow)
; ---------------------------------------------------------------------------
; In case you wish to use this queue system outside of the spin dash, this is the
; registers in which it expects data in:
; d1.l: Address to data (In 68k address space)
; d2.w: Destination in VRAM
; d3.w: Length of data
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_144E: DMA_68KtoVRAM: QueueCopyToVRAM: QueueVDPCommand: Add_To_DMA_Queue:
QueueDMATransfer:
		movea.l	($FFFFC8FC).w,a1
		cmpa.w	#$C8FC,a1
		beq.s	QueueDMATransfer_Done ; return if there's no more room in the buffer

		; piece together some VDP commands and store them for later...
		move.w	#$9300,d0 ; command to specify DMA transfer length & $00FF
		move.b	d3,d0
		move.w	d0,(a1)+ ; store command

		move.w	#$9400,d0 ; command to specify DMA transfer length & $FF00
		lsr.w	#8,d3
		move.b	d3,d0
		move.w	d0,(a1)+ ; store command

		move.w	#$9500,d0 ; command to specify source address & $0001FE
		lsr.l	#1,d1
		move.b	d1,d0
		move.w	d0,(a1)+ ; store command

		move.w	#$9600,d0 ; command to specify source address & $01FE00
		lsr.l	#8,d1
		move.b	d1,d0
		move.w	d0,(a1)+ ; store command

		move.w	#$9700,d0 ; command to specify source address & $FE0000
		lsr.l	#8,d1
		move.b	d1,d0
		move.w	d0,(a1)+ ; store command

		andi.l	#$FFFF,d2 ; command to specify destination address and begin DMA
		lsl.l	#2,d2
		lsr.w	#2,d2
		swap	d2
		ori.l	#$40000080,d2 ; set bits to specify VRAM transfer
		move.l	d2,(a1)+ ; store command

		move.l	a1,($FFFFC8FC).w ; set the next free slot address
		cmpa.w	#$C8FC,a1
		beq.s	QueueDMATransfer_Done ; return if there's no more room in the buffer
		move.w	#0,(a1) ; put a stop token at the end of the used part of the buffer
; return_14AA:
QueueDMATransfer_Done:
		rts
; End of function QueueDMATransfer


; ---------------------------------------------------------------------------
; Subroutine for issuing all VDP commands that were queued
; (by earlier calls to QueueDMATransfer)
; Resets the queue when it's done
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_14AC: CopyToVRAM: IssueVDPCommands: Process_DMA: Process_DMA_Queue:
ProcessDMAQueue:
		lea	($C00004).l,a5
		lea	($FFFFC800).w,a1
; loc_14B6:
ProcessDMAQueue_Loop:
		move.w	(a1)+,d0
		beq.s	ProcessDMAQueue_Done ; branch if we reached a stop token
		; issue a set of VDP commands...
		move.w	d0,(a5)		; transfer length
		move.w	(a1)+,(a5)	; transfer length
		move.w	(a1)+,(a5)	; source address
		move.w	(a1)+,(a5)	; source address
		move.w	(a1)+,(a5)	; source address
		move.w	(a1)+,(a5)	; destination
		move.w	(a1)+,(a5)	; destination
		cmpa.w	#$C8FC,a1
		bne.s	ProcessDMAQueue_Loop ; loop if we haven't reached the end of the buffer
; loc_14CE:
ProcessDMAQueue_Done:
		move.w	#0,($FFFFC800).w
		move.l	#$FFFFC800,($FFFFC8FC).w
		rts
; End of function ProcessDMAQueue