function asmParam(x as ubyte) as ubyte
    asm
    ld a, (ix+5)
    end asm
end function

function basParam(x as ubyte) as ubyte
    return 1
end function

print asmParam(1); basParam(2)
