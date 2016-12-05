         assume cs:codigo,ds:dados,es:dados,ss:pilha

CR        EQU    0DH ; caractere ASCII "Carriage Return"
LF        EQU    0AH ; caractere ASCII "Line Feed"
BS        EQU    08H ; backspace

; SEGMENTO DE DADOS DO PROGRAMA
dados     segment


pal_1 db 0
pal_2 db 0
pal_3 db 0
pal_4 db 0
pal_5 db 0
pal_6 db 0
pal_7 db 0

nome_arq   db 64 dup (?)
buffer     db 128 dup (?)
espacos    dw 0
total      dw 0
palavras   dw 0
maiusculas dw 0
minusculas dw 0
enters     dw 0
outros     dw 0
digitos    dw 0

string_1    db '1','$'
string_2    db '2','$'
string_3    db '3','$'
string_4    db '4','$'
string_5    db '5','$'
string_6    db '6','$'
string_7    db '+','$'
string_mais db '*','$'


msg_pede_nome       db 'Nome do arquivo: ','$'
msg_erro            db 'Erro! Repita.',CR,LF,'$'
msg_outro_arquivo   db CR,LF,'Analise completa. Gostaria de analisar outro arquivo? (S=sim/N=nao):','$'
msg_final           db CR,LF,'Obrigada por utilizar nossos servicos.',CR,LF,'$'
tela_inicial        db ' +++ CONTADOR DE LETRAS E OUTRAS COISAS - Giovanna Varriale Damian - 264850 +++',CR,LF,'$'
tela_separador      db '===============================================================================',CR,LF,'$'
analise_arq         db 'O arquivo ','$'
analise_coisas      db ' contem','$'
analise_palavras    db '     palavras e'
analise_caracteres  db '      caracteres, sendo'
analise_espacos     db '     espacos,',CR,LF
analise_maisculas   db '     maiusculas,'
analise_minusculas  db '     minusculas,'
analise_digitos     db '     digitos,'
analise_crlfs       db '     CRLF(s) e'
analise_outros      db '     outros.','$'

analise_fim         db 'Histograma com tamanho das palavras (representa no maximo 75 de cada tamanho)',CR,LF,'$'
num_1 db ' 1 |',CR,LF,'$'
num_2 db ' 2 |',CR,LF,'$'
num_3 db ' 3 |',CR,LF,'$'
num_4 db ' 4 |',CR,LF,'$'
num_5 db ' 5 |',CR,LF,'$'
num_6 db ' 6 |',CR,LF,'$'
num_7 db '>=7|','$'

handler   dw ?
dados     ends

; SEGMENTO DE PILHA DO PROGRAMA
pilha    segment stack                      ; permite inicializacao automatica de SS:SP
         dw     128 dup(?)
pilha    ends

; SEGMENTO DE CODIGO DO PROGRAMA
codigo   segment
inicio:                                     ; CS e IP sao inicializados com este endereco
         mov    ax,dados                    ; inicializa DS
         mov    ds,ax                       ; com endereco do segmento DADOS
         mov    es,ax                       ; idem em ES
         ; fim da carga inicial dos registradores 00e6e6de segmento

;INICIO DO MEU PROGRAMA -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

limpa_tela:
                                            ; funcao: rolar_tela (inteira)
        mov     ch,0                        ; limpa a tela antes de pedir
        mov     cl,0                        ; o nome do arquivo
        mov     dh,24
        mov     dl,79
        mov     bh,07h                      ; fundo preto e letras cinza claro
        mov     al,0
        mov     ah,6
        int     10h
 ;posiciona_cursor (0,0):
        mov     dh,0
        mov     dl,0
        mov     bh,0
        mov     ah,2
        int     10h

pede_nome_do_arquivo:
        lea    dx,msg_pede_nome             ;"Nome do arquivo:"
        mov    ah,9
        int    21h
                                            ;pega o que for digitado
        lea    di, nome_arq

entra_nome:
        mov    ah,1
        int    21h	                        ; le um caracter com eco

        cmp    al,CR
        je     nome_digitado_tenta_abrir

        cmp    al,BS
        je     arruma_backspace

        mov    [di],al                      ; coloca em nome_arq
        inc    di
        jmp    entra_nome

arruma_backspace:
        dec di
        jmp entra_nome

nome_digitado_tenta_abrir:
        mov   [di],'$'
        inc   di
        mov   byte ptr [di],0               ; forma string ASCIIZ com o nome do arquivo

        mov    dl,LF                        ; escreve LF na tela
        mov    ah,2
        int    21h
                                            ;tenta_abrir_o_arquivo
        mov    ah,3dh
        mov    al,0
        lea    dx,nome_arq
        int    21h
        jnc    abriu_ok
                                            ;se_nao_conseguiu
        lea    dx,msg_erro
        mov    ah,9
        int    21h
        jmp    pede_nome_do_arquivo

abriu_ok:
        mov handler,ax                      ;depois da tela pronta
                                            ;voltamos a mexer no arquivo

