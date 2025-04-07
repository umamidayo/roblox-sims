local Action = require(script.Parent)

local Stand = {}
Stand.__index = Stand
setmetatable(Stand, Action)

function Stand.new(actionData: Action.ActionData)
	local self = setmetatable(Action.new(actionData), Stand)
	self.seat = self.instance and self.instance:FindFirstChildWhichIsA("Seat", true)
	self.requiredState = "Sitting"
	self.resultingState = "Standing"
    self.resultingSubState = "Nothing"
	return self
end

function Stand:perform(sim)
    local humanoid: Humanoid = sim.humanoid
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    sim.state = self.resultingState
    sim.subState = self.resultingSubState
    task.wait(0.5)
    sim:moveTo(self.instancePosition):Wait()
	print(`{sim.name} is now {sim.state} {sim.subState}`)
	self:destroy()
end

return Stand
