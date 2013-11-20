[bits 64]
[CPU intelnop]

; Copyright (c) 2010, Intel Corporation
; All rights reserved.
; 
; Redistribution and use in source and binary forms, with or without 
; modification, are permitted provided that the following conditions are met:
; 
;     * Redistributions of source code must retain the above copyright notice, 
;       this list of conditions and the following disclaimer.
;     * Redistributions in binary form must reproduce the above copyright notice, 
;       this list of conditions and the following disclaimer in the documentation 
;       and/or other materials provided with the distribution.
;     * Neither the name of Intel Corporation nor the names of its contributors 
;       may be used to endorse or promote products derived from this software 
;       without specific prior written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
; IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
; INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
; BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
; LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
; OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
; ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


%macro linux_setup 0
%ifdef __linux__
mov rcx, rdi
mov rdx, rsi
%endif
%endmacro

%macro inversekey 1
movdqu  xmm1,%1
aesimc	xmm0,xmm1
movdqu	%1,xmm0
%endmacro

%macro aesdeclast1 1
aesdeclast	xmm0,%1
%endmacro

%macro aesenclast1 1
aesenclast	xmm0,%1
%endmacro

%macro aesdec1 1
aesdec	xmm0,%1
%endmacro

%macro aesenc1 1
aesenc	xmm0,%1
%endmacro


%macro aesdeclast1_u 1
movdqu xmm4,%1
aesdeclast	xmm0,xmm4
%endmacro

%macro aesenclast1_u 1
movdqu xmm4,%1
aesenclast	xmm0,xmm4
%endmacro

%macro aesdec1_u 1
movdqu xmm4,%1
aesdec	xmm0,xmm4
%endmacro

%macro aesenc1_u 1
movdqu xmm4,%1
aesenc	xmm0,xmm4
%endmacro

%macro aesdec4 1
movdqa	xmm4,%1

aesdec	xmm0,xmm4
aesdec	xmm1,xmm4
aesdec	xmm2,xmm4
aesdec	xmm3,xmm4

%endmacro

%macro aesdeclast4 1
movdqa	xmm4,%1

aesdeclast	xmm0,xmm4
aesdeclast	xmm1,xmm4
aesdeclast	xmm2,xmm4
aesdeclast	xmm3,xmm4

%endmacro


%macro aesenc4 1
movdqa	xmm4,%1

aesenc	xmm0,xmm4
aesenc	xmm1,xmm4
aesenc	xmm2,xmm4
aesenc	xmm3,xmm4

%endmacro

%macro aesenclast4 1
movdqa	xmm4,%1

aesenclast	xmm0,xmm4
aesenclast	xmm1,xmm4
aesenclast	xmm2,xmm4
aesenclast	xmm3,xmm4

%endmacro


%macro load_and_inc4 1
movdqa	xmm4,%1
movdqa	xmm0,xmm5
pshufb	xmm0, xmm6 ; byte swap counter back
movdqa  xmm1,xmm5
paddd	xmm1,[counter_add_one wrt rip]
pshufb	xmm1, xmm6 ; byte swap counter back
movdqa  xmm2,xmm5
paddd	xmm2,[counter_add_two wrt rip]
pshufb	xmm2, xmm6 ; byte swap counter back
movdqa  xmm3,xmm5
paddd	xmm3,[counter_add_three wrt rip]
pshufb	xmm3, xmm6 ; byte swap counter back
pxor	xmm0,xmm4
paddd	xmm5,[counter_add_four wrt rip]
pxor	xmm1,xmm4
pxor	xmm2,xmm4
pxor	xmm3,xmm4
%endmacro

%macro xor_with_input4 1
movdqu xmm4,[%1]
pxor xmm0,xmm4
movdqu xmm4,[%1+16]
pxor xmm1,xmm4
movdqu xmm4,[%1+32]
pxor xmm2,xmm4
movdqu xmm4,[%1+48]
pxor xmm3,xmm4
%endmacro



%macro load_and_xor4 2
movdqa	xmm4,%2
movdqu	xmm0,[%1 + 0*16]
pxor	xmm0,xmm4
movdqu	xmm1,[%1 + 1*16]
pxor	xmm1,xmm4
movdqu	xmm2,[%1 + 2*16]
pxor	xmm2,xmm4
movdqu	xmm3,[%1 + 3*16]
pxor	xmm3,xmm4
%endmacro

