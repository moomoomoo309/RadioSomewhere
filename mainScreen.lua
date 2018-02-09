local sprite = require "sprite"
local shine = require "shine"
local moan = require "Moan"
local scheduler = require "scheduler"
require "gooi"

local w, h = love.graphics.getDimensions()

local textColor = { 74, 215, 255 }

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

face = sprite {
    x = 0,
    y = 0,
    w = love.graphics.getWidth(),
    h = love.graphics.getHeight(),
    imagePath = "assets/fuzz.png",
    filterMin = "linear",
    filterMax = "linear"
}

local textboxCanvas = love.graphics.newCanvas(w, h)

local crtFont = love.graphics.newFont("assets/VT323-Regular.ttf", 72 * love.graphics.getHeight() / 720)

local glowEffect = shine.glowsimple()
glowEffect.min_luma = .3
textScanlineEffect = shine.scanlines()
textScanlineEffect.opacity = .5
textScanlineEffect.line_height = .333333
textScanlineEffect.pixel_size = 9 * h ^ 2 / 1080 ^ 2
textScanlineEffect.center_fade = 0
local boxblur = shine.boxblur()
boxblur.radius_h = 2 * h / 1080
boxblur.radius_v = 2 * h / 1080
local static = shine.filmgrain()
static.opacity = .2
static.grainsize = 2 * h / 1080

local titleFont = crtFont
local msgFont = crtFont
local nextMsgSprite

textShader = boxblur:chain(glowEffect):chain(textScanlineEffect):chain(static)--:chain(glowEffect)

imageScanlineEffect = shine.scanlines()
imageScanlineEffect.opacity = .5
imageScanlineEffect.line_height = .333333
imageScanlineEffect.pixel_size = math.ceil(1440 / h ^ .9)

local faceBlurEffect = shine.boxblur()
faceBlurEffect.radius_h = 1.5 * h / 1080
faceBlurEffect.radius_v = 1.5 * h / 1080

local faceStatic = shine.filmgrain()
faceStatic.opacity = .15
faceStatic.grainsize = 1 * h / 1080

imageShader = faceBlurEffect:chain(faceStatic):chain(imageScanlineEffect)

local marqueeOffset = 0
local cancelMarquee
local function drawMoan(text, msgFont, msgBox, optionsPos, nextMsgSprite, maxLen)
    if moan.showingMessage then
        text = text or moan.getPrintedText()
        local oldColor = { love.graphics.getColor() }
        love.graphics.setColor(unpack(textColor))
        local oldFont

        if msgFont then
            love.graphics.setFont(msgFont)
        end
        if #text > 0 then
            local padStr = text:sub(1, 1) == "#" and "##" or "  "
            if moan.autoWrap then
                love.graphics.print(padStr .. text, msgBox.x, msgBox.y)
            else
                love.graphics.printf(padStr .. text, msgBox.x, msgBox.y, msgBox.w)
            end
        end

        if moan.showingOptions then
            local currentFont = msgFont or titleFont or love.graphics.getFont()
            local padding = currentFont:getHeight() * 1.35
            if not cancelMarquee then
                cancelMarquee = scheduler.every(.1 + (1 - (moan.typeSpeed - .01) / .07) * .25, function()
                    marqueeOffset = (marqueeOffset + 1) % maxLen
                end, function()
                    marqueeOffset = 0
                    cancelMarquee = nil
                end)
            end
            for k, option in pairs(moan.allMsgs[moan.currentMsgInstance].options) do
                local currentOption
                if moan.allMsgs[moan.currentMsgInstance].options[moan.currentOption][1] == option[1] and #option[1] > maxLen then
                    --Selected option
                    local prefix = option[1]:sub(1, 12)
                    local msg = option[1]:sub(13)
                    local before, after = msg:sub(marqueeOffset + 1), msg:sub(1, marqueeOffset + 1)
                    currentOption = prefix .. (#before > maxLen and before or before .. "|" .. after)
                else
                    currentOption = option[1]
                end
                love.graphics.print(currentOption:sub(1,maxLen), optionsPos.x, optionsPos.y + ((k - (text and #text > 0 and 0 or 1)) * padding))
            end
        elseif type(cancelMarquee) == "function" then
            cancelMarquee()
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
            { x = 0, y = 0 }, nextMsgSprite, 44)
end

local function draw()
    console:draw()
    love.graphics.setCanvas(textboxCanvas)
    textShader:draw(function()
        love.graphics.push()
        love.graphics.scale(1, 2)
        moanDraw()
        love.graphics.pop()
    end)
    love.graphics.setCanvas()
    love.graphics.draw(textboxCanvas, w * 235 / 960, h * 377 / 540, 0, .54, .16)
    love.graphics.setCanvas(textboxCanvas)
    love.graphics.clear()
    love.graphics.setCanvas()
    face:draw()
    staticShader:draw(function()
        face:draw()
    end)
    crt:draw()
end

return draw
