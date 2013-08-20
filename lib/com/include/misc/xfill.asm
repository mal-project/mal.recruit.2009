.code
    xfill   proc    char:byte, lpDest:dword, ddSize:dword
        pushad
        mov     ecx, ddSize
        mov     edi, lpDest
        
        movzx   eax, char
        
        rep     stosb
        
        popad
        ret
    xfill   endp
