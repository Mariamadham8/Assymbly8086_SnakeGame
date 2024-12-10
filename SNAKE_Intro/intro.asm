.MODEL SMALL
.STACK 100h

.DATA
   
    buffer DB 2000 DUP(?)

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
            
    text_1 DB "    ~~~~~~~~~~~~~00-", '$'
    text_2 DB "WRITTEN IN ASSEMBLY 8086 LANGUAGE :)", '$'
    text_3 DB "PRESS ANY KEY TO START", '$'
    text_4 DB "                      ", '$'
    
    x1 dw ?           ; Variable to hold the x-coordinate of the first point of the snake
     x2 dw  ?           ; Variable to hold the x-coordinate of the second point of the snake
     y1 dw ?            ; Variable to hold the y-coordinate of the first point of the snake
     y2 dw ?            ; Variable to hold the y-coordinate of the second point of the snake
   colorsnake db 14                                ;variable hold the color of snake
    ColorsOptions db 14,6,10,2,11,3,9,1,13,5 
                       ; Color options for the palette
   flagsc db ?          ; Flag to indicate the end of the ColorsOptions array

    instruc_design db 'Pick A Color $' 
  Press_Enter db 'Press Enter To Start Playing$'
  Example db 'Example$'  


.CODE

; smoe macros definition
;----------------------------------------------->
set_cursor_pos MACRO row, column
    PUSH AX
    PUSH BX
    PUSH DX
    XOR BH, BH
    MOV AH, 02h
    MOV DH, row
    MOV DL, column
    INT 10h
    POP DX
    POP BX
    POP AX
ENDM
;-------------------------

; Macro for printing a string to the screen
print_str MACRO string
    PUSH AX
    PUSH DX
    LEA DX, string
    MOV AH, 09h
    INT 21h
    POP DX
    POP AX
ENDM
;----------------------------
; Macro to print a node of the snake using a 4-tuple position and color
print_snake_node MACRO sX, sY, eX, eY, color
    LOCAL line_start, column_start
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR BH, BH          ; Page number = 0
    MOV AH, 0Ch         ; Function: Write pixel
    MOV CX, sX          ; Start X-coordinate
    MOV DX, sY          ; Start Y-coordinate
    MOV AL, color       ; Color value

line_start:
    INT 10h             ; Draw a pixel
    INC CX              ; Move to the next pixel in X
    CMP CX, eX          ; Check if reached end X
    JNE line_start

    INC DX              ; Move to the next Y line
    MOV CX, sX          ; Reset X to start of line
    CMP DX, eY          ; Check if reached end Y
    JNE line_start

    POP DX
    POP CX
    POP BX
    POP AX
ENDM
;-----------------------

;----------------------------------------------------------->
MAIN PROC
    MOV AX, @DATA         ; Set up data segment
    MOV DS, AX
    MOV ES, AX
    
     ; Initialize mouse driver
    MOV AX, 0000h         ; Function 0: Initialize mouse
    INT 33h
    OR AX, AX             ; Check if mouse driver is installed
    JZ no_mouse           ; Jump if no mouse driver is detected

    CALL hide_cursor      ; Hide the cursor
    CALL show_title       ; Show the title screen
    CALL setSnakeColor    ; Show the color selection screen
    ; Clear screen
    MOV AH, 0
    MOV AL, 3             ; Video mode 3 (text mode)
    INT 10h

    CALL start_playing    ; Start the game logic
    CALL exit_process     ; Exit the program

no_mouse:
    ; Print error message and exit if no mouse is detected
    MOV AH, 09h
    INT 21h
    JMP exit_process
MAIN ENDP
;---------------------------------------------------
start_playing PROC
    ; Game logic can be implemented here
    MOV SI, OFFSET text_4
    MOV DI, 0
    CALL buffer_print_string
    RET
start_playing ENDP
;-----------------------------------------------------

show_title PROC
    ; Clear the screen using BIOS interrupt
    MOV AH, 0            ; Function 0: Clear screen and reset cursor
    MOV AL, 3            ; Video mode 3 (80x25 text mode)
    INT 10h

    CALL buffer_clear     ; Clear the buffer
    CALL buffer_render    ; Render the cleared buffer to the screen

    MOV SI, 18
    CALL sleep

    ; Title animation
    MOV SI, 0
next_:
    MOV BX, [title_ + SI]       ; Load position from title_
    MOV BYTE PTR [buffer + BX], 219  ; Draw block in buffer
    PUSH SI
    CALL buffer_render          ; Render the buffer
    MOV SI, 1
    CALL sleep
    POP SI
    ADD SI, 2
    CMP SI, 274
    JL next_

    ; Print text strings
    MOV SI, OFFSET text_1
    MOV DI, 1626
    CALL buffer_print_string

    MOV SI, OFFSET text_2
    MOV DI, 1781
    CALL buffer_print_string

    ; Wait for a key press
