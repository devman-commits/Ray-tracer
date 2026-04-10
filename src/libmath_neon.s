.arch armv8-a
//note-dont forget to save lr into memory and to later retrieve it from memory for these functions
//were using SoA (structure of arrays) method for neon vector registers utilization

.global vec_add
	vec_add:		
		fadd v6.4s, v0.4s, v3.4s
		fadd v7.4s, v1.4s, v4.4s
		fadd v8.4s, v2.4s, v5.4s
		ret
		
.global vec_sub
		fsub v6.4s, v0.4s, v3.4s
		fsub v7.4s, v1.4s, v4.4s
		fsub v8.4s, v2.4s, v5.4s
		ret

.global vec_dot
	vec_dot:
		fmul v6.4s, v0.4s, v3.4s
		fmla v6.4s, v1.4s, v4.4s
		fmla v6.4s, v2.4s, v5.4s
		ret

//vec axb for four rays, output in v6(X), v7(Y), v8(Z) 		
.global vec_cross
	vec_cross:
		fmul v6.4s, v1.4s, v5.4s
		fmls v6.4s, v2.4s, v4.4s

		fmul v7.4s, v2.4s, v3.4s
		fmls v7.4s, v0.4s, v5.4s

		fmul v8.4s, v0.4s, v4.4s
		fmls v8.4s, v1.4s, v3.4s

//normalize vector to length 1
.global vec_normalize
	vec_normalize:
			//calculating |vector|^2

			fmul v3.4s, v0.4s, v0.4s
			fmla v3.4s, v1.4s, v1.4s
			fmla v3.4s, v2.4s, v2.4s

			//frsqrte directly gives 1/(sqrtx) in one clock cycle
			frsqrte v4.4s, v3.4s

			//normalizing X, Y, Z of all 4 vectors
			fmul v0.4s, v0.4s, v4.4s
			fmul v1.4s, v1.4s, v4.4s
			fmul v2.4s, v2.4s, v4.4s
			ret

//matrix of 4x4 transformation of a vector
//dont forget to edit the registerv3 for W values (0.0 for direcn change only and 1.0 for dirn change + movement)
//4x4 matrix columns are v15, v17, v18,v19 for X, Y, Z, W of the objext to move
//v6, v7, v8, v9 are output vectors X, Y, Z, W
.global mat4_transform
	mat4_transform:
			fmul v6.4s, v0.4s, v16.4s[0]	//=X*M00
			fmla v6.4s, v1.4s, v17.4s[0]	//=Y*M10	
			fmla v6.4s, v2.4s, v18.4s[0]	//=Z*M20
			fmla v6.4s, v3.4s, v19.4s[0]	//=W*M30

			fmul v7.4s, v0.4s, v16.4s[1]	//=X*M01
			fmla v7.4s, v1.4s, v17.4s[1]	//=Y*M11
			fmla v7.4s, v2.4s, v18.4s[1]	//=Z*M21
			fmla v7.4s, v3.4s, v19.4s[1]	//=W*M31

			fmul v8.4s, v0.4s, v16.4s[2]	//=X*M02
			fmla v8.4s, v1.4s, v17.4s[2]	//=Y*M12
			fmla v8.4s, v2.4s, v18.4s[2]	//=Z*M22
			fmla v8.4s, v3.4s, v19.4s[2]	//=W*M32

			fmul v9.4s, v0.4s, v16.4s[3]	//=X*M03
			fmla v9.4s, v1.4s, v17.4s[3]	//=Y*M13
			fmla v9.4s, v2.4s, v18.4s[3]	//=Z*M23
			fmla v9.4s, v3.4s, v19.4s[3]	//=W*M33
			ret

//multiplies vector by a scalar for four rays
//v3 has four distance values all equal to distance t or respective scalar to be multiplied by each vector
.global vector_scale_soa
	vector_scale_soa:
		fmul v6.4s, v0.4s, v3.4s
		fmul v7.4s, v1.4s, v3.4s
		fmul v8.4s, v2.4s, v3.4s
		ret

//for use later
	//store lr and fp using sp
	stp x29, x30, [sp, #-16]!
	mov x29, sp

	// restoring lr and fp
	ldp x29, x30, [sp], #16	
	ret
