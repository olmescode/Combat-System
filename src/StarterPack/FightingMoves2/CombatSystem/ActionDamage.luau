--!strict

local CombatSystemFolder = script:FindFirstAncestor("CombatSystem")

local ActionNames = require(CombatSystemFolder.ActionNames)

local ActionDamage: { [ActionNames.EnumType]: number }  = {
	[ActionNames.HeavyKick] = 20,
	[ActionNames.DoubleHit] = 15,
	[ActionNames.SpinKick] = 10,
	[ActionNames.FuryKick] = 25
}

return ActionDamage
