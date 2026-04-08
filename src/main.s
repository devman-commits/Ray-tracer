.arch armv8-a
.rodata


.global start
	start:
	 ldr x19, =framebuffer
	
	//loops thru each px calling ray_gen, checking instructions and calling shader 
	render_frame:

	//updates light sources X,Z coords using sine and cosine approx for revolving around y-axis
	animate_light:
