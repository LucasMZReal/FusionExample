local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Utils.Fusion)
local New = Fusion.New
local Children = Fusion.Children

return function(properties, imageSize)
	properties = properties or {}
	local children = properties[Children] or {}

	table.insert(children,
		New "ImageLabel" {
			Name = "ImageOverlay",

			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),

			Size = imageSize,

			BackgroundTransparency = 1,
			Image = properties.Image or "",
			ImageColor3 = properties.ImageColor3,
		}
	)
	properties.Image = nil
	properties.ImageColor3 = nil

	return New("ImageButton")(properties)
end