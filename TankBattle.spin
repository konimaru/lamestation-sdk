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
    pst     :               "LameSerial"
    ctrl    :               "LameControl"

VAR

    byte    levelw
    byte    levelh
    byte    currentlevel
    word    leveldata[LEVELS]
    word    levelname[LEVELS]
    word    tilemap
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
    gfx.Start(lcd.Start)
    pst.StartRxTx(WIFI_RX, WIFI_TX, 0, 115200)

    audio.Start
    ctrl.Start

    gfx.ClearScreen
    lcd.SwitchFrame

    InitData

    clicked := 0
    LogoScreen
    TitleScreen
    TankSelect
    LevelSelect                          
    TankFaceOff          



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
                pst.Char(UPDATEORDER) 

        else
              clicked := 0

        repeat while pst.RxCount > 0
           receivebyte := pst.CharIn
                    
           if receivebyte == UPDATEORDER
              yourtank := 1
              theirtank := 0

              choice := 0
              clicked := 1

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

              pst.Char(UPDATETYPE)
              pst.Char(yourtype) 
        else
            joyclicked := 0

      
        if ctrl.A or ctrl.B
          if not clicked
            choice := 0
            clicked := 1

            pst.Char(UPDATEADVANCE)
            
        else
          clicked := 0

        'MULTIPLAYER HANDLING
        repeat while pst.RxCount > 0
           receivebyte := pst.CharIn
                    
           if receivebyte == UPDATETYPE
              theirtype := pst.CharIn

           elseif receivebyte == UPDATEADVANCE
              choice := 0
              clicked := 1          
            


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

              pst.Char(UPDATELEVEL)
              pst.Char(currentlevel)
        else
            joyclicked := 0
              

        
        if ctrl.A or ctrl.B
          if not clicked
            choice := 0
            clicked := 1

            pst.Char(UPDATELEVEL)
            pst.Char(currentlevel)
            pst.Char(UPDATEADVANCE)
            
        else
          clicked := 0

        'MULTIPLAYER HANDLING
        repeat while pst.RxCount > 0
           receivebyte := pst.CharIn
                    
           if receivebyte == UPDATELEVEL
              currentlevel := pst.CharIn

           elseif receivebyte == UPDATEADVANCE
              choice := 0
              clicked := 1       


        gfx.Sprite(@tanklogo, 0, 0, 0, 1, 0)
        gfx.TextBox(string("Level:"),0,2)                  
        gfx.TextBox(levelname[currentlevel],5,2)

        'DRAW TILES TO SCREEN
        xoffset := 5
        yoffset := 2

        levelw := byte[leveldata[currentlevel]][0] 
        levelh := byte[leveldata[currentlevel]][1]
        
        DrawMap(tilemap,0,3,SCREEN_BW,5)


        
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

            pst.Char(UPDATEADVANCE)
        else
          clicked := 0  

        'MULTIPLAYER HANDLING
        repeat while pst.RxCount > 0
           receivebyte := pst.CharIn
                    
           if receivebyte == UPDATEADVANCE
              choice := 0
              clicked := 1   

     
    
PUB GameLoop : menureturn

    audio.StopSong
    audio.SetWaveform(4, 127)
    audio.SetADSR(127, 70, 0, 70)

    clicked := 0
    choice := 0                               
    repeat while not choice

        ctrl.Update
        lcd.SwitchFrame

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
                  if xoffset > levelw-SCREEN_BW
                      xoffset := levelw-SCREEN_BW


                      
              'UP AND DOWN   
              if ctrl.Up
                  yoffset-- 
                  if yoffset < 0
                      yoffset := 0  
              if ctrl.Down
                  yoffset++
                  if yoffset > levelh-SCREEN_BH
                      yoffset := levelh-SCREEN_BH  

               
              if ctrl.A or ctrl.B
                if clicked == 0
                  SpawnTank(yourtank, 0, 1)
                  tankspawned := 1      
                  
                  clicked := 1
              else
                clicked := 0
               




          'HANDLE OPPONENT TANKS
          UpdateHandler
       
          'DRAW TILES TO SCREEN
          DrawMap(tilemap,0,0,SCREEN_BW,SCREEN_BH)

          

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
          BulletHandler

          'HUD OVERLY
          StatusOverlay

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
    

