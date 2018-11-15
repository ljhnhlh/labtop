
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


�û������ں궨���иı�MCU��ʱ��Ƶ��. ��Χ 8MHZ ~ 33MHZ.

������ճ���ģ���г�����������NEC�ı��롣

�û������ں궨����ָ���û���.

ʹ��PCA2�����������38KHZ�ز�, 1/3ռ�ձ�, ÿ��38KHZ���ڷ���ܷ���9us,�ر�16.3us.

ʹ�ÿ������ϵ�16��IOɨ�谴��, MCU��˯��, ����ɨ�谴��.

��������, ��һ֡Ϊ����, �����֡Ϊ�ظ���,��������, ���嶨�������вο�NEC�ı�������.

���ͷź�, ֹͣ����.

******************************************/

#define 	MAIN_Fosc		22118400UL	//������ʱ��

#include	"STC15Fxxxx.H"


/*************	���ⷢ����ر���	**************/
#define	User_code	0xFF00		//��������û���

sbit	P_IR_TX   = P3^7;	//������ⷢ�Ͷ˿�

u16		PCA_Timer2;	//PCA2�����ʱ������
bit		B_Space;	//���Ϳ���(��ʱ)��־
u16		tx_cnt;		//���ͻ���е��������(����38KHZ������������Ӧʱ��), ����Ƶ��Ϊ38KHZ, ����26.3us
u8		TxTime;		//����ʱ��


/*************	IO�ڶ���	**************/
sbit	P_HC595_SER   = P4^0;	//pin 14	SER		data input
sbit	P_HC595_RCLK  = P5^4;	//pin 12	RCLk	store (latch) clock
sbit	P_HC595_SRCLK = P4^3;	//pin 11	SRCLK	Shift data clock

/*************	IO���̱�������	**************/

u8	IO_KeyState, IO_KeyState1, IO_KeyHoldCnt;	//���м��̱���
u8	KeyHoldCnt;	//�����¼�ʱ
u8	KeyCode;	//���û�ʹ�õļ���, 1~16��Ч


/*************	���غ�������	**************/
void	delay_ms(u8 ms);
void	DisableHC595(void);
void	IO_KeyScan(void);
void	PCA_config(void);
void	IR_TxPulse(u16 pulse);
void	IR_TxSpace(u16 pulse);
void	IR_TxByte(u8 dat);




/********************** ������ ************************/
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
	
	PCA_config();
	
	EA = 1;						//�����ж�
	
	DisableHC595();		//��ֹ��ѧϰ���ϵ�HC595��ʾ��ʡ��

	while(1)
	{
		delay_ms(30);		//30ms
		IO_KeyScan();

		if(KeyCode != 0)		//��⵽����
		{
			TxTime = 0;
								//һ֡������С���� = 9 + 4.5 + 0.5625 + 24 * 1.125 + 8 * 2.25 = 59.0625 ms
								//һ֡������󳤶� = 9 + 4.5 + 0.5625 + 8 * 1.125 + 24 * 2.25 = 77.0625 ms
			IR_TxPulse(342);	//��Ӧ9ms��ͬ��ͷ		9ms
			IR_TxSpace(171);	//��Ӧ4.5ms��ͬ��ͷ���	4.5ms
			IR_TxPulse(21);		//��ʼ��������			0.5625ms

			IR_TxByte(User_code%256);	//���û�����ֽ�
			IR_TxByte(User_code/256);	//���û�����ֽ�
			IR_TxByte(KeyCode);			//������
			IR_TxByte(~KeyCode);		//�����ݷ���
			
			if(TxTime < 56)		//һ֡�����77ms����, �����Ļ�,����ʱ��		108ms
			{
				TxTime = 56 - TxTime;
				TxTime = TxTime + TxTime / 8;
				delay_ms(TxTime);
			}
			delay_ms(31);

			while(IO_KeyState != 0)	//��δ�ͷ�
			{
				IR_TxPulse(342);	//��Ӧ9ms��   ͬ��ͷ		9ms
				IR_TxSpace(86);		//��Ӧ2.25ms��ͬ��ͷ���	2.25ms
				IR_TxPulse(21);		//��ʼ��������			 	0.5625ms
				delay_ms(96);
				IO_KeyScan();
			}
			KeyCode = 0;
		}
	}
} 
/**********************************************/

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
		  while(--i)	;   //13T per loop
     }while(--ms);
}



void DisableHC595(void)
{		
	u8	i;
	P_HC595_SER   = 1;
	for(i=0; i<20; i++)
	{
		P_HC595_SRCLK = 1;
		P_HC595_SRCLK = 0;
	}
	P_HC595_RCLK = 1;
	P_HC595_RCLK = 0;							//�����������
	P_HC595_RCLK = 1;
	P_HC595_RCLK = 0;							//�����������
}


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



