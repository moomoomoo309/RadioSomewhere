--- A module allowing scripts of dialogue to be parsed.
--- @module parser

local moan = require "Moan"
local scheduler = require "scheduler"
require "GeneralAPI"

local locked = true
local parser = {
    labels = {}
}

--- Prompts the player for input between dialogue options.
--- @param tbl table The script
--- @param process thread The coroutine the parser is running from.
--- @return string,string What the player's choice resolves to, and what choice the player picked.
local function promptPlayer(tbl, process)
    local choices = {}
    local option
    for k, v in pairs(tbl) do
        if v then
            choices[#choices + 1] = { k, function()
                option = k
                scheduler.after(.01, function()
                    love.keypressed "space"
                end)
            end }
        end
    end
    optionLocked = true
    scheduler.after(.75, function()
        optionLocked = false
    end, "pausable")
    moan.speak("", { "" }, { options = choices })
    repeat
        coroutine.yield() -- Until a choice is picked, don't go back to processVal.
    until option
    moan.speak("", { "" })
    return tbl[option], option
end

--- Contains all commands recognized by the parser.
--- @see processLine
local commands = {
    --- Processes the line, but does not yield.
    continue = function(val, tbl, _, _)
        parser.processLine(val:sub(7), false, true)
    end,
    --- Goes to a label, then comes back once that script is completely finished.
    call = function(val, _, process, noYield)
        local labelName = val:sub(7)
        assert(parser.labels[labelName], ("No label with name %s found."):format(labelName))
        print(("Going to %s..."):format(labelName))
        parser.processVal(nil, process, noYield, parser.labels[labelName])
    end,
    ["goto"] = function(val, _, process, noYield)
        local labelName = val:sub(7)
        assert(parser.labels[labelName], ("No label with name %s found."):format(labelName))
        print(("Going to %s..."):format(labelName))
        parser.processVal(nil, process, noYield, parser.labels[labelName])
        return true
    end
}

