.code
    include     init.asm

;-----------------------------------------------------------------------
    verify  proc uses ebx esi ecx, lpszname, lpszserial:dword
        local    md5[4], hmd5, hx, hcipher, hmessage:hBIG

        invoke  xszlen, lpszname
        mov     ebx, eax
        invoke  md5_hash, lpszname, ebx, addr md5

        invoke  big_create_array, addr hmessage, 4

        ; hacemos... esto
        lea     esi, md5
        mov     eax, [esi][00h]
        or      eax, [esi][04h]; md5._a||md5._b 
        mov     ebx, [esi][08h]
        xor     ebx, [esi][0Ch]; md5._c^md5._d
        adc     eax, ebx
        xor     eax, _dwvolumeserial
        invoke  big_var32, hmd5, eax

        ; desencriptamos el serial
        invoke  big_cinstr, lpszserial, hcipher        
        invoke  big_powmod, hcipher, addr rsa_public, addr rsa_moduli, hmessage
        
        ; verificamos el dlp
        invoke  big_powmod, addr dlp_generator, hmessage, addr dlp_prime, hx

        ; finalmente
        invoke  big_compare, hmd5, hx        
        push    eax
        invoke  big_destroy_array, addr hmessage, 4
        
        pop     eax
        ret

    verify  endp
    verify_end:
;-----------------------------------------------------------------------