{{
MOD ATTACK!
------------------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
------------------------------------------------------------
}}

CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : "LameAudio"
    ctrl    : "LameControl"
    
VAR
    long    volume
    long    volume_inc
    long    volcount
    long    freq

PUB Main
    audio.Start
    ctrl.Start
    
    volume:= 1
    volume_inc := 1
    
    audio.SetWaveform(1, audio#_SAW)
    audio.SetVolumeSpeed(1, 100)    
    audio.SetEnvelope(1, 0)

    repeat
        ctrl.Update
               
        if ctrl.Up
            freq++
        if ctrl.Down
            freq--

        audio.SetFreq(1,freq)

        if ctrl.A
            volume_inc++
            
            volcount++ 
            if (volcount // volume_inc) > (volume_inc >> 1)
                volume := 127
            else
                volume := 0
            
            audio.SetVolume(1,volume)
        else
            volume_inc := 0
            audio.SetVolume(1,0)
           

    
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
