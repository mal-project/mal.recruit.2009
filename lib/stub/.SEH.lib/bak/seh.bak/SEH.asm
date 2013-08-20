;-----------------------------------------------------------------------
.386
.model flat, stdcall

;-----------------------------------------------------------------------

include     project.inc

;-----------------------------------------------------------------------
;3:56 AM Sunday, April 26, 2009
; fixed bug with locals
; este codigo esta basado en un source de yoda

;-----------------------------------------------------------------------
.code

    option epilogue : none
    option prologue : none
InstSEH     proc    lpAddr, lpSEHHandler:dword
	assume fs : nothing

    ; preservamos estos dos registros
    mov     [esp-0Ch], eax
    mov     eax, [esp+4]
	mov     seh_data.SEHEIP, eax
    mov     seh_data.Reg.RegEBP, ebp

	push    [esp+8]
	push    fs:[0]
	mov     fs:[0], esp
	mov     seh_data.Reg.RegESP, esp

    mov     eax, [esp-04h]
    push    [esp+08h]
    ret
InstSEH   endp
    option epilogue : EpilogueDef
    option prologue : PrologueDef
    
;-----------------------------------------------------------------------
    option epilogue : none
DeinstSEH proc
    add     esp, 0Ch
	pop     fs:[0]
	add     esp, 04h

	push    [esp-14h]
	ret
DeinstSEH endp
    option epilogue : EpilogueDef

;-----------------------------------------------------------------------
SEHHandler    proc C pExcept:DWORD,pFrame:DWORD,pContext:DWORD,pDispatch:DWORD

	mov     eax, pContext
	assume  eax : ptr CONTEXT
    
    ;mov     edx, [eax].iDr7
    ;cmp     edx, 400h
    ;jnz     @FUCK

    mov     edx, [eax].iDr0
    test    dx, dx
    jnz     @FUCK

    mov     edx, [eax].iDr1
    test    dx, dx
    jnz     @FUCK

    mov     edx, [eax].iDr2
    test    dx, dx
    jnz     @FUCK

    mov     edx, [eax].iDr3
    test    dx, dx
    jnz     @FUCK

	push    seh_data.SEHEIP
	pop     [eax].regEip
	
	push    seh_data.Reg.RegESP
	pop     [eax].regEsp
	
	push    seh_data.Reg.RegEBP
	pop     [eax].regEbp

	mov     eax, 0;ExceptionContinueExecution
@FUCK:
	ret

SEHHandler    endp

;-----------------------------------------------------------------------

start:
        push    offset SEHHandler
        push    offset _safe
        call    InstSEH
        xor     eax, eax
        div     ecx
_safe:  invoke  DeinstSEH
        .const
            message db "Ok, eeverythign ok",0
        
        .code
        invoke  MessageBoxA, 0, addr message, 0, 0
        ret
end start

;-----------------------------------------------------------------------
