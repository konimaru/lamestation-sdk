' 04_text/PutString.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
        lcd  : "LameLCD"
        gfx  : "LameGFX"
        
        font : "gfx_font6x8"
        
PUB Main

    lcd.Start(gfx.Start)

    gfx.LoadFont(font.Addr, " ", 0, 0)
    gfx.PutString(string("THIS IS A TEST"),4,28)

    lcd.DrawScreen

