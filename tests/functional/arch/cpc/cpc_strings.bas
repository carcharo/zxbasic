' Strings: concatenation, slicing (MID$ equivalent), VAL, STR$, CHR$.
DIM a AS STRING = "HELLO"
DIM b AS STRING
DIM n AS FLOAT
b = a + CHR$(33) + a(1 TO 3)
n = VAL("12")
PRINT b; STR$(n)
