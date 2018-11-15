
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

;��ADC�����ⲿ��ѹ��ʹ���ⲿ��׼�����ѹ.

;��STC��MCU��IO��ʽ����74HC595����8λ����ܡ�

;�û������޸ĺ���ѡ��ʱ��Ƶ��.

;�û�������"�û������"��ѡ��������. �Ƽ�����ʹ�ù��������.

;ʹ��Timer0��16λ�Զ���װ������1ms����,�������������������, �û��޸�MCU��ʱ��Ƶ��ʱ,�Զ���ʱ��1ms.

;�ұ�4λ�������ʾ�����ĵ�ѹֵֵ.

;�ⲿ��ѹ�Ӱ��ϲ��µ�����������, �����ѹ0~VDD, ��Ҫ����VDD�����0V. 

;ʵ����Ŀʹ���봮һ��1K�ĵ��赽ADC�����, ADC������ٲ�һ�����ݵ���.


;******************************************/

;/****************************** �û������ ***********************************/

Fosc_KHZ	EQU	22118	;22118KHZ

STACK_POIRTER	EQU		0D0H	;��ջ��ʼ��ַ

LED_TYPE		EQU		000H	; ����LED����, 000H -- ����, 0FFH -- ����

Timer0_Reload	EQU		(65536 - Fosc_KHZ)	; Timer 0 �ж�Ƶ��, 1000��/��

DIS_DOT			EQU		020H
DIS_BLACK		EQU		010H
DIS_			EQU		011H

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


;*******************************************************************
AUXR		DATA 08EH
P4			DATA 0C0H
P5			DATA 0C8H
ADC_CONTR	DATA 0BCH	;��ADϵ��
ADC_RES		DATA 0BDH	;��ADϵ��
ADC_RESL	DATA 0BEH	;��ADϵ��
P1ASF		DATA 09DH
PCON2		DATA 097H

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

msecond_H		DATA	39H		;
msecond_L		DATA	3AH		;
BandgapH 		DATA	3BH		;
BandgapL 		DATA	3CH		;
ADC3_H			DATA	3DH		;
ADC3_L			DATA	3EH		;



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

;=====================================================

;=====================================================
L_Main_Loop:
	JNB		B_1ms,  L_Main_Loop		;1msδ��
	CLR		B_1ms
	
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
	JC		L_Main_Loop		;if(msecond < 300), jmp
	
;================= 300ms�� ====================================
	MOV		msecond_L, #0	;if(msecond >= 1000)
	MOV		msecond_H, #0

	MOV		A, #ADC_CH2
	LCALL	F_Get_ADC10bitResult	;���ⲿ��׼ADC, ��ѯ��ʽ��һ��ADC, ����ֵ(R6 R7)����ADC���, == 1024 Ϊ����
	MOV		BandgapH, R6			;����Bandgap
	MOV		BandgapL, R7
	
	MOV		A, #ADC_CH3
	LCALL	F_Get_ADC10bitResult	; ���ⲿ��ѹADC, ��ѯ��ʽ��һ��ADC, ����ֵ(R6 R7)����ADC���, == 1024 Ϊ����
	MOV		ADC3_H, R6				;����adc
	MOV		ADC3_L, R7
	
	MOV		R4, ADC3_H		; adc * 123 / Bandgap, �����ⲿ��ѹ, BandgapΪ1.23V, ���ѹ�ֱ���0.01V
	MOV		R5, ADC3_L
	MOV		R7, #250		; TL431Ϊ2.50V, �������, �Ŵ�100��
	LCALL	F_MUL16x8		;(R4,R5)* R7 -->(R5,R6,R7)
	MOV		R4, #0
	MOV		R2, BandgapH
	MOV		R3, BandgapL
	LCALL	F_ULDIV			; (R4,R5,R6,R7)/(R2,R3)=(R4,R5,R6,R7),������(R2,R3),use R0~R7,B,DPL

	LCALL	F_HEX2_DEC		;(R6 R7) HEX Change to DEC ---> (R3 R4 R5), use (R2~R7)
	MOV		LED8+4, #DIS_BLACK
	MOV		A, R4
	ANL		A, #0x0F
	ADD		A, #DIS_DOT		;;��ʾ��ѹֵ, С����
	MOV		LED8+5, A
	MOV		A, R5
	SWAP	A
	ANL		A, #0x0F
	MOV		LED8+6, A
	MOV		A, R5
	ANL		A, #0x0F
	MOV		LED8+7, A

