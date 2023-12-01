.model small

.stack 1000H

.data

LOGO    db "            _                 _     _   "
        db "           | |               (_)   | |  "
        db "   __ _ ___| |_ ___ _ __ ___  _  __| |  "
        db "  / _` / __| __/ _ \ '__/ _ \| |/ _` |  "
        db " | (_| \__ \ ||  __/ | | (_) | | (_| |  "
        db "  \__,_|___/\__\___|_|  \___/|_|\__,_|  "
        db "           \ \ /\ / / _` | | | |        "
        db "            \ V  V / (_| | |_| |        "
        db "             \_/\_/ \__,_|\__, |        "
        db "                           __/ |        "
        db "                          |___/         ", '$'
      
TEXTO_JOGAR db "                  JOGAR                 ", "$"

TEXTO_SAIR db "                  SAIR                  ", "$"

TEXTO_JOGAR_SELECIONADO db "                [ JOGAR ]               ", "$"

TEXTO_SAIR_SELECIONADO db "                [ SAIR ]                ", "$"

OPCAO_MENU_SELECIONADA db 0 ;0 = JOGAR, 1 = SAIR

SETA_CIMA     EQU 72
SETA_BAIXO    EQU 80
SETA_ESQUERDA EQU 75
SETA_DIREITA  EQU 77
BOTAO_ENTER   EQU 28

POSICAO_X_NAVE dw 160 ; Posi??o inicial X da nave
POSICAO_Y_NAVE dw 100 ; Posi??o inicial Y da nave

POSICAO_X_NAVE_ANTERIOR dw 0
POSICAO_Y_NAVE_ANTERIOR dw 0

NAVE db 0FH,0FH,0FH,0FH,0FH,0CH,0CH,0CH,0,0,0FH,0FH,0FH,0FH,0FH,0,0,0,0,0,0,0FH,0FH,0FH,0,0,0,0,0,0,0,0CH,0FH,0FH,0FH,0FH,0FH,0FH,0,0,0,0,0CH,0FH,0EH,0EH,0FH,0FH,0FH,0FH,0,0,0CH,0FH,0EH,0EH,0FH,0FH,0FH,0FH,0,0CH,0FH,0FH,0FH,0FH,0FH,0FH,0,0,0,0FH,0FH,0FH,0,0,0,0,0,0,0FH,0FH,0FH,0FH,0FH,0,0,0,0,0,0FH,0FH,0FH,0FH,0FH,0CH,0CH,0CH,0,0

METEORO db  0,0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,0,0,0,0,7,7,7,7,8,8,7,7,7,7,7,7,7,7,8,8,7,7,7,7,0,0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,0,0,0,0

VIDA db 0,0,0,0,4,4,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0,4,4,0,0,0,0,4,4,4,4,0CH,0CH,4,4,4,4,4,4,4,4,0CH,0CH,4,4,4,4,0,0,0,0,4,4,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0,4,4,0,0,0,0

ESCUDO db   0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0,0,2,2,2,2,0EH,0EH,2,2,2,2,2,2,2,2,0EH,0EH,2,2,2,2,0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0,0

;controladores jogo
NRO_VIDAS db 5
RESTANTE_TEMPO dw 30  
NIVEL db 1
TEMPO_DECORRIDO dw 0


; 50.000 ms
TEMPO_CX dw 0H
TEMPO_DX dw 0C350H
      
.code

CALC_STRING_LENGTH proc
    push SI
    xor CX, CX
  
    STRLEN_LACO:    
        cmp byte ptr [SI],'$'
        je STRLEN_FIM
        inc CX
        inc SI
        jmp STRLEN_LACO

    STRLEN_FIM:
        pop SI
        ret
endp

; Escreve uma string localizada em SI na linha especificada em DH
; Escreve com a cor especificada em BL
ESCREVE_STRING proc
    push AX
    push SI
    push DI
    push BX
    push DX

    mov AX, DS
    mov ES, AX
    mov AH, 13H
    mov AL, 1
    mov BH, 0
    call CALC_STRING_LENGTH
    mov DL, 0
    mov BP, SI
    int 10H

    pop DX
    pop BX
    pop DI
    pop SI
    pop AX
    ret
