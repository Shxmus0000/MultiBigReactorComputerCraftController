local repo = "https://raw.githubusercontent.com/Shxmus0000/MultiBigReactorComputerCraftController/main/"

local function get(file)
    local h = http.get(repo .. file)
    if not h then error("Failed: "..file) end
    local f = fs.open(file, "w")
    f.write(h.readAll())
    f.close()
    h.close()
end

print("Installing...")

get("reactorController.lua")
get("update_reactor.lua")
fs.makeDir("/usr/apis")
get("usr/apis/touchpoint.lua")

print("Done. Run reactorController.lua")
