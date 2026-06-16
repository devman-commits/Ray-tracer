.arch armv8-a
//test for checking whether ray hits the obj in scene 

.section .rodata
	
.section .text
	.global intersect_sphere
		intersect_sphere:
			//using right hand coordinate convection 
			//centre at (0.0, 0.0, -5.0) and radius square
			movi v6.4s, #0
			movi v7.4s, #0
			fmov v8.4s, #-5.0
			fmov v9.4s, #1.0

			//origin (camera)
			movi v0.4s, #0
			movi v1.4s, #0
			movi v2.4s, #0

			//L vector (L=O-C)
			movi v10.4s, #0
			movi v11.4s, #0
			movi v12.4s, #0
			fsub v10.4s, v0.4s, v6.4s
			fsub v11.4s, v1.4s, v7.4s
			fsub v12.4s, v2.4s, v8.4s

			//D dot L (b)
			movi v13.4s, #0
			fmul v13.4s, v3.4s, v10.4s
			fmla v13.4s, v4.4s, v11.4s
			fmla v13.4s, v5.4s, v12.4s

			//L dot L - R^2 (c)
			movi v14.4s, #0
			fmul v14.4s, v10.4s, v10.4s
			fmla v14.4s, v11.4s, v11.4s
			fmla v14.4s, v12.4s, v12.4s
			fsub v14.4s, v14.4s, v9.4s

			//discriminant b^2 - c
			movi v16.4s, #0
			fmul v16.4s, v13.4s, v13.4s
			fsub v16.4s, v16.4s, v14.4s

			//calculating value t
				//calculating bitmask first for discriminant in v15.4s
				fcmge v15.4s, v16.4s, v30.4s
				fsqrt v15.4s, v15.4s
				fneg v13.4s, v13.4s
				fsub v17.4s, v13.4s, v15.4s
				//bitwise compare and giving zeroes to all lanes where d is negative 
				and v17.16b, v17.16b, v15.16b
				mov v26.16b, v15.16b
				fcmge v15.4s, v17.4s, v30.4s
				and v17.16b, v17.16b, v15.16b
		ret
//.global intersect_wireframe_room
