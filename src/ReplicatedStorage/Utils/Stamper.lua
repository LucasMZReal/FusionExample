--[[
	Stamper:

	Stamper is a hyper-efficient library made for handling functions
	that should run every x amount of seconds,
	Stamper handles it all in one connection / thread at a time,
	with custom scheduling.

]]

local RunService = game:GetService("RunService")

type CallbackFunction = (deltaTime: number) -> ()

local TimePassed: number = 0
local NextEvent = nil

local ScriptConnection = {}
ScriptConnection.Connected = true
ScriptConnection.__index = ScriptConnection

function ScriptConnection:Disconnect()
	if self.Connected == false then
		return
	end

	self.Connected = false

	local _node = self._node
	local _next = _node.Next
	local _prev = _node.Previous

	if _next then
		_next.Previous = _prev
	end

	if _prev then
		_prev.Next = _next
	else -- _node is 'NextEvent'
		NextEvent = _next
	end

	self._node = nil
end

export type ScriptConnection = typeof(
	setmetatable({}, ScriptConnection)
)

RunService.Heartbeat:Connect(function(frameDeltaTime: number)
	TimePassed += frameDeltaTime

	local node = NextEvent
	while node ~= nil do
		local deltaTime: number = TimePassed - node.TimeOfLastUpdate

		if deltaTime >= node.Seconds then
			node.TimeOfLastUpdate = TimePassed

			task.defer(
				node.Callback,
				deltaTime
			)
		end

		node = node.Next
	end
end)

return function(
	seconds: number,
	callback: CallbackFunction
): ScriptConnection

	assert(
		typeof(seconds) == 'number',
		"Seconds must be a number"
	)

	assert(
		typeof(callback) == 'function',
		"Handler must be a function"
	)

	local thisEvent = {
		TimeOfLastUpdate = TimePassed,
		Seconds = seconds,
		Callback = callback,

		Next = NextEvent,
		Previous = nil
	}

	if NextEvent then
		NextEvent.Previous = thisEvent
	end
	NextEvent = thisEvent

	return setmetatable({
		Connected = true,
		_node = thisEvent
	}, ScriptConnection)
end