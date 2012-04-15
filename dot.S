; DigiWatch Dot Control Procedures
; (c) Kristian Klomsten Skordal 2012 <kristian.skordal@gmail.com>
; Report bugs and issues on <http://github.com/skordal/digiwatch/issues>

#include <avr/io.h>

; The "dot" is the dot that separates hours and minutes. It is toggled once
; every second to indicate that the clock is running.
.section .text

; Initializes the dot, by enabling the dot output port:
.global dot_init
dot_init:
	sbi _SFR_IO_ADDR(DDRD), DDD6
	cbi _SFR_IO_ADDR(PORTD), PORTD6
	ret

; Turns on the dot:
.global dot_on
dot_on:
	sbi _SFR_IO_ADDR(PORTD), PORTD6
	ret

; Turns off the dot:
.global dot_off
dot_off:
	cbi _SFR_IO_ADDR(PORTD), PORTD6
	ret

; Toggles the dot:
.global dot_toggle
dot_toggle:
	sbi _SFR_IO_ADDR(PIND), PORTD6
	ret

