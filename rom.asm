; smallest rom ever
; features: merged code and header
exreset	equ	0

romstart:
	dc.l	$0
	dc.l	start
	rept	20
	dc.l	fault
	endr
	dc.l	extint
	dc.l	fault
	dc.l	hblank
	dc.l	fault
	dc.l	vblank
	dc.l	fault

hblank:
	tst.b	$FF0005
	bne.s	.exit
	add.b	#1, $FF0000
.exit	rte

vblank:
	st	$FF0005
	add.b	#1, $FF0004
	clr.b	$FF0005
	rte

initz80:
	move.w	#$100, (a1)
	move.w	#$100, $100(a1)

waitz80:
	btst	#$0, (a1)
	bne.s	waitz80
	lea	z80code, a2
	lea	$A10000, a3
	move.w	#$25, d1

z80loop:
	move.b	(a2)+, (a3)+
	dbf	d1, z80loop
	bra.s	z80end

z80code:
	dc.b	$AF			; xor	a
	dc.b	$01, $D9, $1F		; ld	bc, 1fd9h
	dc.b	$11, $27, $00		; ld	de, 0027h
	dc.b	$21, $26, $00		; ld	hl, 0026h
	dc.b	$F9			; ld	sp, hl
	dc.b	$77			; ld	(hl), a
	dc.b	$ED, $B0		; ldir
	dc.b	$DD, $E1		; pop	ix
	dc.b	$FD, $E1		; pop	iy
	dc.b	$ED, $47		; ld	i, a
	dc.b	$ED, $4F		; ld	r, a
	dc.b	$D1			; pop	de
	dc.b	$E1			; pop	hl
	dc.b	$F1			; pop	af
	dc.b	$08			; ex	af, af'
	dc.b	$D9			; exx
	dc.b	$C1			; pop	bc
	dc.b	$D1			; pop	de
	dc.b	$E1			; pop	hl
	dc.b	$F1			; pop	af
	dc.b	$F9			; ld	sp, hl
	dc.b	$F3			; di
	dc.b	$ED, $56		; im	1
	dc.b	$36, $E9		; ld	(hl), e9h
	dc.b	$E9			; jp	(hl)

z80end:
	move.w	#$0, (a1)
	move.w	#$0, $100(a1)
	bra.w	cont

start:					; also the rom header
	move.w	#$2700, sr
	move.b	$A10001, d0
	andi.b	#$F, d0
	beq.s	notmss
	move.l	#"SEGA", $A14000	; "SEGA" @ $100 in rom

extint	rte

notmss:
	clr.l	$FF0000
	clr.l	$FF0004
	bra.w	setup

fault:
	if	exreset
	suba.l	a7, a7
	bra.w	start
	else
	move.w	#$2700, sr
	bra.s	*
	endif

setup:
	lea	$C00000, a0
	lea	$A11100, a1
	move.w	4(a0), d0
	clr.l	d0
	clr.l	d1
	move.l	#$80048114, 4(a0)
	move.l	#$82308340, 4(a0)
	move.l	#$8407856A, 4(a0)
	bra.w	.stay
	dc.b	"A TESTAMENT TO H"	; international name
	dc.b	"OW SMALL IN SIZE"	
	dc.b	" A ROM COULD BE!"
	dc.b	"FU FUCK-OFF-00"	; product no.
	dc.w	$0			; checksum
.stay	move.w	#$8F02, 4(a0)
	move.l	#$86008700, 4(a0)
	move.l	#$8A008B08, 4(a0)
	move.l	#$8C898D34, 4(a0)
	move.l	#$8E008F02, 4(a0)
	bra.w	.stay2
	nop
	nop
	nop
	rept	3
	dc.l	$20202020
	endr
.stay2	move.l	#$90019200, 4(a0)
	move.l	#$93009400, 4(a0)
	move.l	#$95009700, 4(a0)
	bra.w	initz80

cont:
	lea	$C00011, a4
	bra.s	.stay
	dc.b	"JUE "			; region
.stay	move.b	#$9F, (a4)
	move.b	#$BF, (a4)
	move.b	#$DF, (a4)
	move.b	#$FF, (a4)

clearcram:
	clr.l	d0
	clr.l	d1
	move.l	#$C0000000, 4(a0)
	move.b	#$3F, d0
.loop	move.l	d1, (a0)
	dbf	d0, .loop

clearvram:
	move.l	#$40000000, 4(a0)
	move.w	#$3FFF, d0
.loop	move.l	d1, (a0)
	dbf	d0, .loop

clearvsram:
	move.l	#$40000010, 4(a0)	; vsram write
	move.w	#$10, d0
.loop	move.l	d1, (a0)
	dbf	d0, .loop

main:
	clr.l	d0			; clear d0
	move.w	#$8F00, 4(a0)		; always assume word increment = 0
	move.l	#$C0000003, 4(a0)	; cram write mode
		
main_loop:
	move.w	d0, (a0)		; write prev value (if loop >=1)
	add.w	#1, d0			; add one to change colour
	move.w	#100, d1		; how long to delay?

main_wait:
	dbf	d1, main_wait		; coded like this for extra delay
	bra	main_loop		; should give us a (mostly) straight line
	dc.b	"succ"			; hello there
	end
