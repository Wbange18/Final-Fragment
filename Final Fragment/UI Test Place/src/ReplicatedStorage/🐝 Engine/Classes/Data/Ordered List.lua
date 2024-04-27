--[[CLASS DESCRIPTION:
Create a self-organizing list that efficiently sorts items by specified order when added and removed.
]]
local OrderedList = {}

local Engine = _G.Engine

OrderedList.__index = OrderedList

--METHODS=====================================================================

--[[AddItem
Add data to the list, and sort.
@method
@param {string} Key - Key to store data with
@param {string} Value - Value of data
]]
function OrderedList:AddItem(Key, Value)
	
	--Set the actual value to the table
	rawset(self.Contents, Key, Value)
	--self.Contents[Key] = Value
	self:Sort()
	
	return 
end

--[[RemoveItem
Remove data from the list, and sort.
@method
]]
function OrderedList:RemoveItem(Key)
	rawset(self.Contents, Key, nil)
	--self.Contents[Key] = nil
	self:Sort()
	
	return
end

--[[GetItem
Fetch an item from the sorted list
@method
]]
function OrderedList:GetItem(Key)
	return self.OrderedContents[Key]
end

--[[GetKey
Fetch an item's key
@method
@param {object} Value - Value to find
@return {object} item - Original item from dictionary
]]
function OrderedList:GetKey(Value)
	
	return Engine.Tools:GetKey(self.OrderedContents, Value)
end

--[[GetLength
Get the length of the dictionary.
@method
@return {number} length - Length of the table
]]
function OrderedList:GetLength()
	return Engine.Tools:GetDictLength(self.OrderedContents)
end

--[[GetList
Get the contents of the ordered dictionary.
@method
@return {table} items - the contents of the dictionary.
]]
function OrderedList:GetList()
	return self.OrderedContents
end

--[[Sort
Sort the list by specified order.
@method
]]
function OrderedList:Sort()

	--Reset the list ordering table
	self.SortOrder = {}
	
	--Reset the resulting contents
	self.OrderedContents = {}

	--Compile the list ordering table using the layout priorities
	for sortKey, item in pairs(self.Contents) do
			table.insert(self.SortOrder, sortKey)
	end
	
	local orderTable = {
		["Ascending"] = function(a, b)
			return a < b
		end,
		["Descending"] = function(a, b)
			return a > b
		end,
	}
	table.sort(self.SortOrder, function(a,b)
		return orderTable[self.Order](a, b)
	end)

	for i, value in ipairs(self.SortOrder) do
		--Change self.contents to be in terms of the iterator.
		self.OrderedContents[i] = self.Contents[value]
	end
	
end

--[[Destroy
Remove an ordered list and all of its elements.
@method
]]
function OrderedList:Destroy()
	
	self.Contents = nil
	self.SortOrder = nil
	self.OrderedContents = nil
	self = nil
end

--CONSTRUCTOR================================================================

--[[new
Create a new ordered list.
@constructor
@param {string} order - Order to sort by ["Ascending", "Descending"]
@param {string} property - Property to sort by
]]
function OrderedList.new(order, property)
	local newOrderedList = {}
	setmetatable(newOrderedList, OrderedList)
	newOrderedList.Contents = {}
	newOrderedList.SortOrder = {}
	newOrderedList.OrderedContents = {}
	newOrderedList.Order = order
	newOrderedList.SortProperty = property
	
	return newOrderedList
end

return OrderedList