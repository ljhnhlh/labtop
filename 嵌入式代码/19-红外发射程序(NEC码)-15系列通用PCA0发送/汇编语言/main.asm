
;/*---------------------------------------------------------------------*/
;/* --- STC MCU Limited ------------------------------------------------*/
;/* --- Mobile: (86)13922805190 ----------------------------------------*/
;/* --- Fax: 86-755-82905966 -------------------------------------------*/
;/* --- Tel: 86-755-82948412 -------------------------------------------*/
;/* --- Web: www.STCMCU.com --------------------------------------------*/
;/* ���Ҫ��������Ӧ�ô˴���,����������ע��ʹ���˺꾧�Ƽ������ϼ�����   */
;/*---------------------------------------------------------------------*/

;/*************	����˵��	**************

;�û������ں궨���иı�MCU��ʱ��Ƶ��. ��Χ 8MHZ ~ 33MHZ.

;������ճ���ģ���г�����������NEC�ı��롣

;�û������ں궨����ָ���û���.

;ʹ��PCA2�����������38KHZ�ز�, 1/3ռ�ձ�, ÿ��38KHZ���ڷ���ܷ���9us,�ر�16.3us.

;ʹ�ÿ������ϵ�16��IOɨ�谴��, MCU��˯��, ����ɨ�谴��.

;��������, ��һ֡Ϊ����, �����֡Ϊ�ظ���,��������, ���嶨�������вο�NEC�ı�������.

;���ͷź�, ֹͣ����.

;******************************************/

;/****************************** �û������ ***********************************/

STACK_POIRTER	EQU		0D0H	;��ջ��ʼ��ַ
Fosc_KHZ		EQU		22118	;22118KHZ

//Fosc = 22.1184MHZ, ���ı�Ƶ��ʱ, ���ֹ���������� D_38K_DUTY �� D_38K_ON ��ֵ.
D_38K_DUTY	EQU	581							;=(Fosc(MHZ) * 26.3)	/* 	38KHZ����ʱ��	26.3us */
D_38K_ON	EQU	199							;=(Fosc(MHZ) * 9)		/* ����ܵ�ͨʱ��	9us */
D_38K_OFF	EQU	(D_38K_DUTY - D_38K_ON)		;=(Fosc(MHZ) * 17.3)	/* ����ܹر�ʱ��	17.3us */

;*******************************************************************
;*******************************************************************


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

P_SW1 		DATA	0A2H
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

IO_KeyState		DATA	30H	; IO���м�״̬����
IO_KeyState1	DATA	31H
IO_KeyHoldCnt	DATA	32H	; IO�����¼�ʱ
KeyCode			DATA	33H	; ���û�ʹ�õļ���, 1~16ΪADC���� 17~32ΪIO��


/*************	���ⷢ����ر���	**************/
#define	User_code	0xFF00		//��������û���

P_IR_TX   BIT P3.7	;������ⷢ�Ͷ˿�

FLAG0	DATA	0x20
B_Space	BIT	FLAG0.0	;���Ϳ���(��ʱ)��־

PCA_Timer0H	DATA	0x34	;PCA2�����ʱ������
PCA_Timer0L	DATA	0x35
tx_cntH		DATA	0x36	;���ͻ���е��������(����38KHZ������������Ӧʱ��), ����Ƶ��Ϊ38KHZ, ����26.3us
tx_cntL		DATA	0x37	
TxTime		DATA	0x38	;����ʱ��


;*******************************************************************
;*******************************************************************
		ORG		0000H				;reset
		LJMP	F_Main

		ORG		003BH				;7  PCA interrupt
		LJMP	F_PCA_Interrupt


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

	LCALL	F_PCA_Init		;��ʼ��PCA2
	SETB	P_IR_TX
	
	SETB	EA				;�����ж�
	
	LCALL	F_DisableHC595	;��ֹ��ѧϰ���ϵ�HC595��ʾ��ʡ��

	MOV		KeyCode, #0

