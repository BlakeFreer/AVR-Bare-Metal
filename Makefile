HEX_FILE = $(word 2, $(MAKECMDGOALS))

ifeq ($(word 1, $(MAKECMDGOALS)), burn)
  ifeq ($(HEX_FILE),)
    $(error Usage: make burn <HEX_FILE>)
  endif
endif

C_FILE = $(basename $(HEX_FILE)).c

GCC_DEVICE = atmega328p
PROGRAMMER = -c arduino
DUDE_DEVICE = -p m328p
PORT = -P /dev/ttyACM0
BAUD = -b115200

.PHONY: burn clean

burn: $(HEX_FILE)
	sudo avrdude -C /etc/avrdude.conf -F -V $(PROGRAMMER) $(DUDE_DEVICE) $(PORT) $(BAUD) -D -Uflash:w:$<:i

%.hex: %.bin
	avr-objcopy -O ihex -R .eeprom $*.bin $@

%.bin: %.c
	avr-gcc -Os -DF_CPU=16000000UL -mmcu=$(GCC_DEVICE) $< -o $*.bin
	
clean:
	rm -f *.hex *.bin
	
# avoid treating arguments as targets
%:
	@:
