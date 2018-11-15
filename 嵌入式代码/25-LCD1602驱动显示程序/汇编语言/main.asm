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

;����LCD1602�ַ���.


;��ʾЧ��Ϊ: LCD��ʾʱ��.

;******************************************

Fosc_KHZ	EQU	22118	;22118KHZ

STACK_POIRTER	EQU		0D0H	;��ջ��ʼ����

;*******************************************************************
;*******************************************************************

P4		DATA 0C0H
P5		DATA 0C8H

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

P_HC595_SER   BIT P4.0	;	//pin 14	SER		data input
P_HC595_RCLK  BIT P5.4	;	//pin 12	RCLk	store (latch) clock
P_HC595_SRCLK BIT P4.3	;	//pin 11	SRCLK	Shift data clock


hour	DATA	0x30
minute	DATA	0x31
second	DATA	0x32


;*******************************************************************
;*******************************************************************
		ORG		0000H				;reset
		LJMP	F_Main


TestString1:	DB "---Clock demo---", 0x00

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

	LCALL	F_Initialize_LCD
	MOV		A, #0
	LCALL	F_ClearLine
	MOV		A, #1
	LCALL	F_ClearLine

	ANL		P2M1, #NOT (1 SHL 4)	;P2.4����Ϊ�������
	ORL		P2M0, #    (1 SHL 4)
	SETB	P2.4				;������
	LCALL	F_DisableHC595		;��ֹ��ѧϰ���ϵ�HC595��ʾ��ʡ��

	MOV		R2, #0	;��0��
	MOV		R3, #0	;��0���ַ�
	MOV		DPTR, #TestString1
	LCALL	F_PutString

	MOV		hour, #12	;��ʼ��ʱ��ֵ
	MOV		minute, #0
	MOV		second, #0
	LCALL	F_DisplayRTC
	
	LCALL	F_DisableHC595	;��ֹ��ѧϰ���ϵ�HC595��ʾ��ʡ��

;=================== ��ѭ�� ==================================
L_MainLoop:
	MOV		A, #250			;��ʱ250 ms
	LCALL	F_delay_ms
	MOV		A, #250			;��ʱ250 ms
	LCALL	F_delay_ms
	MOV		A, #250			;��ʱ250 ms
	LCALL	F_delay_ms
	MOV		A, #250			;��ʱ250 ms
	LCALL	F_delay_ms

	LCALL	F_RTC
	LCALL	F_DisplayRTC
	LJMP	L_MainLoop

;*******************************************************************
;*******************************************************************



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
	PUSH	AR2		;��ջR2
	PUSH	AR3		;��ջR3
	PUSH	AR4		;��ջR4

	MOV		R2,A

L_Delay_Nms_Loop1:
	MOV		R3, #HIGH (Fosc_KHZ / 14)
	MOV		R4, #LOW  (Fosc_KHZ / 14)

L_Delay_Nms_Loop2:
	MOV		A, R4	; 1T
	CLR		C		; 1T
	SUBB	A, #1	; 2T
	MOV		R4, A	; 1T
	MOV		A, R3	; 1T
	SUBB	A, #0	; 2T
	MOV		R3, A	; 1T
	ORL		A, R4	; 1T
	JNZ		L_Delay_Nms_Loop2	; 4T
	
	DJNZ	R2, L_Delay_Nms_Loop1

	POP		AR4		;��ջR2
	POP		AR3		;��ջR3
	POP		AR2		;��ջR4
	RET



;========================================================================
; ����: F_DisplayRTC
; ����: ��ʾʱ�Ӻ���
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_DisplayRTC:
	MOV		R2, #1	;��2��
	MOV		R3, #4	;��4���ַ�
	MOV		A, hour
	MOV		B, #10
	DIV		AB
	ADD		A, #'0'			;(2,5,hour / 10 + '0')
	LCALL	F_WriteChar
	INC		R3		;��5���ַ�
	MOV		A, B
	ADD		A, #'0'			;(2,6,hour % 10 +'0')
	LCALL	F_WriteChar
	INC		R3		;��6���ַ�
	MOV		A, #'-'			;(2,7,'-')
	LCALL	F_WriteChar

	INC		R3		;��7���ַ�
	MOV		A, minute
	MOV		B, #10
	DIV		AB
	ADD		A, #'0'			;(2,8,minute / 10 + '0')
	LCALL	F_WriteChar
	INC		R3		;��8���ַ�
	MOV		A, B
	ADD		A, #'0'			;(2,9,minute % 10 +'0')
	LCALL	F_WriteChar
	INC		R3		;��9���ַ�
	MOV		A, #'-'			;(2,10,'-')
	LCALL	F_WriteChar

	INC		R3		;��10���ַ�
	MOV		A, second
	MOV		B, #10
	DIV		AB
	ADD		A, #'0'			;(2,8,second / 10 + '0')
	LCALL	F_WriteChar
	INC		R3		;��11���ַ�
	MOV		A, B
	ADD		A, #'0'			;(2,9,second % 10 +'0')
	LCALL	F_WriteChar
	RET

