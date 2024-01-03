Player = Entity:extend()

function Player:new(x, y)
    Player.super.new(self, x, y, "/images/zombie.png")
    self.speed = 300
    self.spriteWalkRight = love.graphics.newImage("/images/zombie_sprite_right.png")
    self.quadsWalkRight = {}
    self.spriteWalkLeft = love.graphics.newImage("/images/zombie_sprite_left.png")
    self.quadsWalkLeft = {}
    self.spriteDead = love.graphics.newImage("/images/zombie_sprite_dead.png")
    self.quadsDead = {}
    
    -- Quads from sprites
    for i = 0, 10 do
        table.insert(self.quadsWalkRight, love.graphics.newQuad(i * self.width, 0, self.width, self.height, self.spriteWalkRight:getDimensions()))
        table.insert(self.quadsWalkLeft, love.graphics.newQuad(i * self.width, 0, self.width, self.height, self.spriteWalkLeft:getDimensions()))
    end
    
    for i = 0,11 do
        table.insert(self.quadsDead, love.graphics.newQuad(i* 200, 0, 200, 167, self.spriteDead:getDimensions()))
    end

    -- Dash sound effect 
    self.soundDash = love.audio.newSource("/audio/dash.ogg", "stream")
    -- Number of lives
    self.livesCounter = 3
    -- Game score
    self.score = 0
    -- Actual frame
    self.frame = 1
    -- Frame when dead
    self.frameDead = 1
    -- Actual sprite
    self.sprite = self.spriteWalkRight
    -- Actual sprites
    self.quads = self.quadsWalkRight
    -- Player state
    self.state = "walk_right"
    -- Ability to dash
    self.dash = false
    -- Timer for dash cooldown 
    self.timer = 2
    -- Damage feedback
    self.damageTimer = 0
    self.damageTimerMax = 0.5
end

function Player:update(dt)
    
    -- Frame update when game over
    if self.dead then
        self.frameDead = self.frameDead + 10 * dt
        if self.frameDead >= 11 then
            self.frameDead = 11
        end
    -- Gameplay
    else
        -- Stay in window
        local windowWidth = love.graphics.getWidth()
        if self.x < 0 then
            self.x = 0
        elseif self.x + self.width > windowWidth then
            self.x = windowWidth - self.width
        end
        -- Damage feedback
        self.damageTimer = self.damageTimer - dt
        -- Dash
        if love.keyboard.isDown("space") and self.dash then
            self.soundDash:play()
            if self.state == "walk_right" then
                self.x = self.x + 100
                self.dash = false
                self.timer = 2
            elseif self.state == "walk_left" then
                self.x = self.x - 100
                self.dash = false
                self.timer = 2    
            end
        end
        -- Walk right
        if love.keyboard.isDown("right") then
            self.x = self.x + self.speed * dt
            self.state = "walk_right"
        -- Walk left
        elseif love.keyboard.isDown("left") then     
            self.x = self.x - self.speed * dt
            self.state = "walk_left"
        else
            self.frame = 0
        end  
        
        -- Walking animation 
        if self.state == "walk_right" then
            self.sprite = self.spriteWalkRight
            self.quads = self.quadsWalkRight 
            self.frame = (self.frame % 11) + 1
        
        elseif self.state == "walk_left" then
            self.sprite = self.spriteWalkLeft
            self.quads = self.quadsWalkLeft
            self.frame = (self.frame % 11) + 1
        end
    end
    -- Initiating game over 
    if self.livesCounter <= 0 then
        self.dead = true
        self.sprite = self.spriteDead
        self.quads = self.quadsDead
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getPixelHeight()
        self.x = math.floor(windowWidth/2 - 100)
        self.y = math.floor((windowHeight/2) - (167/2)) 
    end
    
end
-- Normal draw
function Player:draw()    
    love.graphics.draw(self.sprite, self.quads[math.floor(self.frame)], self.x, self.y)
end
-- Dead animation draw
function Player:drawDead()    
    love.graphics.draw(self.sprite, self.quads[math.floor(self.frameDead)], self.x, self.y)
end