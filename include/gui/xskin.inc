;-----------------------------------------------------------------------
xskin_init          proto   :dword, :dword, :dword
xskin_destroy       proto   :dword
xskin_resource      proto   :dword, :dword, :dword
xskin_background    proto   :dword, :dword
xskin_region        proto   :dword, :dword
xskin_button        proto   :dword, :dword, :dword
xskin_setfont       proto   :dword, :dword, :dword

xskin_scroll_init       proto   :dword
xskin_scroll_display    proto   :dword, :dword

xskin_fade_init     proto   :dword, :dword, :dword
xskin_fade          proto   :dword, :dword, :dword, :dword, :dword

uFMOD_FadeVol       proto   :dword, :dword, :dword, :dword
uFMOD_MUTE          equ uFMOD_MAX_VOL+1

;-----------------------------------------------------------------------
sskin_button    struct
    id_btn_up   dword   ?
    id_btn_down dword   ?
    id_btn_over dword   ?
    rect        RECT    <?>
sskin_button    ends

;-----------------------------------------------------------------------
sskin_data  struct
    hinst   dword   ?
    hwnd    dword   ?
    _hbackground    dword   ?
    _hbrush dword   ?
    _hfont  dword   ?
sskin_data  ends
    
;-----------------------------------------------------------------------
sskin_fade   struct
    hwnd        dword ?
    dw_initial  dword ?
    dw_final    dword ?
    dw_step     dword ?
    dw_speed    dword ?
    dw_level    dword ?
sskin_fade   ends

;-----------------------------------------------------------------------
sfadevol struct
    dw_init     dword   ?
    dw_final    dword   ?
    dw_step     dword   ?
    dw_speed    dword   ?
sfadevol ends

;-----------------------------------------------------------------------
FADE_MAX_LEVEL      equ 0FFh
FADE_OPAQUE         equ FADE_MAX_LEVEL
FADE_INVISIBLE      equ 100h

SCROLL_MAX_SPEED    equ 50
SCROLL_MIN_SPEED    equ 0

SCROLL_DIR_TOP      equ -1
SCROLL_DIR_BOTTOM   equ 1

;-----------------------------------------------------------------------
sPAUSE  struct
    _offset     dword   ?
    _interval   dword   ?
sPAUSE  ends

sPAUSES  struct
    _enabled    BOOL    ?
    _count      dword   ?
    _pauses     dword   ?
    _paused     dword   ?
sPAUSES  ends

;-----------------------------------------------------------------------
sHEADERS    struct
    show        BOOL    ?
    lpheader    dword   ?
    lpfooter    dword   ?
sHEADERS    ends

;-----------------------------------------------------------------------
sSCROLL      struct
    lpData          dword   ?
    Speed           dword   20
    Color           dword   ?
    Direction       dword   SCROLL_DIR_TOP
    hFont           HANDLE  ?
    hFontHeaders    HANDLE  ?
    Pause           BOOL    FALSE
    Autoscroll      BOOL    FALSE
    vCentered       BOOL    FALSE
    Headers         sHEADERS    <?>
    Pagin           sPAUSES  <?>
sSCROLL      ends
sskin_scroll typedef sSCROLL

;-----------------------------------------------------------------------
