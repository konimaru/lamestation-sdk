CON                       
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

    DIR_L = 0
    DIR_R = 1
    DIR_U = 2
    DIR_D = 3
    
    LEVELS = 1
    LEVELSMASK = LEVELS-1
    
    GO_GAME = 1
    GO_MENU = 2
    
    PAUSEMENU1_CHOICES = 3
    
    WIFI_RX = 22
    WIFI_TX = 23


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
    lcd   : "LameLCD"
    gfx   : "LameGFX"
    txt   : "LameText"
    map   : "LameMap"
    audio : "LameAudio"
    music : "LameMusic"
    pst   : "LameSerial"
    ctrl  : "LameControl"
    fn    : "LameFunctions"

    font                        : "gfx_chars_cropped"
    
    gfx_tilemap                 : "gfx_tiles_2b_poketron"
    map_supercastle             : "map_supercastle"
    
    gfx_supertank               : "gfx_supertank"
    gfx_superthang              : "gfx_superthang"
    gfx_class16                 : "gfx_class16"
    gfx_happyface               : "gfx_happyface"
    gfx_moonman                 : "gfx_moonman"
    
    gfx_bullet                  : "gfx_bullet"
    gfx_heart                   : "gfx_heart"
    gfx_tankstand               : "gfx_tankstand"
    gfx_logo_teamlame           : "gfx_logo_teamlame"
    gfx_logo_tankbattle_name    : "gfx_logo_tankbattle_name"
    gfx_logo_tankbattle         : "gfx_logo_tankbattle"

    song_logo : "song_logo"
    song_tankbattle : "song_tankbattle"

VAR

    long    x
    long    y    
    long    tile
    long    tilecnt
    long    tilecnttemp





    byte    score[TANKS]
    byte    oldscore

    byte    yourtank
    byte    theirtank
    byte    yourtype
    byte    oldtype
    byte    theirtype
    byte    tankindex
    byte    levelindex


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
    lcd.Start(gfx.Start)
    gfx.Clear
    lcd.SetFrameLimit(40)
    pst.StartRxTx(31, 30, 0, 115200)

    audio.Start
    music.Start
    ctrl.Start

    gfx.Clear
    lcd.Draw

    txt.Load(font.Addr, " ", 8, 8)
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


' *********************************************************
'  Scenes
' *********************************************************   
PUB LogoScreen

    gfx.Clear
    lcd.Draw
    gfx.Clear
    gfx.Sprite(gfx_logo_teamlame.Addr, -2, 24, 0)
    lcd.Draw

    music.Load(song_logo.Addr)
    music.Play

    fn.Sleep(1500)

    music.Stop

PUB TitleScreen

    music.Load(song_tankbattle.Addr)
    music.Loop



    choice := 1
    repeat until not choice
        ctrl.Update
        lcd.Draw

        gfx.Blit(gfx_logo_tankbattle.Addr)

        if ctrl.A or ctrl.B
              if not clicked
                choice := 0
                clicked := 1
               
                yourtank := 0
                theirtank := 1
                pst.Char(UPDATEORDER) 

        else
              clicked := 0

        repeat while pst.Count > 0
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
        lcd.Draw       
        gfx.Clear

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
        {{
        repeat while pst.Count > 0
           receivebyte := pst.CharIn
                        
           if receivebyte == UPDATETYPE
              theirtype := pst.CharIn
    
           elseif receivebyte == UPDATEADVANCE
              choice := 0
              clicked := 1          
        }}


        gfx.Sprite(gfx_logo_tankbattle_name.Addr, 0, 0, 0)
        txt.Str(string("CHOOSE"), 48, 16)
           
        txt.Str(string("vs."),56,40)
                
        gfx.Sprite(gfx_tankstand.Addr, 20, 44, 0) 
        gfx.Sprite(gfx_tankstand.Addr, 86, 44, 0) 
            
        gfx.Sprite(tanktypegfx[yourtype], 24, 32, 3) 
        gfx.Sprite(tanktypegfx[theirtype], 88, 32, 2) 

        
        txt.Str(tanktypename[yourtype],0,24)
        txt.Str(tanktypename[theirtype],56,56)


