

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

				����˵��

ͨ�����ڶ�STC�ڲ��Դ���EEPROM(FLASH)���ж�д���ԡ�

��FLASH������������д�롢�����Ĳ���������ָ����ַ��

Ĭ�ϲ�����:  115200,8,N,1. 
Ĭ����ʱ��:  22118400HZ.

������������: (������ĸ�����ִ�Сд)
	W 0x8000 1234567890  --> ��0x8000��ַд���ַ�1234567890.
	R 0x8000 10          --> ��0x8000��ַ����10���ֽ�����. 

ע�⣺Ϊ��ͨ�ã�����ʶ���ַ�Ƿ���Ч���û��Լ����ݾ�����ͺ���������

******************************************/


#define 	MAIN_Fosc			22118400L	//������ʱ��
#include	"STC15Fxxxx.H"

#define		Baudrate1			115200L
#define		Tmp_Length			70		//��дEEPROM���峤��

#define		UART1_BUF_LENGTH	(Tmp_Length+9)	//���ڻ��峤��

u8	RX1_TimeOut;
u8	TX1_Cnt;	//���ͼ���
u8	RX1_Cnt;	//���ռ���
bit	B_TX1_Busy;	//����æ��־

u8 	xdata 	RX1_Buffer[UART1_BUF_LENGTH];	//���ջ���
u8	xdata	tmp[Tmp_Length];		//EEPROM��������


void	UART1_config(u8 brt);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.
void	PrintString1(u8 *puts);
void	UART1_TxByte(u8 dat);
void	delay_ms(u8 ms);
u8		CheckData(u8 dat);
u16		GetAddress(void);
u8		GetDataLength(void);
void	EEPROM_SectorErase(u16 EE_address);
void 	EEPROM_read_n(u16 EE_address,u8 *DataAddress,u8 length);
u8		EEPROM_write_n(u16 EE_address,u8 *DataAddress,u8 length);


/********************* ������ *************************/
void main(void)
{
	u8	i,j;
	u16 addr;
	u8	status;

	P0M1 = 0;	P0M0 = 0;	//����Ϊ׼˫���
	P1M1 = 0;	P1M0 = 0;	//����Ϊ׼˫���
	P2M1 = 0;	P2M0 = 0;	//����Ϊ׼˫���
	P3M1 = 0;	P3M0 = 0;	//����Ϊ׼˫���
	P4M1 = 0;	P4M0 = 0;	//����Ϊ׼˫���
	P5M1 = 0;	P5M0 = 0;	//����Ϊ׼˫���
	P6M1 = 0;	P6M0 = 0;	//����Ϊ׼˫���
	P7M1 = 0;	P7M0 = 0;	//����Ϊ׼˫���

	UART1_config(1);	// ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.
	EA = 1;	//�������ж�

	PrintString1("STC15F2K60S2ϵ�е�Ƭ��EEPROM���Գ���, ����������������ʾ��:\r\n");	//SUART1����һ���ַ���
	PrintString1("W 0x8000 1234567890  --> ��0x8000��ַд���ַ�1234567890.\r\n");	//SUART1����һ���ַ���
	PrintString1("R 0x8000 10          --> ��0x8000��ַ����10���ֽ�����.\r\n");	//SUART1����һ���ַ���

	while(1)
	{
		delay_ms(1);
		if(RX1_TimeOut > 0)		//��ʱ����
		{
			if(--RX1_TimeOut == 0)
			{
		//		for(i=0; i<RX1_Cnt; i++)	UART1_TxByte(RX1_Buffer[i]);	//���յ�������ԭ������,���ڲ���

				status = 0xff;	//״̬��һ����0ֵ
				if((RX1_Cnt >= 10) && (RX1_Buffer[1] == ' ') && (RX1_Buffer[8] == ' '))	//�������Ϊ10���ֽ�
				{
					for(i=0; i<8; i++)
					{
						if((RX1_Buffer[i] >= 'a') && (RX1_Buffer[i] <= 'z'))	RX1_Buffer[i] = RX1_Buffer[i] - 'a' + 'A';	//Сдת��д
					}
					addr = GetAddress();
					if(addr < 63488)	//������0~123����
					{
						if(RX1_Buffer[0] == 'W')	//д��N���ֽ�
						{
							j = RX1_Cnt - 9;
							if(j > Tmp_Length)	j = Tmp_Length;	//Խ����
							EEPROM_SectorErase(addr);			//��������
							i = EEPROM_write_n(addr,&RX1_Buffer[9],j);		//дN���ֽ�
							if(i == 0)
							{
								PrintString1("��д��");
								if(j >= 100)	{UART1_TxByte(j/100+'0');	j = j % 100;}
								if(j >= 10)		{UART1_TxByte(j/10+'0');	j = j % 10;}
								UART1_TxByte(j%10+'0');
								PrintString1("�ֽ�����!\r\n");
							}
							else	PrintString1("д�����!\r\n");
							status = 0;	//������ȷ
						}

						else if(RX1_Buffer[0] == 'R')	//PC���󷵻�N�ֽ�EEPROM����
						{
							j = GetDataLength();
							if(j > Tmp_Length)	j = Tmp_Length;	//Խ����
							if(j > 0)
							{
								PrintString1("����");
								UART1_TxByte(j/10+'0');
								UART1_TxByte(j%10+'0');
								PrintString1("���ֽ��������£�\r\n");
								EEPROM_read_n(addr,tmp,j);
								for(i=0; i<j; i++)	UART1_TxByte(tmp[i]);
								UART1_TxByte(0x0d);
								UART1_TxByte(0x0a);
								status = 0;	//������ȷ
							}
						}
					}
				}
				if(status != 0)	PrintString1("�������!\r\n");
				RX1_Cnt  = 0;	//����ֽ���
			}
		}
	}
}
//========================================================================


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
     unsigned int i;
	 do{
	      i = MAIN_Fosc / 14000;
		  while(--i)	;   //14T per loop
     }while(--ms);
}

