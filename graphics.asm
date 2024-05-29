.model small
.stack 100h
.386

.data

	is_over db 0
	
	intro_msg db "Welcome to Brick Breaker Game!", 0Dh, 0Ah, 0DH, 0Ah
          	  db "Use 'A' and 'D' keys to move the paddle left and right.", 0Dh, 0Ah, 0DH, 0Ah
           	  db "Break all the bricks to win the game.", 0Dh, 0Ah, 0DH, 0Ah
          	  db "Press any key to start...$"
			  
	exit_msg db 10,13,"GAME ENDED" , 10 , 13 , "You Scored : $"
	score dw 0

	window_width dw 140h								;the width of windows is  320p
	window_height dw 0c8h								;height of the window is 200p
	window_bounds dw 05h								;to check for the boundary to help proper bounce back of the ball
	
	time_var db 0h										; contains the prev elapsed time
	
	temp_brick_X dw 0
	temp_brick_Y dw 0
	
	bricks_X_1 dw 0fh, 4Bh, 87h, 0C3h, 0FFh
	bricks_Y1 dw 0fh
	
	bricks_X_2 dw 01Eh, 64h, 0AAh, 0F0h
	bricks_Y2 dw 1Ah

	bricks_X_3 dw 0fh, 4Bh, 87h, 0C3h, 0FFh 
	bricks_Y3 dw 25h

	bricks_X_4 dw 01Eh, 64h, 0AAh, 0F0h
	bricks_Y4 dw 30h
	bricks_height dw 05h
	bricks_width  dw 32h
	
	ball_original_X dw 80h								;original ball position at X when game starts
	ball_original_Y dw 64h								;original ball position at Y when game starts
	ball_X dw 80h										;current X position of the ball
	ball_Y dw 64h										;current Y position of the ball
	ball_velocity_X dw 02h								;speed of ball on X axis
	ball_velocity_Y dw 02h								;speed of ball on Y axis
	ball_size	dw 04h
	
	paddle_Width    equ 40       ; Width of the paddle
    paddle_Height   equ 5        ; Height of the paddle
    paddle_Color    equ 0fh       ; Color of the paddle (white)
    screenWidth     equ 320
    screenHeight    equ 200
    boundaryColor   equ 2        ; Green color
    leftKey         equ    'a'   ; Left movement key
    rightKey        equ    'd'      ; Right movement key								

    paddle_X        dw 0AEh
    paddle_Y        equ 190
    keyPressed      db 97h

.code


main proc

	mov ax , @data
	mov ds , ax

	call intro_page	
	call clear_screen
	
	check_time:
		
		mov ah , 2ch									;will contain CH = hours , Cl = miniutes , DH = seconds , dl = 1/100th second
		int 21h											;execute
		cmp dl , time_var								; compares current time with prev time to check if some time has passed
		je check_time
		
		mov time_var , dl								; updates the value of prev time to current time
		


        call Draw_Boundary_Top
        call Draw_Boundary_Bottom
        call Draw_Boundary_Left
        call Draw_Boundary_Right
        

		call move_ball			
		call move_Paddle
		
		call Load_Bricks

		call Draw_Ball
		call Draw_Paddle
		
		cmp is_over , 1
		je game_over
		
		cmp score , 180
		je game_over
		
		JMP check_time  								; after everything check time again 
	
	
game_over:
	call exit_page


mov ah , 4ch
int 21h


main endp





; Procedure to draw a row of the paddle
Draw_Row proc
    push cx                     ; Preserve cx
    push dx                     ; Preserve dx

Draw_Row_Loop:
    ; Draw a pixel at the current position
    mov ah, 0Ch                 ; BIOS function to set pixel
    mov al, paddle_Color        ; Color of the paddle
    int 10h                     ; Call BIOS interrupt to draw the pixel

    ; Move to the next column
    inc cx
    dec bx                      ; Decrement the counter for remaining pixels in the row
    jnz Draw_Row_Loop           ; Continue drawing if there are remaining pixels in the row

    pop dx                      ; Restore dx
    pop cx                      ; Restore cx
    ret

Draw_Row endp

Draw_Boundary_Top proc
    mov cx, 0                   ; Start column
    mov dx, 0                   ; Start row

Draw_Boundary_Top_Loop:
    mov ah, 0Ch                 ; Write pixel
    mov al, boundaryColor
    int 10h
    inc cx                      ; Next column
    cmp cx, screenWidth
    jl Draw_Boundary_Top_Loop  ; Loop until end of row
    ret
Draw_Boundary_Top endp

Draw_Boundary_Bottom proc
    mov cx, 0                   ; Start column
    mov dx, screenHeight - 1    ; Start row (bottom row)

