;/*---------------------------------------------------------------------*/
;/* --- STC MCU International Limited ----------------------------------*/
;/* --- STC 1T Series MCU Demo Programme -------------------------------*/
;/* --- Mobile: (86)13922805190 ----------------------------------------*/
;/* --- Fax: 86-0513-55012956,55012947,55012969 ------------------------*/
;/* --- Tel: 86-0513-55012928,55012929,55012966 ------------------------*/
;/* --- Web: www.GXWMCU.com --------------------------------------------*/
;/* --- QQ:  800003751 -------------------------------------------------*/
;/* ���Ҫ�ڳ�����ʹ�ô˴���,���ڳ�����ע��ʹ���˺꾧�Ƽ������ϼ�����   */
;/*---------------------------------------------------------------------*/


;*************	����˵��	**************

;��STC��MCU��IO��ʽ����74HC595����8λ����ܡ�

;��ʾЧ��Ϊ: ����ʱ��.

;ʹ��Timer0��16λ�Զ���װ������1ms����,�������������������, �û��޸�MCU��ʱ��Ƶ��ʱ,�Զ���ʱ��1ms.

;���4λLED��ʾʱ��(Сʱ,����), �ұ������λ��ʾ����ֵ.

;ADC��������Ϊ1~16.

;����ֻ֧�ֵ�������, ��֧�ֶ��ͬʱ����, ���������в���Ԥ֪�Ľ��.

;�����³���1���,����10��/����ٶ��ṩ�ؼ����. �û�ֻ��Ҫ���KeyCode�Ƿ��0���жϼ��Ƿ���.

;����ʱ���:
;����1: Сʱ+.
;����2: Сʱ-.
;����3: ����+.
;����4: ����-.


;******************************************/

;/****************************** �û������ ***********************************/

Fosc_KHZ	EQU	22118	;22118KHZ

STACK_POIRTER	EQU		0D0H	;��ջ��ʼ��ַ

Timer0_Reload	EQU		(65536 - Fosc_KHZ)	; Timer 0 �ж�Ƶ��, 1000��/��

DIS_DOT			EQU		020H
DIS_BLACK		EQU		010H
DIS_			EQU		011H

;*******************************************************************
;*******************************************************************

AUXR      DATA 08EH
P4        DATA 0C0H
P5        DATA 0C8H
ADC_CONTR DATA 0BCH	;��ADϵ��
ADC_RES   DATA 0BDH	;��ADϵ��
ADC_RESL  DATA 0BEH	;��ADϵ��
P1ASF     DATA 09DH
PCON2     DATA 097H

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
Flag0			DATA	20H
B_1ms			BIT		Flag0.0	;	1ms��־

LED8			DATA	30H		;	��ʾ���� 30H ~ 37H
display_index	DATA	38H		;	��ʾλ����

hour			DATA	39H		;RTC����
minute			DATA	3AH
second			DATA	3BH		;
msecond_H		DATA	3CH		;
msecond_L		DATA	3DH		;

ADC_KeyState	DATA	3EH	; ADC��״̬����
ADC_KeyState1	DATA	3FH
ADC_KeyState2	DATA	40H
ADC_KeyState3	DATA	41H
ADC_KeyHoldCnt	DATA	42H	; ADC�����¼�ʱ

KeyCode			DATA	43H	; ���û�ʹ�õļ���, 1~16ΪADC���� 17~32ΪIO��

cnt10ms			DATA	44H;
cnt50ms			DATA	45H;



;*******************************************************************
;*******************************************************************
		ORG		0000H				;reset
		LJMP	F_Main


		ORG		000BH				;1  Timer0 interrupt
		LJMP	F_Timer0_Interrupt

;*******************************************************************
;*******************************************************************




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
	MOV		PSW, #0		;ѡ���0��R0~R7
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
	
	MOV		hour,   #12	; ��ʼ��ʱ��ֵ
	MOV		minute, #0
	MOV		second, #0
	LCALL	F_DisplayRTC
	
	MOV		cnt10ms, #10

	CLR		A
	MOV		ADC_KeyState, A
	MOV		ADC_KeyState1, A
	MOV		ADC_KeyState2, A
	MOV		ADC_KeyState3, A	; ��״̬
	MOV		ADC_KeyHoldCnt, A	; �����¼�ʱ
	MOV		KeyCode, A		; ���û�ʹ�õļ���, 1~16��Ч

	MOV		P1ASF, #010H		; ����P1.4ΪADC
	MOV		ADC_CONTR, #0E0H	;��ADC, �����ٶ�90T
	ORL		PCON2, #020H		;10λAD����ĸ�2λ��ADC_RES�ĵ�2λ����8λ��ADC_RESL��

