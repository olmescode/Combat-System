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

local COMBAT_ANIMATION = animations.TwinPunch
local ACTION_NAME = ActionNames.TwinPunch

local DEFAULT_ENERGY_COST = 20
local DEFAULT_DAMAGE_AMOUNT = 20

local DETECTION_RANGE_BOX = 12
local DETECTION_RANGE_RAY = 8

local DEBUG_MODE = configuration.DebugMode.Value

local TwinPunch = {}
TwinPunch.__index = TwinPunch

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
	TwinPunch
	))

function TwinPunch.new(tool: Tool): ClassType
	local self = setmetatable({}, TwinPunch)

	self._tool = tool
	self.name = ACTION_NAME
	self.energyCost = DEFAULT_ENERGY_COST
	self.attacking = false
	self.attackCombo = 1
	self.damageAmount = ActionDamage[ACTION_NAME]
	self.cameraShaker = CameraShaker.new()
	self.onActionEnded = Signal.new()
	self.requestCharacterConnection = nil

	local requestCharacterConnection = Network.connectEvent(Network.RemoteEvents.RequestCharacter, function(combatName, characterOther)
		--self:_handleHitEffects(combatName, characterOther)
	end, Network.t.type("string"), Network.t.instanceOf("Model"))

	return self
end

function TwinPunch:_loadAnimationTrack(animation: Animation)
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

function TwinPunch:_handleAttackEffects(character)
	EffectsHandler:playSwingSoundEffect(character)
end

function TwinPunch:_handleHitEffects(actionName, characterOther)
	if actionName ~= self.name then 
		return 
	end

	self.cameraShaker:ShakeOnce(8, 4, 0.2, 0.5)

	EffectsHandler:createHighlightEffect(characterOther)
	EffectsHandler:playPunchedSoundEffect(characterOther)
	EffectsHandler:showDamage(characterOther:FindFirstChild("Head"), self.damageAmount)
end

function TwinPunch:_handleAttackByBlock()
	local character = player.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local detectionRange = DETECTION_RANGE_RAY
	local blockSize = Vector3.new(4, 4, detectionRange)
	local blockCFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, blockSize.Z / 2)
	local direction = humanoidRootPart.CFrame.LookVector * detectionRange

	local blockcastResult = workspace:Blockcast(blockCFrame, blockSize, direction, raycastParams)

	-- Create a visual representation of the blockcast (for debugging purposes)
	if DEBUG_MODE then
		local visualCFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -blockSize.Z / 2)
		local blockPart = Instance.new("Part")
		blockPart.Size = blockSize
		blockPart.CFrame = visualCFrame
		blockPart.Transparency = 0.5
		blockPart.Anchored = true
		blockPart.CanCollide = false
		blockPart.BrickColor = BrickColor.new("Bright blue")
		blockPart.Parent = workspace
		Debris:AddItem(blockPart, 0.5)
	end

	if blockcastResult then
		local hitPart = blockcastResult.Instance
		local hitPosition = blockcastResult.Position
		local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local isBlocking = humanoid.Parent:GetAttribute("Blocking")
			if not isBlocking then
				local characterMaybe = humanoid.Parent
				local actionName = self.name
				Network.fireServer(Network.RemoteEvents.CombatHit, actionName, characterMaybe, hitPosition)
				self:_handleHitEffects(actionName, characterMaybe)
			else
				-- Handle case where player is blocking
			end
		end
	end
end

function TwinPunch:startAction()
	local character = player.Character :: Model
	local isBlocking = character:GetAttribute(Attribute.Blocking)

	if self.attacking == true or isBlocking == true then return end

	self.attacking = true
	
	local function onPunchReached(marker)
		self:_handleAttackByBlock()
		self:_handleAttackEffects(character)
	end
	
	local animationTrack = self:_loadAnimationTrack(COMBAT_ANIMATION)
	if animationTrack then
		-- Connect events for punch reaching markers
		local firstPunchConnection
		firstPunchConnection = animationTrack:GetMarkerReachedSignal("FirstPunch"):Connect(onPunchReached)
		local secondPunchConnection
		secondPunchConnection = animationTrack:GetMarkerReachedSignal("SecondPunch"):Connect(onPunchReached)

		animationTrack.Looped = false
		animationTrack:Play()
		animationTrack.Ended:Wait()
		
		self.onActionEnded:Fire()
		
		animationTrack:Stop()
		animationTrack:Destroy()
		
		firstPunchConnection:Disconnect()
		secondPunchConnection:Disconnect()
		
		self.attacking = false
	end
end

function TwinPunch:endAction()
	self.attacking = false
end

function TwinPunch:destroy()
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

return TwinPunch
