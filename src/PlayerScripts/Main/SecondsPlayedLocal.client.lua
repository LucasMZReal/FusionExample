local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WaitForChild = require(ReplicatedStorage.Utils.BetterWaitForChild)
local Stamper = require(ReplicatedStorage.Utils.Stamper)
local RemoteService = require(ReplicatedStorage.Utils.RemoteService)

local PlayerSecondsPlayedLoaded = RemoteService.GetRemoteEvent(
	"PlayerSecondsPlayedLoaded"
)

local PlayerList = {}

PlayerSecondsPlayedLoaded.OnClientEvent:Connect(
	function(player, timePlayedInfo)
		local leaderstats: Folder = WaitForChild(player, "leaderstats")

		if player.Parent ~= Players then
			return
		end

		local SecondsPlayed = Instance.new("NumberValue")
		SecondsPlayed.Name = "SecondsPlayed"
		SecondsPlayed.Value = timePlayedInfo.SecondsPlayed
			+ (os.time() - timePlayedInfo.JoinedTime)

		SecondsPlayed.Parent = leaderstats

		PlayerList[player] = SecondsPlayed
	end
)

Players.PlayerRemoving:Connect(function(player)
	PlayerList[player] = nil
end)

Stamper(0.1, function(deltaTime)
	for _, secondsPlayed in pairs(PlayerList) do
		secondsPlayed.Value += deltaTime
	end
end)