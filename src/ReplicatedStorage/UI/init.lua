local UIs = {}

for _, UI in ipairs(script.UIs:GetChildren()) do
	UIs[UI.Name] = require(UI)
end

return UIs