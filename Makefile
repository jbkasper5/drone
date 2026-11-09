BUILD_DIR := build
TARGET := drone

ELF := $(BUILD_DIR)/$(TARGET).elf
UF2 := $(BUILD_DIR)/$(TARGET).uf2
PICO_VOLUME := /Volumes/RP2350

OBJDUMP := arm-none-eabi-objdump

# ANSI colors
BLUE   := \033[1;34m
GREEN  := \033[1;32m
YELLOW := \033[1;33m
RESET  := \033[0m

DEBUG ?= 0

ifeq ($(DEBUG), 1)
    BUILD_TYPE := Debug
else
    BUILD_TYPE := Release
endif

.PHONY: all local debug flash clean asm serial

# Build + flash (like rpos `all` builds + copies to the SD card)
all: flash

# Build only. CMake/the Pico SDK do the real work; this just drives it.
local:
	@printf "$(BLUE)==> Configuring ($(BUILD_TYPE))$(RESET)\n"
	cmake -S . -B $(BUILD_DIR) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE)
	@printf "$(GREEN)==> Building $(TARGET)$(RESET)\n"
	cmake --build $(BUILD_DIR) -j

debug: clean
	@printf "$(YELLOW)==> Rebuilding with DEBUG=1$(RESET)\n"
	$(MAKE) DEBUG=1

# Hold BOOTSEL while plugging in the Pico; it mounts as $(PICO_VOLUME)
flash: local
	@printf "$(BLUE)==> Waiting for $(PICO_VOLUME) (hold BOOTSEL + plug in)$(RESET)\n"
	@while [ ! -d $(PICO_VOLUME) ]; do sleep 1; done
	@printf "$(GREEN)==> Flashing $(UF2)$(RESET)\n"
	cp -X $(UF2) $(PICO_VOLUME)/

clean:
	@printf "$(YELLOW)==> Cleaning build artifacts$(RESET)\n"
	rm -rf $(BUILD_DIR) objdump.S

asm: local
	$(OBJDUMP) -d $(ELF) > objdump.S

serial:
	screen /dev/tty.usbmodem* 115200
