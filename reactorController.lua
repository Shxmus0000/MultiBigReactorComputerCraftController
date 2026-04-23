local version = "1.0-MULTI"
local tag = "reactorConfig"

dofile("/usr/apis/touchpoint.lua")

-- =========================
-- GLOBAL STATE
-- =========================
local reactors = {}
local reactorVersion = "Unknown"

local mon, monSide
local sizex, sizey, dim, oo, offy

local btnOn, btnOff, invalidDim
local minb, maxb

local storedLastTick, storedThisTick, lastRFT = 0,0,0
local fuelTemp, caseTemp, fuelUsage, waste, capacity = 0,0,0,0,1
local rod = 0
local rfLost = 0

local displayingGraphMenu = false
local secondsToAverage = 2

-- =========================
-- AVERAGES
-- =========================
local storedThisTickValues = {}
local lastRFTValues = {}
local rodValues = {}
local fuelUsageValues = {}
local wasteValues = {}
local fuelTempValues = {}
local caseTempValues = {}
local rfLostValues = {}

local averageStoredThisTick = 0
local averageLastRFT = 0
local averageRod = 0
local averageFuelUsage = 0
local averageWaste = 0
local averageFuelTemp = 0
local averageCaseTemp = 0
local averageRfLost = 0

-- =========================
-- GRAPH SYSTEM
-- =========================
local graphs =
{
    "Energy Buffer",
    "Control Level",
    "Temperatures",
}

local XOffs =
{
    { 4, true},
    {27, true},
    {50, true},
}

local graphsToDraw = {}

-- =========================
-- UTIL
-- =========================
local function calculateAverage(array)
    local sum = 0
    if #array == 0 then return 0 end
    for _, v in ipairs(array) do
        sum = sum + v
    end
    return sum / #array
end

local function format(num)
    if (num >= 1e9) then return string.format("%7.2fG", num/1e9)
    elseif (num >= 1e6) then return string.format("%7.2fM", num/1e6)
    elseif (num >= 1e3) then return string.format("%7.2fK", num/1e3)
    elseif (num >= 1) then return string.format("%7.2f", num)
    else return string.format("%7.2f", 0) end
end

local function lerp(a,b,t)
    t = math.max(0, math.min(1,t))
    return a + (b-a)*t
end

-- =========================
-- REACTOR DETECTION
-- =========================
local function getPeripheral(name)
    for _,v in pairs(peripheral.getNames()) do
        if peripheral.getType(v) == name then
            return v
        end
    end
end

local function detectReactors()
    reactors = {}

    local types = {
        "bigger-reactor",
        "BiggerReactors_Reactor",
        "BigReactors-Reactor"
    }

    for _,t in ipairs(types) do
        for _,name in pairs(peripheral.getNames()) do
            if peripheral.getType(name) == t then
                table.insert(reactors, peripheral.wrap(name))
            end
        end
    end

    if #reactors > 0 then
        reactorVersion = "Multi Reactor System ("..#reactors..")"
        return true
    end

    return false
end