endp

MOSTRA_OPCOES_BASE proc ; Mostra as opcoes do menu limpas
    push AX
    push SI
    push DI
    push BX
    push DX

    mov DH, 20
    mov BL, 15 ;branco
    mov SI, offset TEXTO_JOGAR
    call ESCREVE_STRING
    
    mov DH, 22
    mov BL, 15 
    mov SI, offset TEXTO_SAIR
    call ESCREVE_STRING

    pop DX
    pop BX
    pop DI
    pop SI
    pop AX
    ret
endp


ATUALIZA_MENU proc
    push AX
    push SI
    push DI
    push BX
    push DX
    
    call MOSTRA_OPCOES_BASE
    
    cmp OPCAO_MENU_SELECIONADA, 0
    je OPCAO_0
    
    mov DH, 22
    mov BL, 15 
    mov SI, offset TEXTO_SAIR_SELECIONADO
    call ESCREVE_STRING
    jmp ATUALIZA_MENU_FIM
    
    OPCAO_0:
        mov DH, 20
        mov BL, 15 ;branco
        mov SI, offset TEXTO_JOGAR_SELECIONADO
        call ESCREVE_STRING
        
     ATUALIZA_MENU_FIM:
        pop DX
        pop BX
        pop DI
        pop SI
        pop AX
     
        ret
endp

MOSTRA_INTRO proc ; Mostra tela inicial do jogo
    push AX
    push SI
    push DI
    push BX
    push DX

    mov DH, 2
    mov BL, 2 ;verde
    mov SI, offset LOGO
    call ESCREVE_STRING
    
    mov AX, 40076
    mov SI, offset NAVE
    call DESENHA_ELEMENTO_10x10
    
    mov AX, 40122
    mov SI, offset METEORO
    call DESENHA_ELEMENTO_10x10
    
    mov AX, 40168
    mov SI, offset VIDA
    call DESENHA_ELEMENTO_10x10
    
    mov AX, 40214
    mov SI, offset ESCUDO
    call DESENHA_ELEMENTO_10x10

    pop DX
    pop BX
    pop DI
    pop SI
    pop AX
    ret
endp


MODO_VIDEO proc
    push AX

    mov AX, 0A000h
    mov ES, AX

    mov AX,0013h
    int 10H

    pop AX
    ret
endp

LER_TECLA proc
    mov AH, 0
    int 16H
    ret
endp

SELECIONA_OPCAO_MENU proc
    push AX
    
    LOOP_OPCAO_MENU:
        call LER_TECLA

    cmp AH, SETA_CIMA
    jne TECLA_BAIXO

    mov OPCAO_MENU_SELECIONADA, 0
    call ATUALIZA_MENU

    TECLA_BAIXO:
        cmp AH, SETA_BAIXO
        jne TECLA_ENTER

        mov OPCAO_MENU_SELECIONADA, 1
        call ATUALIZA_MENU

    TECLA_ENTER:
        cmp AH, BOTAO_ENTER
        jne LOOP_OPCAO_MENU

    pop AX
    ret
endp

; BX = linha
; CX = cor
PINTA_LINHA proc
    push AX
    push DI
    push BX
    push CX
    push DX
    
    mov DI, BX
    mov AX, 320
    
    mul DI
    mov DI, AX
    
    xor AX, AX
    mov AX, CX
    
    xor CX, CX
    mov CX, 320 ;largura tela
    
    LOOP_PINTA_PIXEL:
        stosb
        loop LOOP_PINTA_PIXEL
    
    FIM_PINTA_LINHA:
        pop DX    
        pop CX
        pop BX
        pop DI
        pop AX
        
    ret
endp

;desenha qualquer elemento de 10x10
;AX = coordenada inicial -> esquerda superior
;SI = offset do array
DESENHA_ELEMENTO_10x10 proc
    push AX
    push SI
    push DI
    push BX
    push DX
    
    mov DI, AX ;coordenada

    mov BX, 10
    LOOP_COLUNAS:
        mov CX, 10
        
        rep movsb        
        
        dec BX
        add DI, 310 ;pular linha (320px - 10px)
        
        cmp BX, 0
        jne LOOP_COLUNAS
    
    pop DX
    pop BX
    pop DI
    pop SI
    pop AX
    ret
