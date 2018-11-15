
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


/*************	����˵��	**************

ʹ��PCA0��P3.5���8λ��PWM, �����PWM����RC�˲���ֱ����ѹ��P1.5��ADC�����������ʾ����.

����1����Ϊ115200bps, 8,n, 1, �л���P3.0 P3.1, ���غ�Ϳ���ֱ�Ӳ���. ��ʱ��Ϊ22.1184MHZ, ͨ������1����ռ�ձ�.

��������ʹ��ASCII������֣����磺 10����������ռ�ձ�Ϊ10/256�� 100�� ��������ռ�ձ�Ϊ100/256��

�������õ�ֵΪ0~256, 0Ϊ�����͵�ƽ, 256Ϊ�����ߵ�ƽ.

���4λ�������ʾPWM��ռ�ձ�ֵ���ұ�4λ�������ʾADCֵ��

******************************************/

#define 	MAIN_Fosc			22118400L	//������ʱ��

#include	"STC15Fxxxx.H"


/****************************** �û������ ***********************************/
#define		LED_TYPE	0x00	//����LED����, 0x00--����, 0xff--����

#define	Timer0_Reload	(65536UL -(MAIN_Fosc / 1000))		//Timer 0 �ж�Ƶ��, 1000��/��

/*****************************************************************************/

#define DIS_DOT		0x20
#define DIS_BLACK	0x10
#define DIS_		0x11



/*************	���س�������	**************/
u8 code t_display[]={						//��׼�ֿ�
//	 0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F
	0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F,0x77,0x7C,0x39,0x5E,0x79,0x71,
//black	 -     H    J	 K	  L	   N	o   P	 U     t    G    Q    r   M    y
	0x00,0x40,0x76,0x1E,0x70,0x38,0x37,0x5C,0x73,0x3E,0x78,0x3d,0x67,0x50,0x37,0x6e,
	0xBF,0x86,0xDB,0xCF,0xE6,0xED,0xFD,0x87,0xFF,0xEF,0x46};	//0. 1. 2. 3. 4. 5. 6. 7. 8. 9. -1

u8 code T_COM[]={0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80};		//λ��


/*************	IO�ڶ���	**************/
sbit	P_HC595_SER   = P4^0;	//pin 14	SER		data input
sbit	P_HC595_RCLK  = P5^4;	//pin 12	RCLk	store (latch) clock
sbit	P_HC595_SRCLK = P4^3;	//pin 11	SRCLK	Shift data clock

/*************	���ر�������	**************/

u8 	LED8[8];		//��ʾ����
u8	display_index;	//��ʾλ����
bit	B_1ms;			//1ms��־

u8	cnt200ms;


#define		Baudrate1			115200L

#define		UART1_BUF_LENGTH	128		//���ڻ��峤��

u8	RX1_TimeOut;
u8	TX1_Cnt;	//���ͼ���
u8	RX1_Cnt;	//���ռ���
bit	B_TX1_Busy;	//����æ��־

u8 	xdata 	RX1_Buffer[UART1_BUF_LENGTH];	//���ջ���

bit		B_Capture0,B_Capture1,B_Capture2;
u8		PCA0_mode,PCA1_mode,PCA2_mode;
u16		CCAP0_tmp,PCA_Timer0;
u16		CCAP1_tmp,PCA_Timer1;
u16		CCAP2_tmp,PCA_Timer2;


void	UART1_config(u8 brt);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.
void	PrintString1(u8 *puts);
void	UART1_TxByte(u8 dat);
void	UpdatePwm(u16 pwm_value);


/*************	���ر�������	**************/

u16	adc;

u16		Get_ADC10bitResult(u8 channel);	//channel = 0~7