--- Contains any prefixes recognized by the parser, excluding labels.
--- @see processLine
local prefixes = {
    ["label@"] = function()
        -- Ignore labels, don't print them out
    end,
    ["/r"] = function(val, _, _, noYield)
        assert(type(val) == "string", ("String expected, got %s."):format(type(val)))
        scene:printText(val:sub(3), false, { 255, 0, 0 })
        if not noYield then
            coroutine.yield(val)
        end
    end,
    ["/t{"] = function(val, _, _, noYield)
        local findClosingBrace = val:find("}", 4, true)
        assert(findClosingBrace, "The color table must be closed with a closing brace!")
        local color = stringx.split(val:sub(3, val:find("}", 4, true)), ",")
        assert(type(color) == "table", ("Table expected, got %s."):format(type(color)))
        assert(#color == 3 or #color == 4, ("Length of color table must be 3 or 4, was %d."):format(#color))
        scene:printText(val:sub(findClosingBrace + 1), false, color)
        if not noYield then
            coroutine.yield(val)
        end
    end,
    ["/t#"] = function(val, _, _, noYield)
        local color = tonumber("0x" .. val:sub(4, 12))
        local alpha = color and true or false
        color = color or tonumber("0x" .. val:sub(4, 10))
        assert(color, ("Could not parse #%s as hex string"):format(val:sub(4, (alpha and 12 or 10))))
        scene:printText(val:sub(alpha and 12 or 10), false, { tonumber("0x" .. val:sub(4, 6)), tonumber("0x" .. val:sub(6, 8)), tonumber("0x" .. val:sub(8, 10)), alpha and tonumber("0x" .. val:sub(10, 12)) or nil })
        if not noYield then
            coroutine.yield(val)
        end
    end,
    ["@"] = function(val, tbl, process, noYield)
        local findSpace = val:find(" ", nil, true)
        local firstWord = val:sub(1, findSpace and findSpace - 1 or #val)
        local cmd = firstWord:sub(2):lower()
        assert(commands[cmd], ("Unrecognized command: \"%s\" from string \"%s\""):format(cmd, val))
        return commands[cmd](val, tbl, process, noYield)
    end
}

--- Processes a string from the script.
--- @param val string The string to process
--- @param tbl table The table containing the script.
--- @param process thread The coroutine the parser is being run from.
--- @param noYield boolean Makes the coroutine not yield, so it processes another line.
--- @return boolean if the parent parser should return early.
function parser.processLine(val, tbl, process, noYield)
    assert(type(val) == "string", ("Expected string, got %s."):format(type(val)))
    local prefixed = false
    for k, v in pairs(prefixes) do
        if val:sub(1, #k) == k then
            return v(val, tbl, process, noYield) and true or false
        end
    end
    --No prefix was recognized, so just put the text on the screen.
    if not noYield then
        coroutine.yield(val)
    end
    return false
end

--- Processes the next value in the script.
--- @param script table The script.
--- @param process thread The coroutine the parser is being run from.
--- @param noYield boolean Makes the coroutine not yield, so it processes another line.
--- @param label table|nil The label to jump to, if needed.
--- @return nil
function parser.processVal(script, process, noYield, label)
    if label ~= nil and label.tbl ~= script then
        return parser.processVal(label.tbl, process, noYield, label)
    end
    local t = type(script)
    if t == "table" then
        script.vars = script.vars or {}
        -- If the label is passed, create the intermediate tables for later parsing.
        label = label or { keys = { 1 } }
        -- Go backwards through the keys, so you go deepest to shallowest when going through label keys.
        for i = #label.keys, 1, -1 do
            local tbl = script
            -- Get the current table (the last key is the value to start on)
            for i2 = 1, i - 1 do
                tbl = tbl[label.keys[i2]]
            end
            -- Make sure this isn't a player choice. If it is, don't let them make the choice again, because you came
            -- from inside the choice.
            if type(label.keys[i]) == "number" then
                local start = label.keys[i]
                -- If you just exited a choice, increment the start index or else you'll make the same choice again.
                if i ~= #label.keys and type(label.keys[i+1]) ~= "number" then
                    start = start + 1
                end
                for i2 = start, #tbl do
                    local val = tbl[i2]
                    t = type(val)
                    if t == "table" then
                        -- Option is what the player's choice resolves to, choice is the string they picked.
                        -- That's why choice isn't used here.
                        local option, choice = promptPlayer(val, process)
                        parser.processVal(option, process, noYield)
                    elseif t == "string" then
                        if parser.processLine(val, tbl, process, noYield) then
                            -- This is a hack to make goto work properly. It needs a way to tell the parser it came from
                            -- to return early, since it just finished its goto.
                            return
                        end
                    elseif t == "function" then
                        parser.processVal(val(val, tbl), process, noYield)
                    end
                end
            end
        end
    elseif t == "string" then
        parser.processLine(script, nil, noYield)
    elseif t == "function" then
        parser.processVal(script(script, nil), process, noYield)
    end
end

--- Locks the parser.
--- @return nil
function parser.lock()
    locked = true
end

--- Unlocks the parser.
--- @return nil
function parser.unlock()
    locked = false
end

--- Returns whether the parser is locked or not.
--- @return boolean Whether the parser is locked or not.
function parser.locked()
    return locked
end

function parser.addLabels(script)
    for keys, line in tablex.walk(script) do
        if type(line) == "string" and line:startsWith("label@") then
            local labelName = line:sub(7)
            assert(#labelName > 0, "Label name cannot be empty!")
            assert(parser.labels[labelName] == nil, ("Label with name %s is already taken!"):format(labelName))
            parser.labels[labelName] = { name = labelName, tbl = script, keys = keys }
        end
    end
end

--- Processes the file at the given path using require(). Returns a coroutine to the parser and the table it's reading from, or false if it is unsuccessful.
--- @param path string The path to the file to parse.
--- @return thread,table|boolean A coroutine to the parser and the table it's reading from, or false if it is unsuccessful.
function parser.parse(path)
    if not path then
        error "Cannot parse a script without a path!"
    end
    local processTbl = require(path)
    parser.addLabels(processTbl)
    return unpack { parser.parseTbl(processTbl) }
end

function parser.parseTbl(tbl)
    if type(tbl) == "table" then
        return coroutine.create(parser.processVal), tbl
    else
        return false
    end
end

return parser