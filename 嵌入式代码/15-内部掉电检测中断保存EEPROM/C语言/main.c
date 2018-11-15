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

�û������޸ĺ���ѡ��ʱ��Ƶ��.

ʹ��Timer0��16λ�Զ���װ������1ms����,�������������������, �û��޸�MCU��ʱ��Ƶ��ʱ,�Զ���ʱ��1ms.


������ʹ��5V�汾��IAP15F2K61S2��STC15F2KxxS2���û�������"�û������"�а������MCU�޸ĵ��籣���EEPROM��ַ��

��ʾЧ��Ϊ: �ϵ����ʾ�����, ������ΧΪ0~10000����ʾ���ұߵ�5�������.

�������MCU�����ѹ�жϣ�����������б��档MCU�ϵ�ʱ���������������ʾ��

�û�������"�û������"��ѡ���˲����ݴ���С��
��ĵ���(����1000uF)�������󱣳ֵ�ʱ�䳤�������ڵ�ѹ�ж��в�����(��Ҫ20��msʱ��)Ȼ��д�롣
С�ĵ��ݣ������󱣳ֵ�ʱ���, ��������������ʼ��ʱ�Ȳ���.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ע�⣺����ʱ�����ؽ���"Ӳ��ѡ��"���������Ҫ�̶���������:

����ѡ	�����ѹ��λ(��ֹ��ѹ�ж�)

		��ѹ����ѹ 4.64V

����ѡ	��ѹʱ��ֹEEPROM����.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


******************************************/

#define MAIN_Fosc		22118400L	//������ʱ��

#include	"STC15Fxxxx.H"


#define DIS_DOT		0x20
#define DIS_BLACK	0x10
#define DIS_		0x11


/****************************** �û������ ***********************************/

#define		LargeCapacitor	0	//0: �˲����ݱȽ�С,  1: �˲����ݱȽϴ�

#define		EE_ADDRESS	0x8000	//����ĵ�ַ

#define		Timer0_Reload	(65536UL -(MAIN_Fosc / 1000))		//Timer 0 �ж�Ƶ��, 1000��/��

/*****************************************************************************/






/*************	���س�������	**************/
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
u16	msecond;

u16	Test_cnt;	//�����õ����������
u8	tmp[2];		//ͨ������

void	Display(void);
void	DisableEEPROM(void);
void 	EEPROM_read_n(u16 EE_address,u8 *DataAddress,u16 number);
void 	EEPROM_write_n(u16 EE_address,u8 *DataAddress,u16 number);
void	EEPROM_SectorErase(u16 EE_address);



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
	for(i=0; i<8; i++)	LED8[i] = DIS_BLACK;	//ȫ������
	
	Timer0_1T();
	Timer0_AsTimer();
	Timer0_16bitAutoReload();
	Timer0_Load(Timer0_Reload);
	Timer0_InterruptEnable();
	Timer0_Run();
	EA = 1;		//�����ж�
	
	for(msecond=0; msecond < 200; )	//��ʱ200ms
	{
		if(B_1ms)	//1ms��
		{
			B_1ms = 0;
			msecond ++;
		}
	}

	EEPROM_read_n(EE_ADDRESS,tmp,2);		//����2�ֽ�
	Test_cnt = ((u16)tmp[0] << 8) + tmp[1];	//�����
	if(Test_cnt > 10000)	Test_cnt = 0;	//�������ΧΪ0~10000
	
	#if (LargeCapacitor == 0)	//�˲����ݱȽ�С�����ݱ���ʱ��Ƚ϶̣����Ȳ���
		EEPROM_SectorErase(EE_ADDRESS);	//����һ������
	#endif
	
	Display();		//��ʾ�����
	
	PCON = PCON & ~(1<<5);	//��ѹ����־��0
	ELVD = 1;	//��ѹ����ж�����
	PLVD = 1; 	//��ѹ�ж� ���ȼ���

	while(1)
	{
		if(B_1ms)	//1ms��
		{
			B_1ms = 0;
			if(++msecond >= 1000)	//1�뵽
			{
				msecond = 0;		//��1000ms����
				Test_cnt++;			//�����+1
				if(Test_cnt > 10000)	Test_cnt = 0;	//�������ΧΪ0~10000
				Display();			//��ʾ�����
			}

		}
	}
} 
/**********************************************/

/********************** ��ѹ�жϺ��� ************************/
void	LVD_Routine(void) interrupt LVD_VECTOR
{
	u8	i;

	P_HC595_SER = 0;
	for(i=0; i<16; i++)		//�ȹر���ʾ��ʡ��
	{
		P_HC595_SRCLK = 1;
		P_HC595_SRCLK = 0;
	}
	P_HC595_RCLK = 1;
	P_HC595_RCLK = 0;		//�����������
	
	#if (LargeCapacitor > 0)	//�˲����ݱȽϴ󣬵��ݱ���ʱ��Ƚϳ�(50ms����)�������ж������
		EEPROM_SectorErase(EE_ADDRESS);	//����һ������
	#endif

	tmp[0] = (u8)(Test_cnt >> 8);
	tmp[1] = (u8)Test_cnt;
	EEPROM_write_n(EE_ADDRESS,tmp,2);

	while(PCON & (1<<5))			//����Ƿ���Ȼ�͵�ѹ
	{
		PCON = PCON & ~(1<<5);		//��ѹ����־��0
		for(i=0; i<100; i++)	;	//��ʱһ��
	}
}

