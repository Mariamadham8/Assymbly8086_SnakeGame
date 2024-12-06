
MODEL small
STACK 100h
P186            ; Enable 80186+ instructions like PUSHA and POPA

.data
    note dw 10                ; Placeholder for the current note frequency
    clock dw 0               ; Timer tick reference value
    filename db "getthem.imf", 0
    file_handle dw ?
    buffer db 18644 dup(0)   ; Reserve space for the IMF file content
    
     error_msg db "File error occurred!", 0Dh, 0Ah, "$"
 
   

.code
start:
    ; Initialize data segment
    mov ax, @data
    mov ds, ax
    
    ; Open the .imf file
    mov ah, 3Dh          ; DOS function to open file
    mov al, 0            ; Open for reading
    lea dx, filename     ; Filename address
    int 21h              ; Call DOS
    jc file_error        ; Jump if error
    mov file_handle, ax  ; Save file handle

    ; Read the .imf file content
    mov ah, 3Fh          ; DOS function to read file
    mov bx, file_handle  ; File handle
    lea dx, buffer       ; Buffer address
    mov cx, 18644        ; Number of bytes to read
    int 21h              ; Call DOS
    jc file_error        ; Jump if error

    ; Close the file
    mov ah, 3Eh          ; DOS function to close file
    mov bx, file_handle  ; File handle
    int 21h              ; Call DOS

    ; Set up buffer for playback
    lea si, buffer       ; Start of the buffer
    
    
    next_note:
    ; Check if the buffer has been fully processed
    cmp si, offset buffer + 18644
    jae exit_program

    ; Load the register and data
    mov dx, 0388h          ; OPL2 register select port
    mov al, [si]
    out dx, al             ; Write register value

    mov dx, 0389h          ; OPL2 data port
    mov al, [si + 1]
    out dx, al             ; Write data value

    ; Load the delay value (2 bytes)
    mov ax, word ptr [si + 2]
    mov [note], ax         ; Store the frequency divisor in `note`

    ; Play the sound
    call sound

    ; Advance to the next 4 bytes in the buffer
    add si, 4
    jmp next_note

    file_error:
    ; Handle file errors (optional)
    lea dx, error_msg
    mov ah, 09h
    int 21h
    jmp exit_program
    
    turn_off_sound:
    ; Disable the speaker (turn off sound)
    in al, 61h
    and al, 0FCh          ; Clear speaker enable bits
    out 61h, al

exit_program:
    ; Exit to DOS
    mov ax, 4C00h
    int 21h

; Timer procedure for delay
Timer proc
    pusha
    mov cx, 59000       ; Loop count for delay (adjustable)
DelayLoop:
    loop DelayLoop      ; Create delay by looping
    popa
    ret
Timer endp


; Sound procedure using the PC speaker
sound proc
    pusha

    ; Enable the speaker (turn on sound)
    in al, 61h
    or al, 03h
    out 61h, al

    ; Adjust the frequency for slower sound (increase frequency divisor)
    mov ax, [note]
    add ax, 2          ; Increase the divisor to slow down the frequency (adjust as needed)
    mov [note], ax       ; Update the note with the new divisor

    ; Set up the frequency
    mov al, 0B6h
    out 43h, al
    mov ax, [note]
    out 42h, al          ; Send the low byte of the frequency divisor
    mov al, ah
    out 42h, al          ; Send the high byte of the frequency divisor

    ; Delay for the duration of the note
    call Timer

    ; Disable the speaker (turn off sound)
    in al, 61h
    and al, 0FCh
    out 61h, al

    popa
    ret
sound endp


end start
