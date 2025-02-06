--!strict

local CombatSystemFolder = script:FindFirstAncestor("CombatSystem")

local ActionNames = require(CombatSystemFolder.ActionNames)
local AttackTypes = require(CombatSystemFolder.AttackTypes)

-- Define the mapping of combat names to attack types
local ActionNameToAttackType: { [ActionNames.EnumType]: AttackTypes.EnumType } = {
	[ActionNames.HeavyKick] = AttackTypes.Short,
	[ActionNames.DoubleHit] = AttackTypes.Short,
	[ActionNames.SpinKick] = AttackTypes.Long,
	[ActionNames.FuryKick] = AttackTypes.Long
}

return ActionNameToAttackType
