# Maid

It's a maid.

```lua
local mySignalConnection = script.Destroying:Connect(function() end)
local myInstance = Instance.new("Folder")
local myFunction = function() end
-- these two could also use PascalCase Disconnect and Destroy methods
local myConnection = { disconnect = function() end }
local myObject = { destroy = function() end }

local maid = Maid.new()

maid:giveTask(myConnection)
maid:giveTask(myObject)
maid:giveTask(mySignalConnection)
maid:giveTask(myInstance)
maid:giveTask(myFunction)

maid:destroy() -- cleans up all tasks
```
