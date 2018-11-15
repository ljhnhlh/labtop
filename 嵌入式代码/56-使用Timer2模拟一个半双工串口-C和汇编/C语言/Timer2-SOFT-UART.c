/*---------------------------------------------------------------------*/
/* --- STC MCU Limited ------------------------------------------------*/
/* --- Mobile: (86)13922805190 ----------------------------------------*/
/* --- Fax: 86-755-82905966 -------------------------------------------*/
/* --- Tel: 86-755-82948412 -------------------------------------------*/
/* --- Web: www.STCMCU.com --------------------------------------------*/
/* ���Ҫ��������Ӧ�ô˴���,����������ע��ʹ���˺꾧�Ƽ������ϼ�����   */
/*---------------------------------------------------------------------*/

/*************	����˵��	**************

ʹ��STC15ϵ�е�Timer2����ģ�⴮��. P3.0����, P3.1����, ��˫��.

�ٶ�����оƬ�Ĺ���Ƶ��Ϊ22118400Hz. ʱ��Ϊ5.5296MHZ ~ 35MHZ. 

�����ʸߣ���ʱ��ҲҪѡ��, ����ʹ�� 22.1184MHZ, 11.0592MHZ.

���Է���: ��λ����������, MCU�յ����ݺ�ԭ������.

���ڹ̶�����: 1λ��ʼλ, 8λ����λ, 1λֹͣλ,  �������ڷ�Χ����.

1200 ~ 115200 bps @ 33.1776MHZ
 600 ~ 115200 bps @ 22.1184MHZ
 600 ~  76800 bps @ 18.4320MHZ
 300 ~  57600 bps @ 11.0592MHZ
 150 ~  19200 bps @  5.5296MHZ

******************************************/

#include	<reg52.h>

#define MAIN_Fosc		22118400UL	//������ʱ��
#define	UART3_Baudrate	115200UL	//���岨����
#define	RX_Lenth		32			//���ճ���

#define	UART3_BitTime	(MAIN_Fosc / UART3_Baudrate)

typedef 	unsigned char	u8;
typedef 	unsigned int	u16;
typedef 	unsigned long	u32;

sfr P1M1 = 0x91;	//P1M1.n,P1M0.n 	=00--->Standard,	01--->push-pull		ʵ����1T�Ķ�һ��
sfr P1M0 = 0x92;	//					=10--->pure input,	11--->open drain
sfr P0M1 = 0x93;	//P0M1.n,P0M0.n 	=00--->Standard,	01--->push-pull
sfr P0M0 = 0x94;	//					=10--->pure input,	11--->open drain
sfr P2M1 = 0x95;	//P2M1.n,P2M0.n 	=00--->Standard,	01--->push-pull
sfr P2M0 = 0x96;	//					=10--->pure input,	11--->open drain
sfr P3M1  = 0xB1;	//P3M1.n,P3M0.n 	=00--->Standard,	01--->push-pull
sfr P3M0  = 0xB2;	//					=10--->pure input,	11--->open drain
sfr P4M1  = 0xB3;	//P4M1.n,P4M0.n 	=00--->Standard,	01--->push-pull
sfr P4M0  = 0xB4;	//					=10--->pure input,	11--->open drain
sfr P5M1   = 0xC9;	//	P5M1.n,P5M0.n 	=00--->Standard,	01--->push-pull
sfr P5M0   = 0xCA;	//					=10--->pure input,	11--->open drain
sfr P6M1   = 0xCB;	//	P5M1.n,P5M0.n 	=00--->Standard,	01--->push-pull
sfr P6M0   = 0xCC;	//					=10--->pure input,	11--->open drain
sfr	P7M1   = 0xE1;
sfr	P7M0   = 0xE2;

sfr IE2  = 0xAF;
sfr	AUXR = 0x8E;
sfr INT_CLKO = 0x8F;
sfr	T2H  = 0xD6;
sfr	T2L  = 0xD7;

