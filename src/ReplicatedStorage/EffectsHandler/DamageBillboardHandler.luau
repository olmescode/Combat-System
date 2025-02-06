local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

if RunService:IsServer() then return {} end

local localPlayer = Players.LocalPlayer
while not localPlayer do
	Players.PlayerAdded:Wait()
	localPlayer = Players.LocalPlayer
end

local adorneeToBillboardGui = {}

local DamageBillboardHandler = {}

function DamageBillboardHandler:createBillboardForAdornee(adornee)
	local billboard = adorneeToBillboardGui[adornee]
	if billboard then
		return billboard
	end

	billboard = Instance.new("BillboardGui")
	billboard.Name = "DamageBillboardGui"
	billboard.Adornee = adornee
	billboard.AlwaysOnTop = true
	billboard.ExtentsOffsetWorldSpace = Vector3.new(0,18,0)
	billboard.Size = UDim2.new(0.42,20,15,0)
	billboard.ResetOnSpawn = false
	billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	billboard.Parent = localPlayer.PlayerGui
	adorneeToBillboardGui[adornee] = billboard

	local ancestorCon
	ancestorCon = adornee.AncestryChanged:connect(function(child, parent)
		if parent == nil then
			ancestorCon:disconnect()
			ancestorCon = nil

			local adorneeBillboard = adorneeToBillboardGui[adornee]
			adorneeBillboard:Destroy()
			adorneeToBillboardGui[adornee] = nil
		end
	end)

	return billboard
end

function DamageBillboardHandler:showDamageBillboard(adornee, damageAmount)
	if not adornee then return end
	damageAmount = math.ceil(damageAmount)

	local billboard = self:createBillboardForAdornee(adornee)

	local randomXPos = math.random(-10,10)/30
	
	local damageNumber = Instance.new("TextLabel")
	damageNumber.AnchorPoint = Vector2.new(0.5, 1)
	damageNumber.BackgroundTransparency = 1
	damageNumber.BorderSizePixel = 0
	damageNumber.Position = UDim2.fromScale(0.5 + randomXPos,1)
	damageNumber.Size = UDim2.fromScale(0,0.25)
	damageNumber.Font = Enum.Font.FredokaOne
	damageNumber.Text = tostring(damageAmount)
	damageNumber.TextColor3 = Color3.new(0, 1, 0.498039)
	damageNumber.TextScaled = true
	damageNumber.TextStrokeTransparency = 0
	damageNumber.TextTransparency = 0
	damageNumber.TextXAlignment = Enum.TextXAlignment.Center
	damageNumber.TextYAlignment = Enum.TextYAlignment.Bottom
	damageNumber.Parent = billboard

	local appearTweenInfo = TweenInfo.new(
		0.5, --time
		Enum.EasingStyle.Elastic,
		Enum.EasingDirection.Out,
		0, --repeatCount
		false, --reverses
		0) --delayTime
	local appearTween = TweenService:Create(
		damageNumber,
		appearTweenInfo, {
			Size = UDim2.fromScale(2, damageNumber.Size.Y.Scale),
			TextColor3 = Color3.new(0, 1, 0)
		}
	)

	local upTweenInfo = TweenInfo.new(
		0.5, --time
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0, --repeatCount
		false, --reverses
		0.2) --delayTime
	local upTween = TweenService:Create(
		damageNumber,
		upTweenInfo, {
			Position = UDim2.fromScale(damageNumber.Position.X.Scale, 0.8),
			TextTransparency = 1,
			TextStrokeTransparency = 4,
			Rotation = math.random(-10,10)
		}
	)

	local completedCon
	completedCon = upTween.Completed:connect(function()
		completedCon:disconnect()
		completedCon = nil
		damageNumber:Destroy()
	end)

	appearTween:Play()
	upTween:Play()
end

return DamageBillboardHandler
