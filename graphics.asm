.model small
.stack 100h
.386

.data
	window_width dw 140h	;the width of windows is  320p
	window_height dw 0c8h	;height of the window is 200p
	window_bounds dw 05h		;to check for the boundary to help proper bounce back of the ball
	
	time_var db 0h	; contains the prev elapsed time
	
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
	
	ball_original_X dw 0Ah
	ball_original_Y dw 0Ah
	ball_X dw 0Ah
	ball_Y dw 0Ah
	ball_velocity_X dw 02h
	ball_velocity_Y dw 02h
	ball_size	dw 04h
	
	paddle_X dw 97h
	paddle_Y dw 0BEh
	
	paddle_width dw 2Ah
	paddle_height dw 04h
	paddle_velocity dw 05h								;speed of the paddle


.code


main proc

	mov ax , @data
	mov ds , ax
	
	call clear_screen
	
	check_time:
		
		mov ah , 2ch		;will contain CH = hours , Cl = miniutes , DH = seconds , dl = 1/100th second
		int 21h				;execute
		cmp dl , time_var	; compares current time with prev time to check if some time has passed
		je check_time
		
		mov time_var , dl	; updates the value of prev time to current time
		
		call move_ball
		call move_Paddle
		
		call Load_Bricks

		call Draw_Ball
		call Draw_Paddle
		
		JMP check_time  	; after everything check time again 
		mov ah , 00h
		int 16h
	
	


mov ah , 4ch
int 21h


main endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
move_ball proc

	call Erase_Ball
	mov ax , ball_velocity_X
	add ball_X , ax
	
	mov ax , window_bounds
	sub ax , ball_size
	cmp ball_X , ax		;ball_X < 0 (yes -> ball collides with the left side)
	jl rev_ball_X
	
	mov ax , window_width
	sub ax , window_bounds
	sub ax , ball_size
	cmp ball_X , ax			;ball_X > window_width (yes-> ball collides with the right side)
	jg rev_ball_X
	
	mov ax , ball_velocity_Y
	add ball_Y , ax	

	mov ax , window_bounds
	sub ax , ball_size
	cmp ball_Y , ax			;ball_Y < 0 (yes -> ball collides with the upper side)
	jl rev_ball_Y
	
	mov ax , window_height
	sub ax , window_bounds
	sub ax , ball_size
	cmp ball_Y , ax			;ball_Y > window_height(yes-> ball collides with the bottom)
	jg ball_reset

	call Check_collision

	ret
	
	rev_ball_X:
		neg ball_velocity_X
		ret
		
	rev_ball_Y:
		neg ball_velocity_Y
		ret
		
	ball_reset:
		call Reset_Ball_Position
		ret
	
move_ball endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Erase_Ball proc
    ; Draw over the ball's previous position with the background color
    mov cx , ball_X     ; initial position of column
    mov dx , ball_Y     ; initial position of row 

Erase_Ball_Loop: 
    mov ah , 0ch        ; write to pixel
    mov al , 00h        ; background color (black)
    int 10h             ; execute with the configurations

    inc cx              ; go to next column
    mov ax , cx
    sub ax , ball_X     ; compare number of pixels marked in columns
    cmp ax , ball_size
    JLE Erase_Ball_Loop
    
    mov cx ,  ball_X    ; reset the column to initial
    
    inc dx              ; move to the next row
    mov ax , dx
    sub ax , ball_Y     ; compare number of pixels marked in rows
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


	mov cx , ball_X		; intial position of column
	mov dx , ball_Y		;initial position of column 

Draw_Ball_Loop:	
		mov ah , 0ch		; write to pixel
		mov al , 0fh		;colour of ball is white
		int 10h				;execute with the configurations

		inc cx				; goes to next column
		mov ax , cx
		sub ax , ball_X		; compares number of pixels marked in columns
		cmp ax , ball_size
		JLE Draw_Ball_Loop
		
		mov cx ,  ball_X		; resets the coloumn to intial
		
		inc dx				; moves to the next row
		mov ax , dx			
		sub ax , ball_Y		; compares number of pixels marked in rows
		cmp ax , ball_size
		JLE Draw_Ball_Loop

	ret
Draw_Ball endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Draw_Paddle proc

	mov cx , paddle_X
	mov dx , paddle_Y
	
draw_paddle_loop:
		mov ah , 0ch		; write to pixel
		mov al , 03h		;colour of paddle is Cyan
		int 10h				;execute with the configurations
		
		inc cx				;move to next column
		mov ax,cx
		sub ax , paddle_X
		cmp ax , paddle_width	; compares number of pixels marked in columns
		jle draw_paddle_loop
		
		mov cx , paddle_X		; resets the coloumn to intial
		
		inc dx				; moves to the next row
		mov ax , dx
		sub ax , paddle_Y
		cmp ax , paddle_height	; compares number of pixels marked in rows
		jle draw_paddle_loop
		
	ret
