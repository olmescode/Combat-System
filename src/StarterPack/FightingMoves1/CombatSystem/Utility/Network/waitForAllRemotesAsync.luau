--!strict

--[[
	Wait in parallel for all RemoteEvents and RemoteFunctions defined in RemoteNames to
	replicate into the remoteFolder.

	Used to ensure all remotes exist before the client Network module finishes initializing.
--]]

local CombatSystem = script:FindFirstAncestor("CombatSystem")

local Sift = require(CombatSystem.Dependencies.Sift)
local RemoteEventName = require(CombatSystem.Modules.Network.RemoteName.RemoteEventName)
local RemoteFunctionName = require(CombatSystem.Modules.Network.RemoteName.RemoteFunctionName)
local RemoteFolderName = require(CombatSystem.Modules.Network.RemoteFolderName)

local function waitForAllRemotesAsync(remoteFolder: Instance, timeoutSeconds: number)
	-- Using FindFirstChild to satisfy the type checker
	local remoteEventsFolder = remoteFolder:FindFirstChild(RemoteFolderName.RemoteEvents) :: Folder
	local remoteFunctionsFolder = remoteFolder:FindFirstChild(RemoteFolderName.RemoteFunctions) :: Folder

	-- We are casting these constants tables to any for type compatibility with Sift
	local remoteEvents: { string } = Sift.Dictionary.values(RemoteEventName :: any)
	local remoteFunctions: { string } = Sift.Dictionary.values(RemoteFunctionName :: any)

	-- Validate that the remotes defined under RemoteNames exist in remote folders
	local success = true
	local function search(names: { string }, folder: Folder)
		for _, remoteName in ipairs(names) do
			local remote = folder:WaitForChild(remoteName, timeoutSeconds)
			if not remote then
				success = false
				break
			end
		end
	end

	search(remoteEvents, remoteEventsFolder)
	search(remoteFunctions, remoteFunctionsFolder)

	assert(success, "Network could not find all remotes. Did the client Network module initialize before the server?")
end

return waitForAllRemotesAsync
