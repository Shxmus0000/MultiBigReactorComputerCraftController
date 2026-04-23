local discovery = {}

local function findReactors()
    local reactors = {}

    for _, name in ipairs(peripheral.getNames()) do
        local pType = peripheral.getType(name)

        if pType and string.find(pType:lower(), "reactor") then
            table.insert(reactors, name)
        end
    end

    return reactors
end

local function findMonitors()
    local monitors = {}

    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "monitor" then
            table.insert(monitors, name)
        end
    end

    return monitors
end

function discovery.scan()
    local reactorNames = findReactors()
    local monitorNames = findMonitors()

    local reactors = {}

    for i, rName in ipairs(reactorNames) do
        local mName = monitorNames[i] -- auto pair monitors in order

        reactors[i] = {
            id = i,
            name = "Reactor " .. i,
            reactor = peripheral.wrap(rName),
            monitor = mName and peripheral.wrap(mName) or nil,
            min = 30,
            max = 70
        }
    end

    return reactors
end

return discovery
