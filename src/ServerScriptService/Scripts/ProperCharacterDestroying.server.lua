local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Destroy = require(ReplicatedStorage.Utils.ReplicatedDestroy)

local function OnPlayerAdded(player: Player)
	player.CharacterRemoving:Connect(Destroy)
end

for _, player in ipairs(Players:GetPlayers()) do
	task.defer(OnPlayerAdded, player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)