--[[
	Specifies the names of all RemoteEvents. One RemoteEvent object gets generated for each name
	in this list, and these names are used as enums when interacting with Network to tell it
	which remote event to fire without typing out typo-prone string literals.
--]]

export type EnumType =
	"ShowCombatEffect"
	| "RequestCharacter"

local RemoteEventName = {
	ShowCombatEffect = "ShowCombatEffect" :: "ShowCombatEffect",
	RequestCharacter = "RequestCharacter" :: "RequestCharacter"
}

return RemoteEventName
