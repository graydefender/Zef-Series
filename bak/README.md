# Zef-Series
C64 Programming Tutorial Series

This is where I will be saving my source code for this tutorial series.  These programs were written using the CBM Prg Studio by Arthur Jordison.

Right now the source code consists of one basic program "zef.bas" and a few assembly language programs.

The first one "zef1.asm" was my first cut at converting the basic program into assembler.  The second one, "zef2.asm" is my optimized version.

The third one "zef3.asm" expands upon the second one adding a redefined character set with a shifting character to create that "water" effect.

There is a separate file "shifting.asm" which produces the shifting effect and interrupt in one source file.

"interrupt.asm" provides a quick example of one way to code a program interrupt on the Commodore 64.

"Window.asm" demonstrates a window scrolling technique.  "window2.asm" adds in text output into the mix.

In "zef4.asm" I integrate in the text printing program and text window scroll.

In "zef5.asm" I added borders and colors to the project.

In "zef6.asm" I added the player character, movement detection and "blocked" text.

In "zef7.asm" I added a couple sound effects.  Associated files are "SOUND_Move.asm" and "SOUND_Blocked.asm"

In "zef8.asm" I optimized some code segments.

In "zef9.asm" I added some code to load a new player map

In "zef10.asm" I expand upon zef9.asm further fleshing out the code adding a new map and allowing entry from hash tag and asterisk characters.

In "Zef11.asm" I implemented loading maps from disk.  This is the final version for this project.
