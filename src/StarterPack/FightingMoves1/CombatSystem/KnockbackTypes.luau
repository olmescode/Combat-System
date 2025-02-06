--!strict

--[[
    Enum for types of knockback in the combat system.
--]]

export type EnumType =
	"None"
	 | "Low"
	 | "Medium"
	 | "High"

local KnockbackTypes = {
	None = "None" :: "None",
	Low = "Low" :: "Low",
	Medium = "Medium" :: "Medium",
	High = "High" :: "High"
}

return KnockbackTypes