wait_for_key:
    MOV SI, OFFSET text_3      ; Load text_3 address into SI
    MOV DI, 1388               ; Set the buffer position
    CALL buffer_print_string   ; Print the "PRESS ANY KEY TO START" message
    CALL buffer_render         ; Render the buffer to the screen

check_key:
    MOV AH, 1                  ; Check for keypress
    INT 16h
    JZ check_key               ; Loop until a key is pressed

    ; Clear the screen after a key is pressed
    MOV AH, 0                  ; Function 0: Clear screen and reset cursor
    MOV AL, 3                  ; Video mode 3 (80x25 text mode)
    INT 10h

    RET           
show_title ENDP

buffer_clear PROC
    ; Clear the buffer with spaces
    MOV CX, 2000
    XOR DI, DI
next_clear:
    MOV BYTE PTR [buffer + DI], ' '
    INC DI
    LOOP next_clear
    RET
buffer_clear ENDP


buffer_render PROC
    ; Render buffer to screen
    MOV AX, 0B800h        ; Video memory segment
    MOV ES, AX
    MOV DI, 0
    MOV SI, OFFSET buffer
next_render:
    MOV AL, [SI]
    MOV BYTE PTR ES:[DI], AL
    INC SI
    ADD DI, 2             ; Skip attribute byte
    CMP SI, OFFSET buffer + 2000
    JNZ next_render
    RET
buffer_render ENDP

buffer_print_string PROC
    ; Print a null-terminated string into the buffer
next_print:
    MOV AL, [SI]
    CMP AL, '$'           ; End of string marker
    JZ end_print
    MOV BYTE PTR [buffer + DI], AL
    INC DI
    INC SI
    JMP next_print
end_print:
    RET
buffer_print_string ENDP

hide_cursor PROC
    ; Hide the cursor
    MOV AH, 01h
    MOV CH, 32h
    MOV CL, 0
    INT 10h
    RET
hide_cursor ENDP

sleep PROC
    ; Wait for SI * 55ms
    MOV AH, 0
    INT 1Ah
    ADD DX, SI
wait_sleep:
    MOV AH, 0
    INT 1Ah
    CMP DX, SI
    JB wait_sleep
    RET
sleep ENDP
;----------------------------------------------->

setSnakeColor proc
            mov ax,13h
            int 10h
            set_cursor_pos 4,2
            print_str Example
            set_cursor_pos 4,107
            print_str instruc_design
            set_cursor_pos 21,45
            print_str Press_Enter
        ;Draw Snake for showing examples for user
            mov [x1],40
            mov [x2],45
            mov [y1],60 
            mov [y2],140 
            print_snake_node [x1],[y1],[x2],[y2],[colorsnake]
        ;Drawing Palette of colors to user
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
                    in al,64h       ;check keyboard status
                    cmp al,10b
                    je WaitForKeyPressed3
                    ;
                    in al,60h       ;al hold the scan code  
                    cmp al,1Ch
                    je exitsetsnake
            ;Loop until mouse click
            MouseLp:
                mov ax,3h ;getting mouse status
                int 33h
                and bx,01h      ;check if left mouse clicked
                jz tempMouse ;00 in right bits means that no click
                   
                ;hide mouse
                mov ax,02h
                int 33h
                    
                shr cx,1        ;adjust cx to range 0-319 (before it was 639)
                sub dx,1        ;move back a little
                mov ah,0Dh      ;get Pixel Color
                int 10h
                cmp al,0        ;if it is not in the palette, so dont paint the snake
                je jmpmuose
                cmp al,15
                je jmpmuose
            ;Drawing New Snake with new color that have been chosen
                mov [colorsnake],al
                mov [x1],40
                mov [x2],45
                mov [y1],60 
                mov [y2],140 
                print_snake_node [x1],[y1],[x2],[y2],[colorsnake]
            jmpmuose:
                jmp MouseLp
   
     exitsetsnake:
    ; Clear the screen after a key is pressed
    MOV AH, 0                  ; Function 0: Clear screen and reset cursor
    MOV AL, 3                  ; Video mode 3 (80x25 text mode)
    INT 10h
       endp setSnakeColor
;------------------------------------------------------------------------->
     ;sound proced

;------------------------------------------------------------------------->
       
     exit_process PROC
    ; Exit program
    MOV AH, 4Ch
    INT 21h
    RET
exit_process ENDP
;-------------------------------------------------------------------------->


END MAIN
