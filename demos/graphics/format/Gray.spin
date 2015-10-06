CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"
    
PUB Main
    lcd.Start(gfx.Start)
    gfx.Sprite(@data, 0, 0, 0)
    lcd.DrawScreen

DAT

data
word    0
word    8, 8
word    %%33333333
word    %%33333333
word    %%33333333
word    %%33333333
word    %%33333333
word    %%33333333
word    %%33333333
word    %%33333333