PUB DrawMap(source, position_x, position_y, width, height)
       
    'DRAW TILES TO SCREEN           
    tilecnt := 0
    tilecnttemp := 2
    if yoffset > 0
      repeat y from 0 to yoffset-1
        tilecnttemp += levelw
    repeat y from yoffset to yoffset+height-1
        repeat x from xoffset to xoffset+width-1  
            tilecnt := tilecnttemp + x
            tile := (byte[leveldata[currentlevel]][tilecnt] & TILEBYTE) -  1
            gfx.Box(source + (tile << 4), x-xoffset+position_x,y-yoffset+position_y)

        tilecnttemp += levelw


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


PUB UpdateHandler

    'WIRELESS STUFF
    if tankoldx <> tankx[yourtank]
       pst.Char(UPDATETANKX)
       pst.Char(tankx[yourtank])

    if tankoldy <> tanky[yourtank]
       pst.Char(UPDATETANKY)
       pst.Char(tanky[yourtank])

    if tankolddir <> tankdir[yourtank]
       pst.Char(UPDATETANKDIR)
       pst.Char(tankdir[yourtank])

    if bulletspawned == 1
       pst.Char(UPDATEBULLETSPAWN)
       bulletspawned := 0

    if tankspawned == 1
       pst.Char(UPDATETANKSPAWN)
       pst.Char(respawnindex)
       tankspawned := 0

    if oldscore <> score[yourtank]
       pst.Char(UPDATESCORE)
       pst.Char(score[yourtank])


    repeat while pst.RxCount > 0
          receivebyte := pst.CharIn

          if receivebyte == UPDATETANKX
             tankx[theirtank] := pst.CharIn

          elseif receivebyte == UPDATETANKY
             tanky[theirtank] := pst.CharIn

          elseif receivebyte == UPDATETANKDIR
             tankdir[theirtank] := pst.CharIn

          elseif receivebyte == UPDATEBULLETSPAWN
             SpawnBullet(theirtank)

          elseif receivebyte == UPDATETANKSPAWN
             receivebyte := pst.CharIn
             SpawnTank(theirtank,receivebyte,0)

          elseif receivebyte == UPDATESCORE
             score[theirtank] := pst.CharIn

          elseif receivebyte == UPDATETANKDIED
             receivebyte := pst.CharIn
             tankon[receivebyte] := 0
                  
   
    

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
          

PUB BulletHandler

    repeat bulletindex from 0 to BULLETS-1
        if bulleton[bulletindex]

          if bulletdir[bulletindex] == DIR_L
             bulletx[bulletindex] -= BULLETINGSPEED
          
          elseif bulletdir[bulletindex] == DIR_R
             bulletx[bulletindex] += BULLETINGSPEED   
          
          elseif bulletdir[bulletindex] == DIR_U
             bullety[bulletindex] -= BULLETINGSPEED    
          
          elseif bulletdir[bulletindex] == DIR_D
             bullety[bulletindex] += BULLETINGSPEED  

          bulletxtemp := bulletx[bulletindex] - xoffset
          bulletytemp := bullety[bulletindex] - yoffset

          if (bulletxtemp => 0) and (bulletxtemp =< SCREEN_BW-1) and (bulletytemp => 0) and (bulletytemp =< SCREEN_BH - 1)            

          


             gfx.Sprite(@bulletgfx, bulletxtemp , bulletytemp, 0, 1, 0)


             repeat tankindex from 0 to TANKSMASK
                if tankon[tankindex]
                   collided := 1
                   if bulletx[bulletindex] < tankx[tankindex]
                       collided := 0
                   if bulletx[bulletindex] > tankx[tankindex]+tankw[tankindex]-1
                       collided := 0
                   if bullety[bulletindex] < tanky[tankindex]
                       collided := 0
                   if bullety[bulletindex] > tanky[tankindex]+tankh[tankindex]-1
                       collided := 0
              
                   if collided == 1
                       if tankhealth[tankindex] > 1
                           tankhealth[tankindex]--
                       else
                           tankon[tankindex] := 0
                           score[(tankindex+1) & TANKSMASK]++ 
                           pst.Char(UPDATETANKDIED)
                           pst.Char(tankindex)
                           
                       bulleton[bulletindex] := 0

             
          else
              bulleton[bulletindex] := 0




