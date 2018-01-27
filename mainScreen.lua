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

local crt = sprite {
    x = 0,
    y = 0,
    w = love.graphics.getWidth(),
    h = love.graphics.getHeight(),
    imagePath = "assets/crt.png",
    filterMin = "linear",
    filterMax = "linear"
}

local face = sprite {
    x = 0,
    y = 0,
    w = love.graphics.getWidth(),
    h = love.graphics.getHeight(),
    imagePath = "assets/face1.png",
    filterMin = "linear",
    filterMax = "linear"
}

local personImage
local textbox

local textboxCanvas = love.graphics.newCanvas(w, h)

local crtFont = love.graphics.newFont("assets/VT323-Regular.ttf", 72)

local glowEffect = shine.glowsimple()
glowEffect.min_luma = .3
local scanlineEffect = shine.scanlines()
scanlineEffect.opacity = .5
scanlineEffect.line_height = .4
scanlineEffect.pixel_size = 9
local boxblur = shine.boxblur()
boxblur.radius_h = 3
boxblur.radius_v = 3
local static = shine.filmgrain()
static.opacity = .2
static.grainsize = 2

local titleFont = crtFont
local msgFont = crtFont
local nextMsgSprite

local fullCrtEffect = boxblur:chain(glowEffect):chain(scanlineEffect):chain(static)
local faceGlowEffect = shine.glowsimple()
faceGlowEffect.min_luma = .9
local faceScanlineEffect = shine.scanlines()
faceScanlineEffect.opacity = .5
faceScanlineEffect.line_height = .3
faceScanlineEffect.pixel_size = 3
local faceBlurEffect = shine.boxblur()
faceBlurEffect.radius_h = 1.5
faceBlurEffect.radius_v = 1.5
local faceStatic = shine.filmgrain()
faceStatic.opacity = .15
faceStatic.grainsize = 1
local faceCrtEffect = faceBlurEffect:chain(faceGlowEffect):chain(faceScanlineEffect):chain(faceStatic)


local function drawMoan(text, msgFont, msgBox, optionsPos, nextMsgSprite)
    if moan.showingMessage then
        text = text or moan.getPrintedText()
        local oldColor = { love.graphics.getColor() }
        love.graphics.setColor(74, 215, 255)
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
end

local moanDraw = function()
    drawMoan(nil, msgFont, { x = 0, y = 0, w = w, h = h },
        { x = 0, y = 0 }, nextMsgSprite)
end

local function draw()
    console:draw()
    love.graphics.setCanvas(textboxCanvas)
    fullCrtEffect:draw(function()
        love.graphics.push()
        love.graphics.scale(1, 2)
        moanDraw()
        love.graphics.pop()
    end)
    love.graphics.setCanvas()
    love.graphics.draw(textboxCanvas, w * 235 / 960, h * 377 / 540, 0, .54, .17)
    love.graphics.setCanvas(textboxCanvas)
    love.graphics.clear()
    love.graphics.setCanvas()
    faceCrtEffect:draw(function() face:draw() end)
    crt:draw()
end





return draw
