.code

    xsleep  proc    interval:dword
        pushad
        invoke  Sleep, interval
        popad
        ret
    xsleep  endp
