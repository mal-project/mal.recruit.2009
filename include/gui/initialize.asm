.code
;-----------------------------------------------------------------------
    initialize  proc    hWnd:HWND
        local   _dwlen:dword, _szname[100]:byte
        local   _time :SYSTEMTIME
        pushad

        invoke  SendDlgItemMessage, hWnd, IDE_NAME, EM_SETLIMITTEXT, MAX_NAME_LENGTH, 0
        invoke  SendDlgItemMessage, hWnd, IDE_SERIAL, EM_SETLIMITTEXT, MAX_SERIAL_LENGTH, 0

        ; Fetching and displaying user name in field "Name"
        mov     _dwlen, MAX_NAME_LENGTH
        invoke  GetUserName, addr _szname, addr _dwlen
        invoke  SendDlgItemMessage, hWnd, IDE_NAME, WM_SETTEXT, 0, addr _szname
        
        invoke  CreateEvent, 0, 0, 0, 0
        mov     hReg, eax

        invoke  RegisterHotKey, hWnd, WM_ESCAPE, 0, VK_ESCAPE

        invoke  CreateFontIndirect, addr sfont1
        mov     scr_help.hFont, eax
        mov     scr_success.hFont, eax
        mov     scr_down.hFont, eax
        mov     scr_expired.hFont, eax

        invoke  CreateFontIndirect, addr sfont2
        mov     scr_help.hFontHeaders, eax
        mov     scr_success.hFontHeaders, eax
        mov     scr_down.hFontHeaders, eax
        mov     scr_expired.hFontHeaders, eax
        
        invoke  GetLocalTime, addr _time
        .if     _time.wYear > 2009
            invoke  SendMessage, hWnd, WM_EXPIRED, 0, 0
        .endif

        popad
        ret
    initialize  endp
    initialize_end:

;-----------------------------------------------------------------------