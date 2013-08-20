.code
    include     gui\initialize.asm
    ;include     gui\integrity.asm

;-----------------------------------------------------------------------
MainDlgProc proc    hWnd, uMsg, wParam, lParam:dword

    switch  uMsg
        case    WM_INITDIALOG
            
            m2m     hwnd, hWnd
            
            invoke  xskin_init, addr xskin, hInst, hWnd

            invoke  xskin_background, addr xskin, IDR_MAIN
            mov     hbrush, eax

            invoke  xskin_region, addr xskin, IDR_RGN
            
            invoke  xskin_button, addr xskin, IDB_CLOSE, addr sexit_btn            
            invoke  xskin_button, addr xskin, IDB_HELP, addr shelp_btn

            invoke  xskin_setfont, addr xskin, IDE_SERIAL, addr mfont
            invoke  xskin_setfont, addr xskin, IDE_NAME, 0

            invoke  xskin_resource, addr xskin, IDR_INFO, RT_RCDATA
            mov     scr_help.lpData, eax

            invoke  initialize, hWnd

            invoke  uFMOD_SetVolume, 0h
            invoke  uFMOD_FadeVol, uFMOD_MIN_VOL, uFMOD_MAX_VOL, 4h, 200h
            invoke  uFMOD_PlaySong, IDR_MUSIC, hInst, XM_RESOURCE

            invoke  xskin_fade_init, addr xskin, addr xfade, 0h
            invoke  xskin_fade, addr xskin, addr xfade, FADE_OPAQUE-40h, 5h, 20h

        case    WM_CTLCOLOREDIT
            invoke  GetDlgCtrlID, lParam
            .if     eax == IDE_SERIAL || eax == IDE_NAME
                invoke  SetBkMode, wParam, TRANSPARENT
                invoke  SetTextColor, wParam, EDIT_TEXT_COLOR
                invoke  SetBkColor, wParam, 0
                
                invoke  GetDlgCtrlID, lParam
                .if     eax == IDE_SERIAL
                    invoke  SetBrushOrgEx, wParam, -90, 53, 0
                .elseif eax == IDE_NAME
                    invoke  SetBrushOrgEx, wParam, -90, 69, 0
                
                .endif
                return  hbrush
            
            .endif

        case    WM_COMMAND || uMsg == WM_HOTKEY
            switch  wParam                   
                case    IDB_CLOSE
                    invoke  SendMessage, hWnd, WM_CLOSE, 0, 0

                case    IDB_HELP
                    invoke  xskin_scroll_init, addr scr_help
                    invoke  xskin_scroll_display, addr xskin, IDD_SCROLLER
                    
                case    WM_ESCAPE
                    invoke  SendMessage, hWnd, WM_CLOSE, 0, 0
                
                default
                    .if     ax == IDE_NAME || ax == IDE_SERIAL
                        shr     eax, 16
                        .if     ax == EN_CHANGE
                            invoke  SetEvent, hReg
                        .endif
                    .endif
            endsw

        case    WM_LBUTTONDOWN
            invoke  SendMessage, hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0

        case    WM_CLOSE || uMsg == WM_LBUTTONDBLCLK || uMsg == WM_RBUTTONDOWN
            invoke  uFMOD_FadeVol, uFMOD_MAX_VOL, uFMOD_MUTE, -10h, 30h
            invoke  uFMOD_PlaySong, 0, 0, 0
            invoke  xskin_fade, addr xskin, addr xfade, FADE_INVISIBLE, -10h, 10h
            invoke  xskin_destroy, addr xskin

            invoke  EndDialog, hWnd, 0

        case    WM_EXPIRED
            invoke  xskin_scroll_init, addr scr_expired
            invoke  xskin_scroll_display, addr xskin, IDD_SCROLLER
            
        case    WM_SERVERDOWN
            invoke  xskin_scroll_init, addr scr_down
            invoke  xskin_scroll_display, addr xskin, IDD_SCROLLER
            invoke  SendMessage, hWnd, WM_CLOSE, 0, 0

        case    WM_DEFEATED
            invoke  xskin_scroll_init, addr scr_success
            invoke  xskin_scroll_display, addr xskin, IDD_SCROLLER

    endsw

    return  FALSE

MainDlgProc endp
MainDlgProc_end:

;-----------------------------------------------------------------------
