;==========================
;filename 2440IO_addr.inc
;==========================
;=================
;Memory control
;=================
BWSCON EQU 0x48000000 ;Bus width & wait status
BANKCON0 EQU 0x48000004 ;Boot ROM control
BANKCON1 EQU 0x48000008 ;BANK1 control
BANKCON2 EQU 0x4800000c ;BANK2 control
BANKCON3 EQU 0x48000010 ;BANK3 control
BANKCON4 EQU 0x48000014 ;BANK4 control
INTOFFSET EQU 0x4A000014
rSUBSRCPND EQU 0x4A000018
rINTSUBMSK EQU 0x4A00001C
rINTMSK EQU 0x4A000008
rSRCPND EQU 0x4A000000
rINTPND EQU 0x4A000010
;==========================
; CLOCK & POWER MANAGEMENT
;==========================
LOCKTIME EQU 0x4c000000 ;PLL lock time counter
MPLLCON EQU 0x4c000004 ;MPLL control
UPLLCON EQU 0x4c000008 ;UPLL control
CLKCON EQU 0x4c00000c ;Clock generator control
CLKSLOW EQU 0x4c000010 ;Slow clock control
CLKDIVN EQU 0x4c000014 ;Clock divider control
;=================
; WATCH DOG TIMER
;=================
WTCON EQU 0x53000000 ;Watch-dog timer mode
WTDAT EQU 0x53000004 ;Watch-dog timer data
WTCNT EQU 0x53000008 ;Watch-dog timer count
	END