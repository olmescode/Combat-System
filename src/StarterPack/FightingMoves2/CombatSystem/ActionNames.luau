--!strict

--[[
    Pseudo enums used to give unique names to combat system abilities so they can
    be referenced by name rather than typo-prone strings.
--]]

export type EnumType =
	"HeavyKick"
	 | "DoubleHit"
	 | "SpinKick"
	 | "FuryKick"

local ActionNames = {
	HeavyKick = "HeavyKick" :: "HeavyKick",
	DoubleHit = "DoubleHit" :: "DoubleHit",
	SpinKick = "SpinKick" :: "SpinKick",
	FuryKick = "FuryKick" :: "FuryKick"
}

return ActionNames
