
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

���ļ�ΪSTC15xxxϵ�еĶ�ʱ����ʼ�����жϳ���,�û�����������ļ����޸��Լ���Ҫ���жϳ���.


******************************************/



#include	"timer.h"

/********************* Timer0�жϺ���************************/
void timer0_int (void) interrupt TIMER0_VECTOR
{
   P10 = ~P10;
}

/********************* Timer1�жϺ���************************/
void timer1_int (void) interrupt TIMER1_VECTOR
{
   P11 = ~P11;

}

/********************* Timer2�жϺ���************************/
void timer2_int (void) interrupt TIMER2_VECTOR
{
	P12 = ~P12;
}

/********************* Timer2�жϺ���************************/
void timer3_int (void) interrupt TIMER3_VECTOR
{
	P13 = ~P13;
}

/********************* Timer2�жϺ���************************/
void timer4_int (void) interrupt TIMER4_VECTOR
{
	P14 = ~P14;
}


//========================================================================
// ����: u8	Timer_Inilize(u8 TIM, TIM_InitTypeDef *TIMx)
// ����: ��ʱ����ʼ������.
// ����: TIMx: �ṹ����,��ο�timer.h��Ķ���.
// ����: �ɹ�����0, �ղ�������1,���󷵻�2.
// �汾: V1.0, 2012-10-22
//========================================================================
u8	Timer_Inilize(u8 TIM, TIM_InitTypeDef *TIMx)
{
	if(TIM > Timer4)	return 1;	//�ղ���

	if(TIM == Timer0)
	{
		if(TIMx->TIM_Mode >  TIM_16BitAutoReloadNoMask)	return 2;	//����
		TR0 = 0;		//ֹͣ����
		ET0 = 0;	//��ֹ�ж�
		PT0 = 0;	//�����ȼ��ж�
		TMOD &= 0xf0;	//��ʱģʽ, 16λ�Զ���װ
		AUXR &= ~0x80;	//12Tģʽ, 
		INT_CLKO &= ~0x01;	//�����ʱ��
		if(TIMx->TIM_Interrupt == ENABLE)		ET0 = 1;	//�����ж�
		if(TIMx->TIM_Polity == PolityHigh)		PT0 = 1;	//�����ȼ��ж�
		TMOD |= TIMx->TIM_Mode;	//����ģʽ,0: 16λ�Զ���װ, 1: 16λ��ʱ/����, 2: 8λ�Զ���װ, 3: 16λ�Զ���װ, ���������ж�
		if(TIMx->TIM_ClkSource == TIM_CLOCK_1T)		AUXR |=  0x80;	//1T
		if(TIMx->TIM_ClkSource == TIM_CLOCK_Ext)	TMOD |=  0x04;	//����������Ƶ
		if(TIMx->TIM_ClkOut == ENABLE)	INT_CLKO |=  0x01;	//���ʱ��
		
		TH0 = (u8)(TIMx->TIM_Value >> 8);
		TL0 = (u8)TIMx->TIM_Value;
		if(TIMx->TIM_Run == ENABLE)	TR0 = 1;	//��ʼ����
		return	0;		//�ɹ�
	}

	if(TIM == Timer1)
	{
		if(TIMx->TIM_Mode >= TIM_16BitAutoReloadNoMask)	return 2;	//����
		TR1 = 0;	//ֹͣ����
		ET1 = 0;	//��ֹ�ж�
		PT1 = 0;	//�����ȼ��ж�
		TMOD &=  0x0f;	//��ʱģʽ, 16λ�Զ���װ
		AUXR &= ~0x40;	//12Tģʽ, 
		INT_CLKO &= ~0x02;	//�����ʱ��
		if(TIMx->TIM_Interrupt == ENABLE)		ET1 = 1;	//�����ж�
		if(TIMx->TIM_Polity == PolityHigh)		PT1 = 1;	//�����ȼ��ж�
		TMOD |= (TIMx->TIM_Mode << 4);	//����ģʽ,0: 16λ�Զ���װ, 1: 16λ��ʱ/����, 2: 8λ�Զ���װ
		if(TIMx->TIM_ClkSource == TIM_CLOCK_1T)		AUXR |=  0x40;	//1T
		if(TIMx->TIM_ClkSource == TIM_CLOCK_Ext)	TMOD |=  0x40;	//����������Ƶ
		if(TIMx->TIM_ClkOut == ENABLE)	INT_CLKO |=  0x02;	//���ʱ��
		
		TH1 = (u8)(TIMx->TIM_Value >> 8);
		TL1 = (u8)TIMx->TIM_Value;
		if(TIMx->TIM_Run == ENABLE)	TR1 = 1;	//��ʼ����
		return	0;		//�ɹ�
	}

	if(TIM == Timer2)		//Timer2,�̶�Ϊ16λ�Զ���װ, �ж������ȼ�
	{
		if(TIMx->TIM_ClkSource >  TIM_CLOCK_Ext)	return 2;
		AUXR &= ~0x1c;		//ֹͣ����, ��ʱģʽ, 12Tģʽ
		IE2  &= ~(1<<2);	//��ֹ�ж�
		INT_CLKO &= ~0x04;	//�����ʱ��
		if(TIMx->TIM_Interrupt == ENABLE)			IE2  |=  (1<<2);	//�����ж�
		if(TIMx->TIM_ClkSource == TIM_CLOCK_1T)		AUXR |=  (1<<2);	//1T
		if(TIMx->TIM_ClkSource == TIM_CLOCK_Ext)	AUXR |=  (1<<3);	//����������Ƶ
		if(TIMx->TIM_ClkOut == ENABLE)	INT_CLKO |=  0x04;	//���ʱ��

		TH2 = (u8)(TIMx->TIM_Value >> 8);
		TL2 = (u8)TIMx->TIM_Value;
		if(TIMx->TIM_Run == ENABLE)	AUXR |=  (1<<4);	//��ʼ����
		return	0;		//�ɹ�
	}

	if(TIM == Timer3)		//Timer3,�̶�Ϊ16λ�Զ���װ, �ж������ȼ�
	{
		if(TIMx->TIM_ClkSource >  TIM_CLOCK_Ext)	return 2;
		T4T3M &= 0xf0;		//ֹͣ����, ��ʱģʽ, 12Tģʽ, �����ʱ��
		IE2  &= ~(1<<5);	//��ֹ�ж�
		if(TIMx->TIM_Interrupt == ENABLE)			IE2  |=  (1<<5);	//�����ж�
		if(TIMx->TIM_ClkSource == TIM_CLOCK_1T)		T4T3M |=  (1<<1);	//1T
		if(TIMx->TIM_ClkSource == TIM_CLOCK_Ext)	T4T3M |=  (3<<1);	//����������Ƶ
		if(TIMx->TIM_ClkOut == ENABLE)	T4T3M |=  1;	//���ʱ��

		TH3 = (u8)(TIMx->TIM_Value >> 8);
		TL3 = (u8)TIMx->TIM_Value;
		if(TIMx->TIM_Run == ENABLE)	T4T3M |=  (1<<3);	//��ʼ����
		return	0;		//�ɹ�
	}

	if(TIM == Timer4)		//Timer4,�̶�Ϊ16λ�Զ���װ, �ж������ȼ�
	{
		if(TIMx->TIM_ClkSource >  TIM_CLOCK_Ext)	return 2;
		T4T3M &= 0x0f;		//ֹͣ����, ��ʱģʽ, 12Tģʽ, �����ʱ��
		IE2  &= ~(1<<6);	//��ֹ�ж�
		if(TIMx->TIM_Interrupt == ENABLE)			IE2  |=  (1<<6);	//�����ж�
		if(TIMx->TIM_ClkSource == TIM_CLOCK_1T)		T4T3M |=  (1<<5);	//1T
		if(TIMx->TIM_ClkSource == TIM_CLOCK_Ext)	T4T3M |=  (3<<5);	//����������Ƶ
		if(TIMx->TIM_ClkOut == ENABLE)	T4T3M |=  (1<<4);	//���ʱ��

		TH4 = (u8)(TIMx->TIM_Value >> 8);
		TL4 = (u8)TIMx->TIM_Value;
		if(TIMx->TIM_Run == ENABLE)	T4T3M |=  (1<<7);	//��ʼ����
		return	0;		//�ɹ�
	}

	return 2;	//����
}
