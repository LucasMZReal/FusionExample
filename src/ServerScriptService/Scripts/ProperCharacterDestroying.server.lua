local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerJanitor = require(ReplicatedStorage.Utils.PlayerJanitor)
local Destroy = require(ReplicatedStorage.Utils.ReplicatedDestroy)

local function OnPlayerAdded(player: Player)
	local playerJanitor = PlayerJanitor.GetJanitorFrom(player)

	playerJanitor:Add(
		player.CharacterRemoving:Connect(Destroy), "Disconnect"
	)
end

for _, player in ipairs(Players:GetPlayers()) do
	task.defer(OnPlayerAdded, player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)