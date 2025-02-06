--!strict

local CombatSystemFolder = script:FindFirstAncestor("CombatSystem")

local ActionNames = require(CombatSystemFolder.ActionNames)
local AttackTypes = require(CombatSystemFolder.AttackTypes)

-- Define the mapping of combat names to attack types
local ActionNameToAttackType: { [ActionNames.EnumType]: AttackTypes.EnumType } = {
	[ActionNames.HeavyPunch] = AttackTypes.Short,
	[ActionNames.TwinPunch] = AttackTypes.Short,
	[ActionNames.Rapid] = AttackTypes.Short,
	[ActionNames.Rampage] = AttackTypes.Long
}

return ActionNameToAttackType
