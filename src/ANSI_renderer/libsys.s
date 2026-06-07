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

	half_block:		//upper half block
		.ascii "m\xE2\x96\x80"
	len_half_block= .-half_block

.section .text
	//itoa conversion
	//leave w0 for the number for conversion here and x19 for mem address and w3 for final result 
	.global itoa_rgb
		itoa_rgb:
		mov x2, #0
		mov x3, #0

		//hundred digits
			mov w23, #100
			udiv w3, w0, w23
			mul w2, w3, w23
			sub w0, w0, w2
			add w3, w3, #48
			strb w3, [x19], #1
			
		//tens digits
			mov w23, #10
			udiv w3, w0, w23
			mul w2, w3, w23
			sub w0, w0, w2
			add w3, w3, #48
			strb w3, [x19], #1

		//ones digit 
			add w0, w0, #48
			strb w0, [x19], #1
			ret 
						
	.global framebuffer_chunk
		framebuffer_chunk:
			//store lr and fp using sp
			stp x29, x30, [sp, #-16]!
			mov x29, sp

			fg_px_0:
				ldr x4, =ansi_fg
				mov x5, len_ansi_fg
				//fg_bg_fetch
				mov x20, #0
				sub x20, x5, #4
				ldr w3, [x4]
				str w3, [x19]	
				mov w3, #0
				ldr w3, [x4, x20]
				str w3, [x19, x20]
				
				add x19, x19, x5
				mov w0, w7
				bl itoa_rgb
				red_end_final_0:
				mov w3, #59
				strb w3, [x19], #1

				mov w0, w11
				bl itoa_rgb
				green_end_final_0:
				mov w3, #59			//59 is ascii for semicolon
				strb w3, [x19], #1

				mov w0, w15
				bl itoa_rgb
				blue_end_final_0:

			bg_px_1:

				ldr x4, =ansi_bg
				mov x5, len_ansi_bg
				//fg_bg_fetch
				mov x20, #0
				sub x20, x5, #4
				ldr w3, [x4]
				str w3, [x19]	
				mov w3, #0
				ldr w3, [x4, x20]
				str w3, [x19, x20]
				
				add x19, x19, x5
				mov w0, w8
				bl itoa_rgb
				red_end_final_1:
				mov w3, #59
				strb w3, [x19], #1

				mov w0, w12
				bl itoa_rgb
				green_end_final_1:
				mov w3, #59
				strb w3, [x19], #1

				mov w0, w16
				bl itoa_rgb
				blue_end_final_1:
				//parsing and writing upper half block
				mov w3, #0
				mov w2, #0
				ldr x2, =half_block
				ldr w3, [x2]
				str w3, [x19], #4
				
			fg_px_2:			
				ldr x4, =ansi_fg
				mov x5, len_ansi_fg
				//fg_bg_fetch
				mov x20, #0
				sub x20, x5, #4
				ldr w3, [x4]
				str w3, [x19]	
				mov w3, #0
				ldr w3, [x4, x20]
				str w3, [x19, x20]
				
				add x19, x19, x5
				mov w0, w9
				bl itoa_rgb
				red_end_final_2:
				mov w3, #59
				strb w3, [x19], #1

				mov w0, w13
				bl itoa_rgb
				green_end_final_2:
				mov w3, #59
				strb w3, [x19], #1

				mov w0, w17
				bl itoa_rgb
				blue_end_final_2:

			bg_px_3:
				ldr x4, =ansi_bg
				mov x5, len_ansi_bg
				//fg_bg_fetch
				mov x20, #0
				sub x20, x5, #4
				ldr w3, [x4]
				str w3, [x19]	
				mov w3, #0
				ldr w3, [x4, x20]
				str w3, [x19, x20]
				
				add x19, x19, x5
				mov w0, w10
				bl itoa_rgb
				red_end_final_3:
				mov w3, #59
				strb w3, [x19], #1

				mov w0, w14
				bl itoa_rgb
				green_end_final_3:
				mov w3, #59
				strb w3, [x19], #1

				mov w0, w18
				bl itoa_rgb
				blue_end_final_3:
				//parsing and writing upper half block
				mov w3, #0
				mov w2, #0
				ldr x2, =half_block
				ldr w3, [x2]
				str w3, [x19], #4

		framebuffer_chunk_end:
			
			// restoring lr and fp
				ldp x29, x30, [sp], #16	
				ret
