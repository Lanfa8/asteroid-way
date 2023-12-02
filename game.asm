.model small

.stack 1000H

.data
LARGURA_TELA equ 320

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

METEORO db 0,0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,0,0,0,0,7,7,7,7,8,8,7,7,7,7,7,7,7,7,8,8,7,7,7,7,0,0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,0,0,0,0

VIDA db 0,0,0,0,4,4,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0,4,4,0,0,0,0,4,4,4,4,0CH,0CH,4,4,4,4,4,4,4,4,0CH,0CH,4,4,4,4,0,0,0,0,4,4,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0,4,4,0,0,0,0

ESCUDO db 0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0,0,2,2,2,2,0EH,0EH,2,2,2,2,2,2,2,2,0EH,0EH,2,2,2,2,0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0,0

QUADRADO_PRETO db 100 dup(0)

;controladores jogo
NRO_VIDAS db 5
RESTANTE_TEMPO dw 30  
NIVEL db 1
TEMPO_DECORRIDO dw 0


; 50.000 ms
TEMPO_CX dw 0
TEMPO_DX dw 0C350H

SEED dw 1

POSICOES_ASTEROIDES dw 0,0,0,0,0,0,0,0
TOTAL_ASTEROIDES_SIMULTANEOS dw 8 

MAX_PROJETEIS EQU 10

; Cada proj?til consiste em 2 palavras (para posX e posY) e 1 byte (para ativo)
posicoes_projeteis DW 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
    mov AX, LARGURA_TELA
    
    mul DI
    mov DI, AX
    
    xor AX, AX
    mov AX, CX
    
    xor CX, CX
    mov CX, LARGURA_TELA
    
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
    push CX
    
    mov DI, AX ;coordenada

    mov BX, 10
    LOOP_COLUNAS:
        mov CX, 10
        
        rep movsb        
        
        dec BX
        add DI, 310 ;pular linha (320px - 10px)
        
        cmp BX, 0
        jne LOOP_COLUNAS
    
    pop CX
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
        add AX, LARGURA_TELA ;pula 1 linha
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
        add AX, LARGURA_TELA
        loop LOOP_LINHAS_STATUS
        
    ;restaura AX com a coordenada inicial que est? na pilha
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
        add AX, LARGURA_TELA
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


GERA_ASTEROIDE proc
    push AX
    push DX
    push SI
    push CX
    push BX
    
    ;verifica se pode gerar um novo asteroide
    mov CX, TOTAL_ASTEROIDES_SIMULTANEOS
    mov SI, offset POSICOES_ASTEROIDES
    LOOP_VERIFICA_ASTEROIDE:
        mov AX, [SI]
        cmp AX, 0 
        je GERA_ASTEROIDE_EFET
        add SI, 2 ; word
        loop LOOP_VERIFICA_ASTEROIDE
    
    jmp FIM_GERA_ASTEROIDE
    
    GERA_ASTEROIDE_EFET:
        mov BX, SI ;salva posicao do asteroide
        mov AX, 5760 ; 18 linhas X 320 px (18 linhas pois remove o espaço para a interface inferior)
        call RAND_NUMBER
        
        mul DX
        add AX, 300
        
        mov SI, offset METEORO
        call DESENHA_ELEMENTO_10x10
        
        mov SI, BX
        mov [SI], AX ;guarda a coordenada na posi?ao do asteroide
    
    FIM_GERA_ASTEROIDE:
        pop BX
        pop CX
        pop SI
        pop DX
        pop AX
    ret
endp

MOVE_ASTEROIDES proc
    push CX
    push SI
    push AX
    push BX
    push DX
    
    mov CX, TOTAL_ASTEROIDES_SIMULTANEOS
    mov SI, offset POSICOES_ASTEROIDES
    LOOP_PERCORRE_ASTEROIDES:
        mov AX, [SI]
        cmp AX, 0
        jne MOVE_ASTEROIDE_UNICO
        
        FLAG_COTINUA_LOOP:
            add SI, 2 ; word
            loop LOOP_PERCORRE_ASTEROIDES

    jmp FIM_MOVE_ASTEROIDES
    
    MOVE_ASTEROIDE_UNICO:
        add AX, 9 ;aponta para a ultima coluna atual
        mov BX, 10
        call LIMPA_COLUNA_PIXELS
        
        mov DX, [SI]
        dec DX
        mov [SI], DX
        
        push SI
        
        mov AX, DX
        mov SI, offset METEORO
        call DESENHA_ELEMENTO_10x10
        
        pop SI
        
        jmp FLAG_COTINUA_LOOP
    
    FIM_MOVE_ASTEROIDES:
        pop DX
        pop BX
        pop AX
        pop SI
        pop CX
    ret
