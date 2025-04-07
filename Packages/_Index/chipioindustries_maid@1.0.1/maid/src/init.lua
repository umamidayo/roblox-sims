local t = require(script.Parent.t)

local DESTRUCTOR_NAMES = {
	"Destroy";
	"destroy";
	"Disconnect";
	"disconnect"
}

local taskTypeCheck = t.union(t.Instance, t.RBXScriptConnection, t.table, t.callback)

local Maid = {}
Maid.__index = Maid

function Maid.new()
	local self = setmetatable({
		_destroyed = false;
		_destructorNames = table.clone(DESTRUCTOR_NAMES);
		_tasks = {};
	}, Maid)

	return self
end

function Maid:giveTask(task)
	self:_assertNotDestroyed()
	self:_assertValidTask(task)
	local deleteFunction = self:_getTaskDeleteFunction(task)
	assert(t.callback(deleteFunction))
	table.insert(self._tasks, deleteFunction)
end

function Maid:destroy()
	self:_assertNotDestroyed()
	self._destroyed = true
	for _index, task in ipairs(self._tasks) do
		task()
	end
end

function Maid:_getTaskDeleteFunction(task)
	self:_assertValidTask(task)
	local taskType = typeof(task)
	local isSignal = taskType == "RBXScriptConnection"
	local objectDestructorName = taskType == "table" and self:_getDestructorName(task)
	local isFunction = taskType == "function"
	local isInstance = taskType == "Instance"
	local deleteFunction = nil

	if isSignal then
		function deleteFunction()
			task:Disconnect()
		end
	elseif objectDestructorName then
		function deleteFunction()
			task[objectDestructorName](task)
		end
	elseif isFunction then
		deleteFunction = task
	elseif isInstance then
		deleteFunction = function()
			task:Destroy()
		end
	else
		error("Invalid task type " .. taskType)
	end

	return deleteFunction
end

function Maid:_getDestructorName(task)
	assert(t.table(task))
	for _index, destructorName in ipairs(self._destructorNames) do
		if task[destructorName] then
			return destructorName
		end
	end
end

function Maid:_assertNotDestroyed()
	assert(not self._destroyed, "Cannot add tasks to a destroyed maid")
end

function Maid:_assertValidTask(task)
	assert(taskTypeCheck(task))
end

return Maid