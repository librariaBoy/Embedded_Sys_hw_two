;�ļ�ASM_Interrupt.s
	IMPORT Uart_Init
;(1)�����ж�������
Mode_USR	EQU     0x50	;IRQ�жϿ��ţ�FIQ�жϹر�
Mode_FIQ 	EQU     0xD1	;�ر�IRQ��FIQ�ж�
Mode_IRQ	EQU     0xD2	;�ر�IRQ��FIQ�ж�
Mode_SVC 	EQU     0xD3	;�ر�IRQ��FIQ�ж�
INTSUBMSK  	EQU		0X4A00001C

		GET	2440Reg_addr.inc
		GET Init_DATA.s
		
    	AREA    MyCode, CODE,READONLY
    	ENTRY				;�����ж�������
		B	ResetHandler		;Reset�жϷ������
		B	.			;handlerUndef
		B	.			;SWI interrupt handler
		B	.			;handlerPAbort
		B	.			;handlerDAbort
		B	.			;handlerReserved
		B	HandlerIRQ	;HandlerIRQ, INTMOD��λΪ0
		B	.			;HandlerFIQ

;(2)��λ���жϴ������
ResetHandler 					
		BL	Clock_Init		;��ʼ�����Ź���ʱ��
		BL	MemSetup		;��ʼ��SDRAM
		BL 	Int_EntryTable
 		LDR SP, =SvcStackSpace	;���ù���ģʽ��ջ 
        MSR	CPSR_c, #Mode_IRQ
        LDR	SP, =IrqStackSpace	;����IRQ�ж�ģʽ��ջ
        MSR	CPSR_c, #Mode_FIQ
        LDR	SP, =FiqStackSpace	;����FIQ�ж�ģʽ��ջ 
        MSR	CPSR_c, #Mode_USR	;�����û�ģʽ
		LDR	SP, =UsrStackSpace	;�����û���ϵͳģʽ��ջ

		;��ʼ��UART
		LDR R0,=0
		LDR R1,=115200
		BL 	Uart_Init
		LDR R0,=pINT_UART0
		LDR R1,=Int_UART0
		STR R1,[R0]


MAIN_LOOP
 		NOP			
		B      	MAIN_LOOP	;��ѭ������IRQ/FIQ�ж�
Clock_Init			
		;GET	Clock_Init.s		;��ʼ�����Ź���ʱ��
MPLL	EQU	((0x5c<<12)|(0x01<<4)|(0x01))	;FCLK=400M
SCALE	EQU	((0x0<<3)|(0x2<<1)|(0x01))	; FCLK:HCLK:PCLK = 1:4:8
   		LDR	R0,=WTCON		;�رտ��Ź�
		LDR	R1,=0x0
		STR	R1,[R0]
		LDR	R0,=CLKDIVN
		LDR	R1,=SCALE		;���÷�Ƶ��
		STR	R1,[R0]
    	MRC    	p15, 0, R1, c1, c0, 0	;�������ƼĴ���
   		ORR    	R1, R1, #0xC0000000	; ����asynchronous bus mode
    	MCR    	p15, 0, R1, c1, c0, 0	; д����ƼĴ���
		LDR	R0,=MPLLCON
		LDR	R1,=MPLL			;����FCLK
		STR	R1,[R0]
		MOV	PC,LR			; ��ʼ��clock����
MemSetup		
		;GET	MemSetup.s		;��ʼ��SDRAM
	 	LDR		R0,=SMRDATA	;SMRDATA���ݿ�ʼ��ַ
    	LDR		R1,=BWSCON    	;BWSCON��ַ
    	ADD    	R2, R0, #52	;SMRDATA���ݽ�����ַ
0    		      
    	LDR		R3, [R0], #4	;��������
    	STR    	R3, [R1], #4	;д��Ĵ���
    	CMP    	R2, R0		;�ж��Ƿ����
    	BNE    	%B0		;���򷵻ر��0
		MOV	PC,LR		;����
SMRDATA    	
    	DCD		0x22000000	;BWSCON
    	DCD    	0x00000700     	;BANKCON0
    	DCD    	0x00000700     	;BANKCON1


; (3)IRQ�жϴ�����򡪡����岿��
HandlerIRQ
		SUB	LR,LR, #4		;���㷵�ص�ַ
    	STMFD	SP!, {LR}		;����ϵ㵽IRQģʽ�Ķ�ջ
    	LDR	LR,= Int_Return 	;�޸�LR��ִ����EINT8_23�Ĵ������󷵻ص�Int_Return�� 
    	
    	;���η��ͺͽ����ж�Դ
		LDR R0,=INTSUBMSK ;���η��ͺͽ����ж�
 		LDR R1,[R0]
 		ORR R1,R1,#0x3
 		STR R1,[R0]
 		
Int_UART0
		LDR	R0,=INTOFFSET	;ȡ���ж�Դ�ı��
		LDR	R1,[R0]		
		LDR	R2,=Int_EntryTable ;�ж�ɢת����ʼ��ַ
		LDR	PC,[R2,R1,LSL#2]	;���ж�ɢת��ȡ��EINT8_23�Ĵ��������ڵ�ַ���൱���޲ε��ӳ�����ã���û����ϵ�
Int_Return	      ;ִ����Int_UART0�Ĵ��������뷵�ش˴�
		LDR R0,=INTSUBMSK ;�򿪷��ͺͽ����ж�
 		LDR R1,[R0]
		MVN R2,#0x3 ;ȡ����
		AND R1,R1,R2
 		STR R1,[R0]
		LDMFD SP!, {PC }^    	;IRQ�жϷ�����򷵻�, ^��ʾ��SPSR��ֵ���Ƶ�CPSR
Int_EntryTable
	GET Int_EntryTable.s


	AREA    MyRWData, DATA, READWRITE	;����RW Base=0x33ffe700

        	AREA    MyZIData, DATA, READWRITE, NOINIT,ALIGN=8
;���ݼ���ջ�����ݶ��뷽ʽ������ʼ��ַΪ0x33ffe800����ջ���ռ��Ϊ1kB
			    SPACE	0x100 * 4	;����ģʽ��ջ��
SvcStackSpace   SPACE	0x100 * 4	;�ж�ģʽ��ջ�ռ�
IrqStackSpace   SPACE	0x100 * 4	;�����ж�ģʽ��ջ�ռ�
FiqStackSpace   SPACE	0x100 * 4
UsrStackSpace
		               END 