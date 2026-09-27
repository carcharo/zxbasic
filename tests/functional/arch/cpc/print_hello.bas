' Phase 1 golden test for --arch cpc: PRINT statement linkage.
' PRINT itself is a Phase 1 stub (src/lib/arch/cpc/runtime/print.asm
' traps via .core.__CPC_NOT_IMPLEMENTED -- see that file's header), so
' this snapshots the current stubbed linkage rather than working output;
' it exists to catch accidental drift until Phase 2/4a port print.asm
' for real.
PRINT "HELLO CPC"
END
