local Action = require(script.Parent)

local Sit = {}
Sit.__index = Sit
setmetatable(Sit, Action)

function Sit.new(actionData: Action.ActionData)
    local self = setmetatable(Action.new(actionData), Sit)
	self.seat = self.instance and self.instance:FindFirstChildWhichIsA("Seat", true)
	self.requiredState = "Standing"
	self.resultingState = "Sitting"

    if self.instance:HasTag("Toilet") then
        self.subState = "Pooping"
    end

    return self
end

function Sit:perform(sim)
    sim:moveTo(self.instancePosition):Wait()
    self.seat:Sit(sim.humanoid)
    sim.state = self.resultingState
    if self.subState then
        sim.subState = self.subState
    end

    print(`{sim.name} is now {sim.state} {sim.subState}`)
end

return Sit