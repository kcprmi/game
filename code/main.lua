function love.load()

    -- Load library and external files
    Object = require "classic"
    require "entity"
    require "anvil"
    require "brain"
    require "ground"
    require "player"
    
    -- Window size
    love.window.setMode(600, 600, {resizable=false})

    -- Load font
    font = love.graphics.newFont("/fonts/VinaSans-Regular.ttf", 30)
    love.graphics.setFont(font)

    -- New game switch
    gameOn = false

    -- Menu elements
    menuElements = {"Start Game", "Quit"}

    -- Selected menu element
    selectedElement = 1 

    -- Timer for optimizing menu selection
    keyPressDelay = 0.08
    keyPressTimer = keyPressDelay

    -- Load audio 
    soundBuzz = love.audio.newSource("/audio/buzzer.ogg", "stream")
    soundBuzz:setVolume(0.3)
    soundGulp = love.audio.newSource("/audio/gulp.ogg", "stream")
    mainTheme = love.audio.newSource("/audio/melody.ogg", "stream")
        
    -- Load life counter graphic
    counter = love.graphics.newImage("/images/heart.png")

    -- Load background
    background = love.graphics.newImage("/images/background.png")

    -- Create player
    player = Player(100, 455)
        
    -- Generate ground
    ground = {}
    local tiles = love.graphics.getWidth()/50
    for i = 0, tiles do
        table.insert(ground, Ground(i*50, 550))
    end

    -- Timers for brains and anvils generators
    timerMaxBrains = 1.2
    timerMaxAnvils = 1.5
    timerBrains = timerMaxBrains
    timerAnvils = timerMaxAnvils
    
    -- Tables for brains and anvils
    listOfBrains = {}
    listOfAnvils = {}
        
    -- Var for making game harder
    nextLevel = 15
    brainsCounter = 0
    genAcc = 0.4
end

function love.update(dt)
    
    
    -- When game is on (menu screen)
    if gameOn then
        if player.dead then
            player:update(dt)
            
            if love.keyboard.isDown("return") then
                love.load()
                gameOn = true
            
            elseif love.keyboard.isDown("escape") then
                love.event.quit()
            end
        else
            -- Play music
            if not mainTheme:isPlaying() then
                love.audio.play(mainTheme)
            end
            -- Quit game 
            if love.keyboard.isDown("escape") then
                gameOn = false
                keyPressTimer = 0.15
            end
            -- Make game harder every 15 brains generated
            if brainsCounter == nextLevel then
                timerMaxAnvils = timerMaxAnvils - genAcc
                nextLevel = nextLevel + 15
            end

            -- Brains generator
            timerBrains = timerBrains - dt
            if timerBrains <= 0 then
                table.insert(listOfBrains, Brain(love.math.random(0, 460), 25))
                timerBrains = timerMaxBrains
                brainsCounter = brainsCounter + 1
            end
            -- Anvils generator
            timerAnvils = timerAnvils- dt
            if timerAnvils <= 0 then
                table.insert(listOfAnvils, Anvil(love.math.random(0, 440), 25))
                timerAnvils = timerMaxAnvils
            end

            -- Dash cooldown
            player.timer = player.timer - dt
            if player.timer <= 0 then
                player.dash = true
            end
            
            -- Update brains
            player:update(dt)
            for i,v in ipairs(listOfBrains) do
                v:update(dt)
                if v:checkCollision(player) then
                    soundGulp:play()
                end
                if v.dead then
                    table.remove(listOfBrains, i)
                end
            end
            -- Update anvils
            for i,v in ipairs(listOfAnvils) do
                v:update(dt)
                if v:checkCollision(player) then
                    soundBuzz:play()
                end
                if v.dead then
                    table.remove(listOfAnvils, i)
                end
            end
        end
        
    -- When game is off display menu
    else
        keyPressTimer = keyPressTimer - dt
        if keyPressTimer <= 0 then
            -- Switch between menu elements
            if love.keyboard.isDown("up") then
                selectedElement = selectedElement - 1 
                if selectedElement < 1 then 
                    selectedElement = #menuElements
                end           
            
            elseif love.keyboard.isDown("down") then
                selectedElement = selectedElement + 1
                if selectedElement > #menuElements then
                    selectedElement = 1
                end
            elseif love.keyboard.isDown("escape") then
                love.event.quit()
            end
            keyPressTimer = keyPressDelay
        end
        if menuElements[selectedElement] == "Start Game" and love.keyboard.isDown("return") then
            gameOn = true
        
        elseif menuElements[selectedElement] == "Quit" and love.keyboard.isDown("return") then
            love.event.quit()
        end
    end
end

function love.draw()
    -- Render game
    if gameOn then
        if player.dead then 
            -- Render Game Over 
            font = love.graphics.newFont("/fonts/VinaSans-Regular.ttf", 50)
            love.graphics.setFont(font)
            love.graphics.print({{1, 0, 0}, "DEAD UNDEAD"}, 375, 50, 0.5)
            player:drawDead()
            font = love.graphics.newFont("/fonts/VinaSans-Regular.ttf", 50)
            love.graphics.setFont(font)
            love.graphics.printf({{1,0,0}, "SCORE: "..tostring(player.score)}, 0, 425, 600, "center") 
            font = love.graphics.newFont("/fonts/VinaSans-Regular.ttf", 25)
            love.graphics.setFont(font)
            love.graphics.printf("restart <enter>", 0, 500, 600, "center")
            love.graphics.printf("quit <esc>", 0, 550, 600, "center")
            love.audio.stop(mainTheme)
        else
            font = love.graphics.newFont("/fonts/VinaSans-Regular.ttf", 40)
            love.graphics.setFont(font)
            -- Draw background
            love.graphics.draw(background, 0, 50)
            
            -- Print Score
            love.graphics.print(player.score, 500, 0)
            
            -- Dash information
            love.graphics.printf({{0,1,0}, "DASH"}, 0, 0, 600, "center")
            love.graphics.printf({{1,0,0, player.timer}, "DASH"}, 0, 0, 600, "center")
            
            -- Draw life counters
            for i=1, player.livesCounter do
                love.graphics.draw(counter, i * 20, 5)       
            end
            
            -- Draw ground
            for i,v in ipairs(ground) do
                v:draw()
            end
            
            -- Draw player
            if player.damageTimer > 0 then
                love.graphics.setColor(1,0,0)
                player:draw()
                love.graphics.setColor(255,255,255)
            else 
                player:draw()
            end
            
            -- Draw brains
            for i,v in ipairs(listOfBrains) do
                v:draw()
            end
    
            -- Draw anvils
            for i,v in ipairs(listOfAnvils) do
                v:draw()
            end
        end
    
    -- Menu screen
    else
        font = love.graphics.newFont("/fonts/VinaSans-Regular.ttf", 50)
        love.graphics.setFont(font)
        for i, element in ipairs(menuElements) do
            --Highlight selected element
            if i == selectedElement then
                love.graphics.setColor(1,0,0)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(element, 0, 400 + i * 50, 600, "center")
        end
        love.graphics.setColor(1, 1, 1)
        font = love.graphics.newFont("/fonts/VinaSans-Regular.ttf", 80)
        love.graphics.setFont(font)
        love.graphics.printf({{0,1,0}, "Zombiecalypse Appetite"}, 0, 5, 600, "center")
        font = love.graphics.newFont("/fonts/VinaSans-Regular.ttf", 25)
        love.graphics.setFont(font)
        love.graphics.printf({{0,1,0}, "By Kacper Mirecki"}, 0, 200, 600, "center")
        love.graphics.printf("instructions:", 0, 300, 600, "center")
        love.graphics.printf("use arrows to walk left and right", 0, 325, 600, "center")
        love.graphics.printf("press <space> to dash", 0, 350, 600, "center")
        love.graphics.printf("press <esc> to quit", 0, 375, 600, "center")

    end
end
