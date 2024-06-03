//test.c   测试文件
#include "2410addr.h"
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

#define rGPHCON ( * (volatile unsigned * )0x56000070)
#define rGPHUP ( * (volatile unsigned * )0x56000078)
#define rINTMSK ( * (volatile unsigned * )0X4A000008)
#define rINTSUBMSK ( * (volatile unsigned * )0X4A00001C)

#define rSRCPND ( * (volatile unsigned * )0x4A000000)
#define rSUBSRCPND ( * (volatile unsigned * )0x4A000018)
#define rINTPND ( * (volatile unsigned * )0x4A000010)

int PCLK;

void delay(int time)			//延时函数
{
		for(; time > 0; time--);
}

//初始化，输入PCLK、波特率——放在复位程序中
void Uart_Init(int pclk,int baud)
{
    int i;
    rGPHCON|=0xa0; 	//GPH2,GPH3 as TXD0,RXD0
    rGPHUP = 0x0;   //GPH2,GPH3内部上拉
    if(pclk == 0)	//参数pclk=0/1，表示用PCLK或
    pclk = PCLK;  	//PCLK是已定义符号 
    rUFCON0 = 0x0; 	//禁止3个通道的FIFO控制寄存器 
    rUFCON1 = 0x0;   
    rUFCON2 = 0x0;   

    rUMCON0 = 0x0;   
    rUMCON1 = 0x0;
    rUMCON2 = 0x0;    //初始化3个通道的MODEM控制寄存器，禁止AFC   
    //Line control register 0: Normal,No parity,1 stop, 8 bits.
    rULCON0=0x3;
    // Control register 0：PCLK、发送终中断产生、接收中断产生、loopback模式
    rUCON0  = 0x325;    
    //Baud rate divisior register 0 
    rUBRDIV0=( (int)(pclk/16/baud+0.5) -1 ); 
    //加0.5为了实现取整 
    
    //清除三个挂起寄存器
    rSRCPND |= 0x1<<28; //清除串口中断挂起SRCPND[28]
	rSUBSRCPND |= 0x3; //清除收发中断SUBSRCPND[1:0] 
	rINTPND |= 0x1<<28; //清除串口中断请求
	
	//打开总中断屏蔽和收发中断屏蔽
	rINTMSK &= ~(0x1<<28);
   	rINTSUBMSK &= ~(0x3);
 }   
 



//接收一字节数据
char Uart_Getch(void)
{
  	return RdURXH0;  //0x50000024，假设小端
}
//接收一个字符串
void Uart_GetString(char *string)
{
    char c;
    while((c = Uart_Getch())!='\r')   //回车符
           *string++ = c;
}

//发送一字节
void Uart_SendByte(int data)
{
       while(!(rUTRSTAT0 & 0x4));
       delay(10);  //because the slow response of hyper_terminal 
       WrUTXH0(data);
}
//发送一个字符串
void Uart_SendString(char *pt)
{
    while(*pt)
        Uart_SendByte(*pt++);
}


void Int_UART0()
{
	int j = rSUBSRCPND;
	
	switch(j)
	{
		case 0x0:
		{
			char* c;
			Uart_GetString(c);
			break;
		}
		case 0x1:
		{
			char* c;
			Uart_SendString(c);
			break;
		}
		default:
			break;
	} 



	rSRCPND = rSRCPND; //清除 SRCPND 寄存器
 	rSUBSRCPND = rSUBSRCPND;//清除 EINTPEND 寄存器
 	rINTPND = rINTPND; //清除 INTPND 寄存器
}
