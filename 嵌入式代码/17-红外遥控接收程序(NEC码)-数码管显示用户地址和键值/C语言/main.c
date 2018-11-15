
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

������ճ����������г�����������NEC���롣

Ӧ�ò��ѯ B_IR_Press��־Ϊ,���ѽ��յ�һ���������IR_code��, ���������� �û��������B_IR_Press��־.

���������4λ��ʾ�û���, ���ұ���λ��ʾ����, ��Ϊʮ������.

******************************************/

#define MAIN_Fosc	22118400L	//������ʱ��
#define	SysTick 	10000		// ��/��, ϵͳ�δ�Ƶ��, ��4000~16000֮��

#include	"STC15Fxxxx.H"


/***********************************************************/

#define DIS_DOT		0x20
#define DIS_BLACK	0x10
#define DIS_		0x11


/****************************** �Զ������ ***********************************/

#define	Timer0_Reload	(65536UL - ((MAIN_Fosc + SysTick/2) / SysTick))		//Timer 0 �ж�Ƶ��, ��config.h��ָ��ϵͳ�δ�Ƶ��, ��4000~16000֮��.

/*****************************************************************************/





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

u8	cnt_1ms;		//1ms������ʱ


/*************	������ճ����������	**************/
sbit	P_IR_RX	= P3^6;			//��������������IO��

u8	IR_SampleCnt;		//��������
u8	IR_BitCnt;			//����λ��
u8	IR_UserH;			//�û���(��ַ)���ֽ�
u8	IR_UserL;			//�û���(��ַ)���ֽ�
u8	IR_data;			//����ԭ��
u8	IR_DataShit;		//������λ

bit	P_IR_RX_temp;		//Last sample
bit	B_IR_Sync;			//���յ�ͬ����־
bit	B_IR_Press;			//������������
u8	IR_code;			//�������
u16	UserCode;			//�û���

/*********************************/



/********************** ������ ************************/
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

	cnt_1ms = SysTick / 1000;
	EA = 1;		//�����ж�
	
	
	for(i=0; i<8; i++)	LED8[i] = DIS_;
	LED8[4] = DIS_BLACK;
	LED8[5] = DIS_BLACK;

	while(1)
	{
		if(B_1ms)	//1ms��
		{
			B_1ms = 0;
			
			if(B_IR_Press)		//��⵽�յ��������
			{
				B_IR_Press = 0;
				
				LED8[0] = (u8)((UserCode >> 12) & 0x0f);	//�û�����ֽڵĸ߰��ֽ�
				LED8[1] = (u8)((UserCode >> 8)  & 0x0f);	//�û�����ֽڵĵͰ��ֽ�
				LED8[2] = (u8)((UserCode >> 4)  & 0x0f);	//�û�����ֽڵĸ߰��ֽ�
				LED8[3] = (u8)(UserCode & 0x0f);			//�û�����ֽڵĵͰ��ֽ�
				LED8[6] = IR_code >> 4;
				LED8[7] = IR_code & 0x0f;
			}
		}
	}
} 
/**********************************************/





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



//*******************************************************************
//*********************** IR Remote Module **************************
//*********************** By  (Coody) 2002-8-24 *********************
//*********************** IR Remote Module **************************
//this programme is used for Receive IR Remote (NEC Code).

//data format: Synchro, AddressH, AddressL, data, /data, (total 32 bit).

//send a frame(85ms), pause 23ms, send synchro of continue frame, pause 94ms

//data rate: 108ms/Frame


//Synchro: low=9ms, high=4.5 / 2.25ms, low=0.5626ms
//Bit0: high=0.5626ms, low=0.5626ms
//Bit1: high=1.6879ms, low=0.5626ms
//frame rate = 108ms ( pause 23 ms or 96 ms)

/******************** �������ʱ��궨��, �û���Ҫ�����޸�	*******************/

#define IR_SAMPLE_TIME		(1000000UL/SysTick)			//��ѯʱ����, us, �������Ҫ����60us~250us֮��
#if ((IR_SAMPLE_TIME <= 250) && (IR_SAMPLE_TIME >= 60))
	#define	D_IR_sample			IR_SAMPLE_TIME		//�������ʱ�䣬��60us~250us֮��
#endif

#define D_IR_SYNC_MAX		(15000/D_IR_sample)	//SYNC max time
#define D_IR_SYNC_MIN		(9700 /D_IR_sample)	//SYNC min time
#define D_IR_SYNC_DIVIDE	(12375/D_IR_sample)	//decide data 0 or 1
#define D_IR_DATA_MAX		(3000 /D_IR_sample)	//data max time
#define D_IR_DATA_MIN		(600  /D_IR_sample)	//data min time
#define D_IR_DATA_DIVIDE	(1687 /D_IR_sample)	//decide data 0 or 1
#define D_IR_BIT_NUMBER		32					//bit number

//*******************************************************************************************
//**************************** IR RECEIVE MODULE ********************************************

void IR_RX_NEC(void)
{
	u8	SampleTime;

	IR_SampleCnt++;							//Sample + 1

	F0 = P_IR_RX_temp;						//Save Last sample status
	P_IR_RX_temp = P_IR_RX;					//Read current status
	if(F0 && !P_IR_RX_temp)					//Pre-sample is high��and current sample is low, so is fall edge
	{
		SampleTime = IR_SampleCnt;			//get the sample time
		IR_SampleCnt = 0;					//Clear the sample counter

			 if(SampleTime > D_IR_SYNC_MAX)		B_IR_Sync = 0;	//large the Maxim SYNC time, then error
		else if(SampleTime >= D_IR_SYNC_MIN)					//SYNC
		{
			if(SampleTime >= D_IR_SYNC_DIVIDE)
			{
				B_IR_Sync = 1;					//has received SYNC
				IR_BitCnt = D_IR_BIT_NUMBER;	//Load bit number
			}
		}
		else if(B_IR_Sync)						//has received SYNC
		{
			if(SampleTime > D_IR_DATA_MAX)		B_IR_Sync=0;	//data samlpe time too large
			else
			{
				IR_DataShit >>= 1;					//data shift right 1 bit
				if(SampleTime >= D_IR_DATA_DIVIDE)	IR_DataShit |= 0x80;	//devide data 0 or 1
				if(--IR_BitCnt == 0)				//bit number is over?
				{
					B_IR_Sync = 0;					//Clear SYNC
					if(~IR_DataShit == IR_data)		//�ж�����������
					{
						UserCode = ((u16)IR_UserH << 8) + IR_UserL;
						IR_code      = IR_data;
						B_IR_Press   = 1;			//������Ч
					}
				}
				else if((IR_BitCnt & 7)== 0)		//one byte receive
				{
					IR_UserL = IR_UserH;			//Save the User code high byte
					IR_UserH = IR_data;				//Save the User code low byte
					IR_data  = IR_DataShit;			//Save the IR data byte
				}
			}
		}
	}
}


/********************** Timer0�жϺ��� ************************/
void timer0 (void) interrupt TIMER0_VECTOR
{

	IR_RX_NEC();
	if(--cnt_1ms == 0)
	{
		cnt_1ms = SysTick / 1000;
		B_1ms = 1;		//1ms��־
		DisplayScan();	//1msɨ����ʾһλ
	}

}


