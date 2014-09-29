'             _____        _____
'               '. \      / .'
'             ()  ' \    / '        ||
'       __    __   \ \  / /    __   ||
'   ___|| \\__||____\ \/ /____//_|__||___
'   ___||_//__||_____)  (_____\\_,__||___
'      ||           / /\ \
'      ||          / /  \ \
'              __-'_/    \_'-__
'
'         Amazing Action Platformer Game
' *********************************************************
'  Copyright (c) 2014 LameStation LLC
'  See end of file for terms of use.
'  
'  Authors: Brett Weir
' *********************************************************

CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000


    ' screensize constants
    SCREEN_W = 128
    SCREEN_H = 64

    ' Directional constants
    UP = 0
    RIGHT = 1
    DOWN = 2
    LEFT = 3

    HURT_TIMEOUT = 20
    ENEMY_TIMEOUT = 5
    SHOOT_TIMEOUT = 5

    
    SONGS = 1
    SONGOFF = 255
    BAROFF = 254
    SNOP = 253
    SOFF = 252
    
    BARRESOLUTION = 8
    MAXBARS = 18
    
    'object types
    #0, PLAYER, TANK, IBOT, IDRONE, BOSS
    
    #0, TITLE, INGAME, MENU, PAUSE, DIED, GAMEOVER, WIN, STARTLEVEL, INTRO
    


OBJ
    lcd     : "LameLCD" 
    gfx     : "LameGFX"
    map     : "LameMap"
    audio   : "LameAudio"
    music   : "LameMusic"
    ctrl    : "LameControl"
    fn      : "LameFunctions"
    
    gfx_player      : "gfx_player_small"
    gfx_ibot        : "gfx_ibot"
    gfx_idrone      : "gfx_idrone"
    gfx_tank        : "gfx_tank"    
    gfx_macrosoth   : "gfx_macrosoth"
    gfx_laser       : "gfx_laser"
    gfx_bullet      : "gfx_bullet"        
    gfx_head        : "gfx_head"
    gfx_boom        : "gfx_boom"
    gfx_healthbar   : "gfx_healthbar"
    gfx_starmap     : "gfx_starmap"
    gfx_pixmain     : "gfx_pixmain"
    
    font : "font8x8"
    
    gfx_tiles_pixel : "gfx_tiles_pixel"

    song_theme      : "sng_pixeltheme"
    song_sad        : "sng_sad"
    song_ohno       : "sng_ohno"
    song_superohno  : "sng_superohno"
    song_boss       : "sng_boss"
    song_yeah       : "sng_yeah"


VAR
    byte    gamestate
    byte    clicked

PUB Main

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#FULLSPEED)
    gfx.LoadFont(font.Addr, " ", 8, 8)

    audio.Start
    music.Start
    ctrl.Start

    InitGraphicAssets

    InitGame
    InitLevel
    
    music.LoadSong(song_theme.Addr)
    music.LoopSong

    
    gamestate := TITLE
    clicked := 0
    repeat
        case gamestate
            TITLE:      TitleScreen
            INTRO:      GameIntro
                        gamestate := STARTLEVEL
            STARTLEVEL: InitLevel                
                        music.StopSong                        
                        gamestate := INGAME
            INGAME:     GameLoop
            DIED:       PlayerDied
                        gamestate := STARTLEVEL
            WIN:        Victory
                        gamestate := TITLE
            GAMEOVER:   ItsGameOver
                        InitGame
                        gamestate := STARTLEVEL

PUB TitleScreen
    ctrl.Update
    gfx.ClearScreen(0)

    gfx.PutString(string("p  i      e  l"), 8, 30)
    gfx.Sprite(gfx_pixmain.Addr, 40, 8, 0)        
    gfx.PutString(string("press A/B"), 28, 56)

    if ctrl.A or ctrl.B
        if not clicked
            gamestate := INTRO
            clicked := 1
        else
            clicked := 0
    lcd.DrawScreen

