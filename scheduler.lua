--- A class allowing for functions to be scheduled based on certain conditions.
--- @class scheduler
--- @field paused table Contains whether a group is paused or not.
--- @field functions table Contains the functions within a group.
--- @field groups table Contains a flat list of groups.
local scheduler = {
    paused = {},
    functions = {},
    groups = {}
}

--- Sleeps the running coroutine until seconds has passed. Will not work on the main thread.
--- @param seconds number How many seconds to sleep for.
--- @return nil
function scheduler.sleep(seconds)
    assert(type(seconds) == "number", ("Number expected, got %s."):format(type(seconds)))
    if seconds == 0 then
        return
    end
    assert(seconds > 0, ("Tried to sleep for %d seconds, but cannot move time backward."):format(seconds))
    --Check for the main thread
    local co = coroutine.running()
    local success, errMessage = pcall(coroutine.yield)
    assert(success, errMessage:find("C-call", nil, true) and "You can't sleep on the main thread!" or errMessage)
    coroutine.resume(co)
    --Actually sleep
    love.timer.sleep(seconds)
end

--- Run fct after seconds has passed. Returns a function which cancels this function.
--- @param seconds number How many seconds to wait before running fct.
--- @param fct function The function to run after the time has passed.
--- @param group string|nil The group the function should be in. Defaults to "default"
--- @return function a function which cancels this function.
function scheduler.after(seconds, fct, group)
    assert(type(fct) == "function", ("Function expected, got %s."):format(type(fct)))
    group = group or "default"
    scheduler.functions[group] = scheduler.functions[group] or {}
    local index = #scheduler.functions[group] + 1
    local timeElapsed = 0
    scheduler.functions[group][index] = function(dt)
        timeElapsed = timeElapsed + dt
        if timeElapsed >= seconds then
            fct()
            scheduler.functions[group][index] = nil
        end
    end
    return function()
        if scheduler.functions[group][index] then
            scheduler.functions[group][index] = nil
        end
    end
end

--- Run fct until seconds has passed. Returns a function which cancels this function.
--- @param seconds number How many seconds to wait until fct should stop being run.
--- @param fct function The function to continuously run before the time has passed.
--- @param cancelFct function|nil A function to run if this one is cancelled.
--- @param group string|nil The group the function should be in. Defaults to "default".
--- @return function a function which cancels this function.
function scheduler.before(seconds, fct, cancelFct, group)
    assert(type(fct) == "function", ("Function expected, got %s."):format(type(fct)))
    assert(type(cancelFct) == "function" or not cancelFct, ("Function or nil expected, got %s."):format(type(cancelFct)))
    group = group or "default"
    scheduler.functions[group] = scheduler.functions[group] or {}
    local index = #scheduler.functions[group] + 1
    local timeElapsed = 0
    scheduler.functions[group][index] = function(dt)
        timeElapsed = timeElapsed + dt
        if timeElapsed >= seconds then
            scheduler.functions[group][index] = nil
        else
            fct(timeElapsed, dt)
        end
    end
    return function()
        if scheduler.functions[group][index] then
            scheduler.functions[group][index] = nil
            if type(cancelFct) == "function" then
                cancelFct()
            end
        end
    end
end

--- Runs fct until conditionFct returns a truthy value or the function returned is called.
--- @param conditionFct function A function supplying the condition that will stop fct.
--- @param fct function The function to run continuously while conditionFct returns a truthy value.
--- @param cancelFct function|nil A function to run if this one is cancelled.
--- @param group string|nil The group the function should be in. Defaults to "default".
--- @return function a function which cancels this function.
function scheduler._until(conditionFct, fct, cancelFct, group)
    assert(type(fct) == "function", ("Function expected, got %s."):format(type(fct)))
    assert(type(conditionFct) == "function", ("Function expected, got %s."):format(type(conditionFct)))
    assert(type(cancelFct) == "function" or not cancelFct, ("Function or nil expected, got %s."):format(type(cancelFct)))
    local done = conditionFct()
    group = group or "default"
    scheduler.functions[group] = scheduler.functions[group] or {}
    local index = #scheduler.functions[group] + 1
    scheduler.functions[group][index] = function()
        if done then
            scheduler.groups[scheduler.functions[group][index]] = nil
            scheduler.functions[group][index] = nil
            return
        end
        fct()
        done = done or conditionFct()
    end
    scheduler.groups[scheduler.functions[group][index]] = group
    return function()
        done = true
        if type(cancelFct) == "function" then
            cancelFct()
        end
    end
end

scheduler["until"] = scheduler._until

