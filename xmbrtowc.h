#ifdef WIN32
//
// Implementation of _mbrtowc()
//
// Copyright (c) 2004, Algin Technology LLC
// Written by Alan Klietz 
// Distributed under GNU General Public License version 2.
//
// $Id: xmbrtowc.h,v 1.2 2007/10/05 00:48:19 cvsalan Exp $
//

#ifdef __cplusplus
extern "C" {
#endif

extern size_t __cdecl
xmbrtowc(wchar_t *pwc, const char *s, size_t n, mbstate_t *pst);

#define mbrtowc(pwc,s,n,pst) xmbrtowc(pwc,s,n,pst)

#ifndef __cplusplus
//
// wchar.h forgot to define mbsinit() outside of __cplusplus.
// It is wrong anyway.
//
extern int mbsinit(const mbstate_t *mbs);
#endif

//
// Return the current effective codepage
//
extern int get_codepage();

#ifdef __cplusplus
}
#endif

#endif // WIN32

/*
vim:tabstop=4:shiftwidth=4:noexpandtab
*/
