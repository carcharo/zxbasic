' ----------------------------------------------------------------
' Amstrad CPC: sinclair.bas is not available.
'
' It bundles Spectrum-only libraries (attr.bas; screen.bas is available as a
' separate cpc stdlib include) and POKEs the Spectrum's UDG system variable at
' 23675, which on the CPC is inside the program itself. Include the libraries
' that exist for cpc directly instead: point.bas, screen.bas, input.bas, alloc.bas.
' ----------------------------------------------------------------
#error "sinclair.bas is not available for --arch cpc. Include point.bas, screen.bas, input.bas or alloc.bas directly."