--- Runs fct when conditionFct returns a truthy value or the function returned is called without a parameter.
--- @param conditionFct function A function supplying the condition that will run fct.
--- @param fct function The function to run when conditionFct returns a truthy value.
--- @param cancelFct function|nil A function to run if this one is cancelled.
--- @param group string|nil The group the function should be in. Defaults to "default".
--- @return function A function which cancels this function. Takes a parameter specifying if fct should not be run.
function scheduler.when(conditionFct, fct, cancelFct, group)
    assert(type(fct) == "function", ("Function expected, got %s."):format(type(fct)))
    assert(type(conditionFct) == "function", ("Function expected, got %s."):format(type(conditionFct)))
    assert(type(cancelFct) == "function" or not cancelFct, ("Function or nil expected, got %s."):format(type(cancelFct)))
    local done = conditionFct()
    local skip = false
    group = group or "default"
    scheduler.functions[group] = scheduler.functions[group] or {}
    local index = #scheduler.functions[group] + 1
    scheduler.functions[group][index] = function()
        if done then
            if not skip then
                fct()
            end
            scheduler.groups[scheduler.functions[group][index]] = nil
            scheduler.functions[group][index] = nil
            return
        end
        done = done or conditionFct()
    end
    scheduler.groups[scheduler.functions[group][index]] = group
    return function(doNotRunFct)
        skip = doNotRunFct
        done = true
        if type(cancelFct) == "function" then
            cancelFct()
        end
        scheduler.functions[group][index]()
    end
end

--- Runs fct every seconds seconds.
--- @param seconds number The number of seconds to wait between running fct.
--- @param fct function The function to run every seconds seconds.
--- @param cancelFct function|nil A function to run if this one is cancelled.
--- @param group string|nil The group the function should be in. Defaults to "default".
--- @return function a function which cancels this function.
function scheduler.every(seconds, fct, cancelFct, group)
    assert(type(fct) == "function", ("Function expected, got %s."):format(type(fct)))
    assert(type(cancelFct) == "function" or not cancelFct, ("Function or nil expected, got %s."):format(type(cancelFct)))
    group = group or "default"
    scheduler.functions[group] = scheduler.functions[group] or {}
    local index = #scheduler.functions[group] + 1
    local timeElapsed = 0
    local timesRun = 0
    scheduler.functions[group][index] = function(dt)
        timeElapsed = timeElapsed + dt
        if timeElapsed >= seconds then
            timeElapsed = 0
            timesRun = timesRun + 1
            fct(timesRun)
        end
    end
    scheduler.groups[scheduler.functions[group][index]] = group
    return function()
        if scheduler.functions[group][index] then
            scheduler.functions[group][index] = nil
            if type(cancelFct) == "function" then
                cancelFct()
            end
        end
    end
end

--- Runs fct every time conditionFct returns a truthy value.
--- @param conditionFct function A function supplying the condition that will run fct.
--- @param fct function The function to run every time conditionFct returns a truthy value.
--- @param cancelFct function|nil A function to run if this one is cancelled.
--- @param group string|nil The group the function should be in. Defaults to "default".
--- @return string a function which cancels this function.
function scheduler.everyCondition(conditionFct, fct, cancelFct, group)
    assert(type(fct) == "function", ("Function expected, got %s."):format(type(fct)))
    assert(type(conditionFct) == "function", ("Function expected, got %s."):format(type(conditionFct)))
    assert(type(cancelFct) == "function" or not cancelFct, ("Function or nil expected, got %s."):format(type(cancelFct)))
    group = group or "default"
    scheduler.functions[group] = scheduler.functions[group] or {}
    local index = #scheduler.functions[group] + 1
    local timesRun = 0
    scheduler.functions[group][index] = function()
        if conditionFct() then
            timesRun = timesRun + 1
            fct(timesRun)
        end
    end
    scheduler.groups[scheduler.functions[group][index]] = group
    return function()
        if scheduler.functions[group][index] then
            scheduler.functions[group][index] = nil
            if type(cancelFct) == "function" then
                cancelFct()
            end
        end
    end
end

--- Pause the given group.
--- @param group any The key of the group to pause. Can technically be any value.
--- @return nil
function scheduler.pause(group)
    local pausedGroup = scheduler.paused
    pausedGroup[group] = true
end

--- Resumes the given group.
--- @param group any The key of the group to resume. Can technically be any value.
--- @return nil
function scheduler.resume(group)
    local pausedGroup = scheduler.paused
    pausedGroup[group] = false
end

--- Updates all of the functions in the scheduler, checking if any need to run and running them if necessary.
--- @param dt number The time between the last update and this one.
--- @return nil
function scheduler.update(dt)
    assert(type(dt) == "number", ("Number expected, got %s."):format(type(dt)))
    local pausedGroup = scheduler.paused
    for group, fcts in pairs(scheduler.functions) do
        if not pausedGroup[group] then
            for _, fct in pairs(fcts) do
                fct(dt)
            end
        end
    end
end

--- An alias to scheduler.resume
--- @see scheduler.resume
scheduler.unpause = scheduler.resume


return scheduler