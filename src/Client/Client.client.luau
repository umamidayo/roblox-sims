local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Modules.Network)
Network.init()

local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")

for _, module: Instance in PlayerScripts.Client.Systems:GetChildren() do
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

print("Client initialized")