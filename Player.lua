Player = Class()

function Player:init()
    self.height = 30
    self.width = 50
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = 210

    self.wall = 5
    self.dx = 200

    -- lives
    self.lives = {
        number = 5,
        numberX = 4,
        numberY = 4 + 16 + 3,
        visual = love.graphics.newImage("lives/Picture1.png"),
        visualX = 4 + 8,
        visualY = 4 + 16 + 1
    }

    self.colour = "black"

    -- abilities 
    self.dashTimer = 0
    self.hasDash = false
    self.dashVisual = {
        online = love.graphics.newImage("dash/dash on.png"),
        offline = love.graphics.newImage("dash/dash off.png"),
        x = 4,
        y = 4
    }

    -- mouse controls
    self.mouseX = 0

    -- track score
    self.score = {
        score = 0,
        x = VIRTUAL_WIDTH - 48,
        y = 4,
        limit = 48,
        align = "right"
    }

    -- font
    self.font = love.graphics.newFont("font/font.ttf", 16)
end

function Player:update(dt)
    if love.mouse.isDown(1) or love.mouse.isDown(2) then 
        self.mouseX = love.mouse.getX()
    end
    
    -- left click to dash 
    self:checkDash(dt)
    if love.mouse.isDown(1) and self.hasDash == true then 
        self:dash()
    end

    -- right click to move
    if love.mouse.isDown(2) then 
        self:move(dt)
    end

end

function Player:render()
    -- draw dash ability status
    if self.hasDash == true then 
        love.graphics.draw(self.dashVisual.online, self.dashVisual.x, self.dashVisual.y)
    else
        love.graphics.draw(self.dashVisual.offline, self.dashVisual.x, self.dashVisual.y)
    end
    
    -- draw how many lives left
    love.graphics.setFont(self.font)
    love.graphics.print(tostring(self.lives.number), self.lives.numberX, self.lives.numberY)
    love.graphics.draw(self.lives.visual, self.lives.visualX, self.lives.visualY)

    -- draw score
    love.graphics.printf(tostring(self.score.score), self.score.x, self.score.y, self.score.limit, self.score.align)

    -- left edge
    self:setColour()
    love.graphics.rectangle("fill", self.x, self.y, self.wall, self.height)
    -- bot edge
    love.graphics.rectangle("fill", self.x, self.y + self.height - self.wall, self.width, self.wall)
    -- right edge 
    love.graphics.rectangle("fill", self.x + self.width - self.wall, self.y, self.wall, self.height)
end

function Player:move(dt)
    local moveX = math.max(0, math.min(VIRTUAL_WIDTH - self.width, self.mouseX / 1280 * 432  - self.width / 2)) 

    -- stop jittery movements 
    if moveX < self.x - 1 or moveX > self.x + 1 then 
        if moveX > self.x then
            self.x = self.x + self.dx * dt 
        elseif moveX < self.x then 
            self.x = self.x - self.dx * dt 
        end 
    end
end

function Player:dash()
    self.x = math.max(0, math.min(VIRTUAL_WIDTH - self.width, self.mouseX / 1280 * 432  - self.width / 2)) 
    self.hasDash = false
    self.dashTimer = 0
end

function Player:setColour()
    -- default black
    love.graphics.setColor(0,0,0)
    self.colour = "black"

    -- white
    if love.keyboard.isDown("q") and love.keyboard.isDown("w") and love.keyboard.isDown("e") then
        love.graphics.setColor(229 / 255, 228 / 255, 226 / 255)
        self.colour = "white"
    -- red
    elseif love.keyboard.isDown("q") then
        love.graphics.setColor(255 / 255, 36 / 255, 0)
        self.colour = "red"
    -- green
    elseif love.keyboard.isDown("w") then
        love.graphics.setColor(0, 168 / 255, 107 / 255)
        self.colour = "green"
    -- blue
    elseif love.keyboard.isDown("e") then
        love.graphics.setColor(0, 128 / 255, 1)
        self.colour = "blue"
    end
end

-- tracks the cooldown of dash
function Player:checkDash(dt)
    self.dashTimer = self.dashTimer + dt

    if self.dashTimer >= 3 and self.hasDash == false then 
        self.hasDash = true
    end 
end
