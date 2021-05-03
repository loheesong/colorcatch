Ball = Class()

function Ball:init()
    self.x = math.random(0, VIRTUAL_WIDTH - 16)
    self.y = -16
    self.width = 16
    self.height = 16
    
    repeat 
        self.dx = math.random(-100,100)
    until self.dx > 30 or self.dx < -30

    self.dy = math.random(30,80)
    
    -- size of each ball is 16 pixels 
    self.colourVisual = {
        black = love.graphics.newImage("ball colour/black.png"),
        red = love.graphics.newImage("ball colour/red.png"),
        green = love.graphics.newImage("ball colour/green.png"),
        blue = love.graphics.newImage("ball colour/blue.png"),
        white = love.graphics.newImage("ball colour/white.png") 
    }
    self.colourKey = {"black", "red", "green", "blue", "white"}
    self.colour = math.random(#self.colourKey)
    self.colourImage = self.colourVisual[self.colourKey[self.colour]]

    -- tells another function to remove reference to ball that has gone past the top or bottom edge of screen 
    self.toDelete = false

    -- remove a life from player
    self.minusLife = false

    -- sounds for ball 
    self.sounds = {
        bounce = love.audio.newSource("sounds/bounce.wav", "static"),
        loseLife = love.audio.newSource("sounds/lose life.wav", "static"),
        score = love.audio.newSource("sounds/score.wav", "static")
    }
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    
    -- bounce when hitting left and right edges of screen
    if self.x < 0 then 
        self.x = 0
        self.dx = -self.dx
        self.sounds.bounce:play()
    end
    if self.x + self.width > VIRTUAL_WIDTH then 
        self.x = VIRTUAL_WIDTH - self.width
        self.dx = -self.dx
        self.sounds.bounce:play()
    end

    if self.y >= VIRTUAL_HEIGHT or self.y + self.height <= 0 then 
        self.toDelete = true
    end

    if self.y >= VIRTUAL_HEIGHT then 
        self.minusLife = true
        self.sounds.loseLife:play()
    end
end

function Ball:render()
    --love.graphics.draw(drawable,x,y,r,sx,sy,ox,oy)
    love.graphics.draw(self.colourImage, self.x, self.y)
end

-----------------------------------COLLISION DETECTION---------------------------------------------
function Ball:score(player)
    -- top edge of ball is below top edge of player and
    -- bottom edge of ball is above than bottom inner wall of player and
    -- left edge of ball is right of left inner wall of player and 
    -- right edge of ball is left of right inner wall of player and
    if self.y > player.y and 
        self.y + self.height < player.y + player.height - player.wall and 
        self.x > player.x + player.wall and
        self.x < player.x + player.width - player.wall then 
        self.toDelete = true
        return true
    end
    
    -- if above either not true 
    return false 
end

function Ball:collideSide(player)

    -- collision with internal edges 
    if self.y + self.height > player.y and 
        self.y < player.y and 
        self.x + self.width / 2 > player.x + player.wall and 
        self.x + self.width / 2 < player.x + player.width - player.wall then

        if self.x < player.x + player. wall and 
            self.x + self.width < player.x + player.width - player.wall then 

            if self.dx <= 0 then 
                self.dx = math.random(80, 100)
            elseif self.dx > 0 then
                self.dx = 1.2 * self.dx
            end

            -- set ball to always be right once touching for smoother "animation"
            self.x = player.x + player.wall
            self.sounds.bounce:play()
        end

        if self.x + self.width > player.x + player.width - player.wall and
            self.x < player.x + player.width - player.wall then 

            if self.dx >= 0 then 
                self.dx = math.random(-100, -80)
            elseif self.dx < 0 then
                self.dx = 1.2 * self.dx
            end

            -- set ball to always be left once touching for smoother "animation"
            self.x = player.x + player.width - player.wall - self.width
            self.sounds.bounce:play()
        end 
    -- collision with top left and right edges of player
    elseif self.y + self.height > player.y and self.y + self.height < player.y + 2 and self.y < player.y then

        -- left side of player
        -- left, mid, right (order of the or statements)
        if self.x + self.width > player.x and self.x + self.width < player.x + player.wall or
            self.x < player.x and self.x + self.width > player.x + player.wall or
            self.x > player.x and self.x < player.x + player.wall then 
            
            self.dy = -self.dy
            self.sounds.bounce:play()
        end

        -- right side of player 
        -- left, mid, right (order of the or statements)
        if self.x + self.width > player.x + player.width - player.wall and self.x + self.width < player.x + player.width or
            self.x < player.x + player.width - player.wall and self.x + self.width > player.x + player.width or 
            self.x > player.x + player.width - player.wall and self.x < player.x + player.width then
            
            self.dy = -self.dy
            self.sounds.bounce:play()
        end
        
    -- collision with left or right edge of player
    -- case 1: top edge of player is between top and bottom edge of ball
    -- case 2: entire ball is between top and bottom edge of player
    -- case 3: bottom edge of player is between top and bottom edge of ball
    elseif self.y + self.height > player.y and self.y < player.y or
        player.y < self.y and player.y + player.height > self.y + self.height or
        self.y < player.y + player.height and self.y + self.height > player.y + player.height then 

        -- ball is clipping into left side 
        if self.x + self.width > player.x and self.x < player.x then 
            if self.dx >= 0 then 
                self.dx = math.random(-100, -80)
            elseif self.dx < 0 then
                self.dx = 1.2 * self.dx
            end
            -- set ball to always be left once touching for smoother "animation"
            self.x = player.x - self.width
            self.sounds.bounce:play()
        end

        -- ball is clipping into right side 
        if self.x < player.x + player.width and self.x + self.width > player.x + player.width then 
            if self.dx <= 0 then 
                self.dx = math.random(80, 100)
            elseif self.dx > 0 then
                self.dx = 1.2 * self.dx
            end
            -- set ball to always be right once touching for smoother "animation"
            self.x = player.x + player.width
            self.sounds.bounce:play()
        end
    end
end

function Ball:collideBall(anotherBall, dt)
    local collide = true 

    if self.x > anotherBall.x + anotherBall.width or anotherBall.x > self.x + self.width then 
        collide = false
    end
    if self.y > anotherBall.y + anotherBall.height or anotherBall.y > self.y + self.height then
        collide = false
    end 

    local predict_selfX = self.x
    local predict_selfY = self.y
    local predict_anotherX = anotherBall.x
    local predict_anotherY = anotherBall.y 
    local multiple = 2

    if collide == true then 
        self.dx = -self.dx
        self.dy = -self.dy
        anotherBall.dx = -anotherBall.dx
        anotherBall.dy = -anotherBall.dy

        while collide == true do 
            -- predict locations of both
            predict_selfX = predict_selfX + self.dx * dt
            predict_selfY = predict_selfY + self.dy * dt
            predict_anotherX = predict_anotherX + anotherBall.dx * dt
            predict_anotherY = predict_anotherY + anotherBall.dy * dt

            -- if balls not intersecting, break (for normal scenarios)
            if predict_selfX > predict_anotherX + anotherBall.width or predict_anotherX > predict_selfX + self.width then 
                break 
            end 
            if predict_selfY > predict_anotherY + anotherBall.height or predict_anotherY > predict_selfY + self.height then
                break
            end

            -- increment dt and multiple 
            dt = dt * multiple
            multiple = multiple + 1
        end

        -- if predictions done on self and another ball, update to those coordinates 
        if predict_selfX ~= self.x or 
            predict_selfY ~= self.y or 
            predict_anotherX ~= anotherBall.x or 
            predict_anotherY ~= anotherBall.y then 
            
            self.x = predict_selfX
            self.y = predict_selfY
            anotherBall.x = predict_anotherX
            anotherBall.y = predict_anotherY
        end

        self.sounds.bounce:play()
    end
end