;========================================================================
; ����: F_RTC
; ����: RTC��ʾ����
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_RTC:
	INC		second
	MOV		A, second
	CLR		C
	SUBB	A, #60
	JNC		$+3
	RET
	MOV		second, #0
	
	INC		minute
	MOV		A, minute
	CLR		C
	SUBB	A, #60
	JNC		$+3
	RET
	MOV		minute, #0
	
	INC		hour
	MOV		A, hour
	CLR		C
	SUBB	A, #24
	JNC		$+3
	RET
	MOV		hour, #0
	RET


;************* LCD1602��س���	*****************************************************/
;8λ���ݷ��ʷ�ʽ	LCD1602		��׼����	������д	2014-2-21

LineLength	EQU	16		;16x2

/*************	Pin define	*****************************************************/

LCD_BUS 	DATA 0x80	;P0--0x80, P1--0x90, P2--0xA0, P3--0xB0

LCD_B7  BIT LCD_BUS.7	;D7 -- Pin 14		LED- -- Pin 16 
LCD_B6  BIT LCD_BUS.6	;D6 -- Pin 13		LED+ -- Pin 15
LCD_B5  BIT LCD_BUS.5	;D5 -- Pin 12		Vo   -- Pin 3
LCD_B4  BIT LCD_BUS.4	;D4 -- Pin 11		VDD  -- Pin 2
LCD_B3  BIT LCD_BUS.3	;D3 -- Pin 10		VSS  -- Pin 1
LCD_B2  BIT LCD_BUS.2	;D2 -- Pin  9
LCD_B1  BIT LCD_BUS.1	;D1 -- Pin  8
LCD_B0  BIT LCD_BUS.0	;D0 -- Pin  7

LCD_ENA	BIT P2.7	;Pin 6
LCD_RW	BIT P2.6	;Pin 5   LCD_RS    R/W   DB7--DB0        FOUNCTION
LCD_RS	BIT P2.5	;Pin 4		0		0	  INPUT      write the command to LCD model
					;			0		1     OUTPUT     read BF and AC pointer from LCD model
					;			1		0     INPUT      write the data to LCD  model
					;			1		1     OUTPUT     read the data from LCD model

;total 2 lines, 16x2= 32
;first line address:  0~15
;second line address: 64~79


C_CLEAR			EQU	0x01	;clear LCD
C_HOME 			EQU	0x02	;cursor go home
C_CUR_L			EQU	0x04	;cursor shift left after input
C_RIGHT			EQU	0x05	;picture shift right after input
C_CUR_R			EQU	0x06	;cursor shift right after input
C_LEFT 			EQU	0x07	;picture shift left after input
C_OFF  			EQU	0x08	;turn off LCD
C_ON   			EQU	0x0C	;turn on  LCD
C_FLASH			EQU	0x0D	;turn on  LCD, flash 
C_CURSOR		EQU	0x0E	;turn on  LCD and cursor
C_FLASH_ALL		EQU	0x0F	;turn on  LCD and cursor, flash
C_CURSOR_LEFT	EQU	0x10	;single cursor shift left
C_CURSOR_RIGHT	EQU	0x10	;single cursor shift right
C_PICTURE_LEFT	EQU	0x10	;single picture shift left
C_PICTURE_RIGHT	EQU	0x10	;single picture shift right
C_BIT8			EQU	0x30	;set the data is 8 bits
C_BIT4			EQU	0x20	;set the data is 4 bits
C_L1DOT7		EQU	0x30	;8 bits,one line 5*7  dots
C_L1DOT10		EQU	0x34	;8 bits,one line 5*10 dots
C_L2DOT7		EQU	0x38	;8 bits,tow lines 5*7 dots
C_4bitL2DOT7	EQU	0x28	;4 bits,tow lines 5*7 dots
C_CGADDRESS0	EQU	0x40	;CGRAM address0 (addr=40H+x)
C_DDADDRESS0	EQU	0x80	;DDRAM address0 (addr=80H+x)


;========================================================================
; ����: F_LCD_DelayNop
; ����: ��ʱ����
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_LCD_DelayNop:
	NOP			;NOP(15)
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	RET

;========================================================================
; ����: F_CheckBusy
; ����: ���æ
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_CheckBusy:			;check the LCD busy or not. With time out
	PUSH	ACC
	PUSH	AR2
	PUSH	AR3
	MOV		R2, #HIGH 10000
	MOV		R3, #LOW  10000

L_CheckBusyLoop:
	JNB		LCD_B7, L_QuitCheckBusy	; 5T
	MOV		A, R3	; 1T
	CLR		C	 	; 1T
	SUBB	A, #1	; 2T
	MOV		R3, A	; 1T
	MOV		A, R2	; 1T
	SUBB	A, #0	; 2T
	MOV		R2, A	; 1T
	ORL		A, R3	; 1T
	JNZ		L_CheckBusyLoop	; 4T
L_QuitCheckBusy:
	POP		AR3
	POP		AR2
	POP		ACC

;	JB		LCD_B7, $	;check the LCD busy or not. Without time out
	RET


