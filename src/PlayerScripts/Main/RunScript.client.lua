local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyInputService = require(ReplicatedStorage.Utils.KeyInputService)

local LocalPlayer = Players.LocalPlayer
local PlayerCharacter = LocalPlayer.Character

LocalPlayer.CharacterAdded:Connect(function(character: Model)
	PlayerCharacter = character
end)

KeyInputService.ConnectToKeyCode(Enum.KeyCode.LeftShift, function(isBegin)
	if PlayerCharacter == nil then
		return
	end

	local humanoid = PlayerCharacter:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = isBegin and 22 or 16
	end
end)