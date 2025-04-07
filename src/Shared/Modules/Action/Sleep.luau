local Action = require(script.Parent)

local Sleep = {}
Sleep.__index = Sleep
setmetatable(Sleep, Action)

function Sleep.new(actionData: Action.ActionData)
	local self = setmetatable(Action.new(actionData), Sleep)
	self.seat = self.instance and self.instance:FindFirstChildWhichIsA("Seat", true)
	self.requiredState = "Standing"
	self.resultingState = "Sitting"

	if self.instance:HasTag("Bed") then
		self.subState = "Sleeping"
	end

	return self
end

function Sleep:perform(sim)
	sim:moveTo(self.instancePosition):Wait()
	self.seat:Sit(sim.humanoid)
	sim.state = self.resultingState
	if self.subState then
		sim.subState = self.subState
	end

	print(`{sim.name} is now {sim.state} {sim.subState}`)
end

return Sleep
