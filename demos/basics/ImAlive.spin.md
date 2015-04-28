
This tutorial demonstrates that the Propeller itself is

alive by blinking a connected LED. It verifies that the crystal oscillator is working too.

We can use the `Pinout` object to get the pin that the LED is on.

    OBJ
        pin : "Pinout"

    CON
        LED_PIN = pin#LED

Set some arbitrary delay. 1000 seems like a friendly number. You'll see if you use some different values. 1000 is long enough to see, short enough that you're not going to be waiting for it.

        LED_PERIOD = 1000

    PUB Main

There are three commands that allow you to interact with the world on your Propeller. These are `ina`, `outa`, and `dira`.

A register sounds exciting but it's not. There's 32 pins on the Propeller, and there's 32 switches in each of these registers.

WHAT'S A REGISTER? THIS IS TOO LOW-LEVEL; NOT BASIC AT ALL

        dira[LED_PIN]~~

Let's set up an infinite loop forever. In Spin, that's super easy. Just use the `repeat` command.

        repeat

There are a few commands that make working with external pins possible. i

            outa[LED_PIN]~

Sometimes you really just want the microcontroller to just WAIT for something else to happen, but sometimes you don't really care how long. For a quick and dirty delay, I usually just like to call a `repeat` for a certain amount of time.

            repeat LED_PERIOD

            outa[LED_PIN]~~

            repeat LED_PERIOD