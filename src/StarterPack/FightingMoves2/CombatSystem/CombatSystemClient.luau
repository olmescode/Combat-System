--!strict

--[[
	This ClientScript handles player inputs and triggers corresponding actions in 
	various combat ability classes.
	
	It sets up a tool with equipped and unequipped events to bind and unbind actions. 
--]]

print("Required CombatSystemClient")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CombatSystemFolder = script.Parent
local Modules = CombatSystemFolder:WaitForChild("Modules")
local CombatActions = CombatSystemFolder:WaitForChild("CombatActions")
local Assets = CombatSystemFolder:WaitForChild("Assets")

local Network = require(Modules:WaitForChild("Network"))
local ActionManager = require(Modules:WaitForChild("ActionManager"))
local ActionNames = require(CombatSystemFolder:WaitForChild("ActionNames"))
local ActionNameByKeyCodeBindingInfo = require(CombatSystemFolder:WaitForChild("ActionNameByKeyCodeBindingInfo"))

local player = Players.LocalPlayer :: Player

local CombatSystemClient = {}
CombatSystemClient._currentTool = nil
CombatSystemClient._connections = {}
CombatSystemClient._combatActions = {}
CombatSystemClient._currentAttack = nil
CombatSystemClient._oldIdleAnimationId = nil

-- Function to call the appropriate action function when input is began
function CombatSystemClient._actionHandler(action: string, inputState: Enum.UserInputState)
	local currentCombatAction = CombatSystemClient._combatActions[action]
	
	if inputState == Enum.UserInputState.Begin then
		-- Perform action when input begins
		if currentCombatAction then
			currentCombatAction:startAction()
		end
	elseif inputState == Enum.UserInputState.End then
		-- Perform action when input ends
		currentCombatAction:endAction()
	end
end

function CombatSystemClient.setup(tool: Tool)
	assert(tool, "Tool must be provided for setup.")
	local tool = tool :: Tool

	local function onNewCombatAction(combatActionModule)
		if not combatActionModule:IsA("ModuleScript") then
			return
		end
		local combatActionName = combatActionModule.Name
		xpcall(function()
			coroutine.wrap(function()
				local combatAction = require(combatActionModule)

				-- Create an instance of the combat action class
				local instance = combatAction.new(tool)
				CombatSystemClient._combatActions[combatActionName] = instance
				
				CombatSystemClient._registerAction(combatActionName, instance)
			end)()
		end, function(errMsg)
			warn(string.format("Error while loading %s: %s", combatActionModule:GetFullName(), errMsg))
			warn(debug.traceback())
		end)
	end
	
	Network.startClientAsync()
	CombatSystemClient._setupTool(tool)
	
	for _, child in pairs(CombatActions:GetChildren()) do
		onNewCombatAction(child)
	end

	CombatActions.ChildAdded:Connect(onNewCombatAction)
end

function CombatSystemClient._registerAction(actionName, actionClassInstance)
	local actionChanged = ActionManager.registerAction(actionName, actionClassInstance)

	actionChanged:Connect(function(actionId)
		--print(actionId)
	end)
end

function CombatSystemClient._setupTool(tool: Tool)
	-- Setup weapon tools and listening for input
	tool.Equipped:Connect(CombatSystemClient._onToolEquipped)
	tool.Unequipped:Connect(CombatSystemClient._onToolUnequipped)
	
	CombatSystemClient._currentTool = tool
end

function CombatSystemClient._onToolEquipped()
	-- Load and play idle animation when the tool is equipped
	local character = player.Character :: Model
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	
	if character then
		local animateScript = character:WaitForChild("Animate") :: any
		if animateScript then
			-- Store the old idle animation ID
			CombatSystemClient._oldIdleAnimationId = animateScript.idle.Animation1.AnimationId
			
			local animationId = Assets.Animations.Idle.AnimationId
			animateScript.idle.Animation1.AnimationId = animationId
			animateScript.idle.Animation2.AnimationId = animationId
			
			-- Change the state of the humanoid to Idle
			humanoid:ChangeState(Enum.HumanoidStateType.Landed)
		end
	end
	
	-- Bind your tool's actions when equipped
	for actionName, _ in pairs(ActionNames) do
		local bindingInfo = ActionNameByKeyCodeBindingInfo[actionName]
		ActionManager.bindAction(
			actionName, 
			CombatSystemClient._actionHandler, 
			bindingInfo.keyCodes.Keyboard, 
			bindingInfo.keyCodes.Gamepad, 
			bindingInfo.displayOrder,
			bindingInfo.cooldown
		)
	end
	
	ActionManager.toggleMasteryFrame(true)
end

function CombatSystemClient._onToolUnequipped()
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Stop all playing animation tracks
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			track:Stop()
		end
	end

	-- Reset idle animations
	local animateScript = character:FindFirstChild("Animate")
	if animateScript then
		animateScript.idle.Animation1.AnimationId = CombatSystemClient._oldIdleAnimationId
		animateScript.idle.Animation2.AnimationId = CombatSystemClient._oldIdleAnimationId
	end
	
	-- Change humanoid state to Landed if not moving
	if humanoid.MoveDirection.Magnitude == 0 then
		humanoid:ChangeState(Enum.HumanoidStateType.Landed)
	end
	
	-- Unbind tool's actions
	for actionName, _ in pairs(ActionNames) do
		ActionManager.unbindAction(actionName)
	end
	
	ActionManager.toggleMasteryFrame(false)
end

return CombatSystemClient
