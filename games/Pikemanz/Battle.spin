{{
Pikemanz - Battle Engine
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation.
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000 
    
    
CON
    BACK_OX    = 78
    BACK_OY    = 0
    FRONT_OX     = 20
    FRONT_OY     = 20

OBJ
    lcd     :   "LameLCD"
    gfx     :   "LameGFX"
    audio   :   "LameAudio"
    music   :   "LameMusic"
    ctrl    :   "LameControl"
    fn      :   "LameFunctions"
    
    state   :   "PikeState"
   
    pk1     :   "gfx_pk_pakechu2"
    pk2     :   "gfx_pk_mootoo"

   ' song    :   "song_battle"
    
    menu    :   "PikeMenu"
    pike    :   "PikeManager"

VAR
    byte    front_pk
    byte    back_pk
    
    byte    hp_dsp[2]
        
    byte    click
    byte    clickjoy
    
PUB Main
    lcd.Start(gfx.Start)
    audio.Start
    music.Start    
    ctrl.Start
    
    gfx.ClearScreen(gfx#WHITE)
    
    Scene
        
PUB FaceOffScene | i

    repeat i from 120 to 0 step 2
        gfx.ClearScreen(gfx#WHITE)
        pike.Draw(back_pk, BACK_OX - i, BACK_OY)
        pike.Draw(front_pk, FRONT_OX + i, FRONT_OY)
        menu.MessageBox(string("DURP wants",10,"to FIGHT"), 1,40,128,24,6,6)
        lcd.DrawScreen
    fn.Sleep(1000)

PUB Init
   ' music.LoadSong(song.Addr)
    'music.LoopSong    
   
    gfx.LoadFont(font_text.Addr, " ", 0, 0)
    
    front_pk := pike.SetPikeman(0, string("PAKECHU"), 20, 10, 32, 50, pk1.Addr)
    CreateNumberStr(@str_hpmax, pike.GetMaxHealth(front_pk))
    
    back_pk := pike.SetPikeman(1, string("MOOTOO"), 130, 40, 32, 50, pk2.Addr)
    
    hp_dsp[back_pk] := pike.GetHealth(back_pk)
    hp_dsp[front_pk] := pike.GetHealth(front_pk)    
            
PUB Scene
    Init
    SquareWipe
    FaceOffScene
    
    repeat
    
        ctrl.Update
        gfx.ClearScreen(gfx#WHITE)
        
        if ctrl.A
            if not click
                click := 1
                pike.Hurt(back_pk, 20)
        else
            click := 0
           
        HealthHandler
        
        pike.Draw(back_pk, BACK_OX, BACK_OY)
        pike.Draw(front_pk, FRONT_OX, FRONT_OY)
  
        StatusBox(pike.GetName(back_pk),hp_dsp[back_pk], pike.GetMaxHealth(back_pk), 1, 1, 1)    
        StatusBox(pike.GetName(front_pk),hp_dsp[front_pk], pike.GetMaxHealth(front_pk), 76, 40,0)

        HandleInterface
        
        if ctrl.B
            return state#_OVERWORLD
    
        lcd.DrawScreen
DAT
    dialog      byte    _SELECT
    
CON
    #0, _HEALTH, _SELECT, _ATTACK
        
PUB HandleInterface
    
   ' AttackDialog(1, 40, pike.GetName(back_pk), string("SLASH"), true)    
'    AttackDialog(1, 40, pike.GetName(front_pk), string("HYPER DESTROY"), false)    
'    

    case dialog
        _SELECT:    BattleDialog(1,40)
        _ATTACK:    
        other:      ControlHealth
    
PUB ControlHealth
    if ctrl.Down
        pike.Hurt(front_pk, 2)
    if ctrl.Up
        pike.Heal(front_pk, 2)
    
OBJ
    arrow   :   "gfx_arrow"
    
CON
    COLWIDTH = 30
    ROWHEIGHT = 6
    ROWS = 2
    
VAR
    byte    select

PUB BattleDialog(x, y)
    menu.Box(x,y,74,24,6,6)
        
    y += 6
    x += 7
    
    ListSelector
    
    gfx.Sprite(arrow.Addr, x + COLWIDTH*(select/ROWS), y + ROWHEIGHT*(select//ROWS)+1, 0)

    ' menu options
    gfx.PutString(string("FYTE"),x+4, y)
    gfx.PutString(string("ITAM"),x+constant(COLWIDTH+4), y)
        
    y += 6
    gfx.PutString(string("PIKE"),x+4, y)
    gfx.PutString(string("RAN"),x+constant(COLWIDTH+4), y)
    
PUB ListSelector
    
    if ctrl.Down
        if not clickjoy
            clickjoy := 1
            if select < 3
                select++
    elseif ctrl.Up
        if not clickjoy
            clickjoy := 1
            if select > 0
                select--
    else
        clickjoy := 0

PUB AttackDialog(x, y, name, attack, enemy)
    menu.Box(x,y,128,24,6,6)
    
    y += 6
    x += 7
    
    if enemy
        gfx.PutString(string("Enemy"),x+1, y)
        gfx.PutString(name,x+36, y)
    else
        gfx.PutString(name,x, y)
    
    y += 7
    gfx.PutString(string("used"),x, y)
    gfx.PutString(attack,x+30, y)
    
PUB HealthHandler | i
    repeat i from 0 to pike#PIKEZ-1
        if hp_dsp[i] > pike.GetHealth(i)
            hp_dsp[i]--
        if hp_dsp[i] < pike.GetHealth(i)
            hp_dsp[i]++

OBJ
    dia         :   "gfx_dialog"
    bar         :   "gfx_bar"
    
    hp          :   "gfx_healthbar"
    hp_box      :   "gfx_health"
    hp_text     :   "gfx_hp"

    font_text   :   "gfx_font6x6_b"   
            
PUB StatusBox(name, health, maxhealth, x, y, opposing) | w
    
    w := health*word[hp.Addr][1]/maxhealth
    
    ' pikemanz name
    gfx.PutString(name,x, y+1)
    y += 7
    
    ' health bar
    gfx.Sprite(hp_text.Addr, x, y+1, 0)

    gfx.Sprite(hp_box.Addr, x+9, y, 0)
    
    gfx.SetClipRectangle(x+10, y+1, x+10+w, y+3)
    gfx.Sprite(hp.Addr, x+10, y+1, 0)
    gfx.SetClipRectangle(0, 0, gfx#SCREEN_W, gfx#SCREEN_H)
    y += 6
    
    ' actual health count
    if not opposing    
        CreateNumberStr(@str_hp, hp_dsp[front_pk])
        gfx.PutString(@str_hp,x+11,y)
        gfx.PutChar("/",x+29,y)
        gfx.PutString(@str_hpmax,x+34,y)
            
        y += 7
        x += 11
    
    gfx.Sprite(bar.Addr, x, y, 0)        '
    gfx.Sprite(bar.Addr, x+16, y, 0)
    
    
VAR
    byte    str_hp[4]
    byte    str_hpmax[4]

PUB CreateNumberStr(str, value) | i, active, ind
    i := 100
    active := 0

    repeat ind from 0 to 2
        if value => i
            active := 1
            byte[str][ind] := value / i + "0"
            value //= i
        else
            if active or (i == 1 and value == 0)
                byte[str][ind] := "0"
            else
                byte[str][ind] := " "

        i /= 10

    byte[str][3] := 0
    
OBJ
    black   :   "gfx_black"
    
    
CON
    #0, DOWN, RIGHT, UP, LEFT

    

    
PUB SquareWipe | x1, y1, x2, y2, x, y, dir
    
    lcd.SetFrameLimit(0)
    
    dir := DOWN
    x := y := y1 := 0
    x1 := 1
    x2 := 15
    y2 := 7
    
    repeat 128
        gfx.Sprite(black.Addr, x << 3, y << 3, 0)
        case dir
            DOWN:   if y < y2
                        y++
                    else
                        y2--
                        dir := RIGHT
            RIGHT:  if x < x2
                        x++
                    else
                        dir := UP
                        x2--

            UP:     if y > y1
                        y--
                    else
                        dir := LEFT
                        y1++
            LEFT:   if x > x1
                        x--
                    else
                        dir := DOWN
                        x1++
        lcd.DrawScreen

    lcd.SetFrameLimit(lcd#FULLSPEED)

DAT
{{

 TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}
DAT
