;MemSetup.s	��ʼ��SDRAM�ӳ���
	;GET	2440Reg_addr.inc
	
	AREA MyMemSetup,CODE,READONLY
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
    	             	
		END			;�����ļ��ڵĻ�����αָ��
