' cpc.bas basics: Mode, SetInk, SetBorder, WaitVsync, AyWrite, AyRead.
#include <cpc.bas>
DIM v AS UBYTE
Mode 1
SetInk 1, 24
SetBorder 3
WaitVsync
AyWrite 7, 62
v = AyRead(7)
