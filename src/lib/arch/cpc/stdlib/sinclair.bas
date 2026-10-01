' ----------------------------------------------------------------
' Amstrad CPC: sinclair.bas is not available.
'
' It bundles Spectrum-only libraries (attr.bas, screen.bas) and POKEs
' the Spectrum's UDG system variable at 23675, which on the CPC is
' inside the program itself. Include the libraries that exist for cpc
' directly instead: point.bas, input.bas, alloc.bas.
' ----------------------------------------------------------------
#error "sinclair.bas is not available for --arch cpc. Include point.bas, input.bas or alloc.bas directly."