PUB LevelSelect

    choice := 1
    joyclicked := 0
    repeat until not choice

        ctrl.Update
        lcd.Draw
        gfx.Clear      


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
        {{
        repeat while pst.Count > 0
           receivebyte := pst.CharIn
                    
           if receivebyte == UPDATELEVEL
              currentlevel := pst.CharIn

           elseif receivebyte == UPDATEADVANCE
              choice := 0
              clicked := 1       
              }}

        gfx.Sprite(gfx_logo_tankbattle_name.Addr, 0, 0, 0)
        txt.Str(string("Level:"),0,16)                  
        txt.Str(levelname[currentlevel],40,16)
        
        map.Load(tilemap,leveldata[currentlevel])
        map.DrawRectangle(xoffset, yoffset, 0, 24, 128, 64)

PUB TankFaceOff
         
    choice := 1
    repeat until not choice

        ctrl.Update 
        lcd.Draw        
        gfx.Clear

        gfx.Sprite(gfx_logo_tankbattle_name.Addr, 0, 0, 0)
        txt.Str(string("Prepare for battle..."),0,24)
     
        if ctrl.A or ctrl.B
          if not clicked
            choice := 0
            clicked := 1

            pst.Char(UPDATEADVANCE)
        else
          clicked := 0  

        'MULTIPLAYER HANDLING
        {{
        repeat while pst.Count > 0
           receivebyte := pst.CharIn
                    
           if receivebyte == UPDATEADVANCE
              choice := 0
              clicked := 1   
              }}


PUB GameLoop : menureturn

    music.Stop
    audio.SetWaveform(2,4)
    audio.SetWaveform(3,4)
    audio.SetADSR(2,127, 70, 0, 70)
    audio.SetADSR(3,127, 70, 0, 70)
  
    InitLevel

    clicked := 0
    choice := 0                               
    repeat while not choice

        ctrl.Update
        lcd.Draw
        gfx.Clear

        if tankon[yourtank]
            ControlTank 
            ControlOffset(yourtank)     
        else
            GhostMode
            
            
        'HandleNetworking
        map.Draw(xoffset,yoffset)

        DrawTanks
        HandleBullets
        HandleStatusBar

    menureturn := choice
    


PUB ControlTank
   
    tankoldx := tankx[yourtank]
    tankoldy := tanky[yourtank]
    tankolddir := tankdir[yourtank]
    oldscore := score[yourtank]

    ' Left/Right
    if ctrl.Left
       tankdir[yourtank] := 0        

       tankx[yourtank] -= tanktypespeed[yourtype]
        if tankx[yourtank] < 0
            tankx[yourtank] := 0
    if ctrl.Right
        tankdir[yourtank] := 1
    
        tankx[yourtank] += tanktypespeed[yourtype]
        if tankx[yourtank] > levelw<<3 - tankw[yourtank]
            tankx[yourtank] := levelw<<3 - tankw[yourtank] 


    ' map collision
    if map.TestCollision(tankx[yourtank], tanky[yourtank], tankw[yourtank], tankh[yourtank])
        tankx[yourtank] := tankoldx
    
    ' Tank-to-tank collision
    
    repeat tankindex from 0 to TANKSMASK
        if tankon[tankindex] and tankindex <> yourtank
            if fn.TestBoxCollision(tankx[yourtank], tanky[yourtank], tankw[yourtank], tankh[yourtank], tankx[tankindex], tanky[tankindex], tankw[tankindex], tankh[tankindex])
                tankx[yourtank] := tankoldx
    
    ' Up/Down
    if ctrl.Up
        tankdir[yourtank] := 2
        
        tanky[yourtank] -= tanktypespeed[yourtype]
        if tanky[yourtank] < 0
            tanky[yourtank] := 0
    if ctrl.Down
        tankdir[yourtank] := 3  

        tanky[yourtank] += tanktypespeed[yourtype]
        if tanky[yourtank] > levelh<<3 - tankh[yourtank]
            tanky[yourtank] := levelh<<3 - tankh[yourtank]
 
    ' map collision
    if map.TestCollision(tankx[yourtank], tanky[yourtank], tankw[yourtank], tankh[yourtank])
        tanky[yourtank] := tankoldy
        
    repeat tankindex from 0 to TANKSMASK
        if tankon[tankindex] and tankindex <> yourtank
            if fn.TestBoxCollision(tankx[yourtank], tanky[yourtank], tankw[yourtank], tankh[yourtank], tankx[tankindex], tanky[tankindex], tankw[tankindex], tankh[tankindex])
                tanky[yourtank] := tankoldy  
 
    if ctrl.A
      if not clicked
        clicked := 1
        tankhealth[yourtank]--
     
       ' choice := GO_MENU 'Go to menu
        
      '  yourtank++
       ' yourtank &= TANKSMASK

    elseif ctrl.B
        if tankon[yourtank] == 1
          SpawnBullet(yourtank)
          bulletspawned := 1
      
    else
        clicked := 0      

