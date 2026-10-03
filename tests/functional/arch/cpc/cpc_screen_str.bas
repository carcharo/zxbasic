' SCREEN$ read-back of a text cell.
#include <screen.bas>
DIM s AS STRING
PRINT AT 0, 0; "A"
s = SCREEN$(0, 0)
PRINT s
