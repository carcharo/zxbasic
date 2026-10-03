' cpc framehook: FrameHook, FrameHookOff, Frames, GameMode.
#include <framehook.bas>
DIM n AS ULONG
GOTO skip
myhook:
ASM
  ld hl, (_cnt)
  inc hl
  ld (_cnt), hl
  ret
END ASM
skip:
DIM cnt AS UINTEGER
FrameHook(@myhook)
GameMode(1)
n = Frames()
GameMode(0)
FrameHookOff()