-- =========================
-- MULTI REACTOR STATS
-- =========================
local function updateStats()
    storedLastTick = storedThisTick

    local totalEnergy = 0
    local totalProduced = 0
    local totalFuel = 0
    local totalWaste = 0
    local totalTempFuel = 0
    local totalTempCase = 0
    local rodSum = 0

    capacity = 0

    for _,r in ipairs(reactors) do

        if r.getEnergyStats then
            local bat = r.getEnergyStats()
            totalEnergy = totalEnergy + bat.energyStored
            totalProduced = totalProduced + bat.energyProducedLastTick
            capacity = capacity + bat.energyCapacity
        elseif r.battery then
            totalEnergy = totalEnergy + r.battery().stored()
            totalProduced = totalProduced + r.battery().producedLastTick()
            capacity = capacity + r.battery().capacity()
        end

        if r.getFuelStats then
            local f = r.getFuelStats()
            totalFuel = totalFuel + (f.fuelConsumedLastTick or 0)
        elseif r.fuelTank then
            totalFuel = totalFuel + (r.fuelTank().burnedLastTick() or 0)
        end

        if r.getWasteAmount then
            totalWaste = totalWaste + r.getWasteAmount()
        elseif r.fuelTank then
            totalWaste = totalWaste + r.fuelTank().waste()
        end

        if r.getFuelTemperature then
            totalTempFuel = totalTempFuel + r.getFuelTemperature()
            totalTempCase = totalTempCase + r.getCasingTemperature()
        end

        rodSum = rodSum + (r.getControlRodLevel and r.getControlRodLevel(0) or 0)
    end

    storedThisTick = totalEnergy
    lastRFT = totalProduced
    fuelUsage = totalFuel
    waste = totalWaste

    fuelTemp = totalTempFuel / #reactors
    caseTemp = totalTempCase / #reactors
    rod = rodSum / #reactors

    rfLost = lastRFT + storedLastTick - storedThisTick

    -- averages
    table.insert(storedThisTickValues, storedThisTick)
    table.insert(lastRFTValues, lastRFT)
    table.insert(rodValues, rod)
    table.insert(fuelUsageValues, fuelUsage)
    table.insert(wasteValues, waste)
    table.insert(fuelTempValues, fuelTemp)
    table.insert(caseTempValues, caseTemp)
    table.insert(rfLostValues, rfLost)

    local maxIterations = 20 * secondsToAverage
    while #storedThisTickValues > maxIterations do
        table.remove(storedThisTickValues,1)
        table.remove(lastRFTValues,1)
        table.remove(rodValues,1)
        table.remove(fuelUsageValues,1)
        table.remove(wasteValues,1)
        table.remove(fuelTempValues,1)
        table.remove(caseTempValues,1)
        table.remove(rfLostValues,1)
    end

    averageStoredThisTick = calculateAverage(storedThisTickValues)
    averageLastRFT = calculateAverage(lastRFTValues)
    averageRod = calculateAverage(rodValues)
    averageFuelUsage = calculateAverage(fuelUsageValues)
    averageWaste = calculateAverage(wasteValues)
    averageFuelTemp = calculateAverage(fuelTempValues)
    averageCaseTemp = calculateAverage(caseTempValues)
    averageRfLost = calculateAverage(rfLostValues)
end

-- =========================
-- CONTROL ALL REACTORS
-- =========================
local function setRods(level)
    level = math.max(0, math.min(100, level))
    for _,r in ipairs(reactors) do
        if r.setAllControlRodLevels then
            r.setAllControlRodLevels(level)
        elseif r.setControlRodLevel then
            r.setControlRodLevel(0, level)
        end
    end
end

local pid = {
    Kp = -0.08,
    Ki = -0.0015,
    Kd = -0.01,
    integral = 0,
    lastError = 0
}

local function iteratePID(error)
    local P = pid.Kp * error
    pid.integral = math.max(-100, math.min(100, pid.integral + pid.Ki * error))
    local D = pid.Kd * (error - pid.lastError)

    pid.lastError = error

    return math.max(0, math.min(100, P + pid.integral + D))
end

local function updateRods()
    if not btnOn then return end

    local targetRF = (minb + maxb)/2 / 100 * capacity
    local error = targetRF - storedThisTick

    local rodLevel = iteratePID(error)
    setRods(rodLevel)
end

-- =========================
-- INIT / MAIN
-- =========================
local function main()
    term.clear()
    term.setCursorPos(1,1)

    print("Detecting reactors...")
    while not detectReactors() do
        print("No reactors found...")
        sleep(1)
    end

    print("Found "..#reactors.." reactors")

    btnOn = true
    btnOff = false
    minb = 30
    maxb = 70

    print("Starting controller...")
    sleep(1)

    while true do
        updateStats()
        updateRods()
        sleep(0.25)
    end
end

main()
