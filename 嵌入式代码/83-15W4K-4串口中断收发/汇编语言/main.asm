
;/*---------------------------------------------------------------------*/
;/* --- STC MCU Limited ------------------------------------------------*/
;/* --- Mobile: (86)13922805190 ----------------------------------------*/
;/* --- Fax: 86-755-82905966 -------------------------------------------*/
;/* --- Tel: 86-755-82948412 -------------------------------------------*/
;/* --- Web: www.STCMCU.com --------------------------------------------*/
;/* ���Ҫ��������Ӧ�ô˴���,����������ע��ʹ���˺꾧�Ƽ������ϼ�����   */
;/*---------------------------------------------------------------------*/

;/*************	����˵��	**************

; 4����ȫ˫���жϷ�ʽ�շ�ͨѶ���򡣱�����ʹ��22.1184MHZʱ��.

; ͨ��PC��MCU��������, MCU�յ���ͨ�����ڰ��յ�������ԭ������.

;******************************************/

;/****************************** �û������ ***********************************/

UART1_Baudrate	EQU		(-48)	;115200bps @ 22.1184MHz		UART1_Baudrate = -(MAIN_Fosc / 4 / Baudrate)
UART2_Baudrate	EQU		(-96)	; 57600bps @ 22.1184MHz		UART2_Baudrate = -(MAIN_Fosc / 4 / Baudrate)
UART3_Baudrate	EQU		(-144)	; 38400bps @ 22.1184MHz		UART3_Baudrate = -(MAIN_Fosc / 4 / Baudrate)
UART4_Baudrate	EQU		(-288)	; 19200bps @ 22.1184MHz		UART4_Baudrate = -(MAIN_Fosc / 4 / Baudrate)


;*******************************************************************
;*******************************************************************
P_SW1 		DATA	0A2H
AUXR		DATA 	08EH
T2H			DATA 	0D6H
T2L			DATA 	0D7H
P_SW2		DATA	0BAH
S2CON 		DATA	09AH
S2BUF 		DATA	09BH
IE2   		DATA	0AFH

T4T3M 	DATA	0xD1;
T4H		DATA	0xD2;
T4L		DATA 	0xD3;
T3H		DATA 	0xD4;
T3L		DATA 	0xD5;
S3CON 	DATA	0xAC;
S3BUF 	DATA	0xAD;
S4CON	DATA	0x84;
S4BUF	DATA	0x85;
INT_CLKO DATA   0x8F;

P3M1 	DATA	0xB1;	//P3M1.n,P3M0.n 	=00--->Standard,	01--->push-pull
P3M0	DATA	0xB2;	//					=10--->pure input,	11--->open drain
P4M1	DATA 	0xB3;	//P4M1.n,P4M0.n 	=00--->Standard,	01--->push-pull
P4M0	DATA 	0xB4;	//					=10--->pure input,	11--->open drain
P5M1	DATA 	0xC9;	//	P5M1.n,P5M0.n 	=00--->Standard,	01--->push-pull
P5M0 	DATA	0xCA;	//					=10--->pure input,	11--->open drain
P6M1 	DATA	0xCB;	//	P5M1.n,P5M0.n 	=00--->Standard,	01--->push-pull
P6M0	DATA	0xCC;	//					=10--->pure input,	11--->open drain
P7M1	DATA	0xE1;
P7M0	DATA	0xE2;
P1M1 	DATA	0x91;	//P1M1.n,P1M0.n 	=00--->Standard,	01--->push-pull		ʵ����1T�Ķ�һ��
P1M0	DATA	0x92;	//					=10--->pure input,	11--->open drain
P0M1	DATA 	0x93;	//P0M1.n,P0M0.n 	=00--->Standard,	01--->push-pull
P0M0	DATA 	0x94;	//					=10--->pure input,	11--->open drain
P2M1	DATA 	0x95;	//P2M1.n,P2M0.n 	=00--->Standard,	01--->push-pull
P2M0 	DATA	0x96;	//					=10--->pure input,	11--->open drain


