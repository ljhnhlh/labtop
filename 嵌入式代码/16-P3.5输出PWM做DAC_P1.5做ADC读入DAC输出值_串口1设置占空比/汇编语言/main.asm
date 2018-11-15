
;/*---------------------------------------------------------------------*/
;/* --- STC MCU Limited ------------------------------------------------*/
;/* --- Mobile: (86)13922805190 ----------------------------------------*/
;/* --- Fax: 86-755-82905966 -------------------------------------------*/
;/* --- Tel: 86-755-82948412 -------------------------------------------*/
;/* --- Web: www.STCMCU.com --------------------------------------------*/
;/* ���Ҫ��������Ӧ�ô˴���,����������ע��ʹ���˺꾧�Ƽ������ϼ�����   */
;/*---------------------------------------------------------------------*/

;/*************	����˵��	**************

;ʹ��PCA0��P3.5���8λ��PWM, �����PWM����RC�˲���ֱ����ѹ��P1.5��ADC�����������ʾ����.

;����1����Ϊ115200bps, 8,n, 1, �л���P3.0 P3.1, ���غ�Ϳ���ֱ�Ӳ���. ��ʱ��Ϊ22.1184MHZ, ͨ������1����ռ�ձ�.

;��������ʹ��ASCII������֣����磺 10����������ռ�ձ�Ϊ10/256�� 100�� ��������ռ�ձ�Ϊ100/256��

;�������õ�ֵΪ0~256, 0Ϊ�����͵�ƽ, 256Ϊ�����ߵ�ƽ.

;���4λ�������ʾPWM��ռ�ձ�ֵ���ұ�4λ�������ʾADCֵ��

;��STC��MCU��IO��ʽ����74HC595����8λ����ܡ�

;�û������޸ĺ���ѡ��ʱ��Ƶ��.

;�û�������"�û������"��ѡ��������. �Ƽ�����ʹ�ù��������.

;ʹ��Timer0��16λ�Զ���װ������1ms����,�������������������, �û��޸�MCU��ʱ��Ƶ��ʱ,�Զ���ʱ��1ms.

;******************************************/

;/****************************** �û������ ***********************************/

Fosc_KHZ	EQU	22118	;22118KHZ

STACK_POIRTER	EQU		0D0H	;��ջ��ʼ��ַ

LED_TYPE		EQU		000H	; ����LED����, 000H -- ����, 0FFH -- ����

Timer0_Reload	EQU		(65536 - Fosc_KHZ)	; Timer 0 �ж�Ƶ��, 1000��/��

DIS_DOT			EQU		020H
DIS_BLACK		EQU		010H
DIS_			EQU		011H

;UART1_Baudrate	EQU		(-4608)	;   600bps @ 11.0592MHz
;UART1_Baudrate	EQU		(-2304)	;  1200bps @ 11.0592MHz	UART1_Baudrate = (MAIN_Fosc / Baudrate)
;UART1_Baudrate	EQU		(-1152)	;  2400bps @ 11.0592MHz
;UART1_Baudrate	EQU		(-576)	;  4800bps @ 11.0592MHz
;UART1_Baudrate	EQU		(-288)	;  9600bps @ 11.0592MHz
;UART1_Baudrate	EQU		(-144)	; 19200bps @ 11.0592MHz
;UART1_Baudrate	EQU		(-72)	; 38400bps @ 11.0592MHz
;UART1_Baudrate	EQU		(-48)	; 57600bps @ 11.0592MHz
;UART1_Baudrate	EQU		(-24)	;115200bps @ 11.0592MHz

;UART1_Baudrate	EQU		(-7680)	;   600bps @ 18.432MHz
;UART1_Baudrate	EQU		(-3840)	;  1200bps @ 18.432MHz
;UART1_Baudrate	EQU		(-1920)	;  2400bps @ 18.432MHz
;UART1_Baudrate	EQU		(-960)	;  4800bps @ 18.432MHz
;UART1_Baudrate	EQU		(-480)	;  9600bps @ 18.432MHz
;UART1_Baudrate	EQU		(-240)	; 19200bps @ 18.432MHz
;UART1_Baudrate	EQU		(-120)	; 38400bps @ 18.432MHz
;UART1_Baudrate	EQU		(-80)	; 57600bps @ 18.432MHz
;UART1_Baudrate	EQU		(-40)	;115200bps @ 18.432MHz

;UART1_Baudrate	EQU		(-9216)	;   600bps @ 22.1184MHz
;UART1_Baudrate	EQU		(-4608)	;  1200bps @ 22.1184MHz
;UART1_Baudrate	EQU		(-2304)	;  2400bps @ 22.1184MHz
;UART1_Baudrate	EQU		(-1152)	;  4800bps @ 22.1184MHz
;UART1_Baudrate	EQU		(-576)	;  9600bps @ 22.1184MHz
;UART1_Baudrate	EQU		(-288)	; 19200bps @ 22.1184MHz
;UART1_Baudrate	EQU		(-144)	; 38400bps @ 22.1184MHz
;UART1_Baudrate	EQU		(-96)	; 57600bps @ 22.1184MHz
UART1_Baudrate	EQU		(-48)	;115200bps @ 22.1184MHz

