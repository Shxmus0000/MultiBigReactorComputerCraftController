-- Multi-Reactor Extension of Kasra-G ReactorController
-- Fully compatible with touchpoint + original UI system

local version = "0.60-MULTI"

dofile("/usr/apis/touchpoint.lua")

-- ===== GLOBAL STATE =====
local reactors = {}
local mon, monSide
local sizex, sizey, dim, oo

local btnOn = {}
local btnOff = {}
local minb = {}
local maxb = {}

local graphsToDraw = {}

local secondsToAverage = 2

-- ===== HELPERS =====
local function getPeripheral(name)
    for _,v in pairs(peripheral.getNames()) do
        if peripheral.getType(v) == name then
            return v
        end
    end
end

-- ===== REACTOR WRAPPER =====
local function wrapReactor(r)
    local type
    if r.getEnergyStats then
        type = "Extreme"
    elseif r.battery then
        type = "Bigger"
    else
        type = "Big"
    end

    return {
        obj = r,
        type = type,

        stored = 0,
        rf = 0,
        rod = 0,
        capacity = 1,

        pid = {
            setpointRFT = 0,
            setpointRF = 0,
            Kp = -0.08,
            Ki = -0.0015,
            Kd = -0.01,
            integral = 0,
            lastError = 0
        }
    }
end

-- ===== DETECT ALL REACTORS =====
local function detectReactors()
    for _,name in pairs(peripheral.getNames()) do
        if peripheral.getType(name):lower():find("reactor") then
            table.insert(reactors, wrapReactor(peripheral.wrap(name)))
        end
    end
end

-- ===== RF READING (FIXED CORE ISSUE) =====
local function getRFt(r)
    if r.type == "Extreme" then
        return r.obj.getEnergyStats().energyProducedLastTick
    elseif r.type == "Bigger" then
        return r.obj.battery().producedLastTick()
    else
        return r.obj.getEnergyProducedLastTick() or 0
    end
end

local function getEnergy(r)
    if r.type == "Extreme" then
        return r.obj.getEnergyStats().energyStored
    elseif r.type == "Bigger" then
        return r.obj.battery().stored()
    else
        return r.obj.getEnergyStored()
    end
end

local function setRods(r, level)
    level = math.max(0, math.min(100, level))

    if r.type == "Bigger" then
        r.obj.getControlRod(0).setLevel(level)
    else
        r.obj.setAllControlRodLevels(level)
    end

    r.rod = level
end

-- ===== PID (PER REACTOR) =====
local function pidStep(pid, error)
    local P = pid.Kp * error

    pid.integral = pid.integral + pid.Ki * error
    pid.integral = math.max(math.min(pid.integral, 100), -100)

    local D = pid.Kd * (error - pid.lastError)

    local out = P + pid.integral + D
    pid.lastError = error

    return math.max(0, math.min(100, out))
end

-- ===== UPDATE LOOP =====
local function update()
    for _,r in ipairs(reactors) do

        r.stored = getEnergy(r)
        r.rf = getRFt(r)

        local error = (500000 - r.stored) / 10000

        local rod = pidStep(r.pid, error)

        setRods(r, rod)

        if r.stored < 200000 then
            r.obj.setActive(true)
        elseif r.stored > 800000 then
            r.obj.setActive(false)
        end
    end
end

-- ===== DRAW SYSTEM =====
local function draw()
    mon.setBackgroundColor(colors.black)
    mon.clear()

    local w,h = mon.getSize()
    local cols = math.max(1, #reactors)
    local pw = math.floor(w / cols)

    for i,r in ipairs(reactors) do
        local x = (i-1)*pw + 1

        mon.setCursorPos(x,2)
        mon.write("R"..i.." ["..r.type.."]")

        mon.setCursorPos(x,3)
        mon.write("RF/t: "..math.floor(r.rf))

        mon.setCursorPos(x,4)
        mon.write("Energy: "..math.floor(r.stored))

        mon.setCursorPos(x,5)
        mon.write("Rod: "..math.floor(r.rod).."%")
    end
end

-- ===== MONITOR INIT =====
local function initMon()
    monSide = getPeripheral("monitor")
    if not monSide then error("No monitor") end

    mon = peripheral.wrap(monSide)
    mon.setTextScale(0.5)

    sizex, sizey = mon.getSize()
end

-- ===== LOOP =====
local function loop()
    while true do
        update()
        draw()
        sleep(0.2)
    end
end

-- ===== MAIN =====
local function main()
    initMon()
    detectReactors()

    if #reactors == 0 then
        error("No reactors found")
    end

    print("Loaded "..#reactors.." reactors")

    loop()
end

main()
