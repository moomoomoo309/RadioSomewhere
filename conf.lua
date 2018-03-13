local stringx = require "pl.stringx"

love.filesystem.newFile("currentResolution.txt")
if not love.filesystem.isFile("currentResolution.txt") then
    love.filesystem.write("currentResolution.txt", "1360\n768")
end

local function readFromFile(file)
    str = love.filesystem.read(file)


    return stringx.split(str)
end

function love.conf(t)
    local w, h = unpack(readFromFile("currentResolution.txt"))
    t.window.width = w
    t.window.height = h
    t.version = "0.10.2"
    t.vsync = false
end