u8	Tx3_read;			//���Ͷ�ָ��
u8	Rx3_write;			//����дָ��
u8 	idata	buf3[RX_Lenth];	//���ջ���

u16	RxTimeOut;
bit	B_RxOk;		//���ս�����־


//===================== ģ�⴮�����===========================
sbit P_RX3 = P3^0;	//����ģ�⴮�ڽ���IO
sbit P_TX3 = P3^1;	//����ģ�⴮�ڷ���IO

u8  Tx3_DAT;		// ������λ����, �û����ɼ�
u8  Rx3_DAT;		// ������λ����, �û����ɼ�
u8  Tx3_BitCnt;		// �������ݵ�λ������, �û����ɼ�
u8  Rx3_BitCnt;		// �������ݵ�λ������, �û����ɼ�
u8	Rx3_BUF;		// ���յ����ֽ�, �û���ȡ
u8	Tx3_BUF;		// Ҫ���͵��ֽ�, �û�д��
bit	Rx3_Ring;		// ���ڽ��ձ�־, �Ͳ����ʹ��, �û����򲻿ɼ�
bit	Tx3_Ting;		// ���ڷ��ͱ�־, �û���1������, �ײ㷢�������0
bit	RX3_End;		// ���յ�һ���ֽ�, �û���ѯ ����0
//=============================================================

void	UART_Init(void);


/******************** ������ **************************/
void main(void)
{
	P0M1 = 0;	P0M0 = 0;	//����Ϊ׼˫���
	P1M1 = 0;	P1M0 = 0;	//����Ϊ׼˫���
	P2M1 = 0;	P2M0 = 0;	//����Ϊ׼˫���
	P3M1 = 0;	P3M0 = 0;	//����Ϊ׼˫���
	P4M1 = 0;	P4M0 = 0;	//����Ϊ׼˫���
	P5M1 = 0;	P5M0 = 0;	//����Ϊ׼˫���
	P6M1 = 0;	P6M0 = 0;	//����Ϊ׼˫���
	P7M1 = 0;	P7M0 = 0;	//����Ϊ׼˫���
	
	UART_Init();	//PCA��ʼ��
	EA = 1;
	
	while (1)		//user's function
	{
		if (RX3_End)		// ����Ƿ��յ�һ���ֽ�
		{
			RX3_End = 0;	// �����־
			buf3[Rx3_write] = Rx3_BUF;	// д�뻺��
			if(++Rx3_write >= RX_Lenth)	Rx3_write = 0;	// ָ����һ��λ��,  ������
			RxTimeOut = 1000;	//װ�س�ʱʱ��
		}
		if(RxTimeOut != 0)		// ��ʱʱ���Ƿ��0?
		{
			if(--RxTimeOut == 0)	// (��ʱʱ��  - 1) == 0?
			{
				B_RxOk = 1;
				AUXR &=  ~(1<<4);	//Timer2 ֹͣ����
				INT_CLKO &= ~(1 << 6);	//��ֹINT4�ж�
				T2H = (65536 - UART3_BitTime) / 256;	//����λ
				T2L = (65536 - UART3_BitTime) % 256;	//����λ
				AUXR |=  (1<<4);	//Timer2 ��ʼ����
			}
		}
		
		if(B_RxOk)		// ����Ƿ����OK?
		{
			if (!Tx3_Ting)		// ����Ƿ��Ϳ���
			{
				if (Tx3_read != Rx3_write)	// ����Ƿ��յ����ַ�
				{
					Tx3_BUF = buf3[Tx3_read];	// �ӻ����һ���ַ�����
					Tx3_Ting = 1;				// ���÷��ͱ�־
					if(++Tx3_read >= RX_Lenth)	Tx3_read = 0;	// ָ����һ��λ��,  ������
				}
				else
				{
					B_RxOk = 0;
					AUXR &=  ~(1<<4);		//Timer2 ֹͣ����
					INT_CLKO |=  (1 << 6);	//����INT4�ж�
				}
			}
		}
	}
}


