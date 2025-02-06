--!strict

--[[
    Pseudo enums used to give unique names to combat system abilities so they can
    be referenced by name rather than typo-prone strings.
--]]

export type EnumType =
	"HeavyPunch"
	 | "TwinPunch"
	 | "Rapid"
	 | "Rampage"

local ActionNames = {
	HeavyPunch = "HeavyPunch" :: "HeavyPunch",
	TwinPunch = "TwinPunch" :: "TwinPunch",
	Rapid = "Rapid" :: "Rapid",
	Rampage = "Rampage" :: "Rampage"
}

return ActionNames
