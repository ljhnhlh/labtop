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

; ��STC��MCU��IO��ʽ����74HC595����8λ����ܡ�

; �û������޸ĺ���ѡ��ʱ��Ƶ��.

; ��ʾЧ��Ϊ: ��ʾ�����, 5���ι��, �ȸ�λ.


;******************************************

;****************************** �û������ ***********************************/

Fosc_KHZ	EQU	22118	;22118KHZ

STACK_POIRTER	EQU		0D0H	; ��ջ��ʼ��ַ

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

WDT_CONTR DATA 0xC1		;Watch-Dog-Timer Control register
;                                      7     6     5      4       3      2   1   0     Reset Value
;                                  WDT_FLAG  -  EN_WDT CLR_WDT IDLE_WDT PS2 PS1 PS0    xx00,0000
D_WDT_FLAG		EQU	(1 SHL 7)
D_EN_WDT		EQU	(1 SHL 5)
D_CLR_WDT		EQU	(1 SHL 4)	;auto clear
D_IDLE_WDT		EQU	(1 SHL 3)	;WDT counter when Idle
D_WDT_SCALE_2	EQU	0
D_WDT_SCALE_4	EQU	1
D_WDT_SCALE_8	EQU	2		;T=393216*N/fo
D_WDT_SCALE_16	EQU	3
D_WDT_SCALE_32	EQU	4
D_WDT_SCALE_64	EQU	5
D_WDT_SCALE_128	EQU	6
D_WDT_SCALE_256	EQU	7
        
;*************	IO�ڶ���	**************/
P_HC595_SER   BIT P4.0	;	//pin 14	SER		data input
P_HC595_RCLK  BIT P5.4	;	//pin 12	RCLk	store (latch) clock
P_HC595_SRCLK BIT P4.3	;	//pin 11	SRCLK	Shift data clock

;*************	���ر�������	**************/
LED8			DATA	30H		;	��ʾ���� 30H ~ 37H
display_index	DATA	38H		;	��ʾλ����

ms_cnt_H 		DATA	39H		; 1000ms ����ֵ
ms_cnt_L		DATA	3AH		;
tes_cnt			DATA	3BH		; �����õļ�������

;*******************************************************************
;*******************************************************************
		ORG		0000H				;reset
		LJMP	F_Main



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
		
	MOV		ms_cnt_H, #HIGH 1000	; ��װ1000ms����ֵ
	MOV		ms_cnt_L, #LOW  1000
	
	MOV		tes_cnt, #0
	MOV		LED8+7, tes_cnt

;=================== ��ѭ�� ==================================
L_MainLoop:
	MOV		A, #1			;��ʱ1ms
	LCALL	F_delay_ms	
	LCALL	F_DisplayScan

	MOV		A, tes_cnt
	CLR		C
	SUBB	A, #6	; if(tes_cnt <= 5)	//5���ι��, ����λ,
	JNC		L_QuitWatchDog
	MOV		WDT_CONTR, #(D_EN_WDT + D_CLR_WDT + D_WDT_SCALE_16)	; ι��
L_QuitWatchDog:

	MOV		A, ms_cnt_L		; if(--ms_cnt == 0)
	CLR		C
	SUBB	A, #1
	MOV		ms_cnt_L, A
	MOV		A, ms_cnt_H
	SUBB	A, #0
	MOV		ms_cnt_H, A
	ORL		A, ms_cnt_L
	JNZ		L_cnt1000_NotZero
	MOV		ms_cnt_H, #HIGH 1000	; ��װ1000ms����ֵ
	MOV		ms_cnt_L, #LOW  1000
	INC		tes_cnt		; ���Լ���+1
	MOV		LED8+7, tes_cnt	;

L_cnt1000_NotZero:
	LJMP	L_MainLoop

;**********************************************/


;========================================================================
; ����: F_delay_ms
; ����: ��ʱ�ӳ���
; ����: ACC: ��ʱms��.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
; ��ע: ����ACCC��PSW��, ���õ���ͨ�üĴ�������ջ
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


;========================================================================
; ����: F_Send_595
; ����: ��HC595����һ���ֽ��ӳ���
; ����: ACC: Ҫ���͵��ֽ�����.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
; ��ע: ����ACCC��PSW��, ���õ���ͨ�üĴ�������ջ
;========================================================================
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

;========================================================================
; ����: F_DisplayScan
; ����: ��ʾɨ���ӳ���
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
; ��ע: ����ACCC��PSW��, ���õ���ͨ�üĴ�������ջ
;========================================================================
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



	END



