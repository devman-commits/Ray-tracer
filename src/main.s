.arch armv8-a
.section .rodata
.align 4
offset_x: .float 0.0, 0.0, 1.0, 1.0
offset_y: .float 0.0, 1.0, 0.0, 1.0
//1280 here
inv_width: .float 0.00078125, 0.00078125, 0.00078125, 0.00078125
inv_height: .float (1.0/720.0), (1.0/720.0), (1.0/720.0), (1.0/720.0)
aspect_ratio: .float (16.0/9.0), (16.0/9.0), (16.0/9.0), (16.0/9.0)

.section .bss
.align 4
	.global fb
		fb: .space 	262144
		fb_end: 

.global start
	start:
		ldr x26, =fb
		fmov v30.4s, #0.0		//min color value
		movi v31.4s, #255		//maximum color value
		ucvtf v31.4s, v31.4s	//convert 255 integer to float 255.0 
		fmov v28.4s, #0.0
		movi v29.4s, #1
		ucvtf v29.4s, v29.4s
		
	frame_start:
		mov w27, #0
		mov w28, #0
		bl ppm_ini
		//dates light sources X,Z coords using sine and cosine approx for revolving around y-axis
  	animate_light:
			
			 //creates a ray direction using pixel x/y coords and camera fov
			 ray_gen:
			 	px_normalize:
			 		//moving curent x and y into v0.4s and v1.4s
			 		dup v0.4s, w27
			 		dup v1.4s, w28
			 		ucvtf v0.4s, v0.4s
			 		ucvtf v1.4s, v1.4s
			 		ldr q2, =offset_x
			 		fadd v0.4s, v0.4s, v2.4s
			 		ldr q2, =offset_y
			 		fadd v1.4s, v1.4s, v2.4s
			 		//add 0.5 to offset the ray to px centre
			 		fmov v2.4s, #0.5
			 		fadd v0.4s, v0.4s, v2.4s
			 		fadd v1.4s, v1.4s, v2.4s

			 		//normalize screen dimensions to [0.0, 1.0]
			 		ldr q2, =inv_width
			 		fmul v0.4s, v0.4s, v2.4s
			 		ldr q2, =inv_height
			 		fmul v1.4s, v1.4s, v2.4s

			 		fmov v2.4s, #2.0
			 		fmov v3.4s, #1.0
					//for X
			 		fmul v0.4s, v0.4s, v2.4s
					fsub v0.4s, v0.4s, v3.4s
					//for Y
			 		fmul v1.4s, v1.4s, v2.4s
			 		fmul v1.4s, v3.4s, v1.4s
					//to prevent strectched image 
					ldr q2, =aspect_ratio
			 		fmul v0.4s, v0.4s, v2.4s

			 		//store -1.0 in v2.4s to represent screen one unit apart from the origin
			 		fmov v2.4s, #-1.0
			 		vec_normalize:
		 				//calculating |vector|^2		 	
		 				fmul v3.4s, v0.4s, v0.4s
						fmla v3.4s, v1.4s, v1.4s
		 				fmla v3.4s, v2.4s, v2.4s
			 		
	 					//frsqrte directly gives 1/(sqrtx) in one clock cycle
		 				frsqrte v4.4s, v3.4s
			 		
						//normalizing X, Y, Z of all 4 vectors
			 			fmul v3.4s, v0.4s, v4.4s
			 			fmul v4.4s, v1.4s, v4.4s
			 			fmul v5.4s, v2.4s, v4.4s
			 		bl intersect_sphere
	 
	//loops thru each px calling ray_gen, checking instructions and calling shader 
	//also kepps check of x and y coords
.global render_frame
	render_frame:
		
			flush_check:
			ldr x1, =fb_end
			sub x1, x1, #64
			cmp x23, x1
			bge flush_buffer
		//incrementing x and y coords of screen
		mov w0, #2
		add w27, w0
		cmp w27, #1280
		blt width_left 
		add w28, w0
		cmp w28, #720
		bge frame_flush
		mov w0, #1
		add w24, w0
		cmp w24, #100
		bg end 
		b frame_start
		width_left:
		b ray_gen
		
	end:
	mov x0, #0
	mov x8, #93
	svc 0
