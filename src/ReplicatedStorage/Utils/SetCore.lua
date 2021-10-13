local StarterGui = game:GetService("StarterGui")
local SetCore = {}

function SetCore:ChatActive(active: boolean)
	StarterGui:SetCore("ChatActive", active)
end

function SetCore:BadgesNotificationsActive(active: boolean)
	StarterGui:SetCore("BadgesNotificationsActive", active)
end

function SetCore:ResetButtonCallback(
	active: boolean,
	bindableEvent: BindableEvent?
)
	StarterGui:SetCore(
		"ResetButtonCallback",
		active, bindableEvent
	)
end

function SetCore:ChatMakeSystemMessage(
	configTable: {
		Text: string,
		TextSize: number?,
		Font: Enum.Font?,
		Color: Color3?
	}
)
	StarterGui:SetCore("ChatMakeSystemMessage", configTable)
end

function SetCore:ChatWindowSize(windowSize: UDim2)
	StarterGui:SetAttribute("ChatWindowSize", windowSize)
end

function SetCore:ChatWindowPosition(windowPosition: UDim2)
	StarterGui:SetAttribute("ChatWindowPosition", windowPosition)
end

function SetCore:ChatBarDisabled(disabled: boolean)
	StarterGui:SetCore("ChatBarDisabled", disabled)
end

function SetCore:SendNotification(
	configTable: {
		Title: string,
		Text: string,
		Icon: string?,
		Duration: number?,

		Callback: BindableFunction?,
		Button1: string?,
		Button2: string?
	}
)
	StarterGui:SetCore("SendNotification", configTable)
end

function SetCore:TopbarEnabled(enabled: boolean)
	StarterGui:SetCore("TopbarEnabled", enabled)
end

function SetCore:DevConsoleVisible(visibility: boolean)
	StarterGui:SetCore("DevConsoleVisible", visibility)
end

function SetCore:PromptSendFriendRequest(player: Player)
	StarterGui:SetCore("PromptSendFriendRequest", player)
end

function SetCore:PromptUnfriend(player: Player)
	StarterGui:SetCore("PromptUnfriend", player)
end

function SetCore:PromptBlockPlayer(player: Player)
	StarterGui:SetCore("PromptBlockPlayer", player)
end

function SetCore:PromptUnblockPlayer(player: Player)
	StarterGui:SetCore("PromptUnblockPlayer", player)
end

function SetCore:AvatarContextMenuEnabled(enabled: boolean)
	StarterGui:SetCore("AvatarContextMenuEnabled", enabled)
end

function SetCore:AvatarContextMenuTarget(player: Player)
	StarterGui:SetCore("AvatarContextMenuTarget", player)
end

type AvatarContextMenuOption =
	Enum.AvatarContextMenuOption |
	{[number]: string | BindableEvent}

-- Option can be an Enum.AvatarContextMenuOption or a two element table,
-- on which the first element is the name of the custom action,
-- and the second being a BindableEvent which will be fired with a player
-- was selected when the option was activated.
function SetCore:AddAvatarContextMenuOption(
	option: AvatarContextMenuOption
)
	StarterGui:SetCore("AddAvatarContextMenuOption", option)
end

-- Removes an option to the Avatar Context Menu.
-- The option argument must be the same as what was used
-- with :AddAvatarContextMenuOption
function SetCore:RemoveAvatarContextMenuOption(
	option: AvatarContextMenuOption
)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", option)
end

-- ...
function SetCore:AvatarContextMenuTheme(...)
	StarterGui:SetCore("AvatarContextMenuTheme", ...)
end

function SetCore:CoreGuiChatConnections(
	parameterName: string,
	value: {[number]: BindableEvent | BindableFunction}
)
	StarterGui:SetCore("CoreGuiChatConnections", parameterName, value)
end

return SetCore