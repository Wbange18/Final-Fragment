--[[

Notification Service is not a working model. It is far too complex in the notification frame constructor.
This is a symptom of bad design.

THIS HAS BEEN FIXED

Current things this constructor tries to do:
Connect to mouseover events
Connect to scroll events
Reorganize when elements are added or removed

Instead we need new classes and a new approach.

Scroll Frame can still contain the methods it has. However...

new structure

FFNotificationService: Accept calls from random scripts. Instantiate the scroll frame and other classes.

SortList: Sort contents added to it by ascending number.
	Add: Add contents
	Remove: Remove contents

ScrollFrame: Accept calls to add notifications.
	Add: Add and organize notifications like __newindex does. Use SortList to handle the order.
	
How does the frame know when elements are removed?
Will scrollFrame ever add a notification not expecting a callback?


--[[[
	newNotificationFrame.Notifications = setmetatable({}, {
		--[[__index
		Purpose: Allow the table to be called by its ascending integer order. Find this in the ordering table
		and return the correct notification object.
		@metamethod
		
__index = function(Table, Key)
	local FFNotificationService = _G.Engine.Services.FFNotificationService
	local CurrentFrame = FFNotificationService.CurrentFrame
	return rawget(Table, rawget(CurrentFrame.NotificationOrder, Key))
end,

		--[[__newindex
		Purpose: Organize newly input or removed notifications, adjusting the list to be in order of
		ascending LayoutPriorities from 0. Also, fire zero-delay update functions Scroll and UpdateBars.
		@metamethod
		
__newindex = function(Table, Key, Value)

	--These are required in the newindex scope
	local FFNotificationService = _G.Engine.Services.FFNotificationService
	local CurrentFrame = FFNotificationService.CurrentFrame

	CurrentFrame.Updating = true

	--Set the actual value to the table
	rawset(Table, Key, Value)

	--Reset the notification ordering table
	CurrentFrame.NotificationOrder = {}

	--Compile the notification ordering table using the layout priorities
	for _, notification in ipairs(Table) do
		table.insert(CurrentFrame.NotificationOrder, notification.LayoutPriority)
	end

	-- Sort the values in the ordering table
	table.sort(CurrentFrame.NotificationOrder, function(a,b)
		return a < b
	end)

	--Assign the layout orders to the keys of the ordering table
	for i, value in ipairs(CurrentFrame.NotificationOrder) do
		Table[value].Instance.LayoutOrder = i
	end

	--Update the context bars
	CurrentFrame:UpdateBars()

	--If the window is scrolled to the bottom, move it up one (in the case that a value was removed)
	if Value == nil then
		if CurrentFrame.Focused == (CurrentFrame.ScrollFactor + 1) then

			--Workaround against the Scroll function's debounce protection; I arbitrarily move the Focused value
			--to an impossible one.
			CurrentFrame.Focused = 0
			CurrentFrame:Scroll(nil, nil, -1)
		end
	end
	CurrentFrame.Updating = false
end
})

	local mouseConnection
	mouseConnection = focusNotification.Instance.MouseLeave:Connect(function()
		mouseConnection:Disconnect()
		self:TopFocus()
	end)
]]


