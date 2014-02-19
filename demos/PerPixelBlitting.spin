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
    TOTALBUFFER_BYTES = SCREENSIZE_BYTES

    FRAMEFLIP = SCREENSIZE_BYTES
    
    SCREENLOCK = 0


OBJ
        lcd     :               "LameLCD" 
        gfx     :               "LameGFX"
        ctrl    :               "LameControl"
        pst     :               "LameSerial"

VAR

    long    x  
    word    prebuffer[TOTALBUFFER_BYTES/2]
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
    word    anotherpointer
    
    
    byte    pos_x
    byte    pos_y
    byte    pos_dir
    byte    pos_speed
    byte    pos_speedx
    
    byte    bulletbox_x
    byte    bulletbox_y
    byte    bulletbox
    byte    bulletbox_dir
    byte    bulletbox_speed
    




PUB Graphics_Demo

    dira~
    screenpointer := lcd.Start
    anotherpointer := @prebuffer
    gfx.Start(@anotherpointer)
    ctrl.Start
    
    repeat
       { 
        repeat x from 0 to 10000
        gfx.Blit(@gfx_test_checker)        
        gfx.TranslateBuffer(@prebuffer, word[screenpointer])
        lcd.SwitchFrame
   }

            lcd.SwitchFrame
            ctrl.Update

            
            gfx.ClearScreen
            
            
            gfx.Box(@gfx_test_box2,pos_x,pos_y)
            
            if ctrl.Right
                pos_x += 1
                pos_dir := 1

            if ctrl.Left
                pos_x -= 1
                pos_dir := 3



                
            pos_y += pos_speed
                
            if pos_y < 50
                pos_speed += 1
            else
                pos_y := 50
                pos_speed := 0
 
                 if ctrl.Up
                    pos_dir := 0            
                    pos_speed := -8
            


            if ctrl.Down
                pos_dir := 2
                
                
            if ctrl.B or ctrl.A
                bulletbox := 1
                bulletbox_dir := pos_dir
                bulletbox_x := pos_x
                bulletbox_y := pos_y
                bulletbox_speed := 1
                
                
            if bulletbox

                if bulletbox_speed < 5
                    bulletbox_speed += 1
               
                if bulletbox_dir == 0
                    bulletbox_y -= bulletbox_speed                
                if bulletbox_dir == 1
                    bulletbox_x += bulletbox_speed                
                if bulletbox_dir == 2
                    bulletbox_y += bulletbox_speed                
                if bulletbox_dir == 3
                    bulletbox_x -= bulletbox_speed                                    

                if bulletbox_x =< 0 or bulletbox_x => 120 or bulletbox_y =< 0 or bulletbox_y => 56
                    bulletbox := 0
                else              
                    gfx.Box(@gfx_test_box2,bulletbox_x,bulletbox_y)
        
            repeat x from 0 to 1000            
            
            gfx.TranslateBuffer(@prebuffer, word[screenpointer])




PUB TranslateBuffer(destbuffer, sourcebuffer)

    srcpointer := 0
    destpointer := 0

    repeat index_y from 0 to 7 step 1
      repeat index_x from 0 to 15
    
        srcpointer  := ((index_y << 7) + index_x)       ' y is the long axis in linear mode; 256 bits/2 (word aligned here)
        destpointer := ((index_y << 4) + index_x) << 4      ' x is long axis in LCD layout




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


gfx_test_box2
word    $5554, $4001, $4dd1, $4dd1, $4dd1, $4dd1, $4001, $5555




gfx_tiles_2b_tuxor

