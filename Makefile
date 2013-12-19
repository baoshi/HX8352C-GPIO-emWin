######################################
# STM32F10x Makefile
######################################

######################################
# target
######################################
TARGET = emWin

######################################
# building variables
######################################
# debug build?
DEBUG = 1
# build for debug in ram?
RAMBUILD = 0
# optimization
OPT = -O0

#######################################
# pathes
#######################################
# firmware library path
PERIPHLIBPATH = ../../STM32F10x_StdPeriph_Lib_V3.5.0/Libraries
STEMWINLIBPATH = ../../STemWin_Library_V1.1.0/Libraries/STemWinLibrary522
# source path
VPATH = src startup
VPATH += $(PERIPHLIBPATH)/CMSIS/CM3/CoreSupport
VPATH += $(PERIPHLIBPATH)/CMSIS/CM3/DeviceSupport/ST/STM32F10x
VPATH += $(PERIPHLIBPATH)/STM32F10x_StdPeriph_Driver/src
VPATH += $(STEMWINLIBPATH)/OS
# Build path
BUILD_DIR = build

######################################
# source
######################################
SRCS = \
  main.c \
  GUIDEMO.c \
  GUIDEMO_Resource.c \
  GUIDEMO_Conf.c \
  GUIDEMO_Intro.c \
  GUIDEMO_AntialiasedText.c \
  GUIDEMO_Speed.c \
  HX8352C_GPIO.c \
  GUIDRV_HX8352C.c \
  LCDConf.c \
  GUIConf.c \
  GUI_X.c \
  system_stm32f10x.c \
  stm32f10x_it.c
SRCSASM = \
  startup_stm32f10x_hd.s \
  HX8352C_GPIO_Lowlevel.s

######################################
# firmware Library
######################################
PERIPHLIB_SOURCES = \
  stm32f10x_gpio.c \
  stm32f10x_rcc.c \
  stm32f10x_fsmc.c
 
#######################################
# binaries
#######################################
CC = arm-none-eabi-gcc
AS = arm-none-eabi-gcc -x assembler-with-cpp
CP = arm-none-eabi-objcopy
AR = arm-none-eabi-ar
SZ = arm-none-eabi-size
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S
 
#######################################
# CFLAGS
#######################################
# macros for gcc
DEFS = -DSTM32F10X_HD -DUSE_STDPERIPH_DRIVER
ifeq ($(RAMBUILD), 1)
DEFS += -DVECT_TAB_SRAM
endif
ifeq ($(DEBUG), 1)
DEFS += -DDEBUG -D_DEBUG
endif
# includes for gcc
INCLUDES = -Iinc
INCLUDES += -I$(PERIPHLIBPATH)/CMSIS/CM3/CoreSupport
INCLUDES += -I$(PERIPHLIBPATH)/CMSIS/CM3/DeviceSupport/ST/STM32F10x
INCLUDES += -I$(PERIPHLIBPATH)/STM32F10x_StdPeriph_Driver/inc
INCLUDES += -I$(STEMWINLIBPATH)/inc
# compile gcc flags
CFLAGS = -mthumb -mcpu=cortex-m3 $(DEFS) $(INCLUDES) $(OPT) -Wall
ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif
# Generate dependency information
CFLAGS += -MD -MP -MF .dep/$(@F).d

#######################################
# LDFLAGS
#######################################
# link script
ifeq ($(RAMBUILD), 1)
LDSCRIPT = linker/STM32F103RC_ram.ld
else
LDSCRIPT = linker/STM32F103RC_flash.ld
endif
# libraries
LIBS = -lc -lm -lnosys
LIBPATH =
STMWINLIB = $(STEMWINLIBPATH)/Lib/STemWin522_CM3_GCC.a
LDFLAGS = -mthumb -mcpu=cortex-m3 -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections 


# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex


#######################################
# build the application
#######################################
# list of firmware library objects
PERIPHLIB_OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(PERIPHLIB_SOURCES:.c=.o)))
# list of C program objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SRCS:.c=.o)))
# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(SRCSASM:.s=.o)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.s=.lst)) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) $(PERIPHLIB_OBJECTS) Makefile
	$(CC) $(OBJECTS) $(PERIPHLIB_OBJECTS) $(STMWINLIB) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR):
	mkdir -p $@


#######################################
# delete all user application files
#######################################
clean:
	-rm -fR .dep $(BUILD_DIR)
  
#
# Include the dependency files, should be the last of the makefile
#
-include $(shell mkdir .dep 2>/dev/null) $(wildcard .dep/*)

# *** EOF ***

