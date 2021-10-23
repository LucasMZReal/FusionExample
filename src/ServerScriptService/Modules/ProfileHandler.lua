local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileService = require(ServerScriptService.Modules.ProfileService)
local Janitor = require(ReplicatedStorage.Utils.Janitor)
local Signal = require(ReplicatedStorage.Utils.Signal)
local RemoteService = require(ReplicatedStorage.Utils.RemoteService)

local PlayerDataLoaded = RemoteService.GetRemoteEvent("PlayerDataLoaded")

local ProfileStore = ProfileService.GetProfileStore("PlayerData", {
	SecondsPlayed = 0,
	Badges = {}
})

local Profiles = {}
local OnProfileLoaded = Signal.new()

--// Init

local function OnPlayerAdded(player)
	local profile = ProfileStore:LoadProfileAsync(
		"Player_".. player.UserId,

		function()
			return player.Parent == Players
				and "ForceLoad"
				or "Cancel"
		end
	)

	if profile then
		if player.Parent ~= Players then
			profile:Release()
			return
		end

		profile:Reconcile()

		profile:ListenToRelease(function()
			if Profiles[player] == nil then
				return
			end

			Profiles[player] = nil
			player:Kick("Profile loaded in remote server. Please re-join.")
		end)

		profile:AddUserId(player.UserId)

		Profiles[player] = profile
		OnProfileLoaded:Fire(player, profile)

		PlayerDataLoaded:FireClient(player)
	else
		player:Kick("Could not load your profile. Please join later.")

		OnProfileLoaded:Fire(player, nil)
	end
end

Players.PlayerAdded:Connect(OnPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	task.defer(OnPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
	local profile = Profiles[player]

	if profile then
		Profiles[player] = nil
		profile:Release()
	end
end)

--// Module code

local ProfileHandler = {}

function ProfileHandler.GetProfileStore()
	return ProfileStore
end

function ProfileHandler.FindFirstProfile(player)
	return Profiles[player]
end

function ProfileHandler.WaitForProfile(player)
	do
		local profile = Profiles[player]
		if profile then
			return profile
		end
	end

	local thread do
		thread = coroutine.running()
		local wasResumed = false

		local janitor = Janitor.new()

		janitor:Add(Players.PlayerRemoving:Connect(function(removedPlayer)
			if wasResumed then
				return
			end

			if removedPlayer == player then
				janitor:Cleanup()

				wasResumed = true
				task.spawn(thread, nil)
			end
		end))

		janitor:Add(OnProfileLoaded:Connect(function(_player, profile)
			if wasResumed then
				return
			end

			if _player == player then
				janitor:Cleanup()

				wasResumed = true
				task.spawn(thread, profile)
			end
		end))
	end

	return coroutine.yield()
end

return ProfileHandler