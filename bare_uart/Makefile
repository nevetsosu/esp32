# 'Bare metal' ESP32 application Makefile
# Use the xtensa-esp32-elf toolchain.
TOOLCHAIN = xtensa-esp32-elf-

CFLAGS_PLATFORM  = -mlongcalls -mtext-section-literals -fstrict-volatile-bitfields
# CFLAGS_PLATFORM += -specs=nosys.specs		# provide stubs for sys calls
CFLAGS_PLATFORM += -nostdlib
CFLAGS_PLATFORM += -nodefaultlibs
CFLAGS_PLATFORM += -fno-builtin
CFLAGS_PLATFORM += -nostartfiles
CFLAGS_PLATFORM += -L$(NEWLIB_LPATH)
CFLAGS_PLATFORM += -I$(NEWLIB_IPATH)
CFLAGS_PLATFORM += -lc						# link c standard library from newlib
CFLAGS_PLATFORM += -lgcc					# link gcc low level support lib

ASFLAGS_PLATFORM = $(CFLAGS_PLATFORM)
LDFLAGS_PLATFORM = $(CFLAGS_PLATFORM)

###
# General project build
###
CC = $(TOOLCHAIN)gcc
LD = $(TOOLCHAIN)ld
OC = $(TOOLCHAIN)objcopy
OS = $(TOOLCHAIN)size
OD = $(TOOLCHAIN)objdump

# Includes
INC = -I./include/
# Linker script location.
LDSCRIPT = ./ld/bootloader.ld

# Set C flags.
CFLAGS += $(INC) -Wall -Werror -std=gnu11 $(CFLAGS_PLATFORM) $(COPT)
CFLAGS += -fno-strict-aliasing
CFLAGS += -fdata-sections -ffunction-sections
CFLAGS += -Os		# optimize for size
CFLAGS += -g		# include debugging information
# CFLAGS += -O0

# Set LD flags
LDFLAGS += -T$(LDSCRIPT) -Wl,-Map=$@.map -Wl,--cref -Wl,--gc-sections
LDFLAGS += $(LDFLAGS_PLATFORM)

# Set AS flags
ASFLAGS += -c -O0 -Wall -fmessage-length=0
ASFLAGS += $(ASFLAGS_PLATFORM)

# Set C source files.
C_SRC := $(wildcard ./src/*.c)

# Set C and Assembly source files.
ASM_SRC := \
	./src/startup.S

# Convert to object files
OBJS := $(C_SRC:.c=.o) $(ASM_SRC:.S=.o)

# Set the first rule in the file to 'make all'
.PHONY: all
all: main.elf

# Rules to build files.
%.o: %.S
	$(CC) -x assembler-with-cpp $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

main.elf: $(OBJS)
	$(CC) $^ $(LDFLAGS) -o $@

dump: main.elf
	$(OD) -D $<

format: main.elf
	esptool.py --chip esp32 elf2image --flash_mode=dio --flash_freq 40m --flash_size 4MB -o main.bin main.elf

flash: format
	esptool.py --chip esp32 --baud 460800 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size 4MB 0x1000 main.bin

monitor:
	python -m serial.tools.miniterm /dev/ttyUSB0 115200

openocd: format
	openocd -f interface/ftdi/esp32_devkitj_v1.cfg -f target/esp32.cfg

gdb: main.elf
	xtensa-esp32-elf-gdb $<
	# -ex "target remote localhost:3333"

erase:
	esptool.py erase_flash

.PHONY: clean
clean:
	rm -f $(OBJS)
	rm -f ./main.bin
	rm -f ./main.elf ./main.elf.map
