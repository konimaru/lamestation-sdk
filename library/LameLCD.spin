OBJ
    pin  :   "LamePinout"

CON
    ' LCD pins
    DI = pin#DI         ' data / instruction
    EN = pin#E          ' enable to send data
    
    DB = pin#D0         ' starting data bit
    
    CSA = pin#CSA       ' chip select a
    CSB = pin#CSB       ' chip select b
      
    LCDstart = DI
    LCDend   = CSB

    ' period
    SYNC_PERIOD = 80_000_000/73
    BUSY_PERIOD = 400
    
    ' screen size
    SCREEN_W = 128
    SCREEN_H = 64
    
    ' frame rate
    FULLSPEED = 40
    HALFSPEED = 20
    QUARTERSPEED = 10


    ' for internal use
    CMD_SETSCREEN     = $01F
    CMD_SETFRAMELIMIT = $022
    CMD_DRAWSCREEN    = $026
    CMD_INVERTSCREEN  = $036

PUB Start(buffer) 'must be long aligned
{{
    Initializes the LCD object.
    
    parameters
       buffer: source buffer (usually provided by LameGFX)
    
    result
       Aborts when any part of the initialization fails, otherwise returns
       the address of the screen buffer.
}}

    _draw := buffer
    ifnot cognew(@screen, @insn) +1
      abort

    Exec(CMD_SETSCREEN, 0)                              ' make sure cog is running
    longfill(@screen{0}, 0, 512)                        ' clear screen
    Exec(CMD_SETSCREEN, @screen{0})                     ' activate screen

    return @screen{0}


PUB Draw
{{
    Copy render buffer to screen buffer.
}}

    Exec(CMD_DRAWSCREEN, _draw)

PUB SetFrameLimit(frequency)
{{
    Set user-defined frame limit (0: off)
}}

    rate := clkfreq / frequency                         ' division by 0 is 0 in SPIN
    Exec(CMD_SETFRAMELIMIT, @rate)
    
PUB InvertScreen(enabled) ' boolean value
{{
    Invert black/white but leave gray untouched.
}}

    Exec(CMD_INVERTSCREEN, enabled <> 0)
    
PUB WaitForVerticalSync
{{
    Block execution until vertical sync pulse starts.
}}

    ifnot rate
        repeat
        until sync.byte{0}
        repeat
        while sync.byte{0}                              ' 1/0 transition

PRI Exec(command, parameters)

    command.word[1] := parameters
    insn := command
    repeat
    while insn

DAT                                                     ' DAT mailbox

insn                    long    0                       ' screen[-4]
sync                    long    0                       ' screen[-3]
_draw                   long    0                       ' screen[-2]
rate                    long    0                       ' screen[-1]

DAT                     org     0                       ' single screen LCD driver

screen                  jmpret  $, #setup               ' once

main                    movs    read, #line             ' reset
                        call    #translateLCD           ' flip data for this page

                        mov     eins, rcnt
                        or      eins, CMD_SetPage       ' chip select embedded
                        call    #sendLCDcommand         ' set page
                        
fill                    mov     ccnt, #64

                        mov     eins, scrn wz           ' |
read            if_nz   mov     eins, line              ' read data or black (detached)
                        add     $-1, #1                 ' |
                        
                        mov     zwei, eins
                        shr     zwei, #8

                        test    idnt, #%0_00000001 wc   ' even or odd frame?
                if_nc   and     eins, zwei              ' apply gray value
                        test    idnt, #%1_00000000 wc   ' inverse
                if_c    xor     eins, zwei
                        and     eins, dmsk              ' limit to valid pins
              
                        or      eins, CMD_WriteByte     ' chip select embedded
                        call    #sendLCDcommand         ' send data

                        djnz    ccnt, #read-1           ' for all columns

                        test    CMD_WriteByte, LCD_CE_L wz
                        xor     CMD_WriteByte, LCD_CE_B ' swap displays (L/R)
                if_nz   jmp     #fill                   ' |

                        cmp     rcnt, rmsk wz           ' check recently drawn page
                if_ne   jmp     #main                   ' for all pages

                        xor     idnt, #%0_00000001      ' toggle frame identifier
                        wrbyte  idnt, blnk              ' and announce it

                        rdlong  eins, par wz            ' fetch command
                if_nz   jmp     eins

