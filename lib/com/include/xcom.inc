;-----------------------------------------------------------------------
; en xcom.inc se definen las estructuras y los bloques de DATOS que se
; utilizaran por parte del servidor y por parte del cliente. (externamente
; al engine)
;-----------------------------------------------------------------------
MAX_CLIENTS_ALLOWED equ 4   ; numero maximo de clientes conectados
MAX_SERVER_DATA     equ 10  ; numero de bytes para el servidor
MAX_CLIENT_DATA     equ sizeof _client_data_block
ID_RAND_FLOOR       equ 1
ID_RAND_CEIL        equ 500

MIN_NAME_LENGTH     equ 6
MAX_NAME_LENGTH     equ 15
MIN_SERIAL_LENGTH   equ 32
MAX_SERIAL_LENGTH   equ 200

;-----------------------------------------------------------------------
; bloque de datos del lado del servidor.
_server_data_block     struct
    ;informacion general de la infeccion
    ;infection       _infection_information_block    <?>    ; not used yet
    ;informacion sobre el numero de threads y que hacen
    ;census          _census_information_block       <?>    ; not used yet
    data            db  MAX_SERVER_DATA   dup(NULL)
_server_data_block     ends

;-----------------------------------------------------------------------
; bloque de datos por parte del cliente.
_client_data_block        struct
    verify      BOOL    ?
    status      BOOL    ?
    szname      byte    MAX_NAME_LENGTH    dup(?)
    szserial    byte    MAX_SERIAL_LENGTH  dup(?)
    checksum    dword   ?
_client_data_block        ends

;-----------------------------------------------------------------------
