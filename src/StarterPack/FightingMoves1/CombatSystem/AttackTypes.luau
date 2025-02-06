--!strict

--[[
    Enum for types of attacks in the combat system.
--]]

export type EnumType =
	"Long"
	 | "Short"

local AttackTypes = {
	Long = "Long" :: "Long",
	Short = "Short" :: "Short"
}

return AttackTypes
