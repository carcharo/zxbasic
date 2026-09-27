' Golden test for --arch cpc: floating point linkage.
' Float arithmetic goes through the 25 `rst 30h` copies (see
' src/lib/arch/cpc/runtime/arith/addf.asm and friends) and fp_calc.asm's
' real calculator engine (ported from zx81sd, Phase 3 -- see that file's
' header). This is a compile-only snapshot (see tests/functional/test.py);
' it exists to catch accidental drift in the generated asm. Runtime
' output is checked separately in the emulator (cpc-port-notes.md Phase 3
' results) and in tests/functional/arch/cpc/float_heavy.bas.
DIM x AS FLOAT
DIM y AS FLOAT
x = 1.5
y = x + 2.5
y = y * 2.0
y = SIN(y)
y = SQR(y)
END
