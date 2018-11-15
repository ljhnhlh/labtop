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

;��дRTC, ICΪPCF8563.

;��STC��MCU��IO��ʽ����74HC595����8λ����ܡ�

;�û������޸ĺ���ѡ��ʱ��Ƶ��.
;ʹ��Timer0��16λ�Զ���װ������1ms����,�������������������, �û��޸�MCU��ʱ��Ƶ��ʱ,�Զ���ʱ��1ms.

;8λ�������ʾʱ��(Сʱ-����-��).

;����ɨ�谴������Ϊ17~32.

;����ֻ֧�ֵ�������, ��֧�ֶ��ͬʱ����, ���������в���Ԥ֪�Ľ��.

;�����³���1���,����10��/����ٶ��ṩ�ؼ����. �û�ֻ��Ҫ���KeyCode�Ƿ��0���жϼ��Ƿ���.

;����ʱ���:
;����17: Сʱ+.
;����18: Сʱ-.
;����19: ����+.
;����20: ����-.


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

IO_KeyState		DATA	3EH	; IO���м�״̬����
IO_KeyState1	DATA	3FH
IO_KeyHoldCnt	DATA	40H	; IO�����¼�ʱ
KeyCode			DATA	41H	; ���û�ʹ�õļ���, 1~16ΪADC���� 17~32ΪIO��

RTC				DATA	42H	;����3���ֽ�, ��дRTCʱʹ��
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
	
;	MOV		hour,   #12	; ��ʼ��ʱ��ֵ
;	MOV		minute, #0
;	MOV		second, #0
;	LCALL	F_DisplayRTC
	
	LCALL	F_ReadRTC	;��RTC
	CLR		F0

	MOV		A, second	;if(second >= 60)	F0 = 1;	//����
	CLR		C
	SUBB	A, #60
	JC		$+4
	SETB	F0

	MOV		A, minute	;if(minute >= 60)	F0 = 1;	//����
	CLR		C
	SUBB	A, #60
	JC		$+4
	SETB	F0

	MOV		A, hour		;if(hour   >= 24)	F0 = 1;	//����
	CLR		C
	SUBB	A, #24
	JC		$+4
	SETB	F0

	JNB		F0, L_RTC_NoErr
	MOV		hour, #12		;�д���, Ĭ��12:00:00
	MOV		second, #0		;
	MOV		minute, #0		;
	LCALL	F_WriteRTC		;д��RTC
L_RTC_NoErr:

	LCALL	F_DisplayRTC
	MOV		LED8+2, #DIS_;
	MOV		LED8+5, #DIS_;

	CLR		A
	MOV		IO_KeyState, A
	MOV		IO_KeyState1, A
	MOV		IO_KeyHoldCnt, A
	MOV		KeyCode, A		; ���û�ʹ�õļ���, 17~32��Ч
	MOV		cnt50ms, #50

;=====================================================

;=================== ��ѭ�� ==================================
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
	
;================= 1000ms���� ����RTC ====================================
	MOV		msecond_L, #0	;if(msecond >= 1000)
	MOV		msecond_H, #0

	LCALL	F_ReadRTC	;��RTC
	LCALL	F_DisplayRTC
L_Quit_Check_1000ms:

;======================= 50msɨ��һ�����м��� ==============================
L_Read_IO_Key:
	DJNZ	cnt50ms, L_Quit_Read_IO_Key		; (cnt50ms - 1) != 0, jmp
	MOV		cnt50ms, #50	;
	LCALL	F_IO_KeyScan	;50msɨ��һ�����м���
L_Quit_Read_IO_Key:
;=====================================================


;=====================================================
L_KeyProcess:
	MOV		A, KeyCode
	JZ		L_Quit_KeyProcess
						;�м�����
	MOV		A, KeyCode
	CJNE	A, #17, L_Quit_K17
	INC		hour		;if(KeyCode == 17)	hour +1
	MOV		A, hour
	CLR		C
	SUBB	A, #24
	JC		L_K17_Display
	MOV		hour, #0
