require "gooi"
local moan = require "Moan"
local scheduler = require "scheduler"

local height = love.graphics.getHeight()
local width = love.graphics.getWidth()

local menuButton_xLocation = width * 360 / 960
local menuButton_yLocation = height * 340 / 540
local menuButton_xIncrement = height / 16
local menuButtonHeight = height / 16
local menuButtonWidth = width / 10

local settingsPanelComponents
local fontColor = { 255, 255, 255 }

gameDebug = true
local paused = false
exitOpen = false

gooi.setStyle({ font = love.graphics.newFont("assets/VT323-Regular.ttf", 30 * height / 720) })

local pauseLabel

--- Pause toggle menu
--- @return nil
local function togglePause()
    paused = not paused
    pauseLabel:setVisible(paused)
    print(paused)
end

--- Visibility toggle for the settings screen
--- @return nil
local function toggleVisible()
    for i = 1, #settingsPanelComponents do
        settingsPanelComponents[i].visible = not settingsPanelComponents[i].visible
    end
end

local startBtn
local databaseBtn

function startBlinking()
    return scheduler.every(.8,function()
        if databaseBtn.style.bgColor[4] == 0 then
            databaseBtn.events.hover(databaseBtn)
        else
            databaseBtn.events.unhover(databaseBtn)
        end
    end)
end

