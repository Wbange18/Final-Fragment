local TouchInputService = game:GetService("TouchInputService")

--[[CLASS DESCRIPTION:
Frame of the notification system. As the parent of all notification classes, the frame must sort
and initialize all objects assigned to it. It must also handle the user inputs, altering focused
elements and scrolling the frame.
]]
local Engine = _G.Engine

local ContextActionService = _G.RobloxServices.ContextActionService
local Player = game.Players.LocalPlayer

local PlayerGui = Player.PlayerGui
local Mouse = Player:GetMouse()

--Get Classes
local Notification = Engine.Classes.Notification
local FrameBar = Engine.Classes["Notification Frame Bar"]
local OrderedList = Engine.Classes["Ordered List"]

local NotificationFrame = {}

--Set the table index to the Notification table
NotificationFrame.__index = NotificationFrame

--METHODS=====================================================================

--[[Scroll
Scroll the frame by a magnitude parameter.
@method
@param {number} magnitude - Magnitude of the scroll vector
]]
function NotificationFrame:Scroll(name, state, magnitude)
	self.ScrollFactor =
		math.abs(
			--Clamp the ScrollFactor value between 0 and the max possible position.
			math.clamp(
				self.ScrollFactor + magnitude,
				0,
				math.max(
					self.Notifications:GetLength() - 1,
					0
				)
			)
		) * math.abs(magnitude)
	
	--TODO: Rework This
	if self.ScrollFactor + 1 == self.ScrollPosition then
		return
	end

	self.ScrollPosition = self.ScrollFactor + 1
	self:UpdateBars()
	self:TopFocus()
	
	local Tween = Engine.Tools:QuickTween(self.Instance, 1/12, 
		{
		CanvasPosition = Vector2.new(0,
			(
				--Add the scales of the padding and element together, set them to offset, then multiply
				--by signed scrollfactor.
				(self.Instance.UIListLayout.Padding.Scale + Notification.MinSize.Y.Scale)
				* self.Instance.AbsoluteCanvasSize.Y)
				* (self.ScrollFactor)
			)
		}
	)
end

--[[ChangeFocus
Change the focused notification, and resize others.
@method
@param {object} notification - Target notification to focus
]]
function NotificationFrame:ChangeFocus(focusNotification)
	if self.Focus == "Auto" then
		return
	end
	
	focusNotification:Resize("Large")
	
	--Resize one, unsize others
	for _, notification in ipairs(self.Notifications:GetList()) do
		if notification.Dead == true then
			continue
		end

		if notification == focusNotification then
			continue
		end

		notification:Resize("Small")
	end
end

--[[TopFocus
Change the focus to the default focused element.
@method
]]
function NotificationFrame:TopFocus()
	if self.Focus == "Manual" then
		return
	end
	
	for _, notification in ipairs(self.Notifications:GetList()) do
		if notification.Dead == true then
			continue
		end

		if notification.Instance.LayoutOrder == (self.ScrollFactor + 1) then
			notification:Resize("Large")
			continue
		end
		
		notification:Resize("Small")
    end
end

--[[UpdateBars
Update the context bars at the top and bottom of the frame.
]]
function NotificationFrame:UpdateBars()
	if self.ScrollFactor > 0 then
		self.TopBar:Reveal()
	else
		self.TopBar:Hide()
	end
	
	if self.ScrollFactor < self.Notifications:GetLength() - 3 then
		self.BottomBar:Reveal()
	else
		self.BottomBar:Hide()
	end
end

--[[AddNotification
Add a notification to the frame, when passed from the service
@method
@param {object} notification - notification to add
]]
function NotificationFrame:AddNotification(notification)
	local NotificationService = Engine.Services.NotificationService

	notification:Resize("Small", true)
	
	self.Notifications:AddItem(notification.LayoutPriority, notification)
	
	self:ResetOrder()
	self:TopFocus()
	self:UpdateBars()
	
	notification.Instance.Parent = self.Instance
	notification:Reveal()
	return
end

