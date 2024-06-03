	;Clock_Init.s	��ʼ�����Ź���ʱ�ӵ��ӳ���
	;GET	2440Reg_addr.inc
	
		AREA MyClockInit,CODE,READONLY
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
		END				;�����������ʶ
