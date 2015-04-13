' 03_maps/MapDemo.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
''
'' simple map demo
''
''        Author: Marko Lukat
'' Last modified: 2014/06/17
''       Version: 0.8
''
'' use joystick for moving around
''
'' no button: move map speed 0
''         A:      ... speed 1
''       A+B:      ... speed 2
''         B: move navi cross
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  NX = lcd#SCREEN_W - 23
  NY = lcd#SCREEN_H - 23

  #0, PX, PY
  #1, SX, SY
  
OBJ
   lcd: "LameLCD"
   gfx: "LameGFX"    
   map: "LameMap"                     
  ctrl: "LameControl"

VAR
  long  cur_x, cur_y, cur_s, old_x, old_y, old_s        ' map position and speed
  long  nav_x, nav_y                                    ' navigation cross
  long  map_w, map_h                                    ' map limits

PUB null : visible | tiles

  lcd.Start(gfx.Start)                                  ' setup screen and renderer
  map.Load(tiles := @gfx_data, @map_data)               ' prepare map

  map_w := map.GetWidth  * word[tiles][SX] - lcd#SCREEN_W
  map_h := map.GetHeight * word[tiles][SY] - lcd#SCREEN_H

  cur_y := map_h                                        ' game start location (piXel)

  demo( 0, -1, 0,  1)
  demo( 1,  0, 1, 15)
  demo( 0,  1, 3, 15)
  demo(-1,  0, 2, 15)
  demo( 0,  0, 0, 15)                                   ' demonstrate navi cross

  repeat
    if process{_buttons}                                ' get button status/events
      visible := 73                                     ' and reset visibility if any

    gfx.ClearScreen(0)                                  ' clear screen (map may be transparent)
    map.Draw(cur_x, cur_y)                              ' draw map

    if visible                                          ' draw navi cross if visible (auto-hide)
      navi(cur_x - old_x, cur_y - old_y, cur_s)
      visible--

    repeat 1
      lcd.WaitForVerticalSync
    lcd.DrawScreen                                      ' update when ready

PRI navi(dx, dy, spd)

  gfx.Sprite(@north, nav_x +  8, nav_y,      ||(dy < 0))
  gfx.Sprite(@east,  nav_x + 16, nav_y +  8, ||(dx > 0))
  gfx.Sprite(@south, nav_x +  8, nav_y + 16, ||(dy > 0))
  gfx.Sprite(@west,  nav_x,      nav_y +  8, ||(dx < 0))
  gfx.Sprite(@speed, nav_x +  8, nav_y +  8, spd)

PRI demo(dx, dy, spd, frm)

  gfx.ClearScreen(0)                                          
  map.Draw(cur_x, cur_y)                                   

  navi(dx, dy, spd)

  repeat frm                                                  
    lcd.WaitForVerticalSync
  lcd.DrawScreen                                              

PRI process : d

  longmove(@old_x, @cur_x, 3)                           ' remember current pos

  ctrl.Update

  cur_s := %01 & ctrl.A
  cur_s |= %10 & ctrl.B

  ifnot d := lookupz(cur_s: 1, 2, 0, 4)                 ' modify navi location
    return advance(@nav_x, 1, NX, NY) or TRUE           ' relocate button pressed

  return advance(@cur_x, d, map_w, map_h) or (old_s <> cur_s)

PRI advance(addr, delta, w, h) : changed

  if ctrl.Right
    changed or= long[addr][PX] < w
    long[addr][PX] := w <# (long[addr][PX] + delta)
  elseif ctrl.Left
    changed or= long[addr][PX]
    long[addr][PX] := 0 #> (long[addr][PX] - delta)     ' update x of coordinate pair at addr

  if ctrl.Up
    changed or= long[addr][PY]
    long[addr][PY] := 0 #> (long[addr][PY] - delta)
  elseif ctrl.Down
    changed or= long[addr][PY] < h
    long[addr][PY] := h <# (long[addr][PY] + delta)     ' update y of coordinate pair at addr

DAT

north   word    14
        word    8, 7

        word    %%22221222
        word    %%22231322
        word    %%22213122
        word    %%22312132
        word    %%22132312
        word    %%23122213
        word    %%21111111

        word    %%22221222
        word    %%22231322
        word    %%22211122
        word    %%22311132
        word    %%22111112
        word    %%23111113
        word    %%21111111

