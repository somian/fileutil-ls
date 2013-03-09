//
// Wrap stdio for more-style pagination
//
// Copyright (c) 2004, Algin Technology LLC
// Written by Alan Klietz 
// Distributed under GNU General Public License version 2.
//
// $Id: more.c,v 1.2 2008/08/28 22:44:33 cvsalan Exp $
//

//
// This is a built-in paginator ("Press any key to continue..")
//
// It is required because piping 'ls | more' does not
// work for colors.   This is because of the way that colors are displayed
// in console mode.  Colors are set not by escape codes embedded in
// the text stream, but rather they are set by doing direct hardware
// pokes on the console framebuffer via WriteConsoleOutputCharacter().
//
// Thus the paginator needs to be 'aware' of colors outside the context
// of the byte stream.   Piping 'ls | more' cannot work.
//
// If not running in a console window, the paginator falls back to the
// Unix-style escape codes.  Thus it works correctly both in console mode
// and in a 'real' GUI shell (e.g., Emacs and rxvt).
//
// This module depends on complex initialization gymnastics to
// work properly between OEM (console mode) and ANSI (GUI) character sets.
// See the comments in ls.c surrounding setlocale()
//
#include "config.h"

#ifdef WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include <io.h> // for isatty()

#include <mbstring.h>

#ifdef WIN32
#include <conio.h> // for getch
#endif

#include "xalloc.h"
#include "more.h"
#include "error.h"
#include "ls.h" // for tabsize

#define STDMORE_BUFSIZ 4096

#ifdef WIN32
//
// By default Win32 console programs use the apallingly slow thread-safe
// version of putc() in MSVCRT.DLL for locking multi-threaded writes.  
// Use the macro instead since we know we are single-threaded.
//
// (Also use setvbuf() to get the best speedup.)
//
#undef putc
#define putc(_c,_stream)  (--(_stream)->_cnt >= 0 \
    ? 0xff & (*(_stream)->_ptr++ = (char)(_c)) :  _flsbuf((_c),(_stream)))
#endif

static int more_enabled;

static char morebuf[STDMORE_BUFSIZ+10];
static struct more _stdmore_dat = { morebuf, STDMORE_BUFSIZ, morebuf,
	0, STDMORE_BUFSIZ, NULL, -1, 0 };
struct more* stdmore = &_stdmore_dat;

#define STDMORE_ERR_BUFSIZ 1
static char err_morebuf[STDMORE_ERR_BUFSIZ+3];
static struct more _stdmore_err_dat = { err_morebuf, STDMORE_ERR_BUFSIZ,
	err_morebuf, 0, STDMORE_ERR_BUFSIZ, NULL, -1, 0 };
struct more* stdmore_err = &_stdmore_err_dat;

static int _more_paginate(struct more* m, int n);

int more_enable(int enable)
{
	int oldval = more_enabled;
	more_enabled = enable;
	return oldval;
}

int more_fflush(struct more *m)
{
	int n;

	if (m->err) return EOF;

	n = m->ptr - m->base;
	m->ptr = m->base;
	m->cnt = m->bufsiz;

	if (n == 0) {
		return 0;
	}

	m->nflushed += n;  // total bytes flushed
	//
	// Feed out n bytes
	//
	if (_more_paginate(m, n) == EOF) {
		m->ptr = m->base; m->cnt = 0; m->err =  1;
		return EOF;
	}
	return 0;
}


int _more_flushbuf(char ch, struct more *m)
{
	if (more_fflush(m) == EOF) {
		return EOF;
	}
	return more_putc(ch, m);
}

int more_fputs(const char *s, struct more* m)
{
	int n;

	for (n = (int)strlen(s); n > 0; --n) {
		if (more_putc(*s, m) == EOF) {
			return EOF;
		}
		++s; // do _not_ increment in more_putc - macro!
	}
	return 0;
}

size_t more_fwrite(const char *s, int siz, int len, struct more* m)
{
	int  n = siz * len, i;

	for (i=0; i < n; ++i) {
		if (more_putc(*s, m) == EOF) {
			return (size_t)i;
		}
		++s; // do _not_ increment in more_putc - macro!
	}
	return (size_t)n;
}

int
_more_doprintf(struct more* m, const char *fmt, va_list args)
{
	int ret;
	char buf[2048];

	ret = _vsnprintf(buf, sizeof(buf)-1, fmt, args);

	if (ret <= 0) { // too big
		return ret;
	}

	if (more_fwrite(buf, 1, ret, m) != (size_t)ret) {
		return -1;
	}

	return ret;
}

int
more_fprintf(struct more *m, const char *fmt, ...)
{
	va_list args;
	int ret;

	va_start(args, fmt);
	ret = _more_doprintf(m, fmt, args);
	va_end(args);

	return ret;
}

int
more_vfprintf(struct more *m, const char *fmt, va_list args)
{
	return _more_doprintf(m, fmt, args);
}

int
more_printf(const char *fmt, ...)
{
	va_list args;
	int ret;

	va_start(args, fmt);
	ret = _more_doprintf(stdmore, fmt, args);
	va_end(args);

	return ret;
}

////////////////////////////////////////////////////////////////////////

int _send_output(FILE *f, char *s, int n)
{
	if (fwrite(s, 1, n, f) != (size_t)n) {
		return EOF;
	}
	return fflush(f);
}

