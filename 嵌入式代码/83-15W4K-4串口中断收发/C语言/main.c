
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


/*********************************************************/
#define MAIN_Fosc		22118400L	//������ʱ��
//#define MAIN_Fosc		11059200L	//������ʱ��

#include	"STC15Fxxxx.H"


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
#define	RX1_Length	128		/* ���ջ��峤�� */
#define	RX2_Length	128		/* ���ջ��峤�� */
#define	RX3_Length	128		/* ���ջ��峤�� */
#define	RX4_Length	128		/* ���ջ��峤�� */

#define	UART_BaudRate1	115200UL	 /* ������ */
#define	UART_BaudRate2	 57600UL	 /* ������ */
#define	UART_BaudRate3	 38400UL	 /* ������ */
#define	UART_BaudRate4	 19200UL	 /* ������ */


/*************	���ر�������	**************/
u8	xdata	RX1_Buffer[RX1_Length];	//���ջ���
u8	xdata	RX2_Buffer[RX2_Length];	//���ջ���
u8	xdata	RX3_Buffer[RX3_Length];	//���ջ���
u8	xdata	RX4_Buffer[RX4_Length];	//���ջ���

u8	TX1_read,RX1_write;	//��д����(ָ��).
u8	TX2_read,RX2_write;	//��д����(ָ��).
u8	TX3_read,RX3_write;	//��д����(ָ��).
u8	TX4_read,RX4_write;	//��д����(ָ��).

bit	B_TX1_Busy,B_TX2_Busy,B_TX3_Busy,B_TX4_Busy;	// ����æ��־


/*************	���غ�������	**************/
void	UART1_config(u8 brt);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.
void	UART2_config(u8 brt);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ��Ч.
void	UART3_config(u8 brt);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer3��������.
void	UART4_config(u8 brt);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer4��������.
void 	PrintString1(u8 *puts);
void 	PrintString2(u8 *puts);
void 	PrintString3(u8 *puts);
void 	PrintString4(u8 *puts);




/**********************************************/
void main(void)
{

	P0n_standard(0xff);	//����Ϊ׼˫���
	P1n_standard(0xff);	//����Ϊ׼˫���
	P2n_standard(0xff);	//����Ϊ׼˫���
	P3n_standard(0xff);	//����Ϊ׼˫���
	P4n_standard(0xff);	//����Ϊ׼˫���
	P5n_standard(0xff);	//����Ϊ׼˫���
	
	UART1_config(1);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.
	UART2_config(2);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ��Ч.
	UART3_config(3);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer3��������.
	UART4_config(4);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer4��������.
	
	EA = 1;

	PrintString1("STC15F4K60S4 USART1 Test Prgramme!\r\n");
	PrintString2("STC15F4K60S4 USART2 Test Prgramme!\r\n");
	PrintString3("STC15F4K60S4 USART3 Test Prgramme!\r\n");
	PrintString4("STC15F4K60S4 USART4 Test Prgramme!\r\n");

	while (1)
	{
		if((TX1_read != RX1_write) && !B_TX1_Busy)	//�յ�������, ���ҷ��Ϳ���
		{
			B_TX1_Busy = 1;		//��־����æ
			SBUF = RX1_Buffer[TX1_read];	//��һ���ֽ�
			if(++TX1_read >= RX1_Length)	TX1_read = 0;	//�����������
		}

		if((TX2_read != RX2_write) && !B_TX2_Busy)	//�յ�������, ���ҷ��Ϳ���
		{
			B_TX2_Busy = 1;		//��־����æ
			S2BUF = RX2_Buffer[TX2_read];	//��һ���ֽ�
			if(++TX2_read >= RX2_Length)	TX2_read = 0;	//�����������
		}

		if((TX3_read != RX3_write) && !B_TX3_Busy)	//�յ�������, ���ҷ��Ϳ���
		{
			B_TX3_Busy = 1;		//��־����æ
			S3BUF = RX3_Buffer[TX3_read];	//��һ���ֽ�
			if(++TX3_read >= RX3_Length)	TX3_read = 0;	//�����������
		}

		if((TX4_read != RX4_write) && !B_TX4_Busy)	//�յ�������, ���ҷ��Ϳ���
		{
			B_TX4_Busy = 1;		//��־����æ
			S4BUF = RX4_Buffer[TX4_read];	//��һ���ֽ�
			if(++TX4_read >= RX4_Length)	TX4_read = 0;	//�����������
		}
	}
}


//========================================================================
// ����: SetTimer2Baudraye(u16 dat)
// ����: ����Timer2�������ʷ�������
// ����: dat: Timer2����װֵ.
// ����: none.
// �汾: VER1.0
// ����: 2014-11-28
// ��ע: 
//========================================================================
void	SetTimer2Baudraye(u16 dat)	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.
{
	AUXR &= ~(1<<4);	//Timer stop
	AUXR &= ~(1<<3);	//Timer2 set As Timer
	AUXR |=  (1<<2);	//Timer2 set as 1T mode
	TH2 = dat / 256;
	TL2 = dat % 256;
	IE2  &= ~(1<<2);	//��ֹ�ж�
	AUXR |=  (1<<4);	//Timer run enable
}