PUB GameLoop
    ctrl.Update
    gfx.Blit(gfx_starmap.Addr)
    HandlePlayer                        
    ControlOffset
    map.Draw(xoffset, yoffset)
    DrawPlayer
    HandleBullets
    HandleEnemies
    HandleEffects
    HandleStatusBar
    lcd.DrawScreen
    fn.Sleep(10)
            
PUB Victory
    music.StopSong
    music.LoadSong(song_yeah.Addr)
    music.LoopSong
    
    ShowGameView
    gfx.TextBox(string("YOU WIN"), 40, 30, 100, 60)
    lcd.DrawScreen
    fn.Sleep(2000)
    
    music.StopSong
    music.LoadSong(song_theme.Addr)
    music.LoopSong            
    StarWarsReel(string("Looks like",10,"the galaxy",10,"is safe once",10,"again, thanks",10,"to you!"),110)

PUB ShowGameView
    gfx.Blit(gfx_starmap.Addr)
    HandlePlayer                        
    ControlOffset
    map.Draw(xoffset, yoffset)
    HandleBullets
    HandleEnemies
    HandleStatusBar

PUB PlayerDied
    playerlives--
    
    music.LoadSong(song_ohno.Addr)
    music.PlaySong         
    
    ShowGameView
    gfx.TextBox(string("Macrosoth",10,"lives yet..."), 20, 20, 100, 60)
    lcd.DrawScreen
    fn.Sleep(2000)

PUB StarWarsReel(text,reeltime) | x, choice
    x := 0
    choice := 0
        
    repeat while x < reeltime and not choice
        ctrl.Update
        if ctrl.A or ctrl.B
            if not clicked
                choice := 1
                clicked := 1
        else
            clicked := 0
        playerx := 55 << 3
        playery := 5 << 3
        pos_dir := LEFT

         
        ControlOffset
        gfx.Blit(gfx_starmap.Addr)
        map.Draw(xoffset, yoffset)
        DrawPlayer

        
        gfx.TextBox(text, 16, 64-x, 108, 64) 
    
        lcd.DrawScreen
        fn.Sleep(70)
        x++

PUB ItsGameOver
    music.LoadSong(song_superohno.Addr)
    music.PlaySong     
    
    ShowGameView
    gfx.TextBox(string("GAME OVER"), 30, 28, 100, 60)
    lcd.DrawScreen
    fn.Sleep(2000)
    
    jumping := 0
    crouching := 1
    pos_frame := 4
    
    music.StopSong   
    music.LoadSong(song_sad.Addr)
    music.LoopSong    
    
    StarWarsReel(string("There was",10,"nothing you",10,"could do to",10,"stop him..."),100)
    
    gfx.Blit(gfx_starmap.Addr)
    map.Draw(xoffset, yoffset)
    DrawPlayer            
    gfx.PutString(string("Press A and "),18,24)
    gfx.PutString(string("try again..."),18,32)
    lcd.DrawScreen
    
    repeat until ctrl.A
        ctrl.Update

PUB GameIntro
    jumping := 0
    crouching := 0
    pos_frame := 0
    
    music.StopSong   
    music.LoadSong(song_sad.Addr)
    music.LoopSong    

    StarWarsReel(string("You have",10,"escaped",10,"the evil",10,"experiments",10,"of the one",10,"they call",10,"Macrosoth.",10,10,"Now you must",10,"defeat him",10,"once and for",10,"all..",10,10,"Before it's",10,"too late..."),200)


' *********************************************************
'  Levels
' *********************************************************  
CON
    LEVELS = 1

OBJ

    map_pixel   :       "map_pixel"

VAR
    word    leveldata[LEVELS]
    byte    currentlevel
    word    tilemap

    long    xoffset
    long    yoffset
    
    byte    playerlives 
    
PUB InitGame
    playerlives := STARTING_LIVES

PUB InitLevel

    tilemap := gfx_tiles_pixel.Addr
    leveldata[0] := map_pixel.Addr

    ControlOffset
    InitPlayer
    InitBullets
    InitEnemies
    InitEffects
        
    map.Load(tilemap, leveldata[currentlevel])
    ReadObjects(map_pixel.objAddr)

            
' *********************************************************
'  Player
' *********************************************************
CON
    
    SPEED = 4
    STARTING_HEALTH = 5
    STARTING_LIVES = 3
VAR
    long    playerx
    long    playery
    long    pos_oldx
    long    pos_oldy

    byte    pos_dir
    long    pos_speed
    long    pos_speedx
    byte    pos_frame
    word    pos_count
    
    byte    jumping
    byte    crouching
    
    byte    playerhealth
    byte    playerhealth_timeout
    byte    playershoot_timeout

PUB InitPlayer
    pos_dir := RIGHT
    playerhealth := STARTING_HEALTH
    playerhealth_timeout := 0

PUB HandlePlayer | adjust
    pos_oldx := playerx
    pos_oldy := playery    
            
    if jumping
        pos_frame := 3
        crouching := 0
    else
        if ctrl.Down
            crouching := 1
        else
            crouching := 0
            
    if not crouching
        if ctrl.Left or ctrl.Right
    
            if ctrl.Left
                playerx -= SPEED
                pos_dir := LEFT
            if ctrl.Right
                playerx += SPEED
                pos_dir := RIGHT
    
            pos_count++
            if pos_count & $1 == 0
                case (pos_count >> 1) & $3  ' Test the frame
                    0:  pos_frame := 0
                    1:  pos_frame := 1
                    2:  pos_frame := 0
                    3:  pos_frame := 2                                                
        else
            pos_frame := 0
            pos_count := 0            
    else
        pos_frame := 4            

    if jumping
        pos_frame := 3

    adjust := map.TestMoveX(pos_oldx, playery, word[gfx_player.Addr][1], word[gfx_player.Addr][2], playerx)
    if adjust
        playerx += adjust

    if ctrl.A
        if not jumping               
            pos_speed := -9
            jumping := 1                 

    if ctrl.B
        if not playershoot_timeout
            playershoot_timeout := SHOOT_TIMEOUT
            
            if crouching
                if pos_dir == LEFT
                    SpawnBullet(playerx, playery+7, LEFT)
                if pos_dir == RIGHT
                    SpawnBullet(playerx, playery+7, RIGHT)    
            else
                if pos_dir == LEFT
                    SpawnBullet(playerx, playery+2, LEFT)
                if pos_dir == RIGHT
                    SpawnBullet(playerx, playery+2, RIGHT)    
        else
            playershoot_timeout--
    else
        playershoot_timeout := 0
                
    pos_speed += 1
    playery += pos_speed

    adjust := map.TestMoveY(playerx, pos_oldy, word[gfx_player.Addr][1], word[gfx_player.Addr][2], playery)
    if adjust
        if  pos_speed > 0
            jumping := 0
        playery += adjust
        pos_speed := 0
    
    if pos_speed > 0
        jumping := 1
        
    if playery > (map.GetHeight << 3)
        KillPlayer
                
    if playerhealth_timeout > 0
        playerhealth_timeout--
        

PUB DrawPlayer
    if not playerhealth_timeout or (playerhealth_timeout & $2)
        if pos_dir == LEFT
            gfx.Sprite(gfx_player.Addr,playerx-xoffset,playery-yoffset, 5+pos_frame)
        if pos_dir == RIGHT
            gfx.Sprite(gfx_player.Addr,playerx-xoffset,playery-yoffset, pos_frame)

PUB KillPlayer
    if playerlives > 1
        gamestate := DIED
    else
        gamestate := GAMEOVER
        
PUB HitPlayer
    if playerhealth_timeout == 0
        playerhealth--
        if not playerhealth > 0
            KillPlayer
        playerhealth_timeout := HURT_TIMEOUT


PUB HandleStatusBar | x

    repeat x from 0 to (playerlives-1)
        gfx.Sprite(gfx_head.Addr, x<<3, 56, 0)
        
    repeat x from 0 to (playerhealth-1)
        gfx.Sprite(gfx_healthbar.Addr, 124-x<<2, 56, 0)        



' *********************************************************
'  Effects
' *********************************************************
CON 
    EFFECTS = 6
    #1, EXPLOSION
  