/************* �������庯�� **************/
void	IR_TxPulse(u16 pulse)
{
	tx_cnt = pulse;
	B_Space = 0;	//������
	CCAPM2 = 0x48 | 0x04 | 0x01;	//����ģʽ 0x00: PCA_Mode_Capture,  0x42: PCA_Mode_PWM,  0x48: PCA_Mode_SoftTimer
	CR = 1;		//����
	while(CR);
}

/************* ���Ϳ��к��� **************/
void	IR_TxSpace(u16 pulse)
{
	tx_cnt = pulse;
	B_Space = 1;	//����
	CCAPM2 = 0x48 | 0x01;	//����ģʽ 0x00: PCA_Mode_Capture,  0x42: PCA_Mode_PWM,  0x48: PCA_Mode_SoftTimer
	CR = 1;		//����
	while(CR);
}


/************* ����һ���ֽں��� **************/
void	IR_TxByte(u8 dat)
{
	u8 i;
	for(i=0; i<8; i++)
	{
		if(dat & 1)		IR_TxSpace(63),	TxTime += 2;	//����1��Ӧ 1.6875 + 0.5625 ms 
		else			IR_TxSpace(21),	TxTime++;		//����0��Ӧ 0.5625 + 0.5625 ms
		IR_TxPulse(21);			//���嶼��0.5625ms
		dat >>= 1;				//��һ��λ
	}
}

//========================================================================
// ����: void	PCA_config(void)
// ����: PCA���ú���.
// ����: None
// ����: none.
// �汾: V1.0, 2012-11-22
//========================================================================
void	PCA_config(void)
{
	AUXR1   = (AUXR1 & ~0x30) | 0x10;	//�л�IO��, 0x00: P1.2 P1.1 P1.0 P3.7,  0x10: P3.4 P3.5 P3.6 P3.7, 0x20: P2.4 P2.5 P2.6 P2.7

	CCON = 0x00;	//��������жϱ�־
	CCAPM2  = 0x48+ 1;	//����ģʽ + �����ж� 0x00: PCA_Mode_Capture,  0x42: PCA_Mode_PWM,  0x48: PCA_Mode_SoftTimer
	CCAPM2 |= 0x04;	//�������ȡ�����, һ������16λ�����ʱ��
	PCA_Timer2 = 100;	//����һ��С�ĳ�ֵ
	CCAP2L = (u8)PCA_Timer2;			//��Ӱ��Ĵ���д�벶��Ĵ�������дCCAPxL
	CCAP2H = (u8)(PCA_Timer2 >> 8);	//��дCCAPxH

	PPCA = 1;	//�����ȼ��ж�
	CMOD  = (CMOD  & ~0xe0) | 0x08;	//ѡ��ʱ��Դ, 0x00: 12T, 0x02: 2T, 0x04: Timer0���, 0x06: ECI, 0x08: 1T, 0x0A: 4T, 0x0C: 6T, 0x0E: 8T
	CH = 0;
	CL = 0;
	CR = 0;
	tx_cnt = 2;
}

//========================================================================
// ����: void	PCA_Handler (void) interrupt PCA_VECTOR
// ����: PCA�жϴ������.
// ����: None
// ����: none.
// �汾: V1.0, 2012-11-22
//========================================================================

#define	D_38K_DUTY	((MAIN_Fosc * 26) / 1000000UL + MAIN_Fosc / 3000000UL)	/* 	38KHZ����ʱ��	26.3us */
#define	D_38K_OFF	((MAIN_Fosc * 17) / 1000000UL + MAIN_Fosc / 3000000UL)	/* ����ܹر�ʱ��	17.3us */
#define	D_38K_ON	((MAIN_Fosc * 9) / 1000000UL)							/* ����ܵ�ͨʱ��	9us */

void	PCA_Handler (void) interrupt PCA_VECTOR
{
	CCON = 0x40;	//��������жϱ�־,������CR
	if(!B_Space)	//�����ز�
	{								//�������壬����װ��TH0ֵ�����ʱ�Զ���װ
		if(P_IR_TX)
		{
			PCA_Timer2 += D_38K_OFF;	//װ�ظߵ�ƽʱ��	17.3us
			if(--tx_cnt == 0)	CR = 0;	//pulse has sent,	stop
		}
		else	PCA_Timer2 += D_38K_ON;	//װ�ص͵�ƽʱ��	9us
	}
	else	//������ͣʱ��
	{
		PCA_Timer2 += D_38K_DUTY;	//װ������ʱ��	26.3us
		if(--tx_cnt == 0)	CR = 0;	//����ʱ��
	}
	CCAP2L = (u8)PCA_Timer2;			//��Ӱ��Ĵ���д�벶��Ĵ�������дCCAP0L
	CCAP2H = (u8)(PCA_Timer2 >> 8);	//��дCCAP0H
}