;=====================================================

;=====================================================
L_Main_Loop:
	JNB		B_1ms,  L_Main_Loop		;1msδ��
	CLR		B_1ms
	
;=================== ���1000ms�Ƿ� ==================================
	INC		msecond_L		;msecond + 1
	MOV		A, msecond_L
	JNZ		L_Check1000ms
	INC		msecond_H
L_Check1000ms:
	CLR		C
	MOV		A, msecond_L	;msecond - 1000
	SUBB	A, #LOW 1000
	MOV		A, msecond_H
	SUBB	A, #HIGH 1000
	JC		L_Quit_Check_1000ms		;if(msecond < 1000), jmp
	
;================= 1000ms���� ����ģ���RTC ====================================
	MOV		msecond_L, #0	;if(msecond >= 1000)
	MOV		msecond_H, #0

	LCALL	F_RTC
	LCALL	F_DisplayRTC
L_Quit_Check_1000ms:

	MOV		A, msecond_L			;���if(msecond == 500)
	CJNE	A, #LOW 500, L_Quit_Display_Dot
	MOV		A, msecond_H
	CJNE	A, #HIGH 500, L_Quit_Display_Dot
	LCALL	F_DisplayRTC	;Сʱ���С����������
L_Quit_Display_Dot:
;=====================================================

;==================== 10ms��һ��ADC =================================
L_Read_ADC_Key:
	DJNZ	cnt10ms, L_Quit_Read_ADC_Key	; (cnt10ms - 1) != 0, jmp
	MOV		cnt10ms, #10	;
	
	MOV		A, #4
	LCALL	F_Get_ADC10bitResult	;ACC - ͨ��0~7, ��ѯ��ʽ��һ��ADC, ����ֵ(R6 R7)����ADC���, == 1024 Ϊ����
	MOV		A, R6
	ANL		A, #0FCH
	JNZ		L_Quit_Read_ADC_Key		; adc >= 1024, ����
	LCALL	F_CalculateAdcKey		; ���㰴��, (R6 R7) == adc, ����ֵ��R4 R5.

L_Quit_Read_ADC_Key:
;=====================================================

;=====================================================
L_KeyProcess:
	MOV		A, KeyCode
	JZ		L_Quit_KeyProcess
							;�м�����
	MOV		A, KeyCode
	MOV		B, #10
	DIV		AB
	MOV		LED8+6, A		; ��ʾ����
	MOV		LED8+7, B

	MOV		A, KeyCode
	CJNE	A, #1, L_Quit_K1
	INC		hour	; hour + 1
	MOV		A, hour
	CLR		C
	SUBB	A, #24
	JC		L_K1_Display
	MOV		hour, #0
L_K1_Display:
	LCALL	F_DisplayRTC
L_Quit_K1:

	MOV		A, KeyCode
	CJNE	A, #2, L_Quit_K2
	DEC		hour	; hour - 1
	MOV		A, hour
	CJNE	A, #255, L_K2_Display
	MOV		hour, #23
L_K2_Display:
	LCALL	F_DisplayRTC
L_Quit_K2:

	MOV		A, KeyCode
	CJNE	A, #3, L_Quit_K3
	MOV		second, #0		;��������ʱ�����
	INC		minute	; minute + 1
	MOV		A, minute
	CLR		C
	SUBB	A, #60
	JC		L_K3_Display
	MOV		minute, #0
L_K3_Display:
	LCALL	F_DisplayRTC
L_Quit_K3:

	MOV		A, KeyCode
	CJNE	A, #4, L_Quit_K4
	MOV		second, #0		;��������ʱ�����
	DEC		minute	; minute - 1
	MOV		A, minute
	CJNE	A, #255, L_K4_Display
	MOV		minute, #59
L_K4_Display:
	LCALL	F_DisplayRTC
L_Quit_K4:

	MOV		KeyCode, #0
L_Quit_KeyProcess:

	LJMP	L_Main_Loop

;**********************************************/