south   word    14
        word    8, 7

        word    %%21111111
        word    %%23122213
        word    %%22132312
        word    %%22312132
        word    %%22213122
        word    %%22231322
        word    %%22221222

        word    %%21111111
        word    %%23111113
        word    %%22111112
        word    %%22311132
        word    %%22211122
        word    %%22231322
        word    %%22221222

east    word    14
        word    8, 7

        word    %%22222231
        word    %%22223111
        word    %%22311321
        word    %%21132221
        word    %%22311321
        word    %%22223111
        word    %%22222231

        word    %%22222231
        word    %%22223111
        word    %%22311111
        word    %%21111111
        word    %%22311111
        word    %%22223111
        word    %%22222231

west    word    14
        word    8, 7

        word    %%21322222
        word    %%21113222
        word    %%21231132
        word    %%21222311
        word    %%21231132
        word    %%21113222
        word    %%21322222

        word    %%21322222
        word    %%21113222
        word    %%21111132
        word    %%21111111
        word    %%21111132
        word    %%21113222
        word    %%21322222

speed   word    14
        word    8, 7

        word    %%22222222
        word    %%22222222
        word    %%22222222
        word    %%22221222
        word    %%22222222
        word    %%22222222
        word    %%22222222

        word    %%22222222
        word    %%22222222
        word    %%22211122
        word    %%22212122
        word    %%22211122
        word    %%22222222
        word    %%22222222

        word    %%21111111
        word    %%21222221
        word    %%21221221
        word    %%21211121
        word    %%21221221
        word    %%21222221
        word    %%21111111

        word    %%22222222
        word    %%22111112
        word    %%22122212
        word    %%22122212
        word    %%22122212
        word    %%22111112
        word    %%22222222

DAT

map_data
word     96, 48  'width, height

