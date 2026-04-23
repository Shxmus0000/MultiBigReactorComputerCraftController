local base = "https://raw.githubusercontent.com/Shxmus0000/MultiBigReactorComputerCraftController/main"

local files = {
    "/reactorController.lua",
    "/update_reactor.lua",
    "/usr/apis/touchpoint.lua"
}

print("Installing Multi Reactor Controller...")

for _,file in pairs(files) do
    local url = base .. file

    local res = http.get(url)
    if not res then
        error("Failed: " .. file)
    end

    local f = fs.open(file, "w")
    f.write(res.readAll())
    f.close()
    res.close()

    print("Installed: " .. file)
end

print("Done. Run reactorController.lua")