reentry                 waitcnt LCD_time, LCD_frameperiod

                        jmp     #main                   ' next frame


cmd_scrn                shr     eins, #16               ' |
                        mov     scrn, eins              ' update display buffer

                        jmp     #done                   ' acknowledge command


cmd_rate                shr     eins, #16
                        rdlong  frqx, eins              ' get limit
                        mov     phsb, #0                ' reset counter

                        jmp     #done                   ' acknowledge command


cmd_draw                cmp     frqx, #0 wz             ' frame rate switched off?
                if_e    jmp     #:copy
                
                        cmp     frqx, phsb wz,wc
                if_a    jmp     #reentry                ' too early, block

                        test    idnt, #%0_00000001 wz
                if_nz   jmp     #reentry                ' only during 1/0 transitions

                        mov     phsb, #0                ' reset counter

:copy                   shr     eins, #16               ' source buffer
                        mov     zwei, scrn              ' destination
                        mov     drei, dst1              ' 512 longs

                        rdlong  vier, eins
                        add     eins, #4
                        wrlong  vier, zwei
                        add     zwei, #4
                        djnz    drei, #$-4              ' buffer copy

                        jmp     #done                   ' acknowledge command


cmd_invert              shr     eins, #16 wz            ' extract boolean payload
                        muxnz   idnt, #%1_00000000      ' update flags

done                    wrlong  zero, par               ' acknowledge command
                        jmp     #reentry
                                
' min enable pulse width: 450ns
' min address setup time: 140ns (before enable high)
'     min data hold time:  10ns
'
' cycle timing assumes 80MHz system clock

sendLCDcommand          mov     outa, eins              ' DI(RS), data, CSA/B

                        mov     cnt, cnt
                        add     cnt, #9{14} + BUSY_PERIOD
'                                     |            |
'                                     |            +----  covers busy period
'                                     +-----------------  (14+4)*12.5ns = 225ns

                        waitcnt cnt, #40                ' 500ns
                        or      outa, LCD_Enable

                        waitcnt cnt, #0
                        andn    outa, LCD_Enable

sendLCDcommand_ret      ret

' Given screen dimensions of 128x64 pixel and 2 bits/pixel we're looking at
' a linear buffer of 64*128*2 bits == 64*32 bytes == 2K. The LCD buffers needs
' the bytes effectively rotated by 90 deg.
'                                         
'    +---------------+---------------+    An 8x8 pixel block holds 16bytes or     
' R0 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    8 words. The LCD expects data to be     
'    +---------------+---------------+    formatted in a way that all 0 bits      
' R1 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    are delivered first starting with R0.0  
'    +---------------+---------------+    in bit position 0 and R7.0 in position  
' R2 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    7. This new byte is followed by column  
'    +---------------+---------------+    1 and so on until column F.             
' R3 |0 1 2 3 4 5 6 7|8 9 A B C D E F|                                            
'    +---------------+---------------+    To achieve this we scan all 16x8 blocks 
' R4 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    of the structure shown to the left. This
'    +---------------+---------------+    gives us outer and inner loop. Address  
' R5 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    offsets increment by 2 (word) for each
'    +---------------+---------------+    column and 8*32 == 256 for each row.    
' R6 |0 1 2 3 4 5 6 7|8 9 A B C D E F|
'    +---------------+---------------+
' R7 |0 1 2 3 4 5 6 7|8 9 A B C D E F|
'    +---------------+---------------+

translateLCD            add     rcnt, radv              ' 8 blocks of 8 rows
                        and     rcnt, rmsk wz

                if_z    mov     addr, scrn              ' |
                        movd    :set, #line             ' rewind
                
                        mov     ccnt, #16               ' 16 blocks of 8 columns

