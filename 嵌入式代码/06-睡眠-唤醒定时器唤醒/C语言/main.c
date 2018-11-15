/*---------------------------------------------------------------------*/
/* --- STC MCU International Limited ----------------------------------*/
/* --- STC 1T Series MCU Demo Programme -------------------------------*/
/* --- Mobile: (86)13922805190 ----------------------------------------*/
/* --- Fax: 86-0513-55012956,55012947,55012969 ------------------------*/
/* --- Tel: 86-0513-55012928,55012929,55012966 ------------------------*/
/* --- Web: www.GXWMCU.com --------------------------------------------*/
/* --- QQ:  800003751 -------------------------------------------------*/
/* 如果要在程序中使用此代码,请在程序中注明使用了宏晶科技的资料及程序   */
/*---------------------------------------------------------------------*/


/*************	本程序功能说明	**************

用STC的MCU的IO方式控制74HC595驱动8位数码管。

用户可以修改宏来选择时钟频率.

显示效果为: 上电后显示+2秒计数, 然后睡眠2秒, 醒来再+2秒,一直重复.


******************************************/

#define MAIN_Fosc		22118400L	//定义主时钟

#include	"STC15Fxxxx.H"

#define DIS_DOT		0x20
#define DIS_BLACK	0x10
#define DIS_		0x11

/****************************** 用户定义宏 ***********************************/

#define		Timer0_Reload	(65536UL -(MAIN_Fosc / 1000))		//Timer 0 中断频率, 1000次/秒

/*****************************************************************************/






/*************	本地常量声明	**************/
u8 code t_display[]={						//标准字库
//	 0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F
	0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F,0x77,0x7C,0x39,0x5E,0x79,0x71,
//black	 -     H    J	 K	  L	   N	o   P	 U     t    G    Q    r   M    y
	0x00,0x40,0x76,0x1E,0x70,0x38,0x37,0x5C,0x73,0x3E,0x78,0x3d,0x67,0x50,0x37,0x6e,
	0xBF,0x86,0xDB,0xCF,0xE6,0xED,0xFD,0x87,0xFF,0xEF,0x46};	//0. 1. 2. 3. 4. 5. 6. 7. 8. 9. -1

u8 code T_COM[]={0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80};		//位码



/*************	IO口定义	**************/
sbit	P_HC595_SER   = P4^0;	//pin 14	SER		data input
sbit	P_HC595_RCLK  = P5^4;	//pin 12	RCLk	store (latch) clock
sbit	P_HC595_SRCLK = P4^3;	//pin 11	SRCLK	Shift data clock

/*************	本地变量声明	**************/

u8 	LED8[8];		//显示缓冲
u8	display_index;	//显示位索引
u16	msecond;		//1000ms计数

u8	Test_cnt;	//测试用的秒计数变量
u8	SleepDelay;	//唤醒后再进入睡眠所延时的时间

void	delay_ms(u8 ms);
void 	DisplayScan(void);
void	SetWakeUpTime(u16 SetTime);




/********************** 主函数 ************************/
void main(void)
{
	u8	i;
	
	P0M1 = 0;	P0M0 = 0;	//设置为准双向口
	P1M1 = 0;	P1M0 = 0;	//设置为准双向口
	P2M1 = 0;	P2M0 = 0;	//设置为准双向口
	P3M1 = 0;	P3M0 = 0;	//设置为准双向口
	P4M1 = 0;	P4M0 = 0;	//设置为准双向口
	P5M1 = 0;	P5M0 = 0;	//设置为准双向口
	P6M1 = 0;	P6M0 = 0;	//设置为准双向口
	P7M1 = 0;	P7M0 = 0;	//设置为准双向口

	display_index = 0;
	for(i=0; i<8; i++)	LED8[i] = DIS_BLACK;	//全部消隐
	
	Test_cnt = 0;	//秒计数范围为0~255
	SleepDelay = 0;
	LED8[5] = 0;
	LED8[6] = 0;
	LED8[7] = Test_cnt;
	
	EA = 1;		//允许总中断

	while(1)
	{
		delay_ms(1);	//延时1ms
		DisplayScan();
		
		if(++msecond >= 1000)	//1秒到
		{
			msecond = 0;		//清1000ms计数
			Test_cnt++;			//秒计数+1
			LED8[5] = Test_cnt / 100;
			LED8[6] = (Test_cnt % 100) / 10;
			LED8[7] = Test_cnt % 10;

			if(++SleepDelay >= 2)	//2秒后睡眠
			{
				SleepDelay = 0;

				P_HC595_SER = 0;
				for(i=0; i<16; i++)		//先关闭显示，省电
				{
					P_HC595_SRCLK = 1;
					P_HC595_SRCLK = 0;
				}
				P_HC595_RCLK = 1;
				P_HC595_RCLK = 0;		//锁存输出数据
				
				SetWakeUpTime(2000);	//2秒后醒来

				PCON |= 0x02;	//Sleep
				_nop_();
				_nop_();
				_nop_();
			}
		}
	}
} 
/**********************************************/


//========================================================================
// 函数: void	SetWakeUpTime(u16 SetTime)
// 描述: 唤醒定时器设置时间值函数。
// 参数: SetTime: 要设置的时间值(睡眠的时间), 单位为ms.
// 返回: none.
// 版本: VER1.0
// 日期: 2014-7-15
// 备注: 
//========================================================================
void	SetWakeUpTime(u16 SetTime)
{
	SetTime = (u16)((32768UL * (u32)SetTime) / 16000);	//重装值 = Fwkt/16 * SetTime/1000 = Fwkt * SetTime / 16000
	if(SetTime > 0)	SetTime--;
	WKTCL = (u8)SetTime;
	WKTCH = (u8)(SetTime >> 8) | 0x80;
}

//========================================================================
// 函数: void  delay_ms(unsigned char ms)
// 描述: 延时函数。
// 参数: ms,要延时的ms数, 这里只支持1~255ms. 自动适应主时钟.
// 返回: none.
// 版本: VER1.0
// 日期: 2013-4-1
// 备注: 
//========================================================================
void  delay_ms(u8 ms)
{
     u16 i;
	 do{
	      i = MAIN_Fosc / 13000;
		  while(--i)	;   //14T per loop
     }while(--ms);
}

/**************** 向HC595发送一个字节函数 ******************/
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

/********************** 显示扫描函数 ************************/
void DisplayScan(void)
{	
	Send_595(~T_COM[display_index]);				//输出位码
	Send_595(t_display[LED8[display_index]]);	//输出段码

	P_HC595_RCLK = 1;
	P_HC595_RCLK = 0;							//锁存输出数据
	if(++display_index >= 8)	display_index = 0;	//8位结束回0
}



