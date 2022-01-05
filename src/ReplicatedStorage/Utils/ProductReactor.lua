local MarketplaceService = game:GetService("MarketplaceService")

type ProductCallback = (ReceiptInfo) -> (Enum.ProductPurchaseDecision)

export type ReceiptInfo = {
	PurchaseId: string,
	PlayerId: number,
	ProductId: number,
	CurrencySpent: number,
	PlaceIdWherePurchased: number
}

local ProductReactor = {}
ProductReactor.__index = ProductReactor

local ProductCallbacks: {[number]: ProductCallback} = {}

function ProductReactor.new(callback: ProductCallback)
	assert(
		typeof(callback) == 'function',
		"Must be callback"
	)

	local self = setmetatable({
		_destroyed = false,
		_callback = callback,
		_products = {}
	}, ProductReactor)

	return self
end

function ProductReactor:IsActive()
	return self._destroyed == false
end

function ProductReactor:ConnectToProduct(productId: number)
	assert(
		typeof(productId) == 'number',
		"Must be number"
	)

	if self._destroyed ~= false then
		return
	end

	if ProductCallbacks[productId] == nil then
		ProductCallbacks[productId] = self._callback
		table.insert(self._products, productId)
	else
		warn("ProductId: ("..productId..") is already assigned a callback")
	end
end

function ProductReactor:ConnectToProducts(...: number)
	if self._destroyed ~= false then
		return
	end

	for _, productId in ipairs({...}) do
		if typeof(productId) ~= 'number' then
			warn("(".. tostring(productId).. ") is not a valid productId")
			continue
		end

		self:ConnectToProduct(productId)
	end
end

function ProductReactor:DisconnectProduct(productId: number)
	assert(
		typeof(productId) == 'number',
		"Must be number"
	)

	if self._destroyed ~= false then
		return
	end

	local _products = self._products
	local index = table.find(_products, productId)

	if index then
		table.remove(_products, index)
		ProductCallbacks[productId] = nil
	else
		warn("ProductId: (".. productId.. ") is not connected to any callback")
	end
end

function ProductReactor:DisconnectProducts(...: number)
	if self._destroyed ~= false then
		return
	end

	for _, productId in ipairs({...}) do
		if typeof(productId) ~= 'number' then
			warn("(".. tostring(productId).. ") is not a valid productId")
			continue
		end

		self:DisconnectProduct(productId)
	end
end

function ProductReactor:Destroy()
	if self._destroyed ~= false then
		return
	end
	self._destroyed = true

	for _, productId in ipairs(self._products) do
		ProductCallbacks[productId] = nil
	end

	self._products = nil
	self._callback = nil
end

function MarketplaceService.ProcessReceipt(receiptInfo: ReceiptInfo)
	local callback = ProductCallbacks[receiptInfo.ProductId]
	if callback ~= nil then
		local success, result = pcall(callback, receiptInfo)

		if success then
			if
				typeof(result) == 'EnumItem'
				and table.find(
					Enum.ProductPurchaseDecision:GetEnumItems(), result
				)
			then
				return result
			else
				warn(
					"Value returned for callback for ProductId: ("..
					receiptInfo.ProductId .. ") is not a valid ProductPurchaseDecision\n"..
					"Value returned: ".. tostring(result)
				)
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
		else
			warn("Callback failed for ProductId: (".. receiptInfo.ProductId..")\n Error: ".. result)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	else
		warn("No callback provided for ProductId: (".. receiptInfo.ProductId.. ")")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

return ProductReactor