--[[
	cameraShakeInstance = CameraShakeInstance.new(magnitude, roughness, fadeInTime, fadeOutTime)
--]]

local CameraShakeInstance = {}
CameraShakeInstance.__index = CameraShakeInstance

CameraShakeInstance.CameraShakeState = {
	FadingIn = 0;
	FadingOut = 1;
	Sustained = 2;
	Inactive = 3;
}

function CameraShakeInstance.new(magnitude, roughness, fadeInTime, fadeOutTime)	
	assert(type(magnitude) == "number", "Magnitude must be a number")
	assert(type(roughness) == "number", "Roughness must be a number")
	assert(type(fadeInTime) == "number", "FadeInTime must be a number")
	assert(type(fadeOutTime) == "number", "FadeOutTime must be a number")
	
	local self = setmetatable({}, CameraShakeInstance)
	
	self.Magnitude = magnitude
	self.Roughness = roughness
	self.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
	self.RotationInfluence = Vector3.new(1, 1, 1)
	self.DeleteOnInactive = true
	self.roughMod = 1
	self.magnMod = 1
	self.fadeOutDuration = fadeOutTime
	self.fadeInDuration = fadeInTime
	self.sustain = (fadeInTime > 0)
	self.currentFadeTime = (fadeInTime > 0 and 0 or 1)
	self.tick = Random.new():NextNumber(-100, 100)
	self._camShakeInstance = true
	
	return self
	
end

function CameraShakeInstance:UpdateShake(deltaTime)
	local _tick = self.tick
	local currentFadeTime = self.currentFadeTime

	local offset = Vector3.new(
		math.noise(_tick, 0) * 0.5,
		math.noise(0, _tick) * 0.5,
		math.noise(_tick, _tick) * 0.5
	)

	if self.fadeInDuration > 0 and self.sustain then
		if currentFadeTime < 1 then
			currentFadeTime = currentFadeTime + (deltaTime / self.fadeInDuration)
		elseif self.fadeOutDuration > 0 then
			self.sustain = false
		end
	end

	if not self.sustain then
		currentFadeTime = currentFadeTime - (deltaTime / self.fadeOutDuration)
	end

	if self.sustain then
		self.tick = _tick + (deltaTime * self.Roughness * self.roughMod)
	else
		self.tick = _tick + (deltaTime * self.Roughness * self.roughMod * currentFadeTime)
	end

	self.currentFadeTime = currentFadeTime

	return offset * self.Magnitude * self.magnMod * currentFadeTime
end

function CameraShakeInstance:StartFadeOut(fadeOutTime)
	if fadeOutTime == 0 then
		self.currentFadeTime = 0
	end
	self.fadeOutDuration = fadeOutTime
	self.fadeInDuration = 0
	self.sustain = false
end

function CameraShakeInstance:StartFadeIn(fadeInTime)
	if fadeInTime == 0 then
		self.currentFadeTime = 1
	end
	self.fadeInDuration = fadeInTime or self.fadeInDuration
	self.fadeOutDuration = 0
	self.sustain = true
end

function CameraShakeInstance:GetScaleRoughness()
	return self.roughMod
end

function CameraShakeInstance:SetScaleRoughness(scale)
	self.roughMod = scale
end

function CameraShakeInstance:GetScaleMagnitude()
	return self.magnMod
end

function CameraShakeInstance:SetScaleMagnitude(scale)
	self.magnMod = scale
end

function CameraShakeInstance:GetNormalizedFadeTime()
	return self.currentFadeTime
end

function CameraShakeInstance:IsShaking()
	return self.currentFadeTime > 0 or self.sustain
end

function CameraShakeInstance:IsFadingOut()
	return not self.sustain and self.currentFadeTime > 0
end

function CameraShakeInstance:IsFadingIn()
	return self.currentFadeTime < 1 and self.sustain and self.fadeInDuration > 0
end

function CameraShakeInstance:GetState()
	if self:IsFadingIn() then
		return CameraShakeInstance.CameraShakeState.FadingIn
	elseif self:IsFadingOut() then
		return CameraShakeInstance.CameraShakeState.FadingOut
	elseif self:IsShaking() then
		return CameraShakeInstance.CameraShakeState.Sustained
	else
		return CameraShakeInstance.CameraShakeState.Inactive
	end
end

function CameraShakeInstance:destroy()
	-- Set all properties to nil or default values
	self.Magnitude = nil
	self.Roughness = nil
	self.PositionInfluence = nil
	self.RotationInfluence = nil
	self.DeleteOnInactive = nil
	self.roughMod = nil
	self.magnMod = nil
	self.fadeOutDuration = nil
	self.fadeInDuration = nil
	self.sustain = nil
	self.currentFadeTime = nil
	self.tick = nil
	self._camShakeInstance = nil
end

return CameraShakeInstance
