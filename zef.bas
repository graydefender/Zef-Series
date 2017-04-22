1000 rem ******************************************************
1020 rem * Glenn Cline
1040 rem * 04/07/2015
1060 rem * Zefeldar .01 basic version (the precursor)
1080 rem * This program will display information
1100 rem * from a viewport section of a string array
1120 rem * Then take input allowing the user to 'move' up
1140 rem * down, left or right. q to stop
1160 rem * the code will allow the viewport to wrap back around
1180 rem * in any direction.
1200 rem * a$ is the string array containing the entire 'map'
1220 rem * xx and yy are the width of the 'viewport'
1240 rem * cx,cy are the starting position, top left corner of the
1260 rem * 'viewport' within the string array
1280 rem * dx,dy are physical starting position on screen, top left corner of the
1300 rem * viewport on the c64 screen.  Adjust these variables to move
1320 rem * the information displayed on the screen
1340 rem * This basic code is slow which is why it needs to rewriten
1360 rem * in asembly, using this code as a framework.
1370 rem * All positions starting with '0'
1380 rem *******************************************************
1390 print chr$(147)
1400 dim a$(10)
1420 a$(0)="graydefenderttttttttccccccccccddddddddddffffffffff"
1440 a$(1)="testingoooggggggggggeeeeeeeeeerrrrrrrrrroooooooooo"
1460 a$(2)="helloworldyyyyyyyyyyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxo"
1480 a$(3)="baaaaxxooojjjjjjjjjjxxiixxiixxxxxxxxxxxiiixxxxiixo"
1500 a$(4)="noxxxxxxooooooooooooiiixxxxxixaaaaaaxxxxxxxxxxxxxo"
1520 a$(5)="wooxxxxooommmmmmmmmmxxxxxxxxxxxxxxxiiiiiiiixxxxxxo"
1540 a$(6)="aooooooooxooooooooonxxxxxxxxxxxxxxxixxxxxxixxxxxxo"
1560 a$(7)="soooooooxxxxooooooowxxxxxxxxxxxxxxxixxxxxxixxxxxxo"
1580 a$(8)="aooooooxoooxooooooofxxxxxxxxxxxxxxxixxxxxxixxxxxxo"
1600 a$(9)="booooooxxxxxooooooocxxxxxxxxxxxxxxxxxxxxxxixxxxxxo"
1620 y=40
1640 xx=8
1660 yy=8
1680 cx=0
1700 cy=1
1720 dx=5
1740 dy=5
1750 wd=50
1760 gosub 1940
1780 a=peek(197)
1790 rem a, s =left and right w,z=up and down q=quit
1800 if a=10 then cx=cx-1:gosub 1940
1820 if a=13 then cx=cx+1:gosub 1940
1840 if a=9 then cy=cy-1:gosub 1940
1860 if a=12 then cy=cy+1:gosub 1940
1880 if a=62 then stop
1900 goto 1780
1910 rem
1920 rem
1940 if cy<0 then cy=9
1960 if cx<0 then cx=wd
1970 if cx>wd then cx=0
1975 if cy>9 then cy=0
1980 offset=1024+(dy*y)+dx-1
2000 for j=0 to yy-1
2020     ny=j+cy
2040     if ny>9 then ny=ny-10
2060     for i=1 to xx
2080        nx=i+cx
2100        if nx>wd then nx=nx-wd
2120        poke offset+i,asc(mid$(a$(ny),nx,1))-64
2140     next i
2160     offset=offset+y
2180 next j
2200 return















