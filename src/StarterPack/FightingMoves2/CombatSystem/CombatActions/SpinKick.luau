--!strict

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local CombatSystem = script:FindFirstAncestor("CombatSystem")

local Network = require(CombatSystem.Modules.Network)
local ActionNames = require(CombatSystem.ActionNames)
local ActionDamage = require(CombatSystem.ActionDamage)
local CameraShaker = require(CombatSystem.Modules.CameraShaker)
local Signal = require(CombatSystem.Modules.Signal)
local Attribute = require(CombatSystem.SharedConstants.Attribute)
local EffectsHandler = require(CombatSystem.Modules.EffectsHandler)

local player = Players.LocalPlayer :: Player

local RemoteEvents = Network.RemoteEvents
local animations = CombatSystem.Assets.Animations
local configuration = CombatSystem.Configuration

local COMBAT_ANIMATION = animations.SpinKick
local ACTION_NAME = ActionNames.SpinKick

local DEFAULT_ENERGY_COST = 20
local DEFAULT_DAMAGE_AMOUNT = 30

local DETECTION_RANGE_BOX = 12
local DETECTION_RANGE_RAY = 8

local DEBUG_MODE = configuration.DebugMode.Value

local SpinKick = {}
SpinKick.__index = SpinKick

export type ClassType = typeof(setmetatable(
	{} :: {
		_tool: Tool,
		name: string,
		energyCost: number?,
		attacking: boolean,
		attackCombo: number,
		damageAmount: number,
		cameraShaker: any?,
		onActionEnded: Signal.ClassType,
		requestCharacterConnection: RBXScriptConnection?,
	},
	SpinKick
	))

function SpinKick.new(tool: Tool): ClassType
	local self = setmetatable({}, SpinKick)

	self._tool = tool
	self.name = ACTION_NAME
	self.energyCost = DEFAULT_ENERGY_COST
	self.attacking = false
	self.attackCombo = 1
	self.damageAmount = ActionDamage[ACTION_NAME]
	self.cameraShaker = CameraShaker.new()
	self.onActionEnded = Signal.new()
	self.requestCharacterConnection = nil

	local requestCharacterConnection = Network.connectEvent(Network.RemoteEvents.RequestCharacter, function(actionName, characterOther)
		--self:_handleHitEffects(actionName, characterOther)
	end, Network.t.type("string"), Network.t.instanceOf("Model"))

	return self
end

function SpinKick:_loadAnimationTrack(animation: Animation)
	local character = player.Character :: Model
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			local animationTrack = animator:LoadAnimation(animation)
			return animationTrack
		end
	end
end

function SpinKick:_handleAttackEffects(character)
	EffectsHandler:playSwingSoundEffect(character)
end

function SpinKick:_handleHitEffects(actionName, characterOther)
	if actionName ~= self.name then 
		return 
	end

	self.cameraShaker:ShakeOnce(8, 4, 0.2, 0.5)

	EffectsHandler:createHighlightEffect(characterOther)
	EffectsHandler:playPunchedSoundEffect(characterOther)
	EffectsHandler:showDamage(characterOther:FindFirstChild("Head"), self.damageAmount)
end

function SpinKick:_handleAttackByBox()
	local character = player.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {character}

	local detectionRange = DETECTION_RANGE_BOX
	local origin = humanoidRootPart.CFrame * CFrame.new(0, 0, -4)
	local size = Vector3.new(detectionRange, detectionRange, detectionRange)

	-- Create a visual representation of the box (for debugging purposes)
	if DEBUG_MODE then
		local boxPart = Instance.new("Part")
		boxPart.Size = size
		boxPart.CFrame = origin
		boxPart.Transparency = 0.5
		boxPart.Anchored = true
		boxPart.CanCollide = false
		boxPart.BrickColor = BrickColor.new("Bright red")
		boxPart.Parent = workspace
		Debris:AddItem(boxPart, 0.5)
	end

	local detectedEnemies = {}
	local hitParts = workspace:GetPartBoundsInBox(origin, size, overlapParams)

	for _, hitPart in ipairs(hitParts) do
		local characterMaybe = hitPart.Parent

		if characterMaybe and not detectedEnemies[characterMaybe] then
			local humanoid = characterMaybe:FindFirstChildOfClass("Humanoid")
			if humanoid then
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {character}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude

				-- Calculate the direction and distance for the ray
				local direction = (characterMaybe.HumanoidRootPart.Position - humanoidRootPart.Position).Unit
				local maxDistance = (characterMaybe.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
				local rayDirection = direction * maxDistance

				local raycastResult = workspace:Raycast(humanoidRootPart.Position, rayDirection, raycastParams)

				if raycastResult then
					local hitPart = raycastResult.Instance
					local hitPosition = raycastResult.Position

					if hitPart:IsDescendantOf(characterMaybe) then
						local isBlocking = characterMaybe:GetAttribute("Blocking")

						if not isBlocking then
							local actionName = self.name
							Network.fireServer(Network.RemoteEvents.CombatHit, actionName, characterMaybe, hitPosition)
							self:_handleHitEffects(actionName, characterMaybe)
						else
							-- Handle case where player is blocking
						end
					end
				end

				detectedEnemies[characterMaybe] = true
			end
		end
	end

	-- Clear the table after processing
	for npc, _ in pairs(detectedEnemies) do
		detectedEnemies[npc] = nil
	end
end

function SpinKick:startAction()
	local character = player.Character :: Model
	local isBlocking = character:GetAttribute("Blocking")

	if self.attacking == true or isBlocking == true then return end

	self.attacking = true
	
	local function onPunchReached(marker)
		self:_handleAttackByBox()
		self:_handleAttackEffects(character)
	end

	local animationTrack = self:_loadAnimationTrack(COMBAT_ANIMATION)
	if animationTrack then
		-- Connect events for punch reaching markers
		local firstPunchConnection
		firstPunchConnection = animationTrack:GetMarkerReachedSignal("FirstPunch"):Connect(onPunchReached)
		
		animationTrack.Looped = false
		animationTrack:Play()
		animationTrack.Ended:Wait()
		
		self.onActionEnded:Fire()
		
		animationTrack:Stop()
		animationTrack:Destroy()
		
		firstPunchConnection:Disconnect()
		
		self.attacking = false
	end
end

function SpinKick:endAction()
	self.attacking = false
end

function SpinKick:destroy()
	if self._tool then
		self._tool:Destroy()
	end

	self._tool = nil
	self.name = nil
	self.energyCost = nil
	self.attacking = nil
	self.attackCombo = nil
	self.damageAmount = nil

	if self.requestCharacterConnection then
		self.requestCharacterConnection:Disconnect()
	end

	self.requestCharacterConnection = nil
	
	if self.cameraShaker then
		self.cameraShaker:destroy()
	end
	
	self.cameraShaker = nil
end

return SpinKick
