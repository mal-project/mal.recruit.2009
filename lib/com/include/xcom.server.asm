;-----------------------------------------------------------------------
; builds a server where comunicate with other processes
    server_build    proc    lpszServer:dword
        local   hfile, hmap:dword
        pushad
    
        invoke  CreateFileMapping, -1, 0, PAGE_READWRITE, 0, sizeof _server_information_block, lpszServer
        mov     hfile, eax
        .if     eax != NULL
    
            invoke  MapViewOfFile, eax, FILE_MAP_ALL_ACCESS, 0, 0, sizeof _server_information_block
            mov     hmap, eax
        
            .if     eax != NULL
                ; initializing channel
                mov     (_server_information_block ptr [eax]).info.version, _XCOM_VERSION
                push    hfile
                pop     (_server_information_block ptr [eax]).info.hFile
                push    hmap
                pop     (_server_information_block ptr [eax]).info.hMap        
            .endif

        .else
            mov     hmap, NULL

        .endif

        popad
        
        mov     eax, hmap
        ret
    server_build    endp
;-----------------------------------------------------------------------
; shutdown a server (stop listining thread)
    server_shutdown    proc    hserver:dword
        pushad
        mov     eax, hserver
        mov     (_server_information_block ptr [eax]).status.live, FALSE
        mov     (_server_information_block ptr [eax]).status.state, _STATUS_SHUTDOWN
        ;invoke  xsleep, SERVER_RESPONSE_TIMEOUT*MAX_SERVER_RESPONSE_TRIES
        popad
        ret
    server_shutdown    endp

;-----------------------------------------------------------------------
; destroy a server. previously all clients should be informed
    server_destroy     proc    hserver:dword
        pushad
        mov     eax, hserver
        invoke  CloseHandle, (_server_information_block ptr [eax]).info.hFile
        mov     eax, hserver
        invoke  UnmapViewOfFile, (_server_information_block ptr [eax]).info.hMap
        popad
        ret
    server_destroy     endp

;-----------------------------------------------------------------------
;
    _server_handle_queries  proc    hserver:dword
        local   _server_timeout:dword
        pushad
        mov     _server_timeout, _SERVER_TIMEOUT_INTERVAL
        mov     eax, hserver
        
        .while  byte ptr (_server_information_block ptr [eax]).query.available == TRUE
            
            ; is there a query?
            .if     dword ptr (_server_information_block ptr [eax]).query.id != NULL
                mov     (_server_information_block ptr [eax]).query.available, FALSE

                ; is there place for a query?
                .if     dword ptr (_server_information_block ptr [eax]).query.slots < MAX_CLIENTS_ALLOWED && dword ptr (_server_information_block ptr [eax]).query.version == _XCOM_VERSION
                    mov     ecx, (_server_information_block ptr [eax]).query.slots
                    
                    push    (_server_information_block ptr [eax]).query.id
                    pop     (_server_information_block ptr [eax]).info.slot_id[ecx*4]
                    
                    mov     edx, ecx
                    imul    edx, _client_information_block_size
                    add     edx, _server_information_block_size
                    add     edx, eax
                    mov     (_server_information_block ptr [eax]).query.slot, edx
                    mov     (_server_information_block ptr [eax]).info.slot_addr[ecx*4], edx
                    mov     (_client_information_block ptr [edx]).server, eax
                    
                    push    (_server_information_block ptr [eax]).query.id
                    pop     (_client_information_block ptr [edx]).id
                    
                    inc     (_server_information_block ptr [eax]).query.slots
                .endif
                
                ; esperamos que nos de una respuesta
                xor     ecx, ecx
                .while  dword ptr (_server_information_block ptr [eax]).query.id != NULL && ecx <= MAX_SERVER_RESPONSE_TRIES
                    invoke  xsleep, SERVER_RESPONSE_TIMEOUT
                    inc     ecx
                .endw
                
                mov     (_server_information_block ptr [eax]).query.slot, NULL
                mov     (_server_information_block ptr [eax]).query.available, TRUE        
            .endif
            
            .if     !dword ptr (_server_information_block ptr [eax]).query.slots
                mov     ecx, (_server_information_block ptr [eax]).query.timeout
                sub     _server_timeout, ecx
                .if     SIGN?
                    mov     (_server_information_block ptr [eax]).query.available, FALSE
                    mov     (_server_information_block ptr [eax]).status.state, _STATUS_SHUTDOWN
                    mov     (_server_information_block ptr [eax]).status.state_ex, _STATUS_TIMEOUT

                .endif
            .endif
            
            invoke  xsleep, _SERVER_THREAD_SLEEP

        .endw
        
        popad
        ret
    _server_handle_queries  endp