VAR
    word    effect
    long    effectx[EFFECTS]
    long    effecty[EFFECTS]
    byte    effecton[EFFECTS]
    byte    effectframe[EFFECTS]
    word    effecttime[EFFECTS]

PUB InitEffects | index
    effect := 0
    repeat index from 0 to constant(EFFECTS-1)
        effecton[index] := 0 
        effectx[index] := 0
        effecty[index] := 0
        effectframe[index] := 0
        effecttime[index] := 0
    

PUB SpawnEffect(x, y, type)

    effecton[effect] := type
    effectx[effect] := x
    effecty[effect] := y
    effectframe[effect] := 0
    effecttime[effect] := 0
                                
    effect++
    if effect > constant(EFFECTS-1)
        effect := 0
        
    audio.SetWaveform(2, 4)
    audio.SetADSR(2, 127, 10, 0, 70)
    audio.PlaySound(2,40)

PUB HandleEffects | effectxtemp, effectytemp, index

    repeat index from 0 to constant(EFFECTS-1)
        if effecton[index]
        
            effecttime[index]++
            if effecttime[index] > 4
                effecttime[index] := 0
                effectframe[index]++
                
            if effectframe[index] > 2
                effecton[index] := 0
            else
                effectxtemp := effectx[index] - xoffset
                effectytemp := effecty[index] - yoffset
      
                if (effectxtemp => 0) and (effectxtemp =< SCREEN_W-1) and (effectytemp => 0) and (effectytemp =< SCREEN_H - 1)          
                    gfx.Sprite(gfx_boom.Addr, effectxtemp , effectytemp, effectframe[index])
                else
                    effecton[index] := 0


' *********************************************************
'  Objects
' *********************************************************
VAR
    word    objectgraphics[8]
    word    objecthealth[8]
    
PUB InitGraphicAssets
    objectgraphics[PLAYER] := gfx_player.Addr
    objectgraphics[TANK] := gfx_tank.Addr
    objectgraphics[IBOT] := gfx_ibot.Addr
    objectgraphics[IDRONE] := gfx_idrone.Addr
    objectgraphics[BOSS] := gfx_macrosoth.Addr
    
    objecthealth[TANK]   := 3
    objecthealth[IBOT]   := 1
    objecthealth[IDRONE] := 2
    objecthealth[BOSS]   := 10
    


PUB ReadObjects(objectaddr) | objcount, object, objtype, objx, objy
    objcount := byte[objectaddr][0]
    objectaddr += 2
    
    repeat object from 0 to objcount-1    
        objx := byte[objectaddr][0] << 3
        objy := byte[objectaddr][1] << 3

        objtype := byte[objectaddr][2]

        case objtype
            PLAYER:     playerx := objx
                        playery := objy
            TANK, IBOT, IDRONE:  SpawnEnemy(objx, objy, objtype, LEFT)
            BOSS:       SpawnEnemy(objx, objy, objtype, LEFT)
            
        objectaddr += 3


PUB GetObjectWidth(type)
    return word[objectgraphics[type]][1]
    
PUB GetObjectHeight(type)
    return word[objectgraphics[type]][2]    


 
' *********************************************************
'  Bullets
' *********************************************************
CON 
    BULLETS = 10
    BULLETINGSPEED = 15
  
VAR
    word    bullet
    long    bulletx[BULLETS]
    long    bullety[BULLETS]
    byte    bulletdir[BULLETS]
    byte    bulleton[BULLETS]
    word    bulletindex

PUB InitBullets
    bullet := 0
    repeat bulletindex from 0 to constant(BULLETS-1)
        bulleton[bulletindex] := 0 
        bulletx[bulletindex] := 0
        bullety[bulletindex] := 0
        bulletdir[bulletindex] := 0
    

PUB SpawnBullet(x, y, dir)

    bulleton[bullet] := 1 
    bulletdir[bullet] := dir
    
    bulletx[bullet] := x
    bullety[bullet] := y
                                
    bullet++
    if bullet > constant(BULLETS-1)
        bullet := 0

    audio.SetWaveform(2, 1)
    audio.SetADSR(2, 127, 50, 0, 50)
    audio.PlaySound(2,70)        

