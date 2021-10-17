local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ProfileHandler = require(ServerScriptService.Modules.ProfileHandler)
local BadgeService3 = require(ReplicatedStorage.Modules.BadgeService3)
local Remotes = require(ReplicatedStorage.Utils.Remotes)

local BadgeDataUpdated = Remotes.GetRemoteEvent("BadgeDataUpdated")

local function OnPlayerAdded(player)
	local profile = ProfileHandler.WaitForProfile(player)

	if not profile then
		return
	end

	local badgeProfile = BadgeService3:LoadProfile(player, profile.Data.Badges)
	BadgeDataUpdated:FireClient(player, badgeProfile.Data)

	badgeProfile.OnUpdate:Connect(function(badgeData)
		BadgeDataUpdated:FireClient(player, badgeData)

		profile.Data.Badges = badgeData
	end)

	badgeProfile:AwardBadge("Welcome")
end

Players.PlayerAdded:Connect(OnPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	task.defer(OnPlayerAdded, player)
end