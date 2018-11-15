
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


#ifndef __USART_H
#define __USART_H	 

#include	"config.h"

#define	RX_Length	128

#define	USART1	1
#define	USART2	2
#define	USART3	3
#define	USART4	4

#define	UART_ShiftRight	0		/* ͬ����λ��� */
#define	UART_8bit_BRTx	(1<<6)	/* 8λ����,�ɱ䲨���� */
#define	UART_9bit		(2<<6)	/* 9λ����,�̶������� */
#define	UART_9bit_BRTx	(3<<6)	/* 9λ����,�ɱ䲨���� */

#define	UART1_SW_P30_P31	0
#define	UART1_SW_P36_P37	(1<<6)
#define	UART1_SW_P16_P17	(2<<6)	/*����ʹ���ڲ�ʱ�� */
#define	UART2_SW_P10_P11	0
#define	UART2_SW_P46_P47	1
#define	UART3_SW_P00_P01	0
#define	UART3_SW_P50_P51	2
#define	UART4_SW_P02_P03	0
#define	UART4_SW_P52_P53	4


#define	BRT_Timer1	1
#define	BRT_Timer2	2
#define	BRT_Timer3	3
#define	BRT_Timer4	4

typedef struct
{ 
	u8	id;				//���ں�

	u8	TX_read;		//���Ͷ�ָ��
	u8	RX_write;		//����дָ��
	u8	TX_Busy;		//æ��־
	u8	*RX_Buffer;
} COMx_Define; 

typedef struct
{
	u8	UART_Mode;			//ģʽ,         UART_ShiftRight,UART_8bit_BRTx,UART_9bit,UART_9bit_BRTx
	u8	UART_BRT_Use;		//ʹ�ò�����,   BRT_Timer1,BRT_Timer2
	u32	UART_BaudRate;		//������,       ENABLE,DISABLE
	u8	UART_RxEnable;		//�������,   ENABLE,DISABLE
	u8	UART_Interrupt;		//�жϿ���,   ENABLE,DISABLE
	u8	UART_P_SW;			//�л��˿�,   UART1_SW_P30_P31,UART1_SW_P36_P37,UART1_SW_P16_P17(����ʹ���ڲ�ʱ��)

} COMx_InitDefine; 

extern	COMx_Define	COM1,COM2,COM3,COM4;
extern	u8 	xdata RX1_Buffer[RX_Length];	//���ջ���
extern	u8 	xdata RX2_Buffer[RX_Length];	//���ջ���
extern	u8 	xdata RX3_Buffer[RX_Length];	//���ջ���
extern	u8 	xdata RX4_Buffer[RX_Length];	//���ջ���

u8	USART_Configuration(u8 UARTx, COMx_InitDefine *COMx);
void PrintString(u8 UARTx, u8 *puts);

#endif

