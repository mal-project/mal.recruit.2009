.code
    xrand   proc    ddfloor:dword, ddceil:dword
        local   _return:dword
        pushad
        
        invoke  GetTickCount
       
        xor     edx, edx
        mov     ecx, ddceil
        idiv    ecx

        .if     edx < ddfloor
            add     edx, ddfloor
        .endif
        
        .if     edx > ddceil
            mov     eax, edx
            xor     edx, edx
            mov     ecx, ddceil
            
            idiv    ecx
            .if     edx < ddfloor
                add     edx, ddfloor
            .endif
        .endif
        
        mov     _return, edx            
        popad
        
        mov     eax, _return
        ret
    xrand   endp
