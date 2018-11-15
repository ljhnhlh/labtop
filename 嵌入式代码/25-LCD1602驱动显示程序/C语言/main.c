
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

����LCD1602�ַ���.

��ʾЧ��Ϊ: LCD��ʾʱ��.

��һ����ʾ ---Clock demo---
�ڶ�����ʾ     12-00-00

******************************************/

#define MAIN_Fosc		22118400L	//������ʱ��

#include	"STC15Fxxxx.H"



/*************	IO�ڶ���	**************/
sbit	P_HC595_SER   = P4^0;	//pin 14	SER		data input
sbit	P_HC595_RCLK  = P5^4;	//pin 12	RCLk	store (latch) clock
sbit	P_HC595_SRCLK = P4^3;	//pin 11	SRCLK	Shift data clock

/*************	���ر�������	**************/

u8	hour,minute,second;

void	DisplayRTC(void);
void	RTC(void);
void	delay_ms(u8 ms);
void	DisableHC595(void);
void	Initialize_LCD(void);
void	Write_AC(u8 hang,u8 lie);
void	Write_DIS_Data(u8 DIS_Data);
void	ClearLine(u8 row);
u8		BIN_ASCII(u8 tmp);
void 	PutString(u8 row, u8 column, u8 *puts);
void	WriteChar(u8 row, u8 column, u8 dat);



//========================================================================
// ����: void main(void)
// ����: ��������
// ����: none.
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
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

	Initialize_LCD();
	ClearLine(0);
	ClearLine(1);
	P2M1 &= ~(1<<4);	//P2.4����Ϊ�������
	P2M0 |=  (1<<4);
	P24 = 1;			//����
	DisableHC595();		//��ֹ��ѧϰ���ϵ�HC595��ʾ��ʡ��

	PutString(0,0,"---Clock demo---");
	
	hour   = 12;	//��ʼ��ʱ��ֵ
	minute = 0;
	second = 0;
	DisplayRTC();
	
	while(1)
	{
		delay_ms(250);		//��ʱ1��
		delay_ms(250);
		delay_ms(250);
		delay_ms(250);
		RTC();
		DisplayRTC();
	}
} 
/**********************************************/

//========================================================================
// ����: void  delay_ms(u8 ms)
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
	      i = MAIN_Fosc / 13000;
		  while(--i)	;   //14T per loop
     }while(--ms);
}

//========================================================================
// ����: void DisableHC595(void)
// ����: ��ֹHC595�������ʾ������
// ����: none.
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
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


//========================================================================
// ����: void	DisplayRTC(void)
// ����: ��ʾʱ�Ӻ���
// ����: none.
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
void	DisplayRTC(void)
{
	if(hour >= 10)	WriteChar(1,4,hour / 10 + '0');
	else			WriteChar(1,4,' ');
	WriteChar(1,5,hour % 10 +'0');
	WriteChar(1,6,'-');
	WriteChar(1,7,minute / 10+'0');
	WriteChar(1,8,minute % 10+'0');
	WriteChar(1,9,'-');
	WriteChar(1,10,second / 10 +'0');
	WriteChar(1,11,second % 10 +'0');
}

//========================================================================
// ����: void	RTC(void)
// ����: RTC��ʾ����
// ����: none.
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
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


/************* LCD1602��س���	*****************************************************/
//8λ���ݷ��ʷ�ʽ	LCD1602		��׼����	������д	2014-2-21

#define LineLength	16		//16x2

/*************	Pin define	*****************************************************/

sfr		LCD_BUS = 0x80;	//P0--0x80, P1--0x90, P2--0xA0, P3--0xB0

sbit	LCD_B7  = LCD_BUS^7;	//D7 -- Pin 14		LED- -- Pin 16 
sbit	LCD_B6  = LCD_BUS^6;	//D6 -- Pin 13		LED+ -- Pin 15
sbit	LCD_B5  = LCD_BUS^5;	//D5 -- Pin 12		Vo   -- Pin 3
sbit	LCD_B4  = LCD_BUS^4;	//D4 -- Pin 11		VDD  -- Pin 2
sbit	LCD_B3  = LCD_BUS^3;	//D3 -- Pin 10		VSS  -- Pin 1
sbit	LCD_B2  = LCD_BUS^2;	//D2 -- Pin  9
sbit	LCD_B1  = LCD_BUS^1;	//D1 -- Pin  8
sbit	LCD_B0  = LCD_BUS^0;	//D0 -- Pin  7

sbit	LCD_ENA	= P2^7;	//Pin 6
sbit	LCD_RW	= P2^6;	//Pin 5	//LCD_RS   R/W   DB7--DB0        FOUNCTION
sbit	LCD_RS	= P2^5;	//Pin 4	//	0		0	  INPUT      write the command to LCD model
								//	0		1     OUTPUT     read BF and AC pointer from LCD model
								//	1		0     INPUT      write the data to LCD  model
								//	1		1     OUTPUT     read the data from LCD model
/*
total 2 lines, 16x2= 32
first line address:  0~15
second line address: 64~79

*/

