' ----------------------------------------------------------------
' Amstrad CPC: attr.bas (ATTR, SETATTR, ATTRADDR) is not available.
'
' The Spectrum keeps one colour attribute byte per 8x8 character cell;
' the CPC has no attribute memory (every pixel has its own pen), so
' there is nothing to read or write (cpcbuild/docs/notes.md, question 6).
' Text colours still work through INK/PAPER; to read a pixel's colour
' use POINT (point.bas).
' ----------------------------------------------------------------
#error "attr.bas is not available for --arch cpc: the CPC has no colour attributes. Use INK/PAPER, and POINT() from point.bas to read a pixel's pen."
