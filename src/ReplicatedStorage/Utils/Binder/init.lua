local BindCounter = 0
-- Used for keeping bindings that are the same
-- priority in the order they were binded

local function compareBindingOrder(binding1, binding2)
	local binding1_priority = binding1.priority
	local binding2_priority = binding2.priority

	if binding1_priority == binding2_priority then
		if binding1.subPriority < binding2.subPriority then
			return true
		else
			return false
		end

	elseif binding1_priority < binding2_priority then
		return true
	else
		return false
	end
end

local Binder = {}
Binder.__index = Binder

local ScriptBinding = {}
ScriptBinding.__index = ScriptBinding

function Binder.new()
	return setmetatable({
		_active = true,
		_bindings = {}
	}, Binder)
end

function Binder:IsActive(): boolean
	return self._active == true
end

function Binder:Bind(
	priority: number,
	callback: (...any) -> ()
)
	assert(
		typeof(priority) == 'number',
		"Must be a number"
	)

	assert(
		typeof(callback) == 'function',
		"Must be a function"
	)

	if self._active == false then
		return setmetatable({
			Binded = false
		}, ScriptBinding)
	end

	local _bindings = self._bindings
	BindCounter += 1

	local node = {
		priority = priority,
		callback = callback,

		subPriority = BindCounter,
		binder = self,
		binding = nil
	}

	table.insert(_bindings, node)
	table.sort(_bindings, compareBindingOrder)

	local binding = setmetatable({
		Binded = true,
		_node = node
	}, ScriptBinding)

	node.binding = binding

	return binding
end

function Binder:Wait(priority: number): (...any)
	assert(
		typeof(priority) == 'number',
		"Must be a number"
	)

	local thread do
		thread = coroutine.running()

		local binding
		binding = self:Bind(priority, function(...)
			if binding == nil then
				return
			end

			binding:Unbind()
			binding = nil

			task.spawn(thread, ...)
		end)
	end

	return coroutine.yield()
end

function Binder:Fire(...)
	if self._active == false then
		return
	end

	for _, node in ipairs(self._bindings) do
		task.defer(node.callback, ...)
	end
end

function Binder:Destroy()
	if self._active == false then
		return
	end

	self._active = false

	for _, node in ipairs(self._bindings) do
		local binding = node.binding

		binding.Binded = false
		binding._node = nil
	end

	self._bindings = nil
end

function ScriptBinding:Unbind()
	if self.Binded == false then
		return
	end

	self.Binded = false

	local _node = self._node
	local _binder = _node.binder
	local _bindings = _binder._bindings

	local index = table.find(_bindings, _node)
	if index then
		table.remove(_bindings, index)
	end

	self._node = nil
end

function ScriptBinding:GetPriority(): number
	if self.Binded then
		return self._node.priority
	else
		error("Cannot get priority from unbinded binding", 2)
	end
end

export type Class = typeof(
	setmetatable({}, Binder)
)

export type ScriptBinding = typeof(
	setmetatable({ Binded = true }, ScriptBinding)
)

return Binder