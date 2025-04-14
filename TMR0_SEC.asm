	CONT	EQU	0X20		;La variable se guarda en CONT guarda en la dirección 0x20
	CONT1	EQU	0X21		;La variable se guarda en CONT1 guarda en la dirección 0x21
	ORG	0X00			;Vector reset
	GOTO	CONFIGURAR
	ORG	0X04			;Vector de interrupción
	GOTO	INT_TMR0
;Configuracion de registros
CONFIGURAR:
	BSF	STATUS,RP0
	CLRF	TRISD
	BSF	OPTION_REG,PS0		;Prescaler 1:256
	BSF	OPTION_REG,PS1
	BSF	OPTION_REG,PS2
	BCF	OPTION_REG,PSA		;Asignado al TMR0
	BCF	OPTION_REG,T0CS		;Fuente de reloj interna
	BCF	STATUS,RP0
	BSF	INTCON,T0IE		;Interrupcion TMR0 activado
	BSF	INTCON,GIE		;Interrupcion global activado
	MOVLW	D'61'			;Valor de carga para 50ms
	MOVWF	TMR0
	CLRF	CONT
	CLRF	CONT1
	CLRF	PORTD
;------Programa principal-------
MAIN:
	GOTO	MAIN
;-------------------------------

;Subrutina de interrupocion TMR0
INT_TMR0:
	BCF	INTCON,T0IF		;Limpiar la bandera de interrupcion del TMR0
	MOVLW	D'61'			;Valor de carga para 50ms
	MOVWF	TMR0
	INCF	CONT,F			;Incrementar la variable CONT y que se guarde el mismo registro
	MOVLW	D'9'			;Repite 9 veces para obtener 450ms
	SUBWF	CONT,W  		;w=CONT-W
	BTFSS	STATUS,Z		;Realiza un salto si z=1
	RETFIE				;z=0 sale de la interrupcion

	MOVLW	D'10'			;z=0, Valor limite de datos en la TABLA
	SUBWF	CONT1,W			;Realiza una resta W=CONT-W
	BTFSS	STATUS,Z		;Realiza un salto si z=1
	GOTO	TOMAR_VALOR		;z=0, ir a la etiqueta TOMAR_VALOR
	GOTO	LIMPIAR			;z=1, ir a la etiqueta LIMPIAR
TOMAR_VALOR:
	MOVF	CONT1,W			;Mover el registro CONT1 al registro de trabajo 
	CALL	TABLA			;LLamar a la tabla con un valor en el registro de trabajo
	MOVWF	PORTD			;Vuelve de la subrutina con un valor en el registro de trabajo
	INCF	CONT1,F			;Incrementa la variable CONT1, y lo guarda en el mismos registro
	CLRF	CONT			;Limpiar el registro CONT
	RETFIE				;Salir de la subrutina interruocion
LIMPIAR					;Limpiar refgistros
	CLRF	CONT1
	CLRF	CONT
	CLRF	PORTD
	RETFIE
;Tabla de datos
TABLA:
	ADDWF	PCL,F
	RETLW	0X01
	RETLW	0X02
	RETLW	0X03
	RETLW	0X04
	RETLW	0X05
	RETLW	0X06
	RETLW	0X07
	RETLW	0X08
	RETLW	0X09
	RETLW	0X0A
	END
