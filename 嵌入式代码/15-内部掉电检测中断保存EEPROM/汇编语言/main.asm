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

;�û������޸ĺ���ѡ��ʱ��Ƶ��.

;�û�������"�û������"��ѡ��������. �Ƽ�����ʹ�ù��������.

;ʹ��Timer0��16λ�Զ���װ������1ms����,�������������������, �û��޸�MCU��ʱ��Ƶ��ʱ,�Զ���ʱ��1ms.

;������ʹ��5V�汾��IAP15F2K61S2��STC15F2KxxS2���û�������"�û������"�а������MCU�޸ĵ��籣���EEPROM��ַ��

;��ʾЧ��Ϊ: �ϵ����ʾ�����, ������ΧΪ0~10000����ʾ���ұߵ�5�������.

;�������MCU�����ѹ�жϣ�����������б��档MCU�ϵ�ʱ���������������ʾ��

;�û�������"�û������"��ѡ���˲����ݴ���С��
;��ĵ���(����1000uF)�������󱣳ֵ�ʱ�䳤�������ڵ�ѹ�ж��в�����(��Ҫ20��msʱ��)Ȼ��д�롣
;С�ĵ��ݣ������󱣳ֵ�ʱ���, ��������������ʼ��ʱ�Ȳ���.

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;ע�⣺����ʱ�����ؽ���"Ӳ��ѡ��"���������Ҫ�̶���������:

;����ѡ	�����ѹ��λ(��ֹ��ѹ�ж�)

;		��ѹ����ѹ 4.64V

;����ѡ	��ѹʱ��ֹEEPROM����.
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


;******************************************

;/****************************** �û������ ***********************************/

Fosc_KHZ	EQU	22118	;22118KHZ

STACK_POIRTER	EQU		0D0H	; ��ջ��ʼ��ַ

LargeCapacitor	EQU		0		; 0: �˲����ݱȽ�С,  1: �˲����ݱȽϴ�

LED_TYPE		EQU		000H	; ����LED����, 000H -- ����, 0FFH -- ����

Timer0_Reload	EQU		(65536 - Fosc_KHZ)	; Timer 0 �ж�Ƶ��, 1000��/��

EE_ADDRESS		EQU		08000H	;����ĵ�ַ

DIS_DOT			EQU		020H
DIS_BLACK		EQU		010H
DIS_			EQU		011H

;*******************************************************************
;*******************************************************************

ISP_EN			EQU		(1 SHL 7)
ISP_SWBS		EQU		(1 SHL 6)
ISP_SWRST		EQU		(1 SHL 5)
;ISP_WAIT_FREQUENCY	EQU	 7	 ;ISP_WAIT_1MHZ	
;ISP_WAIT_FREQUENCY	EQU	 6	 ;ISP_WAIT_2MHZ	
;ISP_WAIT_FREQUENCY	EQU	 5	 ;ISP_WAIT_3MHZ	
;ISP_WAIT_FREQUENCY	EQU	 4	 ;ISP_WAIT_6MHZ	
;ISP_WAIT_FREQUENCY	EQU	 3	 ;ISP_WAIT_12MHZ
;ISP_WAIT_FREQUENCY	EQU	 2	 ;ISP_WAIT_20MHZ
ISP_WAIT_FREQUENCY	EQU	 1	 ;ISP_WAIT_24MHZ
;ISP_WAIT_FREQUENCY	EQU	 0	 ;ISP_WAIT_30MHZ

AUXR      DATA 08EH
P4        DATA 0C0H
P5        DATA 0C8H
ISP_DATA  DATA 0C2H
ISP_ADDRH DATA 0C3H
ISP_ADDRL DATA 0C4H
ISP_CMD   DATA 0C5H
ISP_TRIG  DATA 0C6H
ISP_CONTR DATA 0C7H

ELVD 	BIT IE.6	; ��ѹ����ж�����λ
PLVD 	BIT IP.6	; ��ѹ�ж� ���ȼ��趨λ

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

