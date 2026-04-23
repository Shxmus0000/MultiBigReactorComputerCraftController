local M = {}

local function clear(mon)
    mon.setBackgroundColor(colors.black)
    mon.clear()
end

function M.draw(r)
    local mon = r.monitor
    if not mon then return end

    clear(mon)

    local pct = (r.state.stored / r.state.capacity) * 100

    mon.setCursorPos(1,1)
    mon.write(r.name)

    mon.setCursorPos(1,3)
    mon.write("Energy: " .. string.format("%.1f%%", pct))

    mon.setCursorPos(1,4)
    mon.write("RFT: " .. math.floor(r.state.lastRFT))

    mon.setCursorPos(1,5)
    mon.write("Min: " .. r.bufferMin .. "%")

    mon.setCursorPos(1,6)
    mon.write("Max: " .. r.bufferMax .. "%")

    mon.setCursorPos(1,8)
    mon.write(r.reactor.getActive() and "ONLINE" or "OFFLINE")
end

return M