Draw_Boundary_Bottom_Loop:
    mov ah, 0Ch                 ; Write pixel
    mov al, boundaryColor
    int 10h
    inc cx                      ; Next column
    cmp cx, screenWidth
    jl Draw_Boundary_Bottom_Loop  ; Loop until end of row
    ret
Draw_Boundary_Bottom endp

Draw_Boundary_Left proc
    mov cx, 0                   ; Start column
    mov dx, 0                   ; Start row

Draw_Boundary_Left_Loop:
    mov ah, 0Ch                 ; Write pixel
    mov al, boundaryColor
    int 10h
    inc dx                      ; Next row
    cmp dx, screenHeight
    jl Draw_Boundary_Left_Loop  ; Loop until end of column
    ret
Draw_Boundary_Left endp

Draw_Boundary_Right proc
    mov cx, screenWidth - 1     ; Start column (rightmost column)
    mov dx, 0                   ; Start row

Draw_Boundary_Right_Loop:
    mov ah, 0Ch                 ; Write pixel
    mov al, boundaryColor
    int 10h
    inc dx                      ; Next row
    cmp dx, screenHeight
    jl Draw_Boundary_Right_Loop  ; Loop until end of column
    ret
Draw_Boundary_Right endp







Draw_Paddle proc
    mov cx, paddle_X            ; Initial position of paddle's top-left corner (column)
    mov dx, paddle_Y            ; Initial position of paddle's top-left corner (row)

Draw_Paddle_Loop:
    ; Draw a row of the paddle
    mov ax, paddle_X
    mov bx, paddle_Width        ; Width of the paddle (number of pixels in a row)
    call Draw_Row

    ; Move to the next row
    inc dx

    ; Check if all rows have been drawn
    mov ax, dx
    sub ax, paddle_Y            ; Compare the number of rows drawn with paddle height
    cmp ax, paddle_Height
    jle Draw_Paddle_Loop        ; Continue drawing if not all rows have been drawn

    ret

Draw_Paddle endp







Erase_Paddle proc
    mov cx, paddle_X                ; Initial position of paddle's top-left corner (column)
    mov dx, paddle_Y                ; Initial position of paddle's top-left corner (row)

Erase_Paddle_Loop:
    ; Erase a row of the paddle
    mov ax, paddle_X
    mov bx, paddle_Width            ; Width of the paddle (number of pixels in a row)
    call Erase_Row

    ; Move to the next row
    inc dx

    ; Check if all rows have been erased
    mov ax, dx
    sub ax, paddle_Y                ; Compare the number of rows erased with paddle height
    cmp ax, paddle_Height
    jle Erase_Paddle_Loop           ; Continue erasing if not all rows have been erased

    ret

Erase_Paddle endp

Erase_Row proc
    push cx                         ; Preserve cx
    push dx                         ; Preserve dx

Erase_Row_Loop:
    ; Erase a pixel at the current position (by setting it to the background color)
    mov ah, 0Ch                     ; BIOS function to set pixel
    mov al, 0h                      ; Background color
    int 10h                         ; Call BIOS interrupt to draw the pixel

    ; Move to the next column
    inc cx
    dec bx                          ; Decrement the counter for remaining pixels in the row
    jnz Erase_Row_Loop             ; Continue erasing if there are remaining pixels in the row

    pop dx                          ; Restore dx
    pop cx                          ; Restore cx
    ret

Erase_Row endp





Check_Keypress proc
    mov ah, 1                   ; Check if a key has been pressed
    int 16h
    ret
Check_Keypress endp


Move_Paddle proc
    ; Erase the previous position of the paddle
    call Erase_Paddle

    mov ah, 1                   ; Check if a key has been pressed
    int 16h
    jz NoKeyPress               ; If no key has been pressed, skip movement

    mov ah, 0                   ; Read the pressed key
    int 16h
    cmp al, leftKey             ; Compare with left movement key
    je MoveLeft                 ; Move left if A key is pressed
    cmp al, rightKey            ; Compare with right movement key
    je MoveRight                ; Move right if D key is pressed

NoKeyPress:
    ret

MoveLeft:
    cmp paddle_X, 4             ; Check if the paddle is at the left boundary
    jle NoMovementLeft          ; If yes, don't move left further
    sub paddle_X, 4            ; Move the paddle left
    ret

MoveRight:
    mov ax, paddle_X
    add ax, paddle_Width
    cmp ax, [screenWidth-4]       ; Check if the paddle is at the right boundary
    jge NoMovementRight         ; If yes, don't move right further
    add paddle_X, 4          ; Move the paddle right
    ret

NoMovementLeft:
    ; Optional: Play a sound or display a message for hitting the left boundary
    ret

NoMovementRight:
    ; Optional: Play a sound or display a message for hitting the right boundary
    ret

