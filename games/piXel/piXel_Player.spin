' *********************************************************
'  Player
' *********************************************************
OBJ
    gfx     :   "LameGFX"
    map     :   "LameMap"
    
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
        
        
PUB TestPlayerCollision(x, y, w, h)
    return fn.TestBoxCollision(x, y, w, h, playerx, playery, word[gfx_player.Addr][1], word[gfx_player.Addr][2])

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