%macro store4 1
movdqu [%1 + 0*16],xmm0
movdqu [%1 + 1*16],xmm1
movdqu [%1 + 2*16],xmm2
movdqu [%1 + 3*16],xmm3
%endmacro

%macro copy_round_keys 3
movdqu xmm4,[%2 + ((%3)*16)]
movdqa [%1 + ((%3)*16)],xmm4
%endmacro


section .data
align 16
shuffle_mask:
DD 0FFFFFFFFh
DD 03020100h
DD 07060504h
DD 0B0A0908h

byte_swap_16:
DDQ 0x000102030405060708090A0B0C0D0E0F

align 16
counter_add_one:
DD 1
DD 0
DD 0
DD 0

counter_add_two:
DD 2
DD 0
DD 0
DD 0

counter_add_three:
DD 3
DD 0
DD 0
DD 0

counter_add_four:
DD 4
DD 0
DD 0
DD 0



section .text

align 16
key_expansion256:

pshufd xmm2, xmm2, 011111111b

movdqa xmm4, xmm1
pshufb xmm4, xmm5
pxor xmm1, xmm4
pshufb xmm4, xmm5
pxor xmm1, xmm4
pshufb xmm4, xmm5
pxor xmm1, xmm4
pxor xmm1, xmm2

movdqu [rdx], xmm1
add rdx, 0x10

aeskeygenassist xmm4, xmm1, 0
pshufd xmm2, xmm4, 010101010b

movdqa xmm4, xmm3
pshufb xmm4, xmm5
pxor xmm3, xmm4
pshufb xmm4, xmm5
pxor xmm3, xmm4
pshufb xmm4, xmm5
pxor xmm3, xmm4
pxor xmm3, xmm2

movdqu [rdx], xmm3
add rdx, 0x10

ret




align 16
global iDecExpandKey256
iDecExpandKey256:

linux_setup
push rcx
push rdx
sub rsp,16+8

call iEncExpandKey256

add rsp,16+8
pop rdx
pop rcx

inversekey [rdx + 1*16]
inversekey [rdx + 2*16]
inversekey [rdx + 3*16]
inversekey [rdx + 4*16]
inversekey [rdx + 5*16]
inversekey [rdx + 6*16]
inversekey [rdx + 7*16]
inversekey [rdx + 8*16]
inversekey [rdx + 9*16]
inversekey [rdx + 10*16]
inversekey [rdx + 11*16]
inversekey [rdx + 12*16]
inversekey [rdx + 13*16]

ret




align 16
global iEncExpandKey256
iEncExpandKey256:

linux_setup

movdqu xmm1, [rcx]    ; loading the key
movdqu xmm3, [rcx+16]
movdqu [rdx], xmm1  ; Storing key in memory where all key schedule will be stored
movdqu [rdx+16], xmm3

add rdx,32

movdqa xmm5, [shuffle_mask wrt rip]  ; this mask is used by key_expansion

aeskeygenassist xmm2, xmm3, 0x1     ;
call key_expansion256
aeskeygenassist xmm2, xmm3, 0x2     ;
call key_expansion256
aeskeygenassist xmm2, xmm3, 0x4     ;
call key_expansion256
aeskeygenassist xmm2, xmm3, 0x8     ;
call key_expansion256
aeskeygenassist xmm2, xmm3, 0x10    ;
call key_expansion256
aeskeygenassist xmm2, xmm3, 0x20    ;
call key_expansion256
aeskeygenassist xmm2, xmm3, 0x40    ;

pshufd xmm2, xmm2, 011111111b

movdqa xmm4, xmm1
pshufb xmm4, xmm5
pxor xmm1, xmm4
pshufb xmm4, xmm5
pxor xmm1, xmm4
pshufb xmm4, xmm5
pxor xmm1, xmm4
pxor xmm1, xmm2

movdqu [rdx], xmm1


ret



align 16
global iDec256_CBC
iDec256_CBC:

linux_setup
sub rsp,16*16+8

mov r9,rcx
mov rax,[rcx+24]
movdqu	xmm5,[rax]

mov eax,[rcx+32] ; numblocks
mov rdx,[rcx]
mov r8,[rcx+8]
mov rcx,[rcx+16]


sub r8,rdx

test eax,eax
jz end_dec256_CBC

cmp eax,4
jl	lp256decsingle_CBC

