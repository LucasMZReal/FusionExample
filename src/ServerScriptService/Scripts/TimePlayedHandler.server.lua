local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local PlayerJanitor = require(ReplicatedStorage.Utils.PlayerJanitor)
local BadgeService3 = require(ReplicatedStorage.Modules.BadgeService3)
local ProfileHandler = require(ServerScriptService.Modules.ProfileHandler)
local Stamper = require(ReplicatedStorage.Utils.Stamper)
local RemoteService = require(ReplicatedStorage.Utils.RemoteService)

local PlayerSecondsPlayedLoaded = RemoteService.GetRemoteEvent(
	"PlayerSecondsPlayedLoaded"
)

local PLAYER_PROFILES = {}

local AWARDS = {
	{
		SecondsNeeded = 60,
		BadgeId = "PlayedFor1Minute"
	},
	{
		SecondsNeeded = 60 * 5,
		BadgeId = "PlayedFor5Minutes"
	},
	{
		SecondsNeeded = 60 * 10,
		BadgeId = "PlayedFor10Minutes"
	},
}
local HIGHEST_AWARD_INDEX = #AWARDS

local function OnPlayerAdded(player: Player)
	local profile = ProfileHandler.WaitForProfile(player)
	local badgeProfile = BadgeService3:WaitForProfile(player)
	local playerJanitor = PlayerJanitor.GetJanitorFrom(player)

	if not profile then
		return
	end

	profile:ListenToRelease(function()
		PLAYER_PROFILES[player] = nil
	end)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = 'leaderstats'
	leaderstats.Parent = player

	local playerData = {
		profile.Data,
		badgeProfile,
		profile.Data.SecondsPlayed,
		nil,
		os.time()
	}

	for player2, data in pairs(PLAYER_PROFILES) do
		PlayerSecondsPlayedLoaded:FireClient(
			player,

			player2,
			{
				SecondsPlayed = data[3],
				JoinedTime = data[5]
			}
		)
	end
	PLAYER_PROFILES[player] = playerData

	playerJanitor:Add(function()
		PLAYER_PROFILES[player] = nil
	end)

	PlayerSecondsPlayedLoaded:FireAllClients(
		player,
		{
			SecondsPlayed = playerData[3],
			JoinedTime = playerData[5]
		}
	)
end

Players.PlayerAdded:Connect(OnPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	task.defer(OnPlayerAdded, player)
end

Stamper(1, function(deltaTime)
	for _, data in pairs(PLAYER_PROFILES) do
		local profileData = data[1]
		local highestAwardGiven = data[4]

		profileData.SecondsPlayed += deltaTime

		if highestAwardGiven == HIGHEST_AWARD_INDEX then
			continue
		end

		local badgeProfile = data[2]

		local awardIndex, award = next(AWARDS, highestAwardGiven)

		if profileData.SecondsPlayed >= award.SecondsNeeded then
			data[4] = awardIndex

			badgeProfile:AwardBadge(
				award.BadgeId
			)
		end
	end
end)