;========================================================================
; ����: F_DisplayRTC
; ����: ��ʾʱ���ӳ���
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
; ��ע: ����ACCC��PSW��, ���õ���ͨ�üĴ�������ջ
;========================================================================
F_DisplayRTC:
	PUSH	B		;B��ջ
	
	MOV		A, hour
	MOV		B, #10
	DIV		AB
	MOV		LED8, A
	MOV		LED8+1, B
	
	MOV		A, minute
	MOV		B, #10
	DIV		AB
	MOV		LED8+2, A;
	MOV		LED8+3, B;

	MOV		A, msecond_L	;msecond - 500
	CLR		C
	SUBB	A, #LOW 500
	MOV		A, msecond_H
	SUBB	A, #HIGH 500
	JC		L_QuitDisplayRTC	;if(msecond < 500), jmp
	ORL		LED8+1, #DIS_DOT	; Сʱ���С����������
L_QuitDisplayRTC:
	POP		B		;B��ջ
	RET

;========================================================================
; ����: F_RTC
; ����: RTC��ʾ�ӳ���
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
; ��ע: ����ACCC��PSW��, ���õ���ͨ�üĴ�������ջ
;========================================================================
F_RTC:
	INC		second		; second + 1
	MOV		A, second
	CLR		C
	SUBB	A,#60
	JC		L_QuitRTC	; second >= 60?
	MOV		second, #0;

	INC		minute		; minute + 1
	MOV		A, minute
	CLR		C
	SUBB	A,#60
	JC		L_QuitRTC	; minute >= 60?
	MOV		minute, #0

	INC		hour		; hour + 1
	MOV		A, hour
	CLR		C
	SUBB	A,#24
	JC		L_QuitRTC	; hour >= 24?
	MOV		hour, #0
L_QuitRTC:
	RET



;========================================================================
; ����: F_Get_ADC10bitResult
; ����: ��ѯ����һ��ADC���.
; ����: ACC: ѡ��Ҫת����ADC.
; ����: (R6 R7) = 10λADC���.
; �汾: V1.0, 2013-10-22
;========================================================================
F_Get_ADC10bitResult:	;ACC - ͨ��0~7, ��ѯ��ʽ��һ��ADC, ����ֵ(R6 R7)����ADC���, == 1024 Ϊ����
	MOV		R7, A			//channel
	MOV		ADC_RES,  #0;
	MOV		ADC_RESL, #0;

	MOV		A, ADC_CONTR		;ADC_CONTR = (ADC_CONTR & 0xe0) | ADC_START | channel; 
	ANL		A, #0xE0
	ORL		A, #08H
	ORL		A, R7
	MOV		ADC_CONTR, A
	NOP
	NOP
	NOP
	NOP

L_WaitAdcLoop:
	MOV		A, ADC_CONTR
	JNB		ACC.4, L_WaitAdcLoop

	ANL		ADC_CONTR, #NOT 010H	;�����ɱ�־

	MOV		A, ADC_RES		;10λAD����ĸ�2λ��ADC_RES�ĵ�2λ����8λ��ADC_RESL��
	ANL		A, #3
	MOV		R6, A
	MOV		R7, ADC_RESL

L_QuitAdc:
	RET


