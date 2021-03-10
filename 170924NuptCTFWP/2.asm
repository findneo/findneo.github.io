00000000004004e6 <func>:
  4004e6: 55                    push   rbp
  4004e7: 48 89 e5              mov    rbp,rsp
  4004ea: 48 89 7d e8           mov    QWORD PTR [rbp-0x18],rdi
  4004ee: 89 75 e4              mov    DWORD PTR [rbp-0x1c],esi
  4004f1: c7 45 fc 01 00 00 00  mov    DWORD PTR [rbp-0x4],0x1
  4004f8: eb 28                 jmp    400522 <func+0x3c>
  4004fa: 8b 45 fc              mov    eax,DWORD PTR [rbp-0x4]
  4004fd: 48 63 d0              movsxd rdx,eax
  400500: 48 8b 45 e8           mov    rax,QWORD PTR [rbp-0x18]
  400504: 48 01 d0              add    rax,rdx
  400507: 8b 55 fc              mov    edx,DWORD PTR [rbp-0x4]
  40050a: 48 63 ca              movsxd rcx,edx
  40050d: 48 8b 55 e8           mov    rdx,QWORD PTR [rbp-0x18]
  400511: 48 01 ca              add    rdx,rcx
  400514: 0f b6 0a              movzx  ecx,BYTE PTR [rdx]
  400517: 8b 55 fc              mov    edx,DWORD PTR [rbp-0x4]
  40051a: 31 ca                 xor    edx,ecx
  40051c: 88 10                 mov    BYTE PTR [rax],dl
  40051e: 83 45 fc 01           add    DWORD PTR [rbp-0x4],0x1
  400522: 8b 45 fc              mov    eax,DWORD PTR [rbp-0x4]
  400525: 3b 45 e4              cmp    eax,DWORD PTR [rbp-0x1c]
  400528: 7e d0                 jle    4004fa <func+0x14>
  40052a: 90                    nop
  40052b: 5d                    pop    rbp
  40052c: c3                    ret