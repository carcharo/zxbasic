' ----------------------------------------------------------------
' Amstrad CPC: screen.bas (SCREEN$) is not available.
'
' The Spectrum version reads the character back from Spectrum screen
' memory. The CPC firmware can read a character back (TXT_RD_CHAR), but
' this is not implemented yet.
' ----------------------------------------------------------------
#error "screen.bas is not available for --arch cpc yet: SCREEN$ reads Spectrum screen memory."