Draw_Paddle endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_screen proc

	mov ah , 00h	;set's configuration mode to vedio
	mov al , 04h		;select vedio mode
	int 10h
	
	mov ah , 0bh	;set configuration for background/pallete
	mov bh , 00h	;select background
	mov bl , 00h	;color it black
	int 10h			;execute 
	

	ret
clear_screen endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Draw_bricks proc
	
	
next_brick:
	mov cx , [si]
	mov dx , [di]	

draw_brick_loop:

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
	
	add si, 2
	dec bx
	jnz next_brick 

	ret

	
Draw_bricks endp

Load_Bricks proc

		mov si, offset bricks_X_1 ;row1 coordinates	
		mov di, offset bricks_Y1 
		mov bx, 5                   ;no. of bricks
		call Draw_bricks

		mov si, offset bricks_X_2  ;row2 coordinates
		mov di, offset bricks_Y2
		mov bx, 4		    ;no. of bricks
		call Draw_bricks
		
		mov si, offset bricks_X_3  ;row3 coordinates	
		mov di, offset bricks_Y3 
		mov bx, 5                   ;no. of bricks
		call Draw_bricks
	
		mov si, offset bricks_X_4  ;row4 coordinates
		mov di, offset bricks_Y4
		mov bx, 4		    ;no. of bricks
		call Draw_bricks
	ret
Load_Bricks endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

move_Paddle proc

	call Erase_Paddle

	; first we will check if any key is being pressed
	mov ah , 01h
	int 16h
	
	;if no key is pressed our zero flag is set
	jz exit_move_Paddle
	
	;if the control reaches here it means that some key was oressed so we check which key is pressed
	
	mov ah , 00h
	int 16h
	
	or al , 32											; this will check for both capital and small key in one comparision
	
	cmp al , 'a'										;if key 'a' is pressed we will move the paddle to left
	je move_Paddle_left
	
	cmp al , 'd'										;if key 'd' is pressed we will move the paddle to the right
	je move_Paddle_right
	
move_Paddle_left:
		mov ax , paddle_velocity
		sub paddle_X , ax								;moves paddle_X to left
		
		mov ax , window_bounds							
		cmp paddle_X , ax								;Check for paddle going out if boundary
		jl fix_paddle_position_left						;(yes -> fix the paddle near the boundary)
		jmp exit_move_Paddle
		
	fix_paddle_position_left:
			mov ax , window_bounds
			mov paddle_X , ax							;fixes the paddle
			jmp exit_move_Paddle
			
move_Paddle_right:
		mov ax , paddle_velocity
		add paddle_X , ax								;moves paddle_X to right
		
		mov ax, window_width
		sub ax , window_bounds
		sub ax , paddle_width
		
		cmp paddle_X , ax								;Check for paddle going out if boundary
		jg fix_paddle_position_right					;(yes -> fix the paddle near the boundary)
		jmp exit_move_Paddle
		
	fix_paddle_position_right:
			mov paddle_X , ax							;fixes the paddle
			jmp exit_move_Paddle
	
exit_move_Paddle:
	ret
move_Paddle endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Erase_Paddle proc

	mov cx , paddle_X
	mov dx , paddle_Y
	
Erase_paddle_loop:
		mov ah , 0ch		; write to pixel
		mov al , 00h		;colour of paddle is Black
		int 10h				;execute with the configurations
		
		inc cx				;move to next column
		mov ax,cx
		sub ax , paddle_X
		cmp ax , paddle_width	; compares number of pixels marked in columns
		jle Erase_paddle_loop
		
		mov cx , paddle_X		; resets the coloumn to intial
		
		inc dx				; moves to the next row
		mov ax , dx
		sub ax , paddle_Y
		cmp ax , paddle_height	; compares number of pixels marked in rows
		jle Erase_paddle_loop
		
	ret
Erase_Paddle endp


Check_collision proc

;ball_X + ball_size  > paddle_X &&  ball_X < paddle_X + paddle_width   ; && ball_Y + ball_size > paddle_Y && ball_Y < paddle_Y +  paddle_height

	mov ax , ball_X
	add ax , ball_size
	cmp ax , paddle_X
	jle ball_not_collide

	mov ax , paddle_X
	add ax , paddle_width
	cmp ax , ball_X
	jle ball_not_collide
	
	mov ax , ball_Y
	add ax , ball_size
	cmp ax , paddle_Y
	jle ball_not_collide
	
	mov ax , paddle_Y
	add ax , paddle_height
	cmp ax , ball_Y
	jle ball_not_collide
	
	neg ball_velocity_Y

ball_not_collide:
	ret
Check_collision endp




end main