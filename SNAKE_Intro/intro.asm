IDEAL
MODEL small
STACK 100h

DATASEG

                                                                                          
g db"	  ______                              _____                   ",13,10
  db"	 / _____)                            / ___ \                  ",13,10
  db"	| /  ___  ____ ____   ____    ___   | |   | |_   _ ____  ____ ",13,10
  db"	| | (___)/ _  |    \ / _  )  (___)  | |   | | | | / _  )/ ___)",13,10
  db"	| \____/( ( | | | | ( (/ /          | |___| |\ V ( (/ /| |    ",13,10
  db"	 \_____/ \_||_|_|_|_|\____)          \_____/  \_/ \____)_|    $",13,10                                                                                           
 
struc snake_node
    x dw ?
    y dw ?
    endx dw ?
    endy dw ?
    direcB db ?
    direcN db ?
    next db ?
ends snake_node

struc Player
    l1 db ?
    scorep  db ?
    scorep2 db ?
ends Player

title_  DW 0342, 0341, 0340, 0339, 0338, 0337, 0336, 0335, 0415, 0495
        DW 0575, 0655, 0656, 0657, 0658, 0659, 0660, 0661, 0662, 0742
        DW 0822, 0902, 0982, 0981, 0980, 0979, 0978, 0977, 0976, 0975
        DW 0985, 0905, 0825, 0745, 0665, 0585, 0505, 0425, 0345, 0426
        DW 0507, 0587, 0668, 0669, 0750, 0830, 0911, 0992, 0912, 0832
        DW 0752, 0672, 0592, 0512, 0432, 0352, 0995, 0915, 0835, 0755
        DW 0675, 0595, 0515, 0435, 0355, 0356, 0357, 0358, 0359, 0360
        DW 0361, 0362, 0442, 0522, 0602, 0682, 0762, 0842, 0922, 1002
        DW 0676, 0677, 0678, 0679, 0680, 0681, 0365, 0445, 0525, 0605
        DW 0685, 0765, 0845, 0925, 1005, 0372, 0451, 0530, 0609, 0608
        DW 0687, 0686, 0768, 0769, 0850, 0931, 1012, 0382, 0381, 0380
        DW 0379, 0378, 0377, 0376, 0375, 0455, 0535, 0615, 0695, 0775
        DW 0855, 0935, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022
        DW 0696, 0697, 0698, 0699, 0700, 0701, 0702

        text_1 DB "   ~~~~~~~~~~~~~~~~00-", '$'
        text_2 DB "WRITTEN IN ASSEMBLY 8086 LANGUAGE :)", '$'
        text_3 DB "PRESS ANY KEY TO START", '$'
        text_4 DB "                      ", '$'
        buffer2 DB 2000 DUP(?)                              
        x1 dw ?                                             
        x2 dw ?                                             
        y1 dw ?                                             
        y2 dw ?                                             
        prevMil db ?                                        
        Clock equ es:6Ch                                    
        randX dw ?                                          
        randY dw ?                                          
        endRandX dw ?                                       
        endRandY dw ?                                       
        Score_Text db 'Score:$'                             
        instruc_design db 'Pick A Color $'                  
        Press_Enter db 'Press Enter To Start Playing$'      
        Example db 'Example$'                               
        Present_Score db 'Your Score is: $'                 
        PressAny db 'Press Any Key To Continue..$'
        colorsnake db 14                                    
        ColorsOptions db 14,6,10,2,11,3,9,1,13,5            
        flagsc db ?                                         
        Score_Number dw 0                                   
        pointapple db 10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120,125,130,135,140,145,150,155
        postemp db ?                                        
        flagout db 0                                        
        squad db 11                                         
        arr snake_node 5000 dup (?)                        
        plyr Player 3 dup (?)                               
        flagrand db 0                                       

CODESEG

start:
        mov ax, @data
        mov ds, ax
        mov es,ax               
        mov ax,40h
        mov es,ax               
              
        macro strlen    
            local len
            mov si,offset user
            inc si                      
            xor cx,cx
            dec cx
            len:
                inc cx                  
                inc si                  
                cmp [byte ptr si],0     
                jne len
        endm strlen

        macro print_tail color
            mov ax,[si]
            mov [x1],ax
            mov ax,[si+2]
            mov [y1],ax
            mov ax,[si+4]
            mov [x2],ax
            mov ax,[si+6]
            mov [y2],ax
            print_snake_node [x1],[y1],[x2],[y2],color
        endm print_tail

        macro paint_characters color,v1,v2,v3,v4
            xor al,al
            mov bh, color
            mov ch,v1
            mov cl,v2
            mov dh,v3
            mov dl,v4
            mov ah,6h             
            int 10h
        endm paint_characters

        macro flush_buffer
            mov ah,0Ch
            xor al,al
            int 21h
        endm flush_buffer

        macro push_regs  r1,r2,r3,r4
            irp register,<r1,r2,r3,r4>
                ifnb <register>
                        push register
                endif
            endm
        endm push_regs

        macro pop_regs  r1,r2,r3,r4
            irp register,<r1,r2,r3,r4>
               ifnb <register>
                       pop register
               endif
           endm
        endm pop_regs

        Macro set_node_edges
            mov ax,[randX]
            add ax,5        
            mov [endRandX],ax
            mov bx,[randY]
            add bx,5
            mov [endRandY],bx
        endm set_node_edges

        macro get_pixel_color_by_pos cx_value,dx_value
            mov cx,cx_value
            mov dx,dx_value
            mov ah,0Dh
            int 10h
        endm get_pixel_color_by_pos

        macro print_snake_node sX,sY,eX,eY,color
            local line
            xor bh,bh
            mov ah,0Ch
            mov cx,sX               
            mov dx,sY               
            mov al,color            
            line:
                int 10h
                inc cx              
                cmp cx,eX           
                jne line
            inc dx                  
            mov cx,sX               
            cmp dx,eY               
            jne line                
        endm print_snake_node
macro random_get max_value
    mov ax,40h
    mov es,ax
    mov ax,[Clock]
    mov ah,[byte cs:bx]
    xor al,ah
    xor ah,ah
    and al,max_value
endm random_get

macro timer_wait
    local wait_loop
    local change
    wait_loop:
        mov ah,2ch
        int 21h
        mov [prevMil],dl
        change:
            mov ah,2ch
            int 21h
            cmp dl,[prevMil]
            je change
endm timer_wait

macro get_tail_pos
    local look
    local outlook
    mov bx,offset arr.x
    look:
        cmp [byte ptr bx],0
        je outlook
        add bx,11
        jmp look
    outlook:
        mov si,bx
        sub si,11
endm get_tail_pos

macro set_cursor_pos row,column
    push_regs ax,bx,dx
    xor bh,bh
    mov ah,02h
    mov dh,row
    mov dl,column
    int 10h
    pop_regs dx,bx,ax
endm set_cursor_pos

macro print_str string
    push_regs ax,dx
    mov dx,offset string
    mov ah,9h
    int 21h
    pop_regs dx,ax
endm print_str

macro CopyNewName offsetplyer,offsetscore
    local Copy
    mov si,offset user
    inc si
    mov di,offsetplyer
    Copy:
        mov al,[si]
        mov [di],al
        inc si
        inc di
        cmp [byte ptr si],00
        jne Copy
        mov [byte ptr di-1],00
    mov ax,[Score_Number]
    mov bl,10
    div bl
    mov bx,offsetscore
    mov [bx],al
    mov [bx+1],ah
endm CopyNewName

macro CopySecondName offsetPlayer1,offsetPlayer2
    local Copy4
    mov si,offsetPlayer1
    mov di,offsetPlayer2
    Copy4:
        mov al,[si]
        mov [di],al
        inc si
        inc di
        cmp si,offsetPlayer2
        jne Copy4
endm CopySecondName

macro touchapple_add v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11
    get_tail_pos
    mov ax,v1
    mov v2,ax
    mov ax,v3
    mov v4,ax
    mov ax,v5
    add ax,5
    mov v6,ax
    mov ax,v7
    add ax,5
    mov v8,ax
    mov al,v9
    mov v10,al
    mov v11,al
endm touchapple_add

macro touchapple_sub v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11
    get_tail_pos
    mov ax,v1
    mov v2,ax
    mov ax,v3
    mov v4,ax
    mov ax,v5
    sub ax,5
    mov v6,ax
    mov ax,v7
    sub ax,5
    mov v8,ax
    mov al,v9
    mov v10,al
    mov v11,al
