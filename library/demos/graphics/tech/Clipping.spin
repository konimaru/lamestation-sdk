''
'' simple clipping demo
''
''        Author: Marko Lukat
'' Last modified: 2014/06/17
''       Version: 0.6
''
'' use joystick for moving around
''
'' no button: move noise sprite
''         A: move top left clip corner
''         B: move bottom right clip corner
''       A+B: reset clip area to max
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  #0, PX, PY

OBJ
   lcd: "LameLCD"
   gfx: "LameGFX"
  ctrl: "LameControl"

   bmp: "gfx_rpgtown"

VAR
  long  pos_x, pos_y, cx1, cy1, cx2, cy2                ' sprite position and clip area
  word  size, sx, sy, data[4096]                        ' noise sprite

PUB null : n

  lcd.Start(gfx.Start)                                  ' setup screen and renderer

  size := 8192
    sx := 256
    sy := 128

  frqa := cnt
  repeat 4096
    data[n++] := ?frqa                                  ' prepare noise sprite

  pos_x := -(cx2 := lcd#SCREEN_W)/2
  pos_y := -(cy2 := lcd#SCREEN_H)/2                     ' initial clip area and position

  repeat
    process{_buttons}                                   ' get button status/events

    gfx.Blit(bmp.Addr)                                  ' draw background (instead of CLS)
    gfx.SetClipRectangle(cx1, cy1, cx2, cy2)            ' limit area for next draw
    gfx.Sprite(@data[-3], pos_x, pos_y, 0)              ' draw noise sprite on top

    repeat 1
      lcd.WaitForVerticalSync
    lcd.Draw                                      ' update when ready

PRI process : button

  ctrl.Update                                           ' current button state

  button := %01 & ctrl.A
  button |= %10 & ctrl.B                                ' extract A/B

  ifnot button                                          ' no buttons, just move noise sprite
    return advance(@pos_x, 1, -lcd#SCREEN_W, -lcd#SCREEN_H, 0, 0)

  if button == %01 {A}                                  ' A: move top left clip corner
    return advance(@cx1, 1, 0, 0, cx2, cy2)

  if button == %10 {B}                                  ' B: move bottom right clip corner
    return advance(@cx2, 1, cx1, cy1, lcd#SCREEN_W, lcd#SCREEN_H)

  cx1 := cy1 := 0
  cx2 := lcd#SCREEN_W
  cy2 := lcd#SCREEN_H                                   ' A+B: reset clip area to max

PRI advance(addr, delta, x, y, w, h) : changed

  if ctrl.Right
    changed or= long[addr][PX] < w
    long[addr][PX] := w <# (long[addr][PX] + delta)
  elseif ctrl.Left
    changed or= long[addr][PX] > x
    long[addr][PX] := x #> (long[addr][PX] - delta)     ' update x of coordinate pair at addr

  if ctrl.Up
    changed or= long[addr][PY] > y
    long[addr][PY] := y #> (long[addr][PY] - delta)
  elseif ctrl.Down
    changed or= long[addr][PY] < h
    long[addr][PY] := h <# (long[addr][PY] + delta)     ' update y of coordinate pair at addr
