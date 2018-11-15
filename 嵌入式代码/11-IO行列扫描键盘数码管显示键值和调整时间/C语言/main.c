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


/*************	��������˵��	**************

��STC��MCU��IO��ʽ����74HC595����8λ����ܡ�

��ʾЧ��Ϊ: ����ʱ��.

ʹ��Timer0��16λ�Զ���װ������1ms����,�������������������, �û��޸�MCU��ʱ��Ƶ��ʱ,�Զ���ʱ��1ms.

���4λLED��ʾʱ��(Сʱ,����), �ұ������λ��ʾ����ֵ.

����ɨ�谴������Ϊ17~32.

����ֻ֧�ֵ�������, ��֧�ֶ��ͬʱ����, ���������в���Ԥ֪�Ľ��.

�����³���1���,����10��/����ٶ��ṩ�ؼ����. �û�ֻ��Ҫ���KeyCode�Ƿ��0���жϼ��Ƿ���.

����ʱ���:
����17: Сʱ+.
����18: Сʱ-.
����19: ����+.
����20: ����-.


******************************************/

#define 	MAIN_Fosc		22118400L	//������ʱ��

#include	"STC15Fxxxx.H"


#define	Timer0_Reload	(65536UL -(MAIN_Fosc / 1000))		//Timer 0 �ж�Ƶ��, 1000��/��

#define DIS_DOT		0x20
#define DIS_BLACK	0x10
#define DIS_		0x11




u8 code t_display[]={						//��׼�ֿ�
//	 0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F
	0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F,0x77,0x7C,0x39,0x5E,0x79,0x71,
//black	 -     H    J	 K	  L	   N	o   P	 U     t    G    Q    r   M    y
	0x00,0x40,0x76,0x1E,0x70,0x38,0x37,0x5C,0x73,0x3E,0x78,0x3d,0x67,0x50,0x37,0x6e,
	0xBF,0x86,0xDB,0xCF,0xE6,0xED,0xFD,0x87,0xFF,0xEF,0x46};	//0. 1. 2. 3. 4. 5. 6. 7. 8. 9. -1

u8 code T_COM[]={0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80};		//λ��


sbit	P_HC595_SER   = P4^0;	//pin 14	SER		data input
sbit	P_HC595_RCLK  = P5^4;	//pin 12	RCLk	store (latch) clock
sbit	P_HC595_SRCLK = P4^3;	//pin 11	SRCLK	Shift data clock


u8 	LED8[8];		//��ʾ����
u8	display_index;	//��ʾλ����
bit	B_1ms;			//1ms��־

u8	KeyCode;	//���û�ʹ�õļ���, 1~16��Ч
u8	cnt10ms;

u8 IO_KeyState, IO_KeyState1, IO_KeyHoldCnt;	//���м��̱���
u8	cnt50ms;

u8	hour,minute,second;	//RTC����
u16	msecond;

void	IO_KeyScan(void);	//50ms call




/********************** ��ʾʱ�Ӻ��� ************************/
void	DisplayRTC(void)
{
	if(hour >= 10)	LED8[0] = hour / 10;
	else			LED8[0] = DIS_BLACK;
	LED8[1] = hour % 10;
	LED8[2] = minute / 10;
	LED8[3] = minute % 10;
	if(msecond >= 500)		LED8[1] |= DIS_DOT;	//Сʱ���С����������
}

/********************** RTC��ʾ���� ************************/
void	RTC(void)
{
	if(++second >= 60)
	{
		second = 0;
		if(++minute >= 60)
		{
			minute = 0;
			if(++hour >= 24)	hour = 0;
		}
	}
}

