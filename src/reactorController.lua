local touchpoint = dofile("api/touchpoint.lua")
local reactorCore = dofile("src/reactorCore.lua")
local config = dofile("src/config.lua")

local reactors = config.loadReactors()

-- init each reactor instance
for i, r in ipairs(reactors) do
    reactorCore.init(r)
end

while true do
    for _, r in ipairs(reactors) do
        reactorCore.update(r)
        reactorCore.render(r)
    end

    sleep(0.25)
end
