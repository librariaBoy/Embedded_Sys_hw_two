;MemSetup.s	初始化SDRAM子程序
	;GET	2440Reg_addr.inc
	
	AREA MyMemSetup,CODE,READONLY
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
    	             	
		END			;包含文件内的汇编结束伪指令
