local parser = require "parser"
require "gooi"
local gooi = gooi
local moan = require "Moan"
local drawMainScreen = require "mainScreen"
local audioHandler = require "audioHandler"
local gui = require "game-gui.gui"
local scheduler = require "scheduler"
local sprite = require "sprite"
local shine = require "shine"

local w, h = love.graphics.getDimensions()

local gaussian = shine.gaussianblur()
gaussian.sigma = 20

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

local function drawGame()
    if not atTitleScreen then
        drawMainScreen()
        if gui.currentMenu() == "pause" then
            gooi.draw "pause"
        end
    else
        if gui.currentMenu() == "main_menu" then
            titlecard:draw()
            textShader:draw(function()
                gooi.draw "main_menu"
                love.graphics.push()
                love.graphics.translate(120 * h / 720, 17 * h / 720)
                love.graphics.shear(-.2,0)
                gooi.draw "main_menu_title"
                love.graphics.pop()
            end)
        end
        imageShader:draw(function()
            love.graphics.push()
            love.graphics.shear(-.055, -.03)
            love.graphics.rotate(math.rad(-2))
            love.graphics.translate(30 * h / 1080, 35 * h / 1080)
            gooi.draw "settings"
            love.graphics.pop()
        end)
    end
    if exitOpen then
        imageShader:draw(function()
            gooi.draw()
        end)
    end
    if not gui.currentMenu() then
        gaussian:draw(function()
            gooi.draw "main_game"
        end)
    end
end

function love.draw()
    drawGame()
end


function love.update(dt)
    if atTitleScreen and not gui.currentMenu() then
        atTitleScreen = false
    end
    scheduler.update(dt)
    if gui.currentMenu() ~= "pause" then
        moan.update(dt)
    end
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
        local currentMenu = gui.currentMenu()
        if key == "p" and currentMenu ~= "main_menu" and currentMenu ~= "settings" then
            gui.togglePause()
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




