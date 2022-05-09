local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Utils.Janitor)

local ActiveJanitors: {[Player]: Janitor.Class} = {}

local PlayerJanitor = {}

function PlayerJanitor.GetJanitorFrom(player: Player): Janitor.Class
	assert(
		typeof(player) == 'Instance' and player:IsA("Player") and player.Parent == Players,
		"Must be player and online"
	)

	local activeJanitor = ActiveJanitors[player]
	if activeJanitor ~= nil then
		return activeJanitor
	end

	local janitor = Janitor.new()
	ActiveJanitors[player] = janitor

	return janitor
end

Players.PlayerRemoving:Connect(function(player)
	local activeJanitor = ActiveJanitors[player]
	if activeJanitor ~= nil then
		activeJanitor:Destroy()
		ActiveJanitors[player] = nil
	end
end)

return PlayerJanitor