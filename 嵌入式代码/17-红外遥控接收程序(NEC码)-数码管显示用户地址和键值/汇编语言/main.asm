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

;������ճ����������г�����������NEC���롣��ѯ��ʽ�� Timer0ʮ��λ�Զ���װ, 100us

;Ӧ�ò��ѯ B_IR_Press��־Ϊ,���ѽ��յ�һ���������IR_code��, 

;���������4λ��ʾ�û���, ���ұ���λ��ʾ����, ��Ϊʮ������.

;******************************************/

;/****************************** �û������ ***********************************/

Fosc_KHZ	EQU	22118	;22118KHZ, �û�ֻ��Ҫ�Ķ����ֵ����Ӧ�Լ�ʵ�ʵ�Ƶ��

STACK_POIRTER	EQU		0D0H	;��ջ��ʼ��ַ

Timer0_Reload	EQU		(65536 - (Fosc_KHZ+5)/10)	; Timer 0 �ж�Ƶ��, 10000��/��

DIS_DOT			EQU		020H
DIS_BLACK		EQU		010H
DIS_			EQU		011H

;*******************************************************************
;*******************************************************************

AUXR      DATA 08EH
P4        DATA 0C0H
P5        DATA 0C8H

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

cnt_1ms			DATA	39H		;

;*************	������ճ����������	**************
P_IR_RX			BIT	P3.6	;��������������IO��

P_IR_RX_temp	BIT	Flag0.1		;�û����ɲ���, Last sample
B_IR_Sync		BIT	Flag0.2		;�û����ɲ���, ���յ�ͬ����־
IR_SampleCnt	DATA	3AH	;�û����ɲ���, ��������
IR_BitCnt		DATA	3BH	;�û����ɲ���, ����λ��
IR_UserH		DATA	3CH	;�û����ɲ���, �û���(��ַ)���ֽ�
IR_UserL		DATA	3DH	;�û����ɲ���, �û���(��ַ)���ֽ�
IR_data			DATA	3EH	;�û����ɲ���, ����ԭ��
IR_DataShit		DATA	3FH	;�û����ɲ���, ������λ

B_IR_Press		BIT	Flag0.3		;�û�ʹ��, ������������
IR_code			DATA	40H	;�û�ʹ��, �������
UserCodeH		DATA	41H	;�û�ʹ��, �û�����ֽ�
UserCodeL		DATA	42H	;�û�ʹ��, �û�����ֽ�

;*********************************


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
	MOV		@R0, #DIS_
	INC		R0
	DJNZ	R2, L_ClearLoop

	MOV		R0, #LED8+4
	MOV		@R0, #DIS_BLACK		;�ϵ�����
	INC		R0
	MOV		@R0, #DIS_BLACK		;�ϵ�����
	
	CLR		TR0
	ORL		AUXR, #(1 SHL 7)	; Timer0_1T();
	ANL		TMOD, #NOT 04H		; Timer0_AsTimer();
	ANL		TMOD, #NOT 03H		; Timer0_16bitAutoReload();
	MOV		TH0, #Timer0_Reload / 256	;Timer0_Load(Timer0_Reload);
	MOV		TL0, #Timer0_Reload MOD 256
	SETB	ET0			; Timer0_InterruptEnable();
	SETB	TR0			; Timer0_Run();
	SETB	EA			; �����ж�
	
	MOV		cnt_1ms, #10

;=====================================================

;=====================================================
L_Main_Loop:

	JNB		B_1ms,  L_Main_Loop		;1msδ��
	CLR		B_1ms
	
	JNB		B_IR_Press, L_Main_Loop	;δ��⵽�յ��������

	CLR		B_IR_Press		;��⵽�յ��������
	MOV		A, UserCodeH
	SWAP	A
	ANL		A, #0FH
	MOV		LED8+0, A		;�û�����ֽڵĸ߰��ֽ�
	MOV		A, UserCodeH
	ANL		A, #0FH
	MOV		LED8+1, A		;�û�����ֽڵĵͰ��ֽ�

	MOV		A, UserCodeL
	SWAP	A
	ANL		A, #0FH
	MOV		LED8+2, A		;�û�����ֽڵĸ߰��ֽ�
	MOV		A, UserCodeL
	ANL		A, #0FH
	MOV		LED8+3, A		;�û�����ֽڵĵͰ��ֽ�
	
	MOV		A, IR_code
	SWAP	A
	ANL		A, #0FH
	MOV		LED8+6, A		;ң�����ݵĸ߰��ֽ�
	MOV		A, IR_code
	ANL		A, #0FH
	MOV		LED8+7, A		;ң�����ݵĵͰ��ֽ�

	LJMP	L_Main_Loop

;**********************************************/





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
	PUSH	AR2		;R2��ջ
	MOV		R2, #8
L_Send_595_Loop:
	RLC		A
	MOV		P_HC595_SER,C
	SETB	P_HC595_SRCLK
	CLR		P_HC595_SRCLK
	DJNZ	R2, L_Send_595_Loop
	POP		AR2		;R2��ջ
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
	PUSH	AR0		;R0 ��ջ
	
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
	POP		AR0		;R0 ��ջ
	POP		DPL		;DPL��ջ
	POP		DPH		;DPH��ջ
	RET


;*******************************************************************
;**************** �жϺ��� ***************************************************

