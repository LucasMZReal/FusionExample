local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScriptSignal = require(ReplicatedStorage.Utils.Signal)

local TimerEvent = {}
local Timers = {}

local function DestroyEvent(self)
	if self:IsActive() == false then
		return
	end

	ScriptSignal.Destroy(self)

	self._connection:Disconnect()
	self._connection = nil

	Timers[self] = nil
end

function TimerEvent.GetTimer(
	time: number
): ScriptSignal.Class

	assert(
		typeof(time) == 'number',
		"Must be number"
	)

	local event do
		event = Timers[time]
		if event then
			return event
		end
	end

	event = ScriptSignal.new()
	event.Destroy = DestroyEvent

	local timePassed = 0
	event._connection = RunService.Heartbeat:Connect(function(deltaTime)
		timePassed += deltaTime

		if timePassed < time then
			return
		end

		event:Fire(timePassed)
		timePassed = 0
	end)

	Timers[time] = event

	return event
end

return TimerEvent