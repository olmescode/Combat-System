--[[
	
	CameraShaker.CameraShakeInstance
	
	cameraShaker = CameraShaker.new(renderPriority, callbackFunction)
	
	CameraShaker:Start()
	CameraShaker:Stop()
	CameraShaker:StopSustained([fadeOutTime])
	CameraShaker:Shake(shakeInstance)
	CameraShaker:ShakeSustain(shakeInstance)
	CameraShaker:ShakeOnce(magnitude, roughness [, fadeInTime, fadeOutTime, posInfluence, rotInfluence])
	CameraShaker:StartShake(magnitude, roughness [, fadeInTime, posInfluence, rotInfluence])
	
	
	
	EXAMPLE:
	
		local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
			camera.CFrame = playerCFrame * shakeCFrame
		end)
		
		camShake:Start()
		
		-- Explosion shake:
		camShake:Shake(CameraShaker.Presets.Explosion)
		
		wait(1)
		
		-- Custom shake:
		camShake:ShakeOnce(3, 1, 0.2, 1.5)

		-- Sustained shake:
		camShake:ShakeSustain(CameraShaker.Presets.Earthquake)

		-- Stop all sustained shakes:
		camShake:StopSustained(1) -- Argument is the fadeout time (defaults to the same as fadein time if not supplied)

		-- Stop only one sustained shake:
		shakeInstance = camShake:ShakeSustain(CameraShaker.Presets.Earthquake)
		wait(2)
		shakeInstance:StartFadeOut(1) -- Argument is the fadeout time
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer :: Player
local camera = workspace.CurrentCamera

local CameraShakeInstance = require(script.CameraShakeInstance)

local RENDER_NAME = "CameraShaker"

local CameraShaker = {}
CameraShaker.__index = CameraShaker
CameraShaker.cameraShakeInstance = CameraShakeInstance.CameraShakeState

function CameraShaker.new()
	local self = setmetatable({}, CameraShaker)
	
	self._running = false
	self._renderName = RENDER_NAME
	self._camShakeInstances = {}
	self._removeInstances = {}
	
	self:Start()
	
	return self
end

function CameraShaker:Start(shakeInstance)
	if self._running then return end

	RunService:BindToRenderStep(self._renderName, Enum.RenderPriority.Camera.Value, function(delta)
		self:_beforeCamera(delta)
	end)
	
	self._running = true
end

function CameraShaker:Stop()
	if not self._running then return end
	
	RunService:UnbindFromRenderStep(self._renderName)
	self._running = false
end

function CameraShaker:StopSustained(duration)
	for _, shakeInstance  in ipairs(self._camShakeInstances) do
		if shakeInstance.fadeOutDuration == 0 then
			shakeInstance:StartFadeOut(duration or shakeInstance.fadeInDuration)
		end
	end
end

function CameraShaker:_setCameraCFrame(shakeCFrame)
	camera.CFrame *= shakeCFrame
end

function CameraShaker:_beforeCamera(delta)
	local posAddShake = Vector3.new()
	local rotAddShake = Vector3.new()
	local camShakeInstances = self._camShakeInstances

	for i = 1, #camShakeInstances, 1 do
		local shakeInstance = camShakeInstances[i]
		if not shakeInstance then continue end
		local state = shakeInstance:GetState()

		if state == self.cameraShakeInstance.Inactive then
			--self._removeInstances[#self._removeInstances + 1] = i
			shakeInstance:destroy()
			camShakeInstances[i] = nil
		else
			local shake = shakeInstance:UpdateShake(delta)
			posAddShake = posAddShake + (shake * shakeInstance.PositionInfluence)
			rotAddShake = rotAddShake + (shake * shakeInstance.RotationInfluence)
		end
	end
	
	--[[
	-- Remove dead instances:
	for i = #self._removeInstances, 1, -1 do
		local instIndex = self._removeInstances[i]
		local shakeInstance = camShakeInstances[instIndex]
		
		shakeInstance:destroy()
		camShakeInstances[instIndex] = nil
		self._removeInstances[i] = nil
	end
	]]
	local shakeCFrame = CFrame.new(posAddShake) * CFrame.Angles(0, math.rad(rotAddShake.Y), 0) * CFrame.Angles(math.rad(rotAddShake.X), 0, math.rad(rotAddShake.Z))
	self:_setCameraCFrame(shakeCFrame)
end

function CameraShaker:Shake(shakeInstance)
	assert(typeof(shakeInstance) == "table" and shakeInstance._camShakeInstance, "ShakeInstance must be of type CameraShakeInstance")
	self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
	
	return shakeInstance
end

function CameraShaker:ShakeSustain(shakeInstance)
	assert(typeof(shakeInstance) == "table" and shakeInstance._camShakeInstance, "ShakeInstance must be of type CameraShakeInstance")
	self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
	shakeInstance:StartFadeIn(shakeInstance.fadeInDuration)
	
	return shakeInstance
end

function CameraShaker:ShakeOnce(magnitude, roughness, fadeInTime, fadeOutTime)
	assert(type(magnitude) == "number", "Magnitude must be a number")
	assert(type(roughness) == "number", "Roughness must be a number")
	assert(type(fadeInTime) == "number", "FadeInTime must be a number")
	assert(type(fadeOutTime) == "number", "FadeOutTime must be a number")
	
	local shakeInstance = CameraShakeInstance.new(magnitude, roughness, fadeInTime, fadeOutTime)
	
	self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
	
	return shakeInstance
end

function CameraShaker:StartShake(magnitude, roughness, fadeInTime)
	assert(type(magnitude) == "number", "Magnitude must be a number")
	assert(type(roughness) == "number", "Roughness must be a number")
	assert(type(fadeInTime) == "number", "FadeInTime must be a number")
	
	local shakeInstance = CameraShakeInstance.new(magnitude, roughness, fadeInTime)
	shakeInstance:StartFadeIn(fadeInTime)
	
	self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
	
	return shakeInstance
end

function CameraShaker:destroy()
	self:Stop()

	-- Destroy all shake instances
	for _, shakeInstance in ipairs(self._camShakeInstances) do
		shakeInstance:destroy()
	end

	self._running = false
	self._camShakeInstances = {}
	self._removeInstances = {}
end

return CameraShaker
