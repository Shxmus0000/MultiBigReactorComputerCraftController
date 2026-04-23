local config = {}

function config.loadReactors()
    if fs.exists("config/reactors.json") then
        local f = fs.open("config/reactors.json", "r")
        local data = textutils.unserializeJSON(f.readAll())
        f.close()

        local reactors = {}

        for _, r in ipairs(data) do
            table.insert(reactors, {
                name = r.name,
                reactor = peripheral.wrap(r.reactor),
                monitor = peripheral.wrap(r.monitor),
                bufferMin = r.min,
                bufferMax = r.max
            })
        end

        return reactors
    end

    -- fallback default
    return {
        {
            name = "Reactor 1",
            reactor = peripheral.wrap("BigReactors_0"),
            monitor = peripheral.wrap("monitor_0"),
            bufferMin = 30,
            bufferMax = 70
        }
    }
end

return config
