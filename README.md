Disassembly for the Western Design Center W65C816SXB single-board computer.

Based on original work by "Keith": https://hackaday.io/project/177384-w65c816sxb-investigation.

Source is currently designed to be assembed by the latest 65816-enabled version of the
"6502 Macroassembler & Assembler", originally by Michael Kowalski, but enhanced by Daryl
Richter to add 65816 support (https://sbc.rictor.org/kowalski.html).

A CC65 version (https://cc65.github.io/) is in progress, and once complete, it will become the main
version going forward.

* ROM monitor is $8000 bytes in size, from $8000 to $FFFF.
* RAM locations $7E00 through $7FFF are used (work-RAM), and unavailable to the user application.
* Zero-page locations $00 through $04 are used, but they are copied to the work-RAM, and restored
  before the application is executed, so they are avaiable for the application to use.
* The monitor interfaces through the debugger using a USB FIFO.
* The debugger accesses the USB FIFO through a Windows COM port. This port can be opened manually
  using a terminal emulator and then you can manually interact with the monitor.

* Work-RAM memory locations:

	* CPU context save:
	* A:	$7E00, $7E01
	* X:	$7E02, $7E03
	* Y:	$7E04, $7E05
	* PC:	$7E06, $7E07
	* DP:	$7E08, $7E09
	* SP:	$7E0A, $7E0B
	* P:	$7E0C, $7E0D
	* PB:	$7E0E
	* DB:	$7E0F

	* Zero-page save area: $7E14-$7E18

	* Raw Vectors: Jumped to immediately from FLASH. May be overridden by the user, but not
		recommended. Most run code critical for proper functioning of the debugger. If
		it is reasonable for the user to handle this, then the default handler will call
		the user's handler through the corresponding shadow vector.
	* IRQ_02:	$7E70 (defaults to IRQ_entry_vector_default)
	* NMI_02:	$7E72 (defaults to NMI_entry_vector_default)
	* BRK_816:	$7E74 (defaults to BRK_816_entry_vector_default)
	* NMI_816:	$7E76 (defaults to NMI_816_entry_vector_default)

* Shadow vectors:

	* In '02 emulation mode, the default IRQ entry vector checks for BRK, and if not BRK, then
	  it vectors to SHADOW_VEC_IRQ_02 ($7EFE), which the user can override for IRQ processing.
	* In native mode, SHADOW_VEC_IRQ_816 is called immediately from the default handler.
	* Default NMI entry vector saves the CPU context and then syncs with the debugger.
	* The monitor initially populates each shadow vector with $811F, which is an infinite loop.

* On RESET:

	* The CPU context and the first five bytes of the zero-page is saved to work-RAM.
	* The saved emulation bit is 1, so user programs executed will be run in emulation mode.
	* The user shadow registers are initialized to their defaults.
	* The entry vectors are initialized to their defaults.
	* The debug VIA is initialized. This causes an $FF to be sent to the debugger.
	* The monitor is sycned with the debugger, where it waits for debugger commands.

* Debugger interface:

	* On startup or NMI, $FF is sent from the monitor to the debugger.
	* The debugger sends $55 and then $AA to the debugger.
	* The debugger sends $CC to the debugger.
	* The debugger then sends a command to the debugger (0-9).
	* Each command does something different, and most require extra parameters.
	* The parameters are stored in the first five bytes of RAM ($00 - $04).

	Debugger Commands:
	* 0: Sends a $00 to the debugger. Not sure why this is useful or how it is used.
	* 1: Byte sequence test. Send a sequence of bytes to the monitor, and monitor sends them back.
	* 2: Memory write:
		The debugger sends 5+N bytes to the monitor:
		0: The lowest 8-bits of the 24-bit starting address.
		1: The middle 8-bits of the 24-bit starting address.
		2: The high 8-bits (bank) of the 24-bit starting address.
		3: The lowest 8-bits of the 16-bit transfer count.
		4: The highest 8-bits of the 16-bit transfer count.
		(count): The debugger sends the data to write to memory.
	* 3: Memory read:
		The debugger sends 5 bytes to the monitor:
		0: The lowest 8-bits of the 24-bit starting address.
		1: The middle 8-bits of the 24-bit starting address.
		2: The high 8-bits (bank) of the 24-bit starting address.
		3: The lowest 8-bits of the 16-bit transfer count.
		4: The highest 8-bits of the 16-bit transfer count.
		Then the monitor sends the number of bytes requested.
	* 4: Get system info
	* 5: Begin program execution:
		* Restores CPU context and starts execution from saved values in work-RAM.
	* 6: Apparent no-op command.
	* 7: Apparent no-op command.
	* 8: Executes a BRK, which sends $02 to the debugger. Not sure why.
	* 9: Reads a byte from the debugger, then performs the same action as command 8.