RX1_Length	EQU		128		; ���ڽ��ջ��峤��
RX2_Length	EQU		128		; ���ڽ��ջ��峤��
RX3_Length	EQU		128		; ���ڽ��ջ��峤��
RX4_Length	EQU		128		; ���ڽ��ջ��峤��

RX1_Buffer	EQU		0x0000	; ���ջ����׵�ַ
RX2_Buffer	EQU		(RX1_Buffer+RX1_Length)	; ���ջ����׵�ַ
RX3_Buffer	EQU		(RX2_Buffer+RX2_Length)	; ���ջ����׵�ַ
RX4_Buffer	EQU		(RX3_Buffer+RX3_Length)	; ���ջ����׵�ַ

B_TX1_Busy	BIT		20H.0	; ����æ��־
B_TX2_Busy	BIT		20H.1	; ����æ��־
B_TX3_Busy	BIT		20H.2	; ����æ��־
B_TX4_Busy	BIT		20H.3	; ����æ��־

RX1_write	DATA	30H		; ���ռ���
RX2_write	DATA	31H		; ���ռ���
RX3_write	DATA	32H		; ���ռ���
RX4_write	DATA	33H		; ���ռ���
TX1_read	DATA	34H
TX2_read	DATA	35H
TX3_read	DATA	36H
TX4_read	DATA	37H


STACK_POIRTER	EQU		0D0H	;��ջ��ʼ��ַ

;*******************************************************************
;*******************************************************************
		ORG		00H				;reset
		LJMP	F_Main

		ORG		23H				;4  UART1 interrupt
		LJMP	F_UART1_Interrupt

		ORG		43H				;8  UART2 interrupt
		LJMP	F_UART2_Interrupt

		ORG		8BH				;17  UART3 interrupt
		LJMP	F_UART3_Interrupt

		ORG		93H				;18  UART4 interrupt
		LJMP	F_UART4_Interrupt


;******************** ������ **************************/
F_Main:
	CLR		A
	MOV		P0M1, A		; ����Ϊ׼˫���
	MOV		P0M0, A
	MOV		P1M1, A		; ����Ϊ׼˫���
	MOV		P1M0, A
	MOV		P2M1, A		; ����Ϊ׼˫���
	MOV		P2M0, A
	MOV		P3M1, A		; ����Ϊ׼˫���
	MOV		P3M0, A
	MOV		P4M1, A		; ����Ϊ׼˫���
	MOV		P4M0, A
	MOV		P5M1, A		; ����Ϊ׼˫���
	MOV		P5M0, A
	
	MOV		SP, #STACK_POIRTER
	MOV		PSW, #0
	USING	0		;ѡ���0��R0~R7

;================= �û���ʼ������ ====================================
	MOV		A, #1
	LCALL	F_UART1_config
	MOV		A, #2
	LCALL	F_UART2_config
	MOV		A, #3
	LCALL	F_UART3_config
	MOV		A, #4
	LCALL	F_UART4_config

	SETB	EA		; ����ȫ���ж�

;================= ���ڷ�����ʾ��Ϣ ====================================
	MOV		DPTR, #TestString1	;Load string address to DPTR
	LCALL	F_SendString1		;Send string

	MOV		DPTR, #TestString2	;Load string address to DPTR
	LCALL	F_SendString2		;Send string

	MOV		DPTR, #TestString3	;Load string address to DPTR
	LCALL	F_SendString3		;Send string

	MOV		DPTR, #TestString4	;Load string address to DPTR
	LCALL	F_SendString4		;Send string


;=================== ��ѭ�� ==================================
L_MainLoop:

	MOV		A, TX1_read
	XRL		A, RX1_write
	JZ		L_QuitCheckRx1		;read��write���, ��û���յ�����, �˳�
	JB		B_TX1_Busy, L_QuitCheckRx1		; ����æ�� �˳�
	
	SETB	B_TX1_Busy			; ��־����æ
	MOV		DPTR, #RX1_Buffer
	MOV		A, TX1_read
	LCALL	F_GetRxData
	MOV		SBUF, A		; ��һ���ֽ�
	INC		TX1_read
	MOV		A, TX1_read
	CJNE	A, #RX1_Length, L_QuitCheckRx1
	MOV		TX1_read, #0		; �����������
L_QuitCheckRx1:

	MOV		A, TX2_read
	XRL		A, RX2_write
	JZ		L_QuitCheckRx2		;read��write���, ��û���յ�����, �˳�
	JB		B_TX2_Busy, L_QuitCheckRx2		; ����æ�� �˳�
	
	SETB	B_TX2_Busy			; ��־����æ
	MOV		DPTR, #RX2_Buffer
	MOV		A, TX2_read
	LCALL	F_GetRxData
	MOV		S2BUF, A		; ��һ���ֽ�
	INC		TX2_read
	MOV		A, TX2_read
	CJNE	A, #RX2_Length, L_QuitCheckRx2
	MOV		TX2_read, #0		; �����������
L_QuitCheckRx2:

	MOV		A, TX3_read
	XRL		A, RX3_write
	JZ		L_QuitCheckRx3		;read��write���, ��û���յ�����, �˳�
	JB		B_TX3_Busy, L_QuitCheckRx3		; ����æ�� �˳�
	
	SETB	B_TX3_Busy			; ��־����æ
	MOV		DPTR, #RX3_Buffer
	MOV		A, TX3_read
	LCALL	F_GetRxData
	MOV		S3BUF, A		; ��һ���ֽ�
	INC		TX3_read
	MOV		A, TX3_read
	CJNE	A, #RX3_Length, L_QuitCheckRx3
	MOV		TX3_read, #0		; �����������
L_QuitCheckRx3:

	MOV		A, TX4_read
	XRL		A, RX4_write
	JZ		L_QuitCheckRx4		;read��write���, ��û���յ�����, �˳�
	JB		B_TX4_Busy, L_QuitCheckRx4		; ����æ�� �˳�
	
	SETB	B_TX4_Busy			; ��־����æ
	MOV		DPTR, #RX4_Buffer
	MOV		A, TX4_read
	LCALL	F_GetRxData
	MOV		S4BUF, A		; ��һ���ֽ�
	INC		TX4_read
	MOV		A, TX4_read
	CJNE	A, #RX4_Length, L_QuitCheckRx4
	MOV		TX4_read, #0		; �����������
L_QuitCheckRx4:

	LJMP	L_MainLoop
;===================================================================

F_GetRxData:
	ADD		A, DPL
	MOV		DPL, A
	MOV		A, DPH
	ADDC	A, #0
	MOV		DPH, A
	MOVX	A, @DPTR
	RET


TestString1:    DB  "STC15F4K60S4 USART1 Test Prgramme!",0DH,0AH,0
TestString2:    DB  "STC15F4K60S4 USART2 Test Prgramme!",0DH,0AH,0
TestString3:    DB  "STC15F4K60S4 USART3 Test Prgramme!",0DH,0AH,0
TestString4:    DB  "STC15F4K60S4 USART4 Test Prgramme!",0DH,0AH,0


;----------------------------
;Send a string to UART
;Input: DPTR (address of string)
;Output:None
;----------------------------
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

F_SendString2:
	CLR		A
	MOVC	A, @A+DPTR		;Get current char
	JZ		L_SendEnd2		;Check the end of the string
	SETB	B_TX2_Busy		;��־����æ
	MOV		S2BUF, A		;����һ���ֽ�
	JB		B_TX2_Busy, $	;�ȴ��������
	INC		DPTR 			;increment string ptr
	SJMP	F_SendString2	;Check next
L_SendEnd2:
    RET

F_SendString3:
	CLR		A
	MOVC	A, @A+DPTR		;Get current char
	JZ		L_SendEnd3		;Check the end of the string
	SETB	B_TX3_Busy		;��־����æ
	MOV		S3BUF, A		;����һ���ֽ�
	JB		B_TX3_Busy, $	;�ȴ��������
	INC		DPTR 			;increment string ptr
	SJMP	F_SendString3	;Check next
