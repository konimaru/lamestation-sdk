{{
Tank Battle
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2011 LameStation.
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}


CON
    _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
    _xinfreq        = 5_000_000                ' External oscillator = 5 MHz
                          
    SCREEN_BW = 16   
    SCREEN_BH = 8
    
    
    SCREEN_W = 128
    SCREEN_H = 64
    BITSPERPIXEL = 2
    FRAMES = 1

    SCREEN_H_BYTES = SCREEN_H / 8
    SCREENSIZE_BYTES = SCREEN_W * SCREEN_H_BYTES * BITSPERPIXEL
    TOTALBUFFER_BYTES = SCREENSIZE_BYTES

            
    DIR_U = 2
    DIR_D = 3
    DIR_L = 0
    DIR_R = 1
    
    NL = 10
    TANKS = 2   'must be power of 2
    TANKSMASK = TANKS-1
    
    TANKTYPES = 5 'must be power of 2
    TANKTYPESMASK = TANKTYPES-1
    
    TANKHEALTHMAX = 10
    
    BULLETS = 20
    BULLETSMASK = BULLETS-1
    
    BULLETINGSPEED = 2
    
    XOFFSET1 = 16
    YOFFSET1 = 20
    
    COLLIDEBIT = $80
    TILEBYTE = COLLIDEBIT-1
    
    LEVELS = 1
    LEVELSMASK = LEVELS-1
    
    GO_GAME = 1
    GO_MENU = 2
    
    PAUSEMENU1_CHOICES = 3
    
    WIFI_RX = 22
    WIFI_TX = 23
    
    UPDATETANKX = 1
    UPDATETANKY = 2
    UPDATETANKDIR = 3
    UPDATEBULLETSPAWN = 4
    
    'CONTROLS LIFE AND DEATH
    UPDATETANKSPAWN = 5
    UPDATETANKDIED = 6
    UPDATESCORE = 7
    UPDATEADVANCE = 8
    UPDATEORDER = 9
    UPDATETYPE = 10
    UPDATELEVEL = 11
    
    
    'DECIDES WHO CLICKED TO INITIALIZE THE GAME
    'if this message is sent, you start in starting location 1.
    'if it's received by an opponent, you start in location 2.
    'UPDATEADVANCE = 10


    'SONG PLAYER
    ENDOFSONG = 0
    TIMEWAIT = 1
    NOTEON = 2
    NOTEOFF = 3
    
    SONGS = 2
    SONGOFF = 255
    BAROFF = 254
    SNOP = 253
    SOFF = 252
    
    BARRESOLUTION = 8
    MAXBARS = 18
        

OBJ
    lcd     :               "LameLCD"
    gfx     :               "LameGFX"
    audio   :               "LameAudio"
    ctrl    :               "LameControl"

VAR

    word    prebuffer[TOTALBUFFER_BYTES/2]
    
    word    screenpointer
    word    screen
    word    anotherpointer

    byte    levelw
    byte    levelh
    byte    currentlevel
    word    leveldata[LEVELS]
    word    levelname[LEVELS]
    word    tilemap
    word    levelmap
    byte    levelstarts[LEVELS*TANKS]

    long    x
    long    y    
    long    tile
    long    tilecnt
    long    tilecnttemp


    long    xoffset
    long    yoffset

    long    tankgfx[TANKS]
    long    tankx[TANKS]
    long    tanky[TANKS]
    long    tankoldx
    long    tankoldy
    byte    tankolddir
    byte    tankstartx[TANKS]
    byte    tankstarty[TANKS]

    byte    tankw[TANKS]
    byte    tankh[TANKS]
    byte    tankdir[TANKS]
    byte    tankhealth[TANKS]
    byte    tankon[TANKS]

    long    tankxtemp
    long    tankytemp
    byte    tankwtemp
    byte    tankhtemp

    long    tanktypegfx[TANKTYPES]
    word    tanktypename[TANKTYPES]

    byte    score[TANKS]
    byte    oldscore

    word    bullet
    long    bulletx[BULLETS]
    long    bullety[BULLETS]
    byte    bulletspeed[BULLETS]
    byte    bulletdir[BULLETS]
    byte    bulleton[BULLETS]

    long    bulletxtemp
    long    bulletytemp

    long    bacon

    byte    collided
    byte    yourtank
    byte    theirtank
    byte    yourtype
    byte    oldtype
    byte    theirtype
    byte    tankindex
    byte    levelindex
    word    bulletindex

    byte    choice
    byte    menuchoice
    byte    clicked           
    byte    joyclicked

    byte    intarray[3]


    'WIFI HANDLING VARIABLES
    byte    receivebyte
    byte    bulletspawned
    byte    tankspawned
    byte    respawnindex
    byte    respawnindexsaved

PUB Main

    dira~    
    screenpointer := lcd.Start
    anotherpointer := @prebuffer
    gfx.Start(@anotherpointer)

    audio.Start
    ctrl.Start

    gfx.ClearScreen
    lcd.SwitchFrame

    InitData

    clicked := 0
    'LogoScreen
    'TitleScreen
    'TankSelect
    'LevelSelect                          
    'TankFaceOff          



    menuchoice := GO_GAME
    repeat
        if menuchoice == GO_GAME
            menuchoice := GameLoop
        elseif menuchoice == GO_MENU
            menuchoice := PauseMenu


PUB LogoScreen

    gfx.ClearScreen
    lcd.SwitchFrame
    gfx.ClearScreen
    gfx.Sprite(@teamlamelogo, 0, 3, 0, 1, 0)
    lcd.SwitchFrame

    audio.SetWaveform(3, 127)
    audio.SetADSR(127, 10, 0, 10)
    audio.PlaySequence(@logoScreenSound)  

    repeat x from 0 to 150000 

    audio.StopSong

PUB TitleScreen

    audio.SetWaveform(1, 127)
    audio.SetADSR(127, 127, 100, 127) 
    audio.LoadSong(@titleScreenSong)
    audio.PlaySong



    choice := 1
    repeat until not choice
        ctrl.Update
        lcd.SwitchFrame

        gfx.Blit(@excitingtank)   

        if ctrl.A or ctrl.B
              if not clicked
                choice := 0
                clicked := 1
               
                yourtank := 0
                theirtank := 1

        else
              clicked := 0

PUB TankSelect         

    choice := 1
    joyclicked := 0
    repeat until not choice

        ctrl.Update
        lcd.SwitchFrame         
        gfx.ClearScreen

        if ctrl.Up or ctrl.Down
           if joyclicked == 0
              joyclicked := 1 
              if ctrl.Up
                if yourtype <> 0
                  yourtype--
                else
                  yourtype := TANKTYPESMASK
              if ctrl.Down
                yourtype++
                if yourtype > TANKTYPESMASK
                  yourtype := 0

        else
            joyclicked := 0

      
        if ctrl.A or ctrl.B
          if not clicked
            choice := 0
            clicked := 1
            
        else
          clicked := 0            


        gfx.Sprite(@tanklogo, 0, 0, 0, 1, 0)
        gfx.TextBox(string("CHOOSE"), 6, 2)

        gfx.TextBox(string("You"),2,3)
        gfx.TextBox(string("Enemy"),10,3)
        
        gfx.TextBox(tanktypename[yourtype],0,7)
        gfx.TextBox(tanktypename[theirtype],9,7)
           
        gfx.TextBox(string("vs."),7,5)
            
        gfx.Sprite(tanktypegfx[yourtype], 3, 4, 3, 1, 0) 
        gfx.Sprite(tanktypegfx[theirtype], 11, 4, 2, 1, 0) 

       ' gfx.TextBox(string("At"),3,7)   
        'gfx.TextBox(levelname[currentlevel],5,7)  


    tankgfx[yourtank] := tanktypegfx[yourtype]
    tankgfx[theirtank] := tanktypegfx[theirtype]

    repeat tankindex from 0 to TANKSMASK
       tankw[tankindex] := word[tankgfx[tankindex]][1]
       tankh[tankindex] := word[tankgfx[tankindex]][2]







PUB LevelSelect

    choice := 1
    joyclicked := 0
    repeat until not choice

        ctrl.Update
        lcd.SwitchFrame
        gfx.ClearScreen         


        if ctrl.Up or ctrl.Down
           if not joyclicked
              joyclicked := 1 
              if ctrl.Up
                if currentlevel <> 0
                  currentlevel--
                else
                  currentlevel := LEVELSMASK
              if ctrl.Down
                currentlevel++
                if currentlevel > LEVELSMASK
                  currentlevel := 0
        else
            joyclicked := 0
              

        
        if ctrl.A or ctrl.B
          if not clicked
            choice := 0
            clicked := 1
            
        else
          clicked := 0  

        gfx.Sprite(@tanklogo, 0, 0, 0, 1, 0)
        gfx.TextBox(string("Level:"),0,2)                  
        gfx.TextBox(levelname[currentlevel],5,2)

        'DRAW TILES TO SCREEN
        xoffset := 5
        yoffset := 2

        levelw := byte[leveldata[currentlevel]][0] 
        levelh := byte[leveldata[currentlevel]][1]
        
        DrawMap(tilemap,leveldata[currentlevel],0,3,SCREEN_BW,5)


        
    InitLevel




PUB TankFaceOff
         
    choice := 1
    repeat until not choice

        ctrl.Update 
        lcd.SwitchFrame         
        gfx.ClearScreen

        gfx.Sprite(@tanklogo, 0, 0, 0, 0, 0)
        gfx.TextBox(string("Prepare for battle..."),2,3)
        
        if ctrl.A or ctrl.B
          if not clicked
            choice := 0
            clicked := 1

        else
          clicked := 0       
    
PUB GameLoop : menureturn

    audio.StopSong
    audio.SetWaveform(4, 127)
    audio.SetADSR(127, 70, 0, 70)

    clicked := 0
    choice := 0                               
    repeat while not choice
        
        gfx.TranslateBuffer(@prebuffer, word[screenpointer])
        lcd.SwitchFrame
        
        gfx.ClearScreen

        ctrl.Update

          if tankon[yourtank] == 1   
              tankoldx := tankx[yourtank]
              tankoldy := tanky[yourtank]
              tankolddir := tankdir[yourtank]
              oldscore := score[yourtank]

              'TANK CONTROL
              'LEFT AND RIGHT   
              if ctrl.Left
                 tankdir[yourtank] := 0        

                 tankx[yourtank]--
                  if tankx[yourtank] < 0
                      tankx[yourtank] := 0
              if ctrl.Right
                  tankdir[yourtank] := 1
              
                  tankx[yourtank]++
                  if tankx[yourtank] > levelw - tankw[yourtank]
                      tankx[yourtank] := levelw - tankw[yourtank] 


              tankxtemp := tankx[yourtank] 
              tankytemp := tanky[yourtank]
              
              
              tilecnt := 0
              tilecnttemp := 2
              if tanky[yourtank] > 0
                  repeat y from 0 to tanky[yourtank]-1
                       tilecnttemp += levelw
              repeat y from tankytemp to tankytemp+tankh[yourtank]-1
                  repeat x from tankxtemp to tankxtemp+tankw[yourtank]-1 
                      tilecnt := tilecnttemp + x
               
                      tile := (byte[leveldata[currentlevel]][tilecnt] & COLLIDEBIT)
                      if tile <> 0
                             tankx[yourtank] := tankoldx 
                  tilecnttemp += levelw



              repeat tankindex from 0 to TANKSMASK
                  if tankon[tankindex]
                      if tankindex <> yourtank
                          collided := 1
                          if tankxtemp+tankw[yourtank]-1 < tankx[tankindex]
                             collided := 0
                          if tankxtemp > tankx[tankindex]+tankw[tankindex]-1
                             collided := 0
                          if tankytemp+tankh[yourtank]-1 < tanky[tankindex]
                             collided := 0
                          if tankytemp > tanky[tankindex]+tankh[tankindex]-1
                             collided := 0

                          if collided == 1
                             tankx[yourtank] := tankoldx    



           
          'UP AND DOWN   
              if ctrl.Up
                  tankdir[yourtank] := 2
                  
                  tanky[yourtank]--
                  if tanky[yourtank] < 0
                      tanky[yourtank] := 0
              if ctrl.Down
                  tankdir[yourtank] := 3  

                  tanky[yourtank]++
                  if tanky[yourtank] > levelh - tankh[yourtank]
                      tanky[yourtank] := levelh - tankh[yourtank]
       
              tankxtemp := tankx[yourtank] 
              tankytemp := tanky[yourtank]
              tilecnt := 0
              tilecnttemp := 2
              if tanky[yourtank] > 0
                  repeat y from 0 to tanky[yourtank]-1
                      tilecnttemp += levelw
              repeat y from tankytemp to tankytemp+tankw[yourtank]-1
                  repeat x from tankxtemp to tankxtemp+tankh[yourtank]-1 
                      tilecnt := tilecnttemp + x
               
                      tile := (byte[leveldata[currentlevel]][tilecnt] & COLLIDEBIT)
                      if tile <> 0
                            tanky[yourtank] := tankoldy
                  tilecnttemp += levelw

              repeat tankindex from 0 to TANKSMASK
                  if tankon[tankindex] 
                      if tankindex <> yourtank
                          collided := 1
                          if tankxtemp+tankw[yourtank]-1 < tankx[tankindex]
                             collided := 0
                          if tankxtemp > tankx[tankindex]+tankw[tankindex]-1
                             collided := 0
                          if tankytemp+tankh[yourtank]-1 < tanky[tankindex]
                             collided := 0
                          if tankytemp > tanky[tankindex]+tankh[tankindex]-1
                             collided := 0

                          if collided == 1
                             tanky[yourtank] := tankoldy    


              'OFFSET CONTROL
              ControlOffset(yourtank)
     
        

     
               
               
              if ctrl.A
                if not clicked
                  clicked := 1
               
                 ' choice := GO_MENU 'Go to menu
                  
                '  yourtank++
                 ' yourtank &= TANKSMASK

              elseif ctrl.B
                  if tankon[yourtank] == 1
                    SpawnBullet(yourtank)
                    bulletspawned := 1
                
              else
                  clicked := 0
               



      
          else

              'TANK CONTROL
              'LEFT AND RIGHT   
              if ctrl.Left
                  xoffset--
                  if xoffset < 0
                      xoffset := 0 
              if ctrl.Right
                  xoffset++
                  if xoffset > (levelw<<3)-SCREEN_W
                      xoffset := (levelw<<3)-SCREEN_W


                      
              'UP AND DOWN   
              if ctrl.Up
                  yoffset-- 
                  if yoffset < 0
                      yoffset := 0  
              if ctrl.Down
                  yoffset++
                  if yoffset > (levelh<<3)-SCREEN_H
                      yoffset := (levelh<<3)-SCREEN_H  

               
              if ctrl.A or ctrl.B
                if clicked == 0
                  SpawnTank(yourtank, 0, 1)
                  tankspawned := 1      
                  
                  clicked := 1
              else
                clicked := 0
               
               
                      
          'DRAW TILES TO SCREEN
          DrawMap(tilemap,leveldata[currentlevel],2,2,SCREEN_BW-2,SCREEN_BH-2)

          

          'DRAW TANKS TO SCREEN        
          
          repeat tankindex from 0 to TANKS-1
              if tankon[tankindex] == 1
                  tankxtemp := tankx[tankindex] - xoffset
                  tankytemp := tanky[tankindex] - yoffset
                  tankwtemp := tankw[tankindex]
                  tankhtemp := tankh[tankindex]        
                                                                                        
                  if (tankxtemp => 0) and (tankxtemp =< SCREEN_BW-tankw[yourtank]) and (tankytemp => 0) and (tankytemp =< SCREEN_BH - tankh[yourtank])

                    if tankdir[tankindex] == DIR_D
                        gfx.Sprite(tankgfx[tankindex], tankxtemp, tankytemp, 0, 1, 0)
                    elseif tankdir[tankindex] == DIR_U       
                        gfx.Sprite(tankgfx[tankindex], tankxtemp, tankytemp, 1, 1, 0)
                    elseif tankdir[tankindex] == DIR_L       
                        gfx.Sprite(tankgfx[tankindex], tankxtemp, tankytemp, 2, 1, 0)
                    elseif tankdir[tankindex] == DIR_R       
                        gfx.Sprite(tankgfx[tankindex], tankxtemp, tankytemp, 3, 1, 0)
              
              
                                                             
          'CONTROL EXISTING BULLETS -----
          'BulletHandler

          'HUD OVERLY
          'StatusOverlay

    menureturn := choice

PUB PauseMenu : menureturn

    choice := 0
    repeat while not choice
           
        ctrl.Update 
        lcd.SwitchFrame         
        gfx.ClearScreen

        gfx.Sprite(@tanklogo, 0, 0, 0, 0, 0)
        gfx.TextBox(string(" PAUSE!"),5,2)


        if ctrl.Up or ctrl.Down
           if not joyclicked
              joyclicked := 1 
              if ctrl.Up
                if menuchoice <> 0
                  menuchoice--
                else
                  menuchoice := PAUSEMENU1_CHOICES
              if ctrl.Down
                menuchoice++
                if menuchoice > PAUSEMENU1_CHOICES
                  menuchoice := 0 
        else
            joyclicked := 0
             

        if ctrl.A or ctrl.B
          if not clicked
            choice := GO_GAME
            clicked := 1
        else
          clicked := 0
          
        gfx.Sprite(@bulletgfx, 3, 4+menuchoice, 0, 1, 0)
        gfx.TextBox(string("Return to Game"),4,4)
        gfx.TextBox(string("Change Level"),4,5)
        gfx.TextBox(string("Change Tank"),4,6)
        gfx.TextBox(string("Give Up?"),4,7)


    if menuchoice == 1
        LevelSelect

    elseif menuchoice == 2
        TankSelect

    menureturn := GO_GAME



PUB InitData

    currentlevel := 0
    yourtype := 0
    theirtype := 0

    tilemap := @gfx_tiles_2b_poketron

    leveldata[0] := @map_supercastle  
    'leveldata[0] := @MoonManLevel   
    'leveldata[1] := @WronskianDelta
    'leveldata[2] := @TheCastle
    'leveldata[3] := @thehole
    'leveldata[4] := @pokemon
               
    levelname[0] := @level0name
    'levelname[1] := @level1name
    'levelname[2] := @level2name
    'levelname[3] := @level3name
    'levelname[4] := @level4name

    levelw := byte[leveldata[currentlevel]][0] 
    levelh := byte[leveldata[currentlevel]][1]

    tanktypename[0] := @extremetankname   
    tanktypename[1] := @extremethangname
    tanktypename[2] := @gianttankname
    tanktypename[3] := @happyfacename
    tanktypename[4] := @moonmanname

    tanktypegfx[0] := @extremetank
    tanktypegfx[1] := @extremethang
    tanktypegfx[2] := @gianttank
    tanktypegfx[3] := @happyface
    tanktypegfx[4] := @moonman


PUB InitLevel

    levelw := byte[leveldata[currentlevel]][0] 
    levelh := byte[leveldata[currentlevel]][1]

    'INITIALIZE START LOCATIONS         
    repeat tankindex from 0 to TANKSMASK
        score[tankindex] := 0 
        SpawnTank(tankindex, tankindex, 0)

    tankspawned := 0
    respawnindex := yourtank

    ControlOffset(yourtank)


    bullet := 0
    repeat bulletindex from 0 to BULLETSMASK
        bulleton[bulletindex] := 0 
        bulletx[bulletindex] := 0
        bullety[bulletindex] := 0
        bulletspeed[bulletindex] := 0
        bulletdir[bulletindex] := 0
    bulletspawned := 0



PUB SpawnTank(tankindexvar, respawnindexvar, respawnflag)
    if respawnflag == 1
       respawnindex := (respawnindex + 1) & TANKSMASK
       tankx[tankindexvar] := byte[@startlocations][(currentlevel<<2)+(respawnindex<<1)+0] 
       tanky[tankindexvar] := byte[@startlocations][(currentlevel<<2)+(respawnindex<<1)+1]
    else
       tankx[tankindexvar] := byte[@startlocations][(currentlevel<<2)+(respawnindexvar<<1)+0] 
       tanky[tankindexvar] := byte[@startlocations][(currentlevel<<2)+(respawnindexvar<<1)+1]
    tankon[tankindexvar] := 1
    tankhealth[tankindexvar] := TANKHEALTHMAX
    tankdir[tankindexvar] := 0
    

PUB DrawMap(source_tilemap, source_levelmap, position_x, position_y, width, height)
       
    'DRAW TILES TO SCREEN
    tilecnt := 0
    tilecnttemp := 2
                    
'    if yoffset > 0
      repeat y from 0 to (yoffset>>3)
        tilecnttemp += byte[source_levelmap][1]
    repeat y from 1 to 7
        repeat x from 1 to 15
            tilecnt := tilecnttemp + (xoffset >> 3) + x
            tile := (byte[source_levelmap][tilecnt] & TILEBYTE) -1 
            if tile > 0
                 gfx.Box(source_tilemap + (tile << 4), (x << 3) - (xoffset & $7), (y<<3) - (yoffset & $7))

        tilecnttemp += byte[source_levelmap][0]


PUB ControlOffset(tankindexvar)

    xoffset := tankx[tankindexvar] - 7
    if xoffset < 0
        xoffset := 0      
    elseif xoffset > levelw-SCREEN_BW
        xoffset := levelw-SCREEN_BW
                  
    yoffset := tanky[tankindexvar] - 3
    if yoffset < 0
        yoffset := 0      
    elseif yoffset > levelh-SCREEN_BH
        yoffset := levelh-SCREEN_BH 
    

PUB SpawnBullet(tankindexvar)

    bulleton[bullet] := 1 
    bulletdir[bullet] := tankdir[tankindexvar]

    if bulletdir[bullet] == DIR_L
        bulletx[bullet] := tankx[tankindexvar]
        bullety[bullet] := tanky[tankindexvar]
          
    if bulletdir[bullet] == DIR_R
        bulletx[bullet] := tankx[tankindexvar] + tankw[tankindexvar] - 1
        bullety[bullet] := tanky[tankindexvar]
          
    if bulletdir[bullet] == DIR_U
        bulletx[bullet] := tankx[tankindexvar]
        bullety[bullet] := tanky[tankindexvar]
          
    if bulletdir[bullet] == DIR_D
        bulletx[bullet] := tankx[tankindexvar]
        bullety[bullet] := tanky[tankindexvar] + tankh[tankindexvar] - 1
                      
    bullet++
    if bullet > BULLETSMASK
        bullet := 0

    audio.PlaySound(2+tankindexvar,40)


DAT 'LEVEL DATA


gfx_tiles_2b_poketron

word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $575d, $5515, $5d57, $d555, $45d5, $5557, $7551, $5d55
word    $4771, $dd1d, $cccf, $33f4, $4cf1, $d3cf, $3cd1, $771d, $f1f1, $0001, $7c7c, $0000, $f1f1, $0001, $7c7c, $0000
word    $31f1, $0000, $4c7c, $4000, $31f1, $0000, $4c7c, $4000, $575d, $5515, $5005, $4711, $0df0, $0f10, $01c0, $1300
word    $575d, $5515, $5005, $4711, $0df0, $0f10, $01c0, $1307, $575d, $5515, $5005, $4711, $0df0, $0f10, $11c0, $3307
word    $575d, $5515, $5d57, $d555, $45d5, $1557, $c151, $7c15, $575d, $1515, $c157, $7c15, $d7c1, $3d7c, $c3d7, $7c3d
word    $75d5, $5454, $d543, $543d, $43d7, $3d7c, $d7c3, $7c3d, $575d, $5515, $5d57, $d555, $45d5, $5554, $5d43, $543d
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $4001, $3ffc, $30cc, $3ffc, $4001, $5415, $5714, $1575
word    $5440, $5c4c, $fc0c, $0043, $1533, $57cf, $3c3f, $03ff, $0d15, $3335, $303f, $c340, $c354, $f3d4, $fc3c, $ffc0
word    $5535, $5535, $0cf3, $4010, $1145, $1555, $3ff3, $4404, $43c5, $1551, $f55c, $3554, $f554, $3554, $0ff4, $50c1
word    $f000, $1001, $c015, $0005, $0711, $0df0, $0f10, $11c0, $f00d, $100f, $c011, $0003, $0710, $0df0, $0f10, $11c0
word    $000d, $400f, $5c11, $5003, $4710, $0df0, $0f10, $11c0, $d7c0, $3d7c, $c3d4, $7c3f, $d7c0, $3d7c, $c3d4, $7c3f
word    $d7c3, $3d7c, $c3d7, $7c3d, $d7c3, $3d7c, $c3d7, $7c3d, $c3d7, $3d7c, $d7c3, $7c3d, $c3d7, $3d7c, $d7c3, $7c3d
word    $03d7, $3d7c, $17c3, $fc3d, $03d7, $3d7c, $17c3, $fc3d, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $015d, $5115, $0157, $5155, $f015, $0100, $5414, $5514, $0340, $5105, $0140, $5005, $f14f, $0000, $5555, $5555
word    $5740, $5545, $5d40, $d545, $540f, $0040, $1415, $1455, $5454, $5454, $fcfc, $0000, $5554, $5554, $fffc, $0000
word    $1455, $1455, $3cff, $0000, $1554, $1554, $3ffc, $0000, $3300, $0000, $c001, $7c15, $54dd, $7715, $4cf1, $5d55
word    $3300, $0000, $c003, $7c3f, $54dd, $7715, $4cf1, $5d55, $3300, $0000, $4003, $5c3f, $54dd, $7715, $4cf1, $5d55
word    $d7c3, $3d7c, $c3d7, $3c3d, $43c3, $543c, $0003, $fffc, $03c3, $003c, $1143, $1154, $1155, $1155, $1000, $03ff
word    $c3c0, $3c00, $c144, $1544, $5544, $5544, $0004, $ffc0, $c3d7, $3d7c, $d7c3, $7c3c, $c3c1, $3c15, $c000, $3fff
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $553c, $5500, $5514, $5514, $5500, $5514, $5514, $5514
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $3c55, $0055, $1455, $1455, $0055, $1455, $1455, $1455
word    $00ff, $1501, $3510, $0c54, $00d1, $000d, $0003, $0000, $5500, $4015, $0537, $45cc, $5300, $f000, $c000, $0000
word    $000d, $000f, $c011, $f003, $4710, $0df0, $0f10, $11c0, $f000, $1000, $c003, $000f, $0711, $0df0, $0f10, $11c0
word    $575d, $5515, $5005, $4711, $0df0, $0f10, $11c0, $3300, $0000, $0000, $4444, $4444, $0000, $0000, $1554, $0000
word    $1554, $0000, $0000, $0000, $0ccc, $3330, $1ddc, $5555, $0000, $3ffc, $355c, $355c, $03fc, $355c, $3ffc, $0000
word    $0000, $3ffc, $355c, $355c, $3fc0, $355c, $3ffc, $0000, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5500, $5514, $013c, $5100, $0050, $514c, $f00c, $0140, $5555, $5555, $0140, $5145, $0140, $5005, $f14f, $0000
word    $0055, $1455, $3c40, $0045, $0500, $3145, $1c0f, $0500, $0000, $0000, $0000, $0000, $4444, $1111, $4545, $5555
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $000d, $400f, $5c11, $5003, $4710, $0df0, $0f10, $11c0
word    $f000, $1001, $c015, $0005, $0711, $0df0, $0f10, $11c0, $0000, $4001, $5c17, $d4dd, $7715, $4cf3, $7551, $5d55
word    $0000, $5555, $5555, $5555, $5555, $5555, $0000, $ffff, $d73c, $3d00, $c314, $7c14, $d700, $3d14, $c314, $7c14
word    $3cd7, $007c, $14c3, $143d, $00d7, $147c, $14c3, $143d, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5540, $57cc, $fc3c, $00d0, $5470, $544c, $fc0c, $01c0
word    $355c, $dc37, $d007, $d007, $dc37, $dc37, $355c, $ffff, $0d15, $3335, $303f, $0340, $01d4, $3354, $343c, $0d00
word    $013c, $5100, $0114, $5114, $f000, $0100, $5414, $5514, $3c40, $0045, $1440, $1445, $000f, $0040, $1415, $1455
word    $5555, $5555, $5005, $4711, $0df0, $0f10, $11c0, $3300, $7fff, $f3ff, $cf77, $f5f3, $7dff, $555f, $7377, $5d7f
word    $ffcf, $ddff, $fffd, $f3f7, $f7dd, $fd57, $fd1d, $fff5, $0000, $1111, $5555, $1111, $0000, $0000, $0410, $0000
word    $d7c3, $3d7c, $03c0, $5005, $03c0, $5005, $f14f, $0000, $c3d7, $3d7c, $03c0, $5005, $03c0, $5005, $f14f, $0000
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5440, $5c4c, $fc0c, $0041, $1531, $57c5, $3c15, $0155, $5455, $5455, $fcff, $0000, $5554, $5554, $fffc, $0000
word    $0d15, $3335, $303f, $4340, $4354, $53d4, $543c, $5540, $1554, $4001, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $5555, $0000, $4001, $5c15, $54dd, $7715, $4cf1, $5555, $5555
word    $57f7, $577f, $7f7f, $f5f3, $4fdf, $5dff, $ff37, $ffff, $f5dd, $fd75, $7fdf, $c774, $fdf5, $cf57, $f7df, $ffff
word    $c3c0, $3c00, $c144, $7c04, $d7c0, $3d7c, $c3d4, $7c3f, $ffff, $0000, $ffff, $5555, $ffff, $0000, $ffff, $5555
word    $03c3, $003c, $1143, $103d, $03d7, $3d7c, $17c3, $fc3d, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $ffff, $5fff, $f5ff, $3f7f, $03df, $0cdf, $40f7, $5337
word    $ffff, $fff5, $ff5f, $fdfc, $f7c3, $f730, $df01, $dc05, $55d5, $5555, $0557, $c015, $0315, $f017, $7cc5, $dc05
word    $5d75, $5555, $0550, $c00c, $0cc0, $f00f, $5ff5, $f55f, $5d75, $5555, $5550, $d40c, $54c0, $540f, $503d, $5337
word    $575d, $5515, $5f57, $f555, $cdd5, $d5d7, $fd51, $fd55, $575d, $5515, $dd57, $f5d5, $4dfd, $71f7, $ff51, $fff7
word    $575d, $5515, $5d57, $d555, $45f5, $55d7, $7753, $5d5f, $03ff, $53ff, $03ff, $53ff, $f03f, $0100, $5414, $5514
word    $03c0, $53c5, $03c0, $5005, $f14f, $0000, $5555, $5555, $ffc0, $ffc5, $ffc0, $ffc5, $fc0f, $0040, $1415, $1455
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5037, $40f7, $0cdf, $c3df, $3f7f, $f5ff, $5fff, $ffff, $dcc5, $df01, $f730, $f7c0, $fdfc, $ff5f, $fff5, $ffff
word    $dcc5, $dc07, $7315, $7035, $7315, $7015, $dccd, $dc05, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff
word    $d037, $5337, $5c0d, $74cd, $540d, $54cd, $7037, $5337, $d75d, $7d15, $7fd7, $fcd5, $cdd5, $ffd7, $f751, $dd55
word    $f73f, $7fdc, $73ff, $cfff, $ff47, $dfff, $f7fd, $f33d, $577d, $5517, $5d77, $f77f, $47f7, $57cf, $75d7, $5fc7
word    $1144, $0140, $1144, $1004, $1144, $0140, $1144, $1004, $0410, $1144, $4551, $1554, $1554, $4551, $1144, $0410
word    $4444, $1111, $4444, $1111, $4444, $1111, $4444, $1111, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $ffff, $fc0f, $f153, $c554, $c554, $c55c, $cff3, $f00f, $dcc5, $7c05, $f015, $0315, $3017, $0555, $5555, $5d75
word    $f55f, $5ff5, $f00f, $0330, $3003, $0550, $5555, $5d75, $5037, $573d, $d40f, $54c0, $5503, $d550, $5555, $5755
word    $f7dd, $dd15, $5dd7, $f555, $c7d5, $5557, $7551, $5d55, $ff77, $7fdf, $cfdf, $dd73, $c5c7, $55f7, $755f, $5d55
word    $55ff, $553f, $5d5d, $d5ff, $45df, $5557, $7551, $5d55, $1004, $4144, $0140, $1444, $1504, $0004, $5150, $0000
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $1004, $1141, $0140, $1114, $1054, $1000, $0545, $0000
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555

mapTable_tiles_2b_poketron
word	@map_supercastle


map_supercastle
byte	 50,  50  'width, height
byte	108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108
byte	228,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,230
byte	168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,170
byte	168, 41,114,114, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114,114, 41,170
byte	168, 41,114,114, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114,114, 41,170
byte	168, 41, 41, 41, 41,170,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,168, 41, 41, 41, 41,170
byte	168, 41, 41, 41,182,183,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,181,182, 41, 41, 41,170
byte	168, 41, 41, 41,170,196,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,194,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,196,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,194,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,144,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,143,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,228,229,229,229,229,229,229,229,229,230,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41, 41, 41, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41,114, 41, 41, 41,114,114, 41,170,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,228,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,168, 41,114, 41, 41,114, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,115, 41,114, 41,114,114, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,115,115,115,115,115,115,115,115,115,115, 41, 41,115, 41, 41, 41,114,114, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,229,229,229,229, 41, 41, 41,114, 41, 41, 41, 41, 41, 41, 41,115,115,115,115,115,115,115,115,115,115, 41, 41,115, 41, 41, 41,114,114, 41,114, 41,170,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,155,156,157, 41, 41,115,115,115,115,115,115,115,115,115,115, 41, 41,155,156,157, 41,114, 41, 41,114, 41,170,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,168, 41,170, 41, 41,115,115,115,115,115,115,115,115,115,115, 41, 41,168, 41,170,114, 41, 41, 41,114, 41,170,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,181,182,183, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,181,182,183, 41, 41, 41, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,194,208,209,156,156,156,156,156,156,156,156,156,156,156,156,156,156,207,208,196, 41, 41, 41, 41,182,182,183,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,170,115,115,115,115,208,208,196,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,197,156,157, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,155,156,198, 41, 41, 41, 41, 41,170,196,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,168, 41,170,170, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,168, 41,170, 41, 41, 41, 41, 41,170,196,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,181,182,183,182,182,182,182,182,182,182,182,182,182,182,182,182,182,181,182,183, 41, 41,114, 41, 41,170,196,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,194,208,196,208,208,208,208,208,208,208,208,208,208,208,208,208,208,194,208,196, 41, 41,114, 41, 41,170,144,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,194,208,196,195,208,208,208,195,208,208,208,208,195,208,208,208,195,194,208,196, 41, 41,114, 41, 41,170,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,168, 41, 41,114, 41, 41,194,208,196,208,208,208,208,208,159,171,172,158,208,208,208,208,208,194,208,196, 41, 41,114, 41, 41,170,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,168, 41, 41,114, 41, 41,194,208,196,208,208,208,208,208,159, 57, 57,158,208,208,208,208,208,194,208,196, 41, 41,114, 41, 41,170,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,168,115,115,114,115,115,194,208,196,208,208,208,208,208,159, 57, 57,158,208,208,208,208,208,194,208,196,115,115,114,115,115,170,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,168,115,114, 41,114,115,207,208,209, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,207,208,209,115,114, 41,114,115,170,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,168,115, 41,114, 41,115,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,115, 41,114, 41,115,170,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,168,115,114, 41,114,115,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,115,114, 41,114,115,170,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,168,115,115,115,115,115, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,115,115,115,115,115,170,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,181,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,183,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,194,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,196,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,194,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,196,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,143,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,144,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41,170
byte	168, 41, 41, 41,156,230,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,228,156, 41, 41, 41,170
byte	168, 41, 41, 41, 41,170,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,168, 41, 41, 41, 41,170
byte	168, 41,114,114, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114,114, 41,170
byte	168, 41,114,114, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114,114, 41,170
byte	168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,170
byte	181,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,183
byte	194,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,196
byte	194,208,208,208,196,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,194,208,208,208,196

startlocations

byte	3
byte	3, 3
byte	47, 44
byte	46, 3










DAT 'SPRITE DATA

extremetank
{{
word    $40  'frameboost
word    $2, $2   'width, height
byte    $0, $1, $D6, $D6, $FE, $38, $FF, $E9, $0, $0, $1A, $12, $B7, $87, $B7, $85, $BF, $8D, $BF, $9, $DE, $D6, $0, $0, $D4, $D4, $FF, $39, $FF, $E8, $1E, $11
byte    $E4, $A4, $C3, $83, $C3, $80, $E3, $A1, $1C, $90, $0, $C0, $4, $E4, $D, $ED, $D, $ED, $5, $E4, $0, $C0, $4, $84, $C3, $83, $C3, $80, $E3, $A1, $FC, $B0
byte    $0, $1, $6F, $6F, $FF, $48, $17, $17, $38, $38, $7E, $66, $7E, $40, $7F, $41, $7F, $41, $7E, $40, $7E, $46, $38, $30, $7F, $5F, $FF, $48, $FF, $9F, $E0, $E1
byte    $F0, $A0, $F7, $A7, $F7, $A7, $F0, $A0, $0, $80, $0, $C0, $12, $92, $37, $A7, $37, $A1, $12, $92, $0, $C0, $0, $80, $F0, $A0, $F7, $A4, $F7, $A4, $F3, $A3
byte    $0, $3F, $80, $BF, $80, $87, $B0, $B1, $B6, $B0, $B6, $80, $B6, $80, $B2, $80, $B0, $80, $BD, $B5, $4F, $49, $EF, $D, $F6, $56, $F0, $11, $F0, $1F, $F0, $FF
byte    $0, $F8, $33, $DA, $4B, $C2, $93, $12, $B3, $A2, $83, $2, $83, $82, $93, $12, $B3, $A2, $83, $2, $80, $80, $97, $17, $B7, $A4, $47, $85, $37, $E4, $2, $F2
byte    $F0, $FF, $F0, $1F, $F0, $11, $F6, $56, $EF, $D, $4F, $49, $BD, $B5, $B0, $80, $B2, $80, $B6, $80, $B6, $80, $B6, $B0, $B0, $B1, $80, $87, $80, $BF, $0, $3F
byte    $2, $F2, $37, $E4, $47, $85, $B7, $A4, $97, $17, $80, $80, $83, $2, $B3, $A2, $93, $12, $83, $82, $83, $2, $B3, $A2, $93, $12, $4B, $C2, $33, $DA, $0, $F8
}}
extremethang
{{
word    $40  'frameboost
word    $2, $2   'width, height
byte    $4, $7, $F8, $3, $F8, $1, $9A, $2, $9A, $0, $FA, $0, $FA, $0, $6, $4, $6, $4, $FA, $0, $FA, $0, $9A, $0, $9A, $2, $F8, $1, $F8, $3, $4, $7
byte    $2, $FE, $1, $FC, $5, $FC, $D, $D8, $D, $18, $4D, $48, $2E, $28, $2A, $A8, $2A, $A8, $2E, $28, $4D, $48, $D, $18, $D, $D8, $5, $CC, $1, $EC, $2, $EE
byte    $4, $7, $0, $3, $0, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $0, $3, $4, $7
byte    $3, $EF, $2, $EE, $4, $CC, $C, $DC, $8, $18, $48, $48, $28, $28, $28, $A8, $28, $A8, $28, $28, $48, $48, $8, $18, $C, $DC, $4, $DC, $2, $FE, $3, $FF
byte    $0, $7, $4, $7, $E8, $1, $88, $0, $EC, $0, $EC, $0, $EC, $0, $EC, $0, $D8, $0, $F0, $A0, $E0, $E0, $0, $0, $0, $1, $0, $1, $0, $7, $0, $FF
byte    $1, $F7, $3, $F6, $7, $E4, $B, $E8, $B, $E8, $F, $88, $2F, $28, $6F, $68, $6F, $69, $2F, $2C, $9, $88, $8, $F8, $C, $FC, $4, $FC, $2, $FE, $0, $FF
byte    $0, $FF, $0, $7, $0, $1, $0, $1, $0, $0, $E0, $E0, $F0, $A0, $D8, $0, $EC, $0, $EC, $0, $EC, $0, $EC, $0, $88, $0, $E8, $1, $4, $7, $0, $7
byte    $0, $FF, $2, $FE, $4, $FC, $C, $FC, $8, $F8, $9, $88, $2F, $2C, $6F, $69, $6F, $68, $2F, $28, $F, $88, $B, $E8, $B, $E8, $7, $E4, $3, $F6, $1, $F7
}}
gianttank
{{
word    $90  'frameboost
word    $3, $3   'width, height
byte    $0, $FF, $0, $7F, $80, $BF, $C0, $BF, $C0, $BF, $80, $3F, $0, $3F, $C0, $DF, $0, $3, $0, $1, $24, $5, $24, $5, $24, $5, $24, $5, $0, $1, $0, $3
byte    $E0, $DF, $C0, $27, $0, $7, $FC, $FF, $F7, $F0, $FC, $3, $F8, $FF, $18, $E7, $0, $FF, $54, $54, $F8, $A8, $F8, $A8, $F9, $A9, $F9, $A9, $E0, $A0, $19, $19
byte    $43, $43, $2, $2, $5A, $5A, $22, $2, $22, $2, $5A, $5A, $2, $2, $43, $43, $19, $19, $C0, $80, $E0, $E0, $1F, $1F, $F, $F, $1F, $10, $FF, $EF, $0, $FF
byte    $0, $FF, $19, $99, $7F, $66, $7F, $66, $7F, $66, $7F, $66, $7F, $66, $19, $99, $0, $C0, $0, $C0, $3, $83, $3, $83, $3, $83, $3, $83, $0, $C0, $0, $C0
byte    $19, $99, $7F, $66, $7E, $66, $7F, $67, $71, $61, $7F, $67, $18, $98, $0, $FF, $0, $FF, $2, $3, $FF, $FF, $F8, $F8, $FF, $0, $FE, $FD, $0, $7F, $80, $BF
byte    $0, $7, $0, $3, $8, $B, $8, $B, $8, $B, $8, $B, $0, $3, $0, $7, $C0, $BF, $0, $7F, $0, $7F, $80, $7F, $80, $7F, $0, $7F, $0, $FF, $0, $FF
byte    $0, $9F, $70, $70, $8F, $8F, $87, $81, $8F, $88, $7F, $77, $E0, $80, $3, $3, $6, $6, $4, $4, $C4, $C4, $C4, $C4, $C4, $C4, $C4, $C4, $4, $4, $6, $6
byte    $3, $3, $F0, $A0, $F1, $A1, $F3, $A3, $F3, $A3, $F3, $A2, $58, $58, $0, $FF, $0, $FF, $19, $99, $7F, $66, $7E, $66, $7F, $66, $7F, $66, $7F, $66, $19, $99
byte    $0, $E0, $0, $E0, $1, $C1, $1, $C1, $1, $C1, $1, $C1, $0, $E0, $0, $E0, $19, $99, $7F, $66, $7F, $66, $7F, $66, $7F, $66, $7F, $66, $19, $99, $0, $FF
byte    $0, $FF, $0, $FF, $70, $5F, $78, $57, $7C, $5B, $70, $57, $70, $5F, $70, $5F, $70, $5F, $70, $5F, $70, $5F, $70, $5F, $78, $51, $78, $50, $71, $51, $71, $51
byte    $70, $50, $70, $51, $70, $5F, $70, $5F, $78, $57, $78, $57, $0, $FF, $0, $FF, $0, $FF, $80, $7F, $0, $7E, $80, $FE, $BF, $D5, $AA, $EA, $BE, $FE, $80, $FE
byte    $80, $FE, $80, $FE, $0, $3C, $5A, $42, $2A, $2A, $50, $50, $40, $40, $0, $0, $0, $0, $0, $0, $0, $38, $80, $FE, $81, $FD, $1, $7D, $80, $FF, $0, $FF
byte    $19, $D0, $3E, $88, $BA, $B2, $BA, $B2, $6, $4, $6, $4, $82, $82, $B2, $82, $3E, $34, $3E, $34, $82, $82, $82, $82, $7, $5, $37, $5, $BB, $B3, $BB, $B3
byte    $7, $5, $6, $4, $82, $82, $B2, $82, $3E, $34, $3E, $34, $44, $C4, $2B, $EB, $0, $FF, $0, $FF, $78, $57, $78, $57, $10, $1F, $50, $1F, $80, $81, $C0, $C0
byte    $41, $41, $41, $1, $C8, $80, $C8, $41, $D0, $9F, $90, $9F, $70, $5F, $70, $5F, $70, $5F, $70, $5F, $70, $57, $7C, $5B, $78, $57, $70, $5F, $0, $FF, $0, $FF
byte    $0, $FF, $80, $FF, $1, $7D, $81, $FD, $80, $FE, $0, $38, $1, $1, $0, $0, $0, $0, $40, $40, $50, $50, $2B, $2B, $5B, $42, $0, $3C, $80, $FE, $80, $FE
byte    $80, $FE, $BE, $FE, $AA, $EA, $BF, $D5, $80, $FE, $0, $7E, $80, $7F, $0, $FF, $2B, $EB, $44, $C4, $3E, $34, $3E, $34, $B2, $82, $82, $82, $6, $4, $7, $5
byte    $BB, $B3, $BB, $B3, $37, $5, $7, $5, $82, $82, $82, $82, $3E, $34, $3E, $34, $B2, $82, $82, $82, $6, $4, $6, $4, $BA, $B2, $BA, $B2, $3E, $88, $19, $D0
}}
happyface
{{
word    $40  'frameboost
word    $2, $2   'width, height
byte    $0, $7F, $60, $63, $42, $3, $E2, $E3, $42, $2, $E6, $E6, $E, $2, $7A, $60, $76, $60, $E, $2, $E6, $E6, $42, $2, $E2, $E3, $42, $3, $60, $63, $0, $7F
byte    $0, $F8, $8, $F8, $3E, $F2, $76, $C2, $EE, $82, $DC, $8C, $DA, $8A, $D8, $88, $D8, $88, $DA, $8A, $DC, $8C, $EE, $82, $76, $C2, $3E, $F2, $8, $F8, $0, $F8
byte    $0, $7F, $0, $3, $2, $3, $2, $3, $2, $2, $2, $2, $6, $6, $FE, $FE, $FE, $FE, $6, $6, $2, $2, $2, $2, $2, $3, $2, $3, $0, $3, $0, $7F
byte    $0, $F8, $8, $F8, $20, $E0, $40, $C0, $80, $80, $80, $80, $C0, $C0, $FF, $FF, $FF, $FF, $C0, $C0, $80, $80, $80, $80, $40, $C0, $20, $E0, $0, $F0, $0, $F8
byte    $1A, $61, $6E, $6E, $46, $6, $E2, $E2, $42, $2, $E2, $E2, $42, $2, $E2, $E2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $3, $4, $7, $78, $7F, $80, $FF
byte    $A, $FA, $D8, $88, $D8, $88, $DC, $84, $EE, $82, $F6, $C2, $FE, $E2, $E0, $E0, $C0, $C0, $80, $80, $80, $80, $80, $80, $40, $C0, $30, $F0, $8, $F8, $7, $FF
byte    $80, $FF, $78, $7F, $4, $7, $2, $3, $2, $2, $2, $2, $2, $2, $2, $2, $E2, $E2, $42, $2, $E2, $E2, $42, $2, $E2, $E2, $46, $6, $6E, $6E, $1A, $61
byte    $7, $FF, $8, $F8, $30, $F0, $40, $C0, $80, $80, $80, $80, $80, $80, $C0, $C0, $E0, $E0, $FE, $E2, $F6, $C2, $EE, $82, $DC, $84, $D8, $88, $D8, $88, $A, $FA
}}
moonman

{{
word    $40  'frameboost
word    $2, $2   'width, height
byte    $0, $FF, $30, $FF, $48, $C7, $48, $43, $30, $7, $32, $A7, $1E, $1D, $1F, $1, $1F, $0, $DF, $1, $1E, $3, $1C, $F, $10, $1F, $0, $FF, $0, $FF, $0, $FF
byte    $0, $FF, $0, $FF, $0, $FF, $0, $FE, $8, $FF, $18, $F6, $3F, $67, $3F, $20, $3F, $E0, $3B, $E1, $1B, $F0, $D, $C, $3, $7F, $0, $FD, $0, $E3, $0, $FF
byte    $0, $FF, $0, $FF, $0, $FF, $F0, $FF, $FC, $F, $FE, $3, $FF, $1, $FF, $0, $CF, $1, $BE, $B5, $3A, $B7, $30, $7, $70, $63, $70, $E7, $30, $FF, $0, $FF
byte    $0, $FF, $0, $E3, $0, $FD, $3, $7F, $7, $7, $1F, $FC, $3F, $FC, $3F, $F8, $6, $0, $3E, $76, $18, $F6, $8, $FF, $0, $FE, $0, $FF, $0, $FF, $0, $FF
byte    $0, $FF, $10, $97, $38, $2B, $38, $2F, $3A, $AF, $32, $A7, $17, $15, $1F, $18, $1F, $1, $DE, $1, $DE, $3, $9C, $7, $F8, $F, $F8, $3F, $10, $97, $0, $FF
byte    $0, $FF, $0, $FF, $8, $FE, $18, $F6, $18, $F7, $39, $E6, $39, $62, $3B, $20, $3B, $F0, $3D, $E0, $1F, $70, $E, $8, $5, $FC, $1, $E3, $0, $FF, $0, $FF
byte    $0, $FF, $10, $97, $F8, $3F, $F8, $F, $9C, $7, $DE, $3, $DE, $1, $1F, $1, $1F, $18, $17, $15, $32, $A7, $3A, $AF, $38, $2F, $38, $2B, $10, $97, $0, $FF
byte    $0, $FF, $0, $FF, $1, $E3, $5, $FC, $E, $8, $1F, $70, $3D, $E0, $3B, $F0, $3B, $20, $39, $62, $39, $E6, $18, $F7, $18, $F6, $8, $FE, $0, $FF, $0, $FF
}}






bulletgfx
word    $10  'frameboost
word    $1, $1   'width, height
byte    $0, $FF, $4, $C7, $2A, $AB, $1E, $9D, $3E, $B9, $5E, $D5, $3C, $E3, $0, $FF


heartgfx
word    $10  'frameboost
word    $1, $1   'width, height
byte    $0, $E1, $F, $CE, $1F, $9E, $3E, $39, $38, $39, $3F, $BE, $1F, $DE, $E, $E1

heartbox
byte    $0, $E1, $F, $CE, $1F, $9E, $3E, $39, $38, $39, $3F, $BE, $1F, $DE, $E, $E1       


teamlamelogo
word    $200  'frameboost
word    $10, $2   'width, height
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $8, $0, $8, $0, $8, $0, $8, $0, $F8, $0, $F8, $0, $8, $0, $8, $0, $8, $0, $8, $0, $0, $0, $B8, $0, $F8, $0, $48, $0, $48, $0, $48, $0, $48, $0, $48, $0, $48, $0, $48, $0, $48, $0, $0, $0, $0, $0, $80, $0, $E0, $0, $78, $0, $18, $0, $78, $0, $E0, $0, $80, $0, $0, $0, $0, $0, $F8, $0, $F8, $0, $F8, $0, $E0, $0, $80, $0, $0, $0, $80, $0, $E0, $0, $F8, $0, $F8, $0, $F8, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $F8, $0, $F8, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $80, $0, $E0, $0, $78, $0, $18, $0, $78, $0, $E0, $0, $80, $0, $0, $0, $0, $0, $F8, $0, $F8, $0, $F8, $0, $E0, $0, $80, $0, $0, $0, $80, $0, $E0, $0, $F8, $0, $F8, $0, $F8, $0, $0, $0, $B8, $0, $F8, $0, $48, $0, $48, $0, $48, $0, $48, $0, $48, $0, $48, $0, $48, $0, $48, $0, $0, $0, $8, $0, $38, $0, $8, $0, $0, $0, $38, $0, $8, $0, $30, $0, $8, $0, $30, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $7, $0, $7, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $3, $0, $7, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $6, $0, $7, $0, $1, $0, $0, $0, $0, $0, $0, $0, $1, $0, $7, $0, $6, $0, $4, $0, $7, $0, $7, $0, $0, $0, $3, $0, $7, $0, $6, $0, $7, $0, $3, $0, $0, $0, $7, $0, $7, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $3, $0, $7, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $0, $0, $4, $0, $6, $0, $7, $0, $1, $0, $0, $0, $0, $0, $0, $0, $1, $0, $7, $0, $6, $0, $4, $0, $7, $0, $7, $0, $0, $0, $3, $0, $7, $0, $6, $0, $7, $0, $3, $0, $0, $0, $7, $0, $7, $0, $0, $0, $3, $0, $7, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $4, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0



 'LAME LOGO
tanklogo

{{
word    $200  'frameboost
word    $10, $2   'width, height
byte    $0, $0, $0, $0, $C, $0, $C, $8, $4, $4, $0, $0, $C0, $C0, $E4, $64, $C, $C, $C, $8, $C, $8, $C, $0, $0, $0, $0, $0, $88, $0, $8C, $80
byte    $8C, $80, $C, $0, $C, $0, $C, $0, $8C, $80, $8C, $0, $FC, $0, $F8, $0, $0, $0, $0, $0, $F8, $E0, $FC, $0, $C, $0, $C, $0, $C, $8, $C, $8
byte    $C, $8, $4, $0, $84, $84, $C8, $48, $0, $0, $0, $0, $F8, $0, $F0, $0, $80, $0, $C0, $0, $E0, $80, $78, $40, $3C, $0, $C, $0, $C, $4, $C, $C
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $8C, $C, $8C, $C, $8C, $C, $8C, $8, $8C, $8, $8C, $8, $8C, $0, $8C, $0
byte    $FC, $0, $F8, $0, $0, $0, $0, $0, $88, $0, $8C, $0, $8C, $4, $88, $8, $80, $0, $80, $0, $84, $4, $8C, $8, $FC, $0, $F8, $0, $0, $0, $0, $0
byte    $C, $0, $C, $0, $C, $8, $C, $8, $4, $4, $4, $4, $C, $8, $C, $8, $C, $0, $C, $0, $0, $0, $0, $0, $0, $0, $4, $4, $C, $8, $C, $8
byte    $CC, $C0, $EC, $E0, $C, $0, $C, $0, $C, $0, $C, $0, $0, $0, $0, $0, $3C, $20, $1C, $10, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $F8, $0, $FC, $0, $8C, $0, $8C, $80, $C, $8, $C, $8, $4, $0, $4, $0, $4, $0, $C, $8, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1F, $0, $1F, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1F, $0, $1F, $0
byte    $1, $1, $1, $1, $0, $0, $0, $0, $0, $0, $1, $1, $1F, $18, $1F, $1E, $0, $0, $0, $0, $1C, $C, $19, $9, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $1F, $1, $1F, $0, $0, $0, $0, $0, $F, $F, $1F, $18, $3, $0, $1, $1, $0, $0, $0, $0, $0, $0, $C, $C, $1C, $4, $18, $8
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1F, $10, $1F, $10, $19, $18, $9, $9, $1, $1, $1, $1, $1, $1, $9, $9
byte    $1F, $1E, $F, $8, $0, $0, $0, $0, $1F, $0, $1F, $1C, $1, $0, $1, $0, $1, $0, $1, $0, $1, $0, $1, $0, $1F, $18, $1F, $10, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $1E, $E, $1F, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $1F, $1, $1F, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $E, $2, $1C, $4, $18, $0, $18, $10, $18, $10, $8, $0, $8, $0, $18, $10
byte    $18, $10, $18, $0, $0, $0, $0, $0, $F, $0, $1F, $0, $19, $0, $19, $0, $19, $11, $18, $10, $18, $10, $18, $18, $8, $8, $8, $8, $0, $0, $0, $0
    
         
'RANDOM PIC 2

}}
excitingtank

{{
byte    $40, $0, $0, $0, $C, $0, $C, $8, $4, $4, $0, $0, $C0, $C0, $E4, $64, $C, $C, $C, $8, $C, $8, $8C, $80, $0, $0, $0, $0, $88, $0, $8C, $80
byte    $8C, $80, $C, $0, $C, $0, $C, $0, $8C, $80, $8C, $0, $FC, $0, $F8, $0, $0, $0, $0, $0, $F8, $E0, $FC, $0, $C, $0, $C, $0, $C, $8, $C, $8
byte    $C, $8, $4, $0, $84, $84, $C8, $48, $0, $0, $0, $0, $F8, $0, $F0, $0, $80, $0, $C0, $0, $E0, $80, $78, $40, $3C, $0, $C, $0, $C, $4, $C, $C
byte    $0, $0, $0, $0, $0, $0, $40, $40, $0, $0, $0, $0, $4, $0, $0, $0, $C0, $C0, $E0, $60, $84, $4, $8C, $8, $8C, $8, $8C, $8, $8C, $0, $8C, $0
byte    $FC, $0, $F8, $0, $C0, $C0, $40, $40, $C8, $40, $EC, $60, $AC, $24, $88, $8, $80, $0, $80, $0, $84, $4, $8C, $8, $FC, $0, $F8, $0, $0, $0, $0, $0
byte    $2C, $20, $C, $0, $C, $8, $C, $8, $4, $4, $4, $4, $C, $8, $C, $8, $C, $0, $4C, $0, $0, $0, $80, $80, $80, $80, $4, $4, $C, $8, $C, $8
byte    $CC, $C0, $EC, $E0, $C, $0, $C, $0, $8C, $80, $C, $0, $0, $0, $0, $0, $3C, $20, $1C, $10, $0, $0, $0, $0, $0, $0, $0, $0, $80, $80, $88, $80
byte    $C0, $C0, $F0, $F0, $30, $30, $0, $0, $F8, $0, $FC, $0, $8C, $0, $8C, $80, $C, $8, $C, $8, $4, $0, $4, $0, $4, $0, $0, $0, $40, $40, $0, $0
byte    $0, $0, $0, $0, $20, $0, $0, $0, $0, $0, $0, $0, $1F, $0, $1F, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1F, $0, $1F, $0
byte    $1, $1, $1, $1, $0, $0, $0, $0, $0, $0, $1, $1, $1F, $18, $9F, $9E, $80, $80, $80, $80, $9C, $8C, $F9, $E9, $20, $20, $30, $30, $0, $0, $0, $0
byte    $0, $0, $0, $0, $1F, $1, $1F, $0, $0, $0, $0, $0, $8F, $8F, $9F, $98, $83, $80, $81, $81, $80, $80, $80, $80, $80, $80, $8C, $8C, $DC, $C4, $D8, $C8
byte    $C0, $C0, $C0, $C0, $60, $60, $60, $60, $60, $60, $70, $70, $38, $38, $38, $38, $3F, $30, $3F, $30, $39, $38, $39, $39, $2F, $2F, $7, $7, $3, $3, $9, $9
byte    $1F, $1E, $F, $8, $80, $80, $0, $0, $1F, $0, $1F, $1C, $1, $0, $1, $0, $1, $0, $81, $80, $81, $80, $81, $80, $9F, $98, $9F, $90, $80, $80, $C0, $C0
byte    $E0, $E0, $E0, $E0, $40, $40, $0, $0, $1E, $E, $1F, $1, $4, $4, $4, $4, $A, $A, $E, $E, $6, $6, $3, $3, $1, $1, $0, $0, $0, $0, $0, $0
byte    $1F, $1, $1F, $0, $80, $80, $C0, $C0, $E0, $E0, $60, $60, $B0, $B0, $0, $0, $E, $2, $1C, $4, $1A, $2, $5A, $52, $19, $11, $9, $1, $9, $1, $18, $10
byte    $18, $10, $18, $0, $0, $0, $0, $0, $F, $0, $1F, $0, $19, $0, $19, $0, $99, $91, $98, $90, $D8, $D0, $98, $98, $88, $88, $C0, $C0, $40, $40, $0, $0
byte    $80, $80, $0, $0, $C0, $C0, $80, $80, $0, $0, $0, $0, $22, $22, $0, $0, $50, $50, $40, $40, $60, $60, $70, $70, $72, $72, $70, $70, $70, $70, $18, $18
byte    $1C, $1C, $9C, $9C, $8C, $8C, $86, $86, $A7, $A7, $A3, $A3, $A3, $A3, $AF, $AF, $A3, $A3, $81, $81, $A0, $A0, $80, $80, $B0, $B0, $30, $30, $30, $30, $10, $10
byte    $28, $28, $6C, $6C, $7C, $7C, $7E, $7E, $4E, $4E, $7F, $7F, $D, $D, $C7, $C7, $66, $66, $77, $77, $27, $27, $3, $3, $23, $23, $33, $33, $21, $21, $0, $0
byte    $1, $1, $A0, $A0, $A0, $A0, $84, $84, $A0, $A0, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $82, $82, $80, $80, $80, $80, $88, $88, $80, $80, $80, $80
byte    $D0, $50, $D0, $50, $C8, $48, $C8, $48, $C8, $48, $C4, $44, $CC, $4C, $CC, $CC, $C7, $C7, $87, $87, $87, $87, $83, $3, $82, $2, $81, $1, $C9, $49, $C1, $41
byte    $C8, $C8, $C0, $C0, $C0, $C0, $84, $84, $80, $80, $90, $90, $D0, $D0, $C8, $C8, $CC, $4C, $C4, $44, $FE, $FE, $EE, $6E, $CE, $4E, $DC, $1C, $86, $86, $8E, $8E
byte    $A3, $23, $83, $3, $20, $20, $30, $30, $84, $4, $C0, $0, $E2, $2, $F2, $2, $FA, $2, $F8, $C0, $7C, $60, $3C, $30, $4C, $48, $EC, $E8, $F2, $F2, $F2, $F2
byte    $E2, $E2, $C8, $C8, $E0, $E0, $9C, $9C, $1C, $1C, $2E, $2E, $CF, $CF, $C7, $C7, $C3, $C3, $C3, $C3, $81, $81, $80, $80, $0, $0, $10, $10, $40, $40, $0, $0
byte    $F7, $F7, $E3, $63, $F3, $33, $F3, $33, $F9, $19, $FD, $D, $FC, $4, $FE, $2, $FE, $2, $FE, $2, $FE, $0, $7E, $0, $3F, $1, $1F, $1, $9F, $80, $8F, $80
byte    $8F, $80, $8F, $80, $F, $0, $F, $1, $F, $1, $1F, $1, $1F, $0, $1F, $0, $7F, $0, $FF, $0, $FF, $0, $FF, $1, $FF, $0, $FF, $1, $FF, $3, $FF, $3
byte    $FF, $3, $FF, $3, $FE, $2, $FE, $2, $FE, $2, $FE, $2, $F8, $0, $F8, $80, $F8, $10, $FA, $12, $F2, $F2, $C0, $C0, $8E, $8E, $1A, $1A, $70, $10, $F4, $84
byte    $B5, $25, $B9, $A9, $F9, $D1, $D9, $D1, $C9, $81, $EB, $AB, $DB, $9B, $F7, $A7, $B7, $7, $AF, $8E, $AF, $8C, $EF, $8C, $CF, $8C, $DF, $1E, $DF, $98, $9F, $90
byte    $BF, $3C, $3F, $34, $7F, $70, $FF, $F0, $FF, $F0, $FF, $D0, $FF, $F0, $FF, $C0, $FF, $80, $FF, $E0, $FF, $80, $FF, $0, $FF, $0, $FF, $C0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $1, $FF, $1, $FF, $1, $FF, $1, $FF, $1, $FF, $1, $87, $0, $7B, $60, $FD, $80, $FD, $80, $FD, $80, $FD, $80, $9D, $80
byte    $DD, $80, $1, $0, $5C, $5C, $DF, $0, $1F, $0, $1F, $0, $1F, $0, $1F, $0, $9F, $0, $3, $1, $1C, $0, $1D, $0, $FD, $80, $FC, $80, $FC, $80, $DC, $80
byte    $DD, $C1, $CD, $C1, $CE, $C0, $4E, $40, $7E, $40, $6, $0, $78, $0, $84, $0, $2, $0, $2, $0, $85, $1, $79, $1, $87, $87, $FE, $FE, $FC, $FC, $FC, $FC
byte    $FF, $1, $FF, $0, $FF, $1, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $C1, $0, $BE, $0, $63, $40, $63, $40, $BE, $0, $C1, $0, $F3, $10
byte    $C1, $0, $BE, $0, $63, $40, $63, $40, $7F, $40, $BE, $0, $C0, $80, $38, $38, $C0, $0, $E1, $0, $FF, $0, $FF, $0, $1F, $0, $F, $0, $8F, $0, $C7, $0
byte    $C7, $80, $C7, $80, $E7, $0, $E7, $0, $FF, $80, $FF, $E0, $FF, $E0, $7F, $6C, $7F, $78, $BF, $3F, $BF, $38, $DF, $1F, $DF, $1F, $EF, $F, $60, $0, $7F, $45
byte    $5F, $43, $5E, $5C, $82, $2, $D7, $17, $DF, $F, $6F, $0, $8F, $1, $E7, $2, $7, $3, $F7, $0, $F7, $1, $F6, $0, $F6, $2, $13, $3, $D3, $C3, $51, $41
byte    $57, $45, $57, $40, $57, $44, $16, $6, $76, $4, $B5, $1, $35, $1, $35, $1, $A3, $3, $9B, $2, $B7, $7, $67, $4, $6F, $D, $EF, $F, $DF, $1D, $9F, $1D
byte    $3F, $3F, $7F, $6E, $7F, $4C, $FF, $FC, $FF, $B4, $FF, $E0, $FF, $30, $FF, $0, $FF, $C0, $FF, $C0, $FE, $0, $FD, $1, $FD, $81, $1D, $1, $ED, $1, $F5, $1
byte    $F1, $1, $F0, $0, $C0, $0, $BF, $20, $76, $40, $E6, $80, $EE, $0, $DE, $0, $DF, $0, $DE, $0, $F0, $0, $88, $0, $75, $1, $F5, $1, $ED, $1, $DD, $1
byte    $DD, $1, $ED, $1, $80, $0, $80, $0, $B5, $0, $80, $0, $FC, $0, $FC, $0, $FF, $6, $FD, $4, $F8, $8, $FA, $A, $FB, $1B, $F7, $17, $F7, $37, $EF, $6F
byte    $FF, $C0, $FF, $F0, $FF, $60, $FF, $A0, $FF, $F8, $FF, $F0, $FF, $C0, $FB, $E0, $7B, $40, $7B, $60, $7B, $70, $77, $40, $37, $20, $B6, $20, $B5, $20, $82, $2
byte    $1A, $1A, $1B, $1A, $1B, $1A, $3, $2, $1B, $1A, $19, $19, $1A, $18, $83, $0, $DD, $18, $CD, $88, $EE, $C8, $EE, $4C, $E4, $44, $F0, $0, $9, $8, $D5, $15
byte    $D5, $1, $D5, $1, $D5, $1, $D5, $1, $D5, $1, $D4, $0, $D6, $0, $D6, $0, $D7, $0, $D7, $4, $D7, $4, $D7, $4, $D3, $2, $D3, $2, $D7, $17, $C7, $5
byte    $D1, $11, $AE, $AC, $1F, $10, $67, $60, $79, $40, $7E, $40, $7F, $40, $7F, $40, $0, $0, $7F, $7F, $7F, $40, $7F, $40, $FF, $C0, $FC, $80, $80, $80, $73, $70
byte    $6F, $68, $5F, $50, $5F, $50, $27, $20, $19, $0, $66, $0, $81, $0, $81, $0, $0, $0, $0, $0, $0, $0, $81, $0, $81, $0, $66, $0, $99, $0, $27, $21
byte    $6F, $43, $2F, $2, $AF, $82, $AE, $2, $AC, $0, $AD, $5, $AD, $D, $AD, $2D, $AD, $25, $9D, $1, $D9, $1, $D7, $6, $C7, $6, $C8, $8, $CF, $E, $9F, $E
byte    $8F, $88, $4F, $C, $5F, $1C, $DF, $18, $BE, $30, $B9, $31, $33, $22, $7, $4, $6F, $48, $6F, $40, $4F, $40, $5F, $50, $1F, $0, $1E, $0, $3D, $0, $BB, $80
byte    $B3, $80, $AF, $80, $CF, $80, $EF, $80, $FF, $80, $FF, $80, $FF, $C0, $FF, $F0, $FF, $80, $FF, $E0, $FF, $F0, $FF, $F0, $FF, $F0, $FF, $E0, $FF, $F0, $FF, $0
byte    $F9, $10, $FD, $11, $FD, $91, $FD, $31, $FD, $11, $FC, $10, $FE, $D0, $FE, $48, $FE, $44, $FF, $24, $FF, $24, $FF, $10, $FF, $90, $FF, $90, $FE, $90, $FE, $DA
byte    $FE, $6A, $FE, $6A, $FE, $22, $FF, $23, $FE, $12, $7E, $12, $7E, $4A, $7E, $2A, $7F, $6B, $FF, $5E, $FF, $3A, $FF, $28, $FF, $0, $F, $0, $F0, $F0, $FD, $81
byte    $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FB, $2, $FB, $2, $FB, $2, $FB, $2, $FB, $2, $FB, $2, $FB, $2
byte    $FB, $2, $FB, $3, $F8, $F8, $1, $1, $C1, $C1, $83, $83, $83, $83, $F, $F, $0, $0, $3, $3, $17, $17, $2F, $2F, $3E, $3E, $3E, $3E, $1E, $1E, $3E, $3E
byte    $3E, $3E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $3E, $3E, $2D, $2C, $2D, $2C, $D, $C, $E, $E, $86, $86, $2, $2, $2, $2, $40, $40
byte    $C2, $C0, $FF, $F0, $C0, $C0, $3B, $3B, $FB, $C2, $FB, $82, $FB, $82, $FB, $82, $FB, $82, $FB, $82, $FB, $82, $FB, $82, $FD, $80, $FD, $80, $FD, $80, $FD, $80
byte    $FD, $80, $FD, $81, $FD, $85, $FC, $84, $FC, $84, $E3, $82, $1F, $6, $F0, $0, $F7, $34, $F7, $34, $FF, $3C, $FF, $78, $F0, $70, $F7, $20, $F7, $0, $F6, $0
byte    $FE, $40, $FE, $40, $FE, $40, $FC, $20, $FD, $21, $FD, $21, $FD, $41, $F9, $21, $FB, $23, $FB, $23, $FB, $63, $FB, $43, $F3, $43, $F3, $C3, $F7, $C7, $F7, $7
byte    $FF, $6, $FF, $61, $F9, $21, $F8, $30, $FE, $10, $FF, $10, $FF, $18, $FF, $8, $FF, $C, $FF, $45, $3F, $22, $F, $1, $F, $1, $8F, $1, $CF, $0, $CF, $0
byte    $FF, $8, $FF, $8, $FF, $4, $FF, $4, $FF, $6, $FF, $2, $FF, $81, $FE, $40, $FE, $60, $FF, $20, $FF, $10, $FF, $18, $FF, $8, $FE, $0, $BE, $3A, $F0, $70
byte    $80, $0, $A8, $20, $A8, $20, $A8, $20, $A8, $20, $A8, $20, $A8, $20, $A8, $20, $A8, $20, $A9, $21, $A9, $21, $89, $1, $89, $1, $89, $1, $89, $1, $81, $1
byte    $C1, $C1, $F9, $79, $F4, $34, $FC, $3C, $FF, $1F, $F8, $F8, $FF, $3F, $FF, $3F, $F, $F, $1, $1, $1F, $1F, $3F, $1F, $3F, $1F, $FF, $1F, $FF, $3F, $E9, $29
byte    $FF, $FF, $FF, $3F, $FF, $3F, $FF, $3F, $FD, $1D, $FD, $1D, $F9, $19, $F3, $33, $C7, $7, $DE, $5E, $FE, $7E, $FC, $7C, $F8, $38, $F8, $38, $F1, $31, $F1, $71
byte    $E4, $64, $80, $0, $85, $5, $94, $14, $81, $1, $A1, $21, $A9, $21, $A9, $21, $A9, $21, $C9, $1, $C9, $1, $C9, $1, $C9, $1, $D4, $10, $D4, $10, $D4, $10
byte    $D4, $10, $E4, $0, $E4, $0, $E4, $0, $F0, $0, $FE, $20, $FE, $20, $FF, $20, $FF, $20, $FF, $20, $FF, $20, $BF, $20, $BF, $20, $3F, $27, $3F, $26, $7F, $2A
byte    $FF, $4A, $FF, $4A, $FF, $4A, $FF, $4A, $FF, $4A, $FE, $4A, $FC, $48, $FC, $4C, $FC, $44, $FF, $4, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0



}}




DAT 'SONG DATA

logoScreenSound
byte    NOTEON,0,72
byte    TIMEWAIT,8

byte    NOTEON,1,70
byte    TIMEWAIT,8

byte    NOTEON,2,68
byte    TIMEWAIT,8

byte    NOTEON,3,63
byte    TIMEWAIT,8

byte    NOTEON,4,51
byte    TIMEWAIT,7
byte    NOTEON,5,75
byte    TIMEWAIT,6
byte    NOTEON,6,87
byte    TIMEWAIT,5

byte    ENDOFSONG




titleScreenSong
byte    15     'number of bars
byte    28    'tempo
byte    8    'bar resolution

'ROOT BASS
byte    0, 36,SOFF,  36,SOFF,   34,  36,SOFF,  34
byte    1, 24,SOFF,  24,SOFF,   22,  24,SOFF,  22

'DOWN TO SAD
byte    0, 32,SNOP,  32,SOFF,   31,  32,SOFF,  31
byte    1, 20,SNOP,  20,SOFF,   19,  20,SOFF,  19 

'THEN FOURTH
byte    0, 29,SNOP,  29,SOFF,   27,  29,SOFF,  27
byte    1, 17,SNOP,  17,SOFF,   15,  17,SOFF,  15



byte    2,   48,SNOP,SOFF,  50, SNOP,SOFF,  51,SNOP
byte    2, SNOP,SOFF,  48,SNOP,   51,SNOP,  48,SNOP
byte    2,   53,SNOP,SNOP,  51, SNOP,SNOP,  50,SNOP
byte    2, SNOP,  51,SNOP,SNOP,   50,  51,  50,SNOP  

'melody
byte    2,   48,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP
byte    2, SNOP,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SOFF      

'harmonies
byte    3,   44,SNOP,SNOP,  43, SNOP,SNOP,  41,SNOP
byte    3, SNOP,  39,SNOP,SNOP,   38,SNOP,SNOP,SNOP
byte    3, SNOP,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SOFF  


'SONG ------

byte    0,BAROFF
byte    0,BAROFF
byte    0,BAROFF
byte    0,BAROFF
byte    0,1,BAROFF
byte    0,1,BAROFF
byte    0,1,BAROFF
byte    0,1,BAROFF

'verse 
byte    0,1,6,BAROFF
byte    0,1,7,BAROFF
byte    0,1,8,BAROFF
byte    0,1,9,BAROFF

byte    2,3,10,12,BAROFF
byte    2,3,13,BAROFF
byte    4,5,BAROFF
byte    4,5,11,14,BAROFF

'verse
byte    0,1,6,BAROFF
byte    0,1,7,BAROFF
byte    0,1,8,BAROFF
byte    0,1,9,BAROFF

byte    2,3,10,12,BAROFF
byte    2,3,13,BAROFF
byte    4,5,BAROFF
byte    4,5,11,14,BAROFF

byte    SONGOFF




DAT  'STRING DATA



'TANK NAMES
extremetankname         byte    "Tank Tock",0
extremethangname        byte    "Super Thang",0
gianttankname           byte    "Class XVI",0
happyfacename           byte    "Happy Face",0
moonmanname             byte    "Moon Man",0
  

'LEVEL NAMES
level0name              byte    "Moon Man's Lair",0
level1name              byte    "Wronskian Delta",0
level2name              byte    "Castle Destruction",0
'level3name              byte    "Hole",0
'level4name              byte    "Pokemon",0


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
