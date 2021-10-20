local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Utils.Janitor)

local Yielder do
	Yielder = {}
	Yielder.__index = Yielder

	function Yielder.new(): Yielder
		return setmetatable({
			_thread = nil
		}, Yielder)
	end

	function Yielder:IsYielding(): boolean
		return self._thread ~= nil
	end

	function Yielder:Yield(): (...any)
		if self._thread ~= nil then
			error("Cannot yield two threads at once", 2)
		end

		self._thread = coroutine.running()

		return coroutine.yield()
	end

	function Yielder:Resume(...)
		local thread = self._thread

		if thread == nil then
			error("No thread to resume", 2)
		end

		self._thread = nil

		task.spawn(thread, ...)
	end

	type Yielder = typeof(
		setmetatable({}, Yielder)
	)
end

return function(
	parent: Instance,
	childName: string
): Instance

	assert(
		typeof(parent) == 'Instance',
		"Must be Instance"
	)

	assert(
		typeof(childName) == 'string',
		"Must be string"
	)

	do
		local child = parent:FindFirstChild(childName)
		if child then
			return child
		end
	end

	local yielder = Yielder.new()
	local masterJanitor = Janitor.new()

	local function addListeners(child: Instance)
		local instanceJanitor = Janitor.new()
		masterJanitor:Add(instanceJanitor, "Destroy", child)

		local nameChangedConnection: RBXScriptConnection
		nameChangedConnection = instanceJanitor:Add(
			child:GetPropertyChangedSignal("Name"):Connect(function()
				if nameChangedConnection.Connected == false then
					return
				end

				if not yielder:IsYielding() then
					return
				end

				if child.Name == childName then
					masterJanitor:Destroy()
					yielder:Resume(child)
				end
			end), "Disconnect"
		)

		instanceJanitor:Add(
			child.AncestryChanged:Connect(function(_, _parent)
				if not yielder:IsYielding() then
					return
				end

				if _parent ~= parent then
					masterJanitor:Remove(child)
				end
			end), "Disconnect"
		)
	end

	for _, child in ipairs(parent:GetChildren()) do
		addListeners(child)
	end

	masterJanitor:Add(
		parent.ChildAdded:Connect(function(child: Instance)
			if not yielder:IsYielding() then
				return
			end

			if child.Name == childName then
				masterJanitor:Destroy()
				yielder:Resume(child)
			else
				addListeners(child)
			end
		end), "Disconnect"
	)

	return yielder:Yield()
end