L_SendEnd3:
    RET

F_SendString4:
	CLR		A
	MOVC	A, @A+DPTR		;Get current char
	JZ		L_SendEnd4		;Check the end of the string
	SETB	B_TX4_Busy		;��־����æ
	MOV		S4BUF, A		;����һ���ֽ�
	JB		B_TX4_Busy, $	;�ȴ��������
	INC		DPTR 			;increment string ptr
	SJMP	F_SendString4	;Check next
L_SendEnd4:
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
F_SetTimer2Baudrate:
	ANL		AUXR, #NOT (1 SHL 4)	; Timer stop
	ANL		AUXR, #NOT (1 SHL 3)	; Timer2 set As Timer Ĭ��
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
	CJNE	A, #2, L_UART1_NotUseT2
	ORL		AUXR, #001H		; S1 BRT Use Timer2;	������ʹ��Timer2����
	MOV		DPTR, #UART1_Baudrate
	LCALL	F_SetTimer2Baudrate
	SJMP	L_SetUART1

L_UART1_NotUseT2:
	CLR		TR1						; Timer Stop	������ʹ��Timer1����
	ANL		AUXR, #NOT 01H			; S1 BRT Use Timer1;
	ORL		AUXR, #(1 SHL 6)		; Timer1 set as 1T mode
	ANL		TMOD, #NOT (1 SHL 6)	; Timer1 set As Timer
	ANL		TMOD, #NOT 0x30			; Timer1_16bitAutoReload;
	MOV		TH1, #HIGH UART1_Baudrate
	MOV		TL1, #LOW  UART1_Baudrate
	CLR		ET1						; ��ֹ�ж�
	ANL		INT_CLKO, #NOT 0x02		; �����ʱ��
	SETB	TR1

L_SetUART1:
	MOV		A, SCON
	ANL		A, #03FH
	ORL		A, #(1 SHL 6)	; 8λ����, 1λ��ʼλ, 1λֹͣλ, ��У��
	MOV		SCON, A
;	SETB	PS		; �����ȼ��ж�
	SETB	REN		; �������
	SETB	ES		; �����ж�
	ANL		P_SW1, #NOT 0C0H	; UART1 ʹ��P30 P31��	Ĭ��
;	ORL		P_SW1, #040H		; UART1 ʹ��P36 P37��
;	ORL		P_SW1, #080H		; UART1 ʹ��P16 P17��	(����ʹ���ڲ�ʱ��)

	CLR		A
	MOV		TX1_read, A;
	MOV		RX1_write, A;
	CLR		B_TX1_busy
	RET

;====================================================

;========================================================================
; ����: F_UART2_config
; ����: UART2��ʼ��������
; ����: ACC: ѡ������, 2: ʹ��Timer2��������, ����ֵ: ��Ч.
; ����: none.
; �汾: VER1.0
; ����: 2014-11-28
; ��ע: 
;========================================================================
F_UART2_config:
	CJNE	A, #2, L_UART2_NotUseT2
	MOV		DPTR, #UART2_Baudrate
	LCALL	F_SetTimer2Baudrate

	ANL		S2CON, #NOT (1 SHL 7)	; 8λ����, 1λ��ʼλ, 1λֹͣλ, ��У��
	ORL		S2CON, #(1 SHL 4)		; �������
	ORL		IE2, #1					; �����ж�
	ANL		P_SW2, #NOT 1	; �л��� P1.0 P1.1
;	ORL		P_SW2, #1		; �л��� P4.6 P4.7

	CLR		A
	MOV		TX2_read, A;
	MOV		RX2_write, A;
	CLR		B_TX2_busy
L_UART2_NotUseT2:
	RET
	
;========================================================================
; ����: F_UART3_config
; ����: UART3��ʼ��������
; ����: ACC: ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer3��������.
; ����: none.
; �汾: VER1.0
; ����: 2014-11-28
; ��ע: 
;========================================================================
F_UART3_config:
	CJNE	A, #2, L_UART3_NotUseT2
	ANL		S3CON, #NOT (1 SHL 6)	; BRT select Timer2		������ʹ��Timer2����
	MOV		DPTR, #UART3_Baudrate
	LCALL	F_SetTimer2Baudrate
	SJMP	L_SetUART3

