--!strict

print("Required CombatSystem")

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatSystemFolder = script.Parent

local Network = require(CombatSystemFolder.Modules.Network)
local ActionDamage = require(CombatSystemFolder.ActionDamage)
local AttackTypes = require(CombatSystemFolder.AttackTypes)
local ActionNameToAttackType = require(CombatSystemFolder.ActionNameToAttackType)
local KnockbackTypes = require(CombatSystemFolder.KnockbackTypes)
local ActionNameToKnockbackType = require(CombatSystemFolder.ActionNameToKnockbackType)
local Attribute = require(CombatSystemFolder.SharedConstants.Attribute)

local RemoteEvents = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvents")

local DETECTION_RANGE_BOX = 12
local DETECTION_RANGE_RAY = 8

local KNOCKBACK_STRENGTH_LOW = 5
local KNOCKBACK_STRENGTH_MEDIUM = 10
local KNOCKBACK_STRENGTH_HIGH = 40

local MAX_HIT_PROXIMITY = 10

local CombatSystem = {}
CombatSystem._connections = {}

function CombatSystem.setup()
	Network.startServer()
	
	local combatHitConnection = Network.connectEvent(Network.RemoteEvents.CombatHit, function(
		player: Player,
		combatName: string,
		characterToDamage: Model,
		hitPosition: Vector3
	)
		-- Handle different types of validation logic for combat hits
		local attackType = ActionNameToAttackType[combatName]
		if attackType == AttackTypes.Short then
			CombatSystem._validateAttack(player, combatName, characterToDamage, hitPosition)
		elseif attackType == AttackTypes.Long then
			CombatSystem._validateAttack(player, combatName, characterToDamage, hitPosition)
		end
	end, Network.t.instanceOf("Player"))
	
	local combatBlockedConnection = Network.connectEvent(Network.RemoteEvents.CombatBlocked, function(player: Player, isBlocking: boolean)
		CombatSystem._onDefensiveStanceEvent(player, isBlocking)
	end, Network.t.instanceOf("Player"))
	
	table.insert(CombatSystem._connections, combatHitConnection)
	table.insert(CombatSystem._connections, combatBlockedConnection)
end

function CombatSystem._applyDamage(actionName, characterOther)
	local damageAmount = ActionDamage[actionName]
	if not damageAmount then
		warn("Damage amount not found for action: " .. actionName)
		return
	end

	characterOther.Humanoid:TakeDamage(damageAmount)
end

function CombatSystem._setRecentlyHitAttribute(characterOther, player)
	characterOther:SetAttribute("RecentlyHit", player.Name)
end

function CombatSystem._applyKnockback(actionName, character, characterOther)
	local knockbackType = ActionNameToKnockbackType[actionName]
	local humanoidRootPart: BasePart = character.HumanoidRootPart
	local humanoidRootPartOther: BasePart = characterOther.HumanoidRootPart

	local knockbackStrength = 0
	local knockbackDirection = Vector3.new(0, 0, 0)
	
	-- Determine knockback strength based on knockback type
	if knockbackType == KnockbackTypes.None then
		return
	elseif knockbackType == KnockbackTypes.Low then
		knockbackStrength = KNOCKBACK_STRENGTH_LOW
	elseif knockbackType == KnockbackTypes.Medium then
		knockbackStrength = KNOCKBACK_STRENGTH_MEDIUM
	elseif knockbackType == KnockbackTypes.High then
		knockbackStrength = KNOCKBACK_STRENGTH_HIGH
	end

	-- Calculate knockback direction based on the character's orientation
	knockbackDirection = humanoidRootPart.CFrame.LookVector

	-- Apply knockback using BodyVelocity
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = knockbackDirection * knockbackStrength + Vector3.new(0, 5, 0)
	bodyVelocity.Parent = humanoidRootPartOther

	-- Destroy BodyVelocity after a short delay
	Debris:AddItem(bodyVelocity, 0.1)
end

function CombatSystem._handleHitEffects(actionName, character, characterOther)
	CombatSystem._applyKnockback(actionName, character, characterOther)
end

function CombatSystem._validateAttack(player, actionName, characterToDamage, hitPosition)
	local character = player.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	local humanoid = characterToDamage:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	-- Validate distance between the character hit and the hit position
	local characterHitProximity = (characterToDamage.HumanoidRootPart.Position - hitPosition).Magnitude
	if characterHitProximity > MAX_HIT_PROXIMITY then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	-- PARALLEL: Perform the raycast in parallel
	task.desynchronize()
	
	-- Calculate the direction and distance for the ray
	local direction = (characterToDamage.HumanoidRootPart.Position - humanoidRootPart.Position).Unit
	local maxDistance = (characterToDamage.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude + MAX_HIT_PROXIMITY
	local rayDirection = direction * maxDistance

	local raycastResult = workspace:Raycast(humanoidRootPart.Position, rayDirection, raycastParams)

	if raycastResult then
		local hitPart = raycastResult.Instance

		if not hitPart:IsDescendantOf(characterToDamage) then
			return
		end

		local isBlocking = humanoid.Parent:GetAttribute("Blocking")
		if not isBlocking then
			-- SERIAL: The code below modifies state outside of the actor
			task.synchronize()

			-- Apply the hit effects and damage
			local damageAmount = ActionDamage[actionName]
			RemoteEvents.ShowCombatEffect:FireAllClients(player, actionName, damageAmount, characterToDamage)
			--Network.fireAllClients(Network.RemoteEvents.RequestCharacter, actionName, characterToDamage)

			CombatSystem._applyDamage(actionName, characterToDamage)
			CombatSystem._handleHitEffects(actionName, character, characterToDamage)
			CombatSystem._setRecentlyHitAttribute(characterToDamage, player)
		else
			-- Handle case where player is blocking
		end
	end
end

function CombatSystem._onDefensiveStanceEvent(player, isBlocking)
	-- Update the player's attributes based on the blocking status
	if player and player.Character then
		local character = player.Character
		if character then
			character:SetAttribute(Attribute.Blocking, isBlocking)
		end
	end
end

return CombatSystem
