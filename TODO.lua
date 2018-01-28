--DONE: Database button
--TODO: Files in general
    --Files should show up over the earth
    --Database Label, so the players know what the hell they're looking at
    --Maybe we should ask Karina for a futuristic "window" asset, like for an OS?
    --Files should have an exit file and an optional next/prev button
--TODO: Saved files
    --Each saved file will have this, so you might want to just make a function to make the buttons
    --Needs to be implemented with buttons
--TODO: Contact files
    --Contact files should cause the database button to blink
        --DONE: Maybe blinking should just be a bool?
    --Perhaps the contact files should have an exclamation point next to it or something like that?




-- Modified promptPlayer code from FamiliarFaces:

--- Prompts the player for input between options.
--- @tparam table choices The options to pick from
--- @treturn string The choice the player picked.
local function promptPlayer(choices)
    local buttons = {}
    local function clearButtons()
        for i = 1, #buttons do
            buttons[i].visible = false
            buttons[i] = nil
        end
        buttons = nil
    end

    local choice
    for k in pairs(choices) do
        local btn = gooi.newButton(k):onRelease(function(self)
            choice = choices[self.text]
            clearButtons()
        end)
        btn.x = love.graphics.getWidth() / 2 - btn.w / 2
        btn.y = love.graphics.getHeight() / 3 - btn.h * 1.05 * (#buttons - #choices / 2)
        buttons[#buttons + 1] = btn
    end
    return choice
end