L_UART3_NotUseT2:
	ORL		S3CON, # (1 SHL 6);	//BRT select Timer3		������ʹ��Timer3����
	ANL		T4T3M, #0xF0;		//ֹͣ����, �������λ
	ANL		IE2,   #NOT (1 SHL 5);	//��ֹ�ж�
	ORL		T4T3M, #(1 SHL 1);	//1T
	ANL		T4T3M, #NOT (1 SHL 2);	//��ʱ
	ANL		T4T3M, #NOT  1;		//�����ʱ��
	MOV		T3H,   #HIGH UART3_Baudrate
	MOV		T3L,   #LOW  UART3_Baudrate
	ORL		T4T3M, #(1 SHL 3);	//��ʼ����

L_SetUART3:	
	ANL		S3CON, #NOT  (1<<5);	//��ֹ���ͨѶ��ʽ
	ANL		S3CON, #NOT  (1<<7);	// 8λ����, 1λ��ʼλ, 1λֹͣλ, ��У��
	ORL		IE2,   # (1 SHL 3);	//�����ж�
	ORL		S3CON, # (1 SHL 4);	//�������
	ANL		P_SW2, #NOT  2;		//�л��� P0.0 P0.1
;	ORL		P_SW2, # 2;			//�л��� P5.0 P5.1

	CLR		A
	MOV		TX3_read, A;
	MOV		RX3_write, A;
	CLR		B_TX3_busy
	RET

;========================================================================
; ����: F_UART4_config
; ����: UART4��ʼ��������
; ����: ACC: ѡ������, 2: ʹ��Timer2��������, ����ֵ: ʹ��Timer4��������.
; ����: none.
; �汾: VER1.0
; ����: 2014-11-28
; ��ע: 
;========================================================================
F_UART4_config:
	CJNE	A, #2, L_UART4_NotUseT2
	ANL		S4CON, #NOT (1 SHL 6)	; BRT select Timer2		������ʹ��Timer2����
	MOV		DPTR, #UART4_Baudrate
	LCALL	F_SetTimer2Baudrate
	SJMP	L_SetUART4

L_UART4_NotUseT2:
	ORL		S4CON, #(1 SHL 6);	//BRT select Timer3		������ʹ��Timer3����
	ANL		T4T3M, #0x0F;		//ֹͣ����, �������λ
	ANL		IE2,   #NOT (1 SHL 6);	//��ֹ�ж�
	ORL		T4T3M, #(1 SHL 5);	//1T
	ANL		T4T3M, #NOT (1 SHL 6);	//��ʱ
	ANL		T4T3M, #NOT (1 SHL 4);		//�����ʱ��
	MOV		T4H,   #HIGH UART4_Baudrate
	MOV		T4L,   #LOW  UART4_Baudrate
	ORL		T4T3M, #(1 SHL 7);	//��ʼ����
L_SetUART4:	
	ANL		S4CON, #NOT  (1<<5);	//��ֹ���ͨѶ��ʽ
	ANL		S4CON, #NOT  (1<<7);	// 8λ����, 1λ��ʼλ, 1λֹͣλ, ��У��
	ORL		IE2,   # (1 SHL 4);	//�����ж�
	ORL		S4CON, # (1 SHL 4);	//�������
	ANL		P_SW2, #NOT  4;		//�л��� P0.2 P0.3
;	ORL		P_SW2, # 4;			//�л��� P5.2 P5.3

	CLR		A
	MOV		TX4_read, A;
	MOV		RX4_write, A;
	CLR		B_TX4_busy
	RET

F_GetWriteAddress:
	ADD		A, DPL
	MOV		DPL, A
	MOV		A, DPH
	ADDC	A, #0
	MOV		DPH, A
	RET