L_K17_Display:
	LCALL	F_WriteRTC
	LCALL	F_DisplayRTC
L_Quit_K17:

	MOV		A, KeyCode
	CJNE	A, #18, L_Quit_K18
	DEC		hour	; hour - 1
	MOV		A, hour
	CJNE	A, #255, L_K18_Display
	MOV		hour, #23
L_K18_Display:
	LCALL	F_WriteRTC
	LCALL	F_DisplayRTC
L_Quit_K18:

	MOV		A, KeyCode
	CJNE	A, #19, L_Quit_K19
	MOV		second, #0		;��������ʱ�����
	INC		minute	; minute + 1
	MOV		A, minute
	CLR		C
	SUBB	A, #60
	JC		L_K19_Display
	MOV		minute, #0
L_K19_Display:
	LCALL	F_WriteRTC
	LCALL	F_DisplayRTC
L_Quit_K19:

	MOV		A, KeyCode
	CJNE	A, #20, L_Quit_K20
	MOV		second, #0		;��������ʱ�����
	DEC		minute	; minute - 1
	MOV		A, minute
	CJNE	A, #255, L_K20_Display
	MOV		minute, #59
L_K20_Display:
	LCALL	F_WriteRTC
	LCALL	F_DisplayRTC
L_Quit_K20:

	MOV		KeyCode, #0
L_Quit_KeyProcess:

	LJMP	L_Main_Loop

;**********************************************/


;/*****************************************************
;	���м�ɨ�����
;	ʹ��XY����4x4���ķ�����ֻ�ܵ������ٶȿ�
;
;   Y     P04      P05      P06      P07
;          |        |        |        |
;X         |        |        |        |
;P00 ---- K00 ---- K01 ---- K02 ---- K03 ----
;          |        |        |        |
;P01 ---- K04 ---- K05 ---- K06 ---- K07 ----
;          |        |        |        |
;P02 ---- K08 ---- K09 ---- K10 ---- K11 ----
;          |        |        |        |
;P03 ---- K12 ---- K13 ---- K14 ---- K15 ----
;          |        |        |        |
;******************************************************/


T_KeyTable:  DB 0,1,2,0,3,0,0,0,4,0,0,0,0,0,0,0

F_IO_KeyDelay:
	PUSH	03H		;R3��ջ
	MOV		R3, #60
	DJNZ	R3, $	; (n * 4) T
	POP		03H		;R3��ջ
	RET

F_IO_KeyScan:	;50ms call
	PUSH	06H		;R6��ջ
	PUSH	07H		;R7��ջ

	MOV		R6, IO_KeyState1	; ������һ��״̬

	MOV		P0, #0F0H		;X�ͣ���Y
	LCALL	F_IO_KeyDelay		;delay about 250T
	MOV		A, P0
	ANL		A, #0F0H
	MOV		IO_KeyState1, A		; IO_KeyState1 = P0 & 0xf0

	MOV		P0, #0FH		;Y�ͣ���X
	LCALL	F_IO_KeyDelay		;delay about 250T
	MOV		A, P0
	ANL		A, #0FH
	ORL		A, IO_KeyState1			; IO_KeyState1 |= (P0 & 0x0f)
	MOV		IO_KeyState1, A
	XRL		IO_KeyState1, #0FFH		; IO_KeyState1 ^= 0xff;	ȡ��

	MOV		A, R6					;if(j == IO_KeyState1),	�������ζ����
	CJNE	A, IO_KeyState1, L_QuitCheckIoKey	;�����, jmp
	
	MOV		R6, IO_KeyState		;�ݴ�IO_KeyState
	MOV		IO_KeyState, IO_KeyState1
	MOV		A, IO_KeyState
	JZ		L_NoIoKeyPress		; if(IO_KeyState != 0), �м�����

	MOV		A, R6	
	JZ		L_CalculateIoKey	;if(R6 == 0)	F0 = 1;	��һ�ΰ���
	MOV		A, R6	
	CJNE	A, IO_KeyState,	L_QuitCheckIoKey	; if(j != IO_KeyState), jmp
	
	INC		IO_KeyHoldCnt	; if(++IO_KeyHoldCnt >= 20),	1����ؼ�
	MOV		A, IO_KeyHoldCnt
	CJNE	A, #20, L_QuitCheckIoKey
	MOV		IO_KeyHoldCnt, #18;
