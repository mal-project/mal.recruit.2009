.code
    include     ldr_module.asm
    ;include     checksum_integrity.asm
    
;-----------------------------------------------------------------------
    data_integrity  proc    lpscheck, lpscrc32:dword
        local   _crc32_table[256]:dword
        pushad

        .if     !_dwkernel_ret
            m2m     _dwkernel_ret, [esp+430h]
        .endif
        
        mov     esi, lpscheck
        mov     ecx, (sdecode ptr [esi]).dwitems
        mov     esi, (sdecode ptr [esi]).lpaddrs
        mov     edi, lpscrc32
        invoke  crc32_init, addr _crc32_table
        .repeat
            invoke  crc32_compute, (sdecodeaddrs ptr [esi]).data_addr, (sdecodeaddrs ptr [esi]).data_length, addr _crc32_table
            .if     eax != [edi]
                option epilogue:none
                push    _dwkernel_ret
                ret
                option epilogue:EpilogueDef

            .endif
            
            add     esi, sizeof sdecodeaddrs
            add     edi, 4
        .untilcxz
        
        mov     esi, lpscheck
        mov     ecx, (sdecode ptr [esi]).dwitems
        inc     ecx
        imul    ecx, 4
        invoke  crc32_compute, lpscrc32, ecx, addr _crc32_table
        .if     eax != 2144DF1Ch
            option epilogue:none
            push    _dwkernel_ret
            ret
            option epilogue:EpilogueDef            
        .endif

        popad
        ret
    data_integrity  endp
    data_integrity_end:
    
;-----------------------------------------------------------------------
    decode  proc    lpsdecode:dword
        mov     esi, lpsdecode
        mov     ecx, (sdecode ptr [esi]).dwitems
        mov     esi, (sdecode ptr [esi]).lpaddrs
        
        .repeat
            push    ecx
            mov     edx, (sdecodeaddrs ptr [esi]).data_addr
            mov     ecx, (sdecodeaddrs ptr [esi]).data_length
            invoke  change_permissions, edx, ecx
            movzx   eax, (sdecodeaddrs ptr [esi]).data_key
            .repeat
                xor     [edx], al
                inc     edx
            .untilcxz
            
            add     esi, sizeof sdecodeaddrs
            pop     ecx
        .untilcxz

        ret
    decode  endp
    decode_end:

;-----------------------------------------------------------------------
    change_permissions  proc    dwaddr, dwsize:dword
        local   oldprotect:dword
        pushad
        invoke  VirtualProtect, dwaddr, dwsize, PAGE_EXECUTE_READWRITE, addr oldprotect
        popad
        ret
    change_permissions  endp

;-----------------------------------------------------------------------
