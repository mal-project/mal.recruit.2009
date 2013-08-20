.386
.model flat, stdcall
option casemap:none

include project.inc

.code
    include xcom.server.asm
    include xcom.client.asm
;-----------------------------------------------------------------------
; check the existence of a server
    server_exists  proc    lpszServer:dword
        local   _return:dword
        pushad
        mov     _return, FALSE
        
        invoke  CreateFileMapping, -1, 0, PAGE_READWRITE, 0, sizeof _server_information_block, lpszServer
        push    eax
        
        invoke  GetLastError
        .if     eax == ERROR_ALREADY_EXISTS
            mov     _return, TRUE
        .endif
        
        pop     eax
        invoke  CloseHandle, eax
        popad
        
        mov     eax, _return
        ret
        
    server_exists  endp

;-----------------------------------------------------------------------
;
    server_get_status  proc    hserver:dword, hstatus:dword
        pushad
        mov     eax, hserver
        mov     edx, hstatus
        
        movzx   ecx, (_server_information_block ptr [eax]).status.live
        mov     (_status_information_block ptr [edx]).live, cl
        
        push    (_server_information_block ptr [eax]).status.state
        pop     (_status_information_block ptr [edx]).state
        
        push    (_server_information_block ptr [eax]).status.state_ex
        pop     (_status_information_block ptr [edx]).state_ex
        
        popad
        ret
    server_get_status  endp 

    ; returns: -1 if timeout, 
    wait_signal proc uses ecx, lpdbsignal, dwtimeout, dwtries:dword
        xor     ecx, ecx
        mov     esi, lpdbsignal
        movzx   eax, byte ptr [esi]
        .while  byte ptr [esi] == al && ecx <= dwtries
            invoke  xsleep, SERVER_RESPONSE_TIMEOUT
            inc     ecx
        .endw

        .if     ecx > MAX_SERVER_RESPONSE_TRIES
            xor     eax, eax
            dec     eax
        .else
            mov     eax, ecx
            
        .endif
        ret
    wait_signal endp

;-----------------------------------------------------------------------
end
