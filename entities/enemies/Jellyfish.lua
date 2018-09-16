local Enemy = require "entities.Enemy"

local timer = require "lib.hump.timer"
local anim8 = require "lib.anim8"

local Jellyfish = Enemy:extend()

function Jellyfish:new(x, y)
  Jellyfish.super.new(self, x, y)
  self.name = "Jellyfish"
  self.isJellyfish = true
  self.tag = "Jellyfish"

  -- enemy mechanics
  self.hp = 200

  -- movable
  local speed = 50
  local maxVelocityX = 120
  local maxVelocityY = 120
  local drag = math.abs(G.gravity)*2

  self.movable = {
    velocity = { x = 0, y = 0 },
    acceleration = { x = 0, y = 0 },
    drag = { x = drag, y = drag },
    maxVelocity = { x = maxVelocityX, y = maxVelocityY },
    defaultMaxVelocity = { x = maxVelocityX, y = maxVelocityY },
    speed = { x = speed, y = speed }
  }

  -- draw/sprite component
  self.tileSize = 12
  self.width = self.tileSize
  self.height = self.tileSize

  self.layer = G.layers.enemy
  self.sprite = assets.jellyfish
  self.flippedH = false
  self.offset = { x = self.tileSize/2, y = self.tileSize/2 }
  local g = anim8.newGrid(self.tileSize, self.tileSize, self.sprite:getWidth(), self.sprite:getHeight())
  self.idleAnimation = anim8.newAnimation(g('1-5',1), 0.1)
  self.animation = self.idleAnimation

  self.speed = speed

  self.followPlayer = true
  -- self.followSpeed = 0.2
  if self.followPlayer then
    self.player = scene:getObjectByName("Player")
  end

  table.insert(self.collidableTags.cross, "isOneWay")

  return self
end

function Jellyfish:update(dt)
  Jellyfish.super.update(dt)
  local playerX, playerY = self.player:getMiddlePosition()
  local selfX, selfY = self:getMiddlePosition()

  if self.followPlayer and self.player then
    -- if math.abs(self:distanceFrom(self.player)) > 20 then
      local angle = _.angle(selfX, selfY, playerX, playerY)
      local velX, velY = _.vector(angle, self.speed)
      self.movable.velocity.x = _.lerp(self.movable.velocity.x, velX, self.speed)
      self.movable.velocity.y = _.lerp(self.movable.velocity.y, velY, self.speed)
    -- end
  end
end

function Jellyfish:collide(other, col)
  Jellyfish.super.collide(self, other, col)
  -- knockback
  if other.isBullet and self.bounceForce > 0 then
    local angle = math.rad(math.deg(other.angle))
    local d = self:distanceFrom(self.player)
    local bounceMultiplier = 1

    if d > 100 then
      bounceMultiplier = bounceMultiplier/6
    elseif d > 50 then
      bounceMultiplier = bounceMultiplier/4
    else
      bounceMultiplier = bounceMultiplier/3
    end

    local randomRange = 30
    self:bounce(angle, bounceMultiplier, randomRange)
  end
end

function Jellyfish:draw()
  local selfX, selfY = self:getOffsetPosition()
end

return Jellyfish