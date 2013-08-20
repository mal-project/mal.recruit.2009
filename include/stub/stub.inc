;-----------------------------------------------------------------------
decode  proto   :dword
data_integrity      proto   :dword, :dword
change_permissions  proto   :dword, :dword

;-----------------------------------------------------------------------
sdecodeaddrs    struct
    data_addr   dword   ?
    data_length dword   ?
    data_key    byte    ?
sdecodeaddrs    ends

sdecode struct
    dwitems  dword   ?;number sections to decode
    lpaddrs  dword   ?
sdecode ends

;-----------------------------------------------------------------------
.const    
    sdecode_data sdecodeaddrs   <offset Instance, offset Instance_end-offset Instance, 13h>, <offset verify, offset verify_end-offset verify, 5Ah>,\
                                <offset rsa_public, 4*15, 01Eh>, <offset _server_listener, offset _server_listener_end-offset _server_listener, 0B4h>,\
                                <offset init, offset init_end-offset init, 23h>, <offset ldr_module, offset ldr_module_end-ldr_module, 31h>
    server_data  sdecode        <6, offset sdecode_data>

    server_crc32                dword 6 dup(?)
    server_crc32_checksum       dword ?

    server_crc32_runtime          dword 6 dup(?)
    server_crc32_runtime_checksum dword ?


    cdecode_data sdecodeaddrs   <offset Connect, offset Connect_end-offset Connect, 30h>, <offset MainDlgProc, offset MainDlgProc_end-offset MainDlgProc, 0DEh>, <offset _client_talker, offset _client_talker_end-offset _client_talker, 0ADh>,\
                                <offset initialize, offset initialize_end-offset initialize, 0BAh>, <offset szsuccess, offset scr_pauses_success-offset szsuccess, 0BEh>
    client_data  sdecode        <5, offset cdecode_data>

    client_crc32                dword 5 dup(?)
    client_crc32_checksum       dword ?

    client_crc32_runtime          dword 5 dup(?)
    client_crc32_runtime_checksum dword ?


    sdecode_stub sdecodeaddrs   <offset data_integrity, offset data_integrity_end-offset data_integrity, 55h>, <offset decode, offset decode_end-offset decode, 34h>,\
                                <offset sdecode_data, offset client_crc32_runtime_checksum-offset client_crc32_runtime_checksum, 9Ah>
    stub_data    sdecode        <3, offset sdecode_stub>

    stub_crc32                  dword 3 dup(?)
    stubs_crc32_checksum        dword ?


;-----------------------------------------------------------------------
.data?
    _dwkernel_ret       dword   ?
    
;-----------------------------------------------------------------------
