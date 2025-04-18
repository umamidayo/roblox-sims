local AutonomyUtility = {}

AutonomyUtility.needsInstanceMap = {
	Bladder = "Toilet",
	Hygiene = "Shower",
	Hunger = "Fridge",
	Fun = "Entertainment",
	Energy = "Bed",
	Social = "Sim",
}

AutonomyUtility.needsActionMap = {
	Bladder = "Sit",
	Hygiene = "Shower",
	Hunger = "Eat",
	Fun = "Play",
	Energy = "Sleep",
	Social = "Talk",
}

function AutonomyUtility.findNearestInstance(instanceType: string, sim: Model, distance: number?)
	distance = distance or 1000
	local nearestInstance = nil
	local nearestDistance = distance

	for _, instance in workspace.Props:GetChildren() do
		if instance:HasTag(instanceType) then
			local distanceToInstance = (instance:GetPivot().Position - sim:GetPivot().Position).Magnitude
			if distanceToInstance < nearestDistance then
				nearestInstance = instance
				nearestDistance = distanceToInstance
			end
		end
	end

	return nearestInstance
end

function AutonomyUtility.getNeedType(actionName: string)
	for need, action in AutonomyUtility.needsActionMap do
		if action == actionName then
			return need
		end
	end
end

function AutonomyUtility.getNeedAutonomy(sim, need: string)
	local instanceType = AutonomyUtility.needsInstanceMap[need]
	if not instanceType then
		warn(`{need} is not a valid need`)
		return nil
	end

	local action = AutonomyUtility.needsActionMap[need]
	local instance = AutonomyUtility.findNearestInstance(instanceType, sim.model)

	return action, instance
end

return AutonomyUtility