' read 8 words of an 8x8 pixel block (words are separated by a whole line, 32 bytes)
                        
:columns                rdword  xsrc+0, addr            ' load 8x8 pixel block
                        add     addr, #32
                        rdword  xsrc+1, addr
                        add     addr, #32
                        rdword  xsrc+2, addr
                        add     addr, #32
                        rdword  xsrc+3, addr
                        add     addr, #32
                        rdword  xsrc+4, addr
                        add     addr, #32
                        rdword  xsrc+5, addr
                        add     addr, #32
                        rdword  xsrc+6, addr
                        add     addr, #32
                        rdword  xsrc+7, addr

                        mov     bcnt, #8                ' scan 8 columns

:loop                   shr     xsrc+0, #1 wc           ' extract even column(s)
                        rcr     trgt, #1
                        shr     xsrc+1, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+2, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+3, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+4, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+5, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+6, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+7, #1 wc
                        rcr     trgt, #1

                        shr     xsrc+0, #1 wc           ' extract odd column(s)
                        rcr     trgt, #1
                        shr     xsrc+1, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+2, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+3, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+4, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+5, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+6, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+7, #1 wc
                        rcr     trgt, #17 -DB

                        xor     trgt, nmsk              ' invert odd columns

:set                    mov     line, trgt              ' store one pixel column
                        add     :set, dst1              ' advance destination

                        djnz    bcnt, #:loop

                        sub     addr, #32*7 -2          ' rewind loader, next 8 columns
                        djnz    ccnt, #:columns

                        add     addr, #256 -32          ' next 8 rows
translateLCD_ret        ret                             ' return

' initialised data and/or presets

LCD_time                long    SYNC_PERIOD
LCD_frameperiod         long    SYNC_PERIOD

CMD_DisplayOff          long    %11 << CSA | $3E << DB
CMD_DisplayOn           long    %11 << CSA | $3F << DB
CMD_SetAddress          long    %11 << CSA | $40 << DB  ' +0..63
CMD_SetPage             long    %11 << CSA | $B8 << DB  ' +0..7

CMD_WriteByte           long    %01 << CSA | $00 << DB | 1 << DI

LCD_CE_L                long    %01 << CSA
LCD_CE_B                long    %11 << CSA

LCD_Enable              long    1 << EN                                 

mask                    long    |< (LCDend +1) - |< LCDstart

frqx                    long    0                       ' frame rate limiter
scrn                    long    0                       ' active screen buffer
idnt                    long    0                       ' frame ID (even/odd) and misc flags
dst1                    long    |< 9                    ' dst +/-= 1

dmsk                    long    $00FF << DB
nmsk                    long    $FF00 << DB

rmsk                    long    $07 << DB
radv                    long    $01 << DB
rcnt                    long    $07 << DB               ' row counter 0..7

blnk                    long    4                       ' frame identifier

' Stuff below is re-purposed for temporary storage.

setup                   mov     dira, mask              ' drive outputs
                        add     blnk, par               ' @long[par][1]
                        add     LCD_time, cnt           ' finalize 1st frame target

                        movi    ctrb, #%0_11111_000     ' |
                        mov     frqb, #1                ' frame rate control
                        
                        mov     eins, CMD_DisplayOn     ' chip select embedded
                        call    #sendLCDcommand         ' turn on LCD

                        mov     eins, CMD_SetAddress    ' chip select embedded
                        call    #sendLCDcommand         ' reset address

                        jmp     %%0                     ' return

EOD{ata}                fit

' uninitialised data and/or temporaries

                        org     setup

addr                    res     1
trgt                    res     1

reuse                   res     alias

xsrc                    res     8
bcnt                    res     1
ccnt                    res     1

line                    res     128

tail                    fit

' aliases (different functions share VAR space)

                        org     reuse

eins                    res     1
zwei                    res     1
drei                    res     1
vier                    res     1

                        fit     tail
                        
{screen padding}        long    -1[0 #> (512 - (@EOD - @screen) / 4)]

CON
  zero  = $1F0                                          ' par (dst only)

  alias = 0
