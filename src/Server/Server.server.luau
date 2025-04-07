local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ReplicatedStorage.Shared.Modules.Network)
Network.init()

for _, module: Instance in ServerScriptService.Server.Systems:GetChildren() do
    if module:IsA("ModuleScript") then
        local requiredModule
        local success, errMsg = pcall(function()
            requiredModule = require(module)
        end)

        if not success then
            warn(`Failed to load {module.Name}: {errMsg}`)
            continue
        end

        if requiredModule.init then
            task.spawn(requiredModule.init)
        end
    end
end

print("Server initialized")