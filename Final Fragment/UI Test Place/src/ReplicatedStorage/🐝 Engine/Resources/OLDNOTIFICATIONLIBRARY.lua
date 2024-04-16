--[[
This is a client sided module. If first required on a server script, behavior will be
unpredictable. Additionally, a localized NotificationService must exist on the client. 🐝
]]
local Player = game.Players.LocalPlayer

--Get Roblox Services
local TweenService = game:GetService("TweenService")
local ReplicatedService = game:GetService("ReplicatedStorage")

--Get Bumble Engine
local Bumble = ReplicatedService["🐝 Engine"]

--Get Bumble Engine Module
local Engine = require(Bumble.Engine)

--Get Services
local NotificationService = require(Engine:GetService("NotificationService"))

--Get Resources
local ReferenceNotification = Engine:GetResource("Reference Notification")

Notification = {}

--Set the table index to the Notification table
Notification.__index = Notification

--Module Variables
local Notifications = {}
Notifications.MaxSize = UDim2.new(0.886, 0, 0.087, 0)
Notifications.MinSize = UDim2.new(0.532, 0, 0.055, 0)

--METHODS=====================================================================

--[[Resize
Resize a notification object.
@class
@param (string) size - The size of the notification as Small or Large.
]]
function Notification:Resize(size)
	local sizes = {
		["Small"] = Notifications.MinSize,
		["Large"] = Notifications.MaxSize
	}
	if size == "Small" then
		Engine.Tools:FadeTween(self.Frame.SmallNotification, self.Frame.LargeNotification, 1/7)
		Engine.Tools:QuickTween(self.Frame.MinSubject, 1/7, {TextTransparency = 0})
		Engine.Tools:QuickTween(self.Frame.Content, 1/7, {TextTransparency = 1})
		Engine.Tools:QuickTween(self.Frame.Subject, 1/7, {TextTransparency = 1})

	elseif size == "Large" then
		Engine.Tools:FadeTween(self.Frame.LargeNotification, self.Frame.SmallNotification, 1/7)
		Engine.Tools:QuickTween(self.Frame.MinSubject, 1/7, {TextTransparency = 1})
		Engine.Tools:QuickTween(self.Frame.Content, 1/7, {TextTransparency = 0})
		Engine.Tools:QuickTween(self.Frame.Subject, 1/7, {TextTransparency = 0})
	end

	local goal = {
		Size = sizes[size]
	}

	Engine.Tools:QuickTween(self.Instance, 1/5, goal)
end

--[[Reveal
Reveal a notification object.
@class
]]
function Notification:Reveal()
	local goal = {
		Position = UDim2.new(0, 0, 0, 0)
	}

	Engine.Tools:QuickTween(self.Frame, 1/3, goal)
end

--[[Retract
Retract a notification object.
@class
]]
function Notification:Retract()
	local goal = {
		Position = UDim2.new(-1, 0, 0, 0)
	}

	Engine.Tools:QuickTween(self.Instance.Notification, 1/4, goal, nil, "In")

end

--[[SetTimer
Sets the time the timer will start at, or is currently running at.
@class
@param (number) time - The time to set the timer to.
]]
function Notification:SetTimer(timerTime)
	self.Instance.Notification.Time.Text = timerTime
	self.Duration = timerTime
	self:StartTimer()
end

--[[Stop Timer
Stops the timer for the notification.
@class
@return (number) time - Time the timer was stopped at.
]]
function Notification:StopTimer()
	self.Frame.Time.Visible = false
	self:Destroy()
end

--[[StartTimer
Starts the timer for the notification.
@class
@return (number) time - Time the timer has started from.
]]
function Notification:StartTimer()
	coroutine.wrap(function()
		pcall(function()
			while self.Frame.Time.Visible == true and tonumber(self.Frame.Time.Text) > 0 do
				task.wait(1)
				self.Frame.Time.Text = tonumber(self.Frame.Time.Text) - 1
			end
			self:StopTimer()
		end)
	end)()
end


--[[Destroy
Destroys the notification object.
@class
]]
function Notification:Destroy()
	local scrollingFrame = Player.PlayerGui["In-Game UI"].Notifications.Frame.ScrollingFrame
	self.CancelEvent:Fire()
	self:Retract()
	task.wait(1/4)
	for _, child in ipairs(self.Instance.Parent:GetChildren()) do
		if child:IsA("Frame") then
			if child.LayoutOrder > self.Instance.LayoutOrder then
				child.LayoutOrder = child.LayoutOrder - 1
			end
		end
	end
	self.Instance:Destroy()
	for i, child in ipairs(scrollingFrame:GetChildren()) do
		if  child.Name ~= "UIListLayout" then
			local ID = child:GetAttribute("ID")
			if child.AbsolutePosition.Y >=
				(scrollingFrame.AbsolutePosition.Y - 5) and 
				child.AbsolutePosition.Y <=
				(scrollingFrame.AbsolutePosition.Y + 5) then
				NotificationService:GetObject(ID):Resize("Large")
			else
				NotificationService:GetObject(ID):Resize("Small")
			end
		end
	end
	NotificationService:AdjustNotificationList(self, "Remove")
	setmetatable(self, nil)
	for i in ipairs(self) do
		self[i] = nil
	end
	self = nil