;========================================================================
; ����: F_IniSendCMD
; ����: ��ʼ��д����(�����æ)
; ����: ACC: Ҫд������.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_IniSendCMD:
	CLR		LCD_RW
	MOV		LCD_BUS, A
	LCALL	F_LCD_DelayNop
	SETB	LCD_ENA
	LCALL	F_LCD_DelayNop
	CLR		LCD_ENA
	MOV		LCD_BUS, #0xff
	RET

;========================================================================
; ����: F_Write_CMD
; ����: д����(���æ)
; ����: ACC: Ҫд������.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_Write_CMD:
	CLR		LCD_RS
	SETB	LCD_RW
	MOV		LCD_BUS, #0xff
	LCALL	F_LCD_DelayNop
	SETB	LCD_ENA
	LCALL	F_CheckBusy		;check the LCD busy or not.
	CLR		LCD_ENA
	CLR		LCD_RW
	
	MOV		LCD_BUS, A
	LCALL	F_LCD_DelayNop
	SETB	LCD_ENA
	LCALL	F_LCD_DelayNop
	CLR		LCD_ENA
	MOV		LCD_BUS, #0xff
	RET

;========================================================================
; ����: F_Write_DIS_Data
; ����: д��ʾ����
; ����: ACC: Ҫд������.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_Write_DIS_Data:
	CLR		LCD_RS
	SETB	LCD_RW

	MOV		LCD_BUS, #0xff
	LCALL	F_LCD_DelayNop
	SETB	LCD_ENA
	LCALL	F_CheckBusy		;check the LCD busy or not.
	CLR		LCD_ENA
	CLR		LCD_RW
	SETB	LCD_RS

	MOV		LCD_BUS, A
	LCALL	F_LCD_DelayNop
	SETB	LCD_ENA
	LCALL	F_LCD_DelayNop
	CLR		LCD_ENA
	MOV		LCD_BUS, #0xff
	RET


;========================================================================
; ����: F_Initialize_LCD
; ����: ��ʼ��LCD����
; ����: none.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_Initialize_LCD:
	SETB	LCD_ENA = 0;
	SETB	LCD_RS  = 0;
	SETB	LCD_RW  = 0;

	MOV		A, #100
	LCALL	F_delay_ms
	MOV		A, #C_BIT8		;set the data is 8 bits
	LCALL	F_IniSendCMD

	MOV		A, #10
	LCALL	F_delay_ms
	MOV		A, #C_L2DOT7	;tow lines 5*7 dots
	LCALL	F_Write_CMD

	MOV		A, #10
	LCALL	F_delay_ms
	MOV		A, #C_CLEAR
	LCALL	F_Write_CMD
	MOV		A, #C_CUR_R		;Curror Shift Right
	LCALL	F_Write_CMD
	MOV		A, #C_ON		;turn on  LCD
	LCALL	F_Write_CMD
	RET


;========================================================================
; ����: F_ClearLine
; ����: ���1��
; ����: ACC: ��(0��1)
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_ClearLine:
	MOV		C, ACC.0
	MOV		ACC.6, C
	ANL		A, #0x40
	ORL		A, #0x80
	LCALL	F_Write_CMD		;Write_CMD(0x80)

	PUSH	AR2
	MOV		R2, #LineLength
L_ClearLine_Loop:
	MOV		A, #' '
	LCALL	F_Write_DIS_Data
	DJNZ	R2, L_ClearLine_Loop
	POP		AR2
	RET


;========================================================================
; ����: F_WriteChar
; ����: ָ���С��к��ַ�, дһ���ַ�
; ����: R2: ��(0��1),  R3: �ڼ����ַ�(0~15),  ACC: Ҫд���ַ�.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_WriteChar:
	PUSH	ACC

	MOV		A, R2
	MOV		C, ACC.0
	MOV		ACC.6, C
	ANL		A, #0x40
	ORL		A, #0x80
	ADD		A, R3
	LCALL	F_Write_CMD		;Write_CMD(0x80)

	POP		ACC
	LCALL	F_Write_DIS_Data
	RET

;========================================================================
; ����: F_PutString
; ����: дһ���ַ�����ָ���С��к��ַ����׵�ַ
; ����: R2: ��(0��1),  R3: �ڼ����ַ�(0~15),  DPTR: Ҫд���ַ����׵�ַ.
; ����: none.
; �汾: VER1.0
; ����: 2013-4-1
;========================================================================
F_PutString:
	MOV		A, R2
	MOV		C, ACC.0
	MOV		ACC.6, C
	ANL		A, #0x40
	ORL		A, #0x80
	ADD		A, R3
	LCALL	F_Write_CMD		;Write_CMD(0x80)
L_PutString_Loop:
	CLR		A
	MOVC	A, @A+DPTR
	JZ		L_QuitPutString		;����ֹͣ��0����
	LCALL	F_Write_DIS_Data
	INC		DPTR
	INC		R3
	MOV		A, R3
	CJNE	A, #LineLength, L_PutString_Loop
L_QuitPutString:
	RET

;******************** LCD20 Module END ***************************

	END



