.arch armv8-a
.section .data
	// \0 is null terminator for pathnames 
	filename: .ascii "output001.ppm\0"

	//P3 fprmat (human readable ppm file). width hieght, max_colour_value
	ppm_header: .ascii "P3\n1280 720\n255\n"
	len_header = .-ppm_header

.section .bss
//8 bytes reserve to store file ID
.align 4
	file_descriptor: .space 8
		
.section .text	
	.macro write_px lane
		//red
		umov w0, v23.4s[\lane]
			mov w2, #100
			udiv w3, w0, w2
			msub w0, w3, w2, w0
			add w3, w3, #48
			strb w3,[x26], #1

			mov w2, #10
			mov w3, #0
			udiv w3, w0, w2
			msub w0, w3, w2, w0
			add w3, w3, #48
			strb w3,[x26], #1

			add w0, w0, #48
			strb w0, [x26], #1

			//adding 0x20 for ' '
			mov w0, #0x20
			strb w0, [x26], #1

		//green	
		umov w0, v24.4s[\lane]
			mov w2, #100
			udiv w3, w0, w2
			msub w0, w3, w2, w0
			add w3, w3, #48
			strb w3, [x26], #1

			mov w2, #10
			mov w3, #0
			udiv w3, w0, w2
			msub w0, w3, w2, w0
			add w3, w3, #48
			strb w3, [x26], #1

			add w0, w0, #48
			strb w0, [x26], #1

			//adding 0x20 for ' '
			mov w0, #0x20
			strb w0, [x26], #1

		//blue 
		umov w0, v25.4s[\lane]
			mov w2, #100
			udiv w3, w0, w2
			msub w0, w3, w2, w0
			add w3, w3, #48
			strb w3, [x26], #1

			mov w2, #10
			mov w3, #0
			udiv w3, w0, w2
			msub w0, w3, w2, w0
			add w3, w3, #48
			strb w3, [x26], #1

			add w0, w0, #48
			strb w0, [x26], #1

			//adding 0x20 for ' '
			mov w0, #0x20
			strb w0, [x26], #1

			//adding newline character (0x0A)
			mov w0, #0x0A
			strb w0, [x26], #1

			.endm

	.global ppm_ini
	ppm_ini:
		update_flename:
			mov w0, w24
			ldr x1, =filename

			mov w2, #100
			udiv w3, w0, w2
			msub w0, w3, w2, w0
			add w3, w3, #48
			strb w3, [x1, #6]

			mov w2, #10
			mov w3, #0
			udiv w3, w0, w2
			msub w0, w3, w2, w0
			add w3, w3, #48
			strb w3,[x1, #7]

			add w0, w0, #48
			strb w0, [x1, #8]

		mov x8, #56
		mov x0, #-100
		ldr x1, =filename			
		mov x2, 0x241
		mov x3, #0666
		svc 0
		mov x25, x0		//saving file descriptor in x25

		//writing ppm header
		mov x0, x25
		ldr x1, =ppm_header
		mov x2, len_header
		mov x8, #64
		svc 0
		ret

	.global rgb_px 
		rgb_px:
		//red max min and convert to int 
		fmax v23.4s, v23.4s, v30.4s
		fmin v23.4s, v23.4s, v31.4s
		fcvtzs v23.4s, v23.4s

		//green max min and convert to int 
		fmax v24.4s, v24.4s, v30.4s
		fmin v24.4s, v24.4s, v31.4s
		fcvtzs v24.4s, v24.4s

		//blue max min and convert to int 
		fmax v25.4s, v25.4s, v30.4s
		fmin v25.4s, v25.4s, v31.4s
		fcvtzs v25.4s, v25.4s

			write_px 0
			write_px 1
			write_px 2
			write_px 3
			ret
	
	.global buffer_flush
		buffer_flush:
			ldr x1, =fb
			sub x2, x26, x1
			mov x0, x25
			mov x8, #64
			svc 0
			ldr x26, =fb
			ret

	.global frame_flush
		frame_flush:
			mov x0, x25
			mov x8, #57
			svc 0
			ret
