.arch armv8-a
//for printing each frame

.global flush_frame
	flush_frame:
		cmp x22, #60
		blt end 
		mov x8, #64
		mov x0, #1
		ldr x1, =framebuffer
		sub x2, x19, x1
		svc 0	
		b render_frame

	end:
		ret
