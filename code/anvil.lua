Anvil = Entity:extend()

function Anvil:new(x, y)
    Anvil.super.new(self, x, y, "/images/anvil.png")
    --Falling speed factor
    self.weight = 400
    --Bool to making damage
    self.damage = true
end
--Fall
function Anvil:update(dt)
    self.y = self.y +self.weight * dt
    -- Remove anvils when they miss window
    if self.y > love.graphics.getHeight() then
        self.dead = true
    end
end

function Anvil:draw()
    love.graphics.draw(self.image, self.x, self.y)
end
-- Check collision
function Anvil:checkCollision(player)
    
    if (self.x - 10) + (self.width - 20) > player.x + 10
    and self.x - 10 < (player.x + 10) + (player.width - 20) 
    and self.y + (self.height - 20) > (player.y + 20)
    and (self.y + 10) < (player.y + 20) + player.height then   
        -- Deal damage
        if self.damage == true then
            player.livesCounter = player.livesCounter - 1 
            self.damage = false 
            player.damageTimer = player.damageTimerMax
            return true
        end
    end
end