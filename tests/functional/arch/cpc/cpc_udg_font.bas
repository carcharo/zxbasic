' UDG (USR "a", POKE) and custom font (SetFont).
#include <font.bas>
DIM f(767) AS UBYTE
POKE USR "a", 255
PRINT CHR$(144)
SetFont(@f(0))
