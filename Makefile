include mkenv.mk
include magic.mk

# isogashii:
BUILD = build
BIN = bin
CROSS_COMPILE=arm-none-eabi-

CFLAGS = -march=armv5te -mfloat-abi=soft -Wall \
	 -Os -Iinclude -marm -fno-stack-protector
AFLAGS = 

LDFLAGS = --nostdlib -T fernvale.ld
LIBS = lib/libgcc-armv5.a

STAGE1_LDFLAGS = --nostdlib -T stage1.ld

SRC_C = \
	bionic.c \
	cmd-hex.c \
	cmd-irq.c \
	cmd-peekpoke.c \
	cmd-reboot.c \
	cmd-sleep.c \
	cmd-spi.c \
	cmd-led.c \
	cmd-load.c \
	cmd-bl.c \
	cmd-lcd.c \
	cmd-keypad.c \
	emi.c \
	irq.c \
	lcd.c \
	main.c \
	scriptic.c \
	serial.c \
	spi.c \
	utils.c \
	vectors.c \
	vsprintf.c

SRC_S = \
	scriptic/set-plls.S \
	scriptic/enable-psram.S \
	scriptic/spi.S \
	scriptic/spi-blockmode.S \
	scriptic/keypad.S \
	start.S

OBJ = $(addprefix $(BUILD)/, $(SRC_S:.S=.o) $(SRC_C:.c=.o))

STAGE1_SRC_C = \
	stage1.c \
	serial.c \
	vectors.c

STAGE1_SRC_S = \
	start.S

STAGE1_OBJ = $(addprefix $(BUILD)/, $(STAGE1_SRC_S:.S=.o) $(STAGE1_SRC_C:.c=.o))

all: $(BIN)/firmware.bin \
	$(BIN)/stage1.bin \
	$(BIN)/dump-rom-usb.bin \
	$(BIN)/usb-loader.bin \
	$(BIN)/mt6261-test.bin \
	$(BIN)/fernly-usb-loader
clean:
	$(RM) -rf $(BUILD) $(BIN)

$(BIN)/fernly-usb-loader: fernly-usb-loader.c sha1.c sha1.h
	$(CC_NATIVE) fernly-usb-loader.c sha1.c -o $@

$(BIN)/%.bin: $(BUILD)/%.o
	$(OBJCOPY) -S -O binary $< $@

HEADER_BUILD = $(BUILD)/genhdr
$(BIN)/firmware.bin: $(BUILD)/firmware.elf
	$(OBJCOPY) -S -O binary $(BUILD)/firmware.elf $@

$(BUILD)/firmware.elf: $(OBJ)
	$(LD) $(LDFLAGS) --entry=reset_handler -o $@ $(OBJ) $(LIBS)

$(BIN)/stage1.bin: $(BUILD)/stage1.elf
	$(OBJCOPY) -S -O binary $(BUILD)/stage1.elf $@

$(BUILD)/stage1.elf: $(STAGE1_OBJ)
	$(LD) $(STAGE1_LDFLAGS) --entry=reset_handler -o $@ $(STAGE1_OBJ) $(LIBS)

$(OBJ): $(HEADER_BUILD)/generated.h | $(OBJ_DIRS)
$(HEADER_BUILD)/generated.h: | $(HEADER_BUILD)
	  touch $@

OBJ_DIRS = $(sort $(dir $(OBJ))) scriptic
$(OBJ_DIRS):
	$(MKDIR) -p $@ $@/scriptic
$(HEADER_BUILD):
	$(MKDIR) -p $@ build/scriptic
	$(MKDIR) -p $@ bin/
-include $(OBJ:.o=.P)

test: all
	novena-usb-hub -d u1 ; sleep 1; novena-usb-hub -e u1 ; sleep 2
	$(BUILD)/fernly-usb-loader /dev/fernvale $(BIN)/usb-loader.bin $(BIN)/firmware.bin

shell: all
	novena-usb-hub -d u1 ; sleep 1; novena-usb-hub -e u1 ; sleep 2
	$(BUILD)/fernly-usb-loader -s /dev/fernvale $(BUILD)/usb-loader.bin $(BUILD)/firmware.bin