//========================================================================
// ����: void	UART1_config(u8 brt)
// ����: UART1��ʼ��������
// ����: brt: ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.
// ����: none.
// �汾: VER1.0
// ����: 2014-11-28
// ��ע: 
//========================================================================
void	UART1_config(u8 brt)	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.
{
	u8	i;
	/*********** ������ʹ�ö�ʱ��2 *****************/
	if(brt == 2)
	{
		AUXR |= 0x01;		//S1 BRT Use Timer2;
		SetTimer2Baudraye(65536UL - (MAIN_Fosc / 4) / UART_BaudRate1);
	}

	/*********** ������ʹ�ö�ʱ��1 *****************/
	else
	{
		TR1 = 0;
		AUXR &= ~0x01;		//S1 BRT Use Timer1;
		AUXR |=  (1<<6);	//Timer1 set as 1T mode
		TMOD &= ~(1<<6);	//Timer1 set As Timer
		TMOD &= ~0x30;		//Timer1_16bitAutoReload;
		TH1 = (65536UL - (MAIN_Fosc / 4) / UART_BaudRate1) / 256;
		TL1 = (65536UL - (MAIN_Fosc / 4) / UART_BaudRate1) % 256;
		ET1 = 0;	//��ֹ�ж�
		INT_CLKO &= ~0x02;	//�����ʱ��
		TR1  = 1;
	}
	/*************************************************/

	SCON = (SCON & 0x3f) | (1<<6);	// 8λ����, 1λ��ʼλ, 1λֹͣλ, ��У��
//	PS  = 1;	//�����ȼ��ж�
	ES  = 1;	//�����ж�
	REN = 1;	//�������
	P_SW1 = P_SW1 & 0x3f;	//�л��� P3.0 P3.1
//	P_SW1 = (P_SW1 & 0x3f) | (1<<6);	//�л���P3.6 P3.7
//	P_SW1 = (P_SW1 & 0x3f) | (2<<6);	//�л���P1.6 P1.7 (����ʹ���ڲ�ʱ��)

	for(i=0; i<RX1_Length; i++)		RX1_Buffer[i] = 0;
	B_TX1_Busy  = 0;
	TX1_read    = 0;
	RX1_write   = 0;
}


//========================================================================
// ����: void	UART2_config(u8 brt)
// ����: UART2��ʼ��������
// ����: brt: ѡ������, 2: ʹ��Timer2��������, ����ֵ: ��Ч.
// ����: none.
// �汾: VER1.0
// ����: 2014-11-28
// ��ע: 
//========================================================================
void	UART2_config(u8 brt)	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ��Ч.
{
	u8	i;
	/*********** �����ʹ̶�ʹ�ö�ʱ��2 *****************/
	if(brt == 2)	SetTimer2Baudraye(65536UL - (MAIN_Fosc / 4) / UART_BaudRate2);

	S2CON &= ~(1<<7);	// 8λ����, 1λ��ʼλ, 1λֹͣλ, ��У��
	IE2   |= 1;			//�����ж�
	S2CON |= (1<<4);	//�������
	P_SW2 &= ~1;		//�л��� P1.0 P1.1
//	P_SW2 |= 1;			//�л��� P4.6 P4.7

	for(i=0; i<RX2_Length; i++)		RX2_Buffer[i] = 0;
	B_TX2_Busy  = 0;
	TX2_read    = 0;
	RX2_write   = 0;
}

//========================================================================
// ����: void	UART3_config(u8 brt)
// ����: UART3��ʼ��������
// ����: brt: ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer3��������.
// ����: none.
// �汾: VER1.0
// ����: 2014-11-28
// ��ע: 
//========================================================================
void	UART3_config(u8 brt)	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer3��������.
{
	u8	i;
	/*********** �����ʹ̶�ʹ�ö�ʱ��2 *****************/
	if(brt == 2)
	{
		S3CON &= ~(1<<6);	//BRT select Timer2
		SetTimer2Baudraye(65536UL - (MAIN_Fosc / 4) / UART_BaudRate3);
	}
	/*********** ������ʹ�ö�ʱ��3 *****************/
	else
	{
		S3CON |= (1<<6);	//BRT select Timer3
		T4T3M &= 0xf0;		//ֹͣ����, �������λ
		IE2  &= ~(1<<5);	//��ֹ�ж�
		T4T3M |=  (1<<1);	//1T
		T4T3M &= ~(1<<2);	//��ʱ
		T4T3M &= ~1;		//�����ʱ��
		TH3 = (65536UL - (MAIN_Fosc / 4) / UART_BaudRate3) / 256;
		TL3 = (65536UL - (MAIN_Fosc / 4) / UART_BaudRate3) % 256;
		T4T3M |=  (1<<3);	//��ʼ����
	}
	
	S3CON &= ~(1<<5);	//��ֹ���ͨѶ��ʽ
	S3CON &= ~(1<<7);	// 8λ����, 1λ��ʼλ, 1λֹͣλ, ��У��
	IE2   |=  (1<<3);	//�����ж�
	S3CON |=  (1<<4);	//�������
	P_SW2 &= ~2;		//�л��� P0.0 P0.1
//	P_SW2 |= 2;			//�л��� P5.0 P5.1

	for(i=0; i<RX3_Length; i++)		RX3_Buffer[i] = 0;
	B_TX3_Busy  = 0;
	TX3_read    = 0;
	RX3_write   = 0;
}

