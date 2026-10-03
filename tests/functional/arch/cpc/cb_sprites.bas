' cpcbuild sprites: PutSprite, PutSpriteMasked, GetBlock.
#include <cpcbuild/sprites.bas>
DIM spr(3) AS UBYTE = {1, 2, 3, 4}
DIM buf(3) AS UBYTE
PutSprite(10, 20, 2, 2, @spr(0))
PutSpriteMasked(12, 20, 1, 2, @spr(0))
GetBlock(10, 20, 2, 2, @buf(0))
