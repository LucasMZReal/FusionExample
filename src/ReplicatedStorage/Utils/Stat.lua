local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Utils.Signal)

local StatEnums = {
	Integer = "Int",
	Number = "Number",
	String = "String"
}

local function IsValueTypeValid(valueType: string)
	for _, type in pairs(StatEnums) do
		if type == valueType then
			return true
		end
	end

	return false
end

local function GetLeaderstatsFolder(player: Player): Folder
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats == nil then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	return leaderstats
end

export type Stat<T> = {
	_value: ValueBase & {Value: T},
	Changed: RBXScriptSignal,

	Get: (Stat<T>) -> T,
	Set: (Stat<T>, T) -> (),
	Add: (Stat<T>, T) -> ()
}

local function Stat(
	player: Player,
	name: string,
	valueType: string
): Stat<any>

	assert(
		typeof(name) == 'string',
		"Name must be string"
	)

	assert(
		IsValueTypeValid(valueType),
		"ValueType must be valid"
	)

	local valueBase = Instance.new(valueType.. "Value")
	valueBase.Name = name
	valueBase.Parent = GetLeaderstatsFolder(player)

	local self = {
		_value = valueBase :: ValueBase & {Value: any},
		Changed = valueBase:GetPropertyChangedSignal("Value")
	}

	function self:Get()
		return self._value.Value
	end

	function self:Set(value)
		self._value.Value = value
	end

	function self:Add(value)
		self._value.Value += value
	end

	return self
end

return {
	new = Stat,
	Enum = StatEnums
}