;-----------------------------------------------------------------------
;
    _server_census     proc    hserver:dword
        pushad
        mov     eax, hserver

        .while  dword ptr (_server_information_block ptr [eax]).status.state != _STATUS_SHUTDOWN
            ; esperamos que nos de una respuesta
            xor     ecx, ecx
            .while  ecx <= MAX_CLIENTS_ALLOWED && dword ptr (_server_information_block ptr [eax]).info.slot_id[ecx*4] != NULL

                mov     edx, eax
                invoke  client_live, (_server_information_block ptr [eax]).info.slot_addr[ecx*4]
                .if     eax == FALSE
                    invoke  client_delete, edx, (_server_information_block ptr [edx]).info.slot_addr[ecx*4]
                .endif
                mov     eax, edx

                inc     ecx
            .endw
            
            invoke  xsleep, _SERVER_THREAD_SLEEP
        .endw

        popad
        ret
    _server_census     endp

;-----------------------------------------------------------------------
;
    server_open_queries    proc    hserver:dword
        pushad
        mov     eax, hserver
        mov     (_server_information_block ptr [eax]).query.available,  TRUE
        mov     (_server_information_block ptr [eax]).query.slots,      0
        mov     (_server_information_block ptr [eax]).query.id,         NULL
        mov     (_server_information_block ptr [eax]).query.slot,       NULL
        
        invoke  CreateThread, NULL, NULL, addr _server_handle_queries, hserver, NULL, NULL
        invoke  CreateThread, NULL, NULL, addr _server_census, hserver, NULL, NULL

        popad
        ret
    server_open_queries    endp

;-----------------------------------------------------------------------
;
    server_close_queries    proc    hserver:dword
        pushad
        mov     eax, hserver
        mov     (_server_information_block ptr [eax]).query.available, FALSE
        xor     edx, edx
        dec     edx
        mov     (_server_information_block ptr [eax]).query.slots, edx
        mov     (_server_information_block ptr [eax]).query.id, edx
        mov     (_server_information_block ptr [eax]).query.slot, edx
        popad
        ret
    server_close_queries    endp

;-----------------------------------------------------------------------
;
    server_get_query  proc    hserver:dword, squery:dword
        pushad
        mov     eax, hserver
        mov     edx, squery
        
        movzx   ecx, (_server_information_block ptr [eax]).query.available
        mov     (_query_information_block ptr [edx]).available, cl
        push    (_server_information_block ptr [eax]).query.slots
        pop     (_query_information_block ptr [edx]).slots
        push    (_server_information_block ptr [eax]).query.timeout
        pop     (_query_information_block ptr [edx]).timeout
        push    (_server_information_block ptr [eax]).query.id
        pop     (_query_information_block ptr [edx]).id
        push    (_server_information_block ptr [eax]).query.version
        pop     (_query_information_block ptr [edx]).version
        push    (_server_information_block ptr [eax]).query.slot
        pop     (_query_information_block ptr [edx]).slot
        
        popad
        ret
    server_get_query  endp

;-----------------------------------------------------------------------
;
    server_set_query  proc    hserver:dword, squery:_query_information_block
        pushad
        mov     eax, hserver
        
        movzx   edx, squery.available
        mov     (_server_information_block ptr [eax]).query.available, dl
        push    squery.slots
        pop     (_server_information_block ptr [eax]).query.slots
        push    squery.timeout
        pop     (_server_information_block ptr [eax]).query.timeout
        push    squery.id
        pop     (_server_information_block ptr [eax]).query.id
        push    squery.version
        pop     (_server_information_block ptr [eax]).query.version
        push    squery.slot
        pop     (_server_information_block ptr [eax]).query.slot
        
        popad
        ret
    server_set_query  endp

;-----------------------------------------------------------------------
;
    server_set_status  proc    hserver:dword, sstatus:_status_information_block
        pushad
        mov     eax, hserver
        movzx   edx, sstatus.live
        mov     (_server_information_block ptr [eax]).status.live, dl
        push    sstatus.state
        pop     (_server_information_block ptr [eax]).status.state
        push    sstatus.state_ex
        pop     (_server_information_block ptr [eax]).status.state_ex
        popad
        ret
    server_set_status  endp