endm touchapple_sub
;------------------------------------------------------------end of macros----------------------------------------------------
proc MainBoard
    CALL show_title
    push_regs ax,bx,cx,dx
    mov ax,0002h
    int 10h
    call setSnakeColor
    mov ax,13h
    int 10h
    set_cursor_pos 23,16
    print_str Score_Text
    mov [word ptr Score_Number],0
    call PRINT_NUMBER
    call draw_borders
    call Random_Values
    set_node_edges
    print_snake_node [randX],[randY],[endRandX],[endRandY],4
    mov bx,offset arr.x
    Zero:
        mov [byte ptr bx],00
        inc bx
        cmp bx,offset plyr.l1
        jne Zero
    mov [byte ptr arr.x],100
    mov [byte ptr arr.endx],105
    mov [byte ptr arr.y],160
    mov [byte ptr arr.endy],165
    mov [byte ptr arr.direcN],4
    mov [byte ptr arr.direcB],4
    mov bx,offset arr.x
    mov [byte ptr bx+11],95
    mov bx,offset arr.endx
    mov [byte ptr bx+11],100
    mov bx,offset arr.y
    mov [byte ptr bx+11],160
    mov bx,offset arr.endy
    mov [byte ptr bx+11],165
    mov bx,offset arr.direcN
    mov [byte ptr bx+11],4
    mov bx,offset arr.direcB
    mov [byte ptr bx+11],4
    call PlaySnake
    call stopnoise
    mov ax,0002h
    int 10h
    mov si,offset plyr.scorep
    mov bl,[si+5]
    mov al,10
    mul bl
    xor bh,bh
    mov bl,[si+6]
    add ax,bx
    call display_GameOver
    pop_regs dx,cx,bx,ax
    ret
endp MainBoard

proc setSnakeColor
    mov ax,13h
    int 10h
    set_cursor_pos 4,2
    print_str Example
    set_cursor_pos 4,107
    print_str instruc_design
    set_cursor_pos 21,45
    print_str Press_Enter
    mov [x1],40
    mov [x2],45
    mov [y1],60
    mov [y2],140
    print_snake_node [x1],[y1],[x2],[y2],[colorsnake]
    mov si,offset ColorsOptions
    mov [y1],50
    mov [y2],60
    mov [x1],260
    mov [x2],270
    DrawingPalette:
        print_snake_node [x1],[y1],[x2],[y2],[si]
        inc si
        add [y1],11
        add [y2],11
        cmp si,offset flagsc
        jne DrawingPalette
    tempMouse:
        mov ax,1
        int 33h
        WaitForKeyPressed3:
            in al,64h
            cmp al,10b
            je WaitForKeyPressed3
            in al,60h
            cmp al,1Ch
            je exitsetsnake
    MouseLp:
        mov ax,3h
        int 33h
        and bx,01h
        jz tempMouse
        mov ax,02h
        int 33h
        shr cx,1
        sub dx,1
        mov ah,0Dh
        int 10h
        cmp al,0
        je jmpmuose
        cmp al,15
        je jmpmuose
        mov [colorsnake],al
        mov [x1],40
        mov [x2],45
        mov [y1],60
        mov [y2],140
        print_snake_node [x1],[y1],[x2],[y2],[colorsnake]
    jmpmuose:
        jmp MouseLp
    exitsetsnake:
        ret
endp setSnakeColor

proc draw_borders
    push_regs ax,bx,cx,dx
    xor bl,bl
    mov al,15
    xor bh,bh
    mov ah,0Ch
    xor cx,cx
    xor dx,dx
    jmp Linee
    BottomLine_Settings:
        mov dx,170
    Linee:
        int 10h
        inc cx
        cmp cx,320
        jne Linee
        inc dx
        xor cx,cx
        cmp bl,1
        je Check_BottomLine
        cmp dx,5
        jne Linee
        mov bl,1
        jmp BottomLine_Settings
    Check_BottomLine:
        cmp dx,175
        jne Linee
        xor bl,bl
        xor cx,cx
        xor dx,dx
        jmp Line2
    RightLine_Settings:
        mov cx,315
    Line2:
        int 10h
        inc dx
        cmp dx,175
        jne Line2
        inc cx
        xor dx,dx
        cmp bl,1
        je Check_RightLine
        cmp cx,5
        jne Line2
        mov bl,1
        jmp RightLine_Settings
    Check_RightLine:
        cmp cx,320
        jne Line2
    pop_regs dx,cx,bx,ax
    ret
