local RunService = game:GetService("RunService")

local Sim = require(script.Sim)

local SimSystem = {}

local Sims = {}

function SimSystem.getSim(name: string)
    return Sims[name]
end

function SimSystem.init()
    local elapsed = 0
    RunService.Heartbeat:Connect(function(deltaTime)
        elapsed += deltaTime
        if elapsed < 1.1 then
            return
        else
            elapsed = 0
        end

        for _, sim in Sims do
            task.spawn(function()
                sim:updateNeeds()
            end)
        end
    end)

	local newSim = Sim.new({
		name = "Goro Majima",
		age = 18,
		gender = "Male",
	})
	Sims[newSim.name] = newSim
end

return SimSystem
