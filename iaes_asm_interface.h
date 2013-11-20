/* 
 * Copyright (c) 2010, Intel Corporation
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 * 
 *     * Redistributions of source code must retain the above copyright notice, 
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright notice, 
 *       this list of conditions and the following disclaimer in the documentation 
 *       and/or other materials provided with the distribution.
 *     * Neither the name of Intel Corporation nor the names of its contributors 
 *       may be used to endorse or promote products derived from this software 
 *       without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 * IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
*/


#ifndef _INTEL_AES_ASM_INTERFACE_H__
#define _INTEL_AES_ASM_INTERFACE_H__

#include "iaesni.h"

typedef struct _sAesData
{
	_AES_IN		UCHAR	*in_block;
	_AES_OUT	UCHAR	*out_block;
	_AES_IN		UCHAR	*expanded_key;		
	_AES_INOUT	UCHAR	*iv;					// for CBC mode
	_AES_IN		size_t	num_blocks;
} sAesData;

#if (__cplusplus)
extern "C"
{
#endif
#if 0
#define MYSTDCALL __stdcall
#else
#define MYSTDCALL 
#endif

#ifdef __linux__
#ifndef __LP64__
#define iEncExpandKey256 _iEncExpandKey256
#define iDecExpandKey256 _iDecExpandKey256
#define iEnc256 _iEnc256
#define iDec256 _iDec256
#endif
#endif
	void MYSTDCALL iEncExpandKey256(_AES_IN UCHAR *key, _AES_OUT UCHAR *expanded_key);
	void MYSTDCALL iDecExpandKey256(UCHAR *key, _AES_OUT UCHAR *expanded_key);

	void MYSTDCALL iEnc256(sAesData *data);
	void MYSTDCALL iDec256(sAesData *data);


#endif

