local parser = require "parser"
local shine = require "shine"
local camera = require "camera"
require "gooi"
local gooi = gooi
local moan = require "Moan"
local drawMainScreen = require "mainScreen"

io.stdout:setvbuf "no"

local function randomstring(len)
    local str = {}
    for i = 1, len do
        str[i] = string.char(string.byte "A" + math.floor(math.random(0, 25)))
    end
    return table.concat(str)
end

function love.load()
    moan.speak("?", { randomstring(60) })
    moan.speak("?", { randomstring(60) })
    moan.speak("?", { randomstring(60) })
    moan.speak("?", { randomstring(60) })
    moan.speak("?", { randomstring(60) })
end

function love.draw()
    local oldColor = { love.graphics.getColor() }
    love.graphics.setColor(128, 128, 128)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
    love.graphics.setColor(oldColor)
    drawMainScreen()
    gooi.draw()
end

function love.update(dt)
    moan.update(dt)
    gooi.update(dt)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
    if key == "space" then
        moan.advanceMsg()
    end
end

function love.mousepressed(x, y, button)
    gooi.pressed()
end

function love.mousereleased(x, y, button)
    gooi.released()
end

function love.mousemoved(x, y)
    gooi.mousemoved(x, y)
end




