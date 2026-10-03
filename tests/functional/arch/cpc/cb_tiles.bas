' cpcbuild tiles: SetTileSet, DoTile8, DoTile16, TileMap, TileMapPart, TileRestore.
#include <cpcbuild/tiles.bas>
DIM ts(15) AS UBYTE
DIM map(3) AS UBYTE = {0, 1, 1, 0}
SetTileSet(@ts(0))
DoTile8(1, 2, 0)
DoTile16(2, 3, 0)
TileMap(@map(0), 0, 0, 2, 2)
TileMapPart(@map(0), 2, 4, 4, 1, 2)
TileRestore(@map(0), 2, 0, 0, 4, 8)
