                    ~~~~~ GOBLIN SLAYER ~~~~~
============================================================
              A CS50 Final Project by Thomson Brand
============================================================

HOW TO PLAY:
1. Download LOVE: https://love2d.org/
2. download this entire repo. (the .png file outside of spritesheets is not necessary, but everything else is.). Make sure everything is in one folder.
3. Drag the folder onto the LOVE application (or a shortcut to it). The game will immediately begin to run.
4. Have fun!

This is a simple 2D sidescrolling game made from the bones of the Mario assignment.
The objective is simply to slay as many goblins as you can!

Move the character across the screen with the left and right arrow keys.
The up arrow will make the character jump.

Pressing spacebar while standing still will draw back an arrow. Although your
character is an expert archer, he'll still need about half a second to draw back
before he can fire each arrow. He will continue to fire as long as he is standing
still with the spacebar pressed.

The goblins will come in waves. With each wave defeated, their numbers will
grow and they will speed up slightly. Take 3 hits and you're down for the count!

Each time you slay 10 goblins, a portion of your health will be replenished.
Something about goblin blood in large amounts magically boosts morale.

My current record is round 21 with 264 goblins slain. Can you beat my record?

Files:

Player.lua
Handles the player mechanics, including animations, health and damage. Pops you out of the game when you (inevitably) lose.

enemy.lua
Handles the goblins' mechanics. Provides animations to make them move and handles properly removing them from the game when they die.

projectile.lua
Handles projectile (i.e. the archer's arrows) animations. 

Map.lua
Brings everything together. Applies the spawning and battle mechanics specified in the player, enemy, and projectile classes to make the game work.

main.lua
Calls the map classes. Essentially just presses the 'play' button.

Animation.lua
An open-source class used on the Mario project which includes functions to better modularize animation.

Util.lua, class.lua, push.lua
Utility classes to assist in structuring the project.

3 .png spritesheet files, which contain the images for the background and animations.
1 image of the game-over screen for my current record. Try to beat it!

CREDITS: 
Music: Dino Run DX OST by Pixeljam (Digital album here: https://pixeljam.bandcamp.com/album/dino-run-dx-ost)
class.lua provided by Matthias Richter (https://github.com/bartbes/Class-Commons)
push.lua provided by Ulysse Ramage
Enemy spritesheet created by Stephen "Redshrike" Challener (https://opengameart.org/content/16x16-16x24-32x32-rpg-enemies-updated)
Player and map spritesheets are open assets from opengameart.org
