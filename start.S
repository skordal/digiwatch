; DigiWatch Start Code
; (c) Kristian Klomsten Skordal 2012 <kristian.skordal@gmail.com>
; Report bugs and issues on <http://github.com/skordal/digiwatch/issues>

#include <avr/io.h>

; Application entry point. The start procedure runs all initialization
; procedures neccessary. It then enters the main loop, which just sleeps.
.global start
start:
	; Make sure interrupts are disabled until we choose to enable them:
	cli

	; Set up the stack pointer:
	ldi r16, RAMEND & 0xff
	out _SFR_IO_ADDR(SPL), r16

	; Initialize the "dot":
	rcall dot_init
	rcall dot_on

	; Initialize the number display:
	rcall display_init

	sei

main_loop:
	rjmp main_loop