endp

; Desenha sequencialmente um numero de pixels na determinada cor
; AX = coordenda inicial
; BX = cor
; DX = quantidade pixels
DESENHA_PIXELS proc
    push CX
    push AX
    push DI

    mov DI, AX
    mov CX, DX
    
    mov AX, BX
    rep stosb
    
    pop DI
    pop AX
    pop CX
    ret
endp

DESENHA_INTERFACE proc
    push AX
    push BX
    push DX
    push CX
    
    ;barra amarela
    mov AX, 57600
    mov BX, 0EH
    mov DX, 6400 ;20linhas
    call DESENHA_PIXELS
    
    ;quadrado vermelho
    mov CX, 10
    mov BX, 4
    mov AX, 59355
    mov DX, 10
    
    LOOP_QUADRADO:
        call DESENHA_PIXELS
        add AX, 320 ;pula 1 linha
        loop LOOP_QUADRADO
        
    call ATUALIZA_BARRA_VIDA
    call ATUALIZA_BARRA_TEMPO
    
    pop CX
    pop DX
    pop BX
    pop AX
    ret
endp



; DX = quantidade para atualizar
; BX = cor da barra
; AX = pixels coordenada inicial
ATUALIZAR_BARRA_STATUS proc
    push CX
    push DX    
    push BX
    push AX
    
    mov CX, 10
    LOOP_LINHAS_STATUS:
        call DESENHA_PIXELS
        add AX, 320
        loop LOOP_LINHAS_STATUS
        
    ;restaura AX com a coordenada inicial que está na pilha
    pop AX
    push AX
    
    ;aponta para a coordena de inicio onde deve completar o restante com preto 
    add AX, DX
    
    ;calcula quanto precisa para completar
    push AX

    mov AX, 100
    sub AX, DX
    mov DX, AX
    
    pop AX
    
    mov BX, 0 ;preto
    mov CX, 10
    LOOP_LINHAS_STATUS_VAZIO:
        call DESENHA_PIXELS
        add AX, 320
        loop LOOP_LINHAS_STATUS_VAZIO
    
    pop AX
    pop BX
    pop DX
    pop CX
    ret
endp

ATUALIZA_BARRA_TEMPO proc
    push AX
    push BX
    push DX

    mov AX, 59227
    mov BX, 0BH
    mov DX, RESTANTE_TEMPO
    call ATUALIZAR_BARRA_STATUS         
    
    pop DX
    pop BX
    pop AX
    ret
endp

ATUALIZA_BARRA_VIDA proc
    push AX
    push BX
    push DX

    mov AX, 10
    mul NRO_VIDAS
    mov DX, AX
    
    mov AX, 59392
    mov BX, 0AH
    call ATUALIZAR_BARRA_STATUS    
    
    pop DX
    pop BX
    pop AX
    ret
endp

INICIAR_JOGO proc
    push AX
    push BX
    call MODO_VIDEO
    call DESENHA_INTERFACE

    mov AX, 0A000H
    mov ES, AX
    
    xor BX, BX  
    LOOP_MAIN:

        call ATUALIZA_BARRA_VIDA
        call ATUALIZA_BARRA_TEMPO
        call LE_ENTRADA ; Verifica e processa a entrada do teclado
        call LIMPA_AREA_NAVE ; Limpa a ?rea onde a nave estava
        ; Calcula a posi??o inicial da nave em pixels
        ; Cada linha tem 320 pixels, ent?o multiplique a coordenada Y por 320 e some com a coordenada X
        mov AX, POSICAO_Y_NAVE
        mov CX, 320
        mul CX
        add AX, POSICAO_X_NAVE
        mov DI, AX          ; Armazena a posi??o calculada em DI

        mov SI, offset NAVE

        ; Agora, DI tem a posi??o correta para desenhar a nave
        call DESENHA_ELEMENTO_10x10 ; Desenha a nave na posi??o atualizada
        call PAUSA_CICLO      ; Pausa o ciclo para controlar a velocidade do jogo
        
        inc BX
        cmp BX, 20 ;20 frames por segundo
        je ATUALIZA_TEMPO_RESTANTE
        
        jmp LOOP_MAIN         ; Repete o loop
    
    ATUALIZA_TEMPO_RESTANTE:
        dec RESTANTE_TEMPO
        xor BX, BX
        jmp LOOP_MAIN
        
    FIM_JOGO:
        pop BX
        pop AX
    ret
