{{
KS0108 Sprite And Tile Graphics Library Demo
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2013 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}

'' Why is this necessary?
'' http://en.wikipedia.org/wiki/Flat_memory_model



CON
    _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
    _xinfreq        = 5_000_000                ' External oscillator = 5 MHz


    ' screensize constants
    SCREEN_W = 128
    SCREEN_H = 64
    BITSPERPIXEL = 2
    FRAMES = 1

    SCREEN_H_BYTES = SCREEN_H / 8
    SCREENSIZE_BYTES = SCREEN_W * SCREEN_H_BYTES * BITSPERPIXEL
    TOTALBUFFER_BYTES = SCREENSIZE_BYTES * FRAMES

    FRAMEFLIP = SCREENSIZE_BYTES
    
    SCREENLOCK = 0


OBJ
        lcd     :               "LameLCD" 
        gfx     :               "LameGFX" 
        pst     :               "LameSerial"

VAR

    long    x  
    long    prebuffer[TOTALBUFFER_BYTES/4]
    word    translatematrix_src[8]
    byte    translatematrix_dest[16]
    word    destpointer
    word    srcpointer    
    word    sourcegfx

    word    index
    word    index_x
    word    index_y    
    word    index1
    word    index2

    word    rotate
    
    word    screenpointer
    word    screen



PUB Graphics_Demo

    dira~
    screenpointer := lcd.Start
    gfx.Start(screenpointer)
    
    repeat
    
    
      '  TranslateBuffer(word[screenpointer], @gfx_test_rpgtown)
   
        lcd.SwitchFrame

     '   TranslateBuffer(word[screenpointer], @gfx_test_checker)
        
        'gfx.Blit(@gfx_test_checker)
        gfx.TranslateBuffer(@gfx_test_checker, word[screenpointer])
        
        'repeat x from 0 to 100000
        

   
        lcd.SwitchFrame
   
        gfx.TranslateBuffer(@gfx_test_rpgtown, word[screenpointer])
'        TranslateBuffer(word[screenpointer], @gfx_test_rpgtown)
        
        
        
        
        
       ' repeat x from 0 to 100000

'        gfx.Blit(@gfx_test_rpgtown)
        
'        repeat x from 0 to 10000

   
'        pst.Dec(cnt)
 '       pst.Char(pst#NL)
  '      pst.Char(pst#LF)


PUB TranslateBuffer(destbuffer, sourcebuffer)

    srcpointer := 0
    destpointer := 0

    repeat index_y from 0 to 7 step 1
      repeat index_x from 0 to 15
    
        srcpointer  := ((index_y << 7) + index_x)       ' y is the long axis in linear mode; 256 bits/2 (word aligned here)
'        destpointer := (index_x << 4) + (index_y << 8)      ' x is long axis in LCD layout
        destpointer := ((index_y << 4) + index_x) << 4




        ' COPY FROM SRC        
        repeat index1 from 0 to 15
            translatematrix_dest[index1] := 0
        
        
        ' TRANSLATION
        repeat index1 from 0 to 7
          translatematrix_src[index1] := word[sourcebuffer][srcpointer + (index1 << 4)] 
        
          rotate := 1
          repeat index2 from 0 to 15
            translatematrix_dest[index2] += ( translatematrix_src[index1] & rotate ) >> index2 << index1
            rotate <<= 1
        
        
        ' COPY TO DEST
        repeat index1 from 0 to 15
          byte[destbuffer][destpointer + index1] := translatematrix_dest[index1]



DAT

gfx_test_rpgtown
word    $43c4, $d7c0, $d7c3, $d7c3, $c3d7, $c3d7, $03d7, $575c, $31f0, $43c4, $d7c0, $d7c3, $c3d7, $d7c3, $d7c3, $d7c3
word    $1551, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $5515, $0000, $1551, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c
word    $f55c, $c3d4, $c3d7, $c3d7, $d7c3, $d7c3, $17c3, $5d57, $4c7c, $f55c, $c3d4, $c3d7, $d7c3, $c3d7, $c3d7, $c3d7
word    $3554, $7c3f, $7c3d, $7c3d, $7c3d, $7c3d, $fc3d, $d555, $4000, $3554, $7c3f, $7c3d, $7c3d, $7c3d, $7c3d, $7c3d
word    $f554, $d7c0, $d7c3, $d7c3, $c3d7, $c3d7, $03d7, $45d5, $31f1, $f554, $d7c0, $d7c3, $c3d7, $d7c3, $d7c3, $d7c3
word    $3554, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $5557, $0000, $3554, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c
word    $0ff4, $c3d4, $c3d7, $c3d7, $d7c3, $d7c3, $17c3, $7551, $4c7c, $0ff4, $c3d4, $c3d7, $d7c3, $c3d7, $c3d7, $c3d7
word    $50c1, $7c3f, $7c3d, $7c3d, $7c3d, $7c3d, $fc3d, $5d55, $4000, $50c1, $7c3f, $7c3d, $7c3d, $7c3d, $7c3d, $7c3d
word    $43c4, $d7c0, $d7c3, $d7c3, $c3d7, $c3d7, $03d7, $575c, $31f0, $575c, $d7c0, $03c3, $c3c0, $d7c3, $d7c3, $03c3
word    $1551, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $5515, $0000, $5515, $3d7c, $003c, $3c00, $3d7c, $3d7c, $003c
word    $f55c, $c3d4, $c3d7, $c3d7, $d7c3, $d7c3, $17c3, $5d57, $4c7c, $5d57, $c3d4, $1143, $c144, $c3d7, $c3d7, $1143
word    $3554, $7c3f, $7c3d, $3c3d, $7c3c, $7c3d, $fc3d, $d555, $4000, $d555, $3c3f, $1154, $7c04, $7c3d, $3c3d, $1154
word    $f554, $d7c0, $d7c3, $43c3, $c3c1, $c3d7, $03d7, $45d5, $31f1, $45d5, $43c0, $1155, $d7c0, $d7c3, $43c3, $1155
word    $3554, $3d7c, $3d7c, $543c, $3c15, $3d7c, $3d7c, $5557, $0000, $5557, $543c, $1155, $3d7c, $3d7c, $543c, $1155
word    $0ff4, $c3d4, $c3d7, $0003, $c000, $d7c3, $17c3, $7551, $4c7c, $7551, $0000, $1000, $c3d4, $c3d7, $0003, $1000
word    $50c1, $7c3f, $7c3d, $fffc, $3fff, $7c3d, $fc3d, $5d55, $4000, $5d55, $fffc, $03ff, $7c3f, $7c3d, $fffc, $03ff
word    $575c, $d7c0, $03c3, $0000, $0000, $c3c0, $03d7, $575c, $31f0, $575c, $0000, $0000, $d7c0, $03c3, $0000, $0000
word    $5515, $3d7c, $003c, $5555, $5555, $3c00, $3d7c, $5515, $0000, $5515, $0000, $0000, $3d7c, $003c, $5555, $5555
word    $5d57, $c3d4, $1143, $5555, $5555, $c144, $17c3, $5d57, $4c7c, $5d57, $4444, $4444, $c3d4, $1143, $5555, $5555
word    $d555, $3c3f, $1154, $5555, $5555, $1544, $fc3c, $d555, $4000, $d555, $4444, $4444, $3c3f, $1154, $5555, $5555
word    $45d5, $43c0, $1155, $5555, $5555, $5544, $03c1, $45d5, $31f1, $45d5, $0000, $0000, $43c0, $1155, $5555, $5555
word    $5557, $543c, $1155, $5555, $5555, $5544, $3c15, $5557, $0000, $5557, $0000, $0000, $543c, $1155, $5555, $5555
word    $7551, $0000, $1000, $0000, $0000, $0004, $0000, $7551, $4c7c, $7551, $1554, $1554, $0000, $1000, $0000, $0000
word    $5d55, $fffc, $03ff, $ffff, $ffff, $ffc0, $3fff, $5d55, $4000, $5d55, $0000, $0000, $fffc, $03ff, $ffff, $ffff
word    $575c, $0000, $0000, $0000, $0000, $0000, $0000, $575c, $31f0, $575c, $575c, $43c4, $0000, $0000, $0000, $0000
word    $5515, $0000, $0000, $3ffc, $3ffc, $0000, $0000, $5515, $0000, $5515, $5515, $1551, $0000, $0000, $3ffc, $0000
word    $5d57, $4444, $4444, $355c, $355c, $4444, $4444, $5d57, $4c7c, $5d57, $5d57, $f55c, $4444, $4444, $355c, $4444
word    $d555, $4444, $4444, $355c, $355c, $4444, $4444, $d555, $4000, $d555, $d555, $3554, $4444, $4444, $355c, $4444
word    $45d5, $0000, $0000, $03fc, $3fc0, $0000, $0000, $45d5, $31f1, $45d5, $45d5, $f554, $0000, $0000, $03fc, $0000
word    $5557, $0000, $0000, $355c, $355c, $0000, $0000, $5557, $0000, $5557, $5557, $3554, $0000, $0000, $355c, $0000
word    $7551, $1554, $1554, $3ffc, $3ffc, $1554, $1554, $7551, $4c7c, $7551, $7551, $0ff4, $1554, $1554, $3ffc, $1554
word    $5d55, $0000, $0000, $0000, $0000, $0000, $0000, $5d55, $4000, $5d55, $5d55, $50c1, $0000, $0000, $0000, $0000
word    $5554, $575c, $575c, $575c, $31f0, $4000, $575c, $575c, $31f0, $575c, $575c, $575c, $575c, $575c, $31f0, $4000
word    $5005, $5515, $5515, $5515, $0000, $3ffc, $5515, $5515, $0000, $5515, $5515, $5515, $5515, $5515, $0000, $3ffc
word    $4711, $5d57, $5d57, $5d57, $4c7c, $30cc, $5d57, $5d57, $4c7c, $5d57, $5d57, $5d57, $5d57, $5d57, $4c7c, $30cc
word    $0df0, $d555, $d555, $d555, $4000, $3ffc, $d555, $d555, $4000, $d555, $d555, $d555, $d555, $d555, $4000, $3ffc
word    $1cdc, $45d5, $45d5, $45d5, $31f1, $4001, $45d5, $45d5, $31f1, $45d5, $45d5, $45d5, $45d5, $45d5, $31f1, $4001
word    $11c0, $5557, $5557, $5557, $0000, $5415, $5557, $5557, $0000, $5557, $5557, $5557, $5557, $5557, $0000, $5415
word    $0f10, $7551, $7551, $7551, $4c7c, $5714, $7551, $7551, $4c7c, $7551, $7551, $7551, $7551, $7551, $4c7c, $5714
word    $11c0, $5d55, $5d55, $5d55, $4000, $1575, $5d55, $5d55, $4000, $5d55, $5d55, $5d55, $5d55, $5d55, $4000, $1575
word    $3300, $575c, $575c, $575c, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0
word    $0000, $5515, $5515, $5515, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001
word    $4001, $5d57, $5d57, $5d57, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c
word    $5c15, $d555, $d555, $d555, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $54dd, $45d5, $45d5, $45d5, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1
word    $7715, $5557, $5557, $5557, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001
word    $4cf1, $7551, $7551, $7551, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c
word    $5555, $5d55, $5d55, $5d55, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $575c, $575c, $43c4, $575c, $575c, $575c, $575c, $575c, $575c, $575c, $575c, $575c, $575c, $575c, $575c, $575c
word    $5515, $5515, $1551, $5515, $5515, $5515, $5515, $5515, $5515, $5515, $5515, $5515, $5515, $5515, $5515, $5515
word    $5d57, $5d57, $f55c, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57
word    $d555, $d555, $3554, $d555, $d555, $d555, $d555, $d555, $d555, $d555, $d555, $d555, $d555, $d555, $d555, $d555
word    $45d5, $45d5, $f554, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5
word    $5557, $5557, $3554, $5557, $5557, $5557, $5557, $5557, $5557, $5557, $5557, $5557, $5557, $5557, $5557, $5557
word    $7551, $7551, $0ff4, $7551, $7551, $7551, $7551, $7551, $7551, $7551, $7551, $7551, $7551, $7551, $7551, $7551
word    $5d55, $5d55, $50c1, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $575c
word    $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $5515
word    $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $5d57
word    $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $d555
word    $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $45d5
word    $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $5557
word    $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $7551
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $5d55







gfx_test_checker
word    $0001, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $5554, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $1555
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $5554, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $1555
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000



{{
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │
│                                                                                      │                                             
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}
