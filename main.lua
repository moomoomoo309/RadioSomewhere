local parser = require "parser"
require "gooi"
local gooi = gooi
local moan = require "Moan"
local drawMainScreen = require "mainScreen"
local audioHandler = require "audioHandler"
local gui = require "game-gui.gui"
local scheduler = require "scheduler"
local sprite = require "sprite"

local w, h = love.graphics.getDimensions()

optionLocked = false

io.stdout:setvbuf "no"


local currentParser, script
local atTitleScreen = true
local titlecard = sprite {
    x=0,
    y=0,
    w=w,
    h=h,
    imagePath = "assets/titlecard.png"
}

local function init()
    gui.init()
end

function love.load()
    moan.speak("", { "" })
    currentParser, script = parser.parse "assets.drinkingBuddyScript"
    parser.unlock()
    scheduler.resume "default"
    init()
end

function love.draw()
    if not atTitleScreen then
        drawMainScreen()
    else
        titlecard:draw()
        gooi.draw "main_menu"
    end
    gooi.draw()
end

function love.update(dt)
    if atTitleScreen and not gui.currentMenu() then
        atTitleScreen = false
    end
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
                    print("msg too long!", msg:sub(1, 195), "!", msg:sub(196))
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
    if not atTitleScreen then
        if key == "escape" then
            love.event.quit()
        end
        if not optionLocked then
            if key == "space" then
                advanceDialogue()
            else
                moan.keypressed(key)
            end
        end
        if key == "p" then
            gui.pause()
        end
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




