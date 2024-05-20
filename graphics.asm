.model small
.stack 100h
.386

.data
	window_width dw 140h	;the width of windows is  320p
	window_height dw 0c8h	;height of the window is 200p
	window_bounds dw 05h		;to check for the boundary to help proper bounce back of the ball
	
	time_var db 0h	; contains the prev elapsed time
	
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
		
		call clear_screen
		
		call move_ball
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
	mov al , 13h		;select vedio mode
	int 10h
	
	mov ah , 0bh	;set configuration for background/pallete
	mov bh , 00h	;select background
	mov bl , 00h	;color it black
	int 10h			;execute 
	

	ret
clear_screen endp



























end main