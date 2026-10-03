' cpcbuild palette: SetPalette, PalUpload.
#include <cpcbuild/palette.bas>
DIM pal(3) AS UBYTE = {0, 26, 6, 18}
SetPalette(@pal(0), 4)
PalUpload(@pal(0), 2, 4)
