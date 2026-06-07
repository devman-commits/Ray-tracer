.arch armv8-a
.section .rodata
.align 4
offset_x: .float 0.0, 0.0, 1.0, 1.0
offset_y: .float 0.0, 1.0, 0.0, 1.0

.align 2
	ansi_reset_row:
		.ascii "\x1b[0m\n"
	len_ansi_reset_row= .-ansi_reset_row

	cleanup_str: .ascii "\x1b[0m\x1b[?25h\n"
	len_cleanup_str= .-cleanup_str

	ansi_frame_reset: .ascii "\x1b[H"
	len_ansi_frame_reset= .-ansi_frame_reset

.global start
	start:
		ldr x19, =framebuffer
		fmov v30.4s, #0.0		//min color value
		movi v31.4s, #255		//maximum color value
		ucvtf v31.4s, v31.4s	//convert 255 integer to float 255.0 
		fmov v28.4s, #0.0
		movi v29.4s, #1
		ucvtf v29.4s, v29.4s
		

			 //creates a ray direction using pixel x/y coords and camera fov
			 ray_gen: 	 
	 
	//loops thru each px calling ray_gen, checking instructions and calling shader 
.global render_frame
	render_frame:

	//updates light sources X,Z coords using sine and cosine approx for revolving around y-axis
	animate_light:

	end:
