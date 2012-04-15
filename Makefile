# DigiWatch Makefile
# (c) Kristian Klomsten Skordal 2012 <kristian.skordal@gmail.com>
# Report bugs and issues on <http://github.com/skordal/digiwatch/issues>

# Build tools:
TOOL_PREFIX ?= avr-

CC      := $(TOOL_PREFIX)gcc
LD      := $(TOOL_PREFIX)ld
OBJCOPY := $(TOOL_PREFIX)objcopy

# Build flags:
CFLAGS  += -mmcu=attiny2313
LDFLAGS +=

# Objects to build:
OBJECTS := display.o dot.o interrupts.o start.o

.PHONY: all clean

all: $(OBJECTS)
	$(LD) $(LDFLAGS) -T digiwatch.ld -o digiwatch.elf $(OBJECTS)
	$(OBJCOPY) -O ihex -j .text digiwatch.elf digiwatch.hex

upload: all
	avrdude -c stk500 -p t2313 -P /dev/ttyACM0 -e -U flash:w:digiwatch.hex

clean:
	-$(RM) $(OBJECTS)
	-$(RM) digiwatch.elf digiwatch.hex

display.o: display.S
	$(CC) -c $(CFLAGS) -o display.o display.S

dot.o: dot.S
	$(CC) -c $(CFLAGS) -o dot.o dot.S

interrupts.o: interrupts.S
	$(CC) -c $(CFLAGS) -o interrupts.o interrupts.S

start.o: start.S
	$(CC) -c $(CFLAGS) -o start.o start.S

