' ----------------------------------------------------------------
' Amstrad CPC: print42.bas is not available.
'
' The Spectrum version draws 42-column text straight into Spectrum
' screen memory and reads Spectrum system variables (UDG at 23675).
' The CPC's text modes are 20, 40 and 80 columns (cpc.bas: Mode).
' ----------------------------------------------------------------
#error "print42.bas is not available for --arch cpc (it writes Spectrum screen memory). Use Mode 2 for 80 columns."
