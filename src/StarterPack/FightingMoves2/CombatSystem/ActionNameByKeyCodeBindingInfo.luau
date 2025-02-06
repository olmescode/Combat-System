--[[
	ActionNameByKeyCodeBindingInfo module maps action names to their corresponding 
	key code binding information defined in KeyCodeBindingInfo module.
--]]

local CombatSystemFolder = script:FindFirstAncestor("CombatSystem")

local ActionNames = require(CombatSystemFolder.ActionNames)
local KeyCodeBindingInfo = require(CombatSystemFolder.KeyCodeBindingInfo)

local ActionNameByKeyCodeBindingInfo: { [ActionNames.EnumType]: KeyCodeBindingInfo.EnumType } = {
	[ActionNames.HeavyKick] = KeyCodeBindingInfo.PrimaryAction,
	[ActionNames.DoubleHit] = KeyCodeBindingInfo.SecondaryAction,
	[ActionNames.SpinKick] = KeyCodeBindingInfo.SpecialAbility,
	[ActionNames.FuryKick] = KeyCodeBindingInfo.ThirdAbility
}

return ActionNameByKeyCodeBindingInfo
