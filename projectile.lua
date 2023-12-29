require 'Util'
require 'Map'


projectile = Class{}


function projectile:init(movespeed,damage,image,map)
  self.direction = 'right'
  self.map = map
  self.texture = love.graphics.newImage(image)
  self.x = 0
  self.y = 0
  self.width = 0
  self.height = 0
  self.xOffset = 0
  self.yOffset = 0
  self.sprite = nil
  self.animation = nil
  self.movespeed = movespeed
  self.direction = 'right'
  self.currentFrame = nil


  self.damage = damage
end

  function projectile:makeSprite(x,y,width,height)
    self.width = width
    self.height = height
    self.xOffset = width/2
    self.yOffset = height/2
    self.sprite =  love.graphics.newQuad(x,y,self.width,self.height,self.texture:getDimensions())

    self.animation = Animation({
      texture = self.texture,
      frames = {self.sprite,self.sprite}
    })
    end

  function projectile:setX(value)
    self.x = value
  end

  function projectile:setY(value)
    self.y = value
  end

  function projectile:setDirection(value)
    self.direction = value
  end

  function projectile:update(dt)
        self.animation:update(dt)
        self.currentFrame = self.animation:getCurrentFrame()
        if self.direction == 'left' then
          self.x = self.x + self.movespeed * -dt
        else
          self.x = self.x + self.movespeed * dt
        end
  end


  function projectile:render()
    local d
    if self.direction == 'right' then
      d = 1
    else
     d = -1
    end

    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), 0, d, 1, self.xOffset, self.yOffset)

  end