endp

;ax = coordenada inicial
;bx = quantidade pixels
LIMPA_COLUNA_PIXELS proc
    push CX
    push DI
    push AX
    
    mov DI, AX
    mov CX, BX
    mov AX, 0
    
    LOOP_LIMPA_COLUNA:
        stosb
        add DI, 319 ; pula linha, DI já está +1
        loop LOOP_LIMPA_COLUNA
    
    pop AX
    pop DI
    pop CX
    ret
endp

INICIAR_JOGO proc
    push AX
    push BX
    push CX
    push DI
    push SI
    call MODO_VIDEO
    call DESENHA_INTERFACE

    mov AX, 0A000H
    mov ES, AX
    
    xor BX, BX  
    LOOP_MAIN:
        cmp NRO_VIDAS, 0
        je FIM_JOGO

        call ATUALIZA_BARRA_VIDA
        call ATUALIZA_BARRA_TEMPO
        
        call LE_ENTRADA ; Verifica e processa a entrada do teclado
       
        ; Calcula a posi??o inicial da nave em pixels
        ; Cada linha tem 320 pixels, ent?o multiplique a coordenada Y por 320 e some com a coordenada X
        mov AX, POSICAO_Y_NAVE
        mov CX, LARGURA_TELA
        mul CX
        add AX, POSICAO_X_NAVE
        mov DI, AX          ; Armazena a posi??o calculada em DI

        mov SI, offset NAVE

        ; Agora, DI tem a posi??o correta para desenhar a nave
        call DESENHA_ELEMENTO_10x10 ; Desenha a nave na posi??o atualizada
        
        call LIMPA_PROJETEIS
        call ATUALIZA_PROJETEIS
        call DESENHA_PROJETEIS
        call ATUALIZA_COLISOES_ASTEROIDES
            
        call PAUSA_CICLO      ; Pausa o ciclo para controlar a velocidade do jogo
        
        inc BX
        cmp BX, 20 ;20 frames por segundo
        
        je ATUALIZA_TEMPO_RESTANTE
        call MOVE_ASTEROIDES
        jmp LOOP_MAIN         ; Repete o loop
        
        
    ATUALIZA_TEMPO_RESTANTE:
        dec RESTANTE_TEMPO
        xor BX, BX
        call GERA_ASTEROIDE
        jmp LOOP_MAIN
        
    FIM_JOGO:
        pop SI
        pop DI
        pop CX
        pop BX
        pop AX
    ret
endp

ATUALIZA_COLISOES_ASTEROIDES proc
    push AX
    push BX
    push CX
    push DX
    push SI

    mov CX, TOTAL_ASTEROIDES_SIMULTANEOS
    mov SI, offset POSICOES_ASTEROIDES
    
    mov AX, [POSICAO_Y_NAVE]
    mov DX, 320
    mul DX
    add AX, [POSICAO_X_NAVE]

    LOOP_PERCORRE_ASTEROIDES_COLISOES:
        mov BX, [SI]
        cmp BX, 0
        je FLAG_COTINUA_LOOP_PERCORRE_ASTEROIDES_COLISOES
        
        call VERIFICA_COLISAO_10x10
        cmp DX, 1
        jne FLAG_COTINUA_LOOP_PERCORRE_ASTEROIDES_COLISOES
        
        
        push AX
        push SI
        
        mov AX, [SI]
        mov SI, offset QUADRADO_PRETO
        call DESENHA_ELEMENTO_10x10
        
        pop SI
        
        xor AX, AX
        mov [SI], AX ;limpa asteroide da memoria
        dec NRO_VIDAS
        pop AX

        FLAG_COTINUA_LOOP_PERCORRE_ASTEROIDES_COLISOES:
            add SI, 2 ; word
            loop LOOP_PERCORRE_ASTEROIDES_COLISOES

    FIM_VERIFICA_COLISOES_ASTEROIDES:
        pop SI
        pop DX
        pop CX
        pop BX
        pop AX

    ret
endp