formatando_tela:
 ;coloca_cor_tela = rolar_tela (area_barra_indentificacao);
        mov     ch,0
        mov     cl,0
        mov     dh,1
        mov     dl,79
        mov     bh,30H                      ;fundo ciano e letras pretas
        mov     al,0
        mov     ah,6
        int     10h
 ;coloca_cor_tela = rolar_tela (area-arquivo);
        mov     ch,2
        mov     cl,0
        mov     dh,13
        mov     dl,79
        mov     bh,07h                      ; fundo preto e letras cinza claro
        mov     al,0
        mov     ah,6
        int     10h
 ;coloca_cor_tela = rolar_tela (area_mostra_estatistica):
        mov     ch,14
        mov     cl,0
        mov     dh,24
        mov     dl,79
        mov     bh,30H                      ;fundo ciano e letras pretas
        mov     al,0
        mov     ah,6
        int     10h

 ;posiciona_cursor (0,0):
        mov     dh,0
        mov     dl,0
        mov     bh,0
        mov     ah,2
        int     10h

 ;escreve_mensagem:
        lea    dx,tela_inicial              ;identificacao
        mov    ah,9
        int    21h

        lea    dx,tela_separador            ;separador entre identificacao
        mov    ah,9                         ;e onde sera escrito o arquivo
        int    21h

 ;posiciona_cursor (17,0):
        mov     dh,17
        mov     dl,0
        mov     bh,0
        mov     ah,2
        int     10h

 ;escreve_mensagem:
        lea    dx,analise_fim               ;"O Histograma..."
        mov    ah,9
        int    21h

        lea    dx,num_1                     ;agora escreve todos os numeros
        mov    ah,9
        int    21h
        lea    dx,num_2
        mov    ah,9
        int    21h
        lea    dx,num_3
        mov    ah,9
        int    21h
        lea    dx,num_4
        mov    ah,9
        int    21h
        lea    dx,num_5
        mov    ah,9
        int    21h
        lea    dx,num_6
        mov    ah,9
        int    21h
        lea    dx,num_7
        mov    ah,9
        int    21h                          ;fim dos numeros possiveis

 ;posiciona_cursor(2,0):
        mov    dh,2
        mov    dl,0
        mov    bh,0
        mov    ah,2
        int    10h
        jmp    laco

pula_pra_mostra_estatisticas: ;jne dentro do laco nao alcancou
        jmp    mostra_estatisticas

laco:
        mov ah,3fh                        ; le um caractere do aqruivo
        mov bx,handler
        mov cx,1
        lea dx,buffer
        int 21h

        cmp ax,cx                         ;fim do arquivo?
        jne pula_pra_mostra_estatisticas

                                          ; calcula contagens para fins de estatisticas
        mov al,buffer
        inc total                         ; conta caracteres lidos

        cmp al,' '
        je  conta_espacos

        cmp al,CR
        je  conta_CR

        cmp al,LF
        je  arruma_lf

        cmp al,'@'
        jg nao_e_digito

        cmp al,'0'
        je  conta_digitos
        cmp al,'1'
        je  conta_digitos
        cmp al,'2'
        je  conta_digitos
        cmp al,'3'
        je  conta_digitos
        cmp al,'4'
        je  conta_digitos
        cmp al,'5'
        je  conta_digitos
        cmp al,'6'
        je  conta_digitos
        cmp al,'7'
        je  conta_digitos
        cmp al,'8'
        je  conta_digitos
        cmp al,'9'
        je  conta_digitos
        jmp conta_outros

nao_e_digito:
        cmp al,'Z'
        jg nao_e_maiscula
        jmp conta_maiusculas

nao_e_maiscula:
        cmp al,'a'
        jge veremos_se_e_minuscula_mesmo
        jmp conta_outros

veremos_se_e_minuscula_mesmo:
        cmp al,'z'
        jle conta_minusculas
        jmp conta_outros

arruma_lf:
        mov buffer,' '
        jmp escrever

conta_espacos:
        inc espacos
        inc palavras
        jmp escrever

conta_CR:
        inc enters
        inc palavras
        jmp laco

conta_maiusculas:
        inc maiusculas
        jmp escrever

conta_minusculas:
        inc minusculas
        jmp escrever

conta_outros:
        inc outros
        jmp escrever

conta_digitos:
        inc digitos
        jmp escrever

escrever:
        mov dl, buffer  ; escreve caractere na tela
        mov ah,2
        int 21h

        jmp laco

