# Disassembler! Sort of a pun. Assembly
Disassembles enemy ships?!

-------------------------------------------------------------------------------------------------------------------------------------


xxxxxxx                                xxxxxxx               oooxxxx   xxxxxxx
 xxxxx                                  xxxxx                oxoxxx     xxxxx
  xxx                                    xxx                 oooxx       xxx
   x                                      x                     x         x

                                                              |
            xxxxxxx                                xxxxxxx                     xxxxxxx   xxxxxxx
            xxxxx                                  xxxxx                       xxxxx     xxxxx
            xxx                                    xxx                         xxx       xxx
            x                                      x                           x         x

                                                              |
                                xxxxxxx                                xxxxxxx                     xxxxxxx   xxxxxxx
                                xxxxx                                  xxxxx                       xxxxx     xxxxx
                                xxx                                    xxx                         xxx       xxx
                                x                             |        x                           x         x

                                                              |
                                                              |
                                                              |
                                                              0
                                                             000
                                                            00000
                                                           0000000
-------------------------------------------------------------------------------------------------------------------------------------

## Rules:
1. Game is like space invaders. Enemy ships will keep falling from the sky like 'tetris' at a slower pace.
2. Our ship will be at the bottom with a laser turret.

## Ship's capabilites -
1. One iota of laser will kaboom one pixel square areas of the enemy ship.
2. Firing speed can be altered.
3. The kaboom range can be altered.
4. The ship size and speed can be altered. Size can be proportional to the speed of the ship. You get to choose?
5. Type of ships.

## Enemy ship's capabilities - 
1. Simple: One hit one kill.
2. Extended: Player's ship has some health?
3. Degree of freedom is one in the beginning.

## Type of enemy ships - 
1. Small zombie thug ships, slow rate of fire (RoF) but large in number. High probability of spawning.
2. Mid size thug ships with larger turrets.
3. Extended: Boss ship with humongous size and multiple turrets ? Slow movement.
4. Simple: The enemy can be of various sizes? Round? Shapeless.

## Arena or game environment -
1. Simple: We can fix the player's ship and change the environment, enemies keep piling up like tetris.
2. Extended version (DLC?!): The player ship has four degree of freedoms and it can score points based on the number of enemy ships it wrecks!
3. Extended: Space mines? Environmental factors which can be used.

# MISC -
1. Player stats, high score!
2. Number of ships (lives).


## Resources -
http://employees.oneonta.edu/higgindm/assembly/video_games.htm
http://www.skynet.ie/~darkstar/assembler/tut6.html
http://www.wagemakers.be/english/doc/vga
http://www.gabrielececchetti.it/Teaching/CalcolatoriElettronici/Docs/i8086_and_DOS_interrupts.pdf
https://wiki.osdev.org/Drawing_In_Protected_Mode#Locating_Video_Memory
https://wiki.osdev.org/Printing_to_Screen
http://mikeos.sourceforge.net/write-your-own-os.html
https://www.codeproject.com/Articles/664165/Writing-a-boot-loader-in-Assembly-and-C-Part
http://faydoc.tripod.com/cpu/ Special directives
https://www.glamenv-septzen.net/en/view/6 why 0x7C00
http://www.ctyme.com/intr/int.htm interrupts all
https://montcs.bloomu.edu/Information/LowLevel/assembly64.pdf macro labels %%

https://wiki.osdev.org/Interrupt_Vector_Table IVT
https://nasm.us/doc/nasmdoc0.html HOLY GRAIL OF ASM LANG
https://www.daniweb.com/programming/software-development/threads/256108/problem-with-nasm-s-times-directive why remove .section segments
https://0x00sec.org/t/realmode-assembly-writing-bootable-stuff-part-1/2901 this awesome tutorial

https://www.partitionwizard.com/help/what-is-chs.html Cylinder-head-sector
https://www.pngfind.com/pngs/m/189-1896680_galaga-galaga-ship-hd-png-download.png
https://thestarman.pcministry.com/linux/bochsrc.bxrc.htm # bochs src file
https://www.cs.princeton.edu/courses/archive/fall06/cos318/precepts/bochs_tutorial.html # bochs startup setup tutorial

* structures
https://www.d.umn.edu/~gshute/asm/data-structures.xhtml 
https://www.csee.umbc.edu/courses/undergraduate/313/spring05/burt_katz/lectures/Lect10/structuresInAsm.html

* Timer IVT 1Ch
http://www.gpcet.ac.in/wp-content/uploads/2018/03/mpi-1-22.pdf
