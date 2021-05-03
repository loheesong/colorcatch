Button = Class()

--[[ Button({
    x = ,
    y = ,
    width = ,
    height = ,
    text = {
        text = ,
        font = ,

        red = ,
        green = ,
        blue = ,
        alpha = 
    },
    colour = {
        red = ,
        green = ,
        blue = ,
        alpha = 
    }
})
]]
released = false
function Button:init(param)
    self.x = param.x
    self.y = param.y
    self.width = param.width
    self.height = param.height

    self.text = param.text or {
        text = "test",
        font = love.graphics.newFont('font/font.ttf', 16),

        red = 0,
        green = 0,
        blue = 0,
        alpha = 1
    }

    -- a table of RGB, default to white for button
    self.colour = param.colour or {
        red = 1,
        green = 1, 
        blue = 1,
        alpha = 1
    }

    -- for clicking button
    self.mouseX = 0
    self.mouseY = 0
    self.leftClick = false
end

-- returns next gameState gameState when clicked on
function Button:whenClicked(currentGameState, nextGameState)
    if love.mouse.isDown(1) then 
        self.mouseX = love.mouse.getX() / 1280 * 432
        self.mouseY = love.mouse.getY() / 720 * 243
        -- add wait
        if self.x < self.mouseX and self.mouseX < self.x + self.width and
            self.y < self.mouseY and self.mouseY < self.y + self.height then 
            wait(0)
            return nextGameState
        else
            return currentGameState
        end
    else
        return currentGameState
    end
end

function Button:render()
    -- draw button
    love.graphics.setColor(self.colour.red, self.colour.green, self.colour.blue, self.colour.alpha)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- draw text on button
    love.graphics.setFont(self.text.font)
    love.graphics.setColor(self.text.red, self.text.green, self.text.blue, self.text.alpha)
    love.graphics.printf(self.text.text, self.x, self.y, self.width, "center")
end
--love.graphics.print(text,x,y,r,sx,sy,ox,oy)