word    $0000, $3333, $ffff, $dddd, $5555, $3033, $df77, $3033, $0000, $cccc, $ffff, $7777, $5555, $0f30, $5555, $0f30
word    $0000, $3333, $ffff, $dddd, $5555, $30cc, $d75d, $30cc, $0000, $cccc, $ffff, $7777, $5555, $f3c3, $d5dd, $c303
word    $0000, $3333, $ffff, $dddd, $5555, $3cf0, $f7f5, $0030, $0000, $cccc, $ffff, $7777, $5555, $f3cc, $7f4f, $cc00
word    $0000, $3333, $ffff, $dddd, $5555, $3033, $f4f3, $000c, $0000, $cccc, $ffff, $7777, $5555, $030c, $330c, $0000
word    $557c, $5555, $d57f, $55ff, $f555, $000f, $7000, $5555, $ddf3, $7777, $4c31, $fff5, $5fff, $0007, $f000, $5555
word    $77cc, $4444, $700d, $0c05, $5030, $0005, $7000, $5555, $dff0, $cccc, $4001, $030d, $70c0, $0007, $4000, $5555
word    $d5cc, $cccc, $4003, $00c7, $f300, $0004, $7000, $7575, $77f0, $cccc, $c003, $003f, $7c00, $000f, $f000, $7575
word    $d7c0, $0000, $c003, $0007, $7000, $0004, $4000, $f1f1, $0f00, $0f00, $c003, $0007, $f000, $000c, $4000, $d1d1
word    $0000, $4001, $c003, $fff3, $fff3, $fffc, $fffc, $fff3, $0000, $1554, $300c, $ff33, $fcf3, $fcf3, $ff33, $ff33
word    $0000, $0054, $cc33, $fff3, $ffcf, $ffcf, $fff3, $fff3, $0000, $1454, $c043, $fff3, $ff3f, $ff3f, $fff3, $fff3
word    $3030, $0054, $c103, $fff3, $3cff, $3cff, $fff3, $fff3, $1010, $1554, $cc33, $ff33, $f3ff, $f3ff, $ff33, $ff33
word    $d0d0, $0054, $300c, $fff3, $cfff, $cfff, $fff3, $fff3, $d0d0, $4001, $cd73, $fff3, $3fff, $3fff, $fff3, $fff3
word    $ffff, $3fff, $ffff, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $0fff, $cfff, $0000, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa
word    $f3ff, $f3ff, $ffff, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $fcff, $fcff, $cfcf, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa
word    $cf3f, $cf3f, $ffff, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $ffcf, $ffcf, $ffff, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa
word    $fff3, $fff3, $ffff, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $ff33, $ff3c, $ffff, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa

mapTable_
word	@map_supersidescroll


map_supersidescroll
byte	100,   8  'width, height
byte	  3,  3,  3,  3,  3,  3,  3,  2,  3,  3,  2,  2,  2,  2,  2,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 19,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,  3,  3,  3,  3,  2,  1,  1,  1, 20, 24,  3,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3
byte	  3,  3,  2,  2,  2,  2,  2,  2,  2,  2,  3,  3,  3,  3,  2,  2,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 19,  1,  1,  1,  1,  1,  1,  1,  4,  4,  4,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  2,  2,  3,  3,  3,  2,  2,  1,  1,  1, 20, 24,  3,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3
byte	  3,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,  2,  2,  1,  1,  1,  1,  1,  1, 10, 10, 10, 10, 10, 10, 10,  1,  1,  1,  1,  1,  2,  3,  4,  4,  4,  5,  5,  5,  5,  5,  5,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,  2,  3,  3,  3,  2,  1,  1,  1,  1, 21, 24,  3,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3
byte	  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,  2,  2,  1,  1,  1,  1,  1,  1,  1,  1, 13, 19, 12,  1,  1,  1,  1,  1,  2,  2,  3,  3,  4,  4,  4,  4,  4,  4,  5,  5,  5,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  2,  2,  3,  3,  3,  3,  2,  2,  2,  3,  3,  2,  2,  1,  1,  1,  2, 20, 23,  3,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3
byte	  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,  2,  1,  1,  1,  1,  1,  1,  1,  1, 19,  1,  1, 10,  1, 10,  1, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,  1,  5,  5,  5,  5,  4,  4,  4,  4,  4,  4,  4,  4,  7,  7,  7,  2,  2,  3,  3,  2,  2,  3,  3,  3,  3,  2,  1,  1,  1,  2,  2, 20, 24,  3,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3
byte	  9,  9,  9,  3,  3,  3,  3,  3,  3,  5,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2, 10, 10, 10,  9,  1,  1,  1,  1, 19,  1,  1,  1,  1,  1,  1, 19,  2,  2, 19,  2,  2, 19,  2, 13, 19, 12,  1,  1,  1,  1,  1,  1,  5,  5,  5,  5,  5,  5,  1,  2,  6,  6,  6,  2,  2,  2,  3,  3,  3,  3,  3,  3,  2,  2,  1,  1,  2,  3,  3, 20, 24,  3,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3
byte	  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  3,  3,  3,  3,  3,  3,  3,  3,  3, 19,  1,  1,  9,  9,  9,  1,  1, 19,  1,  1,  1,  1,  1,  1, 19,  2,  2, 19,  2,  2, 19,  1,  1, 19,  1,  1,  1,  1,  1,  1,  2,  7,  7,  7,  7,  7,  7,  7,  7,  6,  6,  6,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7
byte	  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  1,  1, 19,  1,  1,  1,  1,  2,  2, 19,  1,  1, 19,  1,  1, 19,  1,  1, 19,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8





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