;=================== ��ѭ�� ==================================
L_Main_Loop:
	MOV		A, #30
	LCALL	F_delay_ms		;��ʱ30ms
	LCALL	F_IO_KeyScan	;ɨ�����

	MOV		A, KeyCode
	JZ		L_Main_Loop		;�޼�ѭ��
	MOV		TxTime, #0		;
							;һ֡������С���� = 9 + 4.5 + 0.5625 + 24 * 1.125 + 8 * 2.25 = 59.0625 ms
							;һ֡������󳤶� = 9 + 4.5 + 0.5625 + 8 * 1.125 + 24 * 2.25 = 77.0625 ms
	MOV		tx_cntH, #HIGH 342		;��Ӧ9ms��ͬ��ͷ		9ms
	MOV		tx_cntL, #LOW  342
	LCALL	F_IR_TxPulse

	MOV		tx_cntH, #HIGH 171		;��Ӧ4.5ms��ͬ��ͷ���	4.5ms
	MOV		tx_cntL, #LOW  171
	LCALL	F_IR_TxSpace

	MOV		tx_cntH, #HIGH 21		;��������			0.5625ms
	MOV		tx_cntL, #LOW  21
	LCALL	F_IR_TxPulse

	MOV		A, #LOW  User_code	;���û�����ֽ�
	LCALL	F_IR_TxByte
	MOV		A, #HIGH User_code	;���û�����ֽ�
	LCALL	F_IR_TxByte
	MOV		A, KeyCode			;������
	LCALL	F_IR_TxByte
	MOV		A, KeyCode			;�����ݷ���
	CPL		A
	LCALL	F_IR_TxByte

	MOV		A, TxTime
	CLR		C
	SUBB	A, #56		;һ֡�����77ms����, �����Ļ�,����ʱ��		108ms
	JNC		L_ADJ_Time

	CLR		c
	MOV		A, #56
	SUBB	A, TxTime
	MOV		TxTime, A
	RRC		A
	RRC		A
	RRC		A
	ANL		A, #0x1F
	ADD		A, TxTime
	LCALL	F_delay_ms		;TxTime = 56 - TxTime;	TxTime = TxTime + TxTime / 8;	delay_ms(TxTime);
L_ADJ_Time:
	MOV		A, #31			;delay_ms(31)
	LCALL	F_delay_ms
		
L_WaitKeyRelease:
	MOV		A, IO_KeyState
	JZ		L_ClearKeyCode

							;��δ�ͷ�, �����ظ�֡(������)
	MOV		tx_cntH, #HIGH 342		;��Ӧ9ms��ͬ��ͷ		9ms
	MOV		tx_cntL, #LOW  342
	LCALL	F_IR_TxPulse

	MOV		tx_cntH, #HIGH 86		;��Ӧ2.25ms��ͬ��ͷ���	2.25ms
	MOV		tx_cntL, #LOW  86
	LCALL	F_IR_TxSpace

	MOV		tx_cntH, #HIGH 21		;��������			0.5625ms
	MOV		tx_cntL, #LOW  21
	LCALL	F_IR_TxPulse

	MOV		A, #96			;delay_ms(96)
	LCALL	F_delay_ms
	LCALL	F_IO_KeyScan	;ɨ�����
	SJMP	L_WaitKeyRelease

L_ClearKeyCode:
	MOV	KeyCode, #0

	LJMP	L_Main_Loop
;===================================================================


;========================================================================
; ����: F_DisableHC595
; ����: ��ֹHC595��ʾ.
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
; ��ע: ���õ���ͨ�üĴ�������ջ����, �˳�ʱ�ָ�ԭ�����ݲ��ı�.
;========================================================================
F_DisableHC595:
	PUSH	AR7
	SETB	P_HC595_SER
	MOV		R7, #20
L_DisableHC595_Loop:
	SETB	P_HC595_SRCLK
	NOP
	CLR		P_HC595_SRCLK
	NOP
	DJNZ	R7, L_DisableHC595_Loop
	SETB	P_HC595_RCLK = 1;
	NOP
	CLR		P_HC595_RCLK = 0;							//�����������
	SETB	P_HC595_RCLK = 1;
	NOP
	CLR		P_HC595_RCLK = 0;							//�����������
	POP		AR7
	RET