/********************** ��ʾ�������� ************************/
void	Display(void)
{
	u8	i;
	
	LED8[3] = Test_cnt / 10000;
	LED8[4] = (Test_cnt % 10000) / 1000;
	LED8[5] = (Test_cnt % 1000) / 100;
	LED8[6] = (Test_cnt % 100) / 10;
	LED8[7] = Test_cnt % 10;
	
	for(i=3; i<7; i++)	//����Ч0
	{
		if(LED8[i] > 0)	break;
		LED8[i] = DIS_BLACK;
	}
}

//========================================================================
// ����: void	ISP_Disable(void)
// ����: ��ֹ����ISP/IAP.
// ����: non.
// ����: non.
// �汾: V1.0, 2012-10-22
//========================================================================
void	DisableEEPROM(void)
{
	ISP_CONTR = 0;			//��ֹISP/IAP����
	ISP_CMD   = 0;			//ȥ��ISP/IAP����
	ISP_TRIG  = 0;			//��ֹISP/IAP�����󴥷�
	ISP_ADDRH = 0xff;		//��0��ַ���ֽ�
	ISP_ADDRL = 0xff;		//��0��ַ���ֽڣ�ָ���EEPROM������ֹ�����
}

//========================================================================
// ����: void EEPROM_read_n(u16 EE_address,u8 *DataAddress,u16 number)
// ����: ��ָ��EEPROM�׵�ַ����n���ֽڷ�ָ���Ļ���.
// ����: EE_address:  ����EEPROM���׵�ַ.
//       DataAddress: �������ݷŻ�����׵�ַ.
//       number:      �������ֽڳ���.
// ����: non.
// �汾: V1.0, 2012-10-22
//========================================================================

void EEPROM_read_n(u16 EE_address,u8 *DataAddress,u16 number)
{
	EA = 0;		//��ֹ�ж�
	ISP_CONTR = (ISP_EN + ISP_WAIT_FREQUENCY);	//���õȴ�ʱ�䣬����ISP/IAP��������һ�ξ͹�
	ISP_READ();									//���ֽڶ���������ı�ʱ����������������
	do
	{
		ISP_ADDRH = EE_address / 256;		//�͵�ַ���ֽڣ���ַ��Ҫ�ı�ʱ���������͵�ַ��
		ISP_ADDRL = EE_address % 256;		//�͵�ַ���ֽ�
		ISP_TRIG();							//����5AH������A5H��ISP/IAP�����Ĵ�����ÿ�ζ���Ҫ���
											//����A5H��ISP/IAP������������������
											//CPU�ȴ�IAP��ɺ󣬲Ż����ִ�г���
		_nop_();
		*DataAddress = ISP_DATA;			//��������������
		EE_address++;
		DataAddress++;
	}while(--number);

	DisableEEPROM();
	EA = 1;		//���������ж�
}


/******************** ������������ *****************/
//========================================================================
// ����: void EEPROM_SectorErase(u16 EE_address)
// ����: ��ָ����ַ��EEPROM��������.
// ����: EE_address:  Ҫ����������EEPROM�ĵ�ַ.
// ����: non.
// �汾: V1.0, 2013-5-10
//========================================================================
void EEPROM_SectorErase(u16 EE_address)
{
	EA = 0;		//��ֹ�ж�
											//ֻ������������û���ֽڲ�����512�ֽ�/������
											//����������һ���ֽڵ�ַ����������ַ��
	ISP_ADDRH = EE_address / 256;			//��������ַ���ֽڣ���ַ��Ҫ�ı�ʱ���������͵�ַ��
	ISP_ADDRL = EE_address % 256;			//��������ַ���ֽ�
	ISP_CONTR = (ISP_EN + ISP_WAIT_FREQUENCY);	//���õȴ�ʱ�䣬����ISP/IAP��������һ�ξ͹�
	ISP_ERASE();							//������������������ı�ʱ����������������
	ISP_TRIG();
	_nop_();
	DisableEEPROM();
	EA = 1;		//���������ж�
}

//========================================================================
// ����: void EEPROM_write_n(u16 EE_address,u8 *DataAddress,u16 number)
// ����: �ѻ����n���ֽ�д��ָ���׵�ַ��EEPROM.
// ����: EE_address:  д��EEPROM���׵�ַ.
//       DataAddress: д��Դ���ݵĻ�����׵�ַ.
//       number:      д����ֽڳ���.
// ����: non.
// �汾: V1.0, 2012-10-22
//========================================================================
void EEPROM_write_n(u16 EE_address,u8 *DataAddress,u16 number)
{
	EA = 0;		//��ֹ�ж�

	ISP_CONTR = (ISP_EN + ISP_WAIT_FREQUENCY);	//���õȴ�ʱ�䣬����ISP/IAP��������һ�ξ͹�
	ISP_WRITE();							//���ֽ�д��������ı�ʱ����������������
	do
	{
		ISP_ADDRH = EE_address / 256;		//�͵�ַ���ֽڣ���ַ��Ҫ�ı�ʱ���������͵�ַ��
		ISP_ADDRL = EE_address % 256;		//�͵�ַ���ֽ�
		ISP_DATA  = *DataAddress;			//�����ݵ�ISP_DATA��ֻ�����ݸı�ʱ����������
		ISP_TRIG();
		_nop_();
		EE_address++;
		DataAddress++;
	}while(--number);

	DisableEEPROM();
	EA = 1;		//���������ж�
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