L_CalculateIoKey:
	MOV		A, IO_KeyState
	SWAP	A		;R6 = T_KeyTable[IO_KeyState >> 4];
	ANL		A, #0x0F
	MOV		DPTR, #T_KeyTable
	MOVC	A, @A+DPTR
	MOV		R6, A
	
	JZ		L_QuitCheckIoKey	; if(R6 == 0)
	MOV		A, IO_KeyState
	ANL		A, #0x0F
	MOVC	A, @A+DPTR
	MOV		R7, A
	JZ		L_QuitCheckIoKey	; if(T_KeyTable[IO_KeyState& 0x0f] == 0)
	
	MOV		A, R6		;KeyCode = (j - 1) * 4 + T_KeyTable[IO_KeyState & 0x0f] + 16;	//������룬17~32
	ADD		A, ACC
	ADD		A, ACC
	MOV		R6, A
	MOV		A, R7
	ADD		A, R6
	ADD		A, #12
	MOV		KeyCode, A
	SJMP	L_QuitCheckIoKey
	
L_NoIoKeyPress:
	MOV		IO_KeyHoldCnt, #0

L_QuitCheckIoKey:
	MOV		P0, #0xFF
	POP		07H		;R7��ջ
	POP		06H		;R6��ջ
	REt



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
	

;************ I2C��غ��� ****************
SLAW	EQU		0xA2
SLAR	EQU		0xA3

SDA		BIT 	P1.1	;����SDA  PIN5
SCL		BIT 	P1.0	;����SCL  PIN6

;========================================================================
; ����: F_I2C_Delay
; ����: I2C������ʱ, ��ͬ����ƵҪ�޸Ĵ˺���.
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_I2C_Delay:
	PUSH	AR2
	MOV		R2, 11	;Fosc(MHZ) / 2, ��2us����
	DJNZ	R2, $
	POP		AR2
	RET

;========================================================================
; ����: F_I2C_Start
; ����: ����I2C. start the I2C, SDA High-to-low when SCL is high
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_I2C_Start:
	SETB	SDA
	LCALL	F_I2C_Delay
	SETB	SCL
	LCALL	F_I2C_Delay
	CLR		SDA
	LCALL	F_I2C_Delay
	CLR		SCL
	LCALL	F_I2C_Delay
	RET


;========================================================================
; ����: F_I2C_Stop
; ����: ֹͣI2C. STOP the I2C, SDA Low-to-high when SCL is high
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_I2C_Stop:
	CLR		SDA
	LCALL	F_I2C_Delay
	SETB	SCL
	LCALL	F_I2C_Delay
	SETB	SDA
	LCALL	F_I2C_Delay
	RET

;========================================================================
; ����: F_Send_ACK
; ����: ����Ӧ��. Send ACK (LOW)
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_Send_ACK:
	CLR		SDA
	LCALL	F_I2C_Delay
	SETB	SCL
	LCALL	F_I2C_Delay
	CLR		SCL
	LCALL	F_I2C_Delay
	RET

;========================================================================
; ����: F_Send_NoACK
; ����: ���ͷ�Ӧ��. Send No ACK (High)
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_Send_NoACK:
	SETB	SDA
	LCALL	F_I2C_Delay
	SETB	SCL
	LCALL	F_I2C_Delay
	CLR		SCL
	LCALL	F_I2C_Delay
	RET
		