byte      0,  0,  0,  0,134,134,134,134,134,134,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte      0,  0,  0,134,134,134,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte      0,  0,134,134,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte      0,134,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    134,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,138,138,138,138,138,138,138,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,135,135,135,135, 19,135,135,135,135,135,135,135, 19,135,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,138,138,138,138,138,138,138,138,138,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,135,135,135,135,135,134,134,134, 19,134,134,134,134,134,134,134, 19,135,135,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 13, 19, 12,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 13, 19, 12, 13, 19, 12, 13, 19, 12,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,135,135,135,135,135,135,135,134,134,134,134,134,136,136,136,136,136,136,136,136,136,136,134, 19,134,135,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,134,134,134,134,134,134,136,136,136,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136, 19,134,135,135,  0,  0,  0,  0,  0,  0,  0,  0,138,138,138,  0,  0,  0, 19,  0,  0,138,138,  0,  0,  0,138,138,  0,  0,  0,138,138,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,134,134,136,136,136,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,134,135,135,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,134,  0,  0,  0,  0,136,135,135,135,134,134,134,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,134,135,135,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,134,  0,  0,  0,  0,  0,136,136,135,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,135,135,  0,  0,  0,  0,  0,  0, 19,  0,  0, 17, 17, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 19, 17, 17, 19, 17, 17, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17
byte    136,134,  0,  0,  0,  0,  0,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,136,136,136,136,136,136,136,  0,  0,  0,  0,  0,  0,136,136,134,134,136,134,136,135,135,135,  0,  0,  0,  0, 19,135,135,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137
byte    134,134,134,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,  0,  0,  0,  0,  0,  0,136,136,136,136,136,  2,  2,136,136,136,136,136,136,136,136,136,136,136,136,134,136,136,136,134,134,134,135,135,135,135,135,135, 19,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134
byte    134,134,134,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,136,136,136,136,136,136,  2,  2,  2,  2,  2,  2,  2,  2,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,134,134,134,134,134,134,134, 19,136,134,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136
byte    134,134,134,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  2,  3,  3,  3,  3,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  3,  3,  2,  2,  2,136,136,136,136,136,136,136,136,136, 19,136,136,136,136,136,136,136,  0,  0,  0,136,136,136,136,  0,  0,  0,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136
byte    134,134,134,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  2,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  2,  2,  3,  3,  3,  2,  2,  0,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,136,136,136,136,136
byte    136,136,134,134,134,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  2,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  3,  3,  3,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,136,136,134,134,134,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  3,  3,  3,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte      0,136,136,136,136,135,134,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  3,  3,  3,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte      0,  0,  0,136,136,136,136,134,  0,  0,  0,  0,  0,  0,  0,  0,  2,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,135,135,135,135,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte      0,  0,  0,  0,136,136,136,134,134,  0,  0,  0,  0,  0,  0,  0,  2,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  3,135,135,134,134,135,135,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte      0,  0,  0,  0,136,136,136,136,134,134,  0,  0,  0,  2,  0,  2,  2,  3,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,135,135,135,134,134,134,134,135,  2,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte      0,  0,  0,  0,  0,  0,136,136,136,134,135,  0,  2,  2,  2,  2,  2,  2,  3,  3,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,135,135,134,134,134,134,136,136,134,134,135,  2,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte      0,  0,  0,  0,  0,  0,  0,  0,136,136,136,134,  2,  3,  3,  3,  2,  2,  3,  3,  3,  2,  2,  2,  2,  0,  0,  0,  0,135,135,135,135,134,134,134,136,136,136,136,136,136,134,135,  2,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,135,135,135,135,135,135,135,137,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte      0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,134,135,  3,  3,  2,  2,  2,  3,  3,  3,135,135,135,135,135,135,135,135,134,134,134,136,136,136,  0,  0,  0,  0,  0,136,136,135,135,  2,  2,  2,  4,  0,  0,  0,  0,  0,  0,  0,135,135,135,135,135,134,134,134,134,134,135,137,137,  0,137,  0,  0,  0,  0,137,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte    136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,134,135,135,  2,  2,  3,  3,  3,134,134,134,134,134,134,134,134,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,136,134,135,135,135,135,  2,  0,  0,  0,  0,  0,  0,135,135,135,134,134,134,134,134,134,134,134,135,135,135,137,137,  0,  0,  0,  0,137,137,  0,  0,  0,  0,  0,137,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte    136,136,136,136,136,134,134,134,  0,  0,134,134,134,136,136,134,135,135,135,135,135,135,136,136,136,136,136,136,136,136,  0,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,136,136,134,134,134,135,  2,  0,  0,  0,  0,  0,134,134,134,134,134,134,134,134,134,134,134,134,134,135,135,135,135,137,  0,  0,  0,137,137,137,  0,  0,  0,137,135,  0,137,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte    136,136,136,136,136,136,136,136,136,134,134,134,134,134,136,136,136,136,136,136,136,136,136,134,136,136,  0,  0,  0, 19,  0,  0,  0,136,136,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,134,  2,  0,  0,  0,  0,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,135,135,135,135,135,135,135,135,135,135,135,138,138,138,138,138,138,138,138,138,138,  0,  0,  0,  0, 19,  0,  2
byte      3,  3,136,136,136,136,  0,  0,136,136,136,136,134,134,134,134,134,134,134,134,134,134,134,134,  0,  0,  0,  0,  0, 19,  0,  0,  0,136,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,136,136,  2,  0,  0,  0,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,135,135,134,134,134,134,134,134, 19,134, 19, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  2
byte      3,  3,  3,  3,  0,  0,  0,  3,  3,  3,136,136,136,134,134,134,136,136,134,134,134,134,136,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,136,136,136,136,136,136,136,136,136,136,136,136,136,  2,  0,  0,  0,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,134,134,134,134,134,134,134,134,134,136,136,136,136,136,136, 19,  3,  4, 19,  0,  0,  0,  0,  0,  0, 19,  0,  2
byte      3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  0,  0,136,136,136,136,136,136,136,136,136,136,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,136,  3,  3,  3,  3,  3,  3,  3,  4,  4,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  3,  3,  3,  3,  3,  3,134,134,134,134,134,134,134,136,136,136,136,136,136,136,136,136,  3,  4, 19,  2,  3,  0,  0,  0,  0, 19,  2,  3
byte      2,  3,  3,  3,  3,  3,  3,  3,  3,  3,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  3,  3,  3,  3,  4,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  3,  3,  3,134,134,134,134,134,134,136,136,136,  3,  3,136,136,134,136,136,  3,  4, 19,  2,  3,  3,  0,  0,138,138,138,138
byte      2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  3,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  3,  3,  3,  4,  2,  0,  0,  0,  0,  0,  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3,  3,  3,  3,  3,134,134,134,134,136,136,136,  3,  3,  3,  3,  3,136,136,134,136,  3,  4, 19,  2,  3,  3,  3,  0,  0, 19,  2,  3
byte      0,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  3,  2,  2,  0,  0,  0,  0,  0,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  2,  3,  3,  3,  3,  3,135,134,134,136,136,136,  3,  3,  3,  3,  3,  3, 20,136,134,134,  3,  4, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte      0,  0,  2,  2,  3,  3,  3,  3,  3,  3,  3,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,138,138,  0,  0,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  2,  2,  0,  0,  0,  0,  2,  2,  3,  4,  0,  0,  0,135,135,135,135,135,135,135,135,135,135,135,134,134,136,136,136,  3,  3,  3,  3,  3,  3,  0, 20,136,134,134,  3,  4, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte      0,  0,  0,  2,  3,  3,  3,  3,  3,  3,  3,  3,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 13, 19, 12,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  0,  0,  0,  0,  0,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,134,134,134,134,134,134,134,134,134,136,136,136,  3,  3,  3,  3,  3,  3,  0,  0, 20,136,136,134,138,138,138,138,138,  3,  3,  3,  4, 19,  2,  3
byte      0,  0,  0,  0,  2,  3,  3,138,138,138,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  3,138,138,  0,  0,  0,  0,  0,  0,  0,  0,134,134,134,134,136,136,136,136,136,  3,  3,  3,  3,  3,  3,  3,  0,  0, 20, 20,136,136,136,136, 19,136,  3,  3,  3,  3,  4, 19,  2,  3
byte      0,  0,  0,  0,  2,  3,  3,  4,  3,  3,  3,  3,  3, 19, 12,  0,  0,  0,138,138,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,  2,  2,  2,  3,  3,  2,  3,  3,  3,  3,  2,  0,  0,  0, 20, 24,136,136,136,136, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte      0,  0,  0,  2,  2,  2,  3,  4,  4,  4,  3,  3,  3, 19,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  4,  4,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  3,  2,  2,  3,  3,  3,  2,  2,  0,  0,  0, 20, 24,  3,136,136,  4, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte      0,  0,  2,  2,  2,  3,  3,  3,  3,  4,  4,  3,  3, 19,  3,  2,  2,  2,  0,  0,  0,  0,  0,  0,138,138,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  3,  4,  4,  4,  5,  5,  5,  5,  5,  5,  0,  0,  0,  2,  3,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3,  3,  3,  2,  2,  3,  3,  3,  2,  0,  0,  0,  0, 21, 24,  3,  3,  3,  4, 19,  2,  3,  3,  3,138,138,138,138,138
byte      0,  2,  2,  2,  3,  3,  3,  3,  3,  3,  4,  3,  3, 19,  3,  3,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0, 13, 19, 12,  0,  0,  0,  0,  0,  0,  2,  3,  3,  4,  4,  4,  4,  4,  4,  5,  5,  0,  0,  2,  2,  3,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3,  2,  2,  2,  3,  3,  2,  2,  0,  0,  0,  2, 20, 23,  3,  3,  3,  4, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte      2,  2,  2,  3,  3,  3,  3,  3,  3,  3,  4,  3,  3, 19,  3,  4,  4,  3,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,138,  0,138,  0,138,138,138,138,138,138,138,138,138,138,138,138,  0,  0,138,138,138,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  3,  3,  2,  0,  0,  0,  2,  2, 20, 24,  3,  3,  3,  4, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte    137,137,137,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3, 19,  4,  4,  4,  3,  3,  3,  2,138,138,138,137,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  2, 19,  2,  2, 19,  2,  2, 19,  2,  0,  0,  0,  0,  2, 19,  2,  2, 19,134,134,138,138,138,138,138,138,138,138,138,138,135,135,  3,  3,  3,  2,  2,  0,  0,  2,  3,  3, 20, 24,  3,  3,  3,  4, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte    137,137,137,137,137,137,137,137,137,137,137,137,  3, 19,  4,  4,  4,  4,  3,  3,  3, 19,  0,  0,137,137,137,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  2,  2, 19,  2,  2, 19,  2,137,  0,  0,  0,  2, 19,  2,  3, 19,136,136,137,136,  0,  0,  0,136,136,136,  0,136,138,138,138,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,  3,  3,  3,  3,135,135,135,135
byte    137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  2,  0, 19,  0,137,  0,  0,137,  0, 19,  2,  2, 19,  0,137,136,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,134, 17, 17, 17, 17,134,136,136,136

