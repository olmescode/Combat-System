--[[
	ActionNameByKeyCodeBindingInfo module maps action names to their corresponding 
	key code binding information defined in KeyCodeBindingInfo module.
--]]

local CombatSystemFolder = script:FindFirstAncestor("CombatSystem")

local ActionNames = require(CombatSystemFolder.ActionNames)
local KeyCodeBindingInfo = require(CombatSystemFolder.KeyCodeBindingInfo)

local ActionNameByKeyCodeBindingInfo: { [ActionNames.EnumType]: KeyCodeBindingInfo.EnumType } = {
	[ActionNames.HeavyPunch] = KeyCodeBindingInfo.PrimaryAction,
	[ActionNames.TwinPunch] = KeyCodeBindingInfo.SecondaryAction,
	[ActionNames.Rapid] = KeyCodeBindingInfo.SpecialAbility,
	[ActionNames.Rampage] = KeyCodeBindingInfo.ThirdAbility
}

return ActionNameByKeyCodeBindingInfo
