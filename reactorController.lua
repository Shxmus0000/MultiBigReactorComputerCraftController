-- Multi-Reactor Controller (GitHub Version)
-- Supports Big / Extreme / Bigger Reactors

local monitor = peripheral.find("monitor")
if not monitor then error("No monitor found") end

monitor.setTextScale(0.5)

-- ===== REACTORS =====
local reactors = {}

local function detectType(r)
    if r.getEnergyStats then return "Extreme" end
    if r.battery then return "Bigger" end
    return "Big"
end

local function wrap(name)
    local r = peripheral.wrap(name)
    local type = detectType(r)

    local obj = {peripheral = r, type = type, rod = 0}

    function obj.energy()
        if type == "Extreme" then
            return r.getEnergyStats().energyStored
        elseif type == "Bigger" then
            return r.battery().stored()
        else
            return r.getEnergyStored()
        end
    end

    function obj.rf()
        if type == "Extreme" then
            return r.getEnergyStats().energyProducedLastTick
        elseif type == "Bigger" then
            return r.battery().producedLastTick()
        else
            return r.getEnergyProducedLastTick() or 0
        end
    end

    function obj.setActive(state)
        r.setActive(state)
    end

    function obj.setRod(v)
        v = math.max(0, math.min(100, v))
        if type == "Bigger" then
            r.getControlRod(0).setLevel(v)
        else
            r.setAllControlRodLevels(v)
        end
        obj.rod = v
    end

    return obj
end

for _,n in pairs(peripheral.getNames()) do
    if peripheral.getType(n):lower():find("reactor") then
        table.insert(reactors, wrap(n))
    end
end

if #reactors == 0 then error("No reactors found") end

-- ===== SIMPLE AUTO CONTROL =====
local AUTO_MIN = 200000
local AUTO_MAX = 800000
local auto = true

local function update()
    for _,r in ipairs(reactors) do
        local e = r.energy()

        if auto then
            if e < AUTO_MIN then
                r.setActive(true)
                r.setRod(r.rod - 2)
            elseif e > AUTO_MAX then
                r.setRod(r.rod + 2)
            end
        end
    end
end

-- ===== DRAW =====
local function draw()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()

    local w,h = monitor.getSize()
    local pw = math.floor(w / #reactors)

    for i,r in ipairs(reactors) do
        local x = (i-1)*pw + 1

        monitor.setCursorPos(x,2)
        monitor.write("R"..i.." ["..r.type.."]")

        monitor.setCursorPos(x,3)
        monitor.write("RF/t: "..math.floor(r.rf() or 0))

        monitor.setCursorPos(x,4)
        monitor.write("Energy: "..math.floor(r.energy() or 0))

        monitor.setCursorPos(x,5)
        monitor.write("Rod: "..math.floor(r.rod))
    end

    monitor.setCursorPos(2,h)
    monitor.write("[AUTO: "..tostring(auto).." ]")
end

-- ===== INPUT =====
local function click(x,y)
    local _,h = monitor.getSize()
    if y == h then
        auto = not auto
    end
end

-- ===== LOOP =====
while true do
    update()
    draw()

    local e,_,x,y = os.pullEvent("monitor_touch")
    click(x,y)

    sleep(0.2)
end
