//
// Microsoft implemented _mbrtowc() in MSVCRT.DLL but they
// forgot to export it from the DLL (oops).
//
// So we roll own _mbrtowc() here.  This is sui-genris implementation
// w/o reference to the MSVCRT code.  Since I was doing it from scratch
// I decided to add UTF-8 support as an exercise. 
//
// Copyright (c) 2004, Algin Technology LLC
// Written by Alan Klietz 
// Distributed under GNU General Public License version 2.
//
// $Id: xmbrtowc.c,v 1.3 2008/01/15 13:20:06 cvsalan Exp $
//

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <wchar.h>

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <errno.h>

#include "error.h"

#include "xmbrtowc.h"
#include "ls.h"

extern int _HasConsole();

static void _init_codepage();

static int _codepage = -1;

#if WCHAR_MAX != 0xFFFF  // If MSSDK05 or earlier
//
// BUG: MSSDK05 and VS6 forgot to define mbsinit outside of __cplusplus.
//
int mbsinit(const mbstate_t *mbs)
{	
	// Return TRUE if mbstate_t is still in the initial state
	return (mbs==NULL || *mbs == 0);
}
#endif
 
int get_codepage()
{
	//
	// Initialize the codepage if not already
	//
	if (_codepage == -1) {
		_init_codepage();
	}
	return _codepage;
}

//
// Get the user current default OEM/ANSI code page
//
// Use OEM if outputting to a console window, otherwise use ANSI
//
static void _init_codepage()
{
	//
	// BUG: The MUI version of Windows is based on the English 
	// version, with the MUI languages layered on top of it.
	//
	// However GetACP/GetOEMCP are insensitive to the MUI language.
	// In MUI XP, for example, GetACP always is 1252 and GetOEMCP is 437
	// regardless of the MUI language.   This means that CP_ACP
	// and CP_OEM cannot be used with a MUI edition of Windows.
	// Only 100% pure Unicode apps will work correctly!
	//

	_codepage = gbOemCp ? GetOEMCP() : GetACP();

	return;

#ifdef UNDEFINED
	if (_HasConsole() && isatty(STDOUT_FILENO)) {
		//
		// msls is running under a console.  Use the console's current
		// output codepage.
		//
		// BUG: If the user's current locale (LCID) does not support a
		// console codepage, this function punts and returns CP_OEMCP,
		// which the system maps to the ANSI code page.  If the ANSI
		// code page also does not exist (e.g., Arabic languages), the
		// actual console codepage is 437 (United States OEM).  This means
		// that displaying Arabic file names in a console window using 
		// MBCS is impossible.  The only workaround is to re-write all of
		// msls using Unicode, which is too hard.
		//
		// BUG: If redirecting output to a file, msls uses the ANSI codepage. 
		// This allows the file to be viewed correctly in Notepad or Word.
		// However it screws up parsing argv[] command-line input,
		// and error messages to stderr will be wrong.
		//
		_codepage = GetConsoleOutputCP();
		return;
	}

	int lcidCountry = GetThreadLocale();
	char szCodePage[8];
	szCodePage[0] = _T('\0');

	int lcidCountry = GetUserDefaultLCID();
	int info = /*LOCALE_IDEFAULTCODEPAGE -- OEM*/
			     LOCALE_IDEFAULTANSICODEPAGE /* -- ANSI*/;

	//
	// Note: If the requested OEM/ACP codepage for the user user's
	// current local LCID does not exist, GetLocalInfo punts and returns 
	// CP_OEM (1) or, failing that CP_ACP (0).
	//
	// For example, Arabic languages do not work on a console.
	//
	if (!GetLocaleInfo(lcidCountry,
			info,
			szCodePage, sizeof(szCodePage)) ||
			((_codepage = (int)atol(szCodePage)) == 0
				&& szCodePage[0] != '0')) {
		error(EXIT_FAILURE, 0, "Unable to get locale info.");
	}
#endif
}