--[[RemoveNotification
Remove a notification to the frame, when passed from the service
@method
@param {object} notification - notification to remove
]]
function NotificationFrame:RemoveNotification(notification)
	notification:Hide()
	
	if self.Notifications:GetKey(notification) == (self.ScrollFactor + 1) then
		self:Scroll(nil, nil, -1)
	else
		self:TopFocus()
	end
	
	self.Notifications:RemoveItem(notification)
	
	self:ResetOrder()
	self:UpdateBars()
	return
end

--[[ResetOrder
Reset the order of the notification layout orders, following usage of OrderedList:Sort()
@method
]]
function NotificationFrame:ResetOrder()
	for _, object in ipairs(self.Notifications.Contents) do
		object.Instance.LayoutOrder = self.Notifications:GetKey(object)
	end
	return
end

--[[Destroy
Destroy the NotificationFrame
@method
]]
function NotificationFrame:Destroy()
	self.mouseEnterConnection:Disconnect()
	self.mouseLeaveConnection:Disconnect()
	
	for i, notification in ipairs(self.Notifications) do
		notification:Destroy(true)
	end
	self.TopBar:Destroy()
	self.BottomBar:Destroy()
	self.Instance.CanvasPosition = Vector2.new(0,0)
end

--CONSTRUCTORS===============================================================

--[[new
Create a new NotificationFrame
@constructor
@return {object} NotificationFrame
]]
function NotificationFrame.new()
	local newNotificationFrame = {}
	setmetatable(newNotificationFrame, NotificationFrame)
	newNotificationFrame.Instance = game.Players.LocalPlayer.PlayerGui:WaitForChild("In-Game UI").
		Notifications.NotificationFrame.ScrollingFrame
	

	newNotificationFrame.Focus = "Auto"
	newNotificationFrame.ScrollFactor = 0
	newNotificationFrame.ScrollPosition = 1
	newNotificationFrame.Updating = false
	newNotificationFrame.Connections = {}
	newNotificationFrame.Notifications = OrderedList.new("Ascending", "LayoutPriority")
	
	newNotificationFrame.TopBar = FrameBar.new(newNotificationFrame.Instance.Parent["Top Indicator"])
	newNotificationFrame.BottomBar = FrameBar.new(newNotificationFrame.Instance.Parent["Bottom Indicator"])
	

	local runConnection
	local guisAtPosition
	local notificationGui
	local notificationObject
	
	local function scrollAction(name, state, input)
		newNotificationFrame:Scroll(name, state, input.Position.Z)
	end
	
	local function renderCheck()
		guisAtPosition = PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)


		for _, gui in ipairs(guisAtPosition) do
			if gui.Name == "Notification" then
				notificationGui = gui
				break
			end
		end
		
		if notificationGui == nil then
			newNotificationFrame.Focus = "Auto"
			newNotificationFrame:TopFocus()
			return
		end

		--At this point, we have a real notification instance. Lets get the object:
		notificationObject = newNotificationFrame.Notifications:GetItem(notificationGui.LayoutOrder)

		if notificationObject.Dead == true then
			return
		end
		
		if notificationGui.Frame.SmallNotification.Transparency < 1 then
			newNotificationFrame.Focus = "Manual"
			newNotificationFrame:ChangeFocus(
				newNotificationFrame.Notifications[notificationGui.LayoutOrder]
			)
		end
	end
	
	local function mouseEnter()
		ContextActionService:BindAction("Scroll", scrollAction, false, Enum.UserInputType.MouseWheel)

		runConnection = _G.RobloxServices.RunService.Stepped:Connect(renderCheck)
	end
	
	local function mouseLeave()
		ContextActionService:UnbindAction("Scroll")
		runConnection:Disconnect()
	end
	
	newNotificationFrame.mouseEnterConnection = 
		newNotificationFrame.Instance.MouseEnter:Connect(mouseEnter)
	
	newNotificationFrame.mouseLeaveConnection = 
		newNotificationFrame.Instance.MouseLeave:Connect(mouseLeave)
	
	return newNotificationFrame
end

return NotificationFrame