test	rcx,0xf
jz		lp256decfour_CBC

copy_round_keys rsp,rcx,0
copy_round_keys rsp,rcx,1
copy_round_keys rsp,rcx,2
copy_round_keys rsp,rcx,3
copy_round_keys rsp,rcx,4
copy_round_keys rsp,rcx,5
copy_round_keys rsp,rcx,6
copy_round_keys rsp,rcx,7
copy_round_keys rsp,rcx,8
copy_round_keys rsp,rcx,9
copy_round_keys rsp,rcx,10
copy_round_keys rsp,rcx,11
copy_round_keys rsp,rcx,12
copy_round_keys rsp,rcx,13
copy_round_keys rsp,rcx,14
mov rcx,rsp

align 16
lp256decfour_CBC:

test eax,eax
jz end_dec256_CBC

cmp eax,4
jl	lp256decsingle_CBC

load_and_xor4 rdx, [rcx+14*16]
add rdx,16*4
aesdec4 [rcx+13*16]
aesdec4 [rcx+12*16]
aesdec4 [rcx+11*16]
aesdec4 [rcx+10*16]
aesdec4 [rcx+9*16]
aesdec4 [rcx+8*16]
aesdec4 [rcx+7*16]
aesdec4 [rcx+6*16]
aesdec4 [rcx+5*16]
aesdec4 [rcx+4*16]
aesdec4 [rcx+3*16]
aesdec4 [rcx+2*16]
aesdec4 [rcx+1*16]
aesdeclast4 [rcx+0*16]

pxor	xmm0,xmm5
movdqu	xmm4,[rdx - 16*4 + 0*16]
pxor	xmm1,xmm4
movdqu	xmm4,[rdx - 16*4 + 1*16]
pxor	xmm2,xmm4
movdqu	xmm4,[rdx - 16*4 + 2*16]
pxor	xmm3,xmm4
movdqu	xmm5,[rdx - 16*4 + 3*16]

sub eax,4
store4 r8+rdx-(16*4)
jmp lp256decfour_CBC


align 16
lp256decsingle_CBC:

movdqu xmm0, [rdx]
movdqu xmm4,[rcx+14*16]
movdqa	xmm1,xmm0
pxor xmm0, xmm4
aesdec1_u [rcx+13*16]
aesdec1_u [rcx+12*16]
aesdec1_u [rcx+11*16]
aesdec1_u [rcx+10*16]
aesdec1_u [rcx+9*16]
aesdec1_u [rcx+8*16]
aesdec1_u [rcx+7*16]
aesdec1_u [rcx+6*16]
aesdec1_u [rcx+5*16]
aesdec1_u [rcx+4*16]
aesdec1_u [rcx+3*16]
aesdec1_u [rcx+2*16]
aesdec1_u [rcx+1*16]
aesdeclast1_u [rcx+0*16]

pxor	xmm0,xmm5
movdqa	xmm5,xmm1
add rdx, 16
movdqu  [r8 + rdx - 16], xmm0
dec eax
jnz lp256decsingle_CBC

end_dec256_CBC:

mov	   r9,[r9+24]
movdqu [r9],xmm5
add rsp,16*16+8
ret


align 16
global iDec256
iDec256:

linux_setup
sub rsp,16*16+8

mov eax,[rcx+32] ; numblocks
mov rdx,[rcx]
mov r8,[rcx+8]
mov rcx,[rcx+16]

sub r8,rdx


test eax,eax
jz end_dec256

cmp eax,4
jl lp256dec

test	rcx,0xf
jz		lp256dec4

copy_round_keys rsp,rcx,0
copy_round_keys rsp,rcx,1
copy_round_keys rsp,rcx,2
copy_round_keys rsp,rcx,3
copy_round_keys rsp,rcx,4
copy_round_keys rsp,rcx,5
copy_round_keys rsp,rcx,6
copy_round_keys rsp,rcx,7
copy_round_keys rsp,rcx,8
copy_round_keys rsp,rcx,9
copy_round_keys rsp,rcx,10
copy_round_keys rsp,rcx,11
copy_round_keys rsp,rcx,12
copy_round_keys rsp,rcx,13
copy_round_keys rsp,rcx,14
mov rcx,rsp


align 16
lp256dec4:
test eax,eax
jz end_dec256

cmp eax,4
jl lp256dec

