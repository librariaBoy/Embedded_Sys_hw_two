	IMPORT |Image$$RO$$Limit|
	IMPORT |Image$$RW$$Base|
	IMPORT |Image$$ZI$$Base|
	IMPORT |Image$$ZI$$Limit|
	
	AREA MyCode,CODE,READONLY
	LDR	R0,=|Image$$RO$$Limit|
	LDR	R1,=|Image$$RW$$Base|
	LDR	R2,=|Image$$ZI$$Base|
	CMP	R0,R1
	BEQ	%F2
1
	CMP	R1,R3
	LDRCC	R2,[R0],#4
	STRCC	R2,[R1],#4
	BCC		%B1
2
	LDR	R1,=|Image$$ZI$$Limit|
	MOV R2,#0
3
	CMP	R3,R1
	STRCC R2,[R3],#4
	BCC	%B3
	END
			