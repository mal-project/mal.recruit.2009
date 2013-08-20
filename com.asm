.code
;-----------------------------------------------------------------------
    _server_listener    proc    hserver:dword
        local   hstatus :_status_information_block
        local   hquery  :_query_information_block
        pushad


		;invoke  xsleep, 10000
		
        mov     ecx, hserver
        lea     ebx, (_server_information_block ptr [ecx]).user[0]

        inc     hstatus.live
        mov     hstatus.state, _STATUS_IDLE        
        invoke  server_set_status, hserver, hstatus

        invoke  server_get_query, hserver, addr hquery
        mov     hquery.timeout, 1000
        invoke  server_set_query, hserver, hquery
        invoke  server_open_queries, hserver
        
        invoke  init
        
        .repeat
            invoke  xsleep, _SERVER_THREAD_SLEEP

            .if     dword ptr (_server_information_block ptr [ecx]).info.slot_id[0]
                .if     byte ptr (_client_information_block ptr [ebx]).data.verify
                
                    invoke  data_integrity, addr server_data, addr server_crc32_runtime                
                    invoke  ldr_module

                    invoke  verify, addr (_client_information_block ptr [ebx]).data.szname, addr (_client_information_block ptr [ebx]).data.szserial

                    .if     !eax
                        mov     byte ptr (_client_information_block ptr [ebx]).data.status, _STATUS_REGISTERED
                    .else
                        mov     byte ptr (_client_information_block ptr [ebx]).data.status, _STATUS_UNREGISTERED
                    .endif
                    
                    mov     byte ptr (_client_information_block ptr [ebx]).data.verify, FALSE
                .endif
            
            .else
                .break
            
            .endif

            invoke  server_get_status, hserver, addr hstatus
        .until  hstatus.state == _STATUS_SHUTDOWN
        
        invoke  server_close_queries, hserver
        invoke  server_shutdown, hserver
        invoke  server_destroy, hserver
        
        popad
        ret

    _server_listener    endp
    _server_listener_end:

;-----------------------------------------------------------------------
    _client_talker proc    huser:dword
        local   hstatus :_status_information_block
        local   hserver :dword
        pushad

        mov     eax, huser
        push    (_client_information_block ptr [eax]).server
        pop     hserver

        lea     edx, (_client_information_block ptr [eax]).data        

        .while  (1)
            invoke  WaitForSingleObject, hReg, -1
            .if     eax != WAIT_FAILED
                invoke  server_live, hserver
                .break .if !eax

                invoke  SendDlgItemMessage, hwnd, IDE_SERIAL, WM_GETTEXT, MAX_SERIAL_LENGTH, addr (_client_information_block ptr [ebx]).data.szserial
                .if     eax >= MIN_SERIAL_LENGTH && eax <= MAX_SERIAL_LENGTH
                    invoke  SendDlgItemMessage, hwnd, IDE_NAME, WM_GETTEXT, MAX_NAME_LENGTH, addr (_client_information_block ptr [ebx]).data.szname
                    .if     eax >= MIN_NAME_LENGTH && eax <= MAX_NAME_LENGTH
                        mov     (_client_information_block ptr [ebx]).data.verify, TRUE
                        
                        invoke  data_integrity, addr client_data, addr client_crc32_runtime

                        xor     ecx, ecx
                        .while  byte ptr (_client_information_block ptr [ebx]).data.verify && ecx <= MAX_SERVER_RESPONSE_TRIES
                            invoke  xsleep, SERVER_RESPONSE_TIMEOUT
                            inc     ecx
                        .endw
                       
                        .if     !byte ptr (_client_information_block ptr [ebx]).data.verify
                            .if     byte ptr (_client_information_block ptr [ebx]).data.status == _STATUS_REGISTERED
                                invoke  SendMessage, hwnd, WM_DEFEATED, NULL, NULL
                            
                            .endif
                        .else
                            .break
                            
                        .endif

                    .endif
                    
                .endif
            .else
                invoke  xsleep, 5000
                
            .endif

        .endw

        invoke  server_leave, huser
        
        invoke  SendMessage, hwnd, WM_SERVERDOWN, NULL, NULL

        popad
        ret
    _client_talker endp
    _client_talker_end:

;-----------------------------------------------------------------------
