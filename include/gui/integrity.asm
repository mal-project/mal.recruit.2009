.code
;-----------------------------------------------------------------------
    integrity   proc uses ebx, _hwnd:dword
        local   _crc32_table[256]:dword
        local   _data:_client_data_block
        
        invoke  crc32_init, addr _crc32_table
        
        mov     ecx, sizeof _client_data_block
        mov     edi, _client_data_block
        xor     eax, eax
        rep     stosb

        invoke  SendDlgItemMessage, _hwnd, IDE_SERIAL, WM_GETTEXT, MAX_SERIAL_LENGTH, addr _data.szserial
        invoke  SendDlgItemMessage, _hwnd, IDE_NAME, WM_GETTEXT, MAX_NAME_LENGTH, addr _data.szname

        invoke  crc32_compute, addr _data.szname, sizeof _client_data_block.szname, addr _crc32_table
        mov     ebx, eax
        invoke  crc32_compute, addr _data.szserial, sizeof _client_data_block.szserial, addr _crc32_table
        mov     ebx, eax

        ret
    integrity   endp

;-----------------------------------------------------------------------
