--!strict

local CombatSystemFolder = script:FindFirstAncestor("CombatSystem")

local ActionNames = require(CombatSystemFolder.ActionNames)

local ActionDamage: { [ActionNames.EnumType]: number }  = {
	[ActionNames.HeavyPunch] = 20,
	[ActionNames.TwinPunch] = 15,
	[ActionNames.Rapid] = 10,
	[ActionNames.Rampage] = 25
}

return ActionDamage
