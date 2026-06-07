.arch armv8-a
//for printing each frame
.section .rodata
.align 2
	ansi_reset_row:
		.ascii "\x1b[0m\n"
	len_ansi_reset_row= .-ansi_reset_row

	cleanup_str: .ascii "\x1b[0m\x1b[?25h\n"
	len_cleanup_str= .-cleanup_str

	ansi_frame_reset: .ascii "\x1b[H"
	len_ansi_frame_reset= .-ansi_frame_reset


.global flush_frame
	flush_frame:
		cmp x22, #60
		blt end 
		mov x8, #64
		mov x0, #1
		ldr x1, =framebuffer
		sub x2, x19, x1
		svc 0	
		b render_frame

	end:
		ret
