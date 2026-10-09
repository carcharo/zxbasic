function asmRet() as ubyte
    asm
    ld a, 5
    end asm
end function

function basNoRet() as ubyte
    dim a as ubyte = 1
end function

print asmRet(); basNoRet()