;-----------------------------------------------------------------------
;
    _server_live_response  proc    hserver:dword
        pushad
        mov     eax, hserver
        
        .while dword ptr (_server_information_block ptr [eax]).status.state != _STATUS_SHUTDOWN
            .if byte ptr (_server_information_block ptr [eax]).status.live == FALSE
                mov     (_server_information_block ptr [eax]).status.live, TRUE
            .endif
            
            invoke  xsleep, _SERVER_THREAD_SLEEP
        .endw

        popad
        ret
    _server_live_response  endp

;-----------------------------------------------------------------------
;
    server_listen     proc    hserver:dword, lplistener:dword
        local   _return :dword
        pushad
        invoke  CreateThread, NULL, NULL, addr _server_live_response, hserver, NULL, NULL
        invoke  CreateThread, NULL, NULL, lplistener, hserver, NULL, NULL
        mov     _return, eax
        popad
        mov     eax, _return
        ret
    server_listen     endp

;-----------------------------------------------------------------------
; add a client to the server
    client_add    proc    hserver:dword, query_id:dword
        pushad
        mov     eax, hserver
        mov     (_server_information_block ptr [eax]).query.available, FALSE

        ; check if there is place for another user
        .if     dword ptr (_server_information_block ptr [eax]).query.slots <= MAX_CLIENTS_ALLOWED
            ; check if query id was already asigned
            mov     edx, query_id
            xor     ecx, ecx
            .while  ecx <= MAX_SERVER_RESPONSE_TRIES && edx != dword ptr (_server_information_block ptr [eax]).info.slot_id[ecx*4] && dword ptr (_server_information_block ptr [eax]).info.slot_id[ecx*4] != 0
                inc     ecx
            .endw
            
            .if     dword ptr (_server_information_block ptr [eax]).info.slot_id[ecx*4] == NULL
                
                mov     dword ptr (_server_information_block ptr [eax]).info.slot_id[ecx*4], edx
                
                mov     edx, eax
                add     edx, _server_information_block_size
                push    ecx
                imul    ecx, _client_information_block_size
                add     edx, ecx
                pop     ecx
                
                mov     dword ptr (_server_information_block ptr [eax]).info.slot_addr[ecx*4], edx
                inc     dword ptr (_server_information_block ptr [eax]).query.slots
                mov     dword ptr (_server_information_block ptr [eax]).query.slot, edx
                
                ; esperamos que nos de una respuesta
                xor     ecx, ecx
                .while  dword ptr (_server_information_block ptr [eax]).query.id != NULL && ecx <= MAX_SERVER_RESPONSE_TRIES
                    invoke  xsleep, SERVER_RESPONSE_TIMEOUT
                    inc     ecx
                .endw

            .endif
        
        .endif
 
        mov     (_server_information_block ptr [eax]).query.slot, NULL
        mov     (_server_information_block ptr [eax]).query.id,   NULL
        mov     (_server_information_block ptr [eax]).query.available,  TRUE
        
        popad
        ret
    client_add     endp

;-----------------------------------------------------------------------    
; deletes a dead client
    client_delete proc    hserver:dword, hclient:dword
        pushad
        
        ; clear slot_id and slot_addr
        mov     eax, hclient
        mov     edx, (_client_information_block ptr [eax]).id
        
        xor     ecx, ecx
        mov     eax, hserver
        .while  dword ptr (_server_information_block ptr [eax]).info.slot_id[ecx] != NULL
            .if dword ptr (_server_information_block ptr [eax]).info.slot_id[ecx] == edx
                 invoke     xfill, 0, (_server_information_block ptr [eax]).info.slot_addr[ecx], sizeof _client_information_block
                 
                 mov    (_server_information_block ptr [eax]).info.slot_id[ecx], NULL
                 mov    (_server_information_block ptr [eax]).info.slot_addr[ecx], NULL
                 dec    (_server_information_block ptr [eax]).query.slots
            .endif
            inc     ecx
        .endw
        popad
        ret
    client_delete endp

;-----------------------------------------------------------------------
;
    client_live  proc    hclient:dword
        local   _return :dword
        pushad
        mov     _return, FALSE

        mov     eax, hclient
        mov     (_client_information_block ptr [eax]).status.live, FALSE
        
        xor     ecx, ecx
        .while  ecx <= MAX_SERVER_RESPONSE_TRIES
            invoke  xsleep, CLIENT_RESPONSE_TIMEOUT
            
            .break .if byte ptr (_client_information_block ptr [eax]).status.live == TRUE
            
            inc     ecx
        .endw

        .if     ecx <= MAX_SERVER_RESPONSE_TRIES
            mov     _return, TRUE
        .endif

        popad
        
        mov     eax, _return
        ret
    client_live  endp

;-----------------------------------------------------------------------