end

--CONSTRUCTORS===============================================================

--[[new
Create a new Notification object and make it appear.
@constructor
@param {string} subject - The subject of the notification.
@param {string} iconLink - The location for the icon in the notification.
@param {number} duration - How long the notification should last for (in seconds)
@param {bool} showTimer - If the timer will be presently visible.
@param {bool} isDismissable - If the notification can be manually cancelled.
@param {string} content - The text for the notification.
@param {string} priority - The priority of the notification (First, Next, or Last)
@param {string} interfaceLink - The location of the UI to link the notification to.

@return {string} notification - Resultant notification object.
]]
function Notification.new(
	subject, iconLink, duration, timerVisible, dismissable, content, priority, interface
)
	
	--Top level localized variables\/
	local playerGui = Player.PlayerGui
	local scrollingFrame = Player.PlayerGui["In-Game UI"].Notifications.Frame.ScrollingFrame
	local notificationCount = 0

	local newNotification = {}
	setmetatable(newNotification, Notification)
	
	newNotification.__index = Notification

	--Variables\/
	newNotification.Subject = subject or ""
	newNotification.Icon = iconLink or ""
	newNotification.Duration = duration or 5
	newNotification.Timer = timerVisible or false
	newNotification.Dismissable = dismissable or true
	newNotification.Content = content or ""
	newNotification.Priority = priority or "First"
	newNotification.Interface = interface or nil
	newNotification.ID = Engine.Tools:GenerateID(3)

	newNotification.Instance = ReferenceNotification:Clone()
	newNotification.Instance.Name = "Notification"
	newNotification.Frame = newNotification.Instance.Notification
	newNotification.Frame.MinSubject.Text = newNotification.Subject
	newNotification.Frame.Subject.Text = newNotification.Subject
	newNotification.Frame.Content.Text = newNotification.Content
	newNotification.Frame.Icon.Image = newNotification.Icon
	newNotification.CancelButton = newNotification.Frame.Cancel
	newNotification.CancelEvent = newNotification.Frame.CancelEvent

	newNotification.Instance:SetAttribute("ID", newNotification.ID)

	--Update the Layout order of existing notifications and determine the priority of the
	--current one.
	for _,child in ipairs(scrollingFrame:GetChildren()) do
		if child.Name ~= "UIListLayout" then
			if newNotification.Priority ~= "Last" then
				if (newNotification.Priority == "Next" and child.LayoutOrder ~= 1) or 
					newNotification.Priority == "First" then
					child.LayoutOrder += 1
				end
			end
		end
	end

	--Get the number of notifications currently in the UI, and subtract 1 to account for the list
	--layout object (that must remain there.)
	notificationCount = #scrollingFrame:GetChildren() - 1

	--Use a quick dictionary to assign a value to the layout order based on priority.
	local priorityCheckDictionary = {
		["First"] = 1,
		["Next"] = 2,
		["Last"] = notificationCount + 1
	}
	newNotification.Instance.LayoutOrder = priorityCheckDictionary[newNotification.Priority]

	--Default the layout order if there are no other notifications.
	if notificationCount == 0 then
		newNotification.Instance.LayoutOrder = 1
	end

	--Parent the notification.
	newNotification.Instance.Parent = scrollingFrame

	--Draw out the notification from the left side of the screen.
	newNotification:Reveal()
	
	if priority == "First" or NotificationService.First == newNotification.Instance.LayoutOrder then
		NotificationService:MinimizeOthers(newNotification.ID)
	end

	--Notifications[newNotification.ID] = newNotification

	--If the dismissable property is true, make the CancelButton visible and selectable. Otherwise,
	--hide it.
	if dismissable then
		newNotification.CancelButton.Visible = true
	else
		newNotification.CancelButton.Visible = false
	end

	--If the timer property is false, hide the timer. Otherwise, start the timer.
	if timerVisible then
		newNotification.Frame.Time.TextTransparency = 0
	else
		newNotification.Frame.Time.TextTransparency = 1
	end
	
	if duration ~= 0 then
		newNotification:SetTimer(duration)
	end

	--Make the cancel button destroy the notification when pressed. 
	newNotification.CancelButton.MouseButton1Click:Connect(function()
		newNotification:Destroy()
	end)
	
	newNotification.Frame.MouseEnter:Connect(function()
		if NotificationService.ScrollFrame:GetAttribute("Scrolling") == true then
			return
		end
		
		NotificationService:ChangeFocus(newNotification.ID)
	end)

	NotificationService:AdjustNotificationList(newNotification, "Add")

	return newNotification
