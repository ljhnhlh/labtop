
/*------------------------------------------------------------------*/
/* --- STC MCU International Limited -------------------------------*/
/* --- STC 1T Series MCU RC Demo -----------------------------------*/
/* --- Mobile: (86)13922805190 -------------------------------------*/
/* --- Fax: 86-0513-55012956,55012947,55012969 ---------------------*/
/* --- Tel: 86-0513-55012928,55012929,55012966 ---------------------*/
/* --- Web: www.GXWMCU.com -----------------------------------------*/
/* --- QQ:  800003751 ----------------------------------------------*/
/* If you want to use the program or the program referenced in the  */
/* article, please specify in which data and procedures from STC    */
/*------------------------------------------------------------------*/


#include	"config.h"
#include	"USART.h"


/*************	����˵��	**************

4����ȫ˫���жϷ�ʽ�շ�ͨѶ����

ͨ��PC��MCU��������, MCU�յ���ͨ�����ڰ��յ�������ԭ������.

Ĭ�ϲ���:
�������þ�Ϊ 1λ��ʼλ, 8λ����λ, 1λֹͣλ, ��У��.
ÿ�����ڿ���ʹ�ò�ͬ�Ĳ�����.
����1(P3.0 P3.1): 115200bps.
����2(P1.0 P1.1):  57600bps.
����3(P0.0 P0.1):  38400bps.
����4(P0.2 P0.3):  19200bps.

******************************************/

/*************	���س�������	**************/


/*************	���ر�������	**************/


/*************	���غ�������	**************/



/*************  �ⲿ�����ͱ������� *****************/




/***************** �������ú��� *****************************/
void	UART_config(void)
{
	COMx_InitDefine		COMx_InitStructure;					//�ṹ����
	COMx_InitStructure.UART_Mode      = UART_8bit_BRTx;		//ģʽ,       UART_ShiftRight,UART_8bit_BRTx,UART_9bit,UART_9bit_BRTx
	COMx_InitStructure.UART_BRT_Use   = BRT_Timer1;			//ʹ�ò�����,   BRT_Timer1, BRT_Timer2 (ע��: ����2�̶�ʹ��BRT_Timer2)
	COMx_InitStructure.UART_BaudRate  = 115200ul;			//������, һ�� 110 ~ 115200
	COMx_InitStructure.UART_RxEnable  = ENABLE;				//��������,   ENABLE��DISABLE
	COMx_InitStructure.UART_Interrupt = ENABLE;				//�ж�����,   ENABLE��DISABLE
	COMx_InitStructure.UART_P_SW      = UART1_SW_P30_P31;	//�л��˿�,   UART1_SW_P30_P31,UART1_SW_P36_P37,UART1_SW_P16_P17(����ʹ���ڲ�ʱ��)
	USART_Configuration(USART1, &COMx_InitStructure);		//��ʼ������1 USART1,USART2,USART3,USART4

	COMx_InitStructure.UART_Mode      = UART_8bit_BRTx;		//ģʽ,       UART_8bit_BRTx,UART_9bit_BRTx
	COMx_InitStructure.UART_BaudRate  = 57600ul;			//������,     110 ~ 115200
	COMx_InitStructure.UART_RxEnable  = ENABLE;				//��������,   ENABLE��DISABLE
	COMx_InitStructure.UART_Interrupt = ENABLE;				//�ж�����,   ENABLE��DISABLE
	COMx_InitStructure.UART_P_SW      = UART2_SW_P10_P11;	//�л��˿�,   UART2_SW_P10_P11, UART2_SW_P46_P47
	USART_Configuration(USART2, &COMx_InitStructure);		//��ʼ������2 USART1,USART2,USART3,USART4

	COMx_InitStructure.UART_Mode      = UART_8bit_BRTx;		//ģʽ,       UART_8bit_BRTx,UART_9bit_BRTx
	COMx_InitStructure.UART_BRT_Use   = BRT_Timer3;			//ʹ�ò�����, BRT_Timer3, BRT_Timer2
	COMx_InitStructure.UART_BaudRate  = 38400ul;			//������,     110 ~ 115200
	COMx_InitStructure.UART_RxEnable  = ENABLE;				//��������,   ENABLE��DISABLE
	COMx_InitStructure.UART_Interrupt = ENABLE;				//�ж�����,   ENABLE��DISABLE
	COMx_InitStructure.UART_P_SW      = UART3_SW_P00_P01;	//�л��˿�,   UART3_SW_P00_P01, UART3_SW_P50_P51
	USART_Configuration(USART3, &COMx_InitStructure);		//��ʼ������2 USART1,USART2,USART3,USART4

	COMx_InitStructure.UART_Mode      = UART_8bit_BRTx;		//ģʽ,       UART_8bit_BRTx,UART_9bit_BRTx
	COMx_InitStructure.UART_BRT_Use   = BRT_Timer4;			//ʹ�ò�����, BRT_Timer4, BRT_Timer2
	COMx_InitStructure.UART_BaudRate  = 19200ul;			//������,     110 ~ 115200
	COMx_InitStructure.UART_RxEnable  = ENABLE;				//��������,   ENABLE��DISABLE
	COMx_InitStructure.UART_Interrupt = ENABLE;				//�ж�����,   ENABLE��DISABLE
	COMx_InitStructure.UART_P_SW      = UART4_SW_P02_P03;	//�л��˿�,   UART4_SW_P02_P03, UART4_SW_P52_P53
	USART_Configuration(USART4, &COMx_InitStructure);		//��ʼ������4 USART1,USART2,USART3,USART4

}


