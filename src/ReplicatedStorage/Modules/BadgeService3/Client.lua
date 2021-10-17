local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local WaitForChild = require(ReplicatedStorage.Utils.BetterWaitForChild)
local BadgeService3 = script.Parent

local NotificationEvent: RemoteEvent
NotificationEvent = WaitForChild(BadgeService3, "Notification")

return NotificationEvent.OnClientEvent:Connect(function(notificationData)
	StarterGui:SetCore("SendNotification", notificationData)
end)