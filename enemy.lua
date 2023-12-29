--generic Enemy class

require 'Animation'
enemy = Class{}

--sprite credit: https://opengameart.org/content/16x16-16x24-32x32-rpg-enemies-updated
--made by Stephen "Redshrike" Challener

function enemy:init(player,health,damage,movespeed,jumpspeed,size,map)
  self.health = health
  self.maxhealth = health
  self.damage = damage
  self.texture = love.graphics.newImage("spritesheets/enemies.png")

  self.dead = false

  self.map = map

  self.player = player

  self.movespeed = movespeed
  self.jumpspeed = jumpspeed

  --size stat defunct for now, could be used to make big or tiny enemies
  self.width = 16
  self.height = 16

  self.xOffset = self.width/2
  self.yOffset = self.height/2

  self.x = 0
  self.y = 0

  self.dx = 0
  self.dy = 0

  self.frames = {}
  self.currentFrame = nil

  self.state = nil
  self.direction = 'left'


  self.animations = {
    ['idle'] = Animation({
        texture = self.texture,
        frames = {
            love.graphics.newQuad(143, 16, self.width, self.height, self.texture:getDimensions())
        }
    }),
    ['walking'] = Animation({
      texture = self.texture,
      frames = {
            love.graphics.newQuad(144, 80, self.width, self.height, self.texture:getDimensions()),
            love.graphics.newQuad(160, 80, self.width, self.height, self.texture:getDimensions()),
            love.graphics.newQuad(176, 80, self.width, self.height, self.texture:getDimensions())
      },
      interval = 0.15
    }),
    ['jumping'] = Animation({
        texture = self.texture,
        frames = {
            love.graphics.newQuad(48, 32, self.width, self.height, self.texture:getDimensions())
        }
    })
  }

  self.animation = self.animations['idle']
end

function enemy:avoidObstacles(direction)
  if self.direction == 'right' then
    if self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height)) then
      self.dx = self.movespeed
      self:performJump()
    end
  else
    if self.map:collides(self.map:tileAt(self.x - self.width, self.y + self.height)) then
      self.dx = -self.movespeed
      self:performJump()
    end
  end
end

function enemy:performJump()
  self.dy = -self.jumpspeed
  self.animation = self.animations['jumping']
  self.dy = self.dy + self.map.gravity
  if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
      self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
      self.dy = 0
      self.state = 'idle'
      self.animation = self.animations['idle']
      self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
  end
end

function enemy:AI()
  self:avoidObstacles(self.direction)
  if math.abs(self.x - self.player.x) > 10 then
    self.state = 'walking'
    self.animation = self.animations['walking']
    if self.x > self.player.x then
      self.direction = 'left'
      self.dx = -self.movespeed
    elseif self.x < self.player.x then
      self.direction = 'right'
      self.dx = self.movespeed
    end
  else
    self.state = 'idle'
    self.animation = self.animations['idle']
    self.dx = 0
  end
end

function enemy:checkRightCollision()
  if self.dx < 0 then
      if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
          self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
          self.dx = 0
          self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
      end
  end
end

function enemy:checkLeftCollision()
  if self.dx > 0 then
      if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or
          self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
          self.dx = 0
          self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
      end
  end
end

function enemy:causeDamage()
  if self.player:getInvFrames() > 45 and self.player.health > 0 then
    if math.abs(self.player.x-self.x) < self.width and math.abs(self.player.y-self.y) < self.height then
      self.player:damageTaken()
      self.player.health = self.player.health - self.damage
      if self.player.x < self.x then
        self.player.x = self.player.x - 16
      else
        self.player.x = self.player.x + 16
      end
    end
  end
end

function enemy:isDead()
  return self.dead
end



function enemy:update(dt)
  self.animation:update(dt)
  self.currentFrame = self.animation:getCurrentFrame()
  self.x = self.x + self.dx * dt

  if self.dy < 0 then
    if self.map:tileAt(self.x, self.y).id ~= TILE_EMPTY or
        self.map:tileAt(self.x + self.width - 1, self.y).id ~= TILE_EMPTY then
        self.dy = 0
    end
  end
  self.y = self.y + self.dy * dt
  self:checkLeftCollision()
  self:checkRightCollision()
  self:AI()

  self:causeDamage()

  if self.health <= 0 then
    self.dead = true
  end
end


function enemy:render()
  local d
  if self.direction == 'left' then
      d = -1
  else
      d = 1
  end


  love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
      math.floor(self.y + self.yOffset), 0, d, 1, self.xOffset, self.yOffset)

end
