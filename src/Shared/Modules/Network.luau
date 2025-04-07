local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FOLDER_NAME = "Remotes"
local FOLDER_PATH = ReplicatedStorage

local NetworkFolder: Folder? = nil

--[[
    A lightweight networking module that allows you to handle events without boilerplate or setup.

    Written by @umamidayo
]]
local Network = {}

-- Returns a signal with the given name and type. If the signal doesn't already exist, it'll create it.
function Network.getSignal(signalName: string, signalType: string)
	if not NetworkFolder then
		NetworkFolder = FOLDER_PATH:WaitForChild(FOLDER_NAME)
	end

	local signal = NetworkFolder:FindFirstChild(signalName)
	if not signal then
		signal = Instance.new(signalType)
		signal.Name = signalName
		signal.Parent = NetworkFolder
	end

	return signal
end

-- Initializes the network folder if it doesn't exist. On the client, it will wait for the setup to complete.
function Network.init()
	if RunService:IsServer() then
		NetworkFolder = FOLDER_PATH:FindFirstChild(FOLDER_NAME)
		if not NetworkFolder then
			NetworkFolder = Instance.new("Folder")
			NetworkFolder.Name = FOLDER_NAME
			NetworkFolder.Parent = FOLDER_PATH
		end
	else
		NetworkFolder = FOLDER_PATH:WaitForChild(FOLDER_NAME)
	end
end

return Network