;/***************** ADC���̼������ *****************************
;��·������㷨���: Coody
;��ADC���̷����ںܶ�ʵ�ʲ�Ʒ�����, ��֤�����ȶ��ɿ�, ��ʹ����ʹ�õ���Ĥ,���ܿɿ�.
;16����,�����ϸ�������Ӧ��ADCֵΪ (1024 / 16) * k = 64 * k, k = 1 ~ 16, �ر��, k=16ʱ,��Ӧ��ADCֵ��1023.
;����ʵ�ʻ���ƫ��,���ж�ʱ�������ƫ��, ADC_OFFSETΪ+-ƫ��, ��ADCֵ�� (64*k-ADC_OFFSET) �� (64*k+ADC_OFFSET)֮��Ϊ����Ч.
;���һ����ʱ��,�Ͳ���һ��ADC,����10ms.
;Ϊ�˱���żȻ��ADCֵ����, ���߱���ADC���������½�ʱ����, ʹ������3��ADCֵ����ƫ�Χ��ʱ, ADCֵ����Ϊ��Ч.
;�����㷨, �ܱ�֤�����ǳ��ɿ�.
;**********************************************/
ADC_OFFSET	EQU	16		;����С��30
F_CalculateAdcKey:		//R6 R7Ϊ�����ADCֵ (u16 adc),	10ms call
	PUSH	03H		;R3��ջ
	PUSH	04H		;R4��ջ
	PUSH	05H		;R5��ջ
	PUSH	DPH		;DPH��ջ
	PUSH	DPL		;DPL��ջ
	
	CLR		C			;����(adc - (64-ADC_OFFSET)
	MOV		A, R7
	SUBB	A, #(64 - ADC_OFFSET)
	MOV		A, R6
	SUBB	A, #0
	JNC		L_ADC_MoreThanOffset
	MOV		ADC_KeyState, #0	;	if(adc < (64-ADC_OFFSET)), ��״̬��0
	MOV		ADC_KeyHoldCnt, #0	;
	
L_ADC_MoreThanOffset:

	MOV		R4, #0		;j = 64 - ADC_OFFSET;
	MOV		R5, #(64 - ADC_OFFSET)
	MOV		DPH, #0		;k = 64 + ADC_OFFSET;
	MOV		DPL, #(64 + ADC_OFFSET)
	MOV		R3, #1
L_CheckAdcKeyLoop1:
	CLR		C		; adc - j
	MOV		A, R7
	SUBB	A, R5
	MOV		A, R6
	SUBB	A, R4
	JC		L_CheckNextAdcKey		; adc < j

	CLR		C		; adc - k
	MOV		A, R7
	SUBB	A, DPL
	MOV		A, R6
	SUBB	A, DPH
	JNC		L_CheckNextAdcKey		; adc > k
	SJMP	L_CheckAdcKeyEnd	;if((adc >= j) && (adc <= k)),  �ж��Ƿ���ƫ�Χ��

L_CheckNextAdcKey:
	MOV		A, R5		; j = j + 64
	ADD		A, #64
	MOV		R5, A
	MOV		A, R4
	ADDC	A, #0
	MOV		R4, A

	MOV		A, DPL		; k = k + 64
	ADD		A, #64
	MOV		DPL, A
	MOV		A, DPH
	ADDC	A, #0
	MOV		DPH, A
	
	INC		R3
	MOV		A, R3
	CJNE	A, #17, L_CheckAdcKeyLoop1

L_CheckAdcKeyEnd:
	MOV		ADC_KeyState3, ADC_KeyState2
	MOV		ADC_KeyState2, ADC_KeyState1
	MOV		A, R3
	CLR		C
	SUBB	A, #17
	JC		L_AdcKeyIsOk
	MOV		ADC_KeyState1, #0	;if(i > 16)	KeyState1 = 0;	//����Ч
	LJMP	L_QuitCheckAdcKey

L_AdcKeyIsOk:		;����Ч
	MOV		ADC_KeyState1, R3
	MOV		A, ADC_KeyState3
	CJNE	A, ADC_KeyState2, L_QuitCheckAdcKey		;if (KeyState3 != KeyState2)
	CJNE	A, ADC_KeyState1, L_QuitCheckAdcKey 	;if (KeyState3 != KeyState1)
	JZ		L_QuitCheckAdcKey 					;if (KeyState3 == 0)

	MOV		A, ADC_KeyState
	JNZ		L_NotFirstCheck	;���ǵ�һ�μ�⵽, jmp
	MOV		KeyCode,  R3	; �������
	MOV		ADC_KeyState, R3	; �����״̬
	MOV		ADC_KeyHoldCnt, #0	; ��������ŵ�ʱ�����
L_NotFirstCheck:

	MOV		A, ADC_KeyState
	XRL		A, R3
	JNZ		L_NotCheckAdcKeySame
				;if(KeyState == i)	//������⵽ͬһ������
	INC		ADC_KeyHoldCnt
	MOV		A, ADC_KeyHoldCnt
	CJNE	A, #100, L_QuitCheckAdcKey	;if(++KeyHoldCnt >= 100)	//����1���,��10��ÿ����ٶ�Repeat Key
	MOV		ADC_KeyHoldCnt, #90		;����1���,��10��ÿ����ٶ�Repeat Key
	MOV		KeyCode, R3			; �������
	SJMP	L_QuitCheckAdcKey
L_NotCheckAdcKeySame:
	MOV		ADC_KeyHoldCnt, #0	;	����ʱ�������0

L_QuitCheckAdcKey:
	POP		DPL		;DPL��ջ
	POP		DPH		;DPH��ջ
	POP		05H		;R5��ջ
	POP		04H		;R4��ջ
	POP		03H		;R3��ջ
	RET
	


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
	CPL		A
	LCALL	F_Send_595		;���λ��
	
	MOV		DPTR, #T_Display
	MOV		A, display_index
	ADD		A, #LED8
	MOV		R0, A
	MOV		A, @R0
	MOVC	A, @A+DPTR
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