end

return Notification




--[[
What can happen??
Scrolling
-scroll up and down the list, focused is always on mouse cursor
selecting
-whatever the cursor hovers over gets focused, default is top
new notifs
-priority dictates order when added. perhaps higher priorities could always remain on top?
-reorder entire column rather than just individual


--CONSTRUCTORS===============================================================

--[[new
Create a new Notification frame

function NotificationFrame.new()
	local newNotificationFrame = {}
	setmetatable(newNotificationFrame, NotificationFrame)

	newNotificationFrame.__index = NotificationFrame


	return newNotificationFrame
end

return Notification

--[[NOTES

When notifications are created or destroyed, they should resize/add themselves. HOWEVER, they
should NOT reorder the list; that is the notification frame's job. I will paste the script blocks where
this occurred in the past

Update layout orders:

	--for _, child in ipairs(self.Instance.Parent:GetChildren()) do
	--	if child:IsA("Frame") then
	--		if child.LayoutOrder > self.Instance.LayoutOrder then
	--			child.LayoutOrder = child.LayoutOrder - 1
	--		end
	--	end
	--end
	
Resize others:

	--for i, child in ipairs(scrollingFrame:GetChildren()) do
	--	if  child.Name ~= "UIListLayout" then
	--		local ID = child:GetAttribute("ID")
	--		if child.AbsolutePosition.Y >=
	--			(scrollingFrame.AbsolutePosition.Y - 5) and 
	--			child.AbsolutePosition.Y <=
	--			(scrollingFrame.AbsolutePosition.Y + 5) then
	--			NotificationService:GetObject(ID):Resize("Large")
	--		else
	--			NotificationService:GetObject(ID):Resize("Small")
	--		end
	--	end
	--end
	--NotificationService:AdjustNotificationList(self, "Remove")

somethingggg in newnotification

	--Update the Layout order of existing notifications and determine the priority of the
	--current one.
	for _,child in ipairs(scrollingFrame:GetChildren()) do
		if child.Name ~= "UIListLayout" then
			if newNotification.Priority ~= "Last" then
				if (newNotification.Priority == "Next" and child.LayoutOrder ~= 1) or 
					newNotification.Priority == "First" then
					child.LayoutOrder += 1
				end
			end
		end
	end

	--Get the number of notifications currently in the UI, and subtract 1 to account for the list
	--layout object (that must remain there.)
	notificationCount = #scrollingFrame:GetChildren() - 1

more stufff
	--Use a quick dictionary to assign a value to the layout order based on priority.
	local priorityCheckDictionary = {
		["First"] = 1,
		["Next"] = 2,
		["Last"] = notificationCount + 1
	}
	newNotification.Instance.LayoutOrder = priorityCheckDictionary[newNotification.Priority]

	--Parent the notification.
	newNotification.Instance.Parent = scrollingFrame

	--Draw out the notification from the left side of the screen.
	newNotification:Reveal()
	
	if priority == "First" or NotificationService.First == newNotification.Instance.LayoutOrder then
		NotificationService:MinimizeOthers(newNotification.ID)
	end


Default the layout order if there are no other notifications.
	if notificationCount == 0 then
		newNotification.Instance.LayoutOrder = 1
	end


	--Make the cancel button destroy the notification when pressed. 
	newNotification.CancelButton.MouseButton1Click:Connect(function()
		newNotification:Destroy()
	end)
	
	newNotification.Frame.MouseEnter:Connect(function()
		if NotificationService.ScrollFrame:GetAttribute("Scrolling") == true then
			return
		end
		
		NotificationService:ChangeFocus(newNotification.ID)
	end)

	NotificationService:AdjustNotificationList(newNotification, "Add")

	local scrollingFrame = Player.PlayerGui["In-Game UI"].Notifications.Frame.ScrollingFrame
	self.CancelEvent:Fire()
	self:Retract()
	task.wait(1/4)

function NotificationFrame:ToggleSidebar(bar, state)

	--Create a 0 if true, and a 1 if false using engine Class.
	local stateNumber = Engine.Tools:Flip(Engine.Tools:BoolToNumber(state))

	local indicatorTable = {
		["Top"] = self.ScrollFrame.Parent["Top Indicator"],
		["Bottom"] = self.ScrollFrame.Parent["Bottom Indicator"]
	}

	for i, child in ipairs(indicatorTable[bar]:GetChildren()) do
		Engine.Tools:QuickTween(child, 1/4, {Visible = state, BackgroundTransparency = stateNumber})
	end
	Engine.Tools:QuickTween(
		indicatorTable[bar], 1/4, {Position = UDim2.new(-0.139 * stateNumber, 0, indicatorTable[bar].Position.Y.Scale, 0)}
	)
end
]]
