;文件 Int_EntryTable.s,中断散转表
;仲裁电路 32 路输入
	AREA EntryTable,DATA,READONLY
pEINT0 DCD 0
pEINT1 DCD 0
pEINT2 DCD 0
pEINT3 DCD 0
pEINT4_7 DCD 0

pEINT8_23 DCD 0	;存放EINT8_23中断服务程序入口地址——EINT8_23 

pINT_CAM DCD 0
pnBATT_FLT DCD 0
pINT_TICK DCD 0 
pINT_WDT_AC97 DCD 0
pINT_TIMER0 DCD 0
pINT_TIMER1 DCD 0
pINT_TIMER2 DCD 0
pINT_TIMER3 DCD 0
pINT_TIMER4 DCD 0
pINT_UART2 DCD 0
pINT_LCD DCD 0
pINT_DMA0 DCD 0
pINT_DMA1 DCD 0
pINT_DMA2 DCD 0
pINT_DMA3 DCD 0
pINT_SDI DCD 0
pINT_SPI0 DCD 0
pINT_UART1 DCD 0
pINT_NFCON DCD 0
pINT_USBD DCD 0
pINT_USBH DCD 0
pINT_IIC DCD 0
pINT_UART0 DCD 0
pINT_SPI1 DCD 0
pINT_RTC DCD 0 
pINT_ADC DCD 0 
	END