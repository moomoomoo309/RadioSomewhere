local parser = require "parser"
local shine = require "shine"
local camera = require "camera"
require "gooi"
local gooi = gooi
local moan = require "Moan"
local drawMainScreen = require "mainScreen"

function love.load()
    moan.speak("???????????", {"?????????"})
end

function love.draw()
    gooi.draw()
    drawMainScreen()
end

function love.update(dt)
    moan.update(dt)
end

function love.keypressed(key, scancode, isrepeat)
    moan.keypressed(key)
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




