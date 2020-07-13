# Disassembler

<a href="https://www.twitch.tv/markroxor" rel="Twitch Status">![Twitch](https://img.shields.io/twitch/status/markroxor?color=bluevoilet&style=for-the-badge)</a>


Game Development in assembly.  


![](https://github.com/markroxor/web-storage/raw/master/disassembler.gif)


A plug & play game in assmebly for i386 architecture. All you need is a -  
Microcontroller with i386 architecture and a display attached to it.

## Try running locally using qemu -
```shell
make clean && make run disassembler
```

## How to play - 
* Control the player ship using WASD to kill all the enemy ships in vicinity. 
* You level up when there are no more enemies on the screen left.
* Difficulty increases with levelling up, number of ships increase, their frequency of firing bullet increase but your ship's speed increases as well.
* If you lose press r to reset the game, starting with a new level 1.

## Maps
* Draw your own maps by editing disassembler/map*.bin files for each level.
* E represents location of enemy ship on map and P represents location of player ship on map. 

## Resource 
https://github.com/hackbacc/disassembler/raw/master/resources.md

## Known issues
* Screen flickers a bit.
* and many more which I dont know..

## Screenshots
![](https://github.com/markroxor/web-storage/raw/master/level1.png)
![](https://github.com/markroxor/web-storage/raw/master/level3.png)
![](https://github.com/markroxor/web-storage/raw/master/won.png)


