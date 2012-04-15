; DigiWatch Display Control Procedures
; (c) Kristian Klomsten Skordal 2012 <kristian.skordal@gmail.com>
; Report bugs and issues on <http://github.com/skordal/digiwatch/issues>

#include <avr/io.h>
#include "registers.h"

; The procedures in this file controls the number displays.
.section .text

; Mask for the pins controlling BCD output to the displays:
#define BCD_MASK 0x0f
; Mask for the port controlling power to the displays:
#define LCD_MASK 0xf0

# Clock multiplier, for speedy testing:
#define CLOCK_MULTIPLIER 1

; Counter value for the refresh timer:
#define REFRESH_COUNTER_VALUE 195
; Counter value for the clock counter:
#define CLOCK_COUNTER_VALUE 39063 / CLOCK_MULTIPLIER

; This procedure initializes the displays by setting up the output port
; properly.
.global display_init
display_init:
	; Set port B to output:
	ser r16
	out _SFR_IO_ADDR(DDRB), r16

	; Make sure nothing is on the port before we begin:
	clr r16
	out _SFR_IO_ADDR(PORTB), r16

	; Clear the clock value registers:
	ldi r16, 0x00
	mov SECONDS_REGISTER, r16
	mov MINUTES_REGISTER, r16
	mov HOURS_REGISTER, r16

	; Set up the display mask:
	ldi r16, 0x11
	mov DISPLAY_MASK_REGISTER, r16

	; Set up the refresh timer:
	ldi r16, _BV(WGM01)
	out _SFR_IO_ADDR(TCCR0A), r16
	ldi r16, _BV(CS02)
	out _SFR_IO_ADDR(TCCR0B), r16

	; Set the counter value:
	ldi r16, REFRESH_COUNTER_VALUE
	out _SFR_IO_ADDR(OCR0A), r16

	; Set up the clock timer:
	ldi r16, _BV(CS12)|_BV(WGM12)
	out _SFR_IO_ADDR(TCCR1B), r16

	; Set the counter value:
	ldi r16, CLOCK_COUNTER_VALUE & 0xff
	ldi r17, CLOCK_COUNTER_VALUE >> 8
	out _SFR_IO_ADDR(OCR1AH), r17
	out _SFR_IO_ADDR(OCR1AL), r16

	; Enable the timer interrupts:
	ldi r16, _BV(OCIE0A)|_BV(OCIE1A)
	out _SFR_IO_ADDR(TIMSK), r16

	ret

; Interrupt handler for refreshing the displays:
.global display_refresh_handler
display_refresh_handler:
	; Change the active display by rotating the display mask left:
	lds r16, current_display_mask
	mov r17, r16
	lsl r16
	sbrc r17, 7
	ori r16, 1
	sts current_display_mask, r16

	; Set the BCD value for the current display:

	; Right second display:
	sbrc r16, 0
	mov r17, MINUTES_REGISTER

	; Left second display:
	sbrc r16, 1
	mov r17, MINUTES_REGISTER
	sbrc r16, 1
	swap r17

	; Right hour display:
	sbrc r16, 2
	mov r17, HOURS_REGISTER

	; Left hour display:
	sbrc r16, 3
	mov r17, HOURS_REGISTER
	sbrc r16, 3
	swap r17

	; Set the output port values:
	andi r16, LCD_MASK
	andi r17, BCD_MASK
	or r16, r17
	out _SFR_IO_ADDR(PORTB), r16

	reti

; Interrupt handler for updating the clock:
.global clock_tick_handler
clock_tick_handler:
	rcall dot_toggle

	; Increase the second register:
	inc SECONDS_REGISTER
	mov r16, SECONDS_REGISTER
	cpi r16, 60
	brne 3f

	clr SECONDS_REGISTER

	; Load the clock registers into high registers:
	mov r16, MINUTES_REGISTER
	mov r17, HOURS_REGISTER

	; Add a minute:
	inc r16

	; Check if a BCD number "overflows":
	mov r18, r16
	andi r18, 0x0f
	cpi r18, 10

	andi r16, 0xf0	; Preserve the 10's
	or r16, r18	; Or the 1's with the 10's
	brlo 2f

	; Overflow occurred, clear the ones and add one to the tens:
	mov r18, r16
	andi r18, 0xf0
	ldi r19, 0x10
	add r18, r19
	cpi r18, 0x60
	mov r16, r18
	brlo 2f

	; Overflow occurred again, clear the minutes and add one to the hours:
	clr r16

	inc r17	; Add an hour to the hour counter

	; Check for 24:
	cpi r17, 0x24
	brne 1f

	clr r17
	clr r16
	rjmp 2f

1:
	; Check for overflows, same procedure as for the minutes above:
	mov r18, r17
	andi r18, 0x0f
	cpi r18, 10

	andi r17, 0xf0
	or r17, r18
	brlo 2f

	; If overflow, add one to the hour 10's:
	mov r18, r17
	andi r18, 0xf0
	ldi r19, 0x10
	add r18, r19
	mov r17, r18

2:
	mov MINUTES_REGISTER, r16
	mov HOURS_REGISTER, r17
3:
	reti

.section .bss

; Mask indicating which display is currently active:
current_display_mask:
	.skip 1

