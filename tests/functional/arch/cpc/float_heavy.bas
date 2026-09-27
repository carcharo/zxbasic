' Golden test for --arch cpc: a float-heavy program exercising fp_calc.asm
' (Phase 3), fp_tostr.asm/str.asm/printf.asm, val.asm and arith/divf.asm
' together: arithmetic, comparisons, transcendental functions, STR$/VAL,
' RND, float arrays and a FUNCTION taking/returning a FLOAT. Compile-only
' snapshot (see tests/functional/test.py); runtime output is checked in
' the emulator separately (cpc-port-notes.md Phase 3 results).
DIM a AS FLOAT
DIM b AS FLOAT
DIM nums(3) AS FLOAT
DIM i AS UBYTE

FUNCTION doubleIt(v AS FLOAT) AS FLOAT
    RETURN v * 2.0
END FUNCTION

a = 1.0 / 3.0
b = (2.0 / 3.0) * 3.0
PRINT a
PRINT b

b = SQR(2.0)
b = SIN(3.14159 / 6.0)
b = COS(0.0)
b = ATN(1.0) * 4.0
b = EXP(1.0)
b = LN(10.0)

b = INT(-2.5)
b = ABS(-3.25)
b = SGN(-4.0)

IF 0.1 + 0.2 < 0.31 THEN
    PRINT "less"
END IF

PRINT STR$(3.5)
PRINT VAL("12.25") + 1

FOR i = 0 TO 3
    nums(i) = i * 1.5
NEXT i
PRINT nums(2)

b = doubleIt(a)

RANDOMIZE 1
FOR i = 0 TO 4
    PRINT RND
NEXT i

END