/******************** ס���� **************************/
void main(void)
{
	u8	i;
	u16	j;
	
	P0M1 = 0;	P0M0 = 0;	//����Ϊ׼˫���
	P1M1 = 0;	P1M0 = 0;	//����Ϊ׼˫���
	P2M1 = 0;	P2M0 = 0;	//����Ϊ׼˫���
	P3M1 = 0;	P3M0 = 0;	//����Ϊ׼˫���
	P4M1 = 0;	P4M0 = 0;	//����Ϊ׼˫���
	P5M1 = 0;	P5M0 = 0;	//����Ϊ׼˫���
	P6M1 = 0;	P6M0 = 0;	//����Ϊ׼˫���
	P7M1 = 0;	P7M0 = 0;	//����Ϊ׼˫���

	display_index = 0;

	//  Timer0��ʼ��
	AUXR = 0x80;	//Timer0 set as 1T, 16 bits timer auto-reload, 
	TH0 = (u8)(Timer0_Reload / 256);
	TL0 = (u8)(Timer0_Reload % 256);
	ET0 = 1;	//Timer0 interrupt enable
	TR0 = 1;	//Tiner0 run

	//  PCA0��ʼ��
	AUXR1 &= ~0x30;
	AUXR1 |= 0x10;	//�л�IO��, 0x00: P1.2 P1.1 P1.0 P3.7,  0x10: P3.4 P3.5 P3.6 P3.7, 0x20: P2.4 P2.5 P2.6 P2.7
	CCAPM0   = 0x42;	//����ģʽ PWM
	PCA_PWM0 = (PCA_PWM0 & ~0xc0) | 0x00;	//PWM���, 0x00: 8bit, 0x40: 7bit,  0x80: 6bit
	CMOD  = (CMOD  & ~0xe0) | 0x08;	//ѡ��ʱ��Դ, 0x00: 12T, 0x02: 2T, 0x04: Timer0���, 0x06: ECI, 0x08: 1T, 0x0A: 4T, 0x0C: 6T, 0x0E: 8T
	CR = 1;
	UpdatePwm(128);

	//  ADC��ʼ��
	P1ASF = (1 << 5);	//P1.5��ADC
	ADC_CONTR = 0xE0;	//90T, ADC power on

	UART1_config(1);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.
	EA = 1;		//�����ж�
	
	for(i=0; i<8; i++)	LED8[i] = DIS_;	//�ϵ�ȫ����ʾ-
	
	LED8[0] = 1;	//��ʾPWMĬ��ֵ
	LED8[1] = 2;
	LED8[2] = 8;
	LED8[3] = DIS_BLACK;	//��λ����ʾ

	PrintString1("PWM��ADC���Գ���, ����ռ�ձ�Ϊ 0~256!\r\n");	//SUART1����һ���ַ���
	
	while (1)
	{
		if(B_1ms)	//1ms��
		{
			B_1ms = 0;
			if(++cnt200ms >= 200)	//200ms��һ��ADC
			{
				cnt200ms = 0;
				j = Get_ADC10bitResult(5);	//����0~7,��ѯ��ʽ��һ��ADC, ����ֵ���ǽ��, == 1024 Ϊ����
				if(j >= 1000)	LED8[4] = j / 1000;		//��ʾ����ADCֵ
				else			LED8[4] = DIS_BLACK;
				LED8[5] = (j % 1000) / 100;
				LED8[6] = (j % 100) / 10;
				LED8[7] = j % 10;
			}

			if(RX1_TimeOut > 0)		//��ʱ����
			{
				if(--RX1_TimeOut == 0)
				{
					if((RX1_Cnt > 0) && (RX1_Cnt <= 3))	//����Ϊ3λ����
					{
						F0 = 0;	//�����־
						j = 0;
						for(i=0; i<RX1_Cnt; i++)
						{
							if((RX1_Buffer[i] >= '0') && (RX1_Buffer[i] <= '9'))	//�޶�Ϊ����
							{
								j = j * 10 + RX1_Buffer[i] - '0';
							}
							else
							{
								F0 = 1;	//���յ��������ַ�, ����
								PrintString1("����! ���յ��������ַ�! ռ�ձ�Ϊ0~256!\r\n");
								break;
							}
						}
						if(!F0)
						{
							if(j > 256)	PrintString1("����! ����ռ�ձȹ���, �벻Ҫ����256!\r\n");
							else
							{
								UpdatePwm(j);
								if(j >= 100)	LED8[0] = j / 100,	j %= 100;	//��ʾPWMĬ��ֵ
								else			LED8[0] = DIS_BLACK;
								LED8[1] = j % 100 / 10;
								LED8[2] = j % 10;
								PrintString1("�Ѹ���ռ�ձ�!\r\n");
							}
						}
					}
					else  PrintString1("����! �����ַ�����! ����ռ�ձ�Ϊ0~256!\r\n");
					RX1_Cnt = 0;
				}
			}
		}
	}
}


/**********************************************/


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
    for (; *puts != 0;	puts++)   UART1_TxByte(*puts);	//����ֹͣ��0����
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
	Send_595(~LED_TYPE ^ T_COM[display_index]);				//���λ��
	Send_595( LED_TYPE ^ t_display[LED8[display_index]]);	//�������

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


//========================================================================
// ����: u16	Get_ADC10bitResult(u8 channel)
// ����: ��ѯ����һ��ADC���.
// ����: channel: ѡ��Ҫת����ADC.
// ����: 10λADC���.
// �汾: V1.0, 2012-10-22
//========================================================================
u16	Get_ADC10bitResult(u8 channel)	//channel = 0~7
{
	ADC_RES = 0;
	ADC_RESL = 0;

	ADC_CONTR = (ADC_CONTR & 0xe0) | 0x08 | channel; 	//start the ADC
	NOP(4);

	while((ADC_CONTR & 0x10) == 0)	;	//wait for ADC finish
	ADC_CONTR &= ~0x10;		//���ADC������־
	return	(((u16)ADC_RES << 2) | (ADC_RESL & 3));
}


//========================================================================
// ����: UpdatePwm(u8 PCA_id, u16 pwm_value)
// ����: ����PWMֵ. 
// ����: PCA_id: PCA���. ȡֵ PCA0,PCA1,PCA2,PCA_Counter
//		 pwm_value: pwmֵ, ���ֵ������ߵ�ƽ��ʱ��.
// ����: none.
// �汾: V1.0, 2012-11-22
//========================================================================
void	UpdatePwm(u16 pwm_value)
{
	if(pwm_value == 0)			PWM0_OUT_0();	//��������͵�ƽ
	else						CCAP0H = (u8)(256 - pwm_value), PWM0_NORMAL();
}


