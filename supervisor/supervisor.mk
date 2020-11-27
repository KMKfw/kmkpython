SRC_SUPERVISOR = \
	main.c \
	supervisor/port.c \
	supervisor/shared/autoreload.c \
	supervisor/shared/background_callback.c \
	supervisor/shared/board.c \
	supervisor/shared/filesystem.c \
	supervisor/shared/flash.c \
	supervisor/shared/micropython.c \
	supervisor/shared/rgb_led_status.c \
	supervisor/shared/safe_mode.c \
	supervisor/shared/stack.c \
	supervisor/shared/status_leds.c \
	supervisor/shared/tick.c \
	supervisor/shared/translate.c

ifndef $(NO_USB)
	NO_USB = $(wildcard supervisor/usb.c)
endif

ifndef INTERNAL_FLASH_FILESYSTEM
INTERNAL_FLASH_FILESYSTEM = 0
endif
CFLAGS += -DINTERNAL_FLASH_FILESYSTEM=$(INTERNAL_FLASH_FILESYSTEM)

ifndef QSPI_FLASH_FILESYSTEM
QSPI_FLASH_FILESYSTEM = 0
endif
CFLAGS += -DQSPI_FLASH_FILESYSTEM=$(QSPI_FLASH_FILESYSTEM)

ifndef SPI_FLASH_FILESYSTEM
SPI_FLASH_FILESYSTEM = 0
endif
CFLAGS += -DSPI_FLASH_FILESYSTEM=$(SPI_FLASH_FILESYSTEM)

ifeq ($(CIRCUITPY_BLEIO),1)
	SRC_SUPERVISOR += supervisor/shared/bluetooth.c supervisor/bluetooth.c
endif

# Choose which flash filesystem impl to use.
# (Right now INTERNAL_FLASH_FILESYSTEM and (Q)SPI_FLASH_FILESYSTEM are mutually exclusive.
# But that might not be true in the future.)
ifdef EXTERNAL_FLASH_DEVICES
	CFLAGS += -DEXTERNAL_FLASH_DEVICES=$(EXTERNAL_FLASH_DEVICES) \
				-DEXTERNAL_FLASH_DEVICE_COUNT=$(EXTERNAL_FLASH_DEVICE_COUNT)

	SRC_SUPERVISOR += supervisor/shared/external_flash/external_flash.c
	ifeq ($(SPI_FLASH_FILESYSTEM),1)
		SRC_SUPERVISOR += supervisor/shared/external_flash/spi_flash.c
	else
	endif
	ifeq ($(QSPI_FLASH_FILESYSTEM),1)
		SRC_SUPERVISOR += supervisor/qspi_flash.c supervisor/shared/external_flash/qspi_flash.c
	endif
else
	ifeq ($(DISABLE_FILESYSTEM),1)
		SRC_SUPERVISOR += supervisor/stub/internal_flash.c
	else
		SRC_SUPERVISOR += supervisor/internal_flash.c
	endif
endif

ifeq ($(USB),FALSE)
	ifeq ($(wildcard supervisor/serial.c),)
		SRC_SUPERVISOR += supervisor/stub/serial.c
	else
		SRC_SUPERVISOR += supervisor/serial.c
	endif
else
	SRC_SUPERVISOR += \
		lib/tinyusb/src/common/tusb_fifo.c \
		lib/tinyusb/src/device/usbd.c \
		lib/tinyusb/src/device/usbd_control.c \
		lib/tinyusb/src/class/msc/msc_device.c \
		lib/tinyusb/src/class/cdc/cdc_device.c \
		lib/tinyusb/src/tusb.c \
		supervisor/shared/serial.c \
		supervisor/usb.c \
		supervisor/shared/usb/usb_desc.c \
		supervisor/shared/usb/usb.c \
		supervisor/shared/usb/usb_msc_flash.c \
		$(BUILD)/autogen_usb_descriptor.c

	ifeq ($(CIRCUITPY_USB_HID), 1)
		SRC_SUPERVISOR += \
			lib/tinyusb/src/class/hid/hid_device.c \
			shared-bindings/usb_hid/__init__.c \
			shared-bindings/usb_hid/Device.c \
			shared-module/usb_hid/__init__.c \
			shared-module/usb_hid/Device.c
	endif

	ifeq ($(CIRCUITPY_USB_MIDI), 1)
		SRC_SUPERVISOR += \
			lib/tinyusb/src/class/midi/midi_device.c \
			shared-bindings/usb_midi/__init__.c \
			shared-bindings/usb_midi/PortIn.c \
			shared-bindings/usb_midi/PortOut.c \
			shared-module/usb_midi/__init__.c \
			shared-module/usb_midi/PortIn.c \
			shared-module/usb_midi/PortOut.c
	endif

	CFLAGS += -DUSB_AVAILABLE
endif

SUPERVISOR_O = $(addprefix $(BUILD)/, $(SRC_SUPERVISOR:.c=.o))

ifeq ($(CIRCUITPY_DISPLAYIO), 1)
	SRC_SUPERVISOR += \
		supervisor/shared/display.c

	ifeq ($(CIRCUITPY_TERMINALIO), 1)
		SUPERVISOR_O += $(BUILD)/autogen_display_resources.o
	endif
