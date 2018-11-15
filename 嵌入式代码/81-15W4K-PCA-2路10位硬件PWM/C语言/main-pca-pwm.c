
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

/*************	����˵��	**************

STC15W4K60S4 2·10λPWM����Ӧ��.

PWM0  Ϊ10λPWM.
PWM1  Ϊ10λPWM.

******************************************/

#define MAIN_Fosc		24000000L	//������ʱ��

#include	"STC15Fxxxx.H"

#define	PCA0			0
#define	PCA1			1
#define	PCA_Counter		3
#define	PCA_P12_P11_P10	(0<<4)
#define	PCA_P34_P35_P36	(1<<4)
#define	PCA_P24_P25_P26	(2<<4)
#define	PCA_Mode_PWM				0x42	//B0100_0010
#define	PCA_Mode_Capture			0
#define	PCA_Mode_SoftTimer			0x48	//B0100_1000
#define	PCA_Mode_HighPulseOutput	0x4c	//B0100_1100
#define	PCA_Clock_1T	(4<<1)
#define	PCA_Clock_2T	(1<<1)
#define	PCA_Clock_4T	(5<<1)
#define	PCA_Clock_6T	(6<<1)
#define	PCA_Clock_8T	(7<<1)
#define	PCA_Clock_12T	(0<<1)
#define	PCA_Clock_Timer0_OF	(2<<1)
#define	PCA_Clock_ECI	(3<<1)
#define	PCA_Rise_Active	(1<<5)
#define	PCA_Fall_Active	(1<<4)
#define	PCA_PWM_8bit	(0<<6)
#define	PCA_PWM_7bit	(1<<6)
#define	PCA_PWM_6bit	(2<<6)
#define	PCA_PWM_10bit	(3<<6)

void	PCA_config(void);
void	UpdatePwm(u8 PCA_id, u16 pwm_value);


/************************************************/

/**********************************************/
void main(void)
{
	PCA_config();

//	EA = 1;

	UpdatePwm(PCA0,800);
	UpdatePwm(PCA1,400);
	
	while (1)
	{
	
	}
}

//========================================================================
// ����: void	PCA_config(void)
// ����: PCA��ʼ��������
// ����: none.
// ����: none.
// �汾: VER1.0
// ����: 2014-12-15
// ��ע: 
//========================================================================
void	PCA_config(void)
{
	CR = 0;
	CH = 0;
	CL = 0;

//	AUXR1 = (AUXR1 & ~(3<<4)) | PCA_P12_P11_P10;	P1n_standard(0x07);	//�л���P1.2 P1.1 P1.0 (ECI CCP0 CCP1)
//	AUXR1 = (AUXR1 & ~(3<<4)) | PCA_P24_P25_P26;	P2n_standard(0x70);	//�л���P2.4 P2.5 P2.6 (ECI CCP0 CCP1)
	AUXR1 = (AUXR1 & ~(3<<4)) | PCA_P34_P35_P36;	P3n_standard(0x70);	//�л���P3.4 P3.5 P3.6 (ECI CCP0 CCP1)

	CMOD  = (CMOD  & ~(7<<1)) | PCA_Clock_1T;	//ѡ��ʱ��Դ
	CMOD  &= ~1;								//��ֹ����ж�
//	PPCA = 1;	//�����ȼ��ж�

	CCAPM0 = PCA_Mode_PWM;	//����ģʽ
	PCA_PWM0  = (PCA_PWM0 & ~(3<<6)) | PCA_PWM_10bit;	//PWM���
	CCAP0L = 0xff;
	CCAP0H = 0xff;

	CCAPM1 = PCA_Mode_PWM;	//����ģʽ
	PCA_PWM1  = (PCA_PWM1 & ~(3<<6)) | PCA_PWM_10bit;	//PWM���
	CCAP1L = 0xff;
	CCAP1H = 0xff;
	CR = 1;
}

//========================================================================
// ����: UpdatePwm(u8 PCA_id, u16 pwm_value)
// ����: ����PWMֵ. 
// ����: PCA_id: PCA���. ȡֵ PCA0,PCA1
//		 pwm_value: pwmֵ, 0~1024, ���ֵ������ߵ�ƽ��ʱ��, 0��Ӧ�����ĵ͵�ƽ, 1024��Ӧ�����ĸߵ�ƽ.
// ����: none.
// �汾: V1.0, 2012-11-22
//========================================================================
void	UpdatePwm(u8 PCA_id, u16 pwm_value)
{
	if(pwm_value > 1024)	return;	//PWMֵ����, �˳�
	
	if(PCA_id == PCA0)
	{
		if(pwm_value == 0)
		{
			PCA_PWM0 |= 0x32;
			CCAP0H = 0xff;
		}
		else
		{
			pwm_value = ~(pwm_value-1) & 0x3ff;
			PCA_PWM0 = (PCA_PWM0 & ~0x32) | ((u8)(pwm_value >> 4) & 0x30);
			CCAP0H = (u8)pwm_value;
		}
	}
	else if(PCA_id == PCA1)
	{
		if(pwm_value == 0)
		{
			PCA_PWM1 |= 0x32;
			CCAP1H = 0xff;
		}
		else
		{
			pwm_value = ~(pwm_value-1) & 0x3ff;
			PCA_PWM1 = (PCA_PWM1 & ~0x32) | ((u8)(pwm_value >> 4) & 0x30);
			CCAP1H = (u8)pwm_value;
		}
	}
}