;========================================================================
; ����: F_I2C_Check_ACK
; ����: ���Ӧ��. Check ACK
; ����: none.
; ����: If F0=0, then right, if F0=1, then error.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_I2C_Check_ACK:
	SETB	SDA
	LCALL	F_I2C_Delay
	SETB	SCL
	LCALL	F_I2C_Delay
	MOV		C, SDA
	MOV		F0, C
	CLR		SCL
	LCALL	F_I2C_Delay
	RET


;========================================================================
; ����: F_I2C_WriteAbyte
; ����: дһ���ֽ�. write a byte to I2C
; ����: ACC: Ҫд����ֽ�.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_I2C_WriteAbyte:
	PUSH	AR6
	PUSH	AR7
	MOV		R7, ACC
	MOV		R6, #8
L_I2C_WriteAbyteLoop:
	MOV		A, R7
	RLC		A
	MOV		SDA, C
	MOV		R7, A
	LCALL	F_I2C_Delay
	SETB	SCL
	LCALL	F_I2C_Delay
	CLR		SCL
	LCALL	F_I2C_Delay
	DJNZ	R6, L_I2C_WriteAbyteLoop
	POP		AR7
	POP		AR6
	RET

;========================================================================
; ����: F_I2C_ReadAbyte
; ����: ��һ���ֽ�. read A byte from I2C
; ����: none.
; ����: ACC: �Ѷ������ֽ�.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_I2C_ReadAbyte:
	PUSH	AR6
	PUSH	AR7
	
	SETB	SDA
	MOV		R6, #8
L_I2C_ReadAbyteLoop:
	SETB	SCL
	LCALL	F_I2C_Delay
	MOV		A, R7
	MOV		C, SDA
	RLC		A
	MOV		R7, A
	CLR		SCL
	LCALL	F_I2C_Delay
	DJNZ	R6, L_I2C_ReadAbyteLoop
	MOV		A, R7
	POP		AR7
	POP		AR6
	RET

;========================================================================
; ����: F_WriteNbyte
; ����: дN���ֽ��ӳ���
; ����: R2: дI2C�����׵�ַ,  R0: д�����ݴ���׵�ַ,  R3: д���ֽ���
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
; ��ע: ����ACCC��PSW��, ���õ���ͨ�üĴ�������ջ
;========================================================================
F_WriteNbyte:
	LCALL	F_I2C_Start
	MOV		A, #SLAW
	LCALL	F_I2C_WriteAbyte
	LCALL	F_I2C_Check_ACK
	JB		F0, L_WriteN_StopI2C

	MOV		A, R2
	LCALL	F_I2C_WriteAbyte
	LCALL	F_I2C_Check_ACK
	JB		F0, L_WriteN_StopI2C

L_WriteNbyteLoop:
	MOV		A, @R0
	LCALL	F_I2C_WriteAbyte
	INC		R0
	LCALL	F_I2C_Check_ACK
	JB		F0, L_WriteN_StopI2C
	DJNZ	R3, L_WriteNbyteLoop 
L_WriteN_StopI2C:
	LCALL	F_I2C_Stop
	RET


;========================================================================
; ����: F_ReadNbyte
; ����: ��N���ֽ��ӳ���
; ����: R2: ��I2C�����׵�ַ,  R0: �������ݴ���׵�ַ,  R3: �����ֽ���
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
; ��ע: ����ACCC��PSW��, ���õ���ͨ�üĴ�������ջ
;========================================================================
F_ReadNbyte:
	LCALL	F_I2C_Start
	MOV		A, #SLAW
	LCALL	F_I2C_WriteAbyte
	LCALL	F_I2C_Check_ACK
	JB		F0, L_ReadN_StopI2C

	MOV		A, R2
	LCALL	F_I2C_WriteAbyte
	LCALL	F_I2C_Check_ACK
	JB		F0, L_ReadN_StopI2C

	LCALL	F_I2C_Start
	MOV		A, #SLAR
	LCALL	F_I2C_WriteAbyte
	LCALL	F_I2C_Check_ACK
	JB		F0, L_ReadN_StopI2C

	MOV		A, R3
	ANL		A, #0xfe	;�ж��Ƿ����1
	JZ		L_ReadLastByte
	DEC		R3			;����1�ֽ�, ��-1
