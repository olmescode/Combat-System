local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Network)
local DamageBillboardHandler = require(script.DamageBillboardHandler)

local t = Network.t

local assets = script.Assets
local sounds = assets.Sounds
local effects = assets.Effects
local configuration = script.Configuration

local EffectsHandler = {}

function EffectsHandler.start()
	assert(RunService:IsClient(), "EffectsHandler can only be started on the client")

	EffectsHandler._listenForEvents()
end

function EffectsHandler.createHighlightEffect(characterOther)
	local visualEffects = configuration.VisualEffects
	if visualEffects.Value then
		local highlightEffect = effects.Highlight:Clone()
		highlightEffect.Enabled = true
		highlightEffect.Parent = characterOther

		local highlightTweenInfo = TweenInfo.new(
			2, -- time
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

function EffectsHandler.playPunchedSoundEffect(characterOther: Model)
	local soundEffects = configuration.SoundEffects
	if soundEffects.Value then
		local sound = sounds.Punched1:Clone()
		sound.Parent = characterOther
		sound:Play()

		Debris:AddItem(sound, 1)
	end
end

function EffectsHandler.playSwingSoundEffect(character: Model)
	local soundEffects = configuration.SoundEffects
	if soundEffects.Value then
		local sound = sounds.Swing:Clone()
		sound.Parent = character
		sound:Play()

		Debris:AddItem(sound, 1)
	end
end

-- Function to show damagebilboard
function EffectsHandler.showDamage(adornee: Instance, damage: number)
	local visualEffects = configuration.VisualEffects
	if visualEffects.Value then
		DamageBillboardHandler:showDamageBillboard(adornee, damage)
	end
end

function EffectsHandler._listenForEvents()
	Network.connectEvent(Network.RemoteEvents.ShowCombatEffect, function(playerWhoHit, actionName, damageAmount, characterOther)
		if playerWhoHit ~= Players.LocalPlayer then
			EffectsHandler.createHighlightEffect(characterOther)
			EffectsHandler.playPunchedSoundEffect(characterOther)
			EffectsHandler.showDamage(characterOther:FindFirstChild("Head"), damageAmount)
		end
	end, t.tuple(t.instanceOf("Player"), t.string, t.number, t.instanceOf("Model")))
end

return EffectsHandler
