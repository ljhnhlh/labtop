
;/*------------------------------------------------------------------*/
;/* --- STC MCU International Limited -------------------------------*/
;/* --- STC 1T Series MCU RC Demo -----------------------------------*/
;/* --- Mobile: (86)13922805190 -------------------------------------*/
;/* --- Fax: 86-0513-55012956,55012947,55012969 ---------------------*/
;/* --- Tel: 86-0513-55012928,55012929,55012966 ---------------------*/
;/* --- Web: www.GXWMCU.com -----------------------------------------*/
;/* --- QQ:  800003751 ----------------------------------------------*/
;/* If you want to use the program or the program referenced in the  */
;/* article, please specify in which data and procedures from STC    */
;/*------------------------------------------------------------------*/

;/*************	����˵��	**************

;STC15W4K60S4 2·10λPWM����Ӧ��.

;PWM0  Ϊ10λPWM.
;PWM1  Ϊ10λPWM.

;******************************************/

STACK_POIRTER	EQU		0D0H	;��ջ��ʼ��ַ

PCA0				EQU	0
PCA1				EQU	1
PCA_Counter			EQU	3
PCA_P12_P11_P10		EQU	(0 SHL 4)
PCA_P34_P35_P36		EQU	(1 SHL 4)
PCA_P24_P25_P26		EQU	(2 SHL 4)
PCA_Mode_PWM		EQU	0x42
PCA_Mode_Capture	EQU	0
PCA_Mode_SoftTimer	EQU	0x48
PCA_Mode_HighPulseOutput	EQU		0x4c
PCA_Clock_1T		EQU	(4 SHL 1)
PCA_Clock_2T		EQU	(1 SHL 1)
PCA_Clock_4T		EQU	(5 SHL 1)
PCA_Clock_6T		EQU	(6 SHL 1)
PCA_Clock_8T		EQU	(7 SHL 1)
PCA_Clock_12T		EQU	(0 SHL 1)
PCA_Clock_Timer0_OF	EQU	(2 SHL 1)
PCA_Clock_ECI		EQU	(3 SHL 1)
PCA_Rise_Active		EQU	(1 SHL 5)
PCA_Fall_Active		EQU	(1 SHL 4)
PCA_PWM_8bit		EQU	(0 SHL 6)
PCA_PWM_7bit		EQU	(1 SHL 6)
PCA_PWM_6bit		EQU	(2 SHL 6)
PCA_PWM_10bit		EQU	(3 SHL 6)


PCA_PWM0 DATA 0F2H	;	//PCAģ��0 PWM�Ĵ�����
PCA_PWM1 DATA 0F3H	;	//PCAģ��1 PWM�Ĵ�����

AUXR1  DATA 0xA2
CCON   DATA 0xD8
CMOD   DATA 0xD9
CCAPM0 DATA 0xDA	; PCAģ��0�Ĺ���ģʽ�Ĵ�����
CCAPM1 DATA 0xDB	; PCAģ��1�Ĺ���ģʽ�Ĵ�����

CL     DATA 0xE9
CCAP0L DATA 0xEA	; PCAģ��0�Ĳ�׽/�ȽϼĴ�����8λ��
CCAP1L DATA 0xEB	; PCAģ��1�Ĳ�׽/�ȽϼĴ�����8λ��

CH     DATA 0xF9
CCAP0H DATA 0xFA	; PCAģ��0�Ĳ�׽/�ȽϼĴ�����8λ��
CCAP1H DATA 0xFB	; PCAģ��1�Ĳ�׽/�ȽϼĴ�����8λ��

CCF0  BIT CCON.0	; PCA ģ��0�жϱ�־����Ӳ����λ�������������0��
CCF1  BIT CCON.1	; PCA ģ��1�жϱ�־����Ӳ����λ�������������0��
CR    BIT CCON.6	; 1: ����PCA������������0: ��ֹ������
CF    BIT CCON.7	; PCA�����������CH��CL��FFFFH��Ϊ0000H����־��PCA�������������Ӳ����λ�������������0��
PPCA  BIT IP.7		; PCA �ж� ���ȼ��趨λ

P1M1		DATA	091H	;	P1M1.n,P1M0.n 	=00--->Standard,	01--->push-pull
P1M0		DATA	092H	;					=10--->pure input,	11--->open drain
P2M1		DATA	0x95;	
P2M0		DATA	0x96;	
P3M1		DATA	0xB1;	
P3M0		DATA	0xB2;	



;************************************************

		ORG		00H				;reset
		LJMP	F_Main


;******************** ������ **************************/
F_Main:
	
	MOV		SP, #STACK_POIRTER
	MOV		PSW, #0
	USING	0		;ѡ���0��R0~R7

;================= �û���ʼ������ ====================================

	LCALL	F_PCA_config	; ��ʼ��PCA

	MOV		R6, #HIGH 800	; PWMֵ���ֽ�
	MOV		R7, #LOW  800	; PWMֵ���ֽ�
	MOV		A, #PCA0		; PCA ��
	LCALL	F_UpdatePwm		; ����PWMֵ

	MOV		R6, #HIGH 400	; PWMֵ���ֽ�
	MOV		R7, #LOW  400	; PWMֵ���ֽ�
	MOV		A, #PCA1		; PCA ��
	LCALL	F_UpdatePwm		; ����PWMֵ

;=================== ��ѭ�� ==================================
L_Main_Loop:

	LJMP	L_Main_Loop
;===================================================================



;========================================================================
; ����: F_PCA_config
; ����: PCA��ʼ��������
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2014-12-15
; ��ע: 
;========================================================================
F_PCA_config:

	CLR		CR;
	MOV		CH, #0;
	MOV		CL, #0;

	ANL		AUXR1, #NOT (3 SHL 4)

;	ORL		AUXR1, #PCA_P12_P11_P10	; �л���P1.2 P1.1 P1.0 (ECI CCP0 CCP1)
;	ANL		P1M1, #NOT 0x07			; ��P1.2 P1.1 P1.0 (ECI CCP0 CCP1) ����Ϊ׼˫˫���(P1.1 P1.0Ҳ��������Ϊ�������)
;	ANL		P1M0, #NOT 0x07

	ORL		AUXR1, #PCA_P24_P25_P26	; �л���P2.4 P2.5 P2.6 (ECI CCP0 CCP1)
	ANL		P2M1, #NOT 0x70			; ��P2.4 P2.5 P2.6 (ECI CCP0 CCP1) ����Ϊ׼˫˫���(P2.5 P2.6Ҳ��������Ϊ�������)
	ANL		P2M0, #NOT 0x70

;	ORL		AUXR1, #PCA_P34_P35_P36	; �л���P3.4 P3.5 P3.6 (ECI CCP0 CCP1)
;	ANL		P3M1, #NOT 0x70			; P3.4 P3.5 P3.6 (ECI CCP0 CCP1) ����Ϊ׼˫˫���(P3.5 P3.6Ҳ��������Ϊ�������)
;	ANL		P3M0, #NOT 0x70
	
	ANL		CMOD, #NOT (7 SHL 1)
	ORL		CMOD, #PCA_Clock_1T		; ѡ��ʱ��Դ
	ANL		CMOD, #NOT 1			; ��ֹ����ж�
;	SETB	PPCA					; �����ȼ��ж�

	MOV		CCAPM0, #PCA_Mode_PWM	; ����ģʽ
	ANL		PCA_PWM0, #NOT (3 SHL 6)
	ORL		PCA_PWM0, #PCA_PWM_10bit	; PWM���
	MOV		CCAP0L, #0xff;
	MOV		CCAP0H, #0xff;

	MOV		CCAPM1, #PCA_Mode_PWM	; ����ģʽ
	ANL		PCA_PWM1, #NOT (3 SHL 6)
	ORL		PCA_PWM1, #PCA_PWM_10bit; PWM���
	MOV		CCAP1L, #0xff;
	MOV		CCAP1H, #0xff;
	SETB	CR
	RET


;========================================================================
; ����: F_UpdatePwm
; ����: ����PWMֵ. 
; ����: ACC: 	PCA���. ȡֵ PCA0,PCA1
;		R6, R7: pwmֵ, 0~1024, ���ֵ������ߵ�ƽ��ʱ��, 0��Ӧ�����ĵ͵�ƽ, 1024��Ӧ�����ĸߵ�ƽ.
; ����: none.
; �汾: V1.0, 2012-11-22
;========================================================================
F_UpdatePwm:
	PUSH	ACC				; ID��ջ
	CLR		F0				; ���ж��Ƿ� 0, F0 = 0, ��ʾΪ0
	MOV		A, R6
	ORL		A, R7
	JZ		L_UpdatePWM_Is0
	SETB	F0		; F0=0, ��ʾ��0
	MOV		A, R7	; pwm_value = ~(pwm_value-1) & 0x3ff;
	CLR		C
	SUBB	A, #1
	CPL		A
	MOV		R7, A
	MOV		A, R6
	SUBB	A, #0
	CPL		A
	SWAP	A
	ANL		A, #0x30
	MOV		R6, A
L_UpdatePWM_Is0:

	POP		ACC		; �ָ�ID
	CJNE	A, #PCA0, L_NotUpdatePCA0
	JB		F0, L_UpdatePCA0_Not0
	ORL		PCA_PWM0, #0x32		; if(pwm_value == 0)
	MOV		CCAP0H, #0xff
	RET

L_UpdatePCA0_Not0:
	MOV		A, PCA_PWM0		; PCA_PWM0 = (PCA_PWM0 & ~0x32) | ((u8)(pwm_value >> 4) & 0x30);
	ANL		A, #NOT 0x32
	ORL		A, R6
	MOV		PCA_PWM0, A
	MOV		CCAP0H, R7		; CCAP0H = (u8)pwm_value;
	RET

L_NotUpdatePCA0:
	CJNE	A, #PCA1, L_NotUpdatePCA1
	JB		F0, L_UpdatePCA1_Not0
	ORL		PCA_PWM1, #0x32		; if(pwm_value == 0)
	MOV		CCAP1H, #0xff
	RET

L_UpdatePCA1_Not0:
	MOV		A, PCA_PWM1		; PCA_PWM0 = (PCA_PWM0 & ~0x32) | ((u8)(pwm_value >> 4) & 0x30);
	ANL		A, #NOT 0x32
	ORL		A, R6
	MOV		PCA_PWM1, A
	MOV		CCAP1H, R7		; CCAP0H = (u8)pwm_value;
L_NotUpdatePCA1:
	RET

	END
	