F_Timer0_Interrupt:	;Timer0 1ms�жϺ���
	PUSH	PSW		;PSW��ջ
	PUSH	ACC		;ACC��ջ
	PUSH	AR7		;SampleTime

	LCALL	F_IR_RX_NEC

	DJNZ	cnt_1ms, L_Quit_1ms
	MOV		cnt_1ms, #10
	LCALL	F_DisplayScan	; 1msɨ����ʾһλ
	SETB	B_1ms			; 1ms��־
L_Quit_1ms:

	POP		AR7
	POP		ACC		;ACC��ջ
	POP		PSW		;PSW��ջ
	RETI
	

;*******************************************************************
;*********************** IR Remote Module **************************
;*********************** By  (Coody) 2002-8-24 *********************
;*********************** IR Remote Module **************************
;this programme is used for Receive IR Remote (NEC Code).

;data format: Synchro, AddressH, AddressL, data, /data, (total 32 bit).

;send a frame(85ms), pause 23ms, send synchro of continue frame, pause 94ms

;data rate: 108ms/Frame


;Synchro: low=9ms, high=4.5 / 2.25ms, low=0.5626ms
;Bit0: high=0.5626ms, low=0.5626ms
;Bit1: high=1.6879ms, low=0.5626ms
;frame rate = 108ms ( pause 23 ms or 96 ms)

;******************** �������ʱ��궨��, �û���Ҫ�����޸�	*******************

D_IR_sample			EQU	100					;��ѯʱ����, 100us, �������Ҫ����60us~250us֮��
D_IR_SYNC_MAX		EQU	(15000/D_IR_sample)	;SYNC max time
D_IR_SYNC_MIN		EQU	(9700 /D_IR_sample)	;SYNC min time
D_IR_SYNC_DIVIDE	EQU	(12375/D_IR_sample)	;decide data 0 or 1
D_IR_DATA_MAX		EQU	(3000 /D_IR_sample)	;data max time
D_IR_DATA_MIN		EQU	(600  /D_IR_sample)	;data min time
D_IR_DATA_DIVIDE	EQU	(1687 /D_IR_sample)	;decide data 0 or 1
D_IR_BIT_NUMBER		EQU	32					;bit number

;*******************************************************************************************
;**************************** IR RECEIVE MODULE ********************************************

F_IR_RX_NEC:
	INC		IR_SampleCnt		;Sample + 1

	MOV		C, P_IR_RX_temp		;Save Last sample status
	MOV		F0, C
	MOV		C, P_IR_RX			;Read current status
	MOV		P_IR_RX_temp, C

	JNB		F0, L_QuitIrRx				;Pre-sample is high
	JB		P_IR_RX_temp, L_QuitIrRx	;and current sample is low, so is fall edge

	MOV		R7, IR_SampleCnt			;get the sample time
	MOV		IR_SampleCnt, #0			;Clear the sample counter

	MOV		A, R7		; if(SampleTime > D_IR_SYNC_MAX)	B_IR_Sync = 0
	SETB	C
	SUBB	A, #D_IR_SYNC_MAX
	JC		L_IR_RX_1
	CLR		B_IR_Sync		;large than the Maxim SYNC time, then error
	RET
	
L_IR_RX_1:
	MOV		A, R7		; else if(SampleTime >= D_IR_SYNC_MIN)
	CLR		C
	SUBB	A, #D_IR_SYNC_MIN
	JC		L_IR_RX_2

	MOV		A, R7		; else if(SampleTime >= D_IR_SYNC_MIN)
	SUBB	A, #D_IR_SYNC_DIVIDE
	JC		L_QuitIrRx
	SETB	B_IR_Sync			;has received SYNC
	MOV		IR_BitCnt, #D_IR_BIT_NUMBER		;Load bit number
	RET

L_IR_RX_2:
	JNB		B_IR_Sync, L_QuitIrRx	;else if(B_IR_Sync), has received SYNC
	MOV		A, R7		; if(SampleTime > D_IR_DATA_MAX)	B_IR_Sync = 0, data samlpe time too large
	SETB	C
	SUBB	A, #D_IR_DATA_MAX
	JC		L_IR_RX_3
	CLR		B_IR_Sync		;data samlpe time too large
	RET

L_IR_RX_3:
	MOV		A, IR_DataShit		;data shift right 1 bit
	CLR		C
	RRC		A
	MOV		IR_DataShit, A
	
	MOV		A, R7
	CLR		C
	SUBB	A, #D_IR_DATA_DIVIDE
	JC		L_IR_RX_4
	ORL		IR_DataShit, #080H	;if(SampleTime >= D_IR_DATA_DIVIDE)	IR_DataShit |= 0x80;	//devide data 0 or 1
L_IR_RX_4:
	DEC		IR_BitCnt
	MOV		A, IR_BitCnt
	JNZ		L_IR_RX_5			;bit number is over?
	CLR		B_IR_Sync			;Clear SYNC
	MOV		A, IR_DataShit		;if(~IR_DataShit == IR_data)		//�ж�����������
	CPL		A
	XRL		A, IR_data
	JNZ		L_QuitIrRx
	
	MOV		UserCodeH, IR_UserH
	MOV		UserCodeL, IR_UserL
	MOV		IR_code, IR_data
	SETB	B_IR_Press			;������Ч
	RET

L_IR_RX_5:
	MOV		A, IR_BitCnt		;else if((IR_BitCnt & 7)== 0)	one byte receive
	ANL		A, #07H
	JNZ		L_QuitIrRx
	MOV		IR_UserL, IR_UserH		;Save the User code high byte
	MOV		IR_UserH, IR_data		;Save the User code low byte
	MOV		IR_data,  IR_DataShit	;Save the IR data byte
L_QuitIrRx:
	RET


	END