load_and_xor4 rdx,[rcx+14*16]
add rdx, 4*16
aesdec4 [rcx+13*16]
aesdec4 [rcx+12*16]
aesdec4 [rcx+11*16]
aesdec4 [rcx+10*16]
aesdec4 [rcx+9*16]
aesdec4 [rcx+8*16]
aesdec4 [rcx+7*16]
aesdec4 [rcx+6*16]
aesdec4 [rcx+5*16]
aesdec4 [rcx+4*16]
aesdec4 [rcx+3*16]
aesdec4 [rcx+2*16]
aesdec4 [rcx+1*16]
aesdeclast4 [rcx+0*16]

store4 r8+rdx-16*4
sub eax,4
jmp lp256dec4

align 16
lp256dec:

movdqu xmm0, [rdx]
movdqu xmm4,[rcx+14*16]
add rdx, 16
pxor xmm0, xmm4                    ; Round 0 (only xor)
aesdec1_u [rcx+13*16]
aesdec1_u [rcx+12*16]
aesdec1_u [rcx+11*16]
aesdec1_u [rcx+10*16]
aesdec1_u [rcx+9*16]
aesdec1_u [rcx+8*16]
aesdec1_u [rcx+7*16]
aesdec1_u [rcx+6*16]
aesdec1_u [rcx+5*16]
aesdec1_u [rcx+4*16]
aesdec1_u [rcx+3*16]
aesdec1_u [rcx+2*16]
aesdec1_u [rcx+1*16]
aesdeclast1_u [rcx+0*16]

movdqu  [r8+rdx-16], xmm0
dec eax
jnz lp256dec

end_dec256:

add rsp,16*16+8
ret





align 16

lpencctr256four:

test eax,eax
jz end_encctr256

cmp eax,4
jl lp256encctrsingle

load_and_inc4 [rcx+0*16]
add rdx,4*16
aesenc4	[rcx+1*16]
aesenc4	[rcx+2*16]
aesenc4	[rcx+3*16]
aesenc4	[rcx+4*16]
aesenc4	[rcx+5*16]
aesenc4	[rcx+6*16]
aesenc4	[rcx+7*16]
aesenc4	[rcx+8*16]
aesenc4	[rcx+9*16]
aesenc4	[rcx+10*16]
aesenc4	[rcx+11*16]
aesenc4	[rcx+12*16]
aesenc4	[rcx+13*16]
aesenclast4	[rcx+14*16]
xor_with_input4 rdx-(4*16)

store4 r8+rdx-16*4
sub eax,4
jmp lpencctr256four

align 16
lp256encctrsingle:

movdqa xmm0,xmm5
pshufb	xmm0, xmm6 ; byte swap counter back
movdqu xmm4,[rcx+0*16]
paddd	xmm5,[counter_add_one wrt rip]
add rdx, 16
pxor xmm0, xmm4
aesenc1_u [rcx+1*16]
aesenc1_u [rcx+2*16]
aesenc1_u [rcx+3*16]
aesenc1_u [rcx+4*16]
aesenc1_u [rcx+5*16]
aesenc1_u [rcx+6*16]
aesenc1_u [rcx+7*16]
aesenc1_u [rcx+8*16]
aesenc1_u [rcx+9*16]
aesenc1_u [rcx+10*16]
aesenc1_u [rcx+11*16]
aesenc1_u [rcx+12*16]
aesenc1_u [rcx+13*16]
aesenclast1_u [rcx+14*16]
movdqu xmm4, [rdx-16]
pxor  xmm0,xmm4

movdqu  [r8+rdx-16], xmm0
dec eax
jnz lp256encctrsingle

end_encctr256:

mov	   r9,[r9+24]
pshufb xmm5, xmm6 ; byte swap counter
movdqu [r9],xmm5
movdqa xmm6, [rsp+16*16]
add rsp,16*16+8+16
ret



align 16
global iEnc256_CBC
iEnc256_CBC:

linux_setup
sub rsp,16*16+8

mov r9,rcx
mov rax,[rcx+24]
movdqu xmm1,[rax]

mov eax,[rcx+32] ; numblocks
mov rdx,[rcx]
mov r8,[rcx+8]
mov rcx,[rcx+16]

sub r8,rdx

test	rcx,0xf
jz		lp256encsingle_CBC