/***************** ������ *****************************/
void main(void)
{
	P0n_standard(0xff);	//����Ϊ׼˫���
	P1n_standard(0xff);	//����Ϊ׼˫���
	P2n_standard(0xff);	//����Ϊ׼˫���
	P3n_standard(0xff);	//����Ϊ׼˫���
	P4n_standard(0xff);	//����Ϊ׼˫���
	P5n_standard(0xff);	//����Ϊ׼˫���
	
	UART_config();	//���ڳ�ʼ��
	EA = 1;

	PrintString(USART1, "STC15F4K60S4 USART1 Test Prgramme!\r\n");	//USART1����һ���ַ���
	PrintString(USART2, "STC15F4K60S4 USART2 Test Prgramme!\r\n");	//USART2����һ���ַ���
	PrintString(USART3, "STC15F4K60S4 USART3 Test Prgramme!\r\n");	//USART3����һ���ַ���
	PrintString(USART4, "STC15F4K60S4 USART4 Test Prgramme!\r\n");	//USART4����һ���ַ���

	while (1)
	{
		if((COM1.TX_read != COM1.RX_write) && (COM1.TX_Busy == 0))	//�յ�������, ���ҷ��Ϳ���
		{
			COM1.TX_Busy = 1;		//��־����æ
			SBUF = COM1.RX_Buffer[COM1.TX_read];	//��һ���ֽ�
			if(++COM1.TX_read >= RX_Length)	COM1.TX_read = 0;	//�����������
		}

		if((COM2.TX_read != COM2.RX_write) && (COM2.TX_Busy == 0))	//�յ�������, ���ҷ��Ϳ���
		{
			COM2.TX_Busy = 1;		//��־����æ
			S2BUF = COM2.RX_Buffer[COM2.TX_read];	//��һ���ֽ�
			if(++COM2.TX_read >= RX_Length)	COM2.TX_read = 0;	//�����������
		}

		if((COM3.TX_read != COM3.RX_write) && (COM3.TX_Busy == 0))	//�յ�������, ���ҷ��Ϳ���
		{
			COM3.TX_Busy = 1;		//��־����æ
			S3BUF = COM3.RX_Buffer[COM3.TX_read];	//��һ���ֽ�
			if(++COM3.TX_read >= RX_Length)	COM3.TX_read = 0;	//�����������
		}

		if((COM4.TX_read != COM4.RX_write) && (COM4.TX_Busy == 0))	//�յ�������, ���ҷ��Ϳ���
		{
			COM4.TX_Busy = 1;		//��־����æ
			S4BUF = COM4.RX_Buffer[COM4.TX_read];	//��һ���ֽ�
			if(++COM4.TX_read >= RX_Length)	COM4.TX_read = 0;	//�����������
		}
	}
}



