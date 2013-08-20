include context.struct.inc
include     bak\user32.inc
includelib  bak\user32.lib

sREGISTERS  struct
    RegEAX      dd  ?
    RegECX      dd  ?
    RegEDX      dd  ?
    RegEBX      dd  ?
    RegESP      dd  ?
    RegEBP      dd  ?
    RegESI      dd  ?
    RegEDI      dd  ?
sREGISTERS  ends

sSEH     struct
    SEHEIP      dd  ?
    Reg         sREGISTERS  <>
sSEH     ends

DATA_STRUCT struct
    SEH     sSEH    <>
DATA_STRUCT ends

.data?
    seh_data    sSEH <?>