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

; ��������ʾ3����ʱ����ʹ��, �����̾�ʹ��16λ�Զ���װ.

; ����ʱ, ѡ��ʱ�� 24MHZ (�û��������޸�Ƶ��).

; ��ʱ��0��16λ�Զ���װ, �ж�Ƶ��Ϊ1000HZ���жϺ�����P1.7ȡ�����500HZ�����ź�.

; ��ʱ��1��16λ�Զ���װ, �ж�Ƶ��Ϊ2000HZ���жϺ�����P1.6ȡ�����1000HZ�����ź�.

; ��ʱ��2��16λ�Զ���װ, �ж�Ƶ��Ϊ3000HZ���жϺ�����P4.7ȡ�����1500HZ�����ź�.

;******************************************/

;/****************************** �û������ ***********************************/


STACK_POIRTER	EQU		0D0H	;��ջ��ʼ��ַ


;*******************************************************************
;*******************************************************************
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

AUXR	DATA	08EH
INT_CLKO DATA   0x8F
IE2		DATA	0xAF
P4		DATA	0xC0
T2H		DATA	0xD6
T2L		DATA	0xD7



;*******************************************************************
;*******************************************************************
		ORG		0000H				;reset
		LJMP	F_Main

		ORG		000BH				;1  Timer0 interrupt
		LJMP	F_Timer0_Interrupt

		ORG		001BH				;3  Timer1 interrupt
		LJMP	F_Timer1_Interrupt

		ORG		0063H				;12  Timer2 interrupt
		LJMP	F_Timer2_Interrupt

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

	LCALL	F_Timer0_init
	LCALL	F_Timer1_init
	LCALL	F_Timer2_init
	SETB	EA
	

;=================== ��ѭ�� ==================================
L_Main_Loop:

	LJMP	L_Main_Loop

;**********************************************/

;========================================================================
; ����: F_Timer0_init
; ����: timer0��ʼ������.
; ����: none.
; ����: none.
; �汾: V1.0, 2015-1-12
;========================================================================
F_Timer0_init:
	CLR		TR0	; ֹͣ����
	SETB	ET0	; �����ж�
;	SETB	PT0	; �����ȼ��ж�
	ANL		TMOD, #NOT 0x03		;
	ORL		TMOD, #0			; ����ģʽ, 0: 16λ�Զ���װ, 1: 16λ��ʱ/����, 2: 8λ�Զ���װ, 3: 16λ�Զ���װ, ���������ж�
;	ORL		TMOD, #0x04			; ����������Ƶ
	ANL		TMOD, #NOT 0x04		; ��ʱ
;	ORL		INT_CLKO, #0x01		; ���ʱ��
	ANL		INT_CLKO, #NOT 0x01	; �����ʱ��

;	ANL		AUXR, #NOT 0x80		; 12T mode
	ORL		AUXR, #0x80			; 1T mode
	MOV		TH0, #HIGH (-24000)	; - 24000000 / 1000
	MOV		TL0, #LOW  (-24000)	;
	SETB	TR0	; ��ʼ����
	RET


;========================================================================
; ����: F_Timer1_init
; ����: timer1��ʼ������.
; ����: none.
; ����: none.
; �汾: V1.0, 2015-1-12
;========================================================================
F_Timer1_init:
	CLR		TR1	; ֹͣ����
	SETB	ET1	; �����ж�
;	SETB	PT1	; �����ȼ��ж�
	ANL		TMOD, #NOT 0x30		;
	ORL		TMOD, #(0 SHL 4)	; ����ģʽ, 0: 16λ�Զ���װ, 1: 16λ��ʱ/����, 2: 8λ�Զ���װ, 3: 16λ�Զ���װ, ���������ж�
;	ORL		TMOD, #0x40			; ����������Ƶ
	ANL		TMOD, #NOT 0x40		; ��ʱ
;	ORL		INT_CLKO, #0x02		; ���ʱ��
	ANL		INT_CLKO, #NOT 0x02	; �����ʱ��

;	ANL		AUXR, #NOT 0x40		; 12T mode
	ORL		AUXR, #0x40			; 1T mode
	MOV		TH1, #HIGH (-12000)	; - 24000000 / 2000
	MOV		TL1, #LOW  (-12000)	;
	SETB	TR1	; ��ʼ����
	RET

;========================================================================
; ����: F_Timer2_init
; ����: timer2��ʼ������.
; ����: none.
; ����: none.
; �汾: V1.0, 2015-1-12
;========================================================================
F_Timer2_init:
	ANL		AUXR, #NOT 0x1c		; ֹͣ����, ��ʱģʽ, 12Tģʽ

;	ANL		IE2, #NOT (1 SHL 2)	; ��ֹ�ж�
	ORL		IE2, #(1 SHL 2)		; �����ж�
;	ORL		INT_CLKO, #0x04		; ���ʱ��
	ANL		INT_CLKO, #NOT 0x04	; �����ʱ��

;	ORL		AUXR, #(1 SHL 3)	; ����������Ƶ
;	ORL		INT_CLKO, #0x02		; ���ʱ��
	ANL		INT_CLKO, #NOT 0x02	; �����ʱ��

	ORL		AUXR, #(1 SHL 2)	; 1T mode
	MOV		T2H, #HIGH (-8000)	; - 24000000 / 3000
	MOV		T2L, #LOW  (-8000)	;

	ORL		AUXR, #(1 SHL 4)	; ��ʼ����
	RET


;**************** �жϺ��� ***************************************************
F_Timer0_Interrupt:	;Timer0 1ms�жϺ���
	PUSH	PSW		;PSW��ջ
	PUSH	ACC		;ACC��ջ

	CPL		P1.7

	POP		ACC		;ACC��ջ
	POP		PSW		;PSW��ջ
	RETI
	
F_Timer1_Interrupt:	;Timer1 1ms�жϺ���
	PUSH	PSW		;PSW��ջ
	PUSH	ACC		;ACC��ջ

	CPL		P1.6

	POP		ACC		;ACC��ջ
	POP		PSW		;PSW��ջ
	RETI
	
F_Timer2_Interrupt:	;Timer2 1ms�жϺ���
	PUSH	PSW		;PSW��ջ
	PUSH	ACC		;ACC��ջ

	CPL		P4.7

	POP		ACC		;ACC��ջ
	POP		PSW		;PSW��ջ
	RETI
	


	END



