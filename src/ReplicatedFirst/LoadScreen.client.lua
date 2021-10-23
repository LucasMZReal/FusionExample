local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if game:IsLoaded() == false then
	game.Loaded:Wait()
end

local QuickTween = require(ReplicatedStorage.Utils.QuickTween)
local Stamper = require(ReplicatedStorage.Utils.Stamper)
local RemoteService = require(ReplicatedStorage.Utils.RemoteService)
local TweenInfos = require(ReplicatedStorage.TweenInfos)
local PlayerDataLoaded = RemoteService.GetRemoteEvent("PlayerDataLoaded")

local Fusion = require(ReplicatedStorage.Utils.Fusion)
local New = Fusion.New
local Children = Fusion.Children

local Loading: Frame
Loading = New "Frame" {
	Name = "Main",

	BackgroundColor3 = Color3.fromRGB(),
	BackgroundTransparency = .15,

	AnchorPoint = Vector2.new(.5, 0),
	Position = UDim2.fromScale(.5, 0),
	Size = UDim2.fromScale(1, 1),

	[Children] = {
		New "TextLabel" {
			Name = "LoadingText",

			BackgroundTransparency = 1,

			Text = "Loading.",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 24,

			Font = Enum.Font.GothamBold,

			AnchorPoint = Vector2.new(.5, .5),
			Position = UDim2.fromScale(.5, .5),
			Size = UDim2.fromOffset(75, 25),
		}
	}
}

local Dots = table.create(3)

local UpdateLoadingTextConnection = nil
UpdateLoadingTextConnection = Stamper(.25, function()
	if Loading == nil then
		return
	end

	if #Dots >= 3 then
		table.clear(Dots)
	end

	table.insert(Dots, ".")

	Loading.LoadingText.Text = "Loading" .. table.concat(Dots)
end)

New "ScreenGui" {
	Name = "LoadingScreen",

	Parent = LocalPlayer.PlayerGui,

	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Global,

	[Children] = Loading
}

ReplicatedFirst:RemoveDefaultLoadingScreen()


local connection do
	connection = PlayerDataLoaded.OnClientEvent:Connect(function()
		if connection == nil then
			return
		end

		connection:Disconnect()
		connection = nil

		LocalPlayer:SetAttribute("IsLoadingEnded", true)

		local tween =
			QuickTween(Loading, TweenInfos.UI, {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(.5, 1)
			})

		tween.Completed:Wait()

		UpdateLoadingTextConnection:Disconnect()
		UpdateLoadingTextConnection = nil

		Loading.Parent:Destroy()
		Loading = nil
	end)
end