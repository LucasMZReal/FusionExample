local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AllBadges = require(ReplicatedStorage.Modules.BadgeService3.Badges)
local OwnedBadges = {}

local Remotes = require(ReplicatedStorage.Utils.Remotes)
local BadgeDataUpdated = Remotes.GetRemoteEvent("BadgeDataUpdated")

local UIShared = require(ReplicatedStorage.UI.Shared)
local OnMenuClosed = UIShared.OnMenuClosed

local Fusion: Fusion = require(ReplicatedStorage.Utils.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Computed = Fusion.Computed
local State = Fusion.State

local List = New "ScrollingFrame" {
	Name = "List",

	BackgroundTransparency = 1,

	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.new(),
	ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
	ScrollBarThickness = 0,

	AnchorPoint = Vector2.new(.5, 1),
	Position = UDim2.fromScale(.5, 1),
	Size = UDim2.fromScale(1, .8),

	[Children] = {
		New "UIListLayout" {
			Padding = UDim.new(0, 5),
			VerticalAlignment = Enum.VerticalAlignment.Center
		}
	}
}

local Menu
Menu = New "Frame" {
	Name = "BadgesMenu",

	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = .25,

	AnchorPoint = Vector2.new(.5, .5),
	Position = UDim2.new(0, -150 - 1, .5, 0),

	Size = UDim2.fromOffset(300, 200),

	[Children] = {
		List,

		New "TextLabel" {
			Name = "Title",

			Text = "Badges",
			TextSize = 24,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBlack,

			BackgroundTransparency = 1,

			AnchorPoint = Vector2.new(.5, 0),
			Position = UDim2.fromScale(.5, 0),
			Size = UDim2.new(1, 0, 0, 45)
		},

		New "TextButton" {
			Name = "ExitButton",

			Font = Enum.Font.GothamBold,
			Text = "X",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 20,

			BackgroundColor3 = Color3.fromRGB(255, 0, 0),

			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromOffset(25, 25),

			[OnEvent "Activated"] = function()
				OnMenuClosed:Fire(true, Menu)
			end,

			[Children] = {
				New "UIStroke" {
					Color = Color3.fromRGB(255, 255, 255),
					Transparency = 0,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				},

				New "UICorner" {
					CornerRadius = UDim.new(0, 12)
				}
			}
		},

		New "UIStroke" {
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = .5
		},

		New "UICorner" {
			CornerRadius = UDim.new(0, 12)
		}
	}
}

local function CreateBadgeComponent(badgeId, props)
	return New "Frame" {
		Name = "Badge",

		BackgroundColor3 = Color3.fromRGB(),
		BackgroundTransparency = .25,

		Size = UDim2.new(1, 0, 0, 75),

		Parent = List,
		[Children] = {
			New "ImageLabel" {
				Name = "BadgeImage",

				BackgroundTransparency = 1,

				AnchorPoint = Vector2.new(0, .5),
				Position = UDim2.new(0, 10, .5, 0),
				Size = UDim2.fromOffset(50, 50),

				Image = props.Image or "rbxassetid://6170641771",
			},

			New "TextLabel" {
				Name = "BadgeName",

				BackgroundTransparency = 1,

				Text = props.Name,
				TextSize = 16,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Center,
				Font = Enum.Font.GothamBlack,

				AnchorPoint = Vector2.new(.5, .5),
				Position = UDim2.new(.5, 10, .5, 0),
				Size = UDim2.fromOffset(50, 25)
			},

			New "ImageLabel" {
				Name = "OwnedImage",

				BackgroundTransparency = 1,

				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromOffset(25, 25),

				Image = Computed(function()
					return OwnedBadges[badgeId]:get()
						and "rbxassetid://7301082956"
						or "rbxassetid://7301082587"
				end)
			},

			New "UICorner" {
				CornerRadius = UDim.new(0, 16)
			}
		}
	}
end

BadgeDataUpdated.OnClientEvent:Connect(function(badgeData)
	for _, badgeId in ipairs(badgeData) do
		OwnedBadges[badgeId]:set(true)
	end
end)

for badgeId, badgeData in pairs(AllBadges) do
	OwnedBadges[badgeId] = State(false)

	CreateBadgeComponent(badgeId, badgeData)
end

return Menu