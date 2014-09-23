' *********************************************************
' jarzzard.spin
' Graphics generated by img2dat
' *********************************************************
CON
    health  =   76
    attack  =   40
    defense =   32
    speed   =   50

PUB Addr
    return @data

PUB Name
    return @nme
DAT
nme     byte    "JARZZAR",0

DAT

data    word

word    400 ' frameboost
word    40, 40 ' width, height
' frame 0
word    $aaaa,$aaaa,$aaaa,$aaaa,$aaaa '                                         
word    $aaaa,$aaaa,$aaaa,$aaaa,$aaaa '                                         
word    $afaa,$aaea,$aaaa,$aaab,$abfe '     ▓▓     ▓            ▓        ▓▓▓▓   
word    $a8ea,$aaea,$aaaa,$aaab,$ad4a '    ▓█      ▓            ▓         █░░▓  
word    $a87a,$ab7a,$eaaa,$aaab,$adca '   ▓░█     ▓░▓          ▓▓         █▓░▓  
word    $a94a,$a97a,$7aaa,$aaab,$bcca '   █░░     ▓░░         ▓░▓         █▓█▓▓ 
word    $a10a,$ad7a,$7eaa,$aaab,$00ca '   ██░█    ▓░░▓       ▓▓░▓         █▓████
word    $a332,$fdca,$5faa,$aaab,$30ca '  █▓█▓█    █▓░▓▓▓    ▓▓░░▓         █▓██▓█
word    $8332,$f52a,$5700,$aaab,$30c2 '  █▓█▓██    █░░▓▓████▓░░░▓        ██▓██▓█
word    $8c32,$3c2a,$d43f,$aaab,$30f2 '  █▓██▓█    ██▓▓█▓▓▓██░░▓▓        █▓▓██▓█
word    $0c32,$c0aa,$f0ff,$aaaa,$f032 '  █▓██▓██    ███▓▓▓▓▓██▓▓         █▓███▓▓
word    $f032,$caaa,$f0ff,$aaaa,$c00c '  █▓███▓▓      █▓▓▓▓▓██▓▓        █▓█████▓
word    $c032,$02ab,$830f,$2aaa,$c30c '  █▓████▓▓    ███▓▓██▓██        ██▓██▓██▓
word    $0032,$d28f,$8313,$0aaa,$c0cf '  █▓█████▓▓█  █░▓▓█░█▓██       ██▓▓█▓███▓
word    $00c2,$f23f,$0cff,$c2aa,$c0c3 '  ██▓████▓▓▓█ █▓▓▓▓▓▓█▓██     ██▓▓██▓███▓
word    $00c2,$fef0,$0cff,$f0aa,$c0c0 '  ██▓██████▓▓ ▓▓▓▓▓▓▓█▓██    ██▓▓███▓███▓
word    $30c2,$f0c0,$303c,$3c02,$c0c0 '  ██▓██▓████▓██▓▓█▓▓███▓█ ████▓▓████▓███▓
word    $30c2,$fc00,$0d0f,$0ff0,$c0c0 '  ██▓██▓██████▓▓▓▓▓██░▓████▓▓▓▓█████▓███▓
word    $30ca,$f000,$3343,$003c,$c0c0 '   █▓██▓███████▓▓▓██░▓█▓██▓▓████████▓███▓
word    $c0ca,$0000,$3d50,$3000,$f0c0 '   █▓███▓██████████░░░▓▓███████▓████▓██▓▓
word    $c0ca,$3fc0,$f373,$303f,$30c0 '   █▓███▓███▓▓▓▓█▓█▓░▓█▓▓▓▓▓███▓████▓██▓█
word    $c0ca,$f5f0,$7f57,$30f5,$30c0 '   █▓███▓██▓▓░░▓▓▓░░░▓▓▓░░░▓▓██▓████▓██▓█
word    $c0ca,$fff0,$fcdc,$30ff,$30f0 '   █▓███▓██▓▓▓▓▓▓█▓░▓█▓▓▓▓▓▓▓██▓███▓▓██▓█
word    $c30a,$ffc0,$ff55,$303f,$30f0 '   ██▓██▓███▓▓▓▓▓░░░░▓▓▓▓▓▓▓███▓███▓▓██▓█
word    $030a,$cc03,$f355,$3003,$3030 '   ██▓███▓████▓█▓░░░░▓█▓▓▓█████▓███▓███▓█
word    $032a,$7000,$3d55,$3000,$b030 '    █▓█████████▓░░░░░░▓▓███████▓███▓███▓ 
word    $0c2a,$c000,$3355,$300c,$bc30 '    ██▓█████████▓░░░░▓█▓██▓████▓███▓██▓▓ 
word    $0c2a,$7300,$3d55,$303c,$8c30 '    ██▓██████▓█▓░░░░░░▓▓██▓▓███▓███▓██▓█ 
word    $002a,$73f0,$3d55,$00ff,$803c '    ███████▓▓▓█▓░░░░░░▓▓█▓▓▓▓█████▓▓████ 
word    $02aa,$ccfc,$f3d7,$03fc,$a00c '      ████▓▓▓█▓█▓▓░░▓▓█▓▓█▓▓▓▓████▓████  
word    $42aa,$7f30,$fd55,$00f3,$a880 '      ██░██▓█▓▓▓░░░░░░▓▓▓▓█▓▓███████ █   
word    $52aa,$3f34,$fcd7,$144f,$a882 '      █░░█░▓█▓▓▓█▓░░▓█▓▓▓▓▓█░█░░█ ██ █   
word    $1aaa,$ffc5,$f354,$117f,$aaa2 '       ░█░░█▓▓▓▓▓█░░░▓█▓▓▓▓▓░░█░█ █      
word    $2aaa,$0fcd,$c0fc,$813f,$aaa2 '        █░▓█▓▓▓███▓▓▓███▓▓▓▓█░██  █      
word    $2aaa,$03f0,$0000,$80ff,$aaa8 '        ███▓▓▓███████████▓▓▓▓███ █       
word    $2aaa,$80ff,$0aaa,$80fc,$aaaa '        █▓▓▓▓███       ███▓▓▓███         
word    $aaaa,$a000,$2aaa,$a000,$aaaa '         ██████         ███████          
word    $eaaa,$a0ff,$2aaa,$a3ff,$aaaa '        ▓▓▓▓▓██         █▓▓▓▓▓█          
word    $4aaa,$a3c4,$caaa,$a447,$aaaa '       █░█░█▓▓█        █▓▓░█░█░          
word    $4aaa,$a044,$0aaa,$9444,$aaaa '       █░█░█░██        ███░█░█░░         
