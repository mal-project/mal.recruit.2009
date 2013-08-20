;-----------------------------------------------------------------------
.386
.model flat, stdcall
option casemap:none

;-----------------------------------------------------------------------
include     project.inc

;-----------------------------------------------------------------------
.code
    includes    stub.asm, core.asm, com.asm, gui.asm

;-----------------------------------------------------------------------    
    Instance    proc
        local   _szfilename[MAX_PATH]:byte
        invoke  GetModuleFileName, NULL, addr _szfilename, MAX_PATH
        .if     eax
            invoke  WinExec, addr _szfilename, SW_SHOW
            .if     eax <= 31
                xor     eax, eax
            .endif
        .endif
        ret
    Instance    endp
    Instance_end:

;-----------------------------------------------------------------------
    Connect proc
        ; conectarse al server
        invoke  server_open, addr szscrtitle, addr sdata
        .if     eax
            invoke  server_query, eax, sdata
            .if     eax
                invoke  server_join, eax, addr _client_talker
            .endif
        .endif
        ret
    Connect endp
    Connect_end:

;-----------------------------------------------------------------------
    start:
        invoke  GetModuleHandle, NULL
        mov     hInst, eax
        
        invoke  server_exists, addr szscrtitle
        .if     !eax
            ; server side
            
            ; lanzar los crc check para comprobar que los datos codificados estan bien
            ; tambien los antidbg (LDR) (thread!)
            invoke  data_integrity, addr server_data, addr server_crc32
            
            invoke  data_integrity, addr stub_data, addr stub_crc32
            
            ; desencriptar parte del codigo de comprobacion
            ; Instance, verify, _server_listener, constants(rsa, dlp)
            invoke  decode, addr server_data
           
            ; lanzar el server
            invoke  server_build, addr szscrtitle
            invoke  server_listen, eax, offset _server_listener
            mov     ebx, eax
            
            ; lanzar la segunda instancia
            invoke  Instance
            .if     eax
            
                invoke  WaitForSingleObject, ebx, INFINITE

            .endif

        .else
        
            invoke  data_integrity, addr client_data, addr client_crc32
            
            ; desencriptamos los datos del cliente
            ; Connect, MainDlgProc, _client_talker, initialize, data(offset mfont- offset szscrtitle)
            ;invoke  decode, addr client_data

            invoke  CreateMutex, NULL, NULL, addr szscrfooter
            invoke  GetLastError
            .if     eax != ERROR_ALREADY_EXISTS
                ; nos conectamos
                invoke  Connect

                ; lanzar el gui
                invoke  DialogBoxParam, hInst, IDD_MAIN, NULL, MainDlgProc, NULL
                
            .endif

        .endif

        invoke ExitProcess, NULL
        ret
    end start
;-----------------------------------------------------------------------