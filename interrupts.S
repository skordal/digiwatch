; DigiWatch Interrupt Vector Table
; (c) Kristian Klomsten Skordal 2012 <kristian.skordal@gmail.com>
; Report bugs and issues on <http://github.com/skordal/digiwatch/issues>

interrupt_vectors:
	rjmp start			; RESET
	reti				; INT0
	reti				; INT1
	reti				; TIMER1 CAPT
	rjmp clock_tick_handler		; TIMER1 COMPA
	reti				; TIMER1 OVF
	reti				; TIMER0 OVF
	reti				; USART0, RX
	reti				; USART0, UDRE
	reti				; USART0, TX
	reti				; ANALOG COMP
	reti				; PCINT
	reti				; TIMER1 COMPB
	rjmp display_refresh_handler	; TIMER0 COMPA
	reti				; TIMER0 COMPB
	reti				; USI START
	reti				; USI OVERFLOW
	reti 				; EE READY
	reti				; WDT OVERFLOW