Move_Paddle endp











;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
intro_page proc

 	    call clear_screen   	;Clear the screen
    
	    mov ax, 04h			;Set up the video mode and text attributes
            int 10h 			;Set text mode
    
    
    	    ;Display the introductory text
    	    mov ah, 09h        ; Display string function
    	    lea dx, intro_msg
    	    int 21h
    
    	   ;Wait for a key press
           mov ah, 00h
           int 16h
    
    ret
intro_page endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

exit_page proc

 	    call clear_screen   	;Clear the screen
    
	    mov ax, 04h			;Set up the video mode and text attributes
            int 10h 			;Set text mode
    
    
    	    ;Display the introductory text
    	    mov ah, 09h        ; Display string function
    	    lea dx, exit_msg
    	    int 21h
			
			mov ax , score
			call genericOutput
    	   ;Wait for a key press
           mov ah, 00h
           int 16h
    
    ret
exit_page endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
move_ball proc

	call Erase_Ball
	mov ax , ball_velocity_X
	add ball_X , ax
	
	mov ax , window_bounds
	sub ax , ball_size
	cmp ball_X , ax										;ball_X < 0 (yes -> ball collides with the left side)
	jl rev_ball_X
	
	mov ax , window_width
	sub ax , window_bounds
	sub ax , ball_size
	cmp ball_X , ax										;ball_X > window_width (yes-> ball collides with the right side)
	jg rev_ball_X
	
	mov ax , ball_velocity_Y
	add ball_Y , ax	

	mov ax , window_bounds
	sub ax , ball_size
	cmp ball_Y , ax										;ball_Y < 0 (yes -> ball collides with the upper side)
	jl rev_ball_Y
	
	mov ax , window_height
	sub ax , window_bounds
	sub ax , ball_size
	cmp ball_Y , ax										;ball_Y > window_height(yes-> ball collides with the bottom)
	jg player_out

	call Check_collision

	ret
	
	rev_ball_X:
		neg ball_velocity_X
		ret
		
	rev_ball_Y:
		neg ball_velocity_Y
		ret
		
	player_out:
		mov is_over , 1
		ret
	
move_ball endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Erase_Ball proc
    ; Draw over the ball's previous position with the background color
    mov cx , ball_X     								; initial position of column
    mov dx , ball_Y    									; initial position of row 

Erase_Ball_Loop: 
    mov ah , 0ch        								; write to pixel
    mov al , 00h        								; background color (black)
    int 10h             								; execute with the configurations

    inc cx              								; go to next column
    mov ax , cx
    sub ax , ball_X     								; compare number of pixels marked in columns
    cmp ax , ball_size
    JLE Erase_Ball_Loop
    
    mov cx ,  ball_X    								; reset the column to initial
    inc dx             									; move to the next row
    mov ax , dx
    sub ax , ball_Y     								; compare number of pixels marked in rows
    cmp ax , ball_size
    JLE Erase_Ball_Loop

    ret
Erase_Ball endp


Reset_Ball_Position proc

	mov ax , ball_original_X
	mov ball_X , ax
	
	mov ax , ball_original_Y
	mov ball_Y , ax
	
	ret
Reset_Ball_Position endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Draw_Ball proc


	mov cx , ball_X										; intial position of column
	mov dx , ball_Y										;initial position of column 

Draw_Ball_Loop:	
		mov ah , 0ch									; write to pixel
		mov al , 0fh									;colour of ball is white
		int 10h											;execute with the configurations

		inc cx											; goes to next column
		mov ax , cx
		sub ax , ball_X									; compares number of pixels marked in columns
		cmp ax , ball_size
		JLE Draw_Ball_Loop
		
		mov cx ,  ball_X								; resets the coloumn to intial
		
		inc dx											; moves to the next row
		mov ax , dx			
		sub ax , ball_Y									; compares number of pixels marked in rows
		cmp ax , ball_size
		JLE Draw_Ball_Loop

	ret
Draw_Ball endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_screen proc

	mov ah , 00h										;set's configuration mode to vedio
	mov al , 04h										;select vedio mode
	int 10h
	
	mov ah , 0bh										;set configuration for background/pallete
	mov bh , 00h										;select background
	mov bl , 00h										;color it black
	int 10h												;execute 
	

	ret
clear_screen endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Draw_bricks proc
	
	
next_brick:
	mov cx , [si]										;move first element of brick_x in cx
	mov dx , [di]										;mov brick_y is dx

