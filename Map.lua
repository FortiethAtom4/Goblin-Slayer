--[[
    Contains tile data and necessary code for rendering a tile map to the
    screen.
]]

require 'Util'

Map = Class{}

TILE_EMPTY = -1

--tileset is 16x16 of 16x16-bit tiles
--stone tiles
DARK_STONE = {2,3,4,5,6,7,8,9,10,11,210,211,212,213,214,215}
DARK_STONE_SIZE = 16
LIGHT_STONE = {50,51,52,53,54,55,56,57,58,59}
LIGHT_STONE_SIZE = 10


-- a speed to multiply delta time to scroll map; smooth value
local SCROLL_SPEED = 62

local numEnemies = 0

local saveLevel = 1

local totalKills = 0
local healthGiven = false
local currentHealth = 0

-- constructor for our map object
function Map:init()
    self.spritesheet = love.graphics.newImage('spritesheets/tileset.png')
    self.sprites = generateQuads(self.spritesheet, 16, 16)


    self.level = 1

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 100
    self.mapHeight = 28
    self.tiles = {}

    -- applies positive Y influence on anything affected
    self.gravity = 15

    -- associate player with map
    self.player = Player(self)

    self.enemies = {}
    self.enemiesSpawned = 0

    self.enemiesDead = 0

    for i = 0, 100, 1 do
      self.enemies[i] = enemy(self.player,10,10,math.random(15,65)+self.level*10,100,1,self)
    end


    -- camera offsets
    self.camX = 0
    self.camY = -3

    -- cache width and height of map in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- first, fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do

            -- support for multiple sheets per tile; storing tiles as tables
            self:setTile(x, y, TILE_EMPTY)
        end
    end


    for i = 0, self.mapWidth, 1 do
        for y = self.mapHeight / 2, self.mapHeight do
            self:setTile(i, y, DARK_STONE[1])
        end
    end


end


function Map:spawnEnemy(x,y)
  self.enemies[self.enemiesSpawned+1].x = x
  self.enemies[self.enemiesSpawned+1].y = y
  self.enemiesSpawned = self.enemiesSpawned + 1
  numEnemies = numEnemies + 1
end


-- return whether a given tile is collidable
function Map:collides(tile)
    -- define our collidable tiles
    local collidables = {}
    for i = 1, DARK_STONE_SIZE, 1 do
      collidables[i] = DARK_STONE[i]
    end


    -- iterate and return true if our tile type matches
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

function Map:checkDeadEnemies(index)
    if self.enemies[index].dead == true then
      self.enemiesDead = self.enemiesDead + 1
      totalKills = totalKills + 1
    end
end

-- function to update camera offset with delta time
function Map:update(dt)
    if self.player.health > 0 then
      self.player:update(dt)
    end
    currentHealth = self.player.health
    if totalKills % 10 == 0 and healthGiven == false then
      if self.player.health < self.player.maxhealth then
        self.player.health = self.player.health + 10
        healthGiven = true
      end
    end

    -- keep camera's X coordinate following the player, preventing camera from
    -- scrolling past 0 to the left and the map's width
    self.camX = math.max(0, math.min(self.player.x - VIRTUAL_WIDTH / 2,
        math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))

  for i = 1, self.enemiesSpawned, 1 do
    if self.enemies[i].dead == false then
      self.enemies[i]:update(dt)
      self.player:causeDamage(self.enemies[i])
      self:checkDeadEnemies(i)
    end
  end
end

function Map:getTotalKills()
  return totalKills
end

-- gets the tile type at a given pixel coordinate
function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

-- returns an integer value for the tile at a given x-y coordinate
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

-- sets a tile at a given x-y coordinate to an integer value
function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

function Map:renderEnemies()
  for i = 1, self.enemiesSpawned,1 do
    if self.enemies[i].dead == false then
      self.enemies[i]:render()
    end
  end
end

-- renders our map to the screen, to be called by main's render
function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            if tile ~= TILE_EMPTY then
                love.graphics.draw(self.spritesheet, self.sprites[tile],
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end
    if self.player.health > 0 then
      self.player:render()
    end

    self:renderEnemies()

end

function Map:reset()
    for i = 1, self.enemiesSpawned, 1 do
      table.remove(self.enemies)
    end
    self.enemiesSpawned = 0
    self.enemiesDead = 0

    for i = 1, #self.player.arrows do
      table.remove(self.player.arrows)
    end
    self:init()
    self.player.health = currentHealth
    saveLevel = saveLevel + 1
    self.level = saveLevel
    self.player.y = self.tileHeight * ((self.mapHeight - 2) / 2) - self.player.height
    self.player.x = self.tileWidth * 10
    for i = 1, numEnemies+self.level, 1 do
      self:spawnEnemy(self.player.x+math.random(200,400), self.player.y)
      numEnemies = numEnemies - 1
    end
    healthGiven = false



end
