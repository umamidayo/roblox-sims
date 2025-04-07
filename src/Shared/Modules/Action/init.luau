local Action = {}
Action.__index = Action

export type ActionData = {
    name: string,
    instance: Model?,
}

function Action.new(actionData: ActionData)
    local self = setmetatable(actionData, Action)
    self.instancePosition = self.instance and self.instance:GetPivot().Position
    return self
end

function Action:destroy()
    setmetatable(self, nil)
end

return Action
