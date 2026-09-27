' Phase 2 golden test for --arch cpc: a showcase of the text layer
' (print.asm, cls.asm, sposn.asm, copy_attr.asm, ink.asm, paper.asm,
' inverse.asm). Compile-only snapshot (see tests/functional/test.py);
' verified against the real firmware in the emulator separately.
CLS
PRINT AT 0,0; "TopLeft";
PRINT AT 24,39; "Z";
PRINT AT 12,20; "Mid"
PRINT INK 2; "red?"; PAPER 1; "pinkish"
PRINT "normal again"
INK 3
PRINT "permanent ink3"
INVERSE 1
PRINT "inverse"
INVERSE 0
PRINT "back"
PRINT 12
PRINT -12
PRINT 1234
PRINT -1234
PRINT 123456
PRINT -123456
PRINT 3.14
PRINT 1,2,3
PRINT 1;TAB(10);2;TAB(25);3
PRINT "a";"b"
PRINT "c"
PRINT "codes: "; CHR$(22)+CHR$(5)+CHR$(5)+CHR$(16)+CHR$(3)+CHR$(17)+CHR$(1)+"X"
PRINT "This is a very long line that should wrap across the forty column width of the screen and keep going well past one row"
FOR i = 1 TO 20
PRINT "line ";i
NEXT i
END