L_ReadNbyteLoop:
	LCALL	F_I2C_ReadAbyte		;*p = I2C_ReadAbyte();	p++;
	MOV		@R0, A
	INC		R0
	LCALL	F_Send_ACK		;send ACK
	DJNZ	R3, L_ReadNbyteLoop 
L_ReadLastByte:
	LCALL	F_I2C_ReadAbyte		;*p = I2C_ReadAbyte()
	MOV		@R0, A
	LCALL	F_Send_NoACK	;send no ACK
L_ReadN_StopI2C:
	LCALL	F_I2C_Stop
	RET

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

	MOV		LED8+2, #DIS_
	
	MOV		A, minute
	MOV		B, #10
	DIV		AB
	MOV		LED8+3, A;
	MOV		LED8+4, B;

	MOV		LED8+5, #DIS_

	MOV		A, second
	MOV		B, #10
	DIV		AB
	MOV		LED8+6, A;
	MOV		LED8+7, B;
L_QuitDisplayRTC:
	POP		B		;B��ջ
	RET


;========================================================================
; ����: F_ReadRTC
; ����: ��RTC������
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
; ��ע: 
;========================================================================
F_ReadRTC:

	MOV		R2, #2		; ��I2C�����׵�ַ
	MOV		R0, #RTC	; �������ݴ���׵�ַ
	MOV		R3, #3		; �����ֽ���
	LCALL	F_ReadNbyte	; R2: ��I2C�����׵�ַ,  R0: �������ݴ���׵�ַ,  R3: �����ֽ���

	MOV		A, RTC		; second
	SWAP	A
	ANL		A, #7
	MOV		B, #10
	MUL		AB
	MOV		B, A
	MOV		A, RTC
	ANL		A, #0x0f
	ADD		A, B
	MOV		second, A	;second = ((RTC >> 4) & 0x07) * 10 + (RTC & 0x0f)

	MOV		A, RTC+1
	SWAP	A
	ANL		A, #7
	MOV		B, #10
	MUL		AB
	MOV		B, A
	MOV		A, RTC+1
	ANL		A, #0x0f
	ADD		A, B
	MOV		minute, A	;minute = (([RTC+1] >> 4) & 0x07) * 10 + ([RTC+1] & 0x0f)
	
	MOV		A, RTC+2
	SWAP	A
	ANL		A, #3
	MOV		B, #10
	MUL		AB
	MOV		B, A
	MOV		A, RTC+2
	ANL		A, #0x0f
	ADD		A, B
	MOV		hour, A		;hour   = (([RTC+2] >> 4) & 0x03) * 10 + ([RTC+2] & 0x0f)
	RET

;========================================================================
; ����: F_WriteRTC
; ����: дRTC������
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
; ��ע: 
;========================================================================
F_WriteRTC:

	MOV		A, second
	MOV		B, #10
	DIV		AB
	SWAP	A
	ADD		A, B
	MOV		RTC, A		;tmp[0] = ((second / 10) << 4) + (second % 10);

	MOV		A, minute
	MOV		B, #10
	DIV		AB
	SWAP	A
	ADD		A, B
	MOV		RTC+1, A	;((minute / 10) << 4) + (minute % 10);

	MOV		A, hour
	MOV		B, #10
	DIV		AB
	SWAP	A
	ADD		A, B
	MOV		RTC+2, A	;((hour / 10) << 4) + (hour % 10);

	MOV		R2, #2		;дI2C�����׵�ַ
	MOV		R0, #RTC	;д�����ݴ���׵�ַ
	MOV		R3, #3		;д���ֽ���
	LCALL	F_WriteNbyte	;
	RET



	END



