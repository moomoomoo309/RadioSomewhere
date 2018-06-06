w, h = love.graphics.getDimensions()

serpent = require "serpent"
local parser = require "parser"
require "gooi"
local gooi = gooi
local moan = require "Moan"
local drawMainScreen = require "mainScreen"
local audioHandler = require "audioHandler"
local gui = require "game-gui.gui"
local scheduler = require "scheduler"
local sprite = require "sprite"
local moonshine = require "moonshine"


optionLocked = false
scanlineSpeed = .05

io.stdout:setvbuf "no"

endStr = "\t\t\t\tT R A N S M I S S I O N\tO V E R"

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
    x = w * 178 / 1920,
    y = h * 241 / 1080,
    w = w * 525 / 1920,
    h = h * 441 / 1080,
    imagePath = "assets/titlecardstatic.png"
}

local cancelMusicLoop

local function init()
    gui.init()
    parseScript "assets.drinkingBuddyScript"
    moan.speak("", { "\t\t\tI N C O M I N G\t\tT R A N S M I S S I O N \n\n\n\n\t\t\t\t\t\t[SPACE TO CONTINUE]" })
    cancelMusicLoop = audioHandler.loop("Openeraudio", nil, 0)
    scheduler.everyCondition(function() return gui.currentMenu() ~= "pause" end, function()
        offsetY = offsetY + scanlineSpeed
        imageShader.scanlines.setters.offsetY(offsetY)
        textShader.scanlines.setters.offsetY(offsetY)
    end, nil, "pauseable")
end

function love.load()
    parser.unlock()
    scheduler.resume "default"
    init()
end

local function queueDialogueOptions()
    print "Queueing dialogue options..."

    print(serpent.block(remainingTransmissions))
    moan.speak("", { "Select Incoming Transmission:" }, { options = remainingTransmissions })
    moan.speak("", { "" })

    print "Locking parser..."
    parser.lock()
    scheduler.after(.75, function()
        parser.unlock()
        print "Unlocking parser..."
    end)
end

local currentScript

function parseScript(path)
    if not path and currentScript then
        currentParser, script = nil, nil
        print "Clearing script..."
        face:setImagePath("assets/fuzz.png", true)
        for i = 1, #remainingTransmissions do
            if not remainingTransmissions[i] then
                break
            end
            if remainingTransmissions[i][1]:find(currentScript, nil, true) then
                table.remove(remainingTransmissions, i)
            end
        end
        moan.speak("", { "" })
        queueDialogueOptions()
    elseif currentScript then
        print "Parsing script..."
    else
        print "Initializing first script..."
    end
    if type(path) == "string" then
        currentParser, script = parser.parse(path)
    elseif type(path) == "table" then
        currentParser, script = parser.parseTbl(path)
    end
end

local picked = false

remainingTransmissions = {
    { "Lost Boy", function()
        currentScript = "Lost Boy"
        print "Lost boy picked!"
        face:setImagePath("assets/oldlady.png", true)
        cancelMusicLoop()
        cancelMusicLoop = audioHandler.loop "Stardust Dreams"
        parseScript "assets.lostBoyScript"
        scheduler.after(.01, function()
            love.keypressed "space"
        end)
    end },
    { "Offer", function()
        currentScript = "Offer"
        print "Offer picked!"
        face:setImagePath("assets/noface.png", true)
        cancelMusicLoop()
        cancelMusicLoop = audioHandler.loop "consumartInSpace"
        parseScript "assets.offerScript"
        scheduler.after(.01, function()
            love.keypressed "space"
        end)
    end },
    { "Questions", function()
        currentScript = "Questions"
        print "Questions picked!"
        face:setImagePath("assets/girl.png", true)
        cancelMusicLoop()
        cancelMusicLoop = audioHandler.loop "Space Debris"
        parseScript "assets.questionsScript"
        scheduler.after(.01, function()
            love.keypressed "space"
        end)
    end }
}
local firstScript = true

offsetY = 0
local function drawGame()
    if not atTitleScreen then
        drawMainScreen()
    else
        if gui.currentMenu() == "main_menu" then
            titlecard:draw()
            imageShader.draw(function()
                titlecardStatic:draw()
            end)
            textShader.draw(function()
                gooi.draw "main_menu"
                love.graphics.push()
                love.graphics.translate(120 * h / 720, 17 * h / 720)
                love.graphics.shear(-.2, 0)
                gooi.draw "main_menu_title"
                love.graphics.pop()
                love.graphics.push()
                love.graphics.shear(-.055, -.03)
                love.graphics.rotate(math.rad(-2))
                love.graphics.translate(30 * h / 1080, 35 * h / 1080)
                gooi.draw "settings"
                love.graphics.pop()
            end)
        end
    end
    if exitOpen then
        local oldColor = {love.graphics.getColor()}
        love.graphics.setColor(0, 0, 0, .35)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(oldColor)
        textShader.draw(gooi.draw)
    end
    if not gui.currentMenu() then
        if databaseBtn.visible then
            gooi.draw "database"
        end
        gooi.draw "main_game"
    end
end

function love.draw()
    if not pauseDone then
        pauseShader.draw(drawGame)
    else
        drawGame()
    end
    if gui.currentMenu() == "pause" then
        gooi.draw "pause"
    end
    love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 10, 10)
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

local firstRun = true
function advanceDialogue()
    if not parser.locked() then
        if not moan.typing then
            print "Advancing dialogue"
            if currentParser and coroutine.status(currentParser) ~= "dead" then
                if firstRun then
                    cancelMusicLoop()
                    cancelMusicLoop = audioHandler.loop "Mountain Goats Tallahassee instrumental cover"
                    face:setImagePath("assets/thomas.png", true)
                    firstRun = false
                end
                print "Resuming coroutine..."
                local success, msg = coroutine.resume(currentParser, script, currentParser)
                if gameDebug and msg and #msg > 195 then
                    print("msg too long!", msg:sub(1, 195), "!", msg:sub(196))
                end
                if not success then
                    print("Error!", success, msg)
                elseif msg then
                    moan.speak("", { msg })
                    print(("msg=%s"):format(msg))
                    moan.keypressed "space"
                else
                    moan.keypressed "space"
                end
                if currentParser and coroutine.status(currentParser) == "dead" then
                    print "Queueing dialogue options..."
                    queueDialogueOptions()
                end
            else
                print "opts"
                print(serpent.block(moan.allMsgs[moan.currentMsgInstance]))
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




