
/*---------------------------------------------------------------------*/
/* --- STC MCU International Limited ----------------------------------*/
/* --- STC 1T Series MCU Demo Programme -------------------------------*/
/* --- Mobile: (86)13922805190 ----------------------------------------*/
/* --- Fax: 86-0513-55012956,55012947,55012969 ------------------------*/
/* --- Tel: 86-0513-55012928,55012929,55012966 ------------------------*/
/* --- Web: www.GXWMCU.com --------------------------------------------*/
/* --- QQ:  800003751 -------------------------------------------------*/
/* ���Ҫ�ڳ�����ʹ�ô˴���,���ڳ�����ע��ʹ���˺꾧�Ƽ������ϼ�����   */
/*---------------------------------------------------------------------*/


#define 	MAIN_Fosc			22118400L	//������ʱ��
#include	"STC15Fxxxx.H"

#include	"app_test_xdata.h"

/*************	����˵��	**************

������ҵ�32K xdata����
���Է�ʽ: 
1: д��0x55, �������ж��Ƿ�ȫ����0x55.
2: д��0xaa, �������ж��Ƿ�ȫ����0xaa.
3: д��32768�ֽڵĺ����ֿ�(�������������), �������Ƚ�.

ͨ�����ڷ��͵����ַ�x��X, ��ʼ����, ��������صĲ��Խ��.

��������115200bps, 8, N, 1,  ��ʱ��Ϊ22.1184MHZ. �л���P1.6 P1.7.

******************************************/

/*************	���س�������	**************/
#define		Baudrate1		115200L

#define		XDATA_LENTH		32768	//xdata����
#define		HZK_LENTH		32768	//�ֿⳤ��



/*************	���ر�������	**************/
#define		UART1_BUF_LENGTH	64	//���ڻ��峤��

u8	RX1_TimeOut;
u8	TX1_Cnt;	//���ͼ���
u8	RX1_Cnt;	//���ռ���
bit	B_TX1_Busy;	//����æ��־

u8 	xdata 	RX1_Buffer[UART1_BUF_LENGTH];	//���ջ���


void	delay_ms(u8 ms);
u8		TestXRAM(void);
void	TxErrorAddress(void);
void	Xdata_Test(void);

void	delay_ms(u8 ms);
void	RX1_Check(void);
void	UART1_config(u8 brt);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.
void	PrintString1(u8 *puts);
void	UART1_TxByte(u8 dat);





/***************** ������ *****************************/
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

	delay_ms(10);
	UART1_config(1);
	EA = 1;		//ȫ���ж�����

	PrintString1("STC15F2K60S2 xdata test programme!\r\n");	//SUART1����һ���ַ���
	PrintString1("\r\nͨ�����ڷ��͵����ַ�x��X, ��ʼ����.\r\n");

	BUS_SPEED_1T();	//1T  2T  4T  8T	3V@22MHZ��1T����ʴ���
	ExternalRAM_enable();	//�����ⲿXDATA
//	InternalRAM_enable();	//�����ڲ�XDATA

	while (1)
	{
		delay_ms(1);
		if(RX1_TimeOut > 0)		//��ʱ����
		{
			if(--RX1_TimeOut == 0)	//����ͨѶ����
			{
				if(RX1_Cnt > 0)		//�յ������ֽ���
				{
					if(RX1_Cnt == 1)	Xdata_Test();	//���ֽ�����
				}
				RX1_Cnt = 0;
			}
		}
	}
}

//========================================================================
// ����: void  delay_ms(unsigned char ms)
// ����: ��ʱ������
// ����: ms,Ҫ��ʱ��ms��, ����ֻ֧��1~255ms. �Զ���Ӧ��ʱ��.
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
void  delay_ms(u8 ms)
{
     u16 i;
	 do{
	      i = MAIN_Fosc / 13000;
		  while(--i)	;   //14T per loop
     }while(--ms);
}


/*************  ����xdata���� *****************/
u8	TestXRAM(void)
{
	u16	ptc;
	u8	xdata *ptx;
	u16	i,j;

	for(ptx=0; ptx<XDATA_LENTH; ptx++)	*ptx = 0x55;	//�����Ƿ���λ��·
	for(ptx=0; ptx<XDATA_LENTH; ptx++)	if(*ptx != 0x55)	return 1;	//����0x55����

	for(ptx=0; ptx<XDATA_LENTH; ptx++)	*ptx = 0xaa;	//�����Ƿ���λ��·
	for(ptx=0; ptx<XDATA_LENTH; ptx++)	if(*ptx != 0xaa)	return 2;	//����0xaa����

	i = 0;
	for(ptx=0; ptx<XDATA_LENTH; ptx++)
	{
		*ptx = (u8)(i >> 8);
		ptx++;
		*ptx = (u8)i;
		i++;
	}
	i = 0;
	for(ptx=0; ptx<XDATA_LENTH; ptx++)
	{
		j = *ptx;
		ptx++;
		j = (j << 8) + *ptx;
		if(i != j)	return 3;	//д�������ִ���
		i++;
	}

	ptx = 0;
	for(ptc=0; ptc<HZK_LENTH; ptc++)	{*ptx = hz[ptc];	ptx++;}
	ptx = 0;
	for(ptc=0; ptc<HZK_LENTH; ptc++)
	{
		if(*ptx != hz[ptc])	return 4;	//д�ֿ����
		ptx++;
	}

	return 0;

}


/*************  ���ʹ����ַ���� *****************/
void	TxErrorAddress(void)
{
	u16	i;
	i = 0x00fd;
	PrintString1("�����ַ = ");
	if(i >= 10000)	UART1_TxByte(i/10000+'0'),	i %= 10000;
	UART1_TxByte(i/1000+'0'),	i %= 1000;
	UART1_TxByte(i/100+'0'),	i %= 100;
	UART1_TxByte(i/10+'0');
	UART1_TxByte(i%10+'0');
	UART1_TxByte(0x0d);
	UART1_TxByte(0x0a);
}

/*************  xdata���Է�����Ϣ���� *****************/
void	Xdata_Test(void)
{
	u8	i;
	if((RX1_Buffer[0] == 'x') || (RX1_Buffer[0] == 'X'))
	{
		PrintString1("���ڲ��� xdata, ���Ժ�......\r\n");
		i = TestXRAM();
			 if(i == 0)	PrintString1("���� xdata �����ȷ!\r\n");
		else if(i == 1)	PrintString1("���� xdata д��0x55����!  "),	TxErrorAddress();
		else if(i == 2)	PrintString1("���� xdata д��0xaa����!  "),	TxErrorAddress();
		else if(i == 3)	PrintString1("���� xdata ����д�����!  "),	TxErrorAddress();
		else if(i == 4)	PrintString1("���� xdata д���ֿ����!  "),	TxErrorAddress();
	}
}


//========================================================================
// ����: void	UART1_TxByte(u8 dat)
// ����: ����һ���ֽ�.
// ����: ��.
// ����: ��.
// �汾: V1.0, 2014-6-30
//========================================================================

void	UART1_TxByte(u8 dat)
{
	SBUF = dat;
	B_TX1_Busy = 1;
	while(B_TX1_Busy);
}

//========================================================================
// ����: void PrintString1(u8 *puts)
// ����: ����1�����ַ���������
// ����: puts:  �ַ���ָ��.
// ����: none.
// �汾: VER1.0
// ����: 2014-11-28
// ��ע: 
//========================================================================
void PrintString1(u8 *puts)	//����һ���ַ���
{
    for (; *puts != 0;	puts++)   	UART1_TxByte(*puts);  	//����ֹͣ��0����
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
	/*********** ������ʹ�ö�ʱ��2 *****************/
	if(brt == 2)
	{
		AUXR |= 0x01;		//S1 BRT Use Timer2;
		SetTimer2Baudraye(65536UL - (MAIN_Fosc / 4) / Baudrate1);
	}

	/*********** ������ʹ�ö�ʱ��1 *****************/
	else
	{
		TR1 = 0;
		AUXR &= ~0x01;		//S1 BRT Use Timer1;
		AUXR |=  (1<<6);	//Timer1 set as 1T mode
		TMOD &= ~(1<<6);	//Timer1 set As Timer
		TMOD &= ~0x30;		//Timer1_16bitAutoReload;
		TH1 = (u8)((65536UL - (MAIN_Fosc / 4) / Baudrate1) / 256);
		TL1 = (u8)((65536UL - (MAIN_Fosc / 4) / Baudrate1) % 256);
		ET1 = 0;	//��ֹ�ж�
		INT_CLKO &= ~0x02;	//�����ʱ��
		TR1  = 1;
	}
	/*************************************************/

	SCON = (SCON & 0x3f) | 0x40;	//UART1ģʽ, 0x00: ͬ����λ���, 0x40: 8λ����,�ɱ䲨����, 0x80: 9λ����,�̶�������, 0xc0: 9λ����,�ɱ䲨����
//	PS  = 1;	//�����ȼ��ж�
	ES  = 1;	//�����ж�
	REN = 1;	//�������
	P_SW1 &= 0x3f;
	P_SW1 |= 0x80;		//UART1 switch to, 0x00: P3.0 P3.1, 0x40: P3.6 P3.7, 0x80: P1.6 P1.7 (����ʹ���ڲ�ʱ��)
//	PCON2 |=  (1<<4);	//�ڲ���·RXD��TXD, ���м�, ENABLE,DISABLE

	B_TX1_Busy = 0;
	TX1_Cnt = 0;
	RX1_Cnt = 0;
}


//========================================================================
// ����: void UART1_int (void) interrupt UART1_VECTOR
// ����: UART1�жϺ�����
// ����: nine.
// ����: none.
// �汾: VER1.0
// ����: 2014-11-28
// ��ע: 
//========================================================================
void UART1_int (void) interrupt UART1_VECTOR
{
	if(RI)
	{
		RI = 0;
		if(RX1_Cnt >= UART1_BUF_LENGTH)	RX1_Cnt = 0;
		RX1_Buffer[RX1_Cnt] = SBUF;
		RX1_Cnt++;
		RX1_TimeOut = 5;
	}

	if(TI)
	{
		TI = 0;
		B_TX1_Busy = 0;
	}
}