PUB StatusOverlay

   
    'STATUS HUD
    if tankon[yourtank] == 1   
        repeat x from 0 to ((tankhealth[yourtank]-1)) step 1
             if x < ((tankhealth[yourtank]-1)>>1)
                 gfx.Box(@heartbox, x>>1, 7)
             else
                 if x & $1 == 0
                     gfx.BoxEx(@heartbox, x>>1, 7, 3)
                 else
                     gfx.Box(@heartbox, x>>1, 7)


    intarray[0] := 48+(score[yourtank]/10)
    intarray[1] := 48+(score[yourtank]//10)
    intarray[2] := 0

    gfx.TextBox(@intarray, 0, 0)


    intarray[0] := 48+(score[theirtank]/10)
    intarray[1] := 48+(score[theirtank]//10)
    intarray[2] := 0

    gfx.TextBox(@intarray, 14, 0)


DAT 'LEVEL DATA

mapTable_tiles_2b_poketron
word    @map_supercastle

gfx_tiles_2b_poketron
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $24, $BF, $1, $FF, $0, $FD, $10, $FF, $1, $FF, $84, $EF, $40, $FF, $8
byte    $F7, $24, $AE, $A6, $DB, $19, $7D, $7C, $AB, $A9, $D7, $56, $EA, $C8, $B7, $26, $33, $0, $44, $44, $55, $55, $55, $11, $11, $0, $44, $44, $55, $55, $55, $11
byte    $11, $0, $44, $44, $55, $55, $55, $11, $11, $0, $44, $44, $11, $11, $CC, $0, $F, $0, $7, $1, $3B, $10, $51, $50, $FB, $A9, $3B, $30, $87, $0, $F, $0
byte    $8F, $80, $87, $1, $3B, $10, $51, $50, $FB, $A9, $3B, $30, $87, $0, $F, $0, $8F, $80, $87, $1, $3B, $10, $51, $50, $FB, $A9, $3B, $30, $C7, $80, $F, $0
byte    $FF, $24, $BF, $1, $FF, $0, $7D, $10, $7F, $1, $BF, $84, $AF, $80, $DF, $48, $DF, $44, $EF, $A1, $EF, $A0, $75, $50, $77, $51, $BB, $A8, $BB, $A8, $DD, $54
byte    $DD, $54, $BB, $A8, $BB, $A8, $77, $51, $75, $50, $EF, $A0, $EF, $A1, $DF, $44, $DF, $44, $BF, $81, $BF, $80, $7D, $10, $7F, $1, $FF, $44, $EF, $0, $FF, $8
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $B1, $0, $EE, $E, $EA, $8A, $8E, $E, $CA, $4A, $EA, $A, $EE, $E, $71, $0
byte    $F8, $F8, $E6, $E6, $D0, $D0, $AB, $A0, $B0, $A0, $77, $46, $77, $44, $27, $4, $7, $4, $77, $44, $77, $46, $B8, $A0, $BB, $BA, $C1, $C1, $E6, $E6, $F8, $F8
byte    $77, $44, $B3, $0, $6F, $47, $74, $44, $73, $40, $E7, $44, $73, $40, $8B, $0, $83, $0, $7D, $4, $7E, $40, $FF, $C1, $7F, $41, $7E, $40, $BE, $3C, $95, $14
byte    $1E, $0, $C, $0, $74, $20, $A0, $A0, $F0, $50, $70, $60, $83, $1, $5, $5, $F, $A, $3, $3, $74, $20, $A0, $A0, $F0, $50, $70, $60, $83, $1, $5, $5
byte    $F, $A, $3, $3, $74, $20, $A0, $A0, $F0, $50, $74, $64, $8C, $0, $1E, $0, $88, $88, $EE, $AA, $EE, $AA, $77, $55, $77, $55, $BB, $AA, $BB, $AA, $DD, $55
byte    $DD, $55, $EE, $AA, $EE, $AA, $77, $55, $77, $55, $BB, $AA, $BB, $AA, $DD, $55, $DD, $55, $BB, $AA, $BB, $AA, $77, $55, $77, $55, $EE, $AA, $EE, $AA, $DD, $55
byte    $DD, $55, $BB, $AA, $BB, $AA, $77, $55, $77, $55, $EE, $AA, $EE, $AA, $88, $88, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $1F, $4, $DF, $1, $DF, $0, $D, $0, $AF, $0, $C0, $0, $DA, $10, $DA, $10, $DA, $10, $DA, $10, $C0, $0, $D5, $0, $D7, $1, $C0, $0, $DA, $10, $DA, $10
byte    $DA, $10, $DA, $10, $C0, $0, $AF, $0, $F, $1, $DF, $4, $DF, $0, $1F, $8, $0, $0, $77, $44, $77, $44, $77, $44, $70, $40, $77, $44, $77, $44, $77, $44
byte    $7, $4, $77, $44, $77, $44, $77, $44, $70, $40, $77, $44, $77, $44, $0, $0, $FC, $0, $B8, $10, $F8, $40, $D0, $50, $A1, $21, $F8, $C8, $B9, $29, $FC, $4
byte    $FC, $C, $B8, $18, $F8, $48, $D0, $50, $A1, $21, $F8, $C8, $B9, $29, $FC, $4, $FC, $C, $B8, $18, $F8, $48, $D0, $50, $A1, $21, $F8, $C8, $B9, $21, $FC, $0
byte    $5D, $55, $AE, $AA, $AE, $AA, $97, $95, $97, $95, $AB, $8A, $AB, $8A, $B5, $85, $B5, $85, $BA, $82, $BA, $82, $BD, $81, $BD, $81, $0, $0, $7C, $0, $0, $0
byte    $0, $0, $7C, $0, $0, $0, $BD, $81, $BD, $81, $BA, $82, $BA, $82, $B5, $85, $B5, $85, $AB, $8A, $AB, $8A, $97, $95, $97, $95, $AE, $AA, $AE, $AA, $5D, $55
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $0, $0, $ED, $1, $ED, $1, $0, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $0, $0, $ED, $1, $ED, $1, $0, $0
byte    $73, $41, $29, $21, $1D, $1, $19, $11, $6, $0, $E, $8, $6, $4, $0, $0, $6, $4, $E, $8, $6, $4, $8, $8, $1D, $10, $D, $0, $31, $20, $7B, $60
byte    $F, $A, $3, $3, $74, $20, $A0, $A0, $F0, $50, $70, $60, $88, $8, $1C, $C, $1C, $C, $8, $8, $70, $20, $A0, $A0, $F0, $50, $70, $60, $83, $1, $5, $5
byte    $F, $0, $7, $1, $3B, $10, $51, $50, $FB, $A9, $3B, $30, $C7, $80, $F, $0, $0, $0, $4C, $0, $40, $0, $4C, $0, $40, $0, $4C, $0, $40, $0, $C, $0
byte    $80, $0, $D1, $50, $E1, $20, $D1, $50, $E1, $20, $D1, $50, $E1, $20, $80, $0, $0, $0, $7E, $7E, $7E, $52, $7E, $52, $7E, $52, $6E, $42, $6E, $6E, $0, $0
byte    $0, $0, $6E, $6E, $6E, $42, $7E, $52, $7E, $52, $7E, $52, $7E, $7E, $0, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $0, $0, $66, $64, $16, $4, $B0, $0, $AF, $0, $3, $0, $6B, $40, $6B, $40, $6B, $40, $6B, $40, $3, $0, $5F, $0, $5F, $0, $3, $0, $6B, $40, $6B, $40
byte    $6B, $40, $6B, $40, $3, $0, $2F, $0, $B0, $0, $D6, $44, $66, $24, $0, $0, $E0, $0, $D0, $0, $A0, $0, $D0, $0, $E0, $0, $D0, $0, $A0, $0, $D0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $F, $A, $3, $3, $74, $20, $A0, $A0, $F0, $50, $74, $64, $8C, $0, $1E, $0
byte    $1E, $0, $C, $0, $74, $20, $A0, $A0, $F0, $50, $70, $60, $83, $1, $5, $5, $FE, $24, $9C, $8, $FC, $20, $E8, $28, $D0, $10, $FC, $A4, $DC, $50, $FE, $8
byte    $BE, $80, $BE, $80, $BE, $80, $BE, $80, $BE, $80, $BE, $80, $BE, $80, $BE, $80, $0, $0, $ED, $1, $ED, $1, $0, $0, $77, $55, $BB, $AA, $BB, $AA, $DD, $55
byte    $DD, $55, $BB, $AA, $BB, $AA, $77, $55, $0, $0, $ED, $1, $ED, $1, $0, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $0, $0, $66, $66, $1C, $14, $BB, $8A, $83, $2, $77, $44, $77, $44, $77, $44
byte    $BE, $BE, $FF, $C1, $F3, $B2, $C1, $80, $C1, $80, $F3, $B2, $FF, $C1, $BE, $BE, $7, $4, $77, $44, $77, $46, $38, $10, $BB, $2A, $C1, $81, $66, $66, $0, $0
byte    $0, $0, $CD, $1, $CD, $1, $0, $0, $AF, $0, $C0, $0, $DA, $10, $DA, $10, $DA, $10, $DA, $10, $C0, $0, $AF, $0, $0, $0, $CD, $1, $CD, $1, $0, $0
byte    $F, $0, $7, $0, $3B, $10, $53, $50, $FB, $A8, $3B, $30, $C7, $80, $F, $0, $FF, $FF, $F7, $B3, $FF, $DF, $FF, $1B, $FF, $47, $BD, $95, $FB, $5B, $FF, $E
byte    $FF, $2B, $FF, $57, $FE, $8E, $BF, $9F, $FF, $9D, $F7, $E7, $FF, $FD, $FF, $FF, $E, $0, $4, $0, $4E, $0, $4, $0, $E, $0, $44, $0, $E, $0, $4, $0
byte    $69, $41, $6A, $42, $2, $2, $57, $15, $57, $15, $3, $2, $6B, $42, $69, $41, $69, $41, $6B, $42, $3, $2, $57, $15, $57, $15, $2, $2, $6A, $42, $69, $41
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $F8, $0, $E6, $6, $D0, $10, $AB, $20, $B0, $20, $77, $46, $77, $44, $27, $4, $7, $4, $77, $44, $77, $44, $77, $44, $70, $40, $77, $44, $77, $44, $77, $44
byte    $7, $4, $77, $44, $77, $46, $B8, $20, $BB, $3A, $C1, $1, $E6, $6, $F8, $0, $2, $0, $1, $0, $1, $0, $1, $0, $1, $0, $1, $0, $1, $0, $2, $0
byte    $80, $0, $80, $0, $80, $0, $80, $0, $80, $0, $80, $0, $80, $0, $80, $0, $FE, $0, $DC, $8, $FC, $20, $E8, $28, $D0, $10, $FC, $24, $DC, $10, $FE, $0
byte    $FF, $FF, $F7, $B6, $FF, $EF, $BF, $B9, $FF, $D7, $FF, $F4, $EF, $CC, $FF, $C8, $F7, $E4, $FF, $C5, $FF, $9A, $FF, $D5, $FF, $EC, $FF, $B6, $D7, $D7, $FF, $FB
byte    $80, $80, $EC, $A0, $E0, $A0, $75, $51, $75, $51, $BA, $AA, $BA, $AA, $DD, $55, $DD, $55, $DD, $55, $DD, $55, $DD, $55, $DD, $55, $DD, $55, $DD, $55, $DD, $55
byte    $DD, $55, $BA, $AA, $BA, $AA, $75, $51, $75, $51, $E0, $A0, $EC, $A0, $80, $80, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $FF, $FF, $3F, $FF, $CF, $7F, $77, $9F, $9B, $2F, $2B, $8F, $D, $C7, $5
byte    $D7, $15, $8F, $D, $2F, $2B, $1F, $1B, $7F, $77, $FF, $CF, $FF, $3F, $FF, $FF, $FF, $24, $FF, $0, $3F, $0, $47, $41, $17, $10, $C7, $C0, $E3, $60, $EB, $A8
byte    $E3, $A0, $EB, $A8, $C7, $41, $D7, $50, $C7, $40, $D7, $51, $E3, $A0, $EB, $A8, $E3, $A0, $EB, $68, $C7, $C1, $17, $10, $87, $80, $3F, $1, $FF, $0, $FF, $8
byte    $FF, $24, $BF, $1, $FF, $0, $FD, $30, $FF, $5, $FF, $D4, $EF, $C8, $FF, $F8, $FF, $A4, $BF, $11, $FF, $B0, $FD, $B8, $FF, $C1, $DF, $D4, $EF, $E8, $FF, $CC
byte    $FF, $E4, $BF, $81, $FF, $10, $FD, $30, $FF, $41, $FF, $84, $EF, $40, $FF, $8, $1F, $1F, $DF, $1F, $DF, $1F, $F, $F, $AF, $F, $C0, $0, $DA, $10, $DA, $10
byte    $DA, $10, $DA, $10, $C0, $0, $D7, $7, $D7, $7, $C0, $0, $DA, $10, $DA, $10, $DA, $10, $DA, $10, $C0, $0, $AF, $F, $F, $F, $DF, $1F, $DF, $1F, $1F, $1F
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $FF, $FF, $FC, $FF, $F3, $FE, $EE, $F8, $D8, $F4, $D4, $F1, $B0, $EB, $A8, $E3, $A0, $F1, $B0, $F4, $D4, $F9, $D9, $FE, $EE, $FF, $F3, $FF, $FC, $FF, $FF
byte    $FF, $2, $FF, $40, $3C, $8, $41, $41, $14, $14, $C3, $C3, $FF, $3C, $FF, $C3, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
byte    $FF, $C3, $FF, $3C, $C3, $C3, $28, $28, $82, $82, $3C, $4, $FF, $48, $FF, $1, $FF, $24, $BF, $1, $FF, $0, $FD, $3C, $F7, $65, $FF, $BE, $EF, $6E, $FF, $F9
byte    $FD, $3D, $FF, $EF, $EF, $ED, $7E, $6E, $FF, $FF, $7B, $3A, $F7, $D7, $FF, $F9, $FF, $FE, $FF, $29, $5F, $1D, $FD, $F0, $FF, $B9, $FF, $84, $EF, $48, $FF, $8
byte    $0, $0, $DD, $0, $0, $0, $77, $0, $77, $0, $0, $0, $DD, $0, $0, $0, $24, $0, $5A, $0, $BD, $0, $7E, $0, $7E, $0, $BD, $0, $5A, $0, $24, $0
byte    $AA, $0, $55, $0, $AA, $0, $55, $0, $AA, $0, $55, $0, $AA, $0, $55, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $C7, $C7, $BB, $A3, $7D, $41, $7D, $41, $7D, $41, $7B, $43, $87, $87, $FF, $FF, $FF, $10, $FF, $0, $FC, $80, $E1, $1, $E8, $8, $E3, $83, $D7, $16, $C7, $5
byte    $D7, $15, $C7, $5, $EB, $8A, $E3, $2, $EB, $A, $E3, $82, $D7, $15, $C7, $5, $D7, $15, $C7, $6, $E3, $3, $E8, $8, $F2, $82, $FE, $0, $FF, $0, $FF, $24
byte    $FF, $24, $BF, $1, $FF, $0, $FD, $15, $FF, $11, $FF, $86, $EF, $49, $FF, $1B, $FF, $7F, $F7, $46, $EF, $29, $FF, $36, $FF, $7, $FF, $8F, $EB, $43, $FF, $1D
byte    $FF, $3B, $BF, $1F, $FF, $B, $FD, $19, $FF, $0, $FF, $84, $EF, $40, $FF, $8, $0, $0, $3B, $0, $40, $0, $4E, $0, $56, $0, $18, $0, $59, $0, $42, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $42, $0, $59, $0, $18, $0, $56, $0, $4E, $0, $40, $0, $3B, $0, $0, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0

map_supercastle
byte     50,  50  'width, height
byte    108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108
byte    228,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,230
byte    168, 41, 41, 41, 41, 41, 41,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 41, 41, 41, 41, 41,170
byte    168, 41,114,114, 41, 41, 41,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 41, 41,114,114, 41,170
byte    168, 41,114,114, 41, 41, 41,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 41, 41,114,114, 41,170
byte    168, 41, 41, 41, 41,170,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,168, 41, 41, 41, 41,170
byte    168, 41, 41, 41,182,183,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,181,182, 41, 41, 41,170
byte    168, 41, 41, 41,170,196,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,194,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,196,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,194,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,144,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,143,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,228,229,229,229,229,229,229,229,229,230,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41, 41, 41, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41,114, 41, 41, 41,114,114, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,228,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,168, 41,114, 41, 41,114, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,115, 41,114, 41,114,114, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,115,115,115,115,115,115,115,115,115,115, 41, 41,115, 41, 41, 41,114,114, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,229,229,229,229, 41, 41, 41,114, 41, 41, 41, 41, 41, 41, 41,115,115,115,115,115,115,115,115,115,115, 41, 41,115, 41, 41, 41,114,114, 41,114, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,155,156,157, 41, 41,115,115,115,115,115,115,115,115,115,115, 41, 41,155,156,157, 41,114, 41, 41,114, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,168, 41,170, 41, 41,115,115,115,115,115,115,115,115,115,115, 41, 41,168, 41,170,114, 41, 41, 41,114, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,181,182,183, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,181,182,183, 41, 41, 41, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,194,208,209,156,156,156,156,156,156,156,156,156,156,156,156,156,156,207,208,196, 41, 41, 41, 41,182,182,183,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,170,115,115,115,115,208,208,196,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,197,156,157, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,155,156,198, 41, 41, 41, 41, 41,170,196,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,168, 41,170,170, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,168, 41,170, 41, 41, 41, 41, 41,170,196,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,181,182,183,182,182,182,182,182,182,182,182,182,182,182,182,182,182,181,182,183, 41, 41,114, 41, 41,170,196,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,194,208,196,208,208,208,208,208,208,208,208,208,208,208,208,208,208,194,208,196, 41, 41,114, 41, 41,170,144,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,194,208,196,195,208,208,208,195,208,208,208,208,195,208,208,208,195,194,208,196, 41, 41,114, 41, 41,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168, 41, 41,114, 41, 41,194,208,196,208,208,208,208,208,159,171,172,158,208,208,208,208,208,194,208,196, 41, 41,114, 41, 41,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168, 41, 41,114, 41, 41,194,208,196,208,208,208,208,208,159, 57, 57,158,208,208,208,208,208,194,208,196, 41, 41,114, 41, 41,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168,115,115,114,115,115,194,208,196,208,208,208,208,208,159, 57, 57,158,208,208,208,208,208,194,208,196,115,115,114,115,115,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168,115,114, 41,114,115,207,208,209, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,207,208,209,115,114, 41,114,115,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168,115, 41,114, 41,115,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,115, 41,114, 41,115,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168,115,114, 41,114,115,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,115,114, 41,114,115,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168,115,115,115,115,115, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,115,115,115,115,115,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,181,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,183,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,194,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,196,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,194,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,196,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,143,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,144,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,156,230,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,228,156, 41, 41, 41,170
byte    168, 41, 41, 41,  1,170,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,168, 41, 41, 41, 41,170
byte    168, 41,114,114,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 41, 41,114,114, 41,170
byte    168, 41,114,114,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 41, 41,114,114, 41,170
byte    168, 41, 41, 41,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 41, 41, 41, 41, 41,170
byte    181,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,183
byte    194,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,196
byte    194,208,208,208,196,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,194,208,208,208,196


 
startlocations
byte    3, 3
byte    47, 44










DAT 'SPRITE DATA


extremetank
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

extremethang
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

gianttank
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

happyface
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

moonman
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
excitingtank
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