Test_cnt_H		DATA	3BH		; �����õ����������
Test_cnt_L		DATA	3CH

address_H		DATA	3DH
address_L		DATA	3EH
length			DATA	3FH

;*******************************************************************
;*******************************************************************
		ORG		0000H				;reset
		LJMP	F_Main

		ORG		000BH				;1  Timer0 interrupt
		LJMP	F_Timer0_Interrupt

		ORG		0033H				;6  Low Voltage Detect interrupt
		LJMP	F_LVD_Interrupt



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
	
	MOV		R2, #200	; delay 200ms
L_PowerUpDelay:
	JNB		B_1ms, $	; �ȴ�1ms��
	CLR		B_1ms
	DJNZ	R2, L_PowerUpDelay

	MOV		address_H, #HIGH EE_ADDRESS
	MOV		address_L, #LOW  EE_ADDRESS
	MOV		length, #2		;����2�ֽ�
	MOV		R0, #Test_cnt_H
	LCALL	F_EEPROM_read_n		;��N���ֽ�	;address_H,address_L,R0,length
	MOV		A, Test_cnt_L
	CLR		C
	SUBB	A, #LOW 10000
	MOV		A, Test_cnt_H
	SUBB	A, #HIGH 10000
	JC		L_LessThan10000
	MOV		Test_cnt_H, #0
	MOV		Test_cnt_L, #0
L_LessThan10000:

IF	(LargeCapacitor == 0)	;�˲����ݱȽ�С�����ݱ���ʱ��Ƚ϶̣����Ȳ���
	LCALL	F_EEPROM_SectorErase	; ����һ������
ENDIF
	
	LCALL	F_Display		; ��ʾ�����
	
	ANL		PCON, #NOT (1 SHL 5)	; ��ѹ����־��0
	SETB	ELVD		; ��ѹ����ж�����
	SETB	PLVD		; ��ѹ�ж� ���ȼ���
	

;=================== ��ѭ�� ==================================
L_MainLoop:
	JNB		B_1ms,  L_MainLoop		;1msδ��
	CLR		B_1ms
	
	INC		msecond_L		;msecond + 1
	MOV		A, msecond_L
	JNZ		$+4
	INC		msecond_H
	
	MOV		A, msecond_L	;msecond - 1000
	CLR		C
	SUBB	A, #LOW 1000
	MOV		A, msecond_H
	SUBB	A, #HIGH 1000
	JC		L_MainLoop		;if(msecond < 1000), jmp
	
	MOV		msecond_L, #0	;if(msecond >= 1000)
	MOV		msecond_H, #0

	INC		Test_cnt_L		;Test_cnt + 1
	MOV		A, Test_cnt_L
	JNZ		$+4
	INC		Test_cnt_H

	MOV		A, Test_cnt_L	;if(Test_cnt > 10000)	Test_cnt = 0;	�������ΧΪ0~10000
	CLR		C
	SUBB	A, #LOW 10000
	MOV		A, Test_cnt_H
	SUBB	A, #HIGH 10000
	JC		L_LessThan10000A
	MOV		Test_cnt_H, #0
	MOV		Test_cnt_L, #0
L_LessThan10000A:
	LCALL	F_Display		; ��ʾ�����

	LJMP	L_MainLoop

;**********************************************/


;========================================================================
; ����: F_LVD_Interrupt
; ����: ��ѹ�жϺ���.
; ����: non.
; ����: non.
; �汾: V1.0, 2014-1-22
;========================================================================
F_LVD_Interrupt:
	PUSH	PSW
	PUSH	ACC
	PUSH	AR2

	CLR		P_HC595_SER		; �ȹر���ʾ��ʡ��
	MOV		R2, #16
L_LVD_ClearDisplay:
	SETB	P_HC595_SRCLK
	CLR		P_HC595_SRCLK
	DJNZ	R2, L_LVD_ClearDisplay
	SETB	P_HC595_RCLK
	CLR		P_HC595_RCLK		;�����������
	
	MOV		address_H, #HIGH EE_ADDRESS
	MOV		address_L, #LOW  EE_ADDRESS