draw_brick_loop:
	
	; works on same principle and drawing the paddle
	
	mov ah, 0ch
	mov al, 0fh
	int 10h

	inc cx
	mov ax,cx
	sub ax , [si]
	cmp ax, bricks_width
	jle draw_brick_loop

	mov cx, [si]
	inc dx
	mov ax, dx
	sub ax, [di]
	cmp ax, bricks_height
	jle draw_brick_loop
	
	add si, 2											;increments by 2 since our array is dw
	dec bx												;contains number of bricks to print in a row
	jnz next_brick 

	ret

	
Draw_bricks endp

Load_Bricks proc

		mov si, offset bricks_X_1 						;row1 coordinates	
		mov di, offset bricks_Y1 
		mov bx, 5                   					;no. of bricks
		call Draw_bricks

		mov si, offset bricks_X_2  						;row2 coordinates
		mov di, offset bricks_Y2
		mov bx, 4		   		 						;no. of bricks
		call Draw_bricks
		
		mov si, offset bricks_X_3  						;row3 coordinates	
		mov di, offset bricks_Y3 
		mov bx, 5                   					;no. of bricks
		call Draw_bricks
	
		mov si, offset bricks_X_4  						;row4 coordinates
		mov di, offset bricks_Y4
		mov bx, 4		   	 							;no. of bricks
		call Draw_bricks
	ret
Load_Bricks endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Check_collision proc

;ball_X + ball_size  > paddle_X &&  ball_X < paddle_X + paddle_width
; && ball_Y + ball_size > paddle_Y && ball_Y < paddle_Y +  paddle_height

	mov ax , ball_X										;condition 1
	add ax , ball_size
	cmp ax , paddle_X
	jle ball_not_collide

	mov ax , paddle_X									;condition 2
	add ax , paddle_width
	cmp ax , ball_X
	jle ball_not_collide
	
	mov ax , ball_Y										;condition 3
	add ax , ball_size
	cmp ax , paddle_Y
	jle ball_not_collide
	
	mov ax , paddle_Y									;condition 4
	add ax , paddle_height
	cmp ax , ball_Y
	jle ball_not_collide
	
	neg ball_velocity_Y

ball_not_collide:
		
		lea si , bricks_X_4								;load si with offset of row 4 bricks
		mov bx , bricks_Y4								; bx wil contain the row position
		mov cx , 4										; number of bricks
		call check_collision_brick
		
		lea si , bricks_X_3								;load si with offset of row 3 bricks	
		mov bx , bricks_Y3								; bx wil contain the row position
		mov cx , 5										; number of bricks
		call check_collision_brick
		
		lea si , bricks_X_2								;load si with offset of row 2 bricks
		mov bx , bricks_Y2								; bx wil contain the row position
		mov cx , 4										; number of bricks
		call check_collision_brick
		
		lea si , bricks_X_1								;load si with offset of row 1 bricks
		mov bx , bricks_Y1								; bx wil contain the row position
		mov cx , 5										; number of bricks
		call check_collision_brick
		
		ret
Check_collision endp

check_collision_brick proc


; If the ball doesn't collide with the Paddle we will compare it with the bricks

;ball_X + ball_size  > Brick_X &&  ball_X < Brick_X + Brick_width
; && ball_Y + ball_size > Brick_Y && ball_Y < Brick_Y +  Brick_height


	mov temp_brick_Y , bx								; bx contains the Y position of bricks row
row:
	mov bx , [si]
	
	cmp bx , -999										; put a sentinal value for the bricks which are already removed
	je no_collision_brick
	
	mov temp_brick_X , bx								;condition 1
	
	mov ax , ball_X
	add ax , ball_size
	cmp ax , temp_brick_X
	jle no_collision_brick

	mov ax , temp_brick_X								;condition 2
	add ax , bricks_width
	cmp ax , ball_X
	jle no_collision_brick
	
	mov ax , ball_Y										;condition 3
	add ax , ball_size
	cmp ax , temp_brick_Y
	jle no_collision_brick
	
	mov ax , temp_brick_Y								;condition 4
	add ax , bricks_height
	cmp ax , ball_Y
	jle no_collision_brick
	
	mov bx , -999										; after confirming that the collision happens , we will put a sentinal value in it
	mov [si] , bx
	
	call clear_screen									; update the screen to remove the broken brick
	
	add score , 10
	neg ball_velocity_Y
	jmp exit_check_collision
	
no_collision_brick:
	add si , 2											; increment by 2 due to word type array
	dec cx
	jnz row


exit_check_collision:

ret
check_collision_brick endp

genericOutput proc

	mov cx,0
	mov bx , 10
again:	
	
	
	xor dx,dx
	div bx
	push dx
	
	inc cx
	cmp ax,0
	je print
	jmp again
	
print:
	pop dx
	cmp dl,9
	jbe digit
	add dl,7h
digit:
	add dl,30h
	mov ah,2h
	int 21h
	dec cx
	jnz print
	
	ret
genericOutput endp


end main