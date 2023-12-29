--[[
    Represents the player in the game, with its own sprite.
]]
require 'projectile'

Player = Class{}

local WALKING_SPEED = 160
local JUMP_VELOCITY = 350


local invincibilityFrames = 45

function Player:init(map)


    self.numArrows = 0
    self.arrows = {}
    for i = 1, 256, 1 do
      self.arrows[i] = nil
    end


    self.x = 0
    self.y = 0
    self.width = 16
    self.height = 16

    self.health = 30
    self.maxhealth = 30


    -- offset from top left to center to support sprite flipping
    self.xOffset = 8
    self.yOffset = 8

    -- reference to map for checking tiles
    self.map = map
    self.texture = love.graphics.newImage("spritesheets/archer.png")

    -- sound effects
    self.sounds = {
    }

    self.bowDrawn = false

    -- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'

    -- determines sprite flipping
    self.direction = 'right'

    -- x and y velocity
    self.dx = 0
    self.dy = 0

    -- position on top of map tiles
    self.y = map.tileHeight * ((map.mapHeight - 2) / 2) - self.height
    self.x = map.tileWidth * 10

    -- initialize all player animations
    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 0, self.width, self.height, self.texture:getDimensions())
            }
        }),
        ['walking'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(32, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(48, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(64, 0, self.width, self.height, self.texture:getDimensions())
            },
            interval = 0.15
        }),
        ['jumping'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(48, 32, self.width, self.height, self.texture:getDimensions())
            }
        }),
        ['idleShooting'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(80, 0, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(0, 16, self.width, self.height, self.texture:getDimensions()),
                love.graphics.newQuad(80, 0, self.width, self.height, self.texture:getDimensions())
            },
            interval = 0.5
        })
    }

    -- initialize animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()

    -- behavior map we can call based on player state
    self.behaviors = {
        ['idleShooting'] = function(dt)
          if love.keyboard.wasPressed('up') then
            self.dy = -JUMP_VELOCITY
            self.state = 'jumping'
            self.animation = self.animations['jumping']
          elseif love.keyboard.isDown('left') then
            self.direction = 'left'
            self.dx = -WALKING_SPEED
            self.state = 'walking'
            self.animations['walking']:restart()
            self.animation = self.animations['walking']


          elseif love.keyboard.isDown('right') then
            self.direction = 'right'
            self.dx = WALKING_SPEED
            self.state = 'walking'
            self.animations['walking']:restart()
            self.animation = self.animations['walking']


          elseif love.keyboard.isDown('space') then
            self.state = 'idleShooting'
            if self.animation.currentFrame == 2 and self.bowDrawn == false then
              self:spawnArrow()
              self.bowDrawn = true
            end

            if self.animation.currentFrame == 1 then
              self.bowDrawn = false
            end
            self.animation = self.animations['idleShooting']
          else
            self.animations['idleShooting']:restart()
            self.dx = 0
            self.state = 'idle'
            self.animation = self.animations['idle']
          end

        end,

        ['idle'] = function(dt)

            if love.keyboard.wasPressed('up') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            elseif love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -WALKING_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']

            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = WALKING_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']

            elseif love.keyboard.isDown('space') then
                self.state = 'idleShooting'

                if self.animation.currentFrame == 2 and self.bowDrawn == false then
                  self:spawnArrow()
                  self.bowDrawn = true
                end

                if self.animation.currentFrame == 1 then
                  self.bowDrawn = false
                end

                self.animation = self.animations['idleShooting']
            else
                self.animations['idleShooting']:restart()
                self.dx = 0
            end
        end,
        ['walking'] = function(dt)

            -- keep track of input to switch movement while walking, or reset
            -- to idle if we're not moving
            if love.keyboard.wasPressed('up') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            elseif love.keyboard.isDown('left') then
                self.animations['idleShooting']:restart()
                self.direction = 'left'
                self.dx = -WALKING_SPEED

            elseif love.keyboard.isDown('right') then
                self.animations['idleShooting']:restart()
                self.direction = 'right'
                self.dx = WALKING_SPEED

            else
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end

            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()

            -- check if there's a tile directly beneath us
            if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then

                -- if so, reset velocity and position and change state
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            end
        end,
        ['jumping'] = function(dt)
            -- break if we go below the surface
            if self.y > 300 then
                return
            end

            if love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -WALKING_SPEED
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = WALKING_SPEED
            end

            -- apply map's gravity before y velocity
            self.dy = self.dy + self.map.gravity

            -- check if there's a tile directly beneath us
            if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then

                -- if so, reset velocity and position and change state
                self.dy = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
            end

            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()
        end
    }
end

function Player:spawnArrow()
  local newArrow = projectile(300,10,"spritesheets/archer.png",map)
  newArrow:makeSprite(80,48,16,8)
  newArrow:setX(self.x)
  newArrow:setY(self.y+4)
  newArrow:setDirection(self.direction)
  table.insert(self.arrows,newArrow)
  self.numArrows = self.numArrows + 1
end

function Player:removeArrow(index)
  table.remove(self.arrows,index)
  self.numArrows = self.numArrows - 1
end

function Player:updateArrows(map,dt)
  for i = 1, self.numArrows, 1 do
    self.arrows[i]:update(dt)
    if self.arrows[i].x < 0 or self.arrows[i].x > map.mapWidth*16 then
      self:removeArrow(i)
    end
  end
end


function Player:causeDamage(enemy)
  for i = 1, self.numArrows, 1 do
    if math.abs(enemy.x-self.arrows[i].x) < 16 and math.abs(enemy.y-self.arrows[i].y) < 8 then
      enemy.health = enemy.health - self.arrows[i].damage
      self:removeArrow(i)
    end
  end
end


function Player:update(dt)
  invincibilityFrames = invincibilityFrames + 1
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = self.x + self.dx * dt

    self:updateArrows(self.map,dt)

    self:calculateJumps()


    -- apply velocity
    self.y = self.y + self.dy * dt
end

-- jumping and block hitting logic
function Player:calculateJumps()

    -- if we have negative y velocity (jumping), check if we collide
    -- with any blocks above us
    if self.dy < 0 then
        if self.map:tileAt(self.x, self.y).id ~= TILE_EMPTY or
            self.map:tileAt(self.x + self.width - 1, self.y).id ~= TILE_EMPTY then
            -- reset y velocity
            self.dy = 0
        end
    end
end

-- checks two tiles to our left to see if a collision occurred
function Player:checkLeftCollision()
    if self.dx < 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
            self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then

            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
        end
    end
end



-- checks two tiles to our right to see if a collision occurred
function Player:checkRightCollision()
    if self.dx > 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then

            self.dx = 0
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
        end
    end
end

function Player:getInvFrames()
  return invincibilityFrames
end

function Player:damageTaken()
  invincibilityFrames = 0
end


function Player:render()
    local scaleX

    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end
    if invincibilityFrames < 45 then
      love.graphics.setColor(1,1,1,0.5)
    end
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), 0, scaleX, 1, self.xOffset, self.yOffset)
    love.graphics.setColor(1,1,1,1)
      for i = 1, self.numArrows, 1 do
        self.arrows[i]:render()
      end

end
