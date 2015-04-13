' 02_graphics/format/03_Ring.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB SinglePixel
    lcd.Start(gfx.Start)
    gfx.Sprite(@data, 0,0, 0)
    lcd.DrawScreen
    
DAT

data
word    0
word    8, 8
word    %%00011000
word    %%01111110
word    %%01100110
word    %%11000011
word    %%11000011
word    %%01100110
word    %%01111110
word    %%00011000