IF	(LargeCapacitor == 1)	;�˲����ݱȽϴ󣬵��ݱ���ʱ��Ƚϳ�(50ms����)�������ж������
	LCALL	F_EEPROM_SectorErase	; ����һ������
ENDIF
	MOV		length, #2
	MOV		R0, #Test_cnt_H
	LCALL	F_EEPROM_write_n		;дN���ֽ�	;address_H,address_L,R0,length

L_LVD_CheckLoop:		; ����Ƿ���Ȼ�͵�ѹ
	MOV		A, PCON
	ANL		PCON, #NOT (1 SHL 5)	; ��ѹ����־��0
	JNB		ACC.5, L_QuitLVD_Init
	MOV		R2, #250
	DJNZ	R2, $			;��ʱһ��
	SJMP	L_LVD_CheckLoop
L_QuitLVD_Init:

	POP		AR2
	POP		ACC
	POP		PSW
	RETI



;========================================================================
; ����: F_HEX2_DEC
; ����: ��˫�ֽ�ʮ��������ת��ʮ����BCD��.
; ����: (R6 R7): Ҫת����˫�ֽ�ʮ��������.
; ����: (R3 R4 R5) = BCD��.
; �汾: V1.0, 2013-10-22
;========================================================================
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

;========================================================================
; ����: F_Display
; ����: ��ʾ��������.
; ����: non.
; ����: non.
; �汾: V1.0, 2014-1-22
;========================================================================
F_Display:
	MOV		R6, Test_cnt_H
	MOV		R7, Test_cnt_L
	LCALL	F_HEX2_DEC		;(R6 R7) HEX Change to DEC ---> (R3 R4 R5), use (R2~R7)
	MOV		LED8+3, R3	;��λ
	MOV		A, R4
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
	
	MOV		R0, #LED8+3
L_Cut0_Loop:			;����λ0
	MOV		A,@R0
	JNZ		L_QuitCut0
	MOV		@R0, #DIS_BLACK
	INC		R0
	CJNE	R0, #LED8+7, L_Cut0_Loop
L_QuitCut0:	
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
	


;========================================================================
; ����: F_DisableEEPROM
; ����: ��ֹ����ISP/IAP.
; ����: non.
; ����: non.
; �汾: V1.0, 2012-10-22
;========================================================================
F_DisableEEPROM:
	MOV		ISP_CONTR, #0		; ��ֹISP/IAP����
	MOV		ISP_CMD,  #0		; ȥ��ISP/IAP����
	MOV		ISP_TRIG, #0		; ��ֹISP/IAP�����󴥷�
	MOV		ISP_ADDRH, #0FFH	; ��0��ַ���ֽ�
	MOV		ISP_ADDRL, #0FFH	; ��0��ַ���ֽڣ�ָ���EEPROM������ֹ�����
	RET

;========================================================================
; ����: F_EEPROM_read_n
; ����: ��ָ��EEPROM�׵�ַ����n���ֽڷ�ָ���Ļ���.
; ����: address_H,address_L:  ����EEPROM���׵�ַ.
;       R0:                   �������ݷŻ�����׵�ַ.
;       length:               �������ֽڳ���.
; ����: non.
; �汾: V1.0, 2012-10-22
;========================================================================
F_EEPROM_read_n:
	PUSH	AR2

	MOV		R2, length
	MOV		ISP_ADDRH, address_H	; �͵�ַ���ֽڣ���ַ��Ҫ�ı�ʱ���������͵�ַ��
	MOV		ISP_ADDRL, address_L	; �͵�ַ���ֽ�
	MOV		ISP_CONTR, #(ISP_EN + ISP_WAIT_FREQUENCY)	; ���õȴ�ʱ�䣬����ISP/IAP��������һ�ξ͹�
	MOV		ISP_CMD, #1				; ISP�����������ֽڶ���������ı�ʱ����������������
	MOV		C, EA
	MOV		F0, C	;����EA
