--Get Roblox Services
local TweenService = game:GetService("TweenService")
local ReplicatedService = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

--Get Bumble Engine
local Bumble = ReplicatedService["🐝 Engine"]

--Get Bumble Engine Module
local Engine = require(Bumble.Engine)

--Get Notification Class
local Notification = Engine:GetClass("Notification")

NotificationService = {}

--Set the table index to the Notification table
NotificationService.__index = NotificationService

--METHODS=====================================================================

--[[ResetService
Reset the UI state to default.
@method
]]
function NotificationService:ResetService()
	self.Player = game.Players.LocalPlayer
	self.ScrollFrame = 
		self.Player.PlayerGui["In-Game UI"].Notifications.Frame.ScrollingFrame
	self.FocusedNotification = nil
	self.First = 1
	self.ScrollFrame:SetAttribute("Scrollable", false)
	for i, child in ipairs(self.Notifications) do
		child = nil
	end
	self:UIChanged()
end

--[[GetObject
Get the service object from an instance's ID attribute.
@method
@param {string}  ID - The ID of the object.
@return {object} object - The resultant object from the string.
]]
function NotificationService:GetObject(ID)
	if self.Notifications[ID] == nil then
		print("Error! No notification exists of ID " .. ID)
		return nil
	end
	return self.Notifications[ID]
end

--[[GetInstance
Get the instance of a notification frame at the given LayoutOrder number.
@method
@param {number} position - The numerical position of the frame.
@return {instance} instance - The resultant instance.
]]
function NotificationService:GetInstance(position)
	--Vars\/
	local instance
	
	for _, item in ipairs(self.ScrollFrame:GetChildren()) do
		if item:IsA("Frame") == true then
			if item.LayoutOrder == position then
				instance = item
				return instance
			end
		end
	end
	
	return instance
end

--[[MinimizeOthers
Minimize all notifications that are not the given ID
@method
@param {string} ID - The ID of the notification to keep maximized.
]]
function NotificationService:MinimizeOthers(ID)
	for _, child in ipairs(self.Notifications) do
		if child.ID ~= ID then
			child:Resize("Small")
		end
	end
end

--[[ChangeFocus
Change the currently focused notification.
@method
@param {string} ID - The ID of the notification to switch to.
@param {boolean} scroll - Whether or not to scroll the list to show this at the top.
]]
function NotificationService:ChangeFocus(ID, scroll)
	
	--Variables\/
	local notificationCount = #self.ScrollFrame:GetChildren()
	local newFocused = nil
	
	if #self.ScrollFrame:GetChildren() <= 2 then
		return
	end

	newFocused = self:GetObject(ID)
	newFocused:Resize("Large")
	
	if scroll then
		self:Scroll(ID)
	end
	
	self:MinimizeOthers(ID)
	
	self.FocusedNotification = newFocused
	return
end

--[[UIChanged
Update the UI, including scrollbars, scroll status, focus status, and data.
@method
@return [i] {string} self.FocusedNotification - The ID of the currently focused notification.
@return [i] {boolean} self.Scrollable - The status of whether or not the UI can be scrolled.
]]
function NotificationService:UIChanged()
	
	--Vars\/
	local notificationCount = #self.ScrollFrame:GetChildren()
	
	local topElement = self:GetInstance(self.First)

	local topNumber = self.First
	local bottomNumber = self.First + 2
	
	--Switch Block\/
	if notificationCount < 2 then
		self.ScrollFrame:SetAttribute("Scrollable", false)
		return
	end
	
	self.ScrollFrame:SetAttribute("Scrollable", true)
	
	--The UI has moved, and the top element should be focused.
	self:ChangeFocus(topElement:GetAttribute("ID"))
	self.ScrollFrame:SetAttribute("Scrollable", true)
	
	if self:GetInstance(self.First - 1) ~= nil then
		self:ToggleSidebar("Top", true)
	else
		self:ToggleSidebar("Top", false)
	end
	
	if self:GetInstance(self.First + 3) ~= nil then
		self:ToggleSidebar("Bottom", true)
	else
		self:ToggleSidebar("Bottom", false)
	end
	return
end

