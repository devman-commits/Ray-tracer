.arch armv8-a
//blinn_phong_shader

//returns the surface normal at the hitpoint 
	.global shader
	shader:
	//core using normal, hitpoint, light position, and camera position.
	//calculates ambient diffuse (lambertian), and specular components using halfway vector
		movi v6.4s, #0
		movi v7.4s, #0
		fmov v8.4s, #-5.0
		fmov v9.4s, #1.0

		//origin (camera)
		movi v0.4s, #0
		movi v1.4s, #0
		movi v2.4s, #0

		//calculating hitpoint 
		fmul v13.4s, v3.4s, v17.4s
		fmul v14.4s, v4.4s, v17.4s
		fmul v16.4s, v5.4s, v17.4s
		fadd v13.4s, v13.4s, v0.4s
		fadd v14.4s, v14.4s, v1.4s
		fadd v15.4s, v15.4s, v2.4s

		//calculating surface normal
		fsub v6.4s, v13.4s, v6.4s
		fsub v7.4s, v14.4s, v7.4s
		fsub v8.4s, v15.4s, v8.4s
			//normalize 
				//calculating |vector|^2		 	
	 			fmul v9.4s, v6.4s, v6.4s
				fmla v9.4s, v7.4s, v7.4s
				fmla v9.4s, v8.4s, v8.4s
			 	
 				//frsqrte directly gives 1/(sqrtx) in one clock cycle
 				frsqrte v9.4s, v9.4s
			 		
				//normalizing X, Y, Z of all 4 vectors
				fmul v6.4s, v6.4s, v9.4s
			 	fmul v7.4s, v7.4s, v9.4s
			 	fmul v8.4s, v8.4s, v9.4s

		//view vector 
		fneg v3.4s, v3.4s
		fneg v4.4s, v4.4s
		fneg v5.4s, v5.4s

		//light vector 
		fsub v10.4s, v20.4s, v13.4s	
		fsub v11.4s, v21.4s, v14.4s
		fsub v12.4s, v22.4s, v16.4s
			//normalize 
				movi v9.4s, #0
				//calculating |vector|^2		 	
	 			fmul v9.4s, v10.4s, v10.4s
				fmla v9.4s, v11.4s, v11.4s
				fmla v9.4s, v12.4s, v12.4s
			 	
 				//frsqrte directly gives 1/(sqrtx) in one clock cycle
 				frsqrte v9.4s, v9.4s
			 		
				//normalizing X, Y, Z of all 4 vectors
				fmul v10.4s, v10.4s, v9.4s
			 	fmul v11.4s, v11.4s, v9.4s
			 	fmul v12.4s, v12.4s, v9.4s

		//halfway vector 
		movi  v17.4s, #0
		fadd  v17.4s, v3.4s, v10.4s
		fadd  v18.4s, v4.4s, v11.4s
		fadd  v19.4s, v5.4s, v12.4s
			//normalize 
				movi v9.4s, #0
				//calculating |vector|^2		 	
	 			fmul v9.4s, v17.4s, v17.4s
				fmla v9.4s, v18.4s, v18.4s
				fmla v9.4s, v19.4s, v19.4s
			 	
 				//frsqrte directly gives 1/(sqrtx) in one clock cycle
 				frsqrte v9.4s, v9.4s
			 		
				//normalizing X, Y, Z of all 4 vectors
				fmul v17.4s, v17.4s, v9.4s
			 	fmul v18.4s, v18.4s, v9.4s
			 	fmul v19.4s, v19.4s, v9.4s
				
		//adding ambient lighting intensity 
			movi v23.4s, #0
			movi v24.4s, #0
			movi v25.4s, #0

		//diffused intensity (lambertian)
			movi v20.4s, #0
			fmul v20.4s, v6.4s, v10.4s
			fmla v20.4s, v7.4s, v11.4s
			fmla v20.4s, v8.4s, v12.4s
			//clamp to greater than zero
			fcmge v15.4s, v20.4s, v30.4s
			and v20.16b, v20.16b, v15.16b

		//specular highlight 
			movi v21.4s, #0
			fmul v21.4s, v6.4s, v17.4s
			fmla v21.4s, v7.4s, v18.4s
			fmla v21.4s, v8.4s, v19.4s
			//clamp to greater than zero
			fcmge v15.4s, v21.4s, v30.4s
			and v21.16b, v21.16b, v15.16b
			fmul v21.4s, v21.4s, v21.4s
			fmul v21.4s, v21.4s, v21.4s
			fmul v21.4s, v21.4s, v21.4s
			fmul v21.4s, v21.4s, v21.4s

		//values of colours for sphere 
		//red sphere and white light 	
		fmov v3.4s, #1.0
		fmov v4.4s, #1.0
		fmov v5.4s, #1.0
		fmov v6.4s, #1.0
		movi v7.4s, #0
		movi v8.4s, #0
		fmov v9.4s, #0.125
		//ambient 
		fmul v23.4s, v6.4s, v9.4s
		fmul v24.4s, v7.4s, v9.4s
		fmul v25.4s, v8.4s, v9.4s
		//diffuse 
		fmla v23.4s, v6.4s, v20.4s
		fmla v24.4s, v7.4s, v20.4s
		fmla v25.4s, v8.4s, v20.4s
		//specular 
		fmla v23.4s, v3.4s, v21.4s
		fmla v24.4s, v4.4s, v21.4s
		fmla v25.4s, v5.4s, v21.4s

		//bg bitmask 
		//grey BG
		fmov v17.4s, #0.75
		fmov v18.4s, #0.75
		fmov v19.4s, #0.75
		//making hit mask for all not hit = 1
		mvn v15.16b, v26.16b
		//zero for all miss
		and v23.16b, v23.16b, v26.16b
		and v24.16b, v24.16b, v26.16b
		and v25.16b, v25.16b, v26.16b
		//zero for all hit
		and v17.16b, v17.16b, v15.16b
		and v18.16b, v18.16b, v15.16b
		and v19.16b, v19.16b, v15.16b
		//OR for getting all color values 
		orr v23.16b, v23.16b, v17.16b
		orr v24.16b, v24.16b, v18.16b
		orr v25.16b, v25.16b, v19.16b
		//scatar multiply with 255 amd return
		fmul v23.4s, v23.4s, v31.4s
		fmul v24.4s, v24.4s, v31.4s
		fmul v25.4s, v25.4s, v31.4s
		ret
		