/**********************************************/
void main(void)
{
	u8	i;
	
	P0M1 = 0;	P0M0 = 0;	//����Ϊ׼˫���
	P1M1 = 0;	P1M0 = 0;	//����Ϊ׼˫���
	P2M1 = 0;	P2M0 = 0;	//����Ϊ׼˫���
	P3M1 = 0;	P3M0 = 0;	//����Ϊ׼˫���
	P4M1 = 0;	P4M0 = 0;	//����Ϊ׼˫���
	P5M1 = 0;	P5M0 = 0;	//����Ϊ׼˫���
	P6M1 = 0;	P6M0 = 0;	//����Ϊ׼˫���
	P7M1 = 0;	P7M0 = 0;	//����Ϊ׼˫���


	display_index = 0;
	
	AUXR = 0x80;	//Timer0 set as 1T, 16 bits timer auto-reload, 
	TH0 = (u8)(Timer0_Reload / 256);
	TL0 = (u8)(Timer0_Reload % 256);
	ET0 = 1;	//Timer0 interrupt enable
	TR0 = 1;	//Tiner0 run
	EA = 1;		//�����ж�
	
	for(i=0; i<8; i++)	LED8[i] = 0x10;	//�ϵ�����

	hour   = 12;	//��ʼ��ʱ��ֵ
	minute = 0;
	second = 0;
	DisplayRTC();

	KeyCode = 0;	//���û�ʹ�õļ���, 1~16��Ч
	cnt10ms = 0;

	IO_KeyState = 0;
	IO_KeyState1 = 0;
	IO_KeyHoldCnt = 0;
	cnt50ms = 0;
	
	while(1)
	{
		if(B_1ms)	//1ms��
		{
			B_1ms = 0;
			if(++msecond >= 1000)	//1�뵽
			{
				msecond = 0;
				RTC();
				DisplayRTC();
			}
			if(msecond == 500)	DisplayRTC();	//Сʱ���С����������


			if(++cnt50ms >= 50)		//50msɨ��һ�����м���
			{
				cnt50ms = 0;
				IO_KeyScan();
			}
			
			if(KeyCode > 0)		//�м�����
			{
				LED8[6] = KeyCode / 10;	//��ʾ����
				LED8[7] = KeyCode % 10;	//��ʾ����

				if(KeyCode == 17)	//hour +1
				{
					if(++hour >= 24)	hour = 0;
					DisplayRTC();
				}
				if(KeyCode == 18)	//hour -1
				{
					if(--hour >= 24)	hour = 23;
					DisplayRTC();
				}
				if(KeyCode == 19)	//minute +1
				{
					second = 0;
					if(++minute >= 60)	minute = 0;
					DisplayRTC();
				}
				if(KeyCode == 20)	//minute -1
				{
					second = 0;
					if(--minute >= 60)	minute = 59;
					DisplayRTC();
				}

				KeyCode = 0;
			}

		}
	}
} 
/**********************************************/

	

/*****************************************************
	���м�ɨ�����
	ʹ��XY����4x4���ķ�����ֻ�ܵ������ٶȿ�

   Y     P04      P05      P06      P07
          |        |        |        |
X         |        |        |        |
P00 ---- K00 ---- K01 ---- K02 ---- K03 ----
          |        |        |        |
P01 ---- K04 ---- K05 ---- K06 ---- K07 ----
          |        |        |        |
P02 ---- K08 ---- K09 ---- K10 ---- K11 ----
          |        |        |        |
P03 ---- K12 ---- K13 ---- K14 ---- K15 ----
          |        |        |        |
******************************************************/


u8 code T_KeyTable[16] = {0,1,2,0,3,0,0,0,4,0,0,0,0,0,0,0};

void IO_KeyDelay(void)
{
	u8 i;
	i = 60;
	while(--i)	;
}

void	IO_KeyScan(void)	//50ms call
{
	u8	j;

	j = IO_KeyState1;	//������һ��״̬

	P0 = 0xf0;	//X�ͣ���Y
	IO_KeyDelay();
	IO_KeyState1 = P0 & 0xf0;

	P0 = 0x0f;	//Y�ͣ���X
	IO_KeyDelay();
	IO_KeyState1 |= (P0 & 0x0f);
	IO_KeyState1 ^= 0xff;	//ȡ��
	
	if(j == IO_KeyState1)	//�������ζ����
	{
		j = IO_KeyState;
		IO_KeyState = IO_KeyState1;
		if(IO_KeyState != 0)	//�м�����
		{
			F0 = 0;
			if(j == 0)	F0 = 1;	//��һ�ΰ���
			else if(j == IO_KeyState)
			{
				if(++IO_KeyHoldCnt >= 20)	//1����ؼ�
				{
					IO_KeyHoldCnt = 18;
					F0 = 1;
				}
			}
			if(F0)
			{
				j = T_KeyTable[IO_KeyState >> 4];
				if((j != 0) && (T_KeyTable[IO_KeyState& 0x0f] != 0)) 
					KeyCode = (j - 1) * 4 + T_KeyTable[IO_KeyState & 0x0f] + 16;	//������룬17~32
			}
		}
		else	IO_KeyHoldCnt = 0;
	}
	P0 = 0xff;
}




/**************** ��HC595����һ���ֽں��� ******************/
void Send_595(u8 dat)
{		
	u8	i;
	for(i=0; i<8; i++)
	{
		dat <<= 1;
		P_HC595_SER   = CY;
		P_HC595_SRCLK = 1;
		P_HC595_SRCLK = 0;
	}
}

/********************** ��ʾɨ�躯�� ************************/
void DisplayScan(void)
{	
	Send_595(~T_COM[display_index]);				//���λ��
	Send_595(t_display[LED8[display_index]]);	//�������

	P_HC595_RCLK = 1;
	P_HC595_RCLK = 0;							//�����������
	if(++display_index >= 8)	display_index = 0;	//8λ������0
}


/********************** Timer0 1ms�жϺ��� ************************/
void timer0 (void) interrupt TIMER0_VECTOR
{
	DisplayScan();	//1msɨ����ʾһλ
	B_1ms = 1;		//1ms��־
}