//========================================================================
// ����: void	UART4_config(u8 brt)
// ����: UART4��ʼ��������
// ����: brt: ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer4��������.
// ����: none.
// �汾: VER1.0
// ����: 2014-11-28
// ��ע: 
//========================================================================
void	UART4_config(u8 brt)	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer4��������.
{
	u8	i;
	/*********** �����ʹ̶�ʹ�ö�ʱ��2 *****************/
	if(brt == 2)
	{
		S4CON &= ~(1<<6);	//BRT select Timer2
		SetTimer2Baudraye(65536UL - (MAIN_Fosc / 4) / UART_BaudRate4);
	}
	/*********** ������ʹ�ö�ʱ��3 *****************/
	else
	{
		S4CON |= (1<<6);	//BRT select Timer4
		T4T3M &= 0x0f;		//ֹͣ����, �������λ
		IE2   &= ~(1<<6);	//��ֹ�ж�
		T4T3M |=  (1<<5);	//1T
		T4T3M &= ~(1<<6);	//��ʱ
		T4T3M &= ~(1<<4);	//�����ʱ��
		TH4 = (65536UL - (MAIN_Fosc / 4) / UART_BaudRate4) / 256;
		TL4 = (65536UL - (MAIN_Fosc / 4) / UART_BaudRate4) % 256;
		T4T3M |=  (1<<7);	//��ʼ����
	}
	
	S4CON &= ~(1<<5);	//��ֹ���ͨѶ��ʽ
	S4CON &= ~(1<<7);	// 8λ����, 1λ��ʼλ, 1λֹͣλ, ��У��
	IE2   |=  (1<<4);	//�����ж�
	S4CON |=  (1<<4);	//�������
	P_SW2 &= ~4;		//�л��� P0.2 P0.3
//	P_SW2 |= 4;			//�л��� P5.2 P5.3

	for(i=0; i<RX4_Length; i++)		RX4_Buffer[i] = 0;
	B_TX4_Busy  = 0;
	TX4_read    = 0;
	RX4_write   = 0;
}


void PrintString1(u8 *puts)
{
    for (; *puts != 0;	puts++)
	{
		B_TX1_Busy = 1;		//��־����æ
		SBUF = *puts;		//��һ���ֽ�
		while(B_TX1_Busy);	//�ȴ��������
	}
}

void PrintString2(u8 *puts)
{
    for (; *puts != 0;	puts++)
	{
		B_TX2_Busy = 1;		//��־����æ
		S2BUF = *puts;		//��һ���ֽ�
		while(B_TX2_Busy);	//�ȴ��������
	}
}

void PrintString3(u8 *puts)
{
    for (; *puts != 0;	puts++)
	{
		B_TX3_Busy = 1;		//��־����æ
		S3BUF = *puts;		//��һ���ֽ�
		while(B_TX3_Busy);	//�ȴ��������
	}
}

void PrintString4(u8 *puts)
{
    for (; *puts != 0;	puts++)
	{
		B_TX4_Busy = 1;		//��־����æ
		S4BUF = *puts;		//��һ���ֽ�
		while(B_TX4_Busy);	//�ȴ��������
	}
}



/********************* UART1�жϺ���************************/
void UART1_int (void) interrupt UART1_VECTOR
{
	if(RI)
	{
		RI = 0;
		RX1_Buffer[RX1_write] = SBUF;
		if(++RX1_write >= RX1_Length)	RX1_write = 0;
	}

	if(TI)
	{
		TI = 0;
		B_TX1_Busy = 0;
	}
}

/********************* UART2�жϺ���************************/
void UART2_int (void) interrupt UART2_VECTOR
{
	if(RI2)
	{
		CLR_RI2();
		RX2_Buffer[RX2_write] = S2BUF;
		if(++RX2_write >= RX2_Length)	RX2_write = 0;
	}

	if(TI2)
	{
		CLR_TI2();
		B_TX2_Busy = 0;
	}

}

/********************* UART3�жϺ���************************/
void UART3_int (void) interrupt UART3_VECTOR
{
	if(RI3)
	{
		CLR_RI3();
		RX3_Buffer[RX3_write] = S3BUF;
		if(++RX3_write >= RX3_Length)	RX3_write = 0;
	}

	if(TI3)
	{
		CLR_TI3();
		B_TX3_Busy = 0;
	}

}

/********************* UART4�жϺ���************************/
void UART4_int (void) interrupt UART4_VECTOR
{
	if(RI4)
	{
		CLR_RI4();
		RX4_Buffer[RX4_write] = S4BUF;
		if(++RX4_write >= RX4_Length)	RX4_write = 0;
	}

	if(TI4)
	{
		CLR_TI4();
		B_TX4_Busy = 0;
	}

}