ATUALIZA_PROJETEIS proc
    push AX
    push BX
    push CX
    push DI
    push DX

    mov CX, MAX_PROJETEIS
    mov DI, offset posicoes_projeteis

    ATUALIZA_LOOP:
         mov AX, [DI]          ; Carrega a posição linear do projétil
         cmp AX, 0
         je PROXIMO_PROJETIL

          add AX, 2             ; Move 2 pixels para a direita
          mov [DI], AX          ; Atualiza a posição do projétil

        ; Verifica se o projétil atingiu o final da linha
        ; Para isso, calculamos AX mod 320 e comparamos com 318 (320 - 2)
        push AX
        mov DX, 0
        mov BX, 320
        div BX               ; DX agora tem AX mod 320
        cmp DX, 0
        je DESATIVA_PROJETIL ; Se >= 318, está no final da linha ou passou dela
        pop AX
        jmp PROXIMO_PROJETIL

        DESATIVA_PROJETIL:
          pop AX
          mov [DI], 0          ; Desativa o projétil

        PROXIMO_PROJETIL:
          add DI, 2            ; Avança para o próximo projétil
          loop ATUALIZA_LOOP

    pop DX
    pop DI
    pop CX
    pop BX
    pop AX
    ret
ATUALIZA_PROJETEIS endp

LIMPA_PROJETEIS proc
    push AX
    push BX
    push CX
    push DI

    mov CX, MAX_PROJETEIS
    mov DI, offset posicoes_projeteis

    LIMPA_LOOP:
        mov AX, [DI]
        cmp AX, 0
        je PROXIMO_PROJETIL_LIMPA

        ; Aqui você pode chamar DESENHA_PIXELS ou uma função semelhante
        ; para limpar (pintar com a cor de fundo) a posição do projétil
        ; Por exemplo, se a cor de fundo for preta (0), você pode fazer:
        mov BX, 0 ; Cor preta
        mov DX, 1 ; Tamanho do projétil
        call DESENHA_PIXELS

    PROXIMO_PROJETIL_LIMPA:
        add DI, 2 ; Avança para o próximo projétil
    loop LIMPA_LOOP

    pop DI
    pop CX
    pop BX
    pop AX
    ret
LIMPA_PROJETEIS endp

DESENHA_PROJETEIS proc
    push AX
    push BX
    push CX
    push SI
    push DI

    mov CX, MAX_PROJETEIS        ; Número máximo de projéteis
    mov SI, offset posicoes_projeteis
    mov BX, 0FH                  ; Cor branca (branco)

    LOOP_DESENHA_PROJETIL:
        lodsw                     ; Carrega a posição do próximo projétil
        or AX, AX                 ; Verifica se a posição é ativa (não zero)
        jz CONTINUA               ; Se zero, pula para o próximo projétil

        mov DI, AX                ; DI recebe a posição do projétil
        mov DX, 1                 ; Quantidade de pixels a desenhar (1 pixel)
        call DESENHA_PIXELS       ; Desenha o projétil

        CONTINUA:
        loop LOOP_DESENHA_PROJETIL

    pop DI
    pop SI
    pop CX
    pop BX
    pop AX
    ret
endp

LE_ENTRADA proc

    push AX
    push BX
    push CX
    push DX
    push DI
    push SI

    mov AX, POSICAO_X_NAVE
    mov POSICAO_X_NAVE_ANTERIOR, AX
    mov AX, POSICAO_Y_NAVE
    mov POSICAO_Y_NAVE_ANTERIOR, AX

    mov AH, 1 ; Verifica se h? uma tecla pressionada
    int 16h
    jz FIM_LE_ENTRADA ; Se nenhuma tecla foi pressionada, pula a atualiza??o

    mov AH, 0 ; Pega o scan code da tecla pressionada
    int 16h

    cmp AH, 48h ; Tecla seta para cima
    je MOVE_CIMA
    cmp AH, 50h ; Tecla seta para baixo
    je MOVE_BAIXO
    

    cmp AH, 39h ; Tecla Espa?o
    je ATIRA

    jmp FIM_LE_ENTRADA

MOVE_CIMA:
    dec POSICAO_Y_NAVE
    ; Calcula a posi??o da linha inferior da nave para limpar
    mov AX, POSICAO_Y_NAVE
    add AX, 10 ; Tamanho da nave em altura
    mov CX, LARGURA_TELA
    mul CX
    add AX, POSICAO_X_NAVE
    mov DI, AX
    call LIMPA_LINHA
    jmp FIM_LE_ENTRADA

