' cpcbuild fill: PenByte, FillRect, ClearScreen.
#include <cpcbuild/fill.bas>
DIM b AS UBYTE
b = PenByte(1)
FillRect(5, 5, 10, 10, 2)
ClearScreen(0)
