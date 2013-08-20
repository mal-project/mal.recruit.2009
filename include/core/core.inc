;-----------------------------------------------------------------------
.const
    ;szrsa_public    db "10001",0
    ;szrsa_private   db "154289DFD3ABDBAE3F66521E996730C64A7F0FB1E2E973F82225C02D7D2547DD",0
    ;szrsa_moduli    db "79D89FA16172012AA09EB748AE64A864572CF3572E6AB587EBEBE242FAC4C161",0
    
    rsa_public    dd 000000001h,000010001h
    ;rsa_private   dd 000000008h,07D2547DDh,02225C02Dh,0E2E973F8h,04A7F0FB1h,0996730C6h,03F66521Eh,0D3ABDBAEh,0154289DFh
    rsa_moduli    dd 000000008h,0FAC4C161h,0EBEBE242h,02E6AB587h,0572CF357h,0AE64A864h,0A09EB748h,06172012Ah,079D89FA1h
    
    ;szdlp_generator db "4AFC15E1",0
    ;szdlp_prime     db "67916E239BD233",0
    dlp_generator dd 000000001h, 04AFC15E1h
    dlp_prime     dd 000000002h, 0239BD233h, 00067916Eh

;-----------------------------------------------------------------------
.data

;-----------------------------------------------------------------------
.data?
    _dwvolumeserial dword   ?

;-----------------------------------------------------------------------