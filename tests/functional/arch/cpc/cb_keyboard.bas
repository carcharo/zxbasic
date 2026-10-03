' cpcbuild keyboard: ScanKeys, KeyDown, AnyKeyDown.
#include <cpcbuild/keyboard.bas>
DIM k AS UBYTE
ScanKeys()
k = KeyDown(KEY_SPACE) + AnyKeyDown()