--- Initializer to create all the gui objects
--- @return nil
local function init()
    if gameDebug == true then
        local debugButton = gooi.newButton({
            text = "debug",
            x = width / 20,
            y = height / 20,
            w = 150,
            h = 200
        }):onRelease(function()
            gooi.setGroupVisible("main_menu", true)
            if settingsPanelComponents[1].visible == false then
                toggleVisible()
            end
        end)
    end

    --[[-------------------------
    -------Main Menu Buttons-----
    ----------------------------]]
    startBtn = gooi.newButton({
        text = "Start",
        x = menuButton_xLocation,
        y = menuButton_yLocation,
        w = menuButtonWidth,
        h = menuButtonHeight,
        group = "main_menu",
    })   :onRelease(function()
        gooi.setGroupVisible("main_menu", false)
        --Make sure that the settings are not visible on game start
        if settingsPanelComponents[1].visible then
            toggleVisible()
        end
    end) :left()

    startBtn.textColor = fontColor

    local settingsBtn = gooi.newButton({
        text = "Settings",
        x = menuButton_xLocation,
        y = menuButton_yLocation + menuButton_xIncrement,
        w = menuButtonWidth,
        h = menuButtonHeight,
        group = "main_menu"
    }):onRelease(function(self)
        if self.visible then
            toggleVisible()
        end
    end):left()

    local exitBtn = gooi.newButton({
        text = "Quit",
        x = menuButton_xLocation,
        y = menuButton_yLocation + (menuButton_xIncrement * 2),
        w = menuButtonWidth,
        h = menuButtonHeight,
        group = "main_menu",
    --icon = "imgs/exit.png"
    }):onRelease(function(self)
        if self.visible then
            exitOpen = true
            gooi.confirm {
                text = "Are you sure?",
                ok = function()
                    love.event.quit()
                end,
                cancel = function()
                    exitOpen = false
                end,
                group = "main_menu"
            }
        end
    end)      :left()


    --[[---------------------------
    ----------Menu Labels----------
    ------------------------------]]

    local radioTitleLbl = gooi.newLabel({
        text = "Radio Somewhere",
        x = width * 340 / 960,
        y = height * 259 / 960,
        w = width / 10,
        h = height / 10,
        group = "main_menu_title",
    }):setStyle({ fgColor = { 255, 110, 255 }, font = love.graphics.newFont("assets/VT323-Regular.ttf", 100 * height / 720) })

    --[[----------------------------------
    -------Settings Panel Generator-------
    -------------------------------------]]

    local settingsPanel = gooi.newPanel {
        x = width * 100 / 960,
        y = height * 130 / 540,
        w = width / 4,
        h = height / 3,
        layout = "grid 6x2"
    }

    local file
    file = love.filesystem.newFile("currentResolution.txt")
    settingsPanelComponents = {
        gooi.newLabel({ text = "Text\nSpeed", group = "settings" }):center(),
        gooi.newSlider({ value = .8, group = "settings" }),
        gooi.newLabel({ text = "txtSpdDisplay", group = "settings" }):center(),
        gooi.newLabel({ text = "Sound", group = "settings" }),
        gooi.newSlider({ value = .5, group = "settings" }),
        gooi.newLabel({ text = "volumeDisplay", group = "settings" }):center(),
        gooi.newLabel({ text = "*Resolution", group = "settings" }),
        gooi.newButton({ text = width .. "x" .. height, group = "settings" }):onRelease(function(self)
            if self.text == "3840x2160" then
                self:setText("1280x720")
                love.filesystem.write("currentResolution.txt", "1280\n720")
            elseif self.text == "3200x1800" then
                self:setText("3840x2160")
                love.filesystem.write("currentResolution.txt", "3840\n2160")
            elseif self.text == "2560x1440" then
                self:setText("3200x1800")
                love.filesystem.write("currentResolution.txt", "3200\n1800")
            elseif self.text == "1920x1080" then
                self:setText("2560x1440")
                love.filesystem.write("currentResolution.txt", "2560\n1440")
            elseif self.text == "1366x768" then
                self:setText("1920x1080")
                love.filesystem.write("currentResolution.txt", "1920\n1080")
            elseif self.text == "1360x768" then
                self:setText("1366x768")
                love.filesystem.write("currentResolution.txt", "1366\n768")
            elseif self.text == "1280x720" then
                self:setText("1360x768")
                love.filesystem.write("currentResolution.txt", "1360\n768")
            end
        end),
        gooi.newLabel({ text = "*Change will take\nplace after restart", group = "settings" }):center() }

    --Update
    settingsPanelComponents[2].callback = function(self, newValue)
        settingsPanelComponents[3]:setText(("%d%%"):format(newValue * 100))
        moan.setSpeed(.08 - newValue * .07)
    end
    settingsPanelComponents[5].callback = function(self, newValue)
        settingsPanelComponents[6]:setText(("%.1f%%"):format(newValue * 100))
        love.audio.setVolume(newValue)
    end

    settingsPanel:setRowspan(1, 1, 2)
    settingsPanel:setRowspan(3, 1, 2)
    settingsPanel:setColspan(6, 1, 2)
    settingsPanel:add(unpack(settingsPanelComponents))

    --Make sure settings visibility is off by default
    for i = 1, 9 do
        settingsPanelComponents[i].visible = false
    end

    --[[---------------------------------
    -------Pause Menu Generator----------
    ------------------------------------]]

    pauseLabel = gooi.newLabel({
        text = "Paused",
        x = width * 100 / 960,
        y = height / 5 - height / 10,
        w = width / 3,
        h = height / 5,
        group = "pause"
    })

    --[[------------------------------
    ------------Game Buttons----------
    ---------------------------------]]


    --main_game
    databaseBtn = gooi.newButton({
        text = "",
        x = width * 905 / 960,
        y = height * 303 / 960,
        w = width * 40 / 960,
        h = height * 40 / 960,
        group = "main_game"
    }):setStyle({ bgColor = component.colors.blue, radius = height * 40 / 960 })
    :onRelease(function()
        --Do the needful
    end)

    databaseBtn.events.hover = function(self)
        self.style.bgColor = {180, 0, 255}
    end
    databaseBtn.events.unhover = function(self)
        self.style.bgColor = component.colors.blue
    end

    contactsPanel = gooi.newPanel({
        x = width * 300 / 960,
        y = height * 130 / 540,
        w = width / 4,
        h = height / 3,
        layout = "grid 4x3"})

    savedFilesPanel = gooi.newPanel({
        x = width * 300 / 960,
        y = height * 130 / 540,
        w = width / 4,
        h = height / 3,
        layout = "grid 4x3"})

    contactsBtn = gooi.newButton({text = "Contacts",
                                  x = height / 2,
                                  y = height / 2,
                                  w = height / 2,
                                  h = height / 2,
                                  group = "main_game"
    }):onRelease()

    savedFilesBtn = gooi.newButton({text = "Saved Files",
                                    x = height / 2,
                                    y = height / 2,
                                    w = height / 2,
                                    h = height / 2,
                                    group = "main_game"
    }):onRelease()
end

local function currentMenu()
    if paused then
        return "pause"
    end
    if startBtn.visible then
        return "main_menu"
    end
end

return { init = init, toggleVisible = toggleVisible, togglePause = togglePause, currentMenu = currentMenu }