L_Quit_Check_300ms:

;=====================================================


	LJMP	L_Main_Loop

;**********************************************/

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
	ORL		P1M1,#(ADC_P12 + ADC_P13)		; P1.2 P1.3���óɸ���
	ANL		P1M0,#NOT (ADC_P12 + ADC_P13)
	MOV		P1ASF, #(ADC_P12 + ADC_P13)		; ����Ҫ��ADC��IO,	ADC_P10 ~ ADC_P17(�����),ADC_P1_All
	MOV		ADC_CONTR, #(ADC_PowerOn + ADC_90T)	;��ADC, �����ٶ�
	ORL		PCON2, #ADC_RES_H2L8		;10λAD����ĸ�2λ��ADC_RES�ĵ�2λ����8λ��ADC_RESL��
	ORL		P1M1, #(ADC_P12 + ADC_P13)	; ��ADC������Ϊ��������
	ANL		P1M0, #NOT (ADC_P12 + ADC_P13)
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



;***************************************************************************
F_ULDIV:
F_DIV32:							; (R4,R5,R6,R7)/(R2,R3)=(R4,R5,R6,R7),������(R2,R3),use R0~R7,B,DPL
		CJNE	R2,#0,F_DIV32_16	; L_0075
		
F_DIV32_8:							;R3��0��(R4,R5,R6,R7)/R3=(R4,R5,R6,R7),������ R3,use R0~R7,B
		MOV		A,R4
		MOV		B,R3
		DIV		AB
		XCH		A,R7
		XCH		A,R6
		XCH		A,R5
		MOV		R4,A
		MOV		A,B
		XCH		A,R3
		MOV		R1,A
		MOV		R0,#24
L_0056:
		MOV		A,R7
		ADD		A,R7
		MOV		R7,A
		MOV		A,R6
		RLC		A
		MOV		R6,A
		MOV		A,R5
		RLC		A
		MOV		R5,A
		MOV		A,R4
		RLC		A
		MOV		R4,A
		MOV		A,R3
		RLC		A
		MOV		R3,A
		JBC		CY,L_006B
		SUBB	A,R1
		JC		L_006F
L_006B:
		MOV		A,R3
		SUBB	A,R1
		MOV		R3,A
		INC		R7
L_006F:
		DJNZ	R0,L_0056
		CLR		A
		MOV		R1,A
		MOV		R2,A
		RET
		

;***************************************************************************
F_DIV32_16:						;R2��0��(R4,R5,R6,R7)/(R2,R3)=(R5,R6,R7),������ (R2,R3),use R0~R7
L_0075:
		MOV		R0,#24			;��ʼR1=0
L_0077:
		MOV		A,R7			;����һλ
		ADD		A,R7
		MOV		R7,A
		MOV		A,R6
		RLC		A
		MOV		R6,A
		MOV		A,R5
		RLC		A
		MOV		R5,A
		MOV		A,R4
		RLC		A
		MOV		R4,A
		XCH		A,R1
		RLC		A
		XCH		A,R1
		JBC		CY,L_008E	;���C=1���϶�����
		SUBB	A,R3
		MOV		A,R1		;�����Ƿ񹻼�
		SUBB	A,R2
		JC		L_0095
L_008E:
		MOV		A,R4
		SUBB	A,R3
		MOV		R4,A
		MOV		A,R1
		SUBB	A,R2
		MOV		R1,A
		INC		R7
L_0095:
		DJNZ	R0,L_0077
		CLR		A
		XCH		A,R1
		MOV		R2,A
		CLR		A
		XCH		A,R4
		MOV		R3,A
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


		END

