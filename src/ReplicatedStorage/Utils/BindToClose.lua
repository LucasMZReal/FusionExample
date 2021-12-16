--[[
	A custom BindToCloseSignal implementation which fixes these issues:

		* Has a :Disconnect method
		* Listeners run in a different order:

			Which is: First connected -> Last connected

			This order fixes a lot of hidden issues, particularly with requiring.
]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScriptSignal = require(ReplicatedStorage.Utils.Signal.Immediate)
-- Must be an immediate mode signal! I am using FastSignal Immediate, you can use GoodSignal.

local BindToCloseSignal = ScriptSignal.new()
local HandlerClosed = ScriptSignal.new()
local ActiveHandlers = 0

game:BindToClose(function()
	BindToCloseSignal:Fire()

	while ActiveHandlers > 0 do
		HandlerClosed:Wait()
	end
end)

local function BindToClose(
	handler: () -> ()
): ScriptSignal.ScriptConnection

	return BindToCloseSignal:Connect(function()
		ActiveHandlers += 1

		local connection
		local thread
		local hasThreadDied = false
		task.spawn(function()
			thread = coroutine.running()

			handler()

			hasThreadDied = true
			ActiveHandlers -= 1
			HandlerClosed:Fire()
		end)

		connection = RunService.Heartbeat:Connect(function()
			if hasThreadDied then
				connection:Disconnect()
				return
			end

			if coroutine.status(thread) == 'dead' and hasThreadDied == false then
				-- This is used to detect when a thread errors

				connection:Disconnect()

				ActiveHandlers -= 1
				HandlerClosed:Fire()

				return
			end
		end)
	end)
end

return BindToClose