copy_round_keys rsp,rcx,0
copy_round_keys rsp,rcx,1
copy_round_keys rsp,rcx,2
copy_round_keys rsp,rcx,3
copy_round_keys rsp,rcx,4
copy_round_keys rsp,rcx,5
copy_round_keys rsp,rcx,6
copy_round_keys rsp,rcx,7
copy_round_keys rsp,rcx,8
copy_round_keys rsp,rcx,9
copy_round_keys rsp,rcx,10
copy_round_keys rsp,rcx,11
copy_round_keys rsp,rcx,12
copy_round_keys rsp,rcx,13
copy_round_keys rsp,rcx,14
mov rcx,rsp

align 16

lp256encsingle_CBC:

movdqu xmm0, [rdx]
movdqu xmm4, [rcx+0*16]
add rdx, 16
pxor xmm0, xmm1
pxor xmm0, xmm4
aesenc1 [rcx+1*16]
aesenc1 [rcx+2*16]
aesenc1 [rcx+3*16]
aesenc1 [rcx+4*16]
aesenc1 [rcx+5*16]
aesenc1 [rcx+6*16]
aesenc1 [rcx+7*16]
aesenc1 [rcx+8*16]
aesenc1 [rcx+9*16]
aesenc1 [rcx+10*16]
aesenc1 [rcx+11*16]
aesenc1 [rcx+12*16]
aesenc1 [rcx+13*16]
aesenclast1 [rcx+14*16]
movdqa xmm1,xmm0

movdqu  [r8+rdx-16], xmm0
dec eax
jnz lp256encsingle_CBC

mov	   r9,[r9+24]
movdqu [r9],xmm1
add rsp,16*16+8
ret



align 16
global iEnc256
iEnc256:

linux_setup
sub rsp,16*16+8

mov eax,[rcx+32] ; numblocks
mov rdx,[rcx]
mov r8,[rcx+8]
mov rcx,[rcx+16]

sub r8,rdx


test eax,eax
jz end_enc256

cmp eax,4
jl lp256enc

test	rcx,0xf
jz		lp256enc4

copy_round_keys rsp,rcx,0
copy_round_keys rsp,rcx,1
copy_round_keys rsp,rcx,2
copy_round_keys rsp,rcx,3
copy_round_keys rsp,rcx,4
copy_round_keys rsp,rcx,5
copy_round_keys rsp,rcx,6
copy_round_keys rsp,rcx,7
copy_round_keys rsp,rcx,8
copy_round_keys rsp,rcx,9
copy_round_keys rsp,rcx,10
copy_round_keys rsp,rcx,11
copy_round_keys rsp,rcx,12
copy_round_keys rsp,rcx,13
copy_round_keys rsp,rcx,14
mov rcx,rsp


align 16

lp256enc4:
test eax,eax
jz end_enc256

cmp eax,4
jl lp256enc


load_and_xor4 rdx,[rcx+0*16]
add rdx, 16*4
aesenc4 [rcx+1*16]
aesenc4 [rcx+2*16]
aesenc4 [rcx+3*16]
aesenc4 [rcx+4*16]
aesenc4 [rcx+5*16]
aesenc4 [rcx+6*16]
aesenc4 [rcx+7*16]
aesenc4 [rcx+8*16]
aesenc4 [rcx+9*16]
aesenc4 [rcx+10*16]
aesenc4 [rcx+11*16]
aesenc4 [rcx+12*16]
aesenc4 [rcx+13*16]
aesenclast4 [rcx+14*16]

store4  r8+rdx-16*4
sub eax,4
jmp lp256enc4

align 16
lp256enc:

movdqu xmm0, [rdx]
movdqu xmm4, [rcx+0*16]
add rdx, 16
pxor xmm0, xmm4
aesenc1_u [rcx+1*16]
aesenc1_u [rcx+2*16]
aesenc1_u [rcx+3*16]
aesenc1_u [rcx+4*16]
aesenc1_u [rcx+5*16]
aesenc1_u [rcx+6*16]
aesenc1_u [rcx+7*16]
aesenc1_u [rcx+8*16]
aesenc1_u [rcx+9*16]
aesenc1_u [rcx+10*16]
aesenc1_u [rcx+11*16]
aesenc1_u [rcx+12*16]
aesenc1_u [rcx+13*16]
aesenclast1_u [rcx+14*16]

movdqu  [r8+rdx-16], xmm0
dec eax
jnz lp256enc

end_enc256:

add rsp,16*16+8
ret
