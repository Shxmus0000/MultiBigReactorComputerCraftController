local files = {
    "startup.lua",
    "update_reactor.lua",
    "src/reactorController.lua",
    "src/reactorCore.lua",
    "src/pid.lua",
    "src/monitorRenderer.lua",
    "src/config.lua",
    "api/touchpoint.lua"
}

for _, f in ipairs(files) do
    print("Installed: " .. f)
end

shell.run("reboot")
