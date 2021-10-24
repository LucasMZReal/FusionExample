local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Utils.Signal)

local KeyEvents = {}
local KeyInputService = {}

local function GetKeyEvent(keyCode: Enum.KeyCode)
	do
		local keyEvent = KeyEvents[keyCode]
		if keyEvent then
			return keyEvent
		end
	end

	local keyEvent = Signal.new()
	KeyEvents[keyCode] = keyEvent

	return keyEvent
end

function KeyInputService.ConnectToKeyCode(
	keyCode: Enum.KeyCode,
	handler: (isInputBegan: boolean) -> ()
)
	local keyEvent = GetKeyEvent(keyCode)

	return keyEvent:Connect(handler)
end

local function FireKeyEvent(isBegin, input: InputObject)
	local keyEvent = KeyEvents[input.KeyCode]

	if not keyEvent then
		return
	end

	keyEvent:Fire(isBegin)
end

UserInputService.InputBegan:Connect(function(
	input: InputObject,
	gameProcessedEvent: boolean
)
	if gameProcessedEvent then
		return
	end

	FireKeyEvent(true, input)
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end

	FireKeyEvent(false, input)
end)

return KeyInputService