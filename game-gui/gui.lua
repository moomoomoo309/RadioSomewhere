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
local contactsPanel
local contactsTable = {}
local pauseLabel
local startBtn
local databaseBtn
local fontColor = { 255, 255, 255 }

gameDebug = false
local paused = false
exitOpen = false

gooi.setStyle({ font = love.graphics.newFont("assets/VT323-Regular.ttf", 30 * height / 720) })

--- Pause toggle menu
--- @return nil
local function togglePause()
    paused = not paused
    pauseLabel:setVisible(paused)
    scheduler[paused and "pause" or "resume"] "pausable"
end

--- Visibility toggle for the settings screen
--- @return nil
local function toggleVisible()
    for i = 1, #settingsPanelComponents do
        settingsPanelComponents[i].visible = not settingsPanelComponents[i].visible
    end
end

function startBlinking()
    return scheduler.every(.8, function()
        if databaseBtn.style.bgColor[4] == 0 then
            databaseBtn.events.hover(databaseBtn)
        else
            databaseBtn.events.unhover(databaseBtn)
        end
    end, nil, "pausable")
end

local function backOutOfFiles(person)
    if contactsTable[person] then
        for i = 1,#contactsTable[person] do
            contactsTable[person].sons[1].ref:setVisible(false)
        end
    end
end

local function addContact(person)
    contactsTable[person] = gooi.newPanel({
        x = width * 300 / 960,
        y = height * 60 / 540,
        w = width * 200 / 960,
        h = height * 250 / 540,
        group = "main_game",
        layout = "grid 4x1"
    }):add(gooi.newButton({text = "Back", group = "main_game"})):onRelease(function()
        backOutOfFiles(person)
    end)
    contactsTable[person].sons[1].ref:setVisible(false)
end