endif
ifndef USB_INTERFACE_NAME
USB_INTERFACE_NAME = "KMKPython"
endif

USB_DEVICES_COMPUTED := CDC,MSC
ifeq ($(CIRCUITPY_USB_MIDI),1)
USB_DEVICES_COMPUTED := $(USB_DEVICES_COMPUTED),AUDIO
endif
ifeq ($(CIRCUITPY_USB_HID),1)
USB_DEVICES_COMPUTED := $(USB_DEVICES_COMPUTED),HID
endif
USB_DEVICES ?= "$(USB_DEVICES_COMPUTED)"

ifndef USB_HID_DEVICES
USB_HID_DEVICES = "KEYBOARD,MOUSE,CONSUMER,GAMEPAD"
endif

ifndef USB_HIGHSPEED
USB_HIGHSPEED = 0
endif

ifndef USB_CDC_EP_NUM_NOTIFICATION
USB_CDC_EP_NUM_NOTIFICATION = 0
endif

ifndef USB_CDC_EP_NUM_DATA_OUT
USB_CDC_EP_NUM_DATA_OUT = 0
endif

ifndef USB_CDC_EP_NUM_DATA_IN
USB_CDC_EP_NUM_DATA_IN = 0
endif

ifndef USB_MSC_EP_NUM_OUT
USB_MSC_EP_NUM_OUT = 0
endif

ifndef USB_MSC_EP_NUM_IN
USB_MSC_EP_NUM_IN = 0
endif

ifndef USB_HID_EP_NUM_OUT
USB_HID_EP_NUM_OUT = 0
endif

ifndef USB_HID_EP_NUM_IN
USB_HID_EP_NUM_IN = 0
endif

ifndef USB_MIDI_EP_NUM_OUT
USB_MIDI_EP_NUM_OUT = 0
endif

ifndef USB_MIDI_EP_NUM_IN
USB_MIDI_EP_NUM_IN = 0
endif

ifndef USB_NUM_EP
USB_NUM_EP = 0
endif

USB_DESCRIPTOR_ARGS = \
	--manufacturer $(USB_MANUFACTURER)\
	--product $(USB_PRODUCT)\
	--vid $(USB_VID)\
	--pid $(USB_PID)\
	--serial_number_length $(USB_SERIAL_NUMBER_LENGTH)\
	--interface_name $(USB_INTERFACE_NAME)\
	--devices $(USB_DEVICES)\
	--hid_devices $(USB_HID_DEVICES)\
	--max_ep $(USB_NUM_EP) \
	--cdc_ep_num_notification $(USB_CDC_EP_NUM_NOTIFICATION)\
	--cdc_ep_num_data_out $(USB_CDC_EP_NUM_DATA_OUT)\
	--cdc_ep_num_data_in $(USB_CDC_EP_NUM_DATA_IN)\
	--msc_ep_num_out $(USB_MSC_EP_NUM_OUT)\
	--msc_ep_num_in $(USB_MSC_EP_NUM_IN)\
	--hid_ep_num_out $(USB_HID_EP_NUM_OUT)\
	--hid_ep_num_in $(USB_HID_EP_NUM_IN)\
	--midi_ep_num_out $(USB_MIDI_EP_NUM_OUT)\
	--midi_ep_num_in $(USB_MIDI_EP_NUM_IN)\
	--output_c_file $(BUILD)/autogen_usb_descriptor.c\
	--output_h_file $(BUILD)/genhdr/autogen_usb_descriptor.h

ifeq ($(USB_RENUMBER_ENDPOINTS), 0)
USB_DESCRIPTOR_ARGS += --no-renumber_endpoints
endif

ifeq ($(USB_HIGHSPEED), 1)
USB_DESCRIPTOR_ARGS += --highspeed
endif

$(BUILD)/supervisor/shared/translate.o: $(HEADER_BUILD)/qstrdefs.generated.h

$(BUILD)/autogen_usb_descriptor.c $(BUILD)/genhdr/autogen_usb_descriptor.h: autogen_usb_descriptor.intermediate

.INTERMEDIATE: autogen_usb_descriptor.intermediate

autogen_usb_descriptor.intermediate: ../../tools/gen_usb_descriptor.py Makefile | $(HEADER_BUILD)
	$(STEPECHO) "GEN $@"
	$(Q)install -d $(BUILD)/genhdr
	$(Q)$(PYTHON3) ../../tools/gen_usb_descriptor.py $(USB_DESCRIPTOR_ARGS)

CIRCUITPY_DISPLAY_FONT ?= "../../tools/fonts/ter-u12n.bdf"

$(BUILD)/autogen_display_resources.c: ../../tools/gen_display_resources.py $(HEADER_BUILD)/qstrdefs.generated.h Makefile | $(HEADER_BUILD)
	$(STEPECHO) "GEN $@"
	$(Q)install -d $(BUILD)/genhdr
	$(Q)$(PYTHON3) ../../tools/gen_display_resources.py \
		--font $(CIRCUITPY_DISPLAY_FONT) \
		--sample_file $(HEADER_BUILD)/qstrdefs.generated.h \
		--output_c_file $(BUILD)/autogen_display_resources.c
