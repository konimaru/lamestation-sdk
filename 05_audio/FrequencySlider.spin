' 05_audio/FrequencySlider.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : "LameAudio"
    ctrl    : "LameControl"
    
VAR
    long    frequency

PUB Main
    audio.Start
    ctrl.Start
    
    frequency := 10000
    
    audio.SetVolume(0, 127)
    audio.SetVolume(1, 127)
    audio.SetVolume(2, 127)
    audio.SetVolume(3, 127)
    
    audio.SetEnvelope(0, 0)
    audio.SetEnvelope(1, 0)
    audio.SetEnvelope(2, 0)
    audio.SetEnvelope(3, 0)
    
    audio.SetWaveform(0, audio#_SINE)
    audio.SetWaveform(1, audio#_SQUARE)
    audio.SetWaveform(2, audio#_SAW)
    audio.SetWaveform(3, audio#_SINE)

    repeat
        ctrl.Update
        
        if ctrl.Left
            frequency -= 1
        if ctrl.Right
            frequency += 1

        audio.SetFreq(0, frequency)
        audio.SetFreq(1, frequency << 1)
        audio.SetFreq(2, frequency)
        audio.SetFreq(3, frequency >> 1)

