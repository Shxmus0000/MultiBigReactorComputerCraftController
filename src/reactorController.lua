local discovery = require("src.discovery")
local reactorCore = require("src.reactorCore")
local dashboard = require("src.scadaDashboard")

local reactors = discovery.scan()

-- init all reactors
for _, r in ipairs(reactors) do
    reactorCore.init(r)
end

while true do
    for _, r in ipairs(reactors) do
        reactorCore.update(r)
    end

    dashboard.render(reactors)

    sleep(0.25)
end