;UART1_Baudrate	EQU		(-6912)	; 1200bps @ 33.1776MHz
;UART1_Baudrate	EQU		(-3456)	; 2400bps @ 33.1776MHz
;UART1_Baudrate	EQU		(-1728)	; 4800bps @ 33.1776MHz
;UART1_Baudrate	EQU		(-864)	; 9600bps @ 33.1776MHz
;UART1_Baudrate	EQU		(-432)	;19200bps @ 33.1776MHz
;UART1_Baudrate	EQU		(-216)	;38400bps @ 33.1776MHz
;UART1_Baudrate	EQU		(-144)	;57600bps @ 33.1776MHz
;UART1_Baudrate	EQU		(-72)	;115200bps @ 33.1776MHz


;*******************************************************************
;*******************************************************************


ADC_P10			EQU		0x01	;IO���� Px.0
ADC_P11			EQU		0x02	;IO���� Px.1
ADC_P12			EQU		0x04	;IO���� Px.2
ADC_P13			EQU		0x08	;IO���� Px.3
ADC_P14			EQU		0x10	;IO���� Px.4
ADC_P15			EQU		0x20	;IO���� Px.5
ADC_P16			EQU		0x40	;IO���� Px.6
ADC_P17			EQU		0x80	;IO���� Px.7
ADC_P1_All		EQU		0xFF	;IO��������

ADC_PowerOn		EQU		(1 SHL 7)
ADC_90T			EQU		(3 SHL 5)
ADC_180T		EQU		(2 SHL 5)
ADC_360T		EQU		(1 SHL 5)
ADC_540T		EQU		0
ADC_FLAG		EQU		(1 SHL 4)	;�����0
ADC_START		EQU		(1 SHL 3)	;�Զ���0
ADC_CH0			EQU		0
ADC_CH1			EQU		1
ADC_CH2			EQU		2
ADC_CH3			EQU		3
ADC_CH4			EQU		4
ADC_CH5			EQU		5
ADC_CH6			EQU		6
ADC_CH7			EQU		7

ADC_RES_H2L8	EQU		(1 SHL 5)
ADC_RES_H8L2	EQU		NOT (1 SHL 5)

PCA_P12_P11_P10_P37		EQU		(0 SHL 4)
PCA_P34_P35_P36_P37		EQU		(1 SHL 4)
PCA_P24_P25_P26_P27		EQU		(2 SHL 4)
PCA_Mode_PWM			EQU		042H
PCA_Mode_Capture		EQU		0
PCA_Mode_SoftTimer		EQU		048H
PCA_Clock_1T			EQU		(4 SHL 1)
PCA_Clock_2T			EQU		(1 SHL 1)
PCA_Clock_4T			EQU		(5 SHL 1)
PCA_Clock_6T			EQU		(6 SHL 1)
PCA_Clock_8T			EQU		(7 SHL 1)
PCA_Clock_12T			EQU		(0 SHL 1)
PCA_Clock_ECI			EQU		(3 SHL 1)
PCA_Rise_Active			EQU		(1 SHL 5)
PCA_Fall_Active			EQU		(1 SHL 4)

;ENABLE					EQU		1

PCA_PWM0 DATA 0F2H	;	//PCAģ��0 PWM�Ĵ�����
PCA_PWM1 DATA 0F3H	;	//PCAģ��1 PWM�Ĵ�����
PCA_PWM2 DATA 0F4H	;	//PCAģ��2 PWM�Ĵ�����

AUXR1  DATA 0xA2
CCON   DATA 0xD8
CMOD   DATA 0xD9
CCAPM0 DATA 0xDA	; PCAģ��0�Ĺ���ģʽ�Ĵ�����
CCAPM1 DATA 0xDB	; PCAģ��1�Ĺ���ģʽ�Ĵ�����
CCAPM2 DATA 0xDC	; PCAģ��2�Ĺ���ģʽ�Ĵ�����

CL     DATA 0xE9
CCAP0L DATA 0xEA	; PCAģ��0�Ĳ�׽/�ȽϼĴ�����8λ��
CCAP1L DATA 0xEB	; PCAģ��1�Ĳ�׽/�ȽϼĴ�����8λ��
CCAP2L DATA 0xEC	; PCAģ��2�Ĳ�׽/�ȽϼĴ�����8λ��

CH     DATA 0xF9
CCAP0H DATA 0xFA	; PCAģ��0�Ĳ�׽/�ȽϼĴ�����8λ��
CCAP1H DATA 0xFB	; PCAģ��1�Ĳ�׽/�ȽϼĴ�����8λ��
CCAP2H DATA 0xFC	; PCAģ��2�Ĳ�׽/�ȽϼĴ�����8λ��

CCF0  BIT CCON.0	; PCA ģ��0�жϱ�־����Ӳ����λ�������������0��
CCF1  BIT CCON.1	; PCA ģ��1�жϱ�־����Ӳ����λ�������������0��
CCF2  BIT CCON.2	; PCA ģ��2�жϱ�־����Ӳ����λ�������������0��
CR    BIT CCON.6	; 1: ����PCA������������0: ��ֹ������
CF    BIT CCON.7	; PCA�����������CH��CL��FFFFH��Ϊ0000H����־��PCA�������������Ӳ����λ�������������0��
PPCA  BIT IP.7		; PCA �ж� ���ȼ��趨λ

;*******************************************************************
AUXR		DATA 08EH
P4			DATA 0C0H
P5			DATA 0C8H
ADC_CONTR	DATA 0BCH	;��ADϵ��
ADC_RES		DATA 0BDH	;��ADϵ��
ADC_RESL	DATA 0BEH	;��ADϵ��
P1ASF		DATA 09DH
PCON2		DATA 097H

INT_CLKO 	DATA 	0x8F
P_SW1 		DATA	0A2H
IE2   		DATA	0AFH
T2H			DATA 	0D6H
T2L			DATA 	0D7H

P0M1	DATA	0x93	; P0M1.n,P0M0.n 	=00--->Standard,	01--->push-pull
P0M0	DATA	0x94	; 					=10--->pure input,	11--->open drain
P1M1	DATA	0x91	; P1M1.n,P1M0.n 	=00--->Standard,	01--->push-pull
P1M0	DATA	0x92	; 					=10--->pure input,	11--->open drain
P2M1	DATA	0x95	; P2M1.n,P2M0.n 	=00--->Standard,	01--->push-pull
P2M0	DATA	0x96	; 					=10--->pure input,	11--->open drain
P3M1	DATA	0xB1	; P3M1.n,P3M0.n 	=00--->Standard,	01--->push-pull
P3M0	DATA	0xB2	; 					=10--->pure input,	11--->open drain
P4M1	DATA	0xB3	; P4M1.n,P4M0.n 	=00--->Standard,	01--->push-pull
P4M0	DATA	0xB4	; 					=10--->pure input,	11--->open drain
P5M1	DATA	0xC9	; P5M1.n,P5M0.n 	=00--->Standard,	01--->push-pull
P5M0	DATA	0xCA	; 					=10--->pure input,	11--->open drain
P6M1	DATA	0xCB	; P6M1.n,P6M0.n 	=00--->Standard,	01--->push-pull
P6M0	DATA	0xCC	; 					=10--->pure input,	11--->open drain
P7M1	DATA	0xE1	;
P7M0	DATA	0xE2	;

;*************	IO�ڶ���	**************/
P_HC595_SER   BIT P4.0	;	//pin 14	SER		data input
P_HC595_RCLK  BIT P5.4	;	//pin 12	RCLk	store (latch) clock
P_HC595_SRCLK BIT P4.3	;	//pin 11	SRCLK	Shift data clock

;*************	���ر�������	**************/
B_1ms			BIT		20H.0	;	1ms��־

LED8			DATA	30H		;	��ʾ���� 30H ~ 37H
display_index	DATA	38H		;	��ʾλ����

msecond_H		DATA	39H		;
msecond_L		DATA	3AH		;

RX1_Lenth		EQU		16		; ���ڽ��ջ��峤��

B_TX1_Busy		BIT		20H.1	; ����æ��־
B_RX1_OK		BIT		20H.2	; ���ս�����־
TX1_Cnt			DATA	3BH		; ���ͼ���
RX1_Cnt			DATA	3CH		; ���ռ���
RX1_TimeOut		DATA	3DH		; ��ʱ����
RX1_Buffer		DATA	40H		;40 ~ 4FH ���ջ���

;*******************************************************************
;*******************************************************************
		ORG		0000H				;reset
		LJMP	F_Main

		ORG		000BH				;1  Timer0 interrupt
		LJMP	F_Timer0_Interrupt

		ORG		0023H				;4  UART1 interrupt
		LJMP	F_UART1_Interrupt


;******************** ������ **************************/
		ORG		0100H		;reset