endp draw_borders
proc PlaySnake
    push_regs ax,bx,cx,dx
    Main_Loop:
        set_cursor_pos 23,22
        call stopnoise
        oo:
        cmp [arr.endy],170
        jae beforeOutlop
        cmp [arr.endx],312
        jae beforeOutlop
        cmp [arr.x],7
        jle beforeOutlop
        cmp [arr.y],7
        jle beforeOutlop
        mov ax,[arr.x]
        cmp [arr.endx],ax
        je beforeOutlop
        mov bx,offset arr.direcN

       WaitForKeyPressed:
            in al,64h
            cmp al,10b
            je WaitForKeyPressed
            in al,60h
            jmp checkKey
        beforeOutlop:
            jmp outlop
        checkKey:
            cmp al,4Bh
            je left_Key
            cmp al,50h
            je down_Key
            cmp al,4Dh
            je right_Key
            cmp al,48h
            je up_Key
            cmp [arr.direcB],1
            je up_Key
            cmp [arr.direcB],2
            je down_Key
            cmp [arr.direcB],3
            je left_Key
            cmp [arr.direcB],4
            je right_Key
        left_Key:
            cmp [arr.direcB],4
            je Move_Snake
            mov [byte ptr bx],3
            jmp Move_Snake
        right_Key:
            cmp [arr.direcB],3
            je Move_Snake
            mov [byte ptr bx],4
            jmp Move_Snake
        down_Key:
            cmp [arr.direcB],1
            je Move_Snake
            mov [byte ptr bx],2
            jmp Move_Snake
        up_Key:
            cmp [arr.direcB],2
            je Move_Snake
            mov [byte ptr bx],1

    Move_Snake:
        flush_buffer
        call Settings_tomove
        cmp [flagout],1
        je outlop
        jmp Main_Loop
    outlop:
        pop_regs dx,cx,bx,ax
        ret
endp PlaySnake

proc Settings_tomove
    mov si,offset arr.x
    lophh:
        add si,11
        cmp [byte ptr si],0
        jne lophh
        sub si,11
        print_tail 0
        call Touching_Apple_Check
        call MoveTheSnake
        mov [flagout],0
        call Touching_Himself
        cmp [flagout],1
        je exitset
        mov si,offset arr.x
        print_snake_node_Loop:
            print_tail [colorsnake]
            add si,11
            cmp [byte ptr si],0
            jne print_snake_node_Loop
        timer_wait
        mov bx,offset arr.direcB
        copy:
            mov al,[bx+1]
            mov [bx],al
            add bx,11
            cmp [byte ptr bx],0
            jne copy
        exitset:
            ret
endp Settings_tomove

proc MoveTheSnake
    mov bx,offset arr.direcB
    setDirecB:
        mov al,[bx]
        mov [bx+12],al
        cmp [word ptr bx+23],0
        je outDirecB
        add bx,11
        jmp setDirecB
    outDirecB:
        mov bx,offset arr.direcN
        mov di,2
        xor cx,cx
        xor ax,ax
        mov dx,2
    MovDirecN:
        mov si,offset arr.x
        cmp [byte ptr bx],1
        je callup
        cmp [byte ptr bx],2
        je calldown
        cmp [byte ptr bx],3
        je callleft
        push bx
        mov bx,cx
        add [word ptr si+bx],5
        add [word ptr si+bx+4],5
        pop bx
        jmp checkmov
    callup:
        push bx
        mov bx,di
        sub [word ptr si+bx],5
        sub [word ptr si+bx+4],5
        pop bx
        jmp checkmov
    calldown:
        push bx
        mov bx,dx
        add [word ptr si+bx],5
        add [word ptr si+bx+4],5
        pop bx
        jmp checkmov
    callleft:
        push bx
        mov bx,aX
        sub [word ptr si+bx],5
        sub [word ptr si+bx+4],5
        pop bx
    checkmov:
        add bx,11
        add di,11
        add ax,11
        add cx,11
        add dx,11
        cmp [byte ptr bx],0
        jne MovDirecN
        ret
