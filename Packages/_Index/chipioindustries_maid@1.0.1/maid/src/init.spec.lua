local Connection = {}
Connection.__index = Connection

function Connection.new(destructorName)
	local self = setmetatable({
		connected = true;
	}, Connection)

	self[destructorName] = function(object)
		object:_disconnect()
	end

	return self
end

function Connection:_disconnect()
	self.connected = false
end

return function()
	local Maid = require(script.Parent)

	local function testConnections(connections, expectation)
		for _destructorName, connection in pairs(connections) do
			expect(connection.connected).to.equal(expectation)
		end
	end

	describe("destruction", function()
		it("should accept RBXScriptConnections", function()
			local newMaid = Maid.new()

			local event = Instance.new("BindableEvent")
			local eventCount = 0
			local function onEvent()
				eventCount += 1
			end
			local connection = event.Event:Connect(onEvent)

			newMaid:giveTask(connection)
			event:Fire()
			expect(connection.Connected).to.equal(true)
			expect(eventCount).to.equal(1)

			newMaid:destroy()
			event:Fire()
			expect(connection.Connected).to.equal(false)
			expect(eventCount).to.equal(1)
			event:Destroy()
		end)
		it("should accept signal connections", function()
			local newMaid = Maid.new()
			local destructorNames = newMaid._destructorNames
			local connections = {}
			for _, name in ipairs(destructorNames) do
				local connection = Connection.new(name)
				connections[name] = connection
				newMaid:giveTask(connection)
			end
			testConnections(connections, true)
			newMaid:destroy()
			testConnections(connections, false)
		end)
		it("should accept functions", function()
			local newMaid = Maid.new()
			local hasDestroyed = false
			local function onDestroyed()
				hasDestroyed = true
			end
			newMaid:giveTask(onDestroyed)
			expect(hasDestroyed).to.equal(false)
			newMaid:destroy()
			expect(hasDestroyed).to.equal(true)
		end)
		it("should accept instances", function()
			local newMaid = Maid.new()
			local instance = Instance.new("Folder")
			local hasDestroyed = false
			local function onDestroying()
				hasDestroyed = true
			end
			instance.Destroying:Connect(onDestroying)
			newMaid:giveTask(instance)
			expect(hasDestroyed).to.equal(false)
			newMaid:destroy()
			expect(hasDestroyed).to.equal(true)
		end)
	end)
	describe("Error handling", function()
		it("should not accept invalid tasks", function()
			local newMaid = Maid.new()
			expect(function()
				newMaid:giveTask(nil)
			end).to.throw()
			expect(function()
				newMaid:giveTask("hello")
			end).to.throw()
		end)
		it("should not allow double destruction", function()
			local newMaid = Maid.new()
			newMaid:destroy()
			expect(function()
				newMaid:destroy()
			end).to.throw()
		end)
		it("should not accept tasks after destruction", function()
			local newMaid = Maid.new()
			newMaid:destroy()
			expect(function()
				newMaid:giveTask(function() end)
			end).to.throw()
		end)
		it("should assert not destroyed", function()
			local newMaid = Maid.new()
			newMaid:_assertNotDestroyed()
			newMaid:destroy()
			expect(function()
				newMaid:_assertNotDestroyed()
			end).to.throw()
		end)
	end)
end