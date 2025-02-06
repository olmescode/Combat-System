--!strict

local CombatSystemFolder = script:FindFirstAncestor("CombatSystem")

local ActionNames = require(CombatSystemFolder.ActionNames)
local KnockbackTypes = require(CombatSystemFolder.KnockbackTypes)

-- Define the mapping of combat names to knockback types
local ActionNameToKnockbackType: { [ActionNames.EnumType]: KnockbackTypes.EnumType } = {
	[ActionNames.HeavyPunch] = KnockbackTypes.Low,
	[ActionNames.TwinPunch] = KnockbackTypes.None,
	[ActionNames.Rapid] = KnockbackTypes.None,
	[ActionNames.Rampage] = KnockbackTypes.High
}

return ActionNameToKnockbackType