endp

LE_ENTRADA proc
    mov AX, POSICAO_X_NAVE
    mov POSICAO_X_NAVE_ANTERIOR, AX
    mov AX, POSICAO_Y_NAVE
    mov POSICAO_Y_NAVE_ANTERIOR, AX
    push AX
    push BX
    push CX
    push DX

    mov AH, 1 ; Verifica se h? uma tecla pressionada
    int 16h
    jz FIM_LE_ENTRADA ; Se nenhuma tecla foi pressionada, pula a atualiza??o

    mov AH, 0 ; Pega o scan code da tecla pressionada
    int 16h

    cmp AH, 11h ; Tecla W (cima)
    je MOVE_CIMA
    cmp AH, 1Fh ; Tecla S (baixo)
    je MOVE_BAIXO

    jmp FIM_LE_ENTRADA

    MOVE_CIMA:
        dec POSICAO_Y_NAVE
        jmp FIM_LE_ENTRADA

    MOVE_BAIXO:
        inc POSICAO_Y_NAVE

    FIM_LE_ENTRADA:
    pop DX
        pop CX
        pop BX
        pop AX
        ret
LE_ENTRADA endp


LIMPAR_TELA proc
    push AX
    push BX
    push CX
    push DX

    mov AH, 06H
    mov AL, 0H

    xor BH, BH
    xor CX, CX

    mov DH, 25
    mov DL, 80

    int 10H

    pop DX
    pop CX
    pop BX
    pop AX
    ret
endp

LIMPA_AREA_NAVE proc
    push AX
    push BX
    push CX
    push DX
    push DI

    ; Calcula a posi??o inicial da ?rea da nave em pixels
    mov AX, POSICAO_Y_NAVE_ANTERIOR
    mov CX, 320
    mul CX
    add AX, POSICAO_X_NAVE_ANTERIOR
    mov DI, AX

    ; Limpa a ?rea da nave (10x10 pixels, por exemplo)
    ; Supondo que o fundo ? preto (cor 0)
    mov CX, 10 ; Altura da nave
    LIMPA_LINHA:
        push CX
        mov CX, 10 ; Largura da nave
        xor AX, AX ; Cor preta
        REP STOSB  ; Preenche a linha com preto
        pop CX
        add DI, 310 ; Move para a pr?xima linha
        loop LIMPA_LINHA

    pop DI
    pop DX
    pop CX
    pop BX
    pop AX
    ret
LIMPA_AREA_NAVE endp

ACAO_MENU proc
    push AX

    call LIMPAR_TELA

    cmp OPCAO_MENU_SELECIONADA, 1
    je FIM_ACAO_MENU
    
    call INICIAR_JOGO

    mov AH, 7H
    int 21H

    call MOSTRAR_TELA_INICIAL

    FIM_ACAO_MENU:

    pop AX
    ret
endp

PAUSA_CICLO proc
    push AX
    push CX
    push DX

    mov AH, 86H
    mov CX, TEMPO_CX
    mov DX, TEMPO_DX
    int 15H

    pop DX
    pop CX
    pop AX
    ret
endp

MOSTRAR_TELA_INICIAL proc
    call MODO_VIDEO
    call MOSTRA_INTRO
    call ATUALIZA_MENU
    call SELECIONA_OPCAO_MENU
    call ACAO_MENU
    ret
endp


INICIO:
    mov AX, @data
    mov DS, AX
    
    call MOSTRAR_TELA_INICIAL

    mov AH, 4CH
    int 21H
end INICIO


