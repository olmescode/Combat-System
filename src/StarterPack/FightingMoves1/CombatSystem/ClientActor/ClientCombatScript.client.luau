local tool = script.Parent.Parent.Parent
local CombatSystemFolder = script.Parent.Parent
local CombatSystemClient = require(CombatSystemFolder:WaitForChild("CombatSystemClient"))

CombatSystemClient.setup(tool)
