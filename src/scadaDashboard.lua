local dashboard = {}

local function clear(mon)
    mon.setBackgroundColor(colors.black)
    mon.clear()
end

local function drawBox(mon, x, y, w, h, color)
    mon.setBackgroundColor(color)

    for i = 0, h - 1 do
        mon.setCursorPos(x, y + i)
        mon.write(string.rep(" ", w))
    end

    mon.setBackgroundColor(colors.black)
end

function dashboard.render(reactors)
    local mainMon = term.current()

    clear(mainMon)

    mainMon.setCursorPos(1,1)
    mainMon.write("=== REACTOR SCADA DASHBOARD ===")

    local cols = 3
    local boxW = 20
    local boxH = 6

    for i, r in ipairs(reactors) do
        local x = ((i - 1) % cols) * (boxW + 2) + 1
        local y = math.floor((i - 1) / cols) * (boxH + 2) + 3

        drawBox(mainMon, x, y, boxW, boxH, colors.gray)

        local pct = (r.state.stored / r.state.capacity) * 100
        local status = pct > r.max and "HIGH"
                    or pct < r.min and "LOW"
                    or "OK"

        mainMon.setCursorPos(x + 1, y + 1)
        mainMon.write(r.name)

        mainMon.setCursorPos(x + 1, y + 2)
        mainMon.write(string.format("Power: %d%%", pct))

        mainMon.setCursorPos(x + 1, y + 3)
        mainMon.write("Status: " .. status)

        mainMon.setCursorPos(x + 1, y + 4)
        mainMon.write("RFT: " .. math.floor(r.state.lastRFT))
    end
end

return dashboard