;********************* UART1�жϺ���************************
F_UART1_Interrupt:
	PUSH	PSW
	PUSH	ACC
	PUSH	DPH
	PUSH	DPL
	
	JNB		RI, L_QuitUartRx1
	CLR		RI
	MOV		DPTR, #RX1_Buffer
	MOV		A, RX1_write
	LCALL	F_GetWriteAddress
	MOV		A, SBUF
	MOVX	@DPTR, A	;����һ���ֽ�
	INC		RX1_write
	MOV		A, RX1_write
	CJNE	A, #RX1_Length, L_QuitUartRx1
	MOV		RX1_write, #0		; �����������
L_QuitUartRx1:

	JNB		TI, L_QuitUartTx1
	CLR		TI
	CLR		B_TX1_Busy		; �������æ��־
L_QuitUartTx1:

	POP		DPL
	POP		DPH
	POP		ACC
	POP		PSW
	RETI


;********************* UART2�жϺ���************************
F_UART2_Interrupt:
	PUSH	PSW
	PUSH	ACC
	PUSH	DPH
	PUSH	DPL
	
	MOV		A, S2CON
	JNB		ACC.0, L_QuitUartRx2
	ANL		S2CON, #NOT 1;
	MOV		DPTR, #RX2_Buffer
	MOV		A, RX2_write
	LCALL	F_GetWriteAddress
	MOV		A, S2BUF
	MOVX	@DPTR, A	;����һ���ֽ�
	INC		RX2_write
	MOV		A, RX2_write
	CJNE	A, #RX2_Length, L_QuitUartRx2
	MOV		RX2_write, #0		; �����������
L_QuitUartRx2:

	MOV		A, S2CON
	JNB		ACC.1, L_QuitUartTx2
	ANL		S2CON, #NOT 2;
	CLR		B_TX2_Busy		; �������æ��־
L_QuitUartTx2:

	POP		DPL
	POP		DPH
	POP		ACC
	POP		PSW
	RETI

;********************* UART3�жϺ���************************
F_UART3_Interrupt:
	PUSH	PSW
	PUSH	ACC
	PUSH	DPH
	PUSH	DPL
	
	MOV		A, S3CON
	JNB		ACC.0, L_QuitUartRx3
	ANL		S3CON, #NOT 1;
	MOV		DPTR, #RX3_Buffer
	MOV		A, RX3_write
	LCALL	F_GetWriteAddress
	MOV		A, S3BUF
	MOVX	@DPTR, A	;����һ���ֽ�
	INC		RX3_write
	MOV		A, RX3_write
	CJNE	A, #RX3_Length, L_QuitUartRx3
	MOV		RX3_write, #0		; �����������
L_QuitUartRx3:

	MOV		A, S3CON
	JNB		ACC.1, L_QuitUartTx3
	ANL		S3CON, #NOT 2;
	CLR		B_TX3_Busy		; �������æ��־
L_QuitUartTx3:

	POP		DPL
	POP		DPH
	POP		ACC
	POP		PSW
	RETI


;********************* UART4�жϺ���************************
F_UART4_Interrupt:
	PUSH	PSW
	PUSH	ACC
	PUSH	DPH
	PUSH	DPL
	
	MOV		A, S4CON
	JNB		ACC.0, L_QuitUartRx4
	ANL		S4CON, #NOT 1;
	MOV		DPTR, #RX4_Buffer
	MOV		A, RX4_write
	LCALL	F_GetWriteAddress
	MOV		A, S4BUF
	MOVX	@DPTR, A	;����һ���ֽ�
	INC		RX4_write
	MOV		A, RX4_write
	CJNE	A, #RX4_Length, L_QuitUartRx4
	MOV		RX4_write, #0		; �����������
L_QuitUartRx4:

	MOV		A, S4CON
	JNB		ACC.1, L_QuitUartTx4
	ANL		S4CON, #NOT 2;
	CLR		B_TX4_Busy		; �������æ��־
L_QuitUartTx4:

	POP		DPL
	POP		DPH
	POP		ACC
	POP		PSW
	RETI



	END




