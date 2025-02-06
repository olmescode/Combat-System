local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local EffectsHandler = {}

local CombatSystem = script:FindFirstAncestor("CombatSystem")

local DamageBillboardHandler = require(CombatSystem.Modules.DamageBillboardHandler)

local sounds = CombatSystem.Assets.Sounds
local effects = CombatSystem.Assets.Effects
local configuration = CombatSystem.Configuration

function EffectsHandler:createHighlightEffect(characterOther)
	local visualEffects = configuration.VisualEffects
	if visualEffects.Value then
		local highlightEffect = effects.Highlight:Clone()
		highlightEffect.Enabled = true
		highlightEffect.Parent = characterOther

		local highlightTweenInfo = TweenInfo.new(
			3, -- time
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			0, -- repeatCount
			false, -- reverses
			0 -- delayTime
		)
		local highlightTween = TweenService:Create(
			highlightEffect,
			highlightTweenInfo, {
				FillTransparency = 1,
				OutlineTransparency = 1
			}
		)

		highlightTween.Completed:Once(function()
			highlightEffect:Destroy()
		end)

		highlightTween:Play()
	end
end

function EffectsHandler:playPunchedSoundEffect(characterOther)
	local soundEffects = configuration.SoundEffects
	if soundEffects.Value then
		local sound = sounds.Punched1:Clone()
		sound.Parent = characterOther
		sound:Play()

		Debris:AddItem(sound, 1)
	end
end

function EffectsHandler:playSwingSoundEffect(character)
	local soundEffects = configuration.SoundEffects
	if soundEffects.Value then
		local sound = sounds.Swing:Clone()
		sound.Parent = character
		sound:Play()

		Debris:AddItem(sound, 1)
	end
end

-- Function to show damagebilboard
function EffectsHandler:showDamage(adornee, damage)
	local visualEffects = CombatSystem.Configuration.VisualEffects
	if visualEffects.Value then
		DamageBillboardHandler:showDamageBillboard(adornee, damage)
	end
end

return EffectsHandler
