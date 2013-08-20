;-----------------------------------------------------------------------
include         includes.inc

;-----------------------------------------------------------------------
MainDlgProc     proto   :dword,:dword,:dword,:dword

;-----------------------------------------------------------------------
CRLF                equ 13, 10
MIN_NAME_LENGTH     equ 6
MAX_NAME_LENGTH     equ 20
MIN_SERIAL_LENGTH   equ 63;leading zero
MAX_SERIAL_LENGTH   equ 65;counting null char

_STATUS_REGISTERED   equ TRUE
_STATUS_UNREGISTERED equ FALSE
WM_EXPIRED           equ WM_USER+1335
WM_SERVERDOWN        equ WM_USER+1336
WM_DEFEATED          equ WM_USER+1337

WM_ESCAPE            equ WM_USER+IDB_CLOSE

EDIT_TEXT_COLOR     equ 00CCAAAAh
SCROLL_TEXT_COLOR   equ 00CCCCCCh

;-----------------------------------------------------------------------
.const
    szscrtitle  byte "Mental Alteration", 0
    szscrfooter byte "Recruit 2009", 0
    
    szsuccess   byte CRLF, CRLF, "Successfully registered", CRLF,\
                     "Now send us your tutorial + kg with src", CRLF, "to be part of MAL", 0
    
    szdown      byte CRLF, CRLF, "Registration could not be performed", CRLF,\
                     "Try again later", 0
    
    szexpired   byte CRLF, CRLF, "This recruit has expired", CRLF, "contact MAL crew for info",0

    mfont		LOGFONT <-11, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE, 0, 3, 2, 1, 3, "Arial">

    sfont1		LOGFONT	<13, 0, NULL, NULL, 0, FALSE, FALSE, FALSE, OEM_CHARSET,\
                OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH, "Arial">

    sfont2		LOGFONT	<10, 0, NULL, NULL, 0, FALSE, FALSE, FALSE, OEM_CHARSET,\ 
                OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH, "Terminal">

    sexit_btn   sskin_button <IDR_EXITUP, IDR_EXITDOWN, IDR_EXITOVER, <4, 440, 0, 0>>
    shelp_btn   sskin_button <IDR_ABOUTUP, IDR_ABOUTDOWN, IDR_ABOUTOVER, <4, 410, 0, 0>>

    scr_pauses_help     dword -110, 3000, -240, 3000, -410, 0A000h, -520, 3000, 26, 4000
    scr_pauses_success  dword 25, -1

;-----------------------------------------------------------------------
.data
    scr_help    sskin_scroll <?, 50, SCROLL_TEXT_COLOR, SCROLL_DIR_TOP, ?, ?, FALSE, FALSE,\
                TRUE, <TRUE, offset szscrtitle, offset szscrfooter>, <TRUE, 5, offset scr_pauses_help, ?>>
    
    scr_success sskin_scroll <offset szsuccess, 50, SCROLL_TEXT_COLOR, SCROLL_DIR_TOP, ?, ?,\
                TRUE, TRUE, TRUE, <TRUE, offset szscrtitle, offset szscrfooter>, <TRUE, 1, offset scr_pauses_success, ?>>

    scr_down    sskin_scroll <offset szdown, 50, SCROLL_TEXT_COLOR, SCROLL_DIR_TOP, ?, ?,\
                TRUE, TRUE, TRUE, <TRUE, offset szscrtitle, offset szscrfooter>, <TRUE, 1, offset scr_pauses_success, ?>>

    scr_expired sskin_scroll <offset szexpired, 50, SCROLL_TEXT_COLOR, SCROLL_DIR_TOP, ?, ?,\
                TRUE, TRUE, TRUE, <TRUE, offset szscrtitle, offset szscrfooter>, <TRUE, 1, offset scr_pauses_success, ?>>

;-----------------------------------------------------------------------
.data?
    hInst       HANDLE      ?
    hReg        HANDLE      ?
    hbrush      HANDLE      ?
    xskin       sskin_data <?>
    xfade       sskin_fade <?>
    sdata       _data_information_block <?>
    hwnd        HWND        ?

;-----------------------------------------------------------------------