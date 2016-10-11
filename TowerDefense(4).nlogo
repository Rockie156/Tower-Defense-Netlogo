;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   TOWER DEFENSE V.4
;    TO DO: work on upgrade cost formula
;           create railgun
;           INFORMATION SECTION
;           Automatic Wave Spawns
;           Variety of enemies with sets of life/speed/shapes
;
;    Optional: Create universal maps (as in world size may be modified)
;              Have the interface display the amount of money needed to upgrade
;              *Activate Grammar! * (capitalizations)
;           
;    Bugs: None?
;
;    fixed: Enemies do not take an extra tick to turn
;          Cannon "splash" does not work
;           EnemySpeed affects ALL enemies vs. an individual enemy -- made into enemies-own variable
;           When a turret shoots, sometime an error occurs where a bullet which had a target no longer has a target - fixed with "carefully"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to cheat
ask enemies [die]
set money 10000
set life 1000
ask patch -14 15 [sprout-machineguns 100]
end

breed [Enemies Enemy]
Enemies-own [Energy EnemySpeed]

breed [MachineGuns MachineGun]
breed [bullets bullet]

breed [IceGuns IceGun]
breed [Icebullets icebullet]

breed [Cannons cannon]
breed [cannonballs cannonball]

Globals [currentlevel level life money target currentpath dead? ready?
         MGcounter MGrange MGrangelevel MGdamage Mgdamagelevel
         CannonCounter CannonRange CannonRangeLevel CannonDamage CannonDamageLevel
         IceGunCounter IceGunRange IceGunRangeLevel IceGunDamage IceGundamagelevel]

to Levels [x]
if ready?
 [if x > 0
    [if ticks mod spawntime = 0
      [wavespawn
      set level level - 1]
    ]
  if x = 0
  [set currentlevel currentlevel + 1
  set level currentlevel * 3
  set ready? false]
]
end

to setup
  crtpath
  set dead? false
  set ready? false
  set-default-shape Enemies "bug"
  set-default-shape IceGuns "IceGun"
  set-default-shape Icebullets "icebullet"
  set-default-shape MachineGuns "MachineGun"
  set-default-shape bullets "bullet"
  set-default-shape Cannons "cannon2"
  set life 100
  set money 1000
  set currentlevel 1
  set level currentlevel * 3
;  set level 100
  ;; upgradables
  ; --Mgsection
  set Mgdamage 4
  set MGdamagelevel 1
  set MGrangelevel 1
  set MGrange 5
  ; -- Icegun section
  set icegundamage 2
  set icegundamagelevel 1
  set icegunrangelevel 1
  set icegunrange 7
  ; --cannon section
  set CannonDamage 10
  set cannondamagelevel 1
  set cannonrange 10
  set cannonrangelevel 1
end

to crtpath
  ca
  if path = 1 [ ;; entry path
  ask patches with [pxcor = -12 and pycor < 16 and pycor > 13] [set pcolor red]
  
  ;; loop 1
  ask patches with [pxcor = -12 and (pycor <= 13 and pycor >= 11)] [set pcolor red]
  ask patches with [pycor = 11 and (pxcor > -12 and pxcor < 13)] [set pcolor red]
  ask patches with [pxcor = 12 and (pycor < 11 and pycor > 3)] [set pcolor red]
  ask patches with [pycor = 4 and pxcor <= 12 and pxcor >= -12] [set pcolor red]
  
  ;; loop 2
  ask patches with [pxcor = -12 and pycor < 5 and pycor >= -2] [set pcolor red]
  ask patches with [pycor = -2 and pxcor >= -12 and pxcor <= 12] [set pcolor red]
  
  ;; loop 3
  ask patches with [pxcor = 12 and pycor <= -3 and pycor >= -9] [set pcolor red]
  ask patches with [pycor = -9 and pxcor <= 12 and pxcor >= -12] [set pcolor red]
  ask patches with [pxcor = -12 and pycor < -9] [set pcolor red]
  
  ;; goals
  ask patches with [pxcor = -12 and pycor = -16] [set pcolor green]
  ask patches with [pxcor = -12 and pycor = 16] [set pcolor blue]
  ]
  if path = 2 [
  ask patches with [pxcor > -16 and pxcor <  8 and pycor = 12] [set pcolor red]
  ask patches with [pxcor = 7 and pycor < 12 and pycor > -8] [set pcolor red]
  ask patches with [pxcor > 6 and pxcor < 15 and pycor = -7] [set pcolor red]
  ask patch -15 12 [set pcolor blue]
  ask patch 15 -7 [set pcolor green]
  ]
  if path = 3 [
  ask patches with [pxcor = 0] [set pcolor red]
  ask patch 0 max-pycor [set pcolor blue]
  ask patch 0 min-pycor [set pcolor green]
  ]
