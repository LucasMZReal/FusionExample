local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local Signal = require(ReplicatedStorage.Utils.Signal)

local function WrapSignal(remoteChannel: RemoteChannel)
	local event = remoteChannel.Event
	local function handler(...)
		event:Fire(...)
	end

	if IsServer then
		remoteChannel._remote.OnServerEvent:Connect(handler)
	else
		remoteChannel._remote.OnClientEvent:Connect(handler)
	end
end

local RemoteFolder: Folder do
	if IsServer then
		RemoteFolder = Instance.new("Folder")
		RemoteFolder.Name = "Remotes"
		RemoteFolder.Parent = script
	else
		local thread = coroutine.running()
		local connection = nil
		connection = script.ChildAdded:Connect(function(child)
			if connection.Connected ~= true then
				return
			end

			if child.Name == "Remotes" then
				RemoteFolder = child

				connection:Disconnect()
				task.spawn(thread)
			end
		end)

		coroutine.yield()
	end
end

--[=[
	A class that handles remote requests between server and client.

	@class RemoteChannel
]=]

--[=[
	The event which is fired when the RemoteChannel is.

	@within RemoteChannel
	@prop Event ScriptSignal
]=]
local RemoteChannel = {}

local RemoteChannelLoaded = Signal.new()
local RemoteChannels: {
	[string]: RemoteChannel
} = {}

--[=[
	Creates a new RemoteChannel.

	@param channelName string
	@return RemoteChannel
]=]
function RemoteChannel.new(channelName: string): RemoteChannel
	assert(
		typeof(channelName) == 'string',
		"Channel Name must be string"
	)

	if RemoteChannels[channelName] then
		return RemoteChannels[channelName]
	end

	if IsServer then
		local remote = Instance.new("RemoteEvent")
		remote.Name = channelName
		remote.Parent = RemoteFolder

		local remoteChannel = setmetatable({
			Event = Signal.new(),
			_remote = remote
		}, RemoteChannel)

		WrapSignal(remoteChannel)

		RemoteChannels[channelName] = remoteChannel

		return remoteChannel
	else
		local thread = coroutine.running()
		local connection = nil
		connection = RemoteChannelLoaded:Connect(function(
			remoteChannelName: string,
			remoteChannel: RemoteChannel
		)
			if connection.Connected == false then
				return
			end

			if channelName == remoteChannelName then
				connection:Disconnect()
				task.spawn(thread, remoteChannel)
			end
		end)

		return coroutine.yield() :: RemoteChannel
	end
end

--[=[
	Fires the RemoteChannel to a specific player with the arguments passed.

	@param player Player -- The player you want to fire the RemoteChannel to
	@param ... any -- The arguments you want to fire this RemoteChannel with
	@error This function errors if called from the client
]=]
function RemoteChannel:FireClient(player: Player, ...: any)
	assert(
		IsServer,
		":FireClient can only be called by the server"
	)

	self._remote:FireClient(player, ...)
end

--[=[
	Fires the RemoteChannel to the server with the arguments passed.

	@param ... any -- The arguments you want to fire this RemoteChannel with
	@error This function errors if called from the server
]=]
function RemoteChannel:FireServer(...: any)
	assert(
		IsClient,
		":FireServer can only be called by the client"
	)

	self._remote:FireServer(...)
end

--[=[
	Disconnects all connections from `RemoteChannel.Event`.
]=]
function RemoteChannel:DisconnectAllConnections()
	self.Event:DisconnectAll()
end

if IsClient then
	RemoteFolder.ChildAdded:Connect(function(child)
		if not child:IsA("RemoteEvent") then
			warn("An instance that is not a RemoteEvent was added into RemoteChannel's internal remote folder")
			return
		end

		local remoteChannel = setmetatable({
			Event = Signal.new(),
			_remote = child :: RemoteEvent
		}, RemoteChannel)

		WrapSignal(remoteChannel)

		RemoteChannels[child.Name] = remoteChannel
		RemoteChannelLoaded:Fire(child.Name, remoteChannel)
	end)
end

export type RemoteChannel = typeof( setmetatable({
	Event = Signal.new(),
	_remote = Instance.new("RemoteEvent")
}, RemoteChannel) )

return RemoteChannel