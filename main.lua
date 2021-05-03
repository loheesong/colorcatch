push = require 'push'
Class = require 'class'

require 'Ball'
require 'Player'
require 'Button'

-- global variables are in caps 
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- keep track of all balls on screen 
balls = {}

-- difficulty interval (in seconds)
difficultyInterval = 20
newBall_timer = 0
maxBalls = 1

-- animate title 
titleTimer = 0
titleINTERVAL = 0.75

-- Runs when the game first starts up, only once; used to initialize the game.
function love.load()
    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle("Color Catch")

    -- more "retro-looking" font object we can use for any text
    instructionsFont = love.graphics.newFont('font/font.ttf', 16)
    scoreFont = love.graphics.newFont('font/font.ttf', 56)
    titleFont = love.graphics.newFont('font/font.ttf', 48)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initiate player 
    player = Player()

    -- ball object to play sound
    soundBall = Ball()

    --gameStates: start, instructions, play, end
    gameState = "start"

    -- to reset game 
    resetted = false

    -- background music
    background = love.audio.newSource("sounds/background.mp3", "stream")
    background:play()
    background:setLooping(true)

    -- buttons used in start screen 
    bigPlay = Button({
        x = VIRTUAL_WIDTH / 2 - 200 / 2, y = VIRTUAL_HEIGHT / 2 + 20,
        width = 200, height = 45,
        
        text = {
            text = "PLAY",
            font = love.graphics.newFont('font/font.ttf', 48),

            red = 0, green = 0, blue = 0, alpha = 1
        },
        colour = {red = 1, green = 1, blue = 1, alpha = 1}
    })
    
    how_to_play = Button({
        x = VIRTUAL_WIDTH / 2 - 150 / 2, y = VIRTUAL_HEIGHT / 2 + 45 + 5 + 20,
        width = 150, height = 20,
        text = {
            text = "How to Play",
            font = love.graphics.newFont('font/font.ttf', 16),

            red = 0, green = 0, blue = 0, alpha = 1
        },
        colour = {red = 1, green = 1, blue = 1, alpha = 1}
    })
    --[
    -- buttons used in end screen 
    main_menu = Button({
        x = VIRTUAL_WIDTH / 2 - 100 - 5, y = VIRTUAL_HEIGHT / 2,
        width = 100, height = 48,
        text = {
            text = "MAIN MENU",
            font = love.graphics.newFont('font/font.ttf', 24),

            red = 0, green = 0, blue = 0, alpha = 1,
        },
        colour = { red = 1, green = 1, blue = 1, alpha = 1}
    })
    play_again = Button({
        x = VIRTUAL_WIDTH / 2 + 5, y = VIRTUAL_HEIGHT / 2,
        width = 100, height = 48,
        text = {
            text = "PLAY AGAIN",
            font = love.graphics.newFont('font/font.ttf', 24),

            red = 0, green = 0, blue = 0, alpha = 1
        },
        colour = {red = 1, green = 1, blue = 1, alpha = 1}
    })
    smallPlay = Button({
        x = VIRTUAL_WIDTH / 2 - 100 / 2, y = VIRTUAL_HEIGHT - 20,
        width = 100, height = 16,
        text = {
            text = "PLAY",
            font = love.graphics.newFont('font/font.ttf', 16),

            red = 0, green = 0, blue = 0, alpha = 1
        },
        colour = {red = 1, green = 1, blue = 1, alpha = 1}
    })
end

-- Runs every frame, with "dt" passed in, our delta in seconds since the last frame, which LÖVE supplies us.
function love.update(dt)

    if gameState == "start" then 
        gameState = bigPlay:whenClicked("start", "play")

        -- prevent gameState from changing back to start 
        if gameState == "start" then 
            gameState = how_to_play:whenClicked("start", "instructions")
        end
        
        titleUpdate(dt)
        background:play()
        background:setVolume(0.25)

    elseif gameState == "instructions" then 
        gameState = smallPlay:whenClicked("instructions", "play")
        background:setVolume(0.25)

    elseif gameState == "play" then
        background:play()
        background:setVolume(0.1)

        if resetted == false then 
            resetGame()
        end

        spawnBall(dt)
        ballsUpdate(dt)
        player:update(dt)

        -- losing condition
        if player.lives.number < 1 then
            -- prepare for reset
            resetted = false 
            gameState = "end"
        end
    elseif gameState == "end" then 
        gameState = main_menu:whenClicked("end", "start")

        if gameState == "end" then 
            gameState = play_again:whenClicked("end", "play")
        end

        background:stop()
    end
end

-- Keyboard handling, called by LÖVE each frame; passes in the key we pressed so we can access.
function love.keypressed(key)
    
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()
    end

    -- to change game state
    if key == 'enter' or key == 'return' then
        if gameState == "start" then 
            gameState = "instructions"
        elseif gameState == "instructions" then 
            gameState = "play"
        elseif gameState == "end" then
            gameState = "start"
        elseif gameState == "play" then 
            gameState = "end"
        end
    end

end

function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    if gameState == "start" then 
        love.graphics.clear(1, 248 / 255, 231 / 255)
        bigPlay:render()
        how_to_play:render()

        -- logo
        printTitle()

    elseif gameState == "instructions" then 
        love.graphics.clear(0.8, 0.8, 0.8)

        printInstructions()

        smallPlay:render()
    elseif gameState == "play" then 
        love.graphics.clear(0.5,0.5,0.5)

        -- render balls
        ballsRender()

        -- render player
        player:render()
    elseif gameState == "end" then 
        love.graphics.clear(0,1,0)

        -- print score
        love.graphics.setFont(scoreFont)
        love.graphics.printf(tostring(player.score.score), 0, 50, 432, "center")

        -- display buttons 
        main_menu:render()
        play_again:render()
    end
    push:apply('end')
end

-----------------------------------------------------------ADDITIONAL FUNCTIONS-----------------------------------------------------------

function mousePos()
    love.graphics.setColor(1,1,1)
    local mouseX, mouseY = love.mouse.getPosition()
    love.graphics.print("MouseX: " .. tostring(mouseX) .. "MouseY: " .. tostring(mouseY),
        10, 10)
end

-- delete a ball once it falls below or above screen, also reduces lives of player
function deleteBall()
    for key, value in ipairs(balls) do 
        if value.toDelete == true then 
            table.remove(balls, key)
        end
        if value.minusLife == true then 
            player.lives.number = player.lives.number - 1
        end
    end
end

-- handles all ball actions on screen 
function ballsUpdate(dt)
    -- updates position of balls and check for collision with player 
    for key, value in ipairs(balls) do 
        if value ~= nil then 
            value:update(dt)
        end

        if value:score(player) then 
            -- make sures the player and ball are same colour
            if player.colour == value.colourKey[value.colour] then 
                -- increment score
                player.score.score = player.score.score + 1
                value.sounds.score:play()
            else
                player.lives.number = player.lives.number - 1
                value.sounds.loseLife:play()
            end
            deleteBall()
        else
            value:collideSide(player)
        end
    end

    -- ball ball collision
    for i = 1, #balls - 1 do
        for j = 2, #balls do 
            if i < j then 
                balls[i]:collideBall(balls[j], dt)
            end
        end
    end
    
    -- delete ball once it is out of range of screen 
    deleteBall()
end

-- render all balls 
function ballsRender()
    for key, value in ipairs(balls) do 
        value:render()
    end
end

-- controls spawning of balls up till the max level on screen, determined by time passed since game started 
function spawnBall(dt)
    newBall_timer = newBall_timer + dt

    -- increase number of balls if less than max on screen
    if #balls < maxBalls then 
        -- create ball object and insert at the back of balls table
        local newBall = Ball()
        table.insert(balls, newBall)
    end
    -- increase max on screen based on time passed since start
    if newBall_timer >= difficultyInterval then 
        maxBalls = maxBalls + 1
        newBall_timer = 0
    end
end

function resetGame()
    -- reset player 
    player.x = VIRTUAL_WIDTH / 2 - player.width / 2
    player.lives.number = 5
    player.score.score = 0
    player.dashTimer = 0
    player.hasDash = false

    -- delete all balls from table 
    for key, value in ipairs(balls) do 
        table.remove(balls, key)
    end

    --reset spawning function 
    newBall_timer = 0
    maxBalls = 1

    -- remembers resetGame has been called
    resetted = true
end

function wait(seconds)
    local start = os.time()
    repeat until os.time() > start + seconds
end

function printInstructions()
    love.graphics.setFont(instructionsFont)
    love.graphics.setColor(0, 0, 0)

    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Default colour is black", 10, 10 + 0*16, VIRTUAL_WIDTH - 10, "left")

    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Press Q to turn player", 10, 10 + 1*16, VIRTUAL_WIDTH - 10, "left")
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("red", 214, 10 + 1*16, VIRTUAL_WIDTH - 10, "left")

    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Press W to turn player", 10, 10 + 2*16, VIRTUAL_WIDTH - 10, "left")
    love.graphics.setColor(0, 1, 0)
    love.graphics.printf("green", 216, 10 + 2*16, VIRTUAL_WIDTH - 10, "left")

    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Press E to turn player", 10, 10 + 3*16, VIRTUAL_WIDTH - 10, "left")
    love.graphics.setColor(0, 0, 1)
    love.graphics.printf("blue", 212, 10 + 3*16, VIRTUAL_WIDTH - 10, "left")

    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Press Q, W, E at the same time to turn player", 10, 10 + 4*16, VIRTUAL_WIDTH - 10, "left")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("white", 10, 10 + 5*16, VIRTUAL_WIDTH - 10, "left")

    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Hold right click to move player towards mouse", 10, 10 + 6*16, VIRTUAL_WIDTH - 10, "left")
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Left click to move player to location instantly if dash is available", 10, 10 + 7*16, VIRTUAL_WIDTH - 10, "left")

    love.graphics.printf("3s", VIRTUAL_WIDTH / 2 - 10, 10 + 10*16, 25, "left")
    love.graphics.printf("not available", 10 + 100, 10 + 10*16 + 8, 75, "center")
    love.graphics.printf("available", 10 + 240, 10 + 11*16, 75, "center")
    love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - 50 / 2, 10 + 11*16, 50 - 4, 4)
    love.graphics.polygon("fill", VIRTUAL_WIDTH / 2 + 50 / 2 - 5, 10 + 11*16 - 4, VIRTUAL_WIDTH / 2 + 50 / 2 - 5, 10 + 11*16 + 8, VIRTUAL_WIDTH / 2 + 50 / 2, 10 + 11*16 + 2)

    love.graphics.setColor(1,1,1)
    love.graphics.draw(player.dashVisual.offline, VIRTUAL_WIDTH / 2 - 16 * 5, 10 + 9*16 + 8)
    love.graphics.draw(player.dashVisual.online, VIRTUAL_WIDTH / 2 + 16 * 4 - 5, 10 + 9*16 + 8)
end

function love.resize(w,h)
    push:resize(w,h)
end

function printTitle()
    love.graphics.setFont(titleFont)
    
    -- black
    love.graphics.setColor(0,0,0)
    love.graphics.printf("C", VIRTUAL_WIDTH / 2 - 250 / 2 + 56, 10, 250, "left")
    -- red
    love.graphics.setColor(255 / 255, 36 / 255, 0)
    love.graphics.printf("O", VIRTUAL_WIDTH / 2 - 250 / 2 + 80, 10, 48, "left")
    -- green
    love.graphics.setColor(0, 168 / 255, 107 / 255)
    love.graphics.printf("L", VIRTUAL_WIDTH / 2 - 250 / 2 + 80 + 30, 10, 48, "left")
    -- blue
    love.graphics.setColor(0, 128 / 255, 1)
    love.graphics.printf("O", VIRTUAL_WIDTH / 2 - 250 / 2 + 80 + 30 + 24, 10, 48, "left")
    -- white
    love.graphics.setColor(0,0,0)
    love.graphics.printf("R", VIRTUAL_WIDTH / 2 - 250 / 2 + 80 + 30 + 24 + 30, 10, 48, "left")
    
    -- black
    love.graphics.setColor(0,0,0)
    love.graphics.printf("CATCH", VIRTUAL_WIDTH / 2 - 250 / 2, 10 + 40, 250, "center")

    -- draw player 
    if 0 < titleTimer and titleTimer < titleINTERVAL * 1 then 
        love.graphics.setColor(0,0,0)
    elseif titleINTERVAL * 1 < titleTimer and titleTimer < titleINTERVAL * 2 then 
        love.graphics.setColor(255 / 255, 36 / 255, 0)
    elseif titleINTERVAL * 2 < titleTimer and titleTimer < titleINTERVAL * 3 then 
        love.graphics.setColor(0, 168 / 255, 107 / 255)
    elseif titleINTERVAL * 3 < titleTimer and titleTimer < titleINTERVAL * 4 then 
        love.graphics.setColor(0, 128 / 255, 1)
    elseif titleINTERVAL * 4 < titleTimer and titleTimer < titleINTERVAL * 5 then 
        love.graphics.setColor(229 / 255, 228 / 255, 226 / 255)
    end

    love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - 80, 30, 6, 60)
    love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 + 70 , 30, 6, 66)
    love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - 80, 90, 150, 6)
end

function titleUpdate(dt)
    if titleTimer < titleINTERVAL * 5 then
        titleTimer = titleTimer + dt
    else
        titleTimer = 0
    end
end