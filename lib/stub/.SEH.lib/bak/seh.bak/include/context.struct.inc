SIZE_OF_80387_REGISTERS   equ 80
MAXIMUM_SUPPORTED_EXTENSION          equ 512

FLOATING_SAVE_AREA STRUCT
  ControlWord   DWORD      ?
  StatusWord    DWORD      ?
  TagWord       DWORD      ?
  ErrorOffset   DWORD      ?
  ErrorSelector DWORD      ?
  DataOffset    DWORD      ?
  DataSelector  DWORD      ?
  RegisterArea  BYTE  SIZE_OF_80387_REGISTERS dup(?)
  Cr0NpxState   DWORD      ?
FLOATING_SAVE_AREA ENDS

CONTEXT STRUCT
  ContextFlags  DWORD      ?
  iDr0          DWORD      ?
  iDr1          DWORD      ?
  iDr2          DWORD      ?
  iDr3          DWORD      ?
  iDr6          DWORD      ?
  iDr7          DWORD      ?
  FloatSave     FLOATING_SAVE_AREA <>
  regGs         DWORD      ?
  regFs         DWORD      ?
  regEs         DWORD      ?
  regDs         DWORD      ?
  regEdi        DWORD      ?
  regEsi        DWORD      ?
  regEbx        DWORD      ?
  regEdx        DWORD      ?
  regEcx        DWORD      ?
  regEax        DWORD      ?
  regEbp        DWORD      ?
  regEip        DWORD      ?
  regCs         DWORD      ?
  regFlag       DWORD      ?
  regEsp        DWORD      ?
  regSs         DWORD      ?
  ExtendedRegisters db MAXIMUM_SUPPORTED_EXTENSION dup(?)
CONTEXT ENDS
