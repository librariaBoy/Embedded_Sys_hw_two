//test.c   �����ļ�
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

void delay(int time)			//��ʱ����
{
		for(; time > 0; time--);
}

//��ʼ��������PCLK�������ʡ������ڸ�λ������
void Uart_Init(int pclk,int baud)
{
    int i;
    rGPHCON|=0xa0; 	//GPH2,GPH3 as TXD0,RXD0
    rGPHUP = 0x0;   //GPH2,GPH3�ڲ�����
    if(pclk == 0)	//����pclk=0/1����ʾ��PCLK��
    pclk = PCLK;  	//PCLK���Ѷ������ 
    rUFCON0 = 0x0; 	//��ֹ3��ͨ����FIFO���ƼĴ��� 
    rUFCON1 = 0x0;   
    rUFCON2 = 0x0;   

    rUMCON0 = 0x0;   
    rUMCON1 = 0x0;
    rUMCON2 = 0x0;    //��ʼ��3��ͨ����MODEM���ƼĴ�������ֹAFC   
    //Line control register 0: Normal,No parity,1 stop, 8 bits.
    rULCON0=0x3;
    // Control register 0��PCLK���������жϲ����������жϲ�����loopbackģʽ
    rUCON0  = 0x325;    
    //Baud rate divisior register 0 
    rUBRDIV0=( (int)(pclk/16/baud+0.5) -1 ); 
    //��0.5Ϊ��ʵ��ȡ�� 
    
    //�����������Ĵ���
    rSRCPND |= 0x1<<28; //��������жϹ���SRCPND[28]
	rSUBSRCPND |= 0x3; //����շ��ж�SUBSRCPND[1:0] 
	rINTPND |= 0x1<<28; //��������ж�����
	
	//�����ж����κ��շ��ж�����
	rINTMSK &= ~(0x1<<28);
   	rINTSUBMSK &= ~(0x3);
 }   
 



//����һ�ֽ�����
char Uart_Getch(void)
{
  	return RdURXH0;  //0x50000024������С��
}
//����һ���ַ���
void Uart_GetString(char *string)
{
    char c;
    while((c = Uart_Getch())!='\r')   //�س���
           *string++ = c;
}

//����һ�ֽ�
void Uart_SendByte(int data)
{
       while(!(rUTRSTAT0 & 0x4));
       delay(10);  //because the slow response of hyper_terminal 
       WrUTXH0(data);
}
//����һ���ַ���
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



	rSRCPND = rSRCPND; //��� SRCPND �Ĵ���
 	rSUBSRCPND = rSUBSRCPND;//��� EINTPEND �Ĵ���
 	rINTPND = rINTPND; //��� INTPND �Ĵ���
}
