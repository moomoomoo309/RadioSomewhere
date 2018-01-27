local sprite = require "sprite"
local shine = require "shine"
local moan = require "Moan"

local console
local crtWindow
local earth
local textbox

local glowEffect = shine.glowsimple()
local scanlineEffect = shine.scanlines()
local crtEffect = shine.crt()

local fullCrtEffect = glowEffect
    :chain(scanlineEffect)
    :chain(crtEffect)

local function draw()
--    earth:draw()
--    console:draw()
    fullCrtEffect:draw(function()
--        crtWindow:draw()
        moan:draw()
--        textbox:draw()
    end)
end





return draw
