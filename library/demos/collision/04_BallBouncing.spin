CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000
OBJ
    lcd  :               "LameLCD"
    gfx  :               "LameGFX"
    map  :               "LameMap"
    ctrl :               "LameControl"

    ball :               "gfx_ball_16x16"
    map1 :               "map_map"
    tile :               "gfx_box_s"

VAR
    long    oldx, oldy
    long    x, y
    long    speedx, speedy
    long    adjust

CON
    w = 16
    h = 16
    maxspeed = 20

PUB Main
    lcd.Start(gfx.Start)
    map.Load(tile.Addr, map1.Addr)

    x := 12
    y := 12

    repeat
        gfx.Clear
        ctrl.Update

        oldx := x
        oldy := y

        ' use the joystick to control speed of the ball
        ' instead of position directly
        if ctrl.Left
            if speedx > -maxspeed
                speedx--
        if ctrl.Right
            if speedx < maxspeed
                speedx++

        x += speedx

        ' apply movement adjustments to ensure object stays within bounds
        adjust := map.TestMoveX(oldx, oldy, word[ball.Addr][1], word[ball.Addr][2], x)
        if adjust
            x += adjust
            speedx := -speedx

        ' then up and down
        if ctrl.Up
            if speedy > -maxspeed
                speedy--
        if ctrl.Down
            if speedy < maxspeed
                speedy++

        y += speedy

        ' apply movement adjustments to ensure object stays within bounds
        adjust := map.TestMoveY(oldx, oldy, word[ball.Addr][1], word[ball.Addr][2], y)
        if adjust
            y += adjust
            speedy := -speedy

        map.Draw(0,0)
        gfx.Sprite(ball.Addr,x, y,0)

        lcd.Draw