#define C_CLEAR			0x01		//clear LCD
#define C_HOME 			0x02		//cursor go home
#define C_CUR_L			0x04		//cursor shift left after input
#define C_RIGHT			0x05		//picture shift right after input
#define C_CUR_R			0x06		//cursor shift right after input
#define C_LEFT 			0x07		//picture shift left after input
#define C_OFF  			0x08		//turn off LCD
#define C_ON   			0x0C		//turn on  LCD
#define C_FLASH			0x0D		//turn on  LCD, flash 
#define C_CURSOR		0x0E		//turn on  LCD and cursor
#define C_FLASH_ALL		0x0F		//turn on  LCD and cursor, flash
#define C_CURSOR_LEFT	0x10		//single cursor shift left
#define C_CURSOR_RIGHT	0x10		//single cursor shift right
#define C_PICTURE_LEFT	0x10		//single picture shift left
#define C_PICTURE_RIGHT	0x10		//single picture shift right
#define C_BIT8			0x30		//set the data is 8 bits
#define C_BIT4			0x20		//set the data is 4 bits
#define C_L1DOT7		0x30		//8 bits,one line 5*7  dots
#define C_L1DOT10		0x34		//8 bits,one line 5*10 dots
#define C_L2DOT7		0x38		//8 bits,tow lines 5*7 dots
#define C_4bitL2DOT7	0x28		//4 bits,tow lines 5*7 dots
#define C_CGADDRESS0	0x40		//CGRAM address0 (addr=40H+x)
#define C_DDADDRESS0	0x80		//DDRAM address0 (addr=80H+x)


#define	LCD_DelayNop()	NOP(15)

#define		LCD_BusData(dat)	LCD_BUS = dat


//========================================================================
// ����: void	CheckBusy(void)
// ����: ���æ����
// ����: none.
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
void	CheckBusy(void)
{
	u16	i;
	for(i=0; i<5000; i++)	{if(!LCD_B7)	break;}		//check the LCD busy or not. With time out
//	while(LCD_B7);			//check the LCD busy or not. Without time out
}

//========================================================================
// ����: void IniSendCMD(u8 cmd)
// ����: ��ʼ��д����(�����æ)
// ����: cmd: Ҫд������.
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
void IniSendCMD(u8 cmd)
{
	LCD_RW = 0;
	LCD_BusData(cmd);
	LCD_DelayNop();
	LCD_ENA = 1;
	LCD_DelayNop();
	LCD_ENA = 0;
	LCD_BusData(0xff);
}

//========================================================================
// ����: void Write_CMD(u8 cmd)
// ����: д����(���æ)
// ����: cmd: Ҫд������.
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
void Write_CMD(u8 cmd)
{
	LCD_RS  = 0;
	LCD_RW = 1;
	LCD_BusData(0xff);
	LCD_DelayNop();
	LCD_ENA = 1;
	CheckBusy();			//check the LCD busy or not.
	LCD_ENA = 0;
	LCD_RW = 0;
	
	LCD_BusData(cmd);
	LCD_DelayNop();
	LCD_ENA = 1;
	LCD_DelayNop();
	LCD_ENA = 0;
	LCD_BusData(0xff);
}

//========================================================================
// ����: void Write_DIS_Data(u8 dat)
// ����: д��ʾ����(���æ)
// ����: dat: Ҫд������.
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
void Write_DIS_Data(u8 dat)
{
	LCD_RS = 0;
	LCD_RW = 1;

	LCD_BusData(0xff);
	LCD_DelayNop();
	LCD_ENA = 1;
	CheckBusy();			//check the LCD busy or not.
	LCD_ENA = 0;
	LCD_RW = 0;
	LCD_RS  = 1;

	LCD_BusData(dat);
	LCD_DelayNop();
	LCD_ENA = 1;
	LCD_DelayNop();
	LCD_ENA = 0;
	LCD_BusData(0xff);
}


//========================================================================
// ����: void Initialize_LCD(void)
// ����: ��ʼ������
// ����: none.
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
void Initialize_LCD(void)
{
	LCD_ENA = 0;
	LCD_RS  = 0;
	LCD_RW = 0;

	delay_ms(100);
	IniSendCMD(C_BIT8);		//set the data is 8 bits

	delay_ms(10);
	Write_CMD(C_L2DOT7);		//tow lines 5*7 dots

	delay_ms(6);
	Write_CMD(C_CLEAR);		//clear LCD RAM
	Write_CMD(C_CUR_R);		//Curror Shift Right
	Write_CMD(C_ON);		//turn on  LCD
}



//========================================================================
// ����: void ClearLine(u8 row)
// ����: ���1��
// ����: row: ��(0��1)
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
void ClearLine(u8 row)
{
	u8 i;
	Write_CMD(((row & 1) << 6) | 0x80);
	for(i=0; i<LineLength; i++)	Write_DIS_Data(' ');
}

//========================================================================
// ����: void	WriteChar(u8 row, u8 column, u8 dat)
// ����: ָ���С��к��ַ�, дһ���ַ�
// ����: row: ��(0��1),  column: �ڼ����ַ�(0~15),  dat: Ҫд���ַ�.
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
void	WriteChar(u8 row, u8 column, u8 dat)
{
	Write_CMD((((row & 1) << 6) + column) | 0x80);
	Write_DIS_Data(dat);
}

//========================================================================
// ����: void PutString(u8 row, u8 column, u8 *puts)
// ����: дһ���ַ�����ָ���С��к��ַ����׵�ַ
// ����: row: ��(0��1),  column: �ڼ����ַ�(0~15),  puts: Ҫд���ַ���ָ��.
// ����: none.
// �汾: VER1.0
// ����: 2013-4-1
// ��ע: 
//========================================================================
void PutString(u8 row, u8 column, u8 *puts)
{
	Write_CMD((((row & 1) << 6) + column) | 0x80);
	for ( ;  *puts != 0;  puts++)		//����ֹͣ��0����
	{
		Write_DIS_Data(*puts);
		if(++column >= LineLength)	break;
	}
}


//******************** LCD20 Module END ***************************
