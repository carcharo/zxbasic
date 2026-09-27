' Phase 1 golden test for --arch cpc: floating point linkage.
' Float arithmetic goes through the 25 `rst 30h` copies (see
' src/lib/arch/cpc/runtime/arith/addf.asm and friends) and the Phase 1
' fp_calc.asm placeholder, which traps via .core.__CPC_NOT_IMPLEMENTED
' -- see that file's header. This snapshots the current stubbed linkage
' (RST 6 vector install, the rst 30h copies, stackf.asm's stub) rather
' than working output; it exists to catch accidental drift until Phase 3
' ports a real calculator.
DIM x AS FLOAT
DIM y AS FLOAT
x = 1.5
y = x + 2.5
y = y * 2.0
y = SIN(y)
y = SQR(y)
END
