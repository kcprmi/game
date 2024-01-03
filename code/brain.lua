Brain = Entity:extend()

function Brain:new(x, y)
    Brain.super.new(self, x, y, "/images/brain.png")
    -- Falling speed
    self.weight = 300
    -- Lifetime after touching ground
    self.lifetime = 0.5
end

function Brain:update(dt)
    self.y = self.y + self.weight * dt
    if self.y >= 550 - self.height then
        self.y = 550 - self.height
        self.lifetime = self.lifetime - dt
    end
    -- Brain stays for a while after contact with ground
    if self.lifetime <= 0 then
        self.dead = true
    end 
end

-- Collision check (brain: player)
function Brain:checkCollision(player)
    
    if self.x + self.width > player.x + 10
    and self.x < (player.x + 10) + (player.width - 10) 
    and self.y + self.height > (player.y + 10)
    and self.y < (player.y + 10) + (player.height - 10) then
        -- Score points
        player.score = player.score + 50  
        self.dead = true
        return true
    end
end


function Brain:draw()
    love.graphics.draw(self.image, self.x, self.y)
end

