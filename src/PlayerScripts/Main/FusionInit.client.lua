local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TweenInfos = require(ReplicatedStorage.TweenInfos)
local QuickTween = require(ReplicatedStorage.Utils.QuickTween)
local BlurEffect = require(ReplicatedStorage.Misc.ScreenBlurEffect)

local Signal = require(ReplicatedStorage.Utils.Signal)

local Fusion = require(ReplicatedStorage.Utils.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local UIShared = require(ReplicatedStorage.UI.Shared)
local OnMenuClosed = Signal.new()

UIShared.OnMenuClosed = OnMenuClosed

local UIs = require(ReplicatedStorage.UI)

--\\ Handle Menu Tweening

OnMenuClosed:Connect(function(
	isClosingMenu: boolean,
	menu: Frame?
)
	if menu then
		QuickTween(menu, TweenInfos.UI, {
			Position = UDim2.new(
				isClosingMenu and 0 or 0.5,
				isClosingMenu and (-menu.Size.X.Offset - 1 / 2) or 0,

				0.5, 0
			)
		})
	end

	QuickTween(BlurEffect, TweenInfos.UI, {
		Size = isClosingMenu and 0 or 24
	})

	QuickTween(UIs.Buttons, TweenInfos.UI, {
		Position = UDim2.new(
			0, isClosingMenu and 10 or -100,
			0, 0
		)
	})
end)

--\\ Handle Buttons

local Buttons do
	local BUTTON_AMOUNT = 0

	Buttons = {
		{
			IsEnabled = true,
			Image = "rbxassetid://7072705696",
			Menu = "BadgesMenu",
		},
		{
			IsEnabled = true,
			Image = "rbxassetid://7072719671",
			Menu = "MusicMenu"
		}
	}

	local function TweenButtonUICorner(button, isHovering)
		QuickTween(button.UICorner, TweenInfos.UI, {
			CornerRadius = isHovering
				and UDim.new(0.25, 0)
				or UDim.new(1, 0)
		})
	end

	for _, buttonData in ipairs(Buttons) do
		if buttonData.IsEnabled then
			BUTTON_AMOUNT += 1
		end
	end

	local buttonInstances = {}

	local IsButtonCountPar = BUTTON_AMOUNT % 2 == 0
	local NextPos = IsButtonCountPar
		and -45 / 2
		or (BUTTON_AMOUNT == 1) and 0
		or -45

	for i, buttonData in ipairs(Buttons) do
		local Button = nil

		Button = New "TextButton" {
			Name = "Button_".. buttonData.Menu,

			Text = "",
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),

			AnchorPoint = Vector2.new(0, .5),
			Position = UDim2.new(0, 0, .5, NextPos),
			Size = UDim2.fromOffset(35, 35),

			[OnEvent "MouseEnter"] = function()
				TweenButtonUICorner(Button, true)
			end,

			[OnEvent "MouseLeave"] = function()
				TweenButtonUICorner(Button, false)
			end,

			[OnEvent "Activated"] = function()
				OnMenuClosed:Fire(false, UIs[buttonData.Menu])
			end,

			[Children] = {
				Image = New "ImageLabel" {
					Name = "Image",

					Image = buttonData.Image,
					BackgroundTransparency = 1,

					AnchorPoint = Vector2.new(.5, .5),
					Position = UDim2.fromScale(.5, .5),
					Size = UDim2.fromScale(.75, .75)
				},

				New "UIStroke" {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,

					Color = Color3.fromRGB(255, 255, 255),
					Thickness = 2,
					Transparency = 0
				},

				New "UICorner" {
					CornerRadius = UDim.new(1, 0)
				}
			}
		}

		buttonInstances[i] = Button

		NextPos += 45
	end

	UIs.Buttons = New "Frame" {
		Name = "Buttons",

		Position = UDim2.new(0, -100, 0, 0),
		Size = UDim2.new(0, 100, 1, 0),
		BackgroundTransparency = 1,

		[Children] = buttonInstances
	}
end

--\\ Mount

if not LocalPlayer.Character then
	LocalPlayer.CharacterAdded:Wait()
end

New "ScreenGui" {
	Name = "MainUI",
	ResetOnSpawn = false,

	Parent = LocalPlayer.PlayerGui,
	[Children] = UIs
}

if not LocalPlayer:GetAttribute("IsLoadingEnded") then
	local IsLoadingEnded_Changed = LocalPlayer:GetAttributeChangedSignal("IsLoadingEnded")

	local thread = coroutine.running()

	local connection
	connection = IsLoadingEnded_Changed:Connect(function()
		if not connection then
			return
		end

		if LocalPlayer:GetAttribute("IsLoadingEnded") then
			connection:Disconnect()
			connection = nil

			task.spawn(thread)
		end
	end)

	coroutine.yield()
end

OnMenuClosed:Fire(true)