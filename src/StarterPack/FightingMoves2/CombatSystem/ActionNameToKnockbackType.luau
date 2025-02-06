--!strict

local CombatSystemFolder = script:FindFirstAncestor("CombatSystem")

local ActionNames = require(CombatSystemFolder.ActionNames)
local KnockbackTypes = require(CombatSystemFolder.KnockbackTypes)

-- Define the mapping of combat names to knockback types
local ActionNameToKnockbackType: { [ActionNames.EnumType]: KnockbackTypes.EnumType } = {
	[ActionNames.HeavyKick] = KnockbackTypes.Low,
	[ActionNames.DoubleHit] = KnockbackTypes.None,
	[ActionNames.SpinKick] = KnockbackTypes.Medium,
	[ActionNames.FuryKick] = KnockbackTypes.High
}

return ActionNameToKnockbackType
