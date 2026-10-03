' cpc.bas firmware sound: SoundQueue, SoundFree, SoundBusy, SoundEnvelope, SoundStop.
#include <cpc.bas>
DIM decay(2) AS UBYTE = {15, 255, 2}
DIM r AS UBYTE
SoundEnvelope 1, @decay(0), 1
r = SoundQueue(1, 239, 50, 12, 1)
r = SoundFree(1) + SoundBusy(1)
SoundStop