--- Adds "file" to person subdirect
---
---
local function addFile(person, fileName)
    if contactsPanel then
        for i = 1, #contactsPanel.sons do
            if contactsPanel.sons[i].ref.text == person and contactsTable[person] then
                contactsTable[person]:add{text = fileName, group = "main_game"}
                :onRelease(function()
                         --TODO: the needful
                end)
            else
                addContact(person)
                contactsPanel:add(gooi.newButton({text = person, group = "main_game"}))
            end
        end
    end
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
    }):onRelease(function()
        gooi.setGroupVisible("main_menu", false)
        --Make sure that the settings are not visible on game start
        if settingsPanelComponents[1].visible then
            toggleVisible()
        end
    end):left()

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
    end):left()


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

    --[[------------------------------------
    ----------Pause Menu Generator----------
    ---------------------------------------]]

    pauseLabel = gooi.newLabel({
        text = "Paused",
        x = width * 100 / 960,
        y = height / 5 - height / 10,
        w = width / 3,
        h = height / 5,
        group = "pause"
    })

    --[[--------------------------------
    -------------Game Buttons-----------
    -----------------------------------]]


    --main_game

    local filePanel = gooi.newPanel({
        x = width * 300 / 960,
        y = height * 60 / 540,
        w = width * 200 / 960,
        h = height * 250 / 540,
        group = "main_game",
        layout = "grid 5x3"
    }):setStyle({ bgColor = component.colors.green })

    local savedFilesPanel
    local contactsBtn
    local savedFilesBtn

    local savedFilesBtn = gooi.newButton({
        text = "Saved Files",
        x = width * 460 / 960,
        y = height * 30 / 540,
        w = width * 100 / 960,
        h = height * 30 / 540,
        group = "main_game"
    })

    local contactsBtn = gooi.newButton({
        text = "Contacts",
        x = width * 300 / 960,
        y = height * 30 / 540,
        w = width * 100 / 960,
        h = height * 30 / 540,
        group = "main_game"
    })

    local function savedFilesVisibility()
        for i = 1, #savedFilesPanel.sons do
            savedFilesPanel.sons[i].ref:setVisible(not savedFilesPanel.sons[i].ref.visible)
        end
    end

    local function fileViewerVisibility()
        for i = 1, #filePanel.sons do
            filePanel.sons[i].ref:setVisible(not filePanel.sons[i].ref.visible)
        end
    end

    local function contactsVisibility()
        for i = 1, #contactsPanel.sons do
           contactsPanel.sons[i].ref:setVisible(not contactsPanel.sons[1].ref.visible)
        end
    end

    local function switchToSaveFiles()
        if not filePanel.sons[1].ref.visible and not savedFilesPanel.sons[1].ref.visible and savedFilesBtn.visible then
            savedFilesVisibility()
        end
    end

    contactsPanel = gooi.newPanel({
        x = width * 330 / 960,
        y = height * 90 / 540,
        w = width * 200 / 960,
        h = height * 200 / 540,
        group = "main_game",
        layout = "grid 4x1"
    }):add(gooi.newButton({text = "chris"}))

    for k,v in pairs (contactsPanel.sons) do
        print(k, v)
    end


    local function switchToContacts()
        if not contactsPanel.sons[1].ref.visible and contactsBtn.visible then
            contactsVisibility()
        end
    end

    local function displayFile(text)
        text = text or "hi"
        filePanel.sons[3].ref:setText(text)
        savedFilesVisibility()
        fileViewerVisibility()
    end

    contactsBtn:onRelease(function ()
        switchToContacts()
    end):setVisible(false)

    savedFilesBtn:onRelease(function()
        switchToSaveFiles()
    end):setVisible(false)

    databaseBtn = gooi.newButton({
        text = "",
        x = width * 905 / 960,
        y = height * 303 / 960,
        w = width * 40 / 960,
        h = height * 40 / 960,
        group = "database"
    }):setStyle({ bgColor = component.colors.blue, radius = height * 40 / 960 })
                      :onRelease(function()
        if filePanel.sons[1].ref.visible or savedFilesPanel.sons[1].ref.visible or contactsBtn.visible or savedFilesBtn.visible then
            if filePanel.sons[1].ref.visible then
                fileViewerVisibility()
            end
            if savedFilesPanel.sons[1].ref.visible then
                savedFilesVisibility()
            end
        else
            savedFilesVisibility()
        end
    end)

    databaseBtn.events.hover = function(self)
        self.style.bgColor = { 180, 0, 255 }
    end
    databaseBtn.events.unhover = function(self)
        self.style.bgColor = component.colors.blue
    end

    local databaseLbl = gooi.newLabel({
        text = "Database",
        x = width * 400 / 960,
        y = height * 200 / 340,
    })


    filePanel:setColspan(1, 1, 2)
    filePanel:setColspan(2, 1, 3)
    filePanel:setRowspan(2, 1, 3)
    filePanel:add(
            gooi.newLabel({ text = "filler", group = "main_game" }):setStyle({ bgColor = component.colors.green }),
            gooi.newButton({ text = "X", group = "main_game" }):onRelease(function()
                fileViewerVisibility()
                savedFilesVisibility()
            end)
                :setStyle({ bgColor = component.colors.green
            }),
            gooi.newLabel({ text = "", group = "main_game" }):setStyle({ bgColor = component.colors.green }),
            gooi.newButton({ text = "Left", group = "main_game" }):onRelease(function()
            end)
                :setStyle({ bgColor = component.colors.green
            }),
            gooi.newLabel({ text = "filler", group = "main_game" }):setStyle({ bgColor = component.colors.green }),
            gooi.newButton({ text = "Right", group = "main_game" }):onRelease(function()
            end)
                :setStyle({ bgColor = component.colors.green
            })
    )
    fileViewerVisibility()

    savedFilesPanel = gooi.newPanel({
        x = width * 330 / 960,
        y = height * 90 / 540,
        w = width * 200 / 960,
        h = height * 200 / 540,
        group = "main_game",
        layout = "grid 5x3"
    })

    savedFilesPanel:setColspan(1, 1, 3)
    savedFilesPanel:add(
            gooi.newLabel({ text = "Saved Files", group = "main_game" }):center(),
            gooi                      .newButton({
                text = "1",
                group = "main_game" }):onRelease(function(self)
                displayFile()

            end),
            gooi                      .newButton({
                text = "2",
                group = "main_game" }):onRelease(function(self)
                displayFile()

            end),
            gooi                      .newButton({
                text = "3",
                group = "main_game" }):onRelease(function(self)
                displayFile()

            end),
            gooi                      .newButton({
                text = "4",
                group = "main_game" }):onRelease(function(self)
                displayFile()

            end),
            gooi                      .newButton({
                text = "5",
                group = "main_game" }):onRelease(function(self)
                displayFile("hello")

            end),
            gooi                      .newButton({
                text = "6",
                group = "main_game" }):onRelease(function(self)
                displayFile()

            end),
            gooi                      .newButton({
                text = "7",
                group = "main_game" }):onRelease(function(self)
                displayFile()

            end),
            gooi                      .newButton({
                text = "8",
                group = "main_game" }):onRelease(function(self)
                displayFile()

            end),
            gooi                      .newButton({
                text = "9",
                group = "main_game" }):onRelease(function(self)
                displayFile()

            end),
            gooi.newButton({ text = "Left", group = "main_game" }),
            gooi.newLabel({ text = "", group = "main_game" }),
            gooi.newButton({ text = "Right", group = "main_game" })
    )


    savedFilesVisibility()

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