endp MoveTheSnake

proc Random_Values
    Again:
        random_get 29d
        mov bx,offset pointapple
        add bx,ax
        mov al,[bx]
        mov [randX],ax
        random_get 29d
        mov bx,offset pointapple
        add bx,ax
        mov al,[bx]
        add [randX],ax
        random_get 29d
        mov bx,offset pointapple
        add bx,ax
        mov al,[bx]
        mov [randY],ax
        mov [flagrand],0
        call CheckRandom
        cmp [flagrand],1
        je Again
        ret
endp Random_Values

proc CheckRandom
    get_tail_pos
    mov bx,offset arr.x
    sub bx,11
checkrand:
    add bx,11
    mov ax,[randX]
    cmp ax,[bx]
    je notgood
    mov ax,[randY]
    cmp ax,[bx+1]
    je notgood
    cmp si,bx
    jae notgood
    jmp checkrand
notgood:
    cmp si,bx
    jae outcheckrand
    mov [flagrand],1
outcheckrand:
    ret
endp CheckRandom

proc Touching_Himself
    cmp [arr.direcN],1
    je CheckUp
    cmp [arr.direcN],2
    je CheckDown
    cmp [arr.direcN],3
    je CheckLeft
    mov ax,[arr.y]
    mov [y1],ax
    add [y1],3
    mov ax,[arr.endx]
    inc ax
    mov [x1],ax
    get_pixel_color_by_pos [x1],[y1]
    cmp al,[colorsnake]
    je touchhimslef
    jmp outhimself
CheckUp:
    mov ax,[arr.x]
    mov [y1],ax
    add [y1],3
    mov ax,[arr.y]
    inc ax
    mov [x1],ax
    get_pixel_color_by_pos [y1],[x1]
    cmp al,[colorsnake]
    je touchhimslef
    jmp outhimself
CheckDown:
    mov ax,[arr.x]
    mov [y1],ax
    add [y1],3
    mov ax,[arr.endy]
    inc ax
    mov [x1],ax
    get_pixel_color_by_pos [y1],[x1]
    cmp al,[colorsnake]
    je touchhimslef
    jmp outhimself
CheckLeft:
    mov ax,[arr.y]
    mov [y1],ax
    add [y1],3
    mov ax,[arr.x]
    inc ax
    mov [x1],ax
    get_pixel_color_by_pos [x1],[y1]
    cmp al,[colorsnake]
    je touchhimslef
    jmp outhimself
touchhimslef:
    mov [flagout],1
outhimself:
    ret
endp Touching_Himself

proc Touching_Apple_Check
    add [randX],3
    add [randY],3
    get_pixel_color_by_pos [randX],[randY]
    sub [randX],3
    sub [randY],3
    cmp al,[colorsnake]
    je Apple_Touch
    jmp Exit_AppleTouch
Apple_Touch:
    inc [Score_Number]
    call PRINT_NUMBER
    call noise
    cmp [byte ptr si+9],2
    je is_down
    cmp [byte ptr si+9],3
    je is_left
    cmp [byte ptr si+9],1
    je bis_up
    cmp [byte ptr si+9],4
    je is_right
is_left:
    touchapple_add [si+2],[bx+2],[si+6],[bx+6],[si],[bx],[si+4],[bx+4],[si+8],[bx+8],[bx+9]
    jmp con
is_down:
    touchapple_sub [si],[bx],[si+4],[bx+4],[si+2],[bx+2],[si+6],[bx+6],[si+8],[bx+8],[bx+9]
    jmp con
bis_up:
    jmp is_up
is_right:
    touchapple_sub [si+2],[bx+2],[si+6],[bx+6],[si],[bx],[si+4],[bx+4],[si+8],[bx+8],[bx+9]
    jmp con
is_up:
    touchapple_add [si],[bx],[si+4],[bx+4],[si+2],[bx+2],[si+6],[bx+6],[si+8],[bx+8],[bx+9]
con:
    sub [randX],3
    sub [randY],3
    add [endRandX],3
    add [endRandY],3
    print_snake_node [randX],[randY],[endRandX],[endRandY],0
    call Random_Values
    set_node_edges
    print_snake_node [randX],[randY],[endRandX],[endRandY],4
Exit_AppleTouch:
    ret
