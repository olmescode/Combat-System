local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage:WaitForChild("Network"))
local EffectsHandler = require(ReplicatedStorage:WaitForChild("EffectsHandler"))

-- Handles all combat effects and their application in the combat system
Network.startClientAsync()
EffectsHandler.start()
