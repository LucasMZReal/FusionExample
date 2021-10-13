local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Fusion: Fusion = require(ReplicatedStorage.Utils.Fusion)
local Components = require(ReplicatedStorage.UI.Components)
local UIShared = require(ReplicatedStorage.UI.Shared)

local New = Fusion.New
local Children = Fusion.Children
local State = Fusion.State
local OnEvent = Fusion.OnEvent

local Sound: Sound do
	Sound = Instance.new("Sound")
	Sound.Name = "Music"
	Sound.Looped = true
	Sound.Parent = SoundService
end

local Menu: Frame
Menu = New("Frame") {
	Name = "MusicMenu",

	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.25,

	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0, -(190 / 2) - 1, 0.5, 0),
	Size = UDim2.fromOffset(190, 75),

	[Children] = {
		Title = New("TextLabel") {
			Text = "Radio",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			Font = Enum.Font.GothamBlack,

			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 35)
		},

		ExitButton = New "TextButton" {
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
				UIShared.OnMenuClosed:Fire(true, Menu)
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

		BottomCenterPivot = New("Frame") {
			Name = "BottomCenterPivot",

			BackgroundTransparency = 1,

			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -5),
			Size = UDim2.fromOffset(180, 25),

			[Children] = {
				InputBar = New("TextBox") {
					Name = "InputBar",

					Font = Enum.Font.GothamBlack,
					PlaceholderText = "Sound ID",
					PlaceholderColor3 = Color3.fromRGB(255, 255, 255),
					Text = "",
					TextColor3 = Color3.fromRGB(255, 255, 255),

					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromOffset(150, 25),

					[Children] = {
						New("UIStroke") {
							Color = Color3.fromRGB(127, 127, 127),

							Transparency = 0.5,
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						},

						New("UIStroke") {
							Thickness = 1,
						},

						New("UICorner") {
							CornerRadius = UDim.new(1, 0)
						}
					}
				},

				PlayButton = Components.ResizableImageButton({
					Name = "PlayButton",

					Image = "rbxassetid://7072720676",
					ImageColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundColor3 = Color3.fromRGB(0, 255, 0),

					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.fromScale(1, 0.5),
					Size = UDim2.fromOffset(25, 25),

					[OnEvent "Activated"] = function()
						local soundId = tonumber(
							Menu.BottomCenterPivot.InputBar.Text
						)

						if soundId then
							Sound.SoundId = "rbxassetid://".. soundId

							if Sound.IsLoaded == false then
								Sound.Loaded:Wait()
							end

							Sound:Play()
						end
					end,

					[Children] = {
						New "UICorner" {
							CornerRadius = UDim.new(1)
						}
					}
				}, UDim2.new(1, 5, 1, 5))
			}
		},

		New("UICorner") {
			CornerRadius = UDim.new(0, 12)
		},

		New("UIStroke") {
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 0.5,
			Thickness = 1,
		}
	}
}

return Menu