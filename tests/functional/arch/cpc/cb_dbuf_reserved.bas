' Reserved-range case: EnableDoubleBuffer/DisableDoubleBuffer in a program small enough to fit.
#include <cpcbuild/display.bas>
EnableDoubleBuffer()
PokeScreen(1, 1, 15)
FlipBuffer()
DisableDoubleBuffer()
