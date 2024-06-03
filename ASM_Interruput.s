;文件ASM_Interrupt.s
	IMPORT Uart_Init
;(1)设置中断向量表
Mode_USR	EQU     0x50	;IRQ中断开放，FIQ中断关闭
Mode_FIQ 	EQU     0xD1	;关闭IRQ、FIQ中断
Mode_IRQ	EQU     0xD2	;关闭IRQ、FIQ中断
Mode_SVC 	EQU     0xD3	;关闭IRQ、FIQ中断
INTSUBMSK  	EQU		0X4A00001C

		GET	2440Reg_addr.inc
		GET Init_DATA.s
		
    	AREA    MyCode, CODE,READONLY
    	ENTRY				;设置中断向量表
		B	ResetHandler		;Reset中断服务程序
		B	.			;handlerUndef
		B	.			;SWI interrupt handler
		B	.			;handlerPAbort
		B	.			;handlerDAbort
		B	.			;handlerReserved
		B	HandlerIRQ	;HandlerIRQ, INTMOD复位为0
		B	.			;HandlerFIQ

;(2)复位的中断处理程序
ResetHandler 					
		BL	Clock_Init		;初始化看门狗、时钟
		BL	MemSetup		;初始化SDRAM
		BL 	Int_EntryTable
 		LDR SP, =SvcStackSpace	;设置管理模式堆栈 
        MSR	CPSR_c, #Mode_IRQ
        LDR	SP, =IrqStackSpace	;设置IRQ中断模式堆栈
        MSR	CPSR_c, #Mode_FIQ
        LDR	SP, =FiqStackSpace	;设置FIQ中断模式堆栈 
        MSR	CPSR_c, #Mode_USR	;进入用户模式
		LDR	SP, =UsrStackSpace	;设置用户与系统模式堆栈

		;初始化UART
		LDR R0,=0
		LDR R1,=115200
		BL 	Uart_Init
		LDR R0,=pINT_UART0
		LDR R1,=Int_UART0
		STR R1,[R0]


MAIN_LOOP
 		NOP			
		B      	MAIN_LOOP	;死循环，被IRQ/FIQ中断
Clock_Init			
		;GET	Clock_Init.s		;初始化看门狗、时钟
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
MemSetup		
		;GET	MemSetup.s		;初始化SDRAM
	 	LDR		R0,=SMRDATA	;SMRDATA数据开始地址
    	LDR		R1,=BWSCON    	;BWSCON地址
    	ADD    	R2, R0, #52	;SMRDATA数据结束地址
0    		      
    	LDR		R3, [R0], #4	;读出数据
    	STR    	R3, [R1], #4	;写入寄存器
    	CMP    	R2, R0		;判断是否结束
    	BNE    	%B0		;逆向返回标号0
		MOV	PC,LR		;返回
SMRDATA    	
    	DCD		0x22000000	;BWSCON
    	DCD    	0x00000700     	;BANKCON0
    	DCD    	0x00000700     	;BANKCON1


; (3)IRQ中断处理程序——主体部分
HandlerIRQ
		SUB	LR,LR, #4		;计算返回地址
    	STMFD	SP!, {LR}		;保存断点到IRQ模式的堆栈
    	LDR	LR,= Int_Return 	;修改LR，执行完EINT8_23的处理程序后返回到Int_Return处 
    	
    	;屏蔽发送和接收中断源
		LDR R0,=INTSUBMSK ;屏蔽发送和接收中断
 		LDR R1,[R0]
 		ORR R1,R1,#0x3
 		STR R1,[R0]
 		
Int_UART0
		LDR	R0,=INTOFFSET	;取得中断源的编号
		LDR	R1,[R0]		
		LDR	R2,=Int_EntryTable ;中断散转表起始地址
		LDR	PC,[R2,R1,LSL#2]	;查中断散转表，取得EINT8_23的处理程序入口地址，相当于无参的子程序调用，但没保存断点
Int_Return	      ;执行完Int_UART0的处理程序后须返回此处
		LDR R0,=INTSUBMSK ;打开发送和接收中断
 		LDR R1,[R0]
		MVN R2,#0x3 ;取反码
		AND R1,R1,R2
 		STR R1,[R0]
		LDMFD SP!, {PC }^    	;IRQ中断服务程序返回, ^表示将SPSR的值复制到CPSR
Int_EntryTable
	GET Int_EntryTable.s


	AREA    MyRWData, DATA, READWRITE	;设置RW Base=0x33ffe700

        	AREA    MyZIData, DATA, READWRITE, NOINIT,ALIGN=8
;满递减堆栈，根据对齐方式，段起始地址为0x33ffe800，各栈区空间均为1kB
			    SPACE	0x100 * 4	;管理模式堆栈空
SvcStackSpace   SPACE	0x100 * 4	;中断模式堆栈空间
IrqStackSpace   SPACE	0x100 * 4	;快速中断模式堆栈空间
FiqStackSpace   SPACE	0x100 * 4
UsrStackSpace
		               END 