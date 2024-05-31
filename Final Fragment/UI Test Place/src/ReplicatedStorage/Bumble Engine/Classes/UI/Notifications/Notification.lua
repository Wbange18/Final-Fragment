local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Timer = require(ReplicatedStorage["Bumble Engine"].Classes.UI.Notifications.NotificationTimer)
local Engine = require(ReplicatedStorage["Bumble Engine"].Engine)

--Get Resources
local ReferenceNotification = Engine:GetResource("Reference Notification")

local Notification = {}

local lastTime = 0

local repeats = 0

--Set the table index to the Notification table
Notification.__index = Notification

--Module Variables
Notification.MaxSize = UDim2.new(0.886, 0, 0.087, 0)
Notification.MinSize = UDim2.new(0.532, 0, 0.055, 0)

--METHODS=====================================================================

--[[Resize
Resize a notification object.
@class
@param (string) size - The size of the notification as Small or Large.
]]
function Notification:Resize(size, instant)
	instant = instant or (instant == nil and false)
	local tweenTime = 1/7
	if instant == true then
		tweenTime = 0
	end
	
	local sizes = {
		["Small"] = Notification.MinSize,
		["Large"] = Notification.MaxSize
	}
	if size == "Small" then
		EngineTools.FadeTween(self.Frame.SmallNotification, self.Frame.LargeNotification, tweenTime)
		EngineTools.QuickTween(self.Frame.MinSubject, tweenTime, {TextTransparency = 0})
		EngineTools.QuickTween(self.Frame.Content, tweenTime, {TextTransparency = 1})
		EngineTools.QuickTween(self.Frame.Subject, tweenTime, {TextTransparency = 1})

	elseif size == "Large" then
		EngineTools.FadeTween(self.Frame.LargeNotification, self.Frame.SmallNotification, tweenTime)
		EngineTools.QuickTween(self.Frame.MinSubject, tweenTime, {TextTransparency = 1})
		EngineTools.QuickTween(self.Frame.Content, tweenTime, {TextTransparency = 0})
		EngineTools.QuickTween(self.Frame.Subject, tweenTime, {TextTransparency = 0})
	end

	local goal = {
		Size = sizes[size]
	}

	--Linear easing style preserves UI proportion when switching focus
	EngineTools.QuickTween(self.Instance, 1/5, goal, Enum.EasingStyle.Linear)
end

--[[Reveal
Reveal a notification object.

@param {bool} waitForTween - Whether or not to wait for tween
]]
function Notification:Reveal(waitForTween)
	waitForTween = waitForTween or (waitForTween == nil and false)
	local goal = {
		Position = UDim2.new(0, 0, 0, 0)
	}

	local tween = EngineTools.QuickTween(self.Frame, 1/3, goal)
	
	if waitForTween then 
		tween.Completed:Wait()
	end
	return
end

--[[Hide
Retract a notification object.

@param {bool} waitForTween - Whether or not to wait for tween
]]
function Notification:Hide(waitForTween)
	waitForTween = waitForTween or (waitForTween == nil and false)
	local goal = {
		Position = UDim2.new(-1, 0, 0, 0)
	}

	local tween = EngineTools.QuickTween(self.Frame, 1/4, goal, nil, Enum.EasingDirection.In)
	
	if waitForTween then
		tween.Completed:Wait()
	end
end

--[[Destroy
Destroys the notification object.
@class
@param {bool} instantly - Whether or not it should immediately dissappear
]]
function Notification:Destroy(instantly)
	instantly = instantly or (instantly == nil and false)
	self.Dead = true

	self.CancelEvent:Fire()
	if instantly == false then
		self:Hide(true)
	end
	EngineTools.QuickTween(self.Instance, 0.04, {Size = UDim2.new(0,0,0,0)}, Enum.EasingStyle.Linear).Completed:Wait()
	
	if self.Duration ~= 0 then
		self.Timer:Destroy()
	end
	
	--Callback parent service
	self.callback(self)

	self.Instance:Destroy()
end

--CONSTRUCTORS===============================================================

--[[new
Create a new Notification object and make it appear.

@param {string} subject - The subject of the notification.
@param {string} iconLink - The location for the icon in the notification.
@param {number} duration - How long the notification should last for (in seconds)
@param {bool} showTimer - If the timer will be presently visible.
@param {bool} isDismissable - If the notification can be manually cancelled.
@param {string} content - The text for the notification.
@param {string} priority - The priority of the notification (First, Next, or Last)
@param {Color3} notificationColor - The color of the notification (Thanks, NAR?)
@param {string} callback - Function to run from parent adressor

@return {string} notification - Resultant notification object.
]]
function Notification.new(
	subject, iconLink, duration, timerVisible, isDismissable, content, priority, notificationColor, callback
)
	local newNotification = {}
	setmetatable(newNotification, Notification)
	
	newNotification.callback = callback

	newNotification.Subject = subject or ""
	newNotification.Icon = iconLink or ""
	newNotification.Duration = duration or 5
	newNotification.timerVisible = timerVisible or (timerVisible == nil and false) --[[Bool params are hacky
	--to make optional]]
	newNotification.isDismissable = isDismissable or (isDismissable == nil)
	newNotification.Content = content or ""
	newNotification.Priority = priority or "First"
	newNotification.Dead = false
	
	local newTime = time()

	if time() == lastTime then
		repeats += 1
		newTime += repeats
	else
		repeats = 0
	end
	
	newNotification.timeAdded = newTime
	
	lastTime = newTime
	
	newNotification.Instance = ReferenceNotification:Clone()
	newNotification.Frame = newNotification.Instance.Frame

	
	local LayoutOrderTable = {["First"] = 1000, ["Next"] = 2000, ["Last"] = 3000}
	newNotification.LayoutPriority = LayoutOrderTable[newNotification.Priority]
	- newNotification.timeAdded
	
	
	newNotification.Instance.Name = "Notification"
	newNotification.Frame.MinSubject.Text = newNotification.Subject
	newNotification.Frame.Subject.Text = newNotification.Subject
	newNotification.Frame.Content.Text = newNotification.Content
	newNotification.Frame.Icon.Image = newNotification.Icon
	newNotification.CancelButton = newNotification.Frame.Cancel
	newNotification.CancelEvent = newNotification.Frame.CancelEvent

	--If the dismissable property is true, make the CancelButton visible and selectable. Otherwise,
	--hide it.
	if isDismissable then
		newNotification.CancelButton.Visible = true
	else
		newNotification.CancelButton.Visible = false
	end

	--Callback for the timer
	
	if newNotification.Duration ~= 0 then
		local function timeUp()
			newNotification:Destroy()
		end
	
		newNotification.Timer = Timer.new(newNotification)
		newNotification.Timer:SetTimer(newNotification.Duration)
		newNotification.Timer:StartTimer(timeUp)
		
	end
	

	--Make the cancel button destroy the notification when pressed. 
	newNotification.ButtonConnection = 
		newNotification.CancelButton.MouseButton1Click:Connect(function()
		newNotification:Destroy()
	end)

	newNotification.Frame.SmallNotification.ImageColor3 = notificationColor or Color3.new(255,255,255)
	newNotification.Frame.LargeNotification.ImageColor3 = notificationColor or Color3.new(255,255,255)
	return newNotification
end

return Notification