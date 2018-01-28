---
--- Created by Justin Neria.
--- DateTime: 1/26/2018 9:22 PM
---

require "gooi"
local moan = require "Moan"

local height = love.graphics.getHeight()
local width = love.graphics.getWidth()

local menuButton_xLocation = width * 360 / 960
local menuButton_yLocation = height * 360 / 540
local menuButton_xIncrement = height / 16
local menuButtonHeight = height / 16
local menuButtonWidth = width / 10

local settingsPanelComponents
local fontColor = { 255, 255, 255 }

local debug = true
local paused = false

gooi.setStyle({ font = love.graphics.newFont("assets/VT323-Regular.ttf", 36) })

--- Pause toggle menu
--- @return nil
local function pause()

end

--- Visibility toggle for the settings screen
--- @return nil
local function toggleVisible()
    for i = 1, #settingsPanelComponents do
        settingsPanelComponents[i].visible = not settingsPanelComponents[i].visible
    end
end

local startBtn

--- Initializer to create all the gui objects
--- @return nil
local function init()
    if debug == true then
        local debugButton = gooi.newButton({
            text = "debug",
            x = 50,
            y = 50,
            w = 100,
            h = 200
        })                      :onRelease(function()
            gooi.setGroupVisible("main_menu", true)
            if settingsPanelComponents[1].visible == false then
                toggleVisible()
            end
        end)
    end

    --[[
    --Main Menu Buttons
    --]]
    local startBtn = gooi.newButton({
        text = "Start",
        x = menuButton_xLocation,
        y = menuButton_yLocation,
        w = menuButtonWidth,
        h = menuButtonHeight,
        group = "main_menu",
    }):onRelease(function()
        gooi.setGroupVisible("main_menu", false)
        --Make sure that the settings are not visible on game start
        if settingsPanelComponents[1].visible == true then
            toggleVisible()
        end


    end)
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
    end)

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
            gooi.confirm({
                text = "Are you sure?",
                ok = function()
                    love.event.quit()
                end
            })
        end
    end):danger()


    --[[
    --Settings Panel Generator
    --]]
    local settingsPanel = gooi.newPanel({
        x = width * 200 / 960,
        y = height * 200 / 540,
        w = 200,
        h = 180,
        layout = "grid 6x2"
    })

    local file
    file = love.filesystem.newFile("currentResolution.txt")
    settingsPanelComponents = {
        gooi.newLabel({ text = "Text \nSpeed" }),
        gooi.newSlider({ value = .5 }),
        gooi.newLabel({ text = "txtSpdDisplay" }):center(),
        gooi.newLabel({ text = "Sound" }),
        gooi.newSlider({ value = .5 }),
        gooi.newLabel({ text = "volumeDisplay" }):center(),
        gooi.newLabel({ text = "Resolution" }),
        gooi.newButton({ text = width .. "x" .. height }):onRelease(function(self)
            if self.text == "3840x2160" then
                self:setText("1280x720")
                love.filesystem.write("currentResolution.txt", "1280\n720")
            end
            if self.text == "3200x1800" then
                self:setText("3840x2160")
                love.filesystem.write("currentResolution.txt", "3840\n2160")
            end
            if self.text == "2560x1440" then
                self:setText("3200x1800")
                love.filesystem.write("currentResolution.txt", "3200\n1800")
            end
            if self.text == "1920x1080" then
                self:setText("2560x1440")
                love.filesystem.write("currentResolution.txt", "2560\n1440")
            end
            if self.text == "1366x768" then
                self:setText("1920x1080")
                love.filesystem.write("currentResolution.txt", "1920\n1080")
            end
            if self.text == "1360x768" then
                self:setText("1366x768")
                love.filesystem.write("currentResolution.txt", "1366\n768")
            end
            if self.text == "1280x720" then
                self:setText("1360x768")
                love.filesystem.write("currentResolution.txt", "1360\n768")
            end
        end),
        gooi.newLabel({ text = "Change will take \nplace after restart" }) }
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
    settingsPanel:add(unpack(settingsPanelComponents))

    --Make sure settings visibility is off by default
    for i = 1, 9 do
        settingsPanelComponents[i].visible = false
    end

    --[[
    --Pause Menu Generator
    --]]

end

local function currentMenu()
    if paused then
        return "pause"
    end
    if startBtn.visible then
        return "main_menu"
    end
end

return { init = init, toggleVisible = toggleVisible, pause = pause, currentMenu = currentMenu }
