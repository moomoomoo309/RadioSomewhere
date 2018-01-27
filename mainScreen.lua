local sprite = require "sprite"
local shine = require "shine"
local moan = require "Moan"

local w, h = love.graphics.getDimensions()

local console = sprite {
    x = 0,
    y = 0,
    w = love.graphics.getWidth(),
    h = love.graphics.getHeight(),
    imagePath = "assets/console.png",
    filterMin = "linear",
    filterMax = "linear"
}
local personImage
local textbox

local textboxCanvas = love.graphics.newCanvas(w, h)

local crtFont = love.graphics.newFont("assets/VT323-Regular.ttf", 72)

local glowEffect = shine.glowsimple()
glowEffect.min_luma = .7
local scanlineEffect = shine.scanlines()
scanlineEffect.opacity = .5
scanlineEffect.line_height = .4
scanlineEffect.pixel_size = 9

local titleFont = crtFont
local msgFont = crtFont
local nextMsgSprite

local fullCrtEffect = glowEffect:chain(scanlineEffect)

local function drawMoan(text, msgFont, msgBox, optionsPos, nextMsgSprite)
    text = text or moan.getPrintedText()
    local oldColor = { love.graphics.getColor() }
    love.graphics.setColor(0, 255, 0)
    local oldFont

    if msgFont then
        love.graphics.setFont(msgFont)
    end
    if moan.autoWrap then
        love.graphics.print(text, msgBox.x, msgBox.y)
    else
        love.graphics.printf(text, msgBox.x, msgBox.y, msgBox.w)
    end

    if moan.showingOptions then
        local currentFont = msgFont or titleFont or love.graphics.getFont()
        local padding = currentFont:getHeight() * 1.35
        for k, option in pairs(moan.allMsgs[moan.currentMsgInstance].options) do
            love.graphics.print(option[1], optionsPos.x, optionsPos.y + ((k - 1) * padding))
        end
    end

    if nextMsgSprite then
        nextMsgSprite:draw()
    end

    if oldFont then
        love.graphics.setFont(oldFont)
    end
    love.graphics.setColor(oldColor)
end

local moanDraw = function()
    drawMoan(nil, msgFont, { x = 0, y = 0, w = w, h = h },
        { x = 0, y = 0 }, nextMsgSprite)
end

local function draw()
    console:draw()
    --[[
    love.graphics.setCanvas(crtWindowCanvas)
    fullCrtEffect:draw(function()
        personImage:draw()
    end)
    --]]
    ---[[
    love.graphics.setCanvas(textboxCanvas)
    fullCrtEffect:draw(function()
        love.graphics.push()
        love.graphics.scale(1,2)
        moanDraw()
        love.graphics.pop()
    end)
    --]]
    love.graphics.setCanvas()
    love.graphics.draw(textboxCanvas, w * 235 / 960, h * 377 / 540, 0, .54, .17)
end





return draw