//========================================================================
// ����: u8	CheckData(u8 dat)
// ����: ���ַ�"0~9,A~F��a~f"ת��ʮ������.
// ����: dat: Ҫ�����ַ�.
// ����: 0x00~0x0FΪ��ȷ. 0xFFΪ����.
// �汾: V1.0, 2012-10-22
//========================================================================
u8	CheckData(u8 dat)
{
	if((dat >= '0') && (dat <= '9'))		return (dat-'0');
	if((dat >= 'A') && (dat <= 'F'))		return (dat-'A'+10);
	return 0xff;
}

//========================================================================
// ����: u16	GetAddress(void)
// ����: ����������뷽ʽ�ĵ�ַ.
// ����: ��.
// ����: 16λEEPROM��ַ.
// �汾: V1.0, 2013-6-6
//========================================================================
u16	GetAddress(void)
{
	u16	address;
	u8	i,j;
	
	address = 0;
	if((RX1_Buffer[2] == '0') && (RX1_Buffer[3] == 'X'))
	{
		for(i=4; i<8; i++)
		{
			j = CheckData(RX1_Buffer[i]);
			if(j >= 0x10)	return 65535;	//error
			address = (address << 4) + j;
		}
		return (address);
	}
	return	65535;	//error
}

/**************** ��ȡҪ�������ݵ��ֽ��� ****************************/
u8	GetDataLength(void)
{
	u8	i;
	u8	length;
	
	length = 0;
	for(i=9; i<RX1_Cnt; i++)
	{
		if(CheckData(RX1_Buffer[i]) >= 10)	break;
		length = length * 10 + CheckData(RX1_Buffer[i]);
	}
	return (length);
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
	for (; *puts != 0;	puts++)	UART1_TxByte(*puts);  	//����ֹͣ��0����
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
	RX1_TimeOut = 0;
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


/*
STC15F/L2KxxS2	�������䣬512�ֽ�/��������0x0000��ʼ��

     �ͺ�        ��С   ������  ��ʼ��ַ  ������ַ   MOVC��ƫ�Ƶ�ַ
STC15F/L2K08S2   53K   106����  0x0000  ~  0xD3FF        0x2000
STC15F/L2K16S2   45K    90����  0x0000  ~  0xB3FF        0x4000
STC15F/L2K24S2   37K    74����  0x0000  ~  0x93FF        0x6000
STC15F/L2K32S2   29K    58����  0x0000  ~  0x73FF        0x8000
STC15F/L2K40S2   21K    42����  0x0000  ~  0x53FF        0xA000
STC15F/L2K48S2   13K    26����  0x0000  ~  0x33FF        0xC000
STC15F/L2K56S2   5K     10����  0x0000  ~  0x13FF        0xE000
STC15F/L2K60S2   1K      2����  0x0000  ~  0x03FF        0xF000

STC15F/L2K61S2   ��EPROM, ����122������FLASH�����Բ�д ��ַ 0x0000~0xF3ff.
*/


#define		ISP_ENABLE()	ISP_CONTR = (ISP_EN + ISP_WAIT_FREQUENCY)
#define		ISP_DISABLE()	ISP_CONTR = 0; ISP_CMD = 0; ISP_TRIG = 0; ISP_ADDRH = 0xff; ISP_ADDRL = 0xff



//========================================================================
// ����: void DisableEEPROM(void)
// ����: ��ֹEEPROM.
// ����: none.
// ����: none.
// �汾: V1.0, 2014-6-30
//========================================================================
void DisableEEPROM(void)		//��ֹ����EEPROM
{
	ISP_CONTR = 0;				//��ֹISP/IAP����
	ISP_CMD   = 0;				//ȥ��ISP/IAP����
	ISP_TRIG  = 0;				//��ֹISP/IAP�����󴥷�
	ISP_ADDRH = 0xff;			//ָ���EEPROM������ֹ�����
	ISP_ADDRL = 0xff;			//ָ���EEPROM������ֹ�����
}

//========================================================================
// ����: void	EEPROM_Trig(void)
// ����: ����EEPROM����.
// ����: none.
// ����: none.
// �汾: V1.0, 2014-6-30
//========================================================================
void	EEPROM_Trig(void)
{
	F0 = EA;	//����ȫ���ж�
	EA = 0;		//��ֹ�ж�, ���ⴥ��������Ч
	ISP_TRIG();							//����5AH������A5H��ISP/IAP�����Ĵ�����ÿ�ζ���Ҫ���
										//����A5H��ISP/IAP������������������
										//CPU�ȴ�IAP��ɺ󣬲Ż����ִ�г���
	_nop_();
	_nop_();
	EA = F0;	//�ָ�ȫ���ж�
}

//========================================================================
// ����: void	EEPROM_SectorErase(u16 EE_address)
// ����: ����һ������.
// ����: EE_address:  Ҫ������EEPROM�������е�һ���ֽڵ�ַ.
// ����: none.
// �汾: V1.0, 2014-6-30
//========================================================================
void	EEPROM_SectorErase(u16 EE_address)
{
	ISP_ENABLE();						//���õȴ�ʱ�䣬����ISP/IAP��������һ�ξ͹�
	ISP_ERASE();						//�����, ������������������ı�ʱ����������������
										//ֻ������������û���ֽڲ�����512�ֽ�/������
										//����������һ���ֽڵ�ַ����������ַ��
	ISP_ADDRH = EE_address / 256;		//��������ַ���ֽڣ���ַ��Ҫ�ı�ʱ���������͵�ַ��
	ISP_ADDRL = EE_address % 256;		//��������ַ���ֽ�
	EEPROM_Trig();						//����EEPROM����
	DisableEEPROM();					//��ֹEEPROM����
}

//========================================================================
// ����: void EEPROM_read_n(u16 EE_address,u8 *DataAddress,u8 lenth)
// ����: ��N���ֽں���.
// ����: EE_address:  Ҫ������EEPROM���׵�ַ.
//       DataAddress: Ҫ�������ݵ�ָ��.
//       length:      Ҫ�����ĳ���
// ����: 0: д����ȷ.  1: д�볤��Ϊ0����.  2: д�����ݴ���.
// �汾: V1.0, 2014-6-30
//========================================================================
void EEPROM_read_n(u16 EE_address,u8 *DataAddress,u8 length)
{
	ISP_ENABLE();							//���õȴ�ʱ�䣬����ISP/IAP��������һ�ξ͹�
	ISP_READ();								//���ֽڶ���������ı�ʱ����������������
	do
	{
		ISP_ADDRH = EE_address / 256;		//�͵�ַ���ֽڣ���ַ��Ҫ�ı�ʱ���������͵�ַ��
		ISP_ADDRL = EE_address % 256;		//�͵�ַ���ֽ�
		EEPROM_Trig();						//����EEPROM����
		*DataAddress = ISP_DATA;			//��������������
		EE_address++;
		DataAddress++;
	}while(--length);

	DisableEEPROM();
}


//========================================================================
// ����: u8 EEPROM_write_n(u16 EE_address,u8 *DataAddress,u8 length)
// ����: дN���ֽں���.
// ����: EE_address:  Ҫд���EEPROM���׵�ַ.
//       DataAddress: Ҫд�����ݵ�ָ��.
//       length:      Ҫд��ĳ���
// ����: 0: д����ȷ.  1: д�볤��Ϊ0����.  2: д�����ݴ���.
// �汾: V1.0, 2014-6-30
//========================================================================
u8 	EEPROM_write_n(u16 EE_address,u8 *DataAddress,u8 length)
{
	u8	i;
	u16	j;
	u8	*p;
	
	if(length == 0)	return 1;	//����Ϊ0����

	ISP_ENABLE();						//���õȴ�ʱ�䣬����ISP/IAP��������һ�ξ͹�
	i = length;
	j = EE_address;
	p = DataAddress;
	ISP_WRITE();							//�����, ���ֽ�д����
	do
	{
		ISP_ADDRH = EE_address / 256;		//�͵�ַ���ֽڣ���ַ��Ҫ�ı�ʱ���������͵�ַ��
		ISP_ADDRL = EE_address % 256;		//�͵�ַ���ֽ�
		ISP_DATA  = *DataAddress;			//�����ݵ�ISP_DATA��ֻ�����ݸı�ʱ����������
		EEPROM_Trig();						//����EEPROM����
		EE_address++;						//��һ����ַ
		DataAddress++;						//��һ������
	}while(--length);						//ֱ������

	EE_address = j;
	length = i;
	DataAddress = p;
	i = 0;
	ISP_READ();								//��N���ֽڲ��Ƚ�
	do
	{
		ISP_ADDRH = EE_address / 256;		//�͵�ַ���ֽڣ���ַ��Ҫ�ı�ʱ���������͵�ַ��
		ISP_ADDRL = EE_address % 256;		//�͵�ַ���ֽ�
		EEPROM_Trig();						//����EEPROM����
		if(*DataAddress != ISP_DATA)		//������������Դ���ݱȽ�
		{
			i = 2;
			break;
		}
		EE_address++;
		DataAddress++;
	}while(--length);

	DisableEEPROM();
	return i;
}



