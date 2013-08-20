;-----------------------------------------------------------------------
    checksum_integrity  proc
        local   _crc32_table[256]:dword
        pushad
        
        INTEGRITY_DATA equ offset stubs_crc32_checksum-offset sdecode_data
        
        invoke  crc32_compute, addr sdecode_data, INTEGRITY_DATA, addr _crc32_table
        mov     _dwcrc32_checksum, eax

        popad
        ret
    checksum_integrity  endp
    checksum_integrity_end:

;-----------------------------------------------------------------------