;========================================================================
; ����: F_delay_ms
; ����: ��ʱ�ӳ���
; ����: ACC: ��ʱms��.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
; ��ע: ����ACCC��PSW��, ���õ���ͨ�üĴ�������ջ����, �˳�ʱ�ָ�ԭ�����ݲ��ı�.
;========================================================================
F_delay_ms:
	PUSH	02H		;��ջR2
	PUSH	03H		;��ջR3
	PUSH	04H		;��ջR4

	MOV		R2,A

L_delay_ms_1:
	MOV		R3, #HIGH (Fosc_KHZ / 13)
	MOV		R4, #LOW (Fosc_KHZ / 13)
	
L_delay_ms_2:
	MOV		A, R4			;1T		Total 13T/loop
	DEC		R4				;2T
	JNZ		L_delay_ms_3	;4T
	DEC		R3
L_delay_ms_3:
	DEC		A				;1T
	ORL		A, R3			;1T
	JNZ		L_delay_ms_2	;4T
	
	DJNZ	R2, L_delay_ms_1

	POP		04H		;��ջR2
	POP		03H		;��ջR3
	POP		02H		;��ջR4
	RET


;========================================================================
; ����: F_IO_KeyDelay
; ����: ���м�ɨ�����.
; ����: none
; ����: ��������, KeyCodeΪ��0����.
; �汾: V1.0, 2013-11-22
;========================================================================
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

F_IO_KeyScan:
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
	RET

;========================================================================
; ����: F_IR_TxPulse
; ����: �������庯��.
; ����: tx_cntH, tx_cntL: Ҫ���͵�38K������
; ����: none.
; �汾: V1.0, 2013-11-22
;========================================================================
F_IR_TxPulse:
	CLR		B_Space	;��־������
	MOV		CCAPM2, #(0x48 + 0x04 + 0x01)	; ����ģʽ 0x00: PCA_Mode_Capture,  0x42: PCA_Mode_PWM,  0x48: PCA_Mode_SoftTimer
	SETB	CR		;����
	JB		CR, $	;�ȴ�����
	SETB	P_IR_TX
	RET

;========================================================================
; ����: F_IR_TxSpace
; ����: ���Ϳ��к���.
; ����: tx_cntH, tx_cntL: Ҫ���͵�38K������
; ����: none.
; �汾: V1.0, 2013-11-22
;========================================================================
F_IR_TxSpace:
	SETB	B_Space	;��־����
	MOV		CCAPM2, #(0x48 + 0x01)	; ����ģʽ 0x00: PCA_Mode_Capture,  0x42: PCA_Mode_PWM,  0x48: PCA_Mode_SoftTimer
	SETB	CR		;����
	JB		CR, $	;�ȴ�����
	SETB	P_IR_TX
	RET


;========================================================================
; ����: F_IR_TxByte
; ����: ����һ���ֽں���.
; ����: ACC: Ҫ���͵��ֽ�
; ����: none.
; �汾: V1.0, 2013-11-22
;========================================================================
F_IR_TxByte:
	PUSH	AR4
	PUSH	AR5

	MOV		R4, #8
	MOV		R5, A
L_IR_TxByteLoop:
	MOV		A, R5
	JNB		ACC.0, L_IR_TxByte_0
	MOV		tx_cntH, #HIGH 63		;��������1
	MOV		tx_cntL, #LOW  63
	LCALL	F_IR_TxSpace
	INC		TxTime			;TxTime += 2;	//����1��Ӧ 1.6875 + 0.5625 ms
	INC		TxTime
	SJMP	L_IR_TxByte_Pause
L_IR_TxByte_0:
	MOV		tx_cntH, #HIGH 21		;��������0
	MOV		tx_cntL, #LOW  21
	LCALL	F_IR_TxSpace
	INC		TxTime			;����0��Ӧ 0.5625 + 0.5625 ms
L_IR_TxByte_Pause:
	MOV		tx_cntH, #HIGH 21		;��������
	MOV		tx_cntL, #LOW  21
	LCALL	F_IR_TxPulse		;���嶼��0.5625ms
	MOV		A, R5
	RR		A				;��һ��λ
	MOV		R5, A
	DJNZ	R4, L_IR_TxByteLoop
	POP		AR5
	POP		AR4
	
	RET

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
	MOV		CCON, #0x00;	//��������жϱ�־
	MOV		tx_cntH, #0
	MOV		tx_cntL, #2

	MOV		CCAPM0, #(0x48 + 1)	;����ģʽ + �ж����� 0x00: PCA_Mode_Capture,  0x42: PCA_Mode_PWM,  0x48: PCA_Mode_SoftTimer
	MOV		PCA_Timer0H, #HIGH 100	;����һ��С�ĳ�ֵ
	MOV		PCA_Timer0L, #LOW  100
	MOV		CCAP0L, PCA_Timer0L	;��Ӱ��Ĵ���д�벶��Ĵ�������дCCAPxL
	MOV		CCAP0H, PCA_Timer0H	;��дCCAPxH

	SETB	PPCA			;�����ȼ��ж�
	ANL		CMOD, #NOT 0xe0
	ORL		CMOD, #0x08		;ѡ��ʱ��Դ, 0x00: 12T, 0x02: 2T, 0x04: Timer0���, 0x06: ECI, 0x08: 1T, 0x0A: 4T, 0x0C: 6T, 0x0E: 8T
	RET



;========================================================================
; ����: F_PCA_Interrupt
; ����: PCA�жϴ������.
; ����: None
; ����: none.
; �汾: V1.0, 2012-11-22
;========================================================================

F_PCA_Interrupt:
	PUSH	PSW
	PUSH	ACC
	MOV		CCON, #0x40;	//��������жϱ�־,������CR
	JB		B_Space, L_PCA0_TxPause

					;�������壬����װ��TH0ֵ�����ʱ�Զ���װ
	CPL		P_IR_TX
	JNB		P_IR_TX, L_PCA0_LoadLow

	MOV		A, PCA_Timer0L
	ADD		A, #LOW D_38K_OFF	;װ�ظߵ�ƽʱ��	17.3us
	MOV		PCA_Timer0L, A
	MOV		A, PCA_Timer0H
	ADDC	A, #HIGH D_38K_OFF
	MOV		PCA_Timer0H, A
	
	MOV		A, tx_cntL	;if(--tx_cnt == 0)	CR = 0;	//pulse has sent,	stop
	DEC		tx_cntL
	JNZ		$+4
	DEC		tx_cntH
	DEC		A
	ORL		A, tx_cntH
	JNZ		L_PCA0_Reload
	CLR		CR
	SJMP	L_PCA0_Reload

L_PCA0_LoadLow:
	MOV		A, PCA_Timer0L
	ADD		A, #LOW D_38K_ON	;PCA_Timer0 += D_38K_ON, װ�ص͵�ƽʱ��	9us
	MOV		PCA_Timer0L, A
	MOV		A, PCA_Timer0H
	ADDC	A, #HIGH D_38K_ON
	MOV		PCA_Timer0H, A
	SJMP	L_PCA0_Reload
	
L_PCA0_TxPause:		;������ͣʱ��
	MOV		A, PCA_Timer0L
	ADD		A, #LOW D_38K_DUTY	;PCA_Timer0 += D_38K_DUTY;	//װ������ʱ��	26.3us
	MOV		PCA_Timer0L, A
	MOV		A, PCA_Timer0H
	ADDC	A, #HIGH D_38K_DUTY
	MOV		PCA_Timer0H, A

	MOV		A, tx_cntL	;if(--tx_cnt == 0)	CR = 0;	//����ʱ��
	DEC		tx_cntL
	JNZ		$+4
	DEC		tx_cntH
	DEC		A
	ORL		A, tx_cntH
	JNZ		L_PCA0_Reload
	CLR		CR

L_PCA0_Reload:
	MOV		CCAP0L, PCA_Timer0L	;��Ӱ��Ĵ���д�벶��Ĵ�������дCCAP0L
	MOV		CCAP0H, PCA_Timer0H	;��дCCAP0H

	POP	ACC
	POP	PSW
	RETI

	END