end
  
;;;;;;;;;;;;;;;;;;;;; Creation Procedures
  
to WaveSpawn
ask patches with [pcolor = blue]    
  [sprout-Enemies 1 [
    if path = 1
      [set heading 180]
    if path = 2
      [set heading 90]
    if path = 3
      [set heading 180]
      set energy 100
      set enemyspeed 1
      set color green
    ]
  ]
end

to CreateMachineGun
  if mouse-down? [
    ask patch mouse-xcor mouse-ycor [       ;;;directly taken from mouse example
      if pcolor != black [stop]
      if any? other turtles-here [stop]
      if money < 100 [stop]
      set money money - 100
      sprout-MachineGuns 1 [
        set target one-of enemies in-radius MGrange
        if target != nobody [
          face target 
        ]
      ]
    ]
  ]
end

to createCannon
  if mouse-down? [
    ask patch mouse-xcor mouse-ycor [
      if pcolor != black [stop]
      if any? other turtles-here [stop]
      if money < 500 [stop]
      set money money - 500
      sprout-cannons 1 [
        set target one-of enemies in-radius cannonrange
        if target != nobody [
          face target
        ]
      ]
    ]
  ]
end

to createIceGun
  if mouse-down? [
    ask patch mouse-xcor mouse-ycor [
      if pcolor != black [stop]
      if any? other turtles-here [stop]
      if money < 100 [stop]
      set money money - 100
      sprout-iceguns 1 [
        set target one-of enemies in-radius IceGunRange
        if target != nobody [
          face target
        ]
      ]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;; Go procedures
  
to EnemyGo
ask Enemies [
  if ticks mod enemyspeed = 0 [
    ifelse [pcolor] of patch-ahead 1 != black 
      [fd 1]
      [if path = 1 [
        ifelse xcor > 0
          [set heading heading + 90
          fd 1]
          [set heading heading - 90
          fd 1]
       ]
     if path = 2 [
       ifelse ycor > 0 
         [set heading heading + 90
         fd 1]
         [set heading heading - 90
         fd 1]
      ] 
    ]
  ]
]
end

to Go
carefully [                      ;; carefully is used to ignore any bugs
if life = 0 [set dead? true]
if dead? [user-message word "Game Over!\nScore: " currentlevel setup]
levels level
if ticks >= 300 [reset-ticks]    ;; prevents ticks from going into the billions. Must be an even number divisible by 1, 2 and 3 to avoid skippiing of certain procedures.
  tick
  set MGcounter ticks
  if ticks mod 2 = 0
    [set IceGunCounter ticks]
  if ticks mod 5 = 0
    [set cannoncounter ticks]
  EnemyGo
  ask Enemies [
    if [pcolor] of patch-here = green [
      set life life - 1
      die
    ]
  ]
  DispEnemyEnergy
  ask MachineGuns [
    if (any? enemies) [                                     ;;this is a large check on the machine guns first, any? enemies
      if (target = nobody or distance target > MGrange) [   ;; now checks for any enemies close to the machine guns
        ifelse (any? enemies in-radius MGrange) [           ;; this then sets the target as one of those enemies 
          set target one-of enemies in-radius MGrange
          while [distance target > MGrange] [
            set target one-of enemies in-radius MGrange
          ]
        ] [
          if (target = nobody) [
            set target one-of enemies
          ]
        ]
      ]
      face target
      if distance target <= MGrange [    ;this checks if the bullets can go forward a total of x, otherwise it'll reappear on the other side
        MachineGunShoot
      ]
    ]
  ]
  ask bullets [die]
  ask IceGuns [
    if (any? enemies) [                                        ;; first checks for any enemies
      if (Target = nobody or distance target > IceGunRange) [  ;; then checks if there is a previous target
        ifelse (any? enemies in-radius IceGunrange) [
        set target one-of enemies in-radius IceGunRange
        while [distance target > Icegunrange] [
          set target one-of enemies in-radius icegunrange
          ]
        ] [
          if target = nobody [
            set target one-of enemies
          ]
        ]
      ]
      face target
      if distance target <= IceGunRange [
        IceGunShoot
      ]
    ]
  ]
  ask icebullets [die]
  ask cannons [
    if any? enemies [
      if target = nobody or distance target > cannonrange [
        ifelse (any? enemies in-radius cannonrange) [
          set target one-of enemies in-radius cannonrange
          while [distance target > cannonrange] [
            set target one-of enemies in-radius cannonrange
            ]
          ] [
            if target = nobody [
              set target one-of enemies
            ]
          ]
        ]
        face target 
        if distance target <= cannonrange [
          cannonshoot
        ]
      ]
    ]
    ask cannonballs [die]
    wait .1]
    [];; command2 in carefully -- not included unless you want to see the error message
end

to DispEnemyEnergy
  ifelse DisplayEnemyLife? [
    ask enemies
     [set label Energy]
  ] [
    ask enemies 
     [set label ""]
  ]
end

;;;;;;;;;;;;;;;;;;;;; Upgradables

to MGrangelevelupgrade
ifelse money >= MGrangelevel ^ 2 * 100
  [set money money - (MGrangelevel ^ 2 * 100)
  set MGrangelevel MGrangelevel + 1
  set MGrange MGrange + 1]
  [print "You don't have enough money!"]
end

to MGdamageupgrade
ifelse money >= MGdamagelevel ^ 2 * 100
  [set money money - (mgdamagelevel ^ 2 * 100)
  set mgdamagelevel mgdamagelevel + 1
  set MGdamage MGdamage + 1]
  [print "You don't have enough money!"]
end

to cannonrangelevelupgrade
ifelse money >= cannonrangelevel ^ 2 * 100
  [set money money - cannonrangelevel ^ 2 * 100
  set cannonrangelevel cannonrangelevel + 1
  set cannonrange cannonrange + 2]
  [print "You don't have enough money!"]
end

to cannondamageupgrade
ifelse money >= cannondamagelevel ^ 2 * 100
  [set money money - cannondamagelevel ^ 2 * 100
  set cannondamage cannondamage + 1
  set cannonrange cannonrange + 1]
  [print "You don't have enough money!"]
end

to IceGunRangeLevelUpgrade
ifelse money >= IceGunRangeLevel ^ 2 * 100
  [set money money - icegunrangelevel ^ 2 * 100
  set icegunrangelevel icegunrangelevel + 1]
  [print "You don't have enough money!"]
end

to IceGunDamageupgrade
ifelse money >= IceGunDamagelevel ^ 2 * 100
   [set money money - (icegundamagelevel ^ 2 * 100)
   set icegundamagelevel icegundamagelevel + 1
   set icegundamage icegundamage + 1]
   [print "you don't have enough money!"]
end

;;;;;;;;;;;;;;;;;;;;;; Shooting Commands

to MachineGunShoot
  if (not (any? other bullets-here) and any? enemies and ticks = MGcounter) [
    hatch-bullets 1 [
      if one-of enemies = nobody [die]
      set color gray
      let x MGrange * 2       ;this makes bullets go forward a total of 5 in "let x 5" with upgrades you can have let x range
      while [x > 0] [
        if any? enemies-here [
          ask one-of enemies-here [
            set energy energy - MGdamage
            if energy <= 0
             [set money money + 20
              die]
          ]
          die
        ]
        fd 0.5 wait .005 display
        set x x - 1
        if x = 0 [die]
      ]
    ]
  ]
  
  ask bullets
   [if not (any? enemies) [die]]
end

to IceGunShoot
  if (not (any? other icebullets-here) and any? enemies and ticks = IceGuncounter) [
    hatch-icebullets 1 [
      if one-of enemies = nobody [die]
      set color blue
      let x icegunrange * 2       ;this makes bullets go forward a total of 5 in "let x 5" with upgrades you can have let x range
      while [x > 0] [
        if any? enemies-here [
          ask one-of enemies-here [
            if not (enemyspeed >= 3)
              [set enemyspeed enemyspeed + 1]
            set energy energy - icegundamage                   
            if energy <= 0 [
              set money money + 20
              die
            ]
          ]
          die
        ]
        fd 0.5 wait .005 display
        set x x - 1
        if x = 0 [die]
      ]
    ]
  ]

  ask icebullets
  [if not (any? enemies) [die]]
end

to CannonShoot
  if (not (any? other cannonballs-here) and any? enemies and ticks = cannoncounter) [
    hatch-icebullets 1 [
      if one-of enemies = nobody [die]
      set color grey      let x cannonrange * 2
      while [x > 0] [
        if any? enemies-here [
          let y cannondamage
          while [y > 0]
            [ask enemies in-radius y
              [set energy energy - 1 if energy <= 0 [die]]
             set y y - 1]
          ask one-of enemies-here [
          set energy energy - cannondamage
          if energy <= 0 [
            set money money + 20
            die
          ]
        ]
        die
      ]
      fd .5 wait .005 display 
      set x x - 1
      if x = 0 [die]
    ]
  ]
]
ask cannonballs
  [if not (any? enemies) [die]]
end

@#$#@#$#@
GRAPHICS-WINDOW
205
10
644
470
16
16
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks

CC-WINDOW
5
601
1150
696
Command Center
0

BUTTON
6
10
91
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
969
554
1141
587
SpawnTime
SpawnTime
1
10
5
1
1
NIL
HORIZONTAL

BUTTON
90
10
175
43
NIL
WaveSpawn
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

MONITOR
116
199
173
252
NIL
Life
17
1
13

MONITOR
60
199
117
252
Level
CurrentLevel
17
1
13

BUTTON
6
41
91
74
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
4
250
173
283
Create Machine Gun
createMachineGun
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

MONITOR
4
199
61
252
NIL
Money
17
1
13

SWITCH
2
168
174
201
DisplayEnemyLife?
DisplayEnemyLife?
0
1
-1000

BUTTON
645
10
850
43
upgrade MG range
MGrangelevelupgrade
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

MONITOR
645
42
720
87
MG range
MGrange
17
1
11

BUTTON
4
282
173
315
NIL
CreateIceGun
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
1073
490
1136
523
NIL
cheat
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

MONITOR
719
42
850
87
Range Upgrade Amount
MGrangelevel ^ 2 * 100
17
1
11

BUTTON
645
84
850
117
Upgrade Ice Range
IceGunRangeLevelUpgrade
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
850
84
1091
117
Upgrade Ice Damage
IceGunDamageupgrade
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
850
10
1091
43
Upgrade MG damage
MGdamageupgrade
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

MONITOR
850
117
939
162
NIL
IceGunDamage
17
1
11

MONITOR
645
117
721
162
NIL
IceGunRange
17
1
11

MONITOR
938
117
1091
162
Damage Upgrade Amount
MGdamagelevel ^ 2 * 100
17
1
11

MONITOR
850
42
939
87
MG Damage
Mgdamage
17
1
11

MONITOR
720
117
850
162
Range Upgrade Amount
IceGunRangelevel ^ 2 * 100
17
1
11

BUTTON
4
314
173
347
NIL
CreateCannon
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
2
136
174
169
Path
Path
1
3
1
1
1
NIL
HORIZONTAL

BUTTON
1014
522
1141
555
NIL
set money 10000
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

MONITOR
938
42
1091
87
Damage Upgrade Amount
IceGundamagelevel ^ 2 * 100
17
1
11

BUTTON
645
162
850
195
Upgrade Cannon Range
CannonRangeLevelUpgrade
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
850
162
1091
195
NIL
CannonDamageUpgrade
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

MONITOR
720
194
850
239
Range Upgrade Amount
Cannonrangelevel ^ 2 * 100
17
1
11

MONITOR
645
194
721
239
NIL
CannonRange
17
1
11

MONITOR
848
194
937
239
NIL
CannonDamage
17
1
11

MONITOR
936
194
1091
239
Damage Upgrade Amount
Cannondamagelevel ^ 2 * 100
17
1
11

TEXTBOX
651
243
1085
418
Weapons Explanations:\n\nMachine Guns: Fire a continous stream of bullets at a rate of 1 bullet per tick.\n\nIce Guns: Fire Ice Bullets which not only slow down the enemy by 1 movement per tick (up to 3 ticks per movement) but also do a small amount of damage. They shoot once per 2 ticks.\n\nCannons: These do a large amount of damage and splash enemies for up to double damage on their current target and their current damage - distance of the detonation point. However, these shoot slowly at 1 shot per 5 ticks.
11
0.0
0

BUTTON
6
81
142
114
Ready to Proceed?
set ready? true
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

TEXTBOX
143
498
293
554
Your \"Level\" is the level you are currently on. It changes to the next as soon as the last enemy spawns.
11
0.0
1

@#$#@#$#@
WHAT IS IT?
-----------
This is a tower defense game. The enemies spawn at one point and move along a path until they reach their goal.  The objective of the game is to prevent the enemies from reaching the other end of the path by placing turrets which kill the enemy.  The enemy come in waves and get increasingly stronger, so you have to upgrade your towers to defend yourself better.  The game is over when you have lost all your lives.

HOW IT WORKS
------------

The enemies and turrets are both turtles.  The enemies spawn at a blue patch, and move along a red path of patches, and die at a green patch.  The enemies are turtles and they move along the red patch starting from the blue patch.  Once they reach the green patch, your life goes down until you reach 0 which is game over.  You must place turrets along the black patches to shoot at the enemies and kill them.  The enemies give money which is used to upgrade/build more towers.

HOW TO USE IT
---------------

Life
Life is the amount of lives you have.  You start with 100 and enemies that reach the green patch take away your life.  Once you reach 0, it's game over.
Level
Level is the level you are on.  Each time the level goes up, it gets harder and harder to kill the enemies.  They sometimes move faster and have more life.
Money 
Money is the amount of money you have You start of with 1000 and use it to place towers and upgrade their range or damage.  Killing enemies gives money and once you dont have enough money to build something, you would have to wait until you had more.
DisplayEnemyLife?
Enemies have a set life and they lose life when turrets attack them.  This is a switch to determine whether you want the enemy life to be seen or not be seen.
Create__________
These buttons create the tower.  The button goes on forever, so you can place as many towers as you want until you run out of money.  There are three different type of towers, ice tower, machine gun tower, and cannon tower.  
Upgrade Buttons
You can upgrade the range and damage of your turrets.  Each upgrade costs a different amount and each upgrade costs more than the one before it.  

THINGS TO NOTICE
----------------
The game gets exponentially harder due to the upgrade system and the enemy life upgrade system.  There are three levels, the easy, medium, and hard levels.  

THINGS TO TRY
-------------
See what level you can get up to before losing.  

Also try the different level modes.  Hard, which is basically a line, is nearly impossible to beat because the path is just a straight line.


CREDITS AND REFERENCES
----------------------
works used: 
Mouse Example (asking patch with mousedown)
Pac Man (Dead? variable)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

bullet
true
0
Circle -13345367 true false 120 120 60

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

cannon
true
0
Polygon -7500403 true true 165 0 165 15 180 150 195 165 195 180 180 195 165 225 135 225 120 195 105 180 105 165 120 150 135 15 135 0
Line -16777216 false 120 150 180 150
Line -16777216 false 120 195 180 195
Line -16777216 false 165 15 135 15
Polygon -16777216 false false 165 0 135 0 135 15 120 150 105 165 105 180 120 195 135 225 165 225 180 195 195 180 195 165 180 150 165 15

cannon1
true
0
Polygon -7500403 true true 90 240 210 240 225 195 75 195 90 240 75 195 120 195 120 90 150 30 180 90 180 195 180 270 120 270 120 180 105 90 120 90 195 90 180 180 240 180 210 270 180 285 120 285 105 270 75 255 60 180 120 180

cannon2
true
0
Circle -1 true false 73 73 152
Polygon -16777216 true false 120 75 120 165 180 165 180 75
Polygon -1 true false 150 45 105 75 195 75
Polygon -16777216 true false 120 135 90 165 210 165 180 135

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

icebullet
true
0
Circle -1 true false 120 120 60
Polygon -1 true false 180 150 195 105 150 120 105 105 120 150 105 195 150 180 195 195 180 150

icegun
true
0
Circle -1 true false 60 90 180
Rectangle -1 true false 135 45 165 105

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

machinegun
true
0
Circle -13345367 true false 45 75 210
Rectangle -13345367 true false 120 0 180 90

machineguntowe
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

missle
true
0
Polygon -1 true false 150 120 105 150 195 150
Polygon -16777216 true false 120 150 120 225 180 225 180 150
Polygon -1 true false 120 195 90 225 210 225 180 195 180 225 120 225
Polygon -1 false false 150 120 105 150 120 150 120 195 120 225 180 225 180 150 195 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

raygun
true
0
Circle -7500403 true true 60 105 180
Rectangle -7500403 true true 120 60 135 120
Rectangle -7500403 true true 165 60 180 120
Circle -7500403 true true 106 29 43
Circle -7500403 true true 152 27 43

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

@#$#@#$#@
NetLogo 4.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
