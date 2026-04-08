.arch armv8-a
//for sys_calls and framebuffer IO

.global sys_exit
	sys_exit:
		mov x8, 93
		svc 0
		ret

.global sys_write
	sys_write:


//for screen drawing by either ppm or using /dev/fb0 for direct screen drawing
.global fb_int


//pushes rendered pixel buffer from memory to output destination
.global fb_flush
