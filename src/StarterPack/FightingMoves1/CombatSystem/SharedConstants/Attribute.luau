--[[
	A source of truth list of all attributes used by scripts. Allows
	scripts to reference attributes by name without typo-prone strings
	that won't be caught until runtime.
--]]

export type EnumType =
	"Blocking"

local Attribute = {
	Blocking = "Blocking" :: "Blocking"
}

return Attribute
