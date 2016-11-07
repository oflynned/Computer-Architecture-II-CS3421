option casemap:none             ; case sensitive
 
includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

extern		printf:NEAR             ; printf

.code

public      fib_x64                 ; make sure function name is exported

fib_x64:    mov     rax, rcx        ; rax = n
            cmp     rax, 1          ; if (n <= 1)
            jle     fib_x64_1       ; return n
            xor     rdx, rdx        ; fi = 0
            mov     rax, 1          ; fj = 1
fib_x64_0:  cmp     rcx, 1          ; while (n > 1)
            jle     fib_x64_1       ;
            mov     r10, rax        ; t = fj
            add     rax, rdx        ; fi = fi + fj
            mov     rdx, r10        ; fi = t
            dec     rcx             ; n--
            jmp     fib_x64_0       ;
fib_x64_1:  ret                     ; return rax
    
;
;   _int64 xp2(_int64 a, _int64 b)
;   {
;       printf("a = %I64d b = %I64d a+b = %I64d\n", a, b, a + b);
;       return a + b;
;   }
;

;
; parameter a       rcx
; parameter b       rdx
;

fxp2        db      'a = %I64d b = %I64d a*b = %I64d', 0AH, 00H     ; string in code section,  OAH = LF

public      xp2                             ; make sure function name is exported

xp2:        push    rbx						; save rbx
            ;sub     rsp, 32                 ; allocate shadow space {runtime error if not allocated}
            lea     r9, [rcx]		        ; printf parameter 4 in r9 {a*b}
			lea		r8, [rdx]				; load param b into temp r8
			imul	r9, r8					; printf parameter 4 in r9 {a*b}
            mov     r8, rdx                 ; printf parameter 3 in r8 {b}
            mov     rdx, rcx                ; printf parameter 2 in rdx {a}
            lea     rcx, fxp2               ; printf parameter 1 in rcx {&fxp2}
            mov     rbx, r9                 ; save r9 in rbx so sum preserved across call printf
            call    printf                  ; call printf
            mov     rax, rbx                ; rax = rbx {a+b}
            ;add     rsp, 32                 ; deallocate shadow space
            pop     rbx                     ; restore rbx
            ret

; globals
public		g		
g			QWORD	256

public		p
p:			push	rbp
			mov		rbp, rsp

			lea		rax, [rcx]
			lea		rbx, [rdx]
			add		rax, rbx
			shl		rax, 2
			dec		rax
			
			mov		rsp, rbp
			pop		rbp			
			ret

public		q
q:			push	rbp
			mov		rbp, rsp

			sub		rsp, 32				; allocate a shadow space of 32 bytes as is calling func
			mov		rdx, rcx			; move i from 1st param to 2nd param pos
			imul	rdx, -1				; negate the sign of the i param
			mov		rcx, [g]			; move g into 1st param pos
			call	p
			add		rsp, 32				; deallocate shadow space
			
			mov		rsp, rbp
			pop		rbp
			ret	

public		f
f:			; func start
			cmp		rcx, 1
			jge		f_re
			mov		rax, 1				; assign a value of 1 to rax if < 1
			jmp		f_end

f_re:		sub		rsp, 32				; allocate a shadow space if conditions are met
			dec		rcx					; pass n-1
			call	f					; f(n-1)
			inc		rcx					; n
			imul	rax, rcx			; n*f(n-1)
			add		rsp, 32				; deallocate shadow space
f_end:		ret

f_xp5_0		db		"a = %I64d b = %I64d c = %I64d d = %I64d e = %I64d sum = %I64d", 0AH, 00H
f_xp5_1		db		"a = %I64d b = %I64d a*b = %I64d", 0AH, 00H

public		xp5
xp5:		; printf("a = %I64d b = %I64d c = %I64d d = %I64d e = %I64d sum = %I64d\n", a, b, c, d, e, sum);
			push	rbx
			sub		rsp, 56				; 7*8 for 7 params

			lea		rbx, [rcx+rdx]		; rbx = a + b
			add		rbx, r8				; += c
			add		rbx, r9				; += d
			mov		r10, [rsp+104]		; r10 = e
			add		rbx, r10			; rbx = a + b + c + d + e
			
			mov		[rsp+48], rbx		; p7
			mov		[rsp+40], r10		; p6
			mov		[rsp+32], r9		; p5
			mov		r9, r8				; p4
			mov		r8, rdx				; p3
			mov		rdx, rcx			; p2
			lea		rcx, f_xp5_0		; p1

			call	printf
			mov		rax, rbx			; save rbx

			mov		rdx, [rsp+32]		; p2
			sub		rdx, 3
			
			mov		r8, [rsp+40]		; p3
			sub		r8, 3

			mov		r9, r8				; p4
			imul	r9, rdx

			lea		rcx, f_xp5_1
			call	printf

			mov		rax, [rsp+48]

			add		rsp, 56				; deallocate shadow space
			pop		rbx

			ret
			end

;;;;;;;;; RISC SOLUTION
			
; g
add		r0, #256, r9    ; use r9 for g, g = 256

; p(i, j)
p:		add   r26, r27, r16   ; k = i + j, store in r16
		sll   r16, #2, r1     ; shift first, store in r1
		ret   r25, 0          ; return value, r25 used. DELAYED JUMP.
		sub   r1, #1, r1      ; executed before ret in delay slot, r1 = (k<<2)-1

; q(i), r26 for param i
q:		add   r9, r0, r10     ; g
		callr r25, p
		sub   r0, r26, r11    ; -i
		ret   r25, 0
		add   r0, r0, r0      ; no op

; f(n)
; no mul instruction, assume some external multiply function
f:      sub   r26, r0, r0 {c}	; test if param passed to func is 0
        jle   f_end
        add   r1, #1			; return 1 << delay slot

        ; determine value of factorial
        add   r26, r0, r10		; move param passed to r10
        call  r25, f			; f(n-1)
        sub   r10, #1			; n-1 <<< delay slot
        add   r26, r0, r10		; move n back to first param for mul(n, n-1)

        call  r25, mul			; n*f(n-1)
        add   r25, r0, r11		; move n-1 into pos 2 of param for mul(n, n-1) <<< delay slot

f_end:  ret   r25, 0			; return n*f(n-1)