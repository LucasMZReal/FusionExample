local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RemotesFolder = ReplicatedStorage.Remotes

local Remotes = {}

-- (yields) Gets a RemoteFunction
function Remotes.GetRemoteEvent(name: string): RemoteEvent
	return RemotesFolder.Events:WaitForChild(name)
end

-- (yields) Gets a RemoteFunction
function Remotes.GetRemoteFunction(name: string): RemoteFunction
	return RemotesFolder.Functions:WaitForChild(name)
end

if RunService:IsServer() then
	local RemoteList = {
		Events = {
			"BadgeDataUpdated",
			"PlayerSecondsPlayedLoaded",
			"PlayerDataLoaded",
		},
		Functions = {},
	}

	for _, name in ipairs(RemoteList.Events) do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = RemotesFolder.Events
	end

	for _, name in ipairs(RemoteList.Functions) do
		local remote = Instance.new("RemoteFunction")
		remote.Name = name
		remote.Parent = RemotesFolder.Functions
	end
end

return Remotes