PUB HandleBullets | bulletxtemp, bulletytemp

    repeat bulletindex from 0 to constant(BULLETS-1)
        if bulleton[bulletindex]

          if bulletdir[bulletindex] == LEFT
             bulletx[bulletindex] -= BULLETINGSPEED
          
          elseif bulletdir[bulletindex] == RIGHT
             bulletx[bulletindex] += BULLETINGSPEED   
          
          elseif bulletdir[bulletindex] == UP
             bullety[bulletindex] -= BULLETINGSPEED    
          
          elseif bulletdir[bulletindex] == DOWN
             bullety[bulletindex] += BULLETINGSPEED  

          bulletxtemp := bulletx[bulletindex] - xoffset
          bulletytemp := bullety[bulletindex] - yoffset

          if (bulletxtemp => 0) and (bulletxtemp =< SCREEN_W-1) and (bulletytemp => 0) and (bulletytemp =< SCREEN_H - 1)
              if fn.TestBoxCollision(bulletx[bulletindex], bullety[bulletindex]+4, 8, 1, playerx, playery, word[gfx_player.Addr][1], word[gfx_player.Addr][2])
                  HitPlayer
                  bulleton[bulletindex] := 0
              else
                  gfx.Sprite(gfx_laser.Addr, bulletxtemp , bulletytemp, 0)
          else
              bulleton[bulletindex] := 0
              
          



' *********************************************************
'  Enemies
' *********************************************************
CON
    ENEMIES = 16
    ENEMYTYPES = 2

VAR           
    byte    enemyindex
    byte    enemycount
    byte    nextenemy
    byte    enemyon[ENEMIES]
    
    long    enemyx[ENEMIES]
    long    enemyy[ENEMIES]
    long    enemyspeedx[ENEMIES]
    long    enemyspeedy[ENEMIES]
    byte    enemyframe[ENEMIES]
    
    long    enemydir[ENEMIES]
    long    enemytmp1[ENEMIES]
        
    byte    enemyhealth[ENEMIES]
    byte    enemytimeout[ENEMIES]
    byte    bossspawned


PUB InitEnemies

    enemycount := 0
    
    repeat enemyindex from 0 to constant(ENEMIES-1)
        enemyon[enemyindex] := 0
        enemyx[enemyindex] := 0
        enemyy[enemyindex] := 0
        enemydir[enemyindex] := RIGHT
        enemyframe[enemyindex] := 0
        enemyhealth[enemyindex] := 0
        enemytimeout[enemyindex] := 0
        
                
PUB HandleEnemies

    repeat enemyindex from 0 to constant(ENEMIES-1)
        if enemyon[enemyindex]
            if enemyx[enemyindex] + GetObjectWidth(enemyon[enemyindex]) - xoffset > 0 and enemyx[enemyindex] - xoffset < SCREEN_W and enemyy[enemyindex] + GetObjectHeight(enemyon[enemyindex]) - yoffset > 0 and enemyy[enemyindex] - yoffset < SCREEN_H
                case enemyon[enemyindex]
                    TANK: EnemyTank(enemyindex)
                    IBOT:  EnemyEye(enemyindex)
                    IDRONE:  EnemyEye(enemyindex)
                    BOSS:  EnemyBoss(enemyindex)    
            
                if not enemytimeout[enemyindex] or (enemytimeout[enemyindex] & $1)
                    DrawObject(enemyindex, enemyon[enemyindex], enemyframe[enemyindex])
                if enemytimeout[enemyindex]
                    enemytimeout[enemyindex]--
                CheckEnemyCollision(enemyindex)
            
PUB EnemyTank(index) | dx, dy
    pos_oldx := enemyx[index]
    pos_oldy := enemyy[index]
    
    dx := playerx - enemyx[index]
    dy := playery - enemyy[index]
    
    if dx > 0
        enemydir[index] := RIGHT
    else
        enemydir[index] := LEFT
    
    if ||dx < 32 and ||(dy + 8) < 16
        
            enemytmp1[index]++
        
            if enemytmp1[index] > 20
                enemytmp1[index] := 0
                if enemydir[index] == LEFT
                    SpawnBullet(enemyx[index]-8, enemyy[index]+5, LEFT)
                if enemydir[index] == RIGHT
                    SpawnBullet(enemyx[index] + 16, enemyy[index]+5, RIGHT)
    else
        if dx > 0
            enemyx[index] += 1
        else
            enemyx[index] -= 1

    if map.TestCollision(enemyx[index], enemyy[index], 16, 16)
        enemyx[index] := pos_oldx
        enemyspeedx[index] := -enemyspeedx[index]
    
    enemyspeedy[index] += 1
    enemyy[index] += enemyspeedy[index]

    if map.TestCollision(enemyx[index], enemyy[index], 16, 16)
        enemyy[index] := pos_oldy
        enemyspeedy[index] := 0
    
    if enemydir[index] == LEFT
        enemyframe[index] := 0
    else
        enemyframe[index] := 1




PUB EnemyEye(index) | dx, dy
    dx := playerx - enemyx[index]
    dy := playery - enemyy[index]
    
    if dx > 0
        enemyx[index]++
    elseif dx < 0
        enemyx[index]--
        
    if dy > 0
        enemyy[index]++
    elseif dy < 0
        enemyy[index]--

    enemyframe[index] := 0



PUB EnemyBoss(index) | dx, dy
    dx := playerx - enemyx[index]
    dy := playery - enemyy[index]

    if not bossspawned
        bossspawned := 1
    
        music.LoadSong(song_boss.Addr)
        music.LoopSong    


    enemyframe[index] := 0

    
PUB DrawObject(index, type, frame) | tmpx, tmpy
    tmpx := enemyx[index] - xoffset
    tmpy := enemyy[index] - yoffset
    gfx.Sprite(objectgraphics[type], tmpx, tmpy, frame)


PUB SpawnEnemy(dx, dy, type, dir)
    if enemycount < constant(ENEMIES-1)
        enemyon[nextenemy] := type
        enemyx[nextenemy] := dx
        enemyy[nextenemy] := dy
        enemyhealth[nextenemy] := objecthealth[type]
        
        nextenemy++
        if nextenemy => ENEMIES
            nextenemy := 0
            
        enemycount++


PUB CheckEnemyCollision(index) | x, y, boom, ran
    repeat bulletindex from 0 to constant(BULLETS-1)
      if bulleton[bulletindex]
    
        if fn.TestBoxCollision(bulletx[bulletindex], bullety[bulletindex]+4, 8, 1, enemyx[index], enemyy[index], GetObjectWidth(enemyon[index]), GetObjectHeight(enemyon[index]))
            if enemyhealth[index] > 1
                enemyhealth[index]--
                enemytimeout[index] := ENEMY_TIMEOUT
            else
            
                repeat y from 0 to (GetObjectHeight(enemyon[index])>>3)-1
                    repeat x from 0 to (GetObjectWidth(enemyon[index])>>3)-1
                        SpawnEffect(enemyx[index]+(x<<3), enemyy[index]+(y<<3), EXPLOSION)
                        
                if enemyon[index] == BOSS
                    gamestate := WIN

                enemyon[index] := 0
            bulleton[bulletindex] := 0
                
    if fn.TestBoxCollision(playerx, playery, GetObjectWidth(PLAYER), GetObjectHeight(PLAYER), enemyx[index], enemyy[index], GetObjectWidth(enemyon[index]), GetObjectHeight(enemyon[index]))
        HitPlayer


PUB ControlOffset | bound_x, bound_y

    bound_x := map.GetWidth << 3 - SCREEN_W
    bound_y := map.GetHeight << 3 - SCREEN_H
    
    xoffset := playerx + (word[gfx_player.Addr][1]>>1) - (SCREEN_W>>1)
    if xoffset < 0
        xoffset := 0      
    elseif xoffset > bound_x
        xoffset := bound_x
        
        
    yoffset := playery + (word[gfx_player.Addr][2]>>1) - (SCREEN_H>>1)
    if yoffset < 0
        yoffset := 0      
    elseif yoffset > bound_y
        yoffset := bound_y


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