DAT

gfx_data
word    16 ' frameboost
word    8, 8 ' width, height
' frame 0
word    $0000
word    $0000
word    $0000
word    $0000
word    $0000
word    $0000
word    $0000
word    $0000
' frame 1
word    $3333
word    $cccc
word    $3333
word    $cccc
word    $3333
word    $cccc
word    $3333
word    $cccc
' frame 2
word    $ffff
word    $ffff
word    $ffff
word    $ffff
word    $ffff
word    $ffff
word    $ffff
word    $ffff
' frame 3
word    $dddd
word    $7777
word    $dddd
word    $7777
word    $dddd
word    $7777
word    $dddd
word    $7777
' frame 4
word    $5555
word    $5555
word    $5555
word    $5555
word    $5555
word    $5555
word    $5555
word    $5555
' frame 5
word    $3033
word    $0f30
word    $30cc
word    $f3c3
word    $3cf0
word    $f3cc
word    $3033
word    $030c
' frame 6
word    $df77
word    $5555
word    $d75d
word    $d5dd
word    $f7f5
word    $7f4f
word    $f4f3
word    $330c
' frame 7
word    $3033
word    $0f30
word    $30cc
word    $c303
word    $0030
word    $cc00
word    $000c
word    $0000
' frame 8
word    $557c
word    $ddf3
word    $77cc
word    $dff0
word    $d5cc
word    $77f0
word    $d7c0
word    $0f00
' frame 9
word    $5555
word    $7777
word    $4444
word    $cccc
word    $cccc
word    $cccc
word    $0000
word    $0f00
' frame 10
word    $d57f
word    $4c31
word    $700d
word    $4001
word    $4003
word    $c003
word    $c003
word    $c003
' frame 11
word    $55ff
word    $fff5
word    $0c05
word    $030d
word    $00c7
word    $003f
word    $0007
word    $0007
' frame 12
word    $f555
word    $5fff
word    $5030
word    $70c0
word    $f300
word    $7c00
word    $7000
word    $f000
' frame 13
word    $000f
word    $0007
word    $0005
word    $0007
word    $0004
word    $000f
word    $0004
word    $000c
' frame 14
word    $7000
word    $f000
word    $7000
word    $4000
word    $7000
word    $f000
word    $4000
word    $4000
' frame 15
word    $5555
word    $5555
word    $5555
word    $5555
word    $7575
word    $7575
word    $f1f1
word    $d1d1
' frame 16
word    $0000
word    $0000
word    $0000
word    $0000
word    $3030
word    $1010
word    $d0d0
word    $d0d0
' frame 17
word    $4001
word    $1554
word    $0054
word    $1454
word    $0054
word    $1554
word    $0054
word    $4001
' frame 18
word    $c003
word    $300c
word    $cc33
word    $c043
word    $c103
word    $cc33
word    $300c
word    $cd73
' frame 19
word    $fff3
word    $ff33
word    $fff3
word    $fff3
word    $fff3
word    $ff33
word    $fff3
word    $fff3
' frame 20
word    $fff3
word    $fcf3
word    $ffcf
word    $ff3f
word    $3cff
word    $f3ff
word    $cfff
word    $3fff
' frame 21
word    $fffc
word    $fcf3
word    $ffcf
word    $ff3f
word    $3cff
word    $f3ff
word    $cfff
word    $3fff
' frame 22
word    $fffc
word    $ff33
word    $fff3
word    $fff3
word    $fff3
word    $ff33
word    $fff3
word    $fff3
' frame 23
word    $fff3
word    $ff33
word    $fff3
word    $fff3
word    $fff3
word    $ff33
word    $fff3
word    $fff3
' frame 24
word    $ffff
word    $0fff
word    $f3ff
word    $fcff
word    $cf3f
word    $ffcf
word    $fff3
word    $ff33
' frame 25
word    $3fff
word    $cfff
word    $f3ff
word    $fcff
word    $cf3f
word    $ffcf
word    $fff3
word    $ff3c
' frame 26
word    $ffff
word    $0000
word    $ffff
word    $cfcf
word    $ffff
word    $ffff
word    $ffff
word    $ffff
' frame 27
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
' frame 28
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
' frame 29
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
' frame 30
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
' frame 31
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa
word    $aaaa

