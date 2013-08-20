;-----------------------------------------------------------------------
    option epilogue:none
    option prologue:none    
    ldr_module  proc
        pushad
        
        assume  fs:nothing
        push    offset _SEHEnd
        call    InstSEH
        
        mov     eax, dword ptr fs:[30h]
        mov     eax, dword ptr[eax+12]
        mov     ecx, 30
        .while  (1)
            inc     eax
            cmp     dword ptr[eax], 0feeefeeeh
            .if     ZERO?
                dec     ecx
                .break .if ZERO?
            .endif
        .endw

        popad
        push    _dwkernel_ret
        ret

    _SEHEnd:
        invoke  DeinstSEH
        popad
        ret
    ldr_module  endp
    ldr_module_end:
    option epilogue:EpilogueDef
    option prologue:PrologueDef

;-----------------------------------------------------------------------
