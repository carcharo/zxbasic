' Phase 2 milestone golden test for --arch cpc: PRINT "Hello CPC".
' print.asm is real now (firmware TXT_OUTPUT via the gate, see that
' file's header for the control-code translation table); this snapshots
' the compiled linkage (COPY_ATTR / __PRINTSTR / PRINT_EOL) to catch
' accidental drift.
PRINT "HELLO CPC"
END
