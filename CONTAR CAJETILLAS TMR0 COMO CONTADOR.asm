;AUTOR:Calle Condori Rodrigo
;El siguiente programa se configura el TMR0 como contador, el limite maximo de este
;contador es de 255 luego se reinicia el contador.
;EJERCICIO 1
;Realizar un contador de cajetillas de cigarro, utilizando el módulo TMR0 como contador.
    __CONFIG _XT_OSC & _WDTE_OFF & _PWRTE_ON & _CP_OFF & _BOREN_OFF & _LVP_OFF
    LIST  P=16F877A
    INCLUDE <P16F877A.INC>

    CBLOCK 0X20
    DECE
    UNIDAD
    DECENA
    CENTENA
    CONTADOR1
    CONTADOR2
    CONTADOR3
    ENDC
 
    #DEFINE  SENSOR1   PORTA,4
    #DEFINE  DISPLAY1  PORTA,0
    #DEFINE  DISPLAY2  PORTA,1
    #DEFINE  DISPLAY3  PORTA,2
RESET_PIC:
                 ORG    0X00
                 GOTO   CONFIGURACION

CONFIGURACION:
                 BCF    STATUS,RP0
                 BCF    STATUS,RP1
                 CLRF   PORTA
                 BSF    STATUS,RP0
                 MOVLW  0X06
                 MOVWF  ADCON1
                 MOVLW  B'111000'
                 MOVWF  TRISA
                 CLRF   TRISB   
                 MOVLW  B'10101000'
                 MOVWF  OPTION_REG
                 BCF    STATUS,RP0
                 CLRF   TMR0
                 CLRF   PORTA
                 CLRF   PORTB
                 CLRF   UNIDAD
                 CLRF   DECENA
                 CLRF   CENTENA
                 CLRF   DECE
MAIN:
                 CALL   VISUALIZAR                  
                 CALL   INTERNO
                 GOTO   MAIN

VISUALIZAR:
;VISUALIZA UNIDADES
                 BSF    DISPLAY1
                 BCF    DISPLAY2
                 BCF    DISPLAY3
                 MOVF   UNIDAD,W
                 CALL   TABLA
                 MOVWF  PORTB
                 MOVLW  .2           ;RETARDO DE 5ms
                 CALL   RETARDO  
;VISUALIZA DECENA
                 BCF    DISPLAY1
                 BSF    DISPLAY2
                 BCF    DISPLAY3
                 MOVF   DECENA,W
                 CALL   TABLA
                 MOVWF  PORTB
                 MOVLW  .2           ;RETARDO DE 5ms
                 CALL   RETARDO
;VISUALIZAR CENTENA
                 BCF    DISPLAY1
                 BCF    DISPLAY2
                 BSF    DISPLAY3
                 MOVF   CENTENA,W
                 CALL   TABLA
                 MOVWF  PORTB
                 MOVLW  .2           ;RETARDO DE 5ms
                 CALL   RETARDO
                 RETURN
TABLA:
                 ADDWF  PCL,F
                 RETLW  0X3F
                 RETLW  0X06
                 RETLW  0X5B
                 RETLW  0X4F
                 RETLW  0X66
                 RETLW  0X6D
                 RETLW  0X7D
                 RETLW  0X07
                 RETLW  0X7F
                 RETLW  0X6F

;INTERNO:
                 ;MOVLW  .255
                 ;SUBWF  TMR0,W
                 ;BTFSS  STATUS,Z
                 ;GOTO   SEPARAR_DIGITO
RESET_LIMPIAR:
                 CLRF   TMR0
                 CLRF   UNIDAD
                 CLRF   DECENA
                 CLRF   CENTENA
                 CLRF   DECE
                 RETURN 
INTERNO:
SEPARAR_DIGITO:
                 MOVF   TMR0,W
                 MOVWF  UNIDAD
                 MOVF   DECE,W             ;MOVEMOS EL REGISTRO DECE(REGISTRO AUXILIAR) A 'W'. EL REGISTRO DECE PRIMERO SERÁ DECE=0,LUEGO DECE=10, DECE=20, SE INCRMENTARÁ DE 10 EN 10 
                 SUBWF  UNIDAD,F           ;SE RESTA UNIDAD=UNIDAD-DECE
SEPARO_UNIDAD:                             ;EL REGISTRO CONTADOR SE SEPARA EN UNIDAD Y DECENA
                 MOVLW  .10                ;LIMITE DE LA UNIDAD TIENE QUE ESTAR EL EL RANGO DE 0 A 10
                 SUBWF  UNIDAD,W           ;S
                 BTFSS  STATUS,Z
                 RETURN

INCREMENTAR_DECE:
                 MOVLW  .10                ;ESTE VALOR NOS PERMITIRA CONFIGURAR LAS UNIDADES SE CARGA EN 'W' 
                 ADDWF  DECE,F             ;SUMAR EL REGISTRO 'W' AL REGISTRO 'DECE',ESTE REGISTRO SE INCREMENTA DE 10 EN 10
                 INCF   DECENA,F           ;INCREMETAMOS A UNA UNIDAD EL REGISTRO DECENA
                 MOVLW  .10                ;VERIFICAR EL LIMITE DE LA DECENA
                 SUBWF  DECENA,W           ;RESTANDO W=DECENA-10
                 BTFSS  STATUS,Z           ;SI ES 0 REALIZARA UN SALTO
                 GOTO   LIMPIAR_UNIDADES   ;NO ES 0 IR A LA ETIQUETA LIMPIAR_UNIDADES
                 CALL   INCREMENTAR_CENTE  ;ES 0 LLAMADA A LA SUBRUTINA 
LIMPIAR_UNIDADES:   
                 CLRF   UNIDAD             ;LIMPIAMOS UNIDAD
                 RETURN
INCREMENTAR_CENTE:
                 CLRF   DECENA
                 INCF   CENTENA,F
				 MOVLW  .2
				 SUBWF	CENTENA,W
				 BTFSS	STATUS,Z
                 RETURN
				 CLRF   CENTENA
				 RETURN

RETARDO:       
                 ;MOVLW   .12              ;REMPLAZAR LOS VALORES P,M,N CALCULADO EN FORMA DECIMAL(EJEM: MOVLW  .33)
                 MOVWF  CONTADOR3
REPETICION3:  
                 MOVLW  .20
                 MOVWF  CONTADOR2
REPETICION2:
                 MOVLW  .33
                 MOVWF  CONTADOR1
REPETICION1:
                 DECFSZ CONTADOR1,1
                 GOTO   REPETICION1
                 DECFSZ CONTADOR2,1
                 GOTO   REPETICION2
                 DECFSZ CONTADOR3,1
                 GOTO   REPETICION3        
                 RETURN
                 END