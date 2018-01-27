local sprite = require "sprite"
local shine = require "shine"
local moan = require "Moan"

local console
local crtWindow
local earth
local textbox

local crtFont = love.graphics.newFont("assets/VT323-Regular.ttf", 36)

local glowEffect = shine.glowsimple()
local scanlineEffect = shine.scanlines()
local crtEffect = shine.crt()

local titleFont = crtFont
local msgFont = crtFont
local nextMsgSprite

local fullCrtEffect = glowEffect:chain(scanlineEffect):chain(crtEffect)

local function drawMoan(titlePos, titleFont, avatarSprite, msgFont, msgBox, optionsPos, nextMsgSprite)
    local oldColor = love.graphics.getColor()
    love.graphics.
    local oldFont
    if titleFont then
        oldFont = love.graphics.getFont()
        love.graphics.setFont(titleFont)
    end
    love.graphics.print(moan.currentTitle, titlePos.x, titlePos.y)
    if avatarSprite then
        avatarSprite:draw()
    end

    if msgFont then
        love.graphics.setFont(msgFont)
    end
    if moan.autoWrap then
        love.graphics.print(moan.getPrintedText(), msgBox.x, msgBox.y, math.rad(4))
    else
        love.graphics.printf(moan.getPrintedText(), msgBox.x, msgBox.y, msgBox.w, "left", math.rad(4))
    end

    if moan.showingOptions then
        local currentFont = msgFont or titleFont or love.graphics.getFont()
        local padding = currentFont:getHeight() * 1.35
        for k, option in pairs(moan.allMsgs[moan.currentMsgInstance].options) do
            -- First option has no Y padding...
            love.graphics.print(option[1], optionsPos.x, optionsPos.y + ((k - 1) * padding))
        end
    end

    if nextMsgSprite then
        nextMsgSprite:draw()
    end

    if oldFont then
        love.graphics.setFont(oldFont)
    end
end

moan.draw = function()
    drawMoan({ x = 0, y = 0 }, titleFont, nil, msgFont, { x = 20, y = 0, w = 100, h = 100 }, { x = 0, y = 0 }, nextMsgSprite)
end

local function draw()
    --    earth:draw()
    --    console:draw()
    fullCrtEffect:draw(function()
        --        crtWindow:draw()
        moan.draw()
        --        textbox:draw()
    end)
end





return draw
