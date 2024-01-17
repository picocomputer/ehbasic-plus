# RP6502 - Enhanced EhBASIC Plus (EBP) - Experimental

For a stable version of EhBASIC for the RP6502 use the official:
https://github.com/picocomputer/ehbasic

Reference manual and more information archived here:<br>
http://retro.hansotten.nl/6502-sbc/lee-davison-web-site/enhanced-6502-basic/

You must have on your development system:
 * [VSCode](https://code.visualstudio.com/). This has its own installer.
 * A source install of [this CC65](https://github.com/picocomputer/cc65).
 * The following suite of tools for your specific OS.
```
$ sudo apt-get install cmake python3 pip git build-essential
$ pip install pyserial
```

# Initial plotting enhancements for the RP6502 Picocomputer's EhBASIC

Working plotting-enhancements coupled with the 12-14-Jan-2024 EhBASIC+save/load mods from the master picocomputer EhBASIC repo. 

Four new commands are available using EhBasic's "CALL" keyword. 
CALL addresses supplied are from the mapfile. 
Plotting command is callable from EhBASIC.

Two plotting screen dimensions are supported.
Either 80- or 40-column EhBASIC console is available. 

The commands are:

    * HGR,screen_dimension - initializes graphics screen mode
       * CALL HGR,0   - selects 320h x 180v x 8bpp mode (16:9 letterbox);
       * CALL HGR,$FF - selects 320h x 240v x 4bpp mode (4:3 fullscreen)
    * HPLOT,x,y,color - paint a pixel of 'color' at x,y on the screen.
    * TEXTMODE, 40 | 80 - return VGA-screen back to console/text mode
       * option of either 80- or 40-column EhBASIC console
    * CLS (or HOME) - clear the console/text screen.

Assumptions / Limitations / Notes:

    * HPLOT targets (only) the two screen-modes listed above on the rp6502's pico-VGA.
    * The x-coordinate from EhBasic is limited to values <= 255 (8-bits). This is a 
      limitation of parameters following the 'CALL' EhBASIC keyword.
    * EhBASIC's executable's origin-address: $C000.  
    * 48639-bytes reported available to the user.
