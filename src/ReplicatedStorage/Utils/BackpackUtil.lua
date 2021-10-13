local StarterGui = game:GetService("StarterGui")
local BackpackUtil = {}

local IsBackpackHidden = false
local HiddenCounter = 0

local function ChangeBackpackVisibility(
	isHidden: boolean
)
	while true do
		local success = pcall(
			StarterGui.SetCoreGuiEnabled,
			StarterGui,

			Enum.CoreGuiType.Backpack,
			isHidden
		)

		if success then
			return
		end

		task.wait()

		if isHidden
			and HiddenCounter == 0
			or HiddenCounter > 0
		then
			return
		end
	end
end

function BackpackUtil:Hide()
	HiddenCounter += 1

	if IsBackpackHidden == false then
		IsBackpackHidden = true
		task.spawn(ChangeBackpackVisibility, true)
	end
end

function BackpackUtil:Show()
	if HiddenCounter == 0 then
		return
	end

	HiddenCounter -= 1

	if HiddenCounter == 0 and IsBackpackHidden then
		IsBackpackHidden = false
		task.spawn(ChangeBackpackVisibility, false)
	end
end

return BackpackUtil