endp Touching_Apple_Check
proc display_GameOver
    mov ax,0002h
    int 10h
    paint_characters 14,1,0,4,70
    paint_characters 6,5,0,8,70
    set_cursor_pos 1,0
    print_str g
    paint_characters 4,8,29,9,70
    set_cursor_pos 8,29
    print_str Present_Score
    call PRINT_NUMBER
    paint_characters 15,17,22,25,70
    set_cursor_pos 17,22
    print_str PressAny
    mov ah,1
    int 21h
    call MainBoard
    ret
endp display_GameOver

proc noise
    in al, 61h
    or al, 00000011b
    out 61h, al
    mov al, 0b6h
    out 43h, al
    mov ax, 1000h
    out 42h, al
    mov al, ah
    out 42h, al
    ret
endp noise

proc stopnoise
    in al, 61h
    and al, 11111100b
    out 61h, al
    ret
endp stopnoise

PROC PRINT_NUMBER
    PUSH BP
    mov bp, sp
    sub sp, 3*8
    mov ax,[Score_Number]
    mov [WORD PTR bp - 2*8], ax
    mov [BYTE PTR bp - 3*8], 0
getDigits:
    mov ax, [WORD PTR bp - 2*8]
    mov dx, 0
    mov bx, 10
    div bx
    push dx
    mov [WORD PTR bp - 2*8], ax
    inc [byte PTR bp - 3*8]
    cmp [WORD PTR bp - 2*8], 0
    je getDigitsEnd
    jmp getDigits
getDigitsEnd:
printDigits:
    cmp [BYTE PTR bp - 3*8], 0
    je printDigitsEnd
    pop ax
    add al, 30h
    mov ah, 0eh
    int 10h
    dec [BYTE PTR bp - 3*8]
    jmp printDigits
printDigitsEnd:
    mov sp, bp
    POP BP
    RET
ENDP PRINT_NUMBER

PROC wait_for_keypress
    MOV AH, 0
    INT 16h
    RET
ENDP wait_for_keypress

PROC show_title
    MOV AH, 0
    MOV AL, 3
    INT 10h
    CALL buffer_clear
    CALL buffer_render
    CALL sleep
    MOV SI, 0
next_:
    MOV BX, [title_ + SI]
    MOV [BYTE PTR buffer2 + BX], 219
    PUSH SI
    CALL buffer_render
    MOV SI, 1
    CALL sleep
    POP SI
    ADD SI, 2
    CMP SI, 274
    JL next_
    MOV SI, OFFSET text_1
    MOV DI, 1626
    CALL buffer_print_string
    MOV SI, OFFSET text_2
    MOV DI, 1781
    CALL buffer_print_string
wait_for_key:
    MOV SI, OFFSET text_3
    MOV DI, 1388
    CALL buffer_print_string
    CALL buffer_render
check_key:
    MOV AH, 1
    INT 16h
    JZ check_key
    MOV AH, 0
    MOV AL, 3
    INT 10h
    RET
ENDP show_title

PROC buffer_clear
    MOV CX, 2000
    XOR DI, DI
next_clear:
    MOV [BYTE PTR buffer2 + DI], ' '
    INC DI
    LOOP next_clear
    RET
ENDP buffer_clear

PROC buffer_render
    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, 0
    MOV SI, OFFSET buffer2
next_render:
    MOV AL, [SI]
    MOV [byte ptr ES:[DI]], AL
    INC SI
    ADD DI, 2
    CMP SI, OFFSET buffer2 + 2000
    JNZ next_render
    RET
ENDP buffer_render

PROC buffer_print_string
next_print:
    MOV AL, [SI]
    CMP AL, '$'
    JZ end_print
    MOV [BYTE PTR buffer2 + DI], AL
    INC DI
    INC SI
    JMP next_print
end_print:
    RET
ENDP buffer_print_string

PROC hide_cursor
    MOV AH, 01h
    MOV CH, 32h
    MOV CL, 0
    INT 10h
    RET
ENDP hide_cursor

PROC sleep
    MOV AH, 0
    INT 1Ah
    ADD DX, SI
wait_sleep:
    MOV AH, 0
    INT 1Ah
    CMP DX, SI
    JB wait_sleep
    RET
ENDP sleep

exit:
    mov ax, 4c00h
    int 21h
END start