mostra_estatisticas:

        std             ; vai preencher mensagem da unidade para o milhar

        mov    ax,palavras
        lea    di,analise_palavras+3
        call   edita    ; coloca em ASCII na mensagem

        mov    ax,total
        lea    di,analise_caracteres+4
        call   edita    ; coloca em ASCII na mensagem

        mov    ax,espacos
        lea    di,analise_espacos+3
        call   edita    ; coloca em ASCII na mensagem

        mov    ax,maiusculas
        lea    di,analise_maisculas+3
        call   edita    ; coloca em ASCII na mensagem

        mov    ax,minusculas
        lea    di,analise_minusculas+3
        call   edita    ; coloca em ASCII na mensagem

        mov    ax,digitos
        lea    di,analise_digitos+3
        call   edita    ; coloca em ASCII na mensagem

        mov    ax,enters
        lea    di,analise_crlfs+3
        call   edita    ; coloca em ASCII na mensagem

        mov    ax,outros
        lea    di,analise_outros+3
        call   edita    ; coloca em ASCII na mensagem

        ;posiciona_cursor (14,0):
        mov     dh,14
        mov     dl,0
        mov     bh,0
        mov     ah,2
        int     10h

        ;escreve_mensagem:
        lea    dx,tela_separador            ;separador entre a area escrita
        mov    ah,9                         ;do area do arquivo e estatisticas
        int    21h

        lea    dx, analise_arq
        mov    ah,9
        int    21h

        lea    dx, nome_arq
        mov    ah,9
        int    21h

        lea    dx, analise_coisas
        mov    ah,9
        int    21h

        lea    dx, analise_palavras
        mov    ah,9
        int    21h

espera_enter:
        mov ah,8	                          ; le caractere sem eco
        int 21h
        cmp al,CR
        je  fecha_arquivo                   ;so passa pro fim se receber enter
        jmp espera_enter                    ;senao fica na mesma tela

fecha_arquivo:
        mov ah,3eh	 ; fecha arquivo
        mov bx,handler
        int 21h

escreve_mensagem_quer_analizar_outro_arquivo:
        ;posiciona_cursor (24,0):
        mov     dh,24
        mov     dl,0
        mov     bh,0
        mov     ah,2
        int     10h

        lea    dx,msg_outro_arquivo
        mov    ah,9
        int    21h

espera_resposta:
        mov ah,1	                          ; le caractere com eco
        int 21h
        cmp al,'S'
        je  verificar_outro_arquivo
        cmp al,'N'
        je  fim_total
        cmp al,'s'
        je  verificar_outro_arquivo
        cmp al,'n'
        je  fim_total
        jmp espera_resposta
fim_total:
        jmp fim_total_e_sem_volta

verificar_outro_arquivo:
        mov buffer,0
        mov espacos,0
        mov total,0
        mov palavras,0
        mov maiusculas,0
        mov minusculas,0
        mov enters,0
        mov outros,0
        mov digitos,0

        mov analise_palavras,' '
        mov analise_palavras+1,' '
        mov analise_palavras+2,' '
        mov analise_palavras+3,' '
        mov analise_palavras+4,' '

        mov analise_caracteres,' '
        mov analise_caracteres+1,' '
        mov analise_caracteres+2,' '
        mov analise_caracteres+3,' '
        mov analise_caracteres+4,' '

        mov analise_espacos,' '
        mov analise_espacos+1,' '
        mov analise_espacos+2,' '
        mov analise_espacos+3,' '
        mov analise_espacos+4,' '

        mov analise_maisculas,' '
        mov analise_maisculas+1,' '
        mov analise_maisculas+2,' '
        mov analise_maisculas+3,' '
        mov analise_maisculas+4,' '

        mov analise_minusculas,' '
        mov analise_minusculas+1,' '
        mov analise_minusculas+2,' '
        mov analise_minusculas+3,' '
        mov analise_minusculas+4,' '

        mov analise_crlfs,' '
        mov analise_crlfs+1,' '
        mov analise_crlfs+2,' '
        mov analise_crlfs+3,' '
        mov analise_crlfs+4,' '

        mov analise_outros,' '
        mov analise_outros+1,' '
        mov analise_outros+2,' '
        mov analise_outros+3,' '
        mov analise_outros+4,' '


        jmp limpa_tela

fim_total_e_sem_volta:
        ;escreve: obrigada por utilizar nossos servicos
        lea    dx,msg_final
        mov    ah,9
        int    21h
        ;acaba aqui
        mov    ax,4c00h         ; funcao retornar ao DOS no AH
                                ; codigo de retorno 0 no AL
        int    21h      ;

; subrotina para editar (converter de bin�rio para ASCII
; com 4 digitos e colocar na mensagem) um valor de 16 bits
; de um contador (pressupoe que mensagem contenha espacos)
; recebe em DI endereco do byte das unidades na mensagem
; recebe em AX o valor do contador
; usa divis�o de 16 bits para evitar overflow na divis�o por 10
edita    proc
         mov bx,10       ; divisor constante
proximo:
         mov dx,0        ; limpa msbits do dividendo
         div bx          ; divisor de 16 bits -> dividendo de 32 bits em DX:AX
         xchg dx,ax      ; permuta resto (DX) e quociente (AX)
         add  al,'0'     ; transforma resto (valor de 0 a 9) em ASCII
         stosb           ; guarda caractere na mensaqgem e DECREMENTA DI
         xchg dx,ax      ; devolve quociente para o AX
         test ax,0FFFFH  ; testa se quociente � zero
         jnz proximo     ; se n�o for, edita proximo digito
         ret             ; se for, missao cumprida !
edita    endp

codigo  ends
        end    inicio
