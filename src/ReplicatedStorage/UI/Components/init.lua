local Components = {}

for _, Component in ipairs(script:GetChildren()) do
	Components[Component.Name] = require(Component)
end

return Components