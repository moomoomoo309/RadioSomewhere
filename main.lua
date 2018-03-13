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

serpent = require "serpent"

local w, h = love.graphics.getDimensions()

optionLocked = false

io.stdout:setvbuf "no"

endStr = "  T R A N S M I S S I O N        O V E R"

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
local titlecardStaticNoiseShader = shine.filmgrain()
titlecardStaticNoiseShader.opacity = .5
staticShader = titlecardStaticNoiseShader:chain(imageScanlineEffect)

local cancelMusicLoop

local function init()
    gui.init()
    parseScript "assets.drinkingBuddyScript"
    moan.speak("", { " I N C O M I N G  T R A N S M I S S I O N \n\n\n\n\t\t\t[SPACE TO CONTINUE]" })
    cancelMusicLoop = audioHandler.loop("Openeraudio", nil, 0)
end

function love.load()
    parser.unlock()
    scheduler.resume "default"
    init()
end

local function convertRemainingTransmissions(tbl)
    local newTbl = {}
    for k,v in pairs(tbl) do
        newTbl[v[1]] = v[2]
    end
    return {newTbl}
end

local function queueDialogueOptions()
    print "Queueing dialogue options..."

    print(serpent.block(remainingTransmissions))
    moan.speak("", { "Select Incoming Transmission:" }, { options = remainingTransmissions })
    moan.speak("", { "" })

    print "Locking parser..."
    parser.lock()
    scheduler.after(.75, function()
        parser.unlock() print "Unlocking parser..."
    end)
end

local currentScript

function parseScript(path)
    if not path and currentScript then
        currentParser, script = nil, nil
        print "Clearing script..."
        face:setImagePath("assets/fuzz.png", true)
        if #remainingTransmissions > 0 then
            promptTitle = "Choose Incoming Transmission:"
            currentParser, script = parser.parseTbl(convertRemainingTransmissions(remainingTransmissions))
        end
        for i = 1,#remainingTransmissions do
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
        cancelMusicLoop = audioHandler.loop("Stardust Dreams")
        parseScript("assets.lostBoyScript")
        promptTitle = ""
        scheduler.after(.01, function() love.keypressed "space" end)
    end},
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
        promptTitle = ""
        scheduler.after(.01, function()
            love.keypressed "space"
        end)
    end }
}
local firstScript = true


local function drawGame()
    if not atTitleScreen then
        drawMainScreen()
        if gui.currentMenu() == "pause" then
            gooi.draw "pause"
        end
    else
        if gui.currentMenu() == "main_menu" then
            titlecard:draw()
            staticShader:draw(function()
                titlecardStatic:draw()
            end)
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
        if databaseBtn.visible then
            gooi.draw "database"
        end
        gooi.draw "main_game"
    end
end

function love.draw()
    drawGame()
    love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end

local scanlineSpeed = 5

function love.update(dt)
    if atTitleScreen and not gui.currentMenu() then
        atTitleScreen = false
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
                if currentParser and coroutine.status(currentParser) == "dead" then
                    queueDialogueOptions()
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
                print "Advancing dialogue"
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