PUB GhostMode  
    if ctrl.Left
        xoffset--
        if xoffset < 0
            xoffset := 0 
    if ctrl.Right
        xoffset++
        if xoffset > levelw<<3-lcd#SCREEN_W
            xoffset := levelw<<3-lcd#SCREEN_W


    
    'UP AND DOWN   
    if ctrl.Up
        yoffset-- 
        if yoffset < 0
            yoffset := 0  
    if ctrl.Down
        yoffset++
        if yoffset > levelh<<3-lcd#SCREEN_H
            yoffset := levelh<<3-lcd#SCREEN_H  

     
    if ctrl.A or ctrl.B
      if clicked == 0
        SpawnTank(yourtank, 0, 1)
        tankspawned := 1      
        
        clicked := 1
    else
        clicked := 0    
    

PUB PauseMenu : menureturn

    choice := 0
    repeat while not choice
           
        ctrl.Update 
        lcd.Draw         
        gfx.Clear

        gfx.Sprite(gfx_logo_tankbattle_name.Addr, 0, 0, 0)
        txt.Str(string(" PAUSE!"),40,16)


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
          
        gfx.Sprite(gfx_bullet.Addr, 3, 4+menuchoice, 0)
        txt.Str(string("Return to Game"),4,4)
        txt.Str(string("Change Level"),4,5)
        txt.Str(string("Change Tank"),4,6)
        txt.Str(string("Give Up?"),4,7)


    if menuchoice == 1
        LevelSelect

    elseif menuchoice == 2
        TankSelect

    menureturn := GO_GAME



PUB InitData

    currentlevel := 0
    yourtype := 0
    theirtype := 1

    tilemap := gfx_tilemap.Addr

    leveldata[0] := map_supercastle.Addr
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

    tanktypename[0] := @gfx_supertankname   
    tanktypename[1] := @gfx_superthangname
    tanktypename[2] := @gfx_class16name
    tanktypename[3] := @gfx_happyfacename
    tanktypename[4] := @gfx_moonmanname

    tanktypegfx[0] := gfx_supertank.Addr
    tanktypegfx[1] := gfx_superthang.Addr
    tanktypegfx[2] := gfx_class16.Addr
    tanktypegfx[3] := gfx_happyface.Addr
    tanktypegfx[4] := gfx_moonman.Addr


    tanktypespeed[0] := 5
    tanktypespeed[1] := 10
    tanktypespeed[2] := 2
    tanktypespeed[3] := 6
    tanktypespeed[4] := 7

              
' *********************************************************
'  Levels
' *********************************************************  
VAR
    long    levelw
    long    levelh
    byte    currentlevel
    word    leveldata[LEVELS]
    word    levelname[LEVELS]
    word    tilemap
    
    long    xoffset
    long    yoffset
      
PUB InitLevel



    levelw := word[leveldata[currentlevel]][0] 
    levelh := word[leveldata[currentlevel]][1]

    'INITIALIZE START LOCATIONS         
    repeat tankindex from 0 to TANKSMASK
        score[tankindex] := 0 
        SpawnTank(tankindex, tankindex, 0)

    tankspawned := 0
    respawnindex := yourtank

    ControlOffset(yourtank)

    InitBullets
    InitTanks
    
    map.Load(tilemap,leveldata[currentlevel])

    

