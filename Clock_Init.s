	;Clock_Init.s	初始化看门狗、时钟的子程序
	;GET	2440Reg_addr.inc
	
		AREA MyClockInit,CODE,READONLY
MPLL	EQU	((0x5c<<12)|(0x01<<4)|(0x01))	;FCLK=400M
SCALE	EQU	((0x0<<3)|(0x2<<1)|(0x01))	; FCLK:HCLK:PCLK = 1:4:8
   		LDR	R0,=WTCON		;关闭看门狗
		LDR	R1,=0x0
		STR	R1,[R0]
		LDR	R0,=CLKDIVN
		LDR	R1,=SCALE		;设置分频比
		STR	R1,[R0]
    	MRC    	p15, 0, R1, c1, c0, 0	;读出控制寄存器
   		ORR    	R1, R1, #0xC0000000	; 设置asynchronous bus mode
    	MCR    	p15, 0, R1, c1, c0, 0	; 写入控制寄存器
		LDR	R0,=MPLLCON
		LDR	R1,=MPLL			;设置FCLK
		STR	R1,[R0]
		MOV	PC,LR			; 初始化clock返回
		END				;汇编程序结束标识
