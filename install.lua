local base = "https://raw.githubusercontent.com/Shxmus0000/MultiBigReactorComputerCraftController/main/"

local files = {
    ["reactorController.lua"] = base .. "reactorController.lua",
    ["update_reactor.lua"] = base .. "update_reactor.lua",
    ["usr/apis/touchpoint.lua"] = base .. "usr/apis/touchpoint.lua",
}

print("Installing Multi Reactor Controller...")

for path, url in pairs(files) do
    local dir = fs.getDir(path)
    if dir and dir ~= "" then
        fs.makeDir(dir)
    end

    print("Downloading " .. path)

    local response = http.get(url)
    if not response then
        error("Failed to download " .. url)
    end

    local file = fs.open(path, "w")
    file.write(response.readAll())
    file.close()
    response.close()
end

print("Install complete!")
print("Run: reactorController.lua")
