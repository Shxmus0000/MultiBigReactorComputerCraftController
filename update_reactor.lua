-- Simple updater for GitHub install

local base = "https://raw.githubusercontent.com/Shxmus0000/MultiBigReactorComputerCraftController/main/"

local files = {
    "/reactorController.lua",
    "/install.lua",
    "/usr/apis/touchpoint.lua"
}

print("Updating Reactor Controller...")

for _,file in pairs(files) do
    local url = base .. file

    local res = http.get(url)
    if not res then
        print("Failed: " .. file)
    else
        local f = fs.open(file, "w")
        f.write(res.readAll())
        f.close()
        res.close()
        print("Updated: " .. file)
    end
end

print("Update complete.")
