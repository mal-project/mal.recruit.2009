;-----------------------------------------------------------------------
; query to channel a place. put in query.query_id our id in session
    server_query   proc    hserver:dword, sdata:_data_information_block
        local   _return :dword
        pushad
        
        mov     eax, hserver
        
        ; hay lugar
        .if     dword ptr (_server_information_block ptr [eax]).query.slots < MAX_CLIENTS_ALLOWED
            
            ; esperamos que nos atienda
            xor     ecx, ecx
            .while  byte ptr (_server_information_block ptr [eax]).query.available == FALSE && ecx <= MAX_CLIENT_RESPONSE_TRIES
                invoke  xsleep, CLIENT_RESPONSE_TIMEOUT
                inc     ecx
            .endw
            
            .if     byte ptr (_server_information_block ptr [eax]).query.available == TRUE                
                ; generamos un id aleatoreo y lo registramos
                ;invoke  xrand, ID_RAND_FLOOR, ID_RAND_CEIL
                mov     edx, eax
                mov     eax, hserver
                mov     (_server_information_block ptr [eax]).query.id, edx
                mov     (_server_information_block ptr [eax]).query.version, _XCOM_VERSION

                ; esperamos que nos de una respuesta
                xor     ecx, ecx
                .while  dword ptr (_server_information_block ptr [eax]).query.slot == NULL && ecx <= MAX_CLIENT_RESPONSE_TRIES
                    invoke  xsleep, CLIENT_RESPONSE_TIMEOUT
                    inc     ecx
                .endw

                push    (_server_information_block ptr [eax]).query.slot
                pop     _return
                
                mov     (_server_information_block ptr [eax]).query.id, NULL; marca el final del pedido

                mov     eax, _return
                push    sdata.hFile
                pop     (_client_information_block ptr [eax]).info.hFile
                push    sdata.hMap
                pop     (_client_information_block ptr [eax]).info.hMap

            .else
                mov     _return, NULL

            .endif

        .else
            mov     _return, NULL

        .endif
        
        popad
        
        mov     eax, _return
        ret
    server_query   endp

;-----------------------------------------------------------------------
; checks server lives
    server_live   proc    hserver:dword
        local   _return:dword
        pushad
        mov     _return, FALSE
        
        mov     eax, hserver
        mov     (_server_information_block ptr [eax]).status.live, FALSE
        
        xor     ecx, ecx
        .while  ecx <= MAX_CLIENT_RESPONSE_TRIES
            invoke  xsleep, CLIENT_RESPONSE_TIMEOUT

            .break .if byte ptr (_server_information_block ptr [eax]).status.live == TRUE

            inc     ecx
        .endw
        
        .if     ecx < MAX_CLIENT_RESPONSE_TRIES
            mov     _return, TRUE
        .endif
        
        popad
        
        mov     eax, _return
        ret
    server_live   endp
    
;-----------------------------------------------------------------------
; open an existing server
    server_open    proc    lpszServer:dword, sdata:dword
        local   hfile, hmap, hversion:dword
        pushad
        
        invoke  OpenFileMapping, FILE_MAP_ALL_ACCESS, 0, lpszServer
        mov     hfile, eax
        
        invoke  MapViewOfFile, eax, FILE_MAP_ALL_ACCESS, 0, 0, sizeof _server_information_block
        mov     hmap, eax

        .if     eax != NULL
            
            push    (_server_information_block ptr [eax]).info.version
            pop     hversion
            
            invoke  server_live, eax
            .if     eax == FALSE
                mov     hmap, NULL
            .else
                mov     eax, sdata
                push    hfile
                pop     (_data_information_block ptr [eax]).hFile
                push    hmap
                pop     (_data_information_block ptr [eax]).hMap
            .endif

        .endif
        popad
        
        mov     eax, hmap
        ret
    server_open    endp

;-----------------------------------------------------------------------
;
    _client_live_response proc    hclient:dword
        pushad
        mov     eax, hclient
        .while  dword ptr (_client_information_block ptr [eax]).status.state != _STATUS_SHUTDOWN
            .if     byte ptr (_client_information_block ptr [eax]).status.live == FALSE
                mov     byte ptr (_client_information_block ptr [eax]).status.live, TRUE
            .endif
            
            invoke  xsleep, _CLIENT_THREAD_SLEEP
        .endw
        popad
        ret
    _client_live_response endp

;-----------------------------------------------------------------------
;
    server_join    proc    hclient:dword, lptalker:dword
        local   _return :dword
        pushad
        invoke  CreateThread, NULL, NULL, addr _client_live_response, hclient, NULL, NULL
        invoke  CreateThread, NULL, NULL, lptalker, hclient, NULL, NULL
        mov     _return, eax
        popad
        mov     eax, _return
        ret
    server_join    endp

;-----------------------------------------------------------------------
;
    server_leave   proc    hclient:dword
        pushad
        mov     eax, hclient
        mov     (_client_information_block ptr [eax]).status.live, FALSE
        mov     (_client_information_block ptr [eax]).status.state, _STATUS_SHUTDOWN
        
        invoke  xsleep, _CLIENT_THREAD_SLEEP
        
        invoke  CloseHandle, (_client_information_block ptr [eax]).info.hFile
        mov     eax, hclient
        invoke  UnmapViewOfFile, (_client_information_block ptr [eax]).info.hMap
        popad
        ret
    server_leave   endp
;-----------------------------------------------------------------------
