.486                                ; create 32 bit code
.model flat, C                      ; 32 bit memory model
 option casemap:none                ; case sensitive

.code

;
; fib32.asm
;
; Copyright (C) 2012 - 2016 jones@scss.tcd.ie
;

;
; example mixing C/C++ and IA32 assembly language
;
; use stack for local variables
;
; simple mechanical code generation which doesn't make good use of the registers
;
; 06/10/14  used ecx instead of ebx to initialise fi and fj as ecx volatile

public      fib_IA32a               ; make sure function name is exported

fib_IA32a:  push    ebp             ; push frame pointer
            mov     ebp, esp        ; update ebp
            sub     esp, 8          ; space for local variables fi [ebp-4] and fj [ebp-8]
            mov     eax, [ebp+8]    ; eax = n
            cmp     eax, 1          ; if (n <= 1) ...
            jle     fib_IA32a2      ; return n
            xor     ecx, ecx        ; ecx = 0   NB: mov [ebp-4], 0 NOT allowed
            mov     [ebp-4], ecx    ; fi = 0
            inc     ecx             ; ecx = 1   NB: mov [ebp-8], 1 NOT allowed
            mov     [ebp-8], ecx    ; fj = 1
fib_IA32a0: mov     eax, 1          ; eax = 1
            cmp     [ebp+8], eax    ; while (n > 1)
            jle     fib_IA32a1      ;
            mov     eax, [ebp-4]    ; eax = fi
            mov     ecx, [ebp-8]    ; ecx = fj
            add     eax, ecx        ; ebx = fi + fj
            mov     [ebp-4], ecx    ; fi = fj
            mov     [ebp-8], eax    ; fj = eax
            dec     DWORD PTR[ebp+8]; n--
            jmp     fib_IA32a0      ;
fib_IA32a1: mov     eax, [ebp-8]    ; eax = fj
fib_IA32a2: mov     esp, ebp        ; restore esp
            pop     ebp             ; restore ebp
            ret     0               ; return
    
;
; example mixing C/C++ and IA32 assembly language
;
; makes better use of registers and instruction set
;

public      fib_IA32b               ; make sure function name is exported

fib_IA32b:  push    ebp             ; push frame pointer
            mov     ebp, esp        ; update ebp
            mov     eax, [ebp+8]    ; mov n into eax
            cmp     eax, 1          ; if (n <= 1)
            jle     fib_IA32b2      ; return n
            xor     ecx, ecx        ; fi = 0
            mov     edx, 1          ; fj = 1
fib_IA32b0: cmp     eax, 1          ; while (n > 1)
            jle     fib_IA32b1      ;
            add     ecx, edx        ; fi = fi + fj
            xchg    ecx, edx        ; swap fi and fj
            dec     eax             ; n--
            jmp     fib_IA32b0      ;
fib_IA32b1: mov     eax, edx        ; eax = fj
fib_IA32b2: mov     esp, ebp        ; restore esp
            pop     ebp             ; restore ebp
            ret     0               ; return
    
public		g
g			DWORD	256				;const

public		p
p:			;func start
			push	ebp
			mov		ebp, esp

			;load parameters int(int i, int j) => return (((i+j) << 2) - 1)
			mov		eax, [ebp+8]	; load i into k, k=i
			add		eax, [ebp+12]	; load and add j into k, k+=j
			shl		eax, 2			; k<<2
			dec		eax				; k-=1

			;func end
			mov		esp, ebp
			pop		ebp
			ret
			

public		q
q:			push	ebp
			mov		ebp, esp

			;func body
			;-i parameter
			mov		eax, [ebp+8]
			imul	eax, -1
			push	eax

			;g parameter
			push	g
			
			call	p	

			mov		esp, ebp
			pop		ebp
			ret

public		f
f:			push	ebp
			mov		ebp, esp

			;func body
			;n param
			mov		eax, [ebp+8]

f_cmp:		cmp		eax, 0
			jg		f_gr
			jle		f_le

f_gr:		dec		eax
			push	eax
			call	f

			imul	eax, [ebp+8] ;access the previous definition of n from frame
			jmp		f_end

f_le:		mov		eax, 1

f_end:		mov		esp, ebp
			pop		ebp
			ret

            end
; eof