PUB ControlOffset(tankindexvar) | bound_x, bound_y

    bound_x := levelw<<3 - lcd#SCREEN_W
    bound_y := levelh<<3 - lcd#SCREEN_H
    
    xoffset := tankx[tankindexvar] + (tankw[tankindexvar]>>1) - (lcd#SCREEN_W>>1)
    if xoffset < 0
        xoffset := 0      
    elseif xoffset > bound_x
        xoffset := bound_x
                  
    yoffset := tanky[tankindexvar] + (tankh[tankindexvar]>>1) - (lcd#SCREEN_H>>1)
    if yoffset < 0
        yoffset := 0      
    elseif yoffset > bound_y
        yoffset := bound_y



              
' *********************************************************
'  Tanks
' *********************************************************
CON
    TANKS = 2   'must be power of 2
    TANKSMASK = TANKS-1
    
    TANKTYPES = 5 'must be power of 2
    TANKTYPESMASK = TANKTYPES-1
    
    TANKHEALTHMAX = 10
    
VAR

    long    tankgfx[TANKS]
    long    tankx[TANKS]
    long    tanky[TANKS]
    long    tankoldx
    long    tankoldy
    byte    tankolddir
    byte    tankstartx[TANKS]
    byte    tankstarty[TANKS]

    long    tankw[TANKS]
    long    tankh[TANKS]
    byte    tankdir[TANKS]
    byte    tankhealth[TANKS]
    byte    tankon[TANKS]

    long    tankxtemp
    long    tankytemp
    long    tankwtemp
    long    tankhtemp

    long    tanktypegfx[TANKTYPES]
    word    tanktypename[TANKTYPES]
    byte    tanktypespeed[TANKTYPES]


PUB InitTanks
    tankgfx[yourtank] := tanktypegfx[yourtype]
    tankgfx[theirtank] := tanktypegfx[theirtype]

    repeat tankindex from 0 to TANKSMASK
       tankw[tankindex] := word[tankgfx[tankindex]][1]
       tankh[tankindex] := word[tankgfx[tankindex]][2]
    
    

PUB SpawnTank(tankindexvar, respawnindexvar, respawnflag)
    if respawnflag == 1
       respawnindex := (respawnindex + 1) & TANKSMASK
       tankx[tankindexvar] := byte[map_supercastle.objAddr][(currentlevel<<2)+(respawnindex<<1)+0] <<3
       tanky[tankindexvar] := byte[map_supercastle.objAddr][(currentlevel<<2)+(respawnindex<<1)+1] <<3
    else
       tankx[tankindexvar] := byte[map_supercastle.objAddr][(currentlevel<<2)+(respawnindexvar<<1)+0] <<3 
       tanky[tankindexvar] := byte[map_supercastle.objAddr][(currentlevel<<2)+(respawnindexvar<<1)+1] <<3
    
    tankon[tankindexvar] := 1
    tankhealth[tankindexvar] := TANKHEALTHMAX
    tankdir[tankindexvar] := 0


PUB DrawTanks    
    repeat tankindex from 0 to TANKSMASK
        if tankon[tankindex]
            tankxtemp := tankx[tankindex] - xoffset
            tankytemp := tanky[tankindex] - yoffset
            tankwtemp := tankw[tankindex]
            tankhtemp := tankh[tankindex]        
                                                                                 
            if (tankxtemp => 0) and (tankxtemp =< lcd#SCREEN_W-tankw[tankindex]) and (tankytemp => 0) and (tankytemp =< lcd#SCREEN_H - tankh[tankindex])

                if tankdir[tankindex] == DIR_D
                    gfx.Sprite(tankgfx[tankindex], tankxtemp, tankytemp, 0)
                elseif tankdir[tankindex] == DIR_U       
                    gfx.Sprite(tankgfx[tankindex], tankxtemp, tankytemp, 1)
                elseif tankdir[tankindex] == DIR_L       
                    gfx.Sprite(tankgfx[tankindex], tankxtemp, tankytemp, 2)
                elseif tankdir[tankindex] == DIR_R       
                    gfx.Sprite(tankgfx[tankindex], tankxtemp, tankytemp, 3)




' *********************************************************
'  Networking
' *********************************************************  
CON
    'DECIDES WHO CLICKED TO INITIALIZE THE GAME
    'if this message is sent, you start in starting location 1.
    'if it's received by an opponent, you start in location 2.
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

PUB HandleNetworking

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


    repeat while pst.Count > 0
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
                  
   
' *********************************************************
'  Bullets
' *********************************************************      
CON 
    BULLETS = 20
    BULLETSMASK = BULLETS-1
    BULLETINGSPEED = 15
  
VAR
    word    bullet
    long    bulletx[BULLETS]
    long    bullety[BULLETS]
    byte    bulletspeed[BULLETS]
    byte    bulletdir[BULLETS]
    byte    bulleton[BULLETS]

    long    bulletxtemp
    long    bulletytemp
    word    bulletindex

PUB InitBullets
    bullet := 0
    repeat bulletindex from 0 to BULLETSMASK
        bulleton[bulletindex] := 0 
        bulletx[bulletindex] := 0
        bullety[bulletindex] := 0
        bulletspeed[bulletindex] := 0
        bulletdir[bulletindex] := 0
    bulletspawned := 0   
    

PUB SpawnBullet(tankindexvar)

    bulleton[bullet] := 1 
    bulletdir[bullet] := tankdir[tankindexvar]

    if bulletdir[bullet] == DIR_L
        bulletx[bullet] := tankx[tankindexvar]
        bullety[bullet] := tanky[tankindexvar]
          
    if bulletdir[bullet] == DIR_R
        bulletx[bullet] := tankx[tankindexvar] + tankw[tankindexvar] - 8
        bullety[bullet] := tanky[tankindexvar]
          
    if bulletdir[bullet] == DIR_U
        bulletx[bullet] := tankx[tankindexvar]
        bullety[bullet] := tanky[tankindexvar]
          
    if bulletdir[bullet] == DIR_D
        bulletx[bullet] := tankx[tankindexvar]
        bullety[bullet] := tanky[tankindexvar] + tankh[tankindexvar] - 8
                      
    bullet++
    if bullet > BULLETSMASK
        bullet := 0

    audio.PlaySound(2+tankindexvar,40)
          

PUB HandleBullets

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

          if (bulletxtemp => 0) and (bulletxtemp =< lcd#SCREEN_W-1) and (bulletytemp => 0) and (bulletytemp =< lcd#SCREEN_H - 1)
          
             gfx.Sprite(gfx_bullet.Addr, bulletxtemp , bulletytemp, 0)

             repeat tankindex from 0 to TANKSMASK
                if tankon[tankindex]
                    if fn.TestBoxCollision(bulletx[bulletindex], bullety[bulletindex], 8, 8, tankx[tankindex], tanky[tankindex], tankw[tankindex], tankh[tankindex])
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




PUB HandleStatusBar

   
    'STATUS HUD
    if tankon[yourtank]
        repeat x from 0 to (tankhealth[yourtank]-1)
            if x == (tankhealth[yourtank]-1)
                if x & 1
                    gfx.SetClipRectangle(0, 56, (x + 1) << 2 ,64) 
                else
                    gfx.Sprite(gfx_heart.Addr, x<<2, 56, 0)
            else
                if not x & 1
                    gfx.Sprite(gfx_heart.Addr, x<<2, 56, 0)
        gfx.SetClipRectangle(0, 0, 128,64)

    intarray[0] := 48+(score[yourtank]/10)
    intarray[1] := 48+(score[yourtank]//10)
    intarray[2] := 0

    txt.Str(@intarray, 0, 0)


    intarray[0] := 48+(score[theirtank]/10)
    intarray[1] := 48+(score[theirtank]//10)
    intarray[2] := 0

    txt.Str(@intarray, 112, 0)




DAT  'STRING DATA



'TANK NAMES
gfx_supertankname         byte    "Tank Tock",0
gfx_superthangname        byte    "Super Thang",0
gfx_class16name           byte    "Class XVI",0
gfx_happyfacename           byte    "Happy Face",0
gfx_moonmanname             byte    "Moon Man",0
  

'LEVEL NAMES
level0name              byte    "Moon Man's Lair",0
level1name              byte    "Wronskian Delta",0
level2name              byte    "Castle Destruction",0
'level3name              byte    "Hole",0
'level4name              byte    "Pokemon",0

