fileutil-ls
===========

Gnu fileutil ls (msls) with MS Windows extensions as done by Algin Technology

### Repository owner/maintainer: Sören Andersen

## Repository location

https://github.com/somian/fileutil-ls

### Source code notes

The source files are all in CRLF DOS line-ending format. This is how they were
stored in the downloaded .zip file in which Algin Technology distributes their
source. Instead of changing the line terminators, it's been decided to leave them
alone. Storing them this way is consistent with platform practices where the
proprietary compiler tools are the primary means of building the code.

This kit supports building with MS Visual C/C++ compiler tools. See the README.TXT
file (copied for preservation as a primary documentation file, as
README.ALAN.TXT). Those tools are not presently used by me. I cannot therefore
vouch for anything. As time permits I will look into porting the build to F/LOSS
compilation tools.

### Acquiring prebuilt binaries

The ls (msls) fileutil is distributed by Algin Technology at http://utools.com/msls.asp.
If all you are looking for is a ready to use tool, packaged and signed according
to Microsoft Windows development standards, I recommend downloading that package.
This is subject to change if improvements I make seem generally useful and are not
incorporated into "upstream" for whatever reasons.

### License

See the file COPYING. As per that document, this is a GNU program, licensed under
the GPL version 2.

### Remarks

I'd like to compliment Algin Technology and Alan on the shipshape condition of his
source code kit. The only flaw I'd point out is that the zip file extracts by
default into "." (there is no directory parent / leader). For those used to
customs in the Linux / Open-Source realm, where a .tar archive is the standard
container for source kits, this is disconcerting.
