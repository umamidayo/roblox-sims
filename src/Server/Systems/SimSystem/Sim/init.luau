local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Autonomy = require(ReplicatedStorage.Shared.Modules.Config.Autonomy)
local AutonomyUtility = require(ReplicatedStorage.Shared.Modules.AutonomyUtility)
local SimplePath = require(ReplicatedStorage.Shared.Modules.SimplePath)

local ActionFolder: Folder = ReplicatedStorage.Shared.Modules.Action
local Assets: Folder = ReplicatedStorage.Assets
local SimModel: Model = Assets.Sim

export type SimData = {
	name: string,
	age: number,
	gender: string,
}

export type SimState = "Standing" | "Sitting" | "Walking" | "Running" | "Dead"
export type SimSubState = "Nothing" | "Eating" | "Cleaning" | "Pooping" | "Sleeping"

local Sim = {}
Sim.__index = Sim

function Sim.new(simData: SimData)
	local self = setmetatable(simData, Sim)
	self.model = SimModel:Clone()
	self.humanoid = self.model.Humanoid
	self.rootPart = self.model.HumanoidRootPart
	self.startPosition = self.model:GetPivot().Position
	self.model.Name = simData.name
	self.model.Parent = workspace
	self.path = SimplePath.new(self.model, {
		AgentRadius = 1,
		AgentHeight = 5,
		AgentCanJump = false,
		AgentCanClimb = false,
	})
	self.path.Visualize = true
	self.actionQueue = {}
	self.needs = {
		Bladder = 50,
		Energy = 50,
		Fun = 50,
		Hunger = 50,
		Hygiene = 50,
		Social = 50,
	}
	self.state = "Standing"
	self.subState = "Nothing"
	self.autonomy = true

	return self
end

function Sim:updateNeeds()
	if self.subState ~= "Sleeping" then
		self.needs.Energy -= 1
	else
		self.needs.Energy += 5
	end

	if self.subState ~= "Eating" then
		self.needs.Hunger -= 1
	else
		self.needs.Hunger += 5
	end

	if self.subState ~= "Cleaning" then
		self.needs.Hygiene -= 1
	else
		self.needs.Hygiene += 5
	end

	if self.subState ~= "Pooping" then
		self.needs.Bladder -= 1
	else
		self.needs.Bladder += 5
	end

	if self.autonomy then
		local needsList = {}
		for need, value in self.needs do
			table.insert(needsList, { need = need, value = value })
		end

		table.sort(needsList, function(a, b)
			return a.value < b.value
		end)

		for _, needData in needsList do
			local need = needData.need
			local value = needData.value

			if value > 90 then
				if self:isFullfillingNeed(need) then
					self:stopCurrentAction()
				end
				continue
			end

			local actionName, instance = AutonomyUtility.getNeedAutonomy(self, need)
			if actionName and instance and not self:hasActionQueued(actionName, instance) then
				self:addAction(actionName, instance)
			end
		end
	end

	self:processActions()
end

function Sim:isFullfillingNeed(need: string)
	local currentAction = self.currentAction
	local needType = AutonomyUtility.getNeedType(currentAction.name)
	return needType == need
end

function Sim:hasActionQueued(actionName: string, actionInstance: Instance?)
	for index, action in self.actionQueue do
		if action.name == actionName and action.instance == actionInstance then
			return index, action
		end
	end
end

function Sim:addAction(actionName: string, actionInstance: Instance?)
	local actionModule = ActionFolder:FindFirstChild(actionName)
	if not actionModule then
		warn(`{self.name} is trying to add an action that doesn't exist: {actionName}`)
		return
	end

	actionModule = require(actionModule)
	local action = actionModule.new({
		name = actionName,
		instance = actionInstance,
	})
	table.insert(self.actionQueue, action)
	print(`{self.name} added action: {actionName}`)
	return action
end

function Sim:processActions()
	if self.processingAction then
		return
	end

	if #self.actionQueue > 0 then
		self.processingAction = true
		self.currentAction = self.actionQueue[1]
		print(`{self.name} is processing action: {self.currentAction.name}`)
		self.currentAction:perform(self)
	end
end

function Sim:stopCurrentAction()
	if self.currentAction then
		self:stand()
		local index = table.find(self.actionQueue, self.currentAction)
		if index then
			table.remove(self.actionQueue, index)
			self.currentAction:destroy()
			self.currentAction = nil
		end
		self.processingAction = false
	end
end

function Sim:stand()
	local humanoid: Humanoid = self.humanoid
	if humanoid.Sit then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
	task.wait(0.5)
	self.state = "Standing"
	self.subState = "Nothing"
end

function Sim:moveTo(position: Vector3)
	self:stand()

	self.path:Run(position)

	self.path.Blocked:Connect(function()
		print(`{self.name} is can't move to their destination because the path is blocked`)
		self.model:MoveTo(self.startPosition)
		self.processingAction = false
	end)

	self.path.Error:Connect(function()
		print(`{self.name} is can't move to their destination because the path errored`)
		self.model:MoveTo(self.startPosition)
		self.processingAction = false
	end)

	return self.path.Reached
end

function Sim:destroy()
	if self.model then
		self.model:Destroy()
	end

	setmetatable(self, nil)
end

return Sim
