local parser = require "parser"
require "gooi"
local gooi = gooi
local moan = require "Moan"
local drawMainScreen = require "mainScreen"
local audioHandler = require "audioHandler"
local gui = require "game-gui.gui"
local scheduler = require "scheduler"

io.stdout:setvbuf "no"

gui.init()

local function randomstring(len)
    local str = {}
    for i = 1, len do
        str[i] = string.char(string.byte "A" + math.floor(math.random(0, 25)))
    end
    return table.concat(str)
end

local currentParser, script

gui.init()
function init()
    gui.init()
end

function love.load()
    moan.speak("", { "" })
    currentParser, script = parser.parse "assets.drinkingBuddyScript"
    parser.unlock()
    scheduler.resume "default"
end

function love.draw()
    drawMainScreen()
    gooi.draw()
end

function love.update(dt)
    scheduler.update(dt)
    moan.update(dt)
    gooi.update(dt)
end

function advanceDialogue()
    if not parser.locked() then
        if not moan.typing then
            if coroutine.status(currentParser) ~= "dead" then
                local success, msg = coroutine.resume(currentParser, script, currentParser)
                if msg and #msg > 195 then
                    print("msg too long!", msg:sub(1, 195), msg:sub(196))
                end
                if not success then
                    print(msg)
                elseif msg then
                    moan.speak("", { msg })
                    moan.keypressed "space"
                else
                    moan.keypressed "space"
                end
            else
                print "ded"
            end
        else
            moan.keypressed "space"
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
    if key == "space" then
        advanceDialogue()
    else
        moan.keypressed(key)
    end
    if key == "p" then
        gui.pause()
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




