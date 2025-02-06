--!strict

--[[
	KeyCodeBindingInfo module defines an enum type representing combat actions 
	along with their associated key bindings for keyboard and gamepad inputs, 
	and their display order.
--]]


local CombatSystemFolder = script:FindFirstAncestor("CombatSystem")

local Keybind = require(CombatSystemFolder.Modules.Keybind)
	
local KeyCodeBindingInfo = {
	PrimaryAction = {
		keyCodes = {
			Keyboard = Keybind.KeyboardPrimaryAction,
			Gamepad = Keybind.GamepadPrimaryAction
		},
		displayOrder = 1,
		cooldown = 2 -- TODO: Move this to an enum
	},
	SecondaryAction = {
		keyCodes = {
			Keyboard = Keybind.KeyboardSecondaryAction,
			Gamepad = Keybind.GamepadSecondaryAction
		},
		displayOrder = 2,
		cooldown = 4
	},
	SpecialAbility = {
		keyCodes = {
			Keyboard = Keybind.KeyboardSpecialAction,
			Gamepad = Keybind.GamepadSpecialAction
		},
		displayOrder = 3,
		cooldown = 6
	},
	ThirdAbility = {
		keyCodes = {
			Keyboard = Keybind.KeyboardDefensiveAction,
			Gamepad = Keybind.GamepadDefensiveAction
		},
		displayOrder = 4,
		cooldown = 2
	}
}

return KeyCodeBindingInfo