MOVE_BAIXO:
   inc POSICAO_Y_NAVE
    ; Calcula a posi??o da linha superior da nave para limpar
    mov AX, POSICAO_Y_NAVE
    dec AX ; Move uma linha acima da posi??o atual
    mov CX, LARGURA_TELA
    mul CX
    add AX, POSICAO_X_NAVE
    mov DI, AX
    call LIMPA_LINHA
    jmp FIM_LE_ENTRADA
    
ATIRA:
    mov CX, MAX_PROJETEIS
    mov DI, offset posicoes_projeteis

    PROCURA_PROJETIL:
        lodsw
        cmp AX, 0
        je ATIVA_PROJETIL
        add DI, 2 ; Avança para o próximo projétil (2 bytes por projétil)
    loop PROCURA_PROJETIL
    jmp FIM_LE_ENTRADA

ATIVA_PROJETIL:
    sub DI, 2 ; Volta ao início do projétil

    ; Configura a posição inicial do projétil
    mov AX, POSICAO_Y_NAVE
    mov BX, 330
    mul BX              ; AX = POSICAO_Y_NAVE * 320
    add AX, POSICAO_X_NAVE ; AX = AX + POSICAO_X_NAVE
    mov [DI], AX        ; Armazena a posição linear absoluta no array projeteis

    jmp FIM_LE_ENTRADA
    
FIM_LE_ENTRADA:
    pop SI
    pop DI
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

LIMPA_LINHA proc
    push AX
    push CX
    push DI

    mov CX, 10 ; Largura da nave
    xor AX, AX ; Cor preta para limpar (ajuste conforme necess?rio)

    REP STOSB  ; Preenche a linha com preto

    pop DI
    pop CX
    pop AX
    ret
LIMPA_LINHA endp


;ax = coordenada esquerda superior1
;bx = coordenada esquerda superior2
;dx = retorna 1 se colidiu
VERIFICA_COLISAO_10x10 proc
    push AX
    push CX

    xor DX, DX

    mov CX, 10
    LOOP_EXTERNO_VERIFICA_COLISAO_10x10:
        push CX
        mov CX, 10
        LOOP_INTERNO_VERIFICA_COLISAO_10x10:
            call VERIFICA_COLISAO_PIXEL_COM_10X10
            cmp DX, 1
            je COLIDIU_10x10

            inc AX  
            loop LOOP_INTERNO_VERIFICA_COLISAO_10x10
        
        pop CX ; restaura1
        add AX, 310 ;pula linha (320px - 10px)
        loop LOOP_EXTERNO_VERIFICA_COLISAO_10x10

    jmp FIM_VERIFICA_COLISAO_10x10
    COLIDIU_10x10:
        pop CX ;restaura 1  
        
    FIM_VERIFICA_COLISAO_10x10:
        pop CX
        pop AX
        ret
endp

;bx = coordenada inicial elemento 10x10
;ax = coordenada pixel
;dx = retorna 1 se colidiu
VERIFICA_COLISAO_PIXEL_COM_10X10 proc
    push CX
    push BX
    
    xor DX, DX
    mov CX, 10
    LOOP_EXTERNO_VERIFICA_COLISAO_PIXEL_COM_10X10:
        push CX
        mov CX, 10
        LOOP_INTERNO_VERIFICA_COLISAO_PIXEL_COM_10X10:
            cmp AX, BX
            je COLIDIU
            inc BX
            loop LOOP_INTERNO_VERIFICA_COLISAO_PIXEL_COM_10X10
        
            pop CX ;restaura
        add BX, 310 ;pula linha (320px - 10px)
        loop LOOP_EXTERNO_VERIFICA_COLISAO_PIXEL_COM_10X10
    
    jmp FIM_VERIFICA_COLISAO_PIXEL_COM_10X10

    COLIDIU:
        pop CX ;restaura
        mov DX, 1
        jmp FIM_VERIFICA_COLISAO_PIXEL_COM_10X10

    FIM_VERIFICA_COLISAO_PIXEL_COM_10X10:
        pop BX
        pop CX
    ret
endp

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

;retorna um numero aleatorio em DL de 0 a 9
RAND_NUMBER proc
    push AX
    push CX
    
    mov AH, 00h  ; interrupts to get system time        
    int 1AH      ; CX:DX now hold number of clock ticks since midnight      

    mov  ax, dx
    xor  dx, dx
    mov  cx, 10    
    div  cx       ; here dx contains the remainder of the division - from 0 to 9

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


