.arch armv8-a
.section .rodata
.align 4
offset_x: .float 0.0, 1.0, 2.0, 3.0
offset_y: .float 0.0, 0.0, 0.0, 0.0
//1280 here
inv_width: .float 0.00078125, 0.00078125, 0.00078125, 0.00078125
inv_height: .float 0.0013888889, 0.0013888889, 0.0013888889, 0.0013888889
aspect_ratio: .float 1.77777778, 1.77777778, 1.77777778, 1.77777778

.section .bss
.align 4
	.global fb
		fb: .space 	262144

.section .text
.global _start
	_start:
		ldr x26, =fb
		movi v30.4s, #0     //minimum color value
    ucvtf v30.4s, v30.4s
    movi v31.4s, #255		//maximum color value
		ucvtf v31.4s, v31.4s	//convert 255 integer to float 255.0 
		
	frame_start:
		mov w27, #0
		mov w28, #0
		bl ppm_ini
		//dates light sources X,Z coords using sine and cosine approx for revolving around y-axis
  	animate_light:
		//sweeps from -50 to +50 in x for 100 frames
		//moving frame counter to light X
		dup v20.4s, w24
		ucvtf v20.4s, v20.4s
		fmov v27.4s, #0.25 
	    fmul v20.4s, v20.4s, v27.4s
    	fmov v27.4s, #25 
		fsub v20.4s, v20.4s, v27.4s 
    	//Y and Z permanent 
		fmov v21.4s, #0.75
	    fmov v22.4s, #-3.0

		  //creates a ray direction using pixel x/y coords and camera fov
			width_left:
			 ray_gen:
			 	px_normalize:
			 		//moving curent x and y into v0.4s and v1.4s
			 		dup v0.4s, w27
			 		dup v1.4s, w28
			 		ucvtf v0.4s, v0.4s
			 		ucvtf v1.4s, v1.4s
			 		ldr x9, =offset_x
			 		ldr q2, [x9]
			 		fadd v0.4s, v0.4s, v2.4s
			 		ldr x9, =offset_y
			 		ldr q2, [x9]
			 		fadd v1.4s, v1.4s, v2.4s
			 		//add 0.5 to offset the ray to px centre
			 		fmov v2.4s, #0.5
			 		fadd v0.4s, v0.4s, v2.4s
			 		fadd v1.4s, v1.4s, v2.4s

			 		//normalize screen dimensions to [0.0, 1.0]
			 		ldr x9, =inv_width
			 		ldr q2, [x9]
			 		fmul v0.4s, v0.4s, v2.4s
			 		ldr x9, =inv_height
			 		ldr q2, [x9]
			 		fmul v1.4s, v1.4s, v2.4s

			 		fmov v2.4s, #2.0
			 		fmov v3.4s, #1.0
					//for X
			 		fmul v0.4s, v0.4s, v2.4s
					fsub v0.4s, v0.4s, v3.4s
					//for Y
			 		fmul v1.4s, v1.4s, v2.4s
			 		fsub v1.4s, v3.4s, v1.4s
					//to prevent strectched image 
					ldr x9, =aspect_ratio
					ldr q2, [x9]
			 		fmul v0.4s, v0.4s, v2.4s

			 		//store -1.0 in v2.4s to represent screen one unit apart from the origin
			 		fmov v2.4s, #-1.0
			 		vec_normalize:
		 				//calculating |vector|^2		 	
		 				fmul v3.4s, v0.4s, v0.4s
						fmla v3.4s, v1.4s, v1.4s
		 				fmla v3.4s, v2.4s, v2.4s
			 		
	 					//frsqrte directly gives 1/(sqrtx) in one clock cycle
		 				frsqrte v9.4s, v3.4s
			 		
						//normalizing X, Y, Z of all 4 vectors
			 			fmul v3.4s, v0.4s, v9.4s
			 			fmul v4.4s, v1.4s, v9.4s
			 			fmul v5.4s, v2.4s, v9.4s
			 		bl intersect_sphere
	 
	//loops thru each px calling ray_gen, checking instructions and calling shader 
	//also kepps check of x and y coords
.global render_frame
	render_frame:
		bl shader
		bl rgb_px		
			flush_check:
			ldr x23, =fb
			sub x23, x26, x23
			ldr x2, =262000
			cmp x23, x2
			blt skip_bufferflush
			bl buffer_flush
		//incrementing x and y coords of screen
		skip_bufferflush:
		add w27, w27, #4
		cmp w27, #1280
		blt width_left 
		mov w27, #0
		add w28, w28, #1
		cmp w28, #720
		blt ray_gen
		bl buffer_flush
		bl frame_flush
		add w24, w24, #1
		cmp w24, #149
		bgt end 
		b frame_start
		
	end:
	mov x0, #0
	mov x8, #93
	svc 0
