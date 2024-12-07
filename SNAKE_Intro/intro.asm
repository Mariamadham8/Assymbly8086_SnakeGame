.MODEL SMALL
.STACK 100h

.DATA
    score DW 0
    is_game_over DB 0

    ; 8 = up, 4 = down, 2 = left, 1 = right
    snake_direction DB 0

    snake_head_x DB 0
    snake_head_y DB 0
    snake_head_previous_x DB 0
    snake_head_previous_y DB 0
    snake_tail_x DB 0
    snake_tail_y DB 0
    snake_tail_previous_x DB 0
    snake_tail_previous_y DB 0

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

.CODE
MAIN PROC
    MOV AX, @DATA         ; Set up data segment
    MOV DS, AX
    MOV ES, AX

    CALL hide_cursor      ; Hide the cursor
    CALL show_title       ; Show the title screen
    CALL start_playing    ; Start the game logic
  
    CALL exit_process     ; Exit the program
MAIN ENDP

start_playing PROC
    ; Game logic can be implemented here
    MOV SI, OFFSET text_4
    MOV DI, 0
    CALL buffer_print_string
    RET
start_playing ENDP

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

exit_process PROC
    ; Exit program
    MOV AH, 4Ch
    INT 21h
    RET
exit_process ENDP

END MAIN