L_EE_Read_Loop:
	CLR		EA		; ��ֹ�ж�
	MOV		ISP_TRIG, #0x5A			;ISP��������
	MOV		ISP_TRIG, #0xA5
	NOP
	MOV		C, F0
	MOV		EA, C		; �����ж�(�������)
	MOV		@R0, ISP_DATA

	MOV		A, ISP_ADDRL	;
	ADD		A, #1
	MOV		ISP_ADDRL, A
	MOV		A, ISP_ADDRH
	ADDC	A, #0
	MOV		ISP_ADDRH, A
	INC		R0
	DJNZ	R2, L_EE_Read_Loop

	LCALL	F_DisableEEPROM
	POP		AR2
	RET

;========================================================================
; ����: F_EEPROM_SectorErase
; ����: ��ָ����ַ��EEPROM��������.
; ����: address_H,address_L:  Ҫ����������EEPROM�ĵ�ַ.
; ����: non.
; �汾: V1.0, 2013-5-10
;========================================================================
F_EEPROM_SectorErase:
											;ֻ������������û���ֽڲ�����512�ֽ�/������
											;����������һ���ֽڵ�ַ����������ַ��
	MOV		ISP_ADDRH, address_H	; �͵�ַ���ֽڣ���ַ��Ҫ�ı�ʱ���������͵�ַ��
	MOV		ISP_ADDRL, address_L	; �͵�ַ���ֽ�
	MOV		ISP_CONTR, #(ISP_EN + ISP_WAIT_FREQUENCY)	; ���õȴ�ʱ�䣬����ISP/IAP��������һ�ξ͹�
	MOV		ISP_CMD, #3		;��������������
	MOV		C, EA
	MOV		F0, C	;����EA
	CLR		EA		; ��ֹ�ж�
	MOV		ISP_TRIG, #0x5A			;ISP��������
	MOV		ISP_TRIG, #0xA5
	NOP
	MOV		C, F0
	MOV		EA, C		; �����ж�(�������)
	LCALL	F_DisableEEPROM
	RET

;========================================================================
; ����: F_EEPROM_write_n
; ����: �ѻ����n���ֽ�д��ָ���׵�ַ��EEPROM.
; ����: address_H,address_L:	д��EEPROM���׵�ַ.
;       R0: 					д��Դ���ݵĻ�����׵�ַ.
;       length:      			д����ֽڳ���.
; ����: non.
; �汾: V1.0, 2014-1-22
;========================================================================
F_EEPROM_write_n:
	PUSH	AR2
	MOV		R2, length
	MOV		ISP_ADDRH, address_H	; �͵�ַ���ֽڣ���ַ��Ҫ�ı�ʱ���������͵�ַ��
	MOV		ISP_ADDRL, address_L	; �͵�ַ���ֽ�
	MOV		ISP_CONTR, #(ISP_EN + ISP_WAIT_FREQUENCY)	; ���õȴ�ʱ�䣬����ISP/IAP��������һ�ξ͹�
	MOV		ISP_CMD, #2		;���ֽ�д��������ı�ʱ����������������
	MOV		C, EA
	MOV		F0, C	;����EA
L_EE_W_Loop:
	MOV		ISP_DATA, @R0	; �����ݵ�ISP_DATA��ֻ�����ݸı�ʱ����������
	CLR		EA		; ��ֹ�ж�
	MOV		ISP_TRIG, #0x5A			;ISP��������
	MOV		ISP_TRIG, #0xA5
	NOP
	MOV		C, F0
	MOV		EA, C		; �����ж�(�������)
	MOV		A, ISP_ADDRL	;
	ADD		A, #1
	MOV		ISP_ADDRL, A
	MOV		A, ISP_ADDRH
	ADDC	A, #0
	MOV		ISP_ADDRH, A
	INC		R0
	DJNZ	R2, L_EE_W_Loop

	LCALL	F_DisableEEPROM
	POP		AR2
	RET


	END



