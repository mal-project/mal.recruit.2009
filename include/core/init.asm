;-----------------------------------------------------------------------
    init    proc
        local   lpRoot:dword
        pushad
        xor     edx, edx
        mov     lpRoot, 005C3A63h 
        invoke  GetVolumeInformation, addr lpRoot, edx, edx, addr _dwvolumeserial, edx, edx, edx, edx
        
        mov     eax, _dwvolumeserial
        xor     eax, server_crc32_checksum
        adc     eax, server_crc32_runtime_checksum
        
        xor     eax, client_crc32_checksum
        sbb     eax, client_crc32_runtime_checksum
        xor     eax, stubs_crc32_checksum
        
        mov     _dwvolumeserial, eax
        popad
        ret
    init    endp
    init_end:

;-----------------------------------------------------------------------