//========================================================================
// ����: void	UART_Init(void)
// ����: UART��ʼ������.
// ����: none
// ����: none.
// �汾: V1.0, 2013-11-22
//========================================================================
void	UART_Init(void)
{
	Tx3_read  = 0;
	Rx3_write = 0;
	Tx3_Ting  = 0;
	Rx3_Ring  = 0;
	RX3_End   = 0;
	Tx3_BitCnt = 0;
	RxTimeOut = 0;
	B_RxOk = 0;

	AUXR &=  ~(1<<4);		// Timer2 ֹͣ����
	T2H = (65536 - UART3_BitTime) / 256;	// ����λ
	T2L = (65536 - UART3_BitTime) % 256;	// ����λ
	INT_CLKO |=  (1 << 6);	// ����INT4�ж�
	IE2  |=  (1<<2);		// ����Timer2�ж�
	AUXR |=  (1<<2);		// 1T
}
//======================================================================

//========================================================================
// ����: void	timer2_int (void) interrupt 12
// ����: Timer2�жϴ������.
// ����: None
// ����: none.
// �汾: V1.0, 2012-11-22
//========================================================================
void	timer2_int (void) interrupt 12
{
	if(Rx3_Ring)		//���յ���ʼλ
	{
		if (--Rx3_BitCnt == 0)		//������һ֡����
		{
			Rx3_Ring = 0;			//ֹͣ����
			Rx3_BUF = Rx3_DAT;		//�洢���ݵ�������
			RX3_End = 1;
			AUXR &=  ~(1<<4);	//Timer2 ֹͣ����
			INT_CLKO |=  (1 << 6);	//����INT4�ж�
		}
		else
		{
			Rx3_DAT >>= 1;			  		//�ѽ��յĵ�b���� �ݴ浽 RxShiftReg(���ջ���)
			if(P_RX3) Rx3_DAT |= 0x80;  	//shift RX data to RX buffer
		}
	}

	if(Tx3_Ting)					// ������, �˳�
	{
		if(Tx3_BitCnt == 0)			//���ͼ�����Ϊ0 �������ֽڷ��ͻ�û��ʼ
		{
			P_TX3 = 0;				//���Ϳ�ʼλ
			Tx3_DAT = Tx3_BUF;		//�ѻ�������ݷŵ����͵�buff
			Tx3_BitCnt = 9;			//��������λ�� (8����λ+1ֹͣλ)
		}
		else						//���ͼ�����Ϊ��0 ���ڷ�������
		{
			if (--Tx3_BitCnt == 0)	//���ͼ�������Ϊ0 �������ֽڷ��ͽ���
			{
				P_TX3 = 1;			//��ֹͣλ����
				Tx3_Ting = 0;		//����ֹͣ
			}
			else
			{
				Tx3_DAT >>= 1;		//�����λ�͵� CY(�洦��־λ)
				P_TX3 = CY;			//����һ��bit����
			}
		}
	}
}


/********************* INT4�жϺ��� *************************/
void Ext_INT4 (void) interrupt 16
{
	AUXR &=  ~(1<<4);	//Timer2 ֹͣ����
	T2H = (65536 - (UART3_BitTime / 2 + UART3_BitTime)) / 256;	//��ʼλ + �������λ
	T2L = (65536 - (UART3_BitTime / 2 + UART3_BitTime)) % 256;	//��ʼλ + �������λ
	AUXR |=  (1<<4);	//Timer2 ��ʼ����
	Rx3_Ring = 1;		//��־���յ���ʼλ
	Rx3_BitCnt = 9;		//��ʼ�����յ�����λ��(8������λ+1��ֹͣλ)
	
	INT_CLKO &= ~(1 << 6);	//��ֹINT4�ж�
	T2H = (65536 - UART3_BitTime) / 256;	//����λ
	T2L = (65536 - UART3_BitTime) % 256;	//����λ
}