--[[AdjustNotificationList
Adjust the notification list to remove or add notifications with their ID.
@method
@param {table} object - The object to adjust the state of.
@param {string} state - The state to adjust the object to. (Add, Remove)
]]
function NotificationService:AdjustNotificationList(object, state)
	if state == "Add" then
		self.Notifications[object.ID] = object
		self:UIChanged()
		return
	end
	
	if state == "Remove" then
		self.Notifications[object.ID] = nil
		self:UIChanged()
		return
	end
end

--[[Scroll
Scroll the UI to a notification.
@method
@param {string} ID - The ID of the notification to scroll to.
@return [i] {number} self.First - The numerical position of the first visible notification.
]]
function NotificationService:Scroll(direction, ID)
	
	--Vars\/
	local topElement = self:GetInstance(self.First)
	local scrollDistance
	local scrollHeight
	local scrollTarget
	local target
	
	if self.ScrollFrame:GetAttribute("Scrollable") == false then
		return
	end
	
	if self:GetInstance(self.First + direction) == nil then
		return
	end
	
	if direction == 0 then
		target = self:GetObject(ID).Instance
		direction = math.sign(target.LayoutOrder - self.First)
	end
	
	if direction ~= 0 then
		target = self:GetInstance(self.First + direction)
	end
	
	self.ScrollFrame:SetAttribute("Scrollable", false)
	self.ScrollFrame:SetAttribute("Scrolling", true)
	
	scrollDistance = target.LayoutOrder - self.First
	
	self:ChangeFocus(self:GetInstance(self.First + scrollDistance):GetAttribute("ID"))
	
	task.wait(1/6)
	
	scrollHeight = math.abs(target.AbsolutePosition.Y - self.ScrollFrame.AbsolutePosition.Y)
	
	scrollTarget = self.ScrollFrame.CanvasPosition + Vector2.new(0, scrollHeight * direction)
	
	Engine.Tools:QuickTween(self.ScrollFrame, 1/6, {CanvasPosition = scrollTarget}).Completed:Wait()
	
	self.ScrollFrame:SetAttribute("Scrollable", true)
	self.ScrollFrame:SetAttribute("Scrolling", false)


	
	self.First = self.First + scrollDistance
	
	self:UIChanged()
end

--[[ToggleSidebar
Reveals or hides the sidebars.
@method
@param {string} bar - Which bar to edit. (Top, Bottom)
@param {boolean} state - Whether to show or hide the bar. (true = show, false = hide)
]]
function NotificationService:ToggleSidebar(bar, state)
	
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

--DEFINITION===============================================================

--Objects\/
NotificationService.Player = game.Players.LocalPlayer
NotificationService.PlayerGui = NotificationService.Player.PlayerGui
NotificationService.ScrollFrame = 
	NotificationService.Player.PlayerGui:WaitForChild("In-Game UI").Notifications.Frame.ScrollingFrame

NotificationService.First = 1

NotificationService.FocusedNotification = nil



NotificationService.Notifications = {}

--Definition\/

--Get the mouse and detect when the scrollframe is entered to await scroll wheel input, when the
--UI is scrollable.
NotificationService.ScrollFrame:GetAttributeChangedSignal("Scrollable"):Connect(function()
	if NotificationService.ScrollFrame:GetAttribute("Scrollable") == true then
		local Mouse = game.Players.LocalPlayer:GetMouse()
		local UserInputConnection
		
		local absolutePosition = NotificationService.ScrollFrame.AbsolutePosition
		local absoluteSize = NotificationService.ScrollFrame.AbsoluteSize
		
		local xComparison = Mouse.X + absolutePosition.X
		local yComparison = Mouse.Y + absolutePosition.Y
		
		if 0 <= xComparison and xComparison <= absoluteSize.X and
			0 <= yComparison and yComparison <= absoluteSize.Y then
			if UserInputConnection ~= nil then
				UserInputConnection:Disconnect()
			end
			UserInputConnection =  UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseWheel then
					local delta = input.Position.Z
					NotificationService:Scroll(delta)
				end
			end)
		end
		
		NotificationService.ScrollFrame.MouseEnter:Connect(function()
			if UserInputConnection ~= nil then
				UserInputConnection:Disconnect()
			end
			UserInputConnection =  UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseWheel then
					local delta = input.Position.Z
					NotificationService:Scroll(delta)
				end
			end)
		end)

		NotificationService.ScrollFrame.MouseLeave:Connect(function()
			if UserInputConnection == nil then
				return
			end
			UserInputConnection:Disconnect()
			UserInputConnection = nil
		end)
	end
end)

return NotificationService