F_Main:
	CLR		A
	MOV		P0M1, A 	;����Ϊ׼˫���
 	MOV		P0M0, A
	MOV		P1M1, A 	;����Ϊ׼˫���
 	MOV		P1M0, A
	MOV		P2M1, A 	;����Ϊ׼˫���
 	MOV		P2M0, A
	MOV		P3M1, A 	;����Ϊ׼˫���
 	MOV		P3M0, A
	MOV		P4M1, A 	;����Ϊ׼˫���
 	MOV		P4M0, A
	MOV		P5M1, A 	;����Ϊ׼˫���
 	MOV		P5M0, A
	MOV		P6M1, A 	;����Ϊ׼˫���
 	MOV		P6M0, A
	MOV		P7M1, A 	;����Ϊ׼˫���
 	MOV		P7M0, A

	
	MOV		SP, #STACK_POIRTER
	MOV		PSW, #0
	USING	0		;ѡ���0��R0~R7

;================= �û���ʼ������ ====================================

	MOV		display_index, #0
	MOV		R0, #LED8
	MOV		R2, #8
L_ClearLoop:
	MOV		@R0, #DIS_BLACK		;�ϵ�����
	INC		R0
	DJNZ	R2, L_ClearLoop
	
	CLR		TR0
	ORL		AUXR, #(1 SHL 7)	; Timer0_1T();
	ANL		TMOD, #NOT 04H		; Timer0_AsTimer();
	ANL		TMOD, #NOT 03H		; Timer0_16bitAutoReload();
	MOV		TH0, #Timer0_Reload / 256	;Timer0_Load(Timer0_Reload);
	MOV		TL0, #Timer0_Reload MOD 256
	SETB	ET0			; Timer0_InterruptEnable();
	SETB	TR0			; Timer0_Run();
	SETB	EA			; �����ж�
	

	LCALL	F_ADC_config	; ADC��ʼ��
	LCALL	F_PCA_Init	;PCA��ʼ��

	MOV		LED8+0, #1	;	//��ʾPWMĬ��ֵ
	MOV		LED8+1, #2	;
	MOV		LED8+2, #8	;
	MOV		LED8+3, #DIS_BLACK	;	//��λ����ʾ

	MOV		A, #1
	LCALL	F_UART1_config	; ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.

	MOV		DPTR, #StringText1	;Load string address to DPTR
	LCALL	F_SendString1		;Send string

;=================== ��ѭ�� ==================================
L_Main_Loop:
	JNB		B_1ms,  L_Main_Loop		;1msδ��
	CLR		B_1ms
	
	MOV		A, RX1_TimeOut
	JNZ		L_CheckRx1TimeOut	;���ڿ��г�ʱ������0, 
L_QuitCheckRxTimeOut:
	LJMP	L_QuitProcessUart1	;���ڿ��г�ʱ����Ϊ0, �˳�
L_CheckRx1TimeOut:
	DJNZ	RX1_TimeOut, L_QuitCheckRxTimeOut	;���ڿ��г�ʱ����-1��0�˳�

	SETB	B_RX1_OK			;���ڿ��г�ʱ, ���ս���, ����־
	MOV		A, RX1_Cnt
	JNZ		L_RxCntNotZero		;���յ��ַ����ǿ�, ����
	LJMP	L_QuitProcessUart1	;���յ��ַ�����, ���˳�

L_RxCntNotZero:
	ANL		A, #NOT 3	;����Ϊ3λ����
	JZ		L_NumberLengthOk
	MOV		DPTR, #StringError3	;Load string address to DPTR	"����! �����ַ�����! ����ռ�ձ�Ϊ0~256!"
	LCALL	F_SendString1		;Send string
	LJMP	L_QuitCalculatePWM	;�˳�
	
L_NumberLengthOk:
	MOV		R2, #0
	MOV		R3, #0
	MOV		R0, #RX1_Buffer
	MOV		R1, RX1_Cnt

L_GetUartPwmLoop:
	MOV		A, @R0
	CLR		C
	SUBB	A, #'0'				;�����Ƿ�С��ASCII����0
	JNC		L_RxdataLargeThan0
	MOV		DPTR, #StringError1	;Load string address to DPTR	"����! ���յ�С��0�������ַ�! ռ�ձ�Ϊ0~256!"
	LCALL	F_SendString1		;Send string
	LJMP	L_QuitCalculatePWM
	
L_RxdataLargeThan0:
	MOV		A, @R0
	CLR		C
	SUBB	A, #03AH			;�����Ƿ����ASCII����9
	JC		L_RxdataLessThan03A
	MOV		DPTR, #StringError4	;Load string address to DPTR	"����! ���յ�����9�������ַ�! ռ�ձ�Ϊ0~256!"
	LCALL	F_SendString1		;Send string
	LJMP	L_QuitCalculatePWM

L_RxdataLessThan03A:
	MOV		AR4, R2
	MOV		AR5, R3
	MOV		R7, #10
	LCALL	F_MUL16x8	;(R4,R5)* R7 -->(R5,R6,R7)
	MOV		AR2, R6
	MOV		AR3, R7
	MOV		A, @R0		;���� [R2 R3] = [R2 R3] * 10 + RX1_Buffer[i] - '0';
	CLR		C
	SUBB	A, #'0'
	ADD		A, R3
	MOV		R3, A
	CLR		A
	ADDC	A, R2
	MOV		R2, A
	INC		R0
	DJNZ	R1, L_GetUartPwmLoop

	MOV		A, R3
	CLR		C
	SUBB	A, #LOW 257		;if(j >= 257)
	MOV		A, R2
	SUBB	A, #HIGH 257
	JC		L_SetPWM_Right
	MOV		DPTR, #StringError2	;Load string address to DPTR	����! ����ռ�ձȹ���, �벻Ҫ����256!
	LCALL	F_SendString1		;Send string
	LJMP	L_QuitCalculatePWM

L_SetPWM_Right:

	LCALL	F_UpdatePwm		;����ռ�ձ�
	MOV		A, R2
	JZ		L_PWM_LessTan256
	MOV		LED8,   #2		;ռ�ձ�Ϊ256,��ʾ256
	MOV		LED8+1, #5
	MOV		LED8+2, #6
	SJMP	L_SetPWM_OK
L_PWM_LessTan256:
	MOV		A, R3
	MOV		B, #100		;��ʾ0~255ռ�ձ�
	DIV		AB
	MOV		LED8,   A
	MOV		A, B
	MOV		B, #10
	DIV		AB
	MOV		LED8+1, A
	MOV		LED8+2, B
	MOV		A, LED8
	JNZ		L_SetPWM_OK
	MOV		LED8, #DIS_BLACK	;��λ��0

L_SetPWM_OK:
	MOV		DPTR, #StringText2	;Load string address to DPTR	"�Ѹ���ռ�ձ�!"
	LCALL	F_SendString1		;Send string
L_QuitCalculatePWM:
	MOV		RX1_Cnt, #0
	CLR		B_RX1_OK
L_QuitProcessUart1:

;=================== ���300ms�Ƿ� ==================================
	INC		msecond_L		;msecond + 1
	MOV		A, msecond_L
	JNZ		$+4
	INC		msecond_H
	
	CLR		C
	MOV		A, msecond_L	;msecond - 300
	SUBB	A, #LOW 300
	MOV		A, msecond_H
	SUBB	A, #HIGH 300
	JNC		L_300msIsGood	;if(msecond < 300), jmp
	LJMP	L_Main_Loop		;if(msecond == 300), jmp
L_300msIsGood:

;================= 300ms�� ====================================
	MOV		msecond_L, #0	;if(msecond >= 1000)
	MOV		msecond_H, #0

	MOV		A, #ADC_CH5
	LCALL	F_Get_ADC10bitResult	; ���ⲿ��ѹADC, ��ѯ��ʽ��һ��ADC, ����ֵ(R6 R7)����ADC���, == 1024 Ϊ����

	LCALL	F_HEX2_DEC		;(R6 R7) HEX Change to DEC ---> (R3 R4 R5), use (R2~R7)
	
	MOV		A, R4			;��ʾADCֵ
	SWAP	A
	ANL		A, #0x0F
	MOV		LED8+4, A
	MOV		A, R4
	ANL		A, #0x0F
	MOV		LED8+5, A
	MOV		A, R5
	SWAP	A
	ANL		A, #0x0F
	MOV		LED8+6, A
	MOV		A, R5
	ANL		A, #0x0F
	MOV		LED8+7, A

	MOV		A, LED8+4			;��ʾ����Ч0
	JNZ		L_QuitProcessADC
	MOV		LED8+4, #DIS_BLACK
	MOV		A, LED8+5
	JNZ		L_QuitProcessADC
	MOV		LED8+5, #DIS_BLACK
	MOV		A, LED8+6
	JNZ		L_QuitProcessADC
	MOV		LED8+6, #DIS_BLACK
L_QuitProcessADC:

L_Quit_Check_300ms:


	LJMP	L_Main_Loop
;===================================================================

;========================================================================
; ����: F_PCA_Init
; ����: PCA��ʼ������.
; ����: none
; ����: none.
; �汾: V1.0, 2013-11-22
;========================================================================
F_PCA_Init:
	CLR		CR
	MOV		CH, #0
	MOV		CL, #0
	MOV		A, AUXR1
	ANL		A, # NOT(3 SHL 4)
	ORL		A, #PCA_P34_P35_P36_P37		;�л�IO��
	MOV		AUXR1, A
	MOV		A, CMOD
	ANL		A, #NOT(7 SHL 1)
	ORL		A, #PCA_Clock_1T		;ѡ��ʱ��Դ
	MOV		CMOD, A

	MOV		CCAPM0, #PCA_Mode_PWM	; PWMģʽ
	MOV		CCAP0L, #128			; ��Ӱ��Ĵ���д�벶��Ĵ�������дCCAP0L
	MOV		CCAP0H, #128			; ��дCCAP0H

;	SETB	PPCA		; �����ȼ��ж�
	SETB	CR			; ����PCA��ʱ��
	RET