#define TABSIZE tabsize // from ls.c

static int rows=40, cols=80; // defaults
static int currow=0, curcol=0;

//
// Feed out m->base, n bytes
//
static int __more_paginate(struct more* m, int n)
{
	static int init = 0;
	static int bHasTerm;
#ifdef WIN32
	static HANDLE hConsole;
	static CONSOLE_SCREEN_BUFFER_INFO csbi;
#endif
	char *s, ch;

	if (init == 0) {
		init = 1;
#ifdef WIN32
		if ((hConsole = GetStdHandle(STD_ERROR_HANDLE)) == INVALID_HANDLE_VALUE) {
			bHasTerm = 0;
		} else if (GetConsoleScreenBufferInfo(hConsole, &csbi) == 0) {
			bHasTerm = 0;
		} else {
			rows = (csbi.srWindow.Bottom - csbi.srWindow.Top) + 1;
			cols = (csbi.srWindow.Right - csbi.srWindow.Left) + 1;
			bHasTerm = 1;
		}
#else
# ifdef TIOCGWINSZ
	    {
			struct winsize ws;

			if (ioctl (STDOUT_FILENO, TIOCGWINSZ, &ws) != -1 && ws.ws_col != 0) {
			  rows = ws.ws_row;
			  cols = ws.ws_col;
			  bHasTerm = 1;
			} else {
			  bHasTerm = 0;
			}
  		}
# else
#warning Missing TIOCGWINSZ - cannot determine # of rows and cols
		bHasTerm = 0;
# endif
#endif
	} // init

	if (m->istty == -1) { // dunno if we are a tty
		if (m->file == NULL) {
			if (m == stdmore) {
				m->file = stdout;
			} else if (m == stdmore_err) {
				m->file = stderr;
			}
		}
		if (!bHasTerm) {
			m->istty = 0;
		} else {
			m->istty = isatty(fileno(m->file));
		}
	}

	if (n <= 0) {
		return 0;
	}

	if (n > 100000) { // sanity check
		return EOF;
	}

	if (!more_enabled || !m->istty) { // not a tty, just output as-is
		return _send_output(m->file, m->base, n);
	}

	/////////////////////////////////////////////////////////////////
	//
	// Send output, pausing on full screen
	//
	for (s = m->base; n > 0; --n) {
		ch = *s++;
		if (putc(ch, m->file) == EOF) {
			return EOF;
		}
		//
		// _ismbblead(ch): Leading byte is in range 0x81-0x9F or 0xE0-0xFC.
		// The trailing byte is guaranteed to be in range 0x40-0xFC (not 0x7F).
		// See _ismbclegal.  Used for Katakana, Kanji, and other
		// Asian language code pages.
		//
		if (_ismbblead(ch)) {
			//
			// Try to output the second byte if available
			//
			if (n-1 > 0) {
				if (putc(*s, m->file) == EOF) {
					return EOF;
				}
				++s; --n;
			} else {
				//
				// BUG: A multibyte char was split at the buffer edge.
				// This will throw the count off if the trailing byte
				// is in 0x81-0x7E,0x80-0x9F,0xE0-0xFC.
				//
				// Since it will always overestimate, it will never
				// overscroll (only underscroll) so it should be safe to
				// ignore.
				// 
				// You can reduce occurences of this bug by making
				// STDMORE_BUFSIZ bigger.
				//
			}
		}

		if (ch == '\n') {
			++currow;
			curcol = 0;
		} else if (ch == '\r') {
			// ignore
		} else if (ch == '\t') {
#ifdef _DEBUG
			if (TABSIZE == 0) {
				fputs("\n\nTried to print tab with -T0 -- aborting (DEBUG)\n", stderr);
				fflush(stderr);
				*(int *)0 = 0; // boom
			}
#endif
			curcol += (TABSIZE == 0 ? 8 : TABSIZE) - curcol % (TABSIZE == 0 ? 8 : TABSIZE);
		} else if (ch >= 32) { // if not a control char
			++curcol;
		}

		// Wrap on right
		if (curcol >= cols) {
			curcol=0;
			++currow;
		}

		if (currow >= rows-1-(1/*lines of previous screen to keep*/)) {
			currow = curcol = 0;
			if (fflush(m->file) == EOF) {
				return EOF;
			}
			fputs("Press any key to continue . . .", stderr);
			fflush(stderr);
			//
			// Use raw-mode getch
			//
			// For Unix set raw mode here
			//
			ch = (char)getch(); // (700 line function, ugh..)
			fputs("\r                               \r", stderr);
			//      "Press any key to continue . . ."
			fflush(stderr);
			//
			// BUG: Control-C does not trigger the signal handler
			// when using getch()!
			//
			if (ch == '\003') { // if we see ^C, bail immediately
				exit(1);
			}
		}
	}

	return fflush(m->file);
}


static int _more_paginate(struct more* m, int n)
{
	int ret;
	static int bInPaginator;

	if (bInPaginator) {
		//
		// Oops, we recursed somehow (prob via error())
		//
		return _send_output(m->file, m->base, n);
	}

	bInPaginator = 1;
	ret = __more_paginate(m, n);
	bInPaginator = 0;

	return ret;
}

/*
vim:tabstop=4:shiftwidth=4:noexpandtab
*/