//
// Determine UTF byte length.
//
// Note: Since mbstate_t is defined as int we cannot
// handle 5 or 6 byte chars.
//
static size_t _utf8_len(const char *s)
{
	unsigned char c = (unsigned char)*s;

	if (c < 0xC0) return 1;
	if (0xC0 <= c && c <= 0xDF) return 2;
	if (0xE0 <= c && c <= 0xEF) return 3;
	if (0xF0 <= c && c <= 0xF7) return 4;
	if (0xF8 <= c && c <= 0xFB) return (size_t)-1; // 5 bytes unsupported
	if (0xF8 <= c && c <= 0xFD) return (size_t)-1; // 6 bytes unsupported
	return (size_t)-1; // Unicode endian markers 0xFE and 0xFF unsupported
}


//
// Implement mbrtowc per Standard ANSI C using MultiByteToWideChar
// and the user default current code page.
//
// This works with all codepages: Latin, Asian, and CP_UTF8.
//
size_t __cdecl
xmbrtowc(wchar_t *pwc, const char *s, size_t n, mbstate_t *pst)
{
	static mbstate_t mbst = 0;
	size_t bytelen = MB_CUR_MAX;
	int bLead;

	if (pst == NULL) {
		pst = &mbst; // note: not thread-safe
	}
	if (s == NULL) {
		pwc = NULL;
		s = "";
	}
	if ( s == NULL || n == 0 ) {
		return 0;
	}
	if ( *s == '\0') {
		if (pwc) {
			*pwc = L'\0';
		}
		return 0;
	}
	//
	// Initialize the codepage if not already
	//
	if (_codepage == -1) {
		_init_codepage();
	}
	if (*pst != 0) { // if continuation of partial multibyte char
		//
		// Determine length of char.
		//
		// Note: MB_CUR_MAX is really a locale-dependent variable,
		// __mb_cur_max, set by setlocale().
		//
		bytelen = (_codepage == CP_UTF8 ? _utf8_len((char*)pst) : MB_CUR_MAX);

		if (bytelen == (size_t)-1 || ++n < bytelen) {
			//
			// Still partial after 2 tries (or garbage in *pst),
			// punt.  Note: This is not strictly ANSI C compliant but
			// it would require extra state which does not fit in an int.
			//
			*pst = 0;
			errno = EILSEQ;
			return (size_t)-1;
		}

		if (n > bytelen) n = bytelen;

		// splice in the remainder of the char
		memcpy(((char*)pst)+1, s, n-1);

		if ((MultiByteToWideChar(_codepage,
				MB_PRECOMPOSED|MB_ERR_INVALID_CHARS,
				(char *)pst, n, pwc, (pwc) ? 1 : 0) == 0)) {  // failed
			*pst = 0;
			errno = EILSEQ;
			return (size_t)-1;
		}
		*pst = 0;
		return bytelen;
	} 
	if (_codepage == CP_UTF8) {
		if ((bytelen = _utf8_len(s)) == (size_t)-1) { // if bad UTF char
			*pst = 0;
			errno = EILSEQ;
			return (size_t)-1;
		}
		bLead = (bytelen > 1);
	} else {
		bytelen = MB_CUR_MAX;
		bLead = isleadbyte((unsigned char)*s);
	}
	if (bLead) { 
		//
		// 1st byte of multibyte char
		//
		if (n < bytelen) { // if input is truncated
			//
			// Tried to convert a partial multibyte char w/o rest of bytes
			//
			((char *)pst)[0] = *s;
			return (size_t)-2; // indicate partial

		} else {
			//
			// Convert multibyte char to Unicode-16
			//
			if (MultiByteToWideChar(_codepage, 
					MB_PRECOMPOSED | MB_ERR_INVALID_CHARS,
					s, bytelen, pwc, (pwc) ? 1 : 0) == 0) {
				//
				// Failed
				//
				*pst = 0;
				errno = EILSEQ;
				return (size_t)-1;
			}
		}
		return bytelen;
	}
	//
	// Single byte char - expansion still possible so do it
	//
	if (MultiByteToWideChar(_codepage, 
		  MB_PRECOMPOSED|MB_ERR_INVALID_CHARS, s, 1, pwc,
		  (pwc) ? 1 : 0) == 0 ) { // failed
		errno = EILSEQ;
		return (size_t)-1;
	}

	return 1; // single byte
}

/*
vim:tabstop=4:shiftwidth=4:noexpandtab
*/
