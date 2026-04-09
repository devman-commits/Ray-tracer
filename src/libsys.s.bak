.arch armv8-a
//for sys_calls and framebuffer IO

.global sys_exit
	sys_exit:
		mov x8, 93
		svc 0
		ret

//.global sys_write
		//sys_write:

//use direct terminal rendering using ANSI true colour rendering
.section .bss 
//since neon is of 128-bits, this aligns data blocks to 2^4 bytes to ensure neon could dump 128 bit wide info in memory without dealing with
//segmentation faluts related to loading from memory for unaligned chunks 
.align 4						
	.global framebuffer
		framebuffer:
		.space 262144	

.section .rodata
	ansi_fg: 
		.ascii "\x1b[38;2;"
	len_ansi_fg= .-ansi_fg

	ansi_bg:
		.ascii "m\x1b[48;2;"
	len_ansi_bg= .-ansi_bg

	ansi_reset:
		.ascii "\x1b[0m\n"
	len_ansi_reset= .-ansi_reset

	half_block:		//upper half block
		.ascii "m\xE2\x96\x80"
	len_half_block= .-half_block

	cleanup_str: .ascii "\x1b[0m\x1b[?25h\n"
	len_cleanup_str= .-cleanup_str

.section .text
	//itoa conversion
	//leave w0 for the number for conversion here and w1 for mem address and w3 for final result 
	.global itoa_rgb
		itoa_rgb:
		mov x2, 0
		mov x3, 0

		//hundred digits
			udiv w3, w0, 100
			mul w2, w3, 100
			sub w0, w2
			add w3, 48
			strb w3, [x1], 1
			
		//tens digits
			udiv w3, w0, 10
			mul w2, w3, 10
			sub w0, w2
			add w3, 48
			strb w3, [x1], 1

		//ones digit 
			add w0, 48
			strb w0, [x1], 1
			ret
			