;======================================================================

;========================================================================
; ����: F_UpdatePwm
; ����: ����PWMֵ. 
; ����: [R2 R3]: pwmֵ, ���ֵ������͵�ƽ��ʱ��.
; ����: none.
; �汾: V1.0, 2012-11-22
;========================================================================
F_UpdatePwm:
	MOV		A, R2
	ORL		A, R3
	JNZ		L_UpdatePWM_Not0
	ORL		PCA_PWM0, #3		; PWM0һֱ���0		PWM0_OUT_0();	��������͵�ƽ
	RET
	
L_UpdatePWM_Not0:
	MOV		A, #0
	CLR		C
	SUBB	A, R3
	MOV		CCAP0H, A
	ANL		PCA_PWM0, #NOT 3	; PWM0�������(Ĭ��)	PWM0_NORMAL();
	RET


;***************************************************************************
F_MUL16x8:               ;(R4,R5)* R7 -->(R5,R6,R7)
        MOV   A,R7      ;1T		1
		MOV   B,R5      ;2T		3
		MUL   AB        ;4T  R3*R7	4
		MOV   R6,B      ;1T		4
		XCH   A,R7      ;2T		3
		
		MOV   B,R4      ;1T		3
		MUL   AB        ;4T  R3*R6	4
		ADD   A,R6      ;1T		2
		MOV   R6,A      ;1T		3
		CLR   A         ;1T		1
		ADDC  A,B       ;1T		3
		MOV   R5,A      ;1T		2
		RET             ;4T		10

;//========================================================================
;// ����: F_HEX2_DEC
;// ����: ��˫�ֽ�ʮ��������ת��ʮ����BCD��.
;// ����: (R6 R7): Ҫת����˫�ֽ�ʮ��������.
;// ����: (R3 R4 R5) = BCD��.
;// �汾: V1.0, 2013-10-22
;//========================================================================
F_HEX2_DEC:        	;(R6 R7) HEX Change to DEC ---> (R3 R4 R5), use (R2~R7)
		MOV  	R2,#16
		MOV  	R3,#0
		MOV  	R4,#0
		MOV  	R5,#0

L_HEX2_DEC:
		CLR  	C	
		MOV  	A,R7
		RLC  	A	
		MOV  	R7,A
		MOV  	A,R6
		RLC  	A	
		MOV  	R6,A

		MOV  	A,R5
		ADDC 	A,R5
		DA   	A	
		MOV  	R5,A

		MOV  	A,R4
		ADDC 	A,R4
		DA   	A	
		MOV  	R4,A

		MOV  	A,R3
		ADDC 	A,R3
		DA   	A	
		MOV  	R3,A

		DJNZ 	R2,L_HEX2_DEC
		RET
;**********************************************/

F_ADC_config:
	MOV		P1ASF, #ADC_P15			; ����Ҫ��ADC��IO,	ADC_P10 ~ ADC_P17(�����),ADC_P1_All
	MOV		ADC_CONTR, #(ADC_PowerOn + ADC_90T)	;��ADC, �����ٶ�
	ORL		PCON2, #ADC_RES_H2L8		;10λAD����ĸ�2λ��ADC_RES�ĵ�2λ����8λ��ADC_RESL��
	ORL		P1M1, #ADC_P15			; ��ADC������Ϊ��������
	ANL		P1M0, #NOT ADC_P15
;	SETB	EADC					;�ж�����
;	SETB	PADC					;���ȼ�����
	RET

;//========================================================================
;// ����: F_Get_ADC10bitResult
;// ����: ��ѯ����һ��ADC���.
;// ����: ACC: ѡ��Ҫת����ADC.
;// ����: (R6 R7) = 10λADC���.
;// �汾: V1.0, 2013-10-22
;//========================================================================
F_Get_ADC10bitResult:	;ACC - ͨ��0~7, ��ѯ��ʽ��һ��ADC, ����ֵ(R6 R7)����ADC���, == 1024 Ϊ����
	MOV		R7, A			//channel
	MOV		ADC_RES,  #0;
	MOV		ADC_RESL, #0;

	MOV		A, ADC_CONTR		;ADC_CONTR = (ADC_CONTR & 0xe0) | ADC_START | channel; 
	ANL		A, #0xE0
	ORL		A, #ADC_START
	ORL		A, R7
	MOV		ADC_CONTR, A
	NOP
	NOP
	NOP
	NOP

	MOV		R3, #100
L_WaitAdcLoop:
	MOV		A, ADC_CONTR
	JNB		ACC.4, L_CheckAdcTimeOut

	ANL		ADC_CONTR, #NOT ADC_FLAG	;�����ɱ�־
	MOV		A, ADC_RES		;10λAD����ĸ�2λ��ADC_RES�ĵ�2λ����8λ��ADC_RESL��
	ANL		A, #3
	MOV		R6, A
	MOV		R7, ADC_RESL
	SJMP	L_QuitAdc
	
L_CheckAdcTimeOut:
	DJNZ	R3, L_WaitAdcLoop
	MOV		R6, #HIGH 1024		;��ʱ����,����1024,���õĳ����ж�
	MOV		R7, #LOW  1024
L_QuitAdc:
	RET

;====================================================================================
StringText1:
    DB  "PWM��ADC���Գ���, ����ռ�ձ�Ϊ 0~256!",0DH,0AH,0
StringText2:
	DB	"�Ѹ���ռ�ձ�!",0DH,0AH,0
StringError1:
	DB	"����! ���յ�С��0�������ַ�! ռ�ձ�Ϊ0~256!",0DH,0AH,0
StringError2:
	DB	"����! ����ռ�ձȹ���, �벻Ҫ����256!",0DH,0AH,0
StringError3:
	DB	"����! �����ַ�����! ����ռ�ձ�Ϊ0~256!",0DH,0AH,0
StringError4:
	DB	"����! ���յ�����9�������ַ�! ռ�ձ�Ϊ0~256!",0DH,0AH,0


;========================================================================
; ����: F_SendString1
; ����: ����1�����ַ���������
; ����: DPTR: �ַ����׵�ַ.
; ����: none.
; �汾: VER1.0
; ����: 2014-11-28
; ��ע: 
;========================================================================
F_SendString1:
	CLR		A
	MOVC	A, @A+DPTR		;Get current char
	JZ		L_SendEnd1		;Check the end of the string
	SETB	B_TX1_Busy		;��־����æ
	MOV		SBUF, A			;����һ���ֽ�
	JB		B_TX1_Busy, $	;�ȴ��������
	INC		DPTR 			;increment string ptr
	SJMP	F_SendString1		;Check next
L_SendEnd1:
    RET

;========================================================================
; ����: F_SetTimer2Baudraye
; ����: ����Timer2�������ʷ�������
; ����: DPTR: Timer2����װֵ.
; ����: none.
; �汾: VER1.0
; ����: 2014-11-28
; ��ע: 
;========================================================================
F_SetTimer2Baudraye:	; ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.
	ANL		AUXR, #NOT (1 SHL 4)	; Timer stop	������ʹ��Timer2����
	ANL		AUXR, #NOT (1 SHL 3)	; Timer2 set As Timer
	ORL		AUXR, #(1 SHL 2)		; Timer2 set as 1T mode
	MOV		T2H, DPH
	MOV		T2L, DPL
	ANL		IE2, #NOT (1 SHL 2)		; ��ֹ�ж�
	ORL		AUXR, #(1 SHL 4)		; Timer run enable
	RET

;========================================================================
; ����: F_UART1_config
; ����: UART1��ʼ��������
; ����: ACC: ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer1��������.
; ����: none.
; �汾: VER1.0
; ����: 2014-11-28
; ��ע: 
;========================================================================
F_UART1_config:
	CJNE	A, #2, L_Uart1NotUseTimer2
	ORL		AUXR, #0x01		; S1 BRT Use Timer2;
	MOV		DPTR, #UART1_Baudrate
	LCALL	F_SetTimer2Baudraye
	SJMP	L_SetupUart1

L_Uart1NotUseTimer2:
	CLR		TR1					; Timer Stop	������ʹ��Timer1����
	ANL		AUXR, #NOT 0x01		; S1 BRT Use Timer1;
	ORL		AUXR, #(1 SHL 6)	; Timer1 set as 1T mode
	ANL		TMOD, #NOT (1 SHL 6); Timer1 set As Timer
	ANL		TMOD, #NOT 0x30		; Timer1_16bitAutoReload;
	MOV		TH1, #HIGH UART1_Baudrate
	MOV		TL1, #LOW  UART1_Baudrate
	CLR		ET1					; ��ֹ�ж�
	ANL		INT_CLKO, #NOT 0x02	; �����ʱ��
	SETB	TR1

L_SetupUart1:
	SETB	REN		; �������
	SETB	ES		; �����ж�

	ANL		SCON, #0x3f
	ORL		SCON, #0x40		; UART1ģʽ, 0x00: ͬ����λ���, 0x40: 8λ����,�ɱ䲨����, 0x80: 9λ����,�̶�������, 0xc0: 9λ����,�ɱ䲨����
;	SETB	PS		; �����ȼ��ж�
	SETB	REN		; �������
	SETB	ES		; �����ж�

	ANL		P_SW1, #0x3f
	ORL		P_SW1, #0x80		; UART1 switch to, 0x00: P3.0 P3.1, 0x40: P3.6 P3.7, 0x80: P1.6 P1.7 (����ʹ���ڲ�ʱ��)
;	ORL		PCON2, #(1 SHL 4)	; �ڲ���·RXD��TXD, ���м�, ENABLE,DISABLE

	CLR		B_TX1_Busy
	MOV		RX1_Cnt, #0;
	MOV		TX1_Cnt, #0;
	RET


;========================================================================
; ����: F_UART1_Interrupt
; ����: UART2�жϺ�����
; ����: nine.
; ����: none.
; �汾: VER1.0
; ����: 2014-11-28
; ��ע: 
;========================================================================
F_UART1_Interrupt:
	PUSH	PSW
	PUSH	ACC
	PUSH	AR0
	
	JNB		RI, L_QuitUartRx
	CLR		RI
	JB		B_RX1_OK, L_QuitUartRx
	MOV		A, RX1_Cnt
	CJNE	A, #RX1_Lenth, L_RxCntNotOver
	MOV		RX1_Cnt, #0		; �����������
L_RxCntNotOver:
	MOV		A, #RX1_Buffer
	ADD		A, RX1_Cnt
	MOV		R0, A
	MOV		@R0, SBUF	;����һ���ֽ�
	INC		RX1_Cnt
	MOV		RX1_TimeOut, #5
L_QuitUartRx:

	JNB		TI, L_QuitUartTx
	CLR		TI
	CLR		B_TX1_Busy		; �������æ��־
L_QuitUartTx:

	POP		AR0
	POP		ACC
	POP		PSW
	RETI


; *********************** ��ʾ��س��� ****************************************
T_Display:						;��׼�ֿ�
;	 0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F
DB	03FH,006H,05BH,04FH,066H,06DH,07DH,007H,07FH,06FH,077H,07CH,039H,05EH,079H,071H
;  black  -    H    J    K	  L	   N	o    P	  U    t    G    Q    r    M    y
DB	000H,040H,076H,01EH,070H,038H,037H,05CH,073H,03EH,078H,03dH,067H,050H,037H,06EH
;    0.   1.   2.   3.   4.   5.   6.   7.   8.   9.   -1
DB	0BFH,086H,0DBH,0CFH,0E6H,0EDH,0FDH,087H,0FFH,0EFH,046H

T_COM:
DB	001H,002H,004H,008H,010H,020H,040H,080H		;	λ��


;//========================================================================
;// ����: F_Send_595
;// ����: ��HC595����һ���ֽ��ӳ���
;// ����: ACC: Ҫ���͵��ֽ�����.
;// ����: none.
;// �汾: VER1.0
;// ����: 2013-4-1
;// ��ע: ����ACCC��PSW��, ���õ���ͨ�üĴ�������ջ
;//========================================================================
F_Send_595:
	PUSH	02H		;R2��ջ
	MOV		R2, #8
L_Send_595_Loop:
	RLC		A
	MOV		P_HC595_SER,C
	SETB	P_HC595_SRCLK
	CLR		P_HC595_SRCLK
	DJNZ	R2, L_Send_595_Loop
	POP		02H		;R2��ջ
	RET

;//========================================================================
;// ����: F_DisplayScan
;// ����: ��ʾɨ���ӳ���
;// ����: none.
;// ����: none.
;// �汾: VER1.0
;// ����: 2013-4-1
;// ��ע: ����ACCC��PSW��, ���õ���ͨ�üĴ�������ջ
;//========================================================================
F_DisplayScan:
	PUSH	DPH		;DPH��ջ
	PUSH	DPL		;DPL��ջ
	PUSH	00H		;R0 ��ջ
	
	MOV		DPTR, #T_COM
	MOV		A, display_index
	MOVC	A, @A+DPTR
	XRL		A, #NOT LED_TYPE
	LCALL	F_Send_595		;���λ��
	
	MOV		DPTR, #T_Display
	MOV		A, display_index
	ADD		A, #LED8
	MOV		R0, A
	MOV		A, @R0
	MOVC	A, @A+DPTR
	XRL		A, #LED_TYPE
	LCALL	F_Send_595		;�������

	SETB	P_HC595_RCLK
	CLR		P_HC595_RCLK	;	�����������
	INC		display_index
	MOV		A, display_index
	ANL		A, #0F8H			; if(display_index >= 8)
	JZ		L_QuitDisplayScan
	MOV		display_index, #0;	;8λ������0
L_QuitDisplayScan:
	POP		00H		;R0 ��ջ
	POP		DPL		;DPL��ջ
	POP		DPH		;DPH��ջ
	RET


;*******************************************************************
;**************** �жϺ��� ***************************************************

F_Timer0_Interrupt:	;Timer0 1ms�жϺ���
	PUSH	PSW		;PSW��ջ
	PUSH	ACC		;ACC��ջ

	LCALL	F_DisplayScan	; 1msɨ����ʾһλ
	SETB	B_1ms			; 1ms��־
	

	POP		ACC		;ACC��ջ
	POP		PSW		;PSW��ջ
	RETI

	END



