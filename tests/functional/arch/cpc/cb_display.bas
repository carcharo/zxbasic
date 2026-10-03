' cpcbuild display: ScreenInit, WaitRetrace, FlipBuffer, PokeScreen, PeekScreen (no double buffer).
#include <cpcbuild/display.bas>
DIM b AS UBYTE
ScreenInit()
WaitRetrace(2)
PokeScreen(10, 20, 255)
b = PeekScreen(10, 20)
FlipBuffer()
