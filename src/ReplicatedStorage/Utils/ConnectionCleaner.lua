-- Really simple Maid only made for connections

local Maid = {}
Maid.__index = Maid

-- Creates a Maid object
function Maid.new()
	return setmetatable({
		_connections = {}
	}, Maid)
end

-- Returns a boolean determing if such maid was cleaned before
function Maid:WasCleaned(): boolean
	return self._connections == nil
end

-- Adds a connection for cleaning up to a maid
function Maid:Add(connection)
	table.insert(
		self._connections,
		connection
	)
end

-- Cleans up a maid
function Maid:Cleanup()
	local _connections = self._connections
	self._connections = nil

	for _, connection in ipairs(_connections) do
		connection:Disconnect()
	end
end

export type Class = typeof(Maid.new())

return Maid