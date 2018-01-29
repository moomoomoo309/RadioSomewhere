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
    x = 0,
    y = 0,
    w = w,
    h = h,
    imagePath = "assets/titlecardemptycrt.png"
}

local titlecardStatic = sprite {
    x=0,
    y=0,
    w=w,
    h=h,
    imagePath = "assets/titlecardstatic.png"
}
local titlecardStaticNoiseShader = shine.noise()
scheduler.everyCondition(function() return titlecardStatic.visible end, function() titlecardStaticNoiseShader:set("iTime", love.timer.getTime()*1000) end)
staticShader = titlecardStaticNoiseShader:chain(imageScanlineEffect)

local cancelMusicLoop

local function init()
    gui.init()
    parseScript "assets.drinkingBuddyScript"
    cancelMusicLoop = audioHandler.loop("Openeraudio", nil, 0)
end

function love.load()
    parser.unlock()
    scheduler.resume "default"
    init()
end

function parseScript(path)
    if not path then
        currentParser, script = nil, nil
        face:setImagePath("assets/fuzz.png", true)
        moan.speak("", {""})
    end
    currentParser, script = parser.parse(path)
end

local picked = false

remainingTransmissions = {
    {"Lost Boy", function()
        print "Lost boy picked!"
        face:setImagePath("assets/oldlady.png", true)
        cancelMusicLoop()
        cancelMusicLoop = audioHandler.loop("Stardust Dreams")
        parseScript("assets.lostBoyScript")
        scheduler.after(.01, function() love.keypressed "space" end)
    end},
    {"Offer", function()
        if not picked then
            picked = true
            print "Offer picked!"
            face:setImagePath("assets/noface.png", true)
            cancelMusicLoop()
            cancelMusicLoop = audioHandler.loop("consumartInSpace")
            parseScript("assets.offerScript")
            scheduler.after(.01, function() love.keypressed "space" end)

        end
    end},
    {"Questions", function()
        print "Questions picked!"
        face:setImagePath("assets/girl.png", true)
        cancelMusicLoop()
        cancelMusicLoop = audioHandler.loop("Space Debris")
        parseScript("assets.questionsScript")
        scheduler.after(.01, function() love.keypressed "space" end)
    end}
}


local function drawGame()
    if not atTitleScreen then
        drawMainScreen()
        if gui.currentMenu() == "pause" then
            gooi.draw "pause"
        end
    else
        if gui.currentMenu() == "main_menu" then
            titlecard:draw()
            local oldColor = {love.graphics.getColor()}
            love.graphics.setColor(oldColor[1], oldColor[2], oldColor[3], 128)
            titlecardStatic:draw()
            staticShader:draw(function() titlecardStatic:draw() end)
            love.graphics.setColor(oldColor)
            textShader:draw(function()
                gooi.draw "main_menu"
                love.graphics.push()
                love.graphics.translate(120 * h / 720, 17 * h / 720)
                love.graphics.shear(-.2, 0)
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
            gooi.draw "database"
        end)
        gooi.draw "main_game"

    end
end

function love.draw()
    drawGame()
end

local scanlineSpeed = 3

function love.update(dt)
    if atTitleScreen and not gui.currentMenu() then
        atTitleScreen = false
        moan.speak("", { " I N C O M I N G  T R A N S M I S S I O N \n\n\n\n\t\t\t[SPACE TO CONTINUE]" })
    end
    scheduler.update(dt)
    if gui.currentMenu() ~= "pause" then
        moan.update(dt)
    end
    gooi.update(dt)
    imageScanlineEffect:set("y_offset", imageScanlineEffect._y_offset + dt * scanlineSpeed)
    textScanlineEffect:set("y_offset", textScanlineEffect._y_offset + dt * scanlineSpeed)
end

local firstRun = true
function advanceDialogue()
    if not parser.locked() then
        if not moan.typing then
            if currentParser and coroutine.status(currentParser) ~= "dead" then
                if firstRun then
                    cancelMusicLoop()
                    cancelMusicLoop = audioHandler.loop "Mountain Goats Tallahassee instrumental cover"
                    face:setImagePath("assets/thomas.png", true)
                end
                firstRun = false
                local success, msg = coroutine.resume(currentParser, script, currentParser)
                if gameDebug and msg and #msg > 195 then
                    print("msg too long!", msg:sub(1, 195), "!", msg:sub(196))
                end
                if not success then
                    print("Error!", success, msg)
                elseif msg then
                    moan.speak("", { msg })
                    moan.keypressed "space"
                else
                    moan.keypressed "space"
                end
            elseif not moan.showingOptions then
                print "Locking parser..."
                parser.lock()

                scheduler.after(.75, function() parser.unlock() print"Unlocking parser..." end)
                print "Queueing dialogue options..."
                moan.speak("", {"Select Incoming Transmission:"}, {options=remainingTransmissions})
                moan.speak("", {""})
                if not currentParser then
                    moan.keypressed "space"
                end
            else
                moan.keypressed "space"
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
    if not atTitleScreen then
        if not optionLocked then
            if key == "space" then
                print"Advancing dialogue"
                advanceDialogue()
            else
                print "Running moan.keypressed"
                moan.keypressed(key)
            end
        else
            print "Option locked"
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




