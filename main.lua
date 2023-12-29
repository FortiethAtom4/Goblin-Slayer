

Class = require 'class'
push = require 'push'

require 'Animation'
require 'Map'
require 'enemy'
require 'Player'

-- close resolution to NES but 16:9
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- actual window resolution
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- seed RNG
math.randomseed(os.time())

-- makes upscaling look pixel-y instead of blurry
love.graphics.setDefaultFilter('nearest', 'nearest')

love.window.setVSync(1)

source = love.audio.newSource('music.mp3', 'static')
source:setLooping(true)
source:play()
-- an object to contain our map data
map = Map()

--choose a number of enemies to spawn here, DO NOT put in draw unless you are mental
map:spawnEnemy(map.player.x+math.random(200,400), map.player.y)
map:spawnEnemy(map.player.x+math.random(200,400), map.player.y)

-- performs initialization of all objects and data needed by program
function love.load()

    -- sets up a different, better-looking retro font as our default
    --love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 8))

    -- sets up virtual screen resolution for an authentic retro feel
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true
    })

    love.window.setTitle('Goblin Slayer')

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

-- called whenever window is resized
function love.resize(w, h)
    push:resize(w, h)
end



-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

-- called whenever a key is pressed
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

-- called every frame, with dt passed in as delta in time since last frame
function love.update(dt)

    map:update(dt)

    -- reset all keys pressed and released this frame
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}


end

-- called each frame, used to render to the screen
function love.draw()
    -- begin virtual resolution drawing
    push:apply('start')


    love.graphics.clear(100/255, 100/255, 255/255, 255/255)



    -- renders our map object onto the screen
    love.graphics.newFont(18)
    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
    love.graphics.print(map.enemiesSpawned-map.enemiesDead.." enemies left",map.camX, map.camY)
    map:render()
    love.graphics.print("Level "..map.level,map.camX, map.camY+20)
    love.graphics.print(map.player.health .. " health",map.camX, map.camY+40)
    if map.player.health <= 0 then
      love.graphics.print("Game Over",map.camX+432/2,map.camY+243/2-20)
      love.graphics.print("Total Kills: "..map:getTotalKills(),map.camX+432/2,map.camY+243/2)
    end
  if map.enemiesSpawned == map.enemiesDead then
    map:reset()
  end



    -- end virtual resolution
    push:apply('end')
end
