--[[CLASS DESCRIPTION:
Notifications are UI elements with enormous functionality, parented to a notification frame.
They have the following responsibilities:
Resize, Reveal, and Hide
These responsibilities are used by the notification frame to manage these notifications on the
player's screen.
Notifications also have a child class; Notification Timer, which is used to time the notification
and allow it to be canceled if the time runs out.
]]
local Player = game.Players.LocalPlayer

--Get Bumble Engine Module
local Engine = _G.Engine

--Get Classes
local Timer = Engine.Classes["Notification Timer"]


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
	local instant = instant or (instant == nil and false)
	local tweenTime = 1/7
	if instant == true then
		tweenTime = 0
	end
	
	local sizes = {
		["Small"] = Notification.MinSize,
		["Large"] = Notification.MaxSize
	}
	if size == "Small" then
		Engine.Tools:FadeTween(self.Frame.SmallNotification, self.Frame.LargeNotification, tweenTime)
		Engine.Tools:QuickTween(self.Frame.MinSubject, tweenTime, {TextTransparency = 0})
		Engine.Tools:QuickTween(self.Frame.Content, tweenTime, {TextTransparency = 1})
		Engine.Tools:QuickTween(self.Frame.Subject, tweenTime, {TextTransparency = 1})

	elseif size == "Large" then
		Engine.Tools:FadeTween(self.Frame.LargeNotification, self.Frame.SmallNotification, tweenTime)
		Engine.Tools:QuickTween(self.Frame.MinSubject, tweenTime, {TextTransparency = 1})
		Engine.Tools:QuickTween(self.Frame.Content, tweenTime, {TextTransparency = 0})
		Engine.Tools:QuickTween(self.Frame.Subject, tweenTime, {TextTransparency = 0})
	end

	local goal = {
		Size = sizes[size]
	}

	--Linear easing style preserves UI proportion when switching focus
	Engine.Tools:QuickTween(self.Instance, 1/5, goal, "Linear")
end

--[[Reveal
Reveal a notification object.
@method
@param {bool} waitForTween - Whether or not to wait for tween
]]
function Notification:Reveal(waitForTween)
	waitForTween = waitForTween or (waitForTween == nil and false)
	local goal = {
		Position = UDim2.new(0, 0, 0, 0)
	}

	local tween = Engine.Tools:QuickTween(self.Frame, 1/3, goal)
	
	if waitForTween then 
		tween.Completed:Wait()
	end
	return
end

--[[Hide
Retract a notification object.
@method
@param {bool} waitForTween - Whether or not to wait for tween
]]
function Notification:Hide(waitForTween)
	waitForTween = waitForTween or (waitForTween == nil and false)
	local goal = {
		Position = UDim2.new(-1, 0, 0, 0)
	}

	local tween = Engine.Tools:QuickTween(self.Frame, 1/4, goal, nil, "In")
	
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
	local instantly = instantly or (instantly == nil and false)

	--[[TODO: Problem: When a notification is destroyed, objects are removed in the transition that
	breaks cases like the render loop for mouse position. However, if we update the frame to compensate,
	the frame will remove the notification before it can animate...
	
	How can I resolve?
	Well... what breaks?

	lets think about the sequence:
	A. Player is hovering over the UI and clicks close
	UI is looking at mouse position to focus an element.
	The target element is the dying notification, and thus error
	Solution: tag notifications if they are dying?

	B. Player is scrolling while the notification times out.
	scroll tween occurs AFTER all calculations occur, so the time isnt an issue
	however, on the impulse

	TopFocus breaks
	mouse hover functions break
	scroll breaks

	why?
	These three are looking for parts of the notification to verify them. Lets investigate why.
	]]

	self.CancelEvent:Fire()
	if instantly == false then
		self:Hide(true)
	end
	
	--Callback parent service
	self.callback(self)
	self.Timer:Destroy()
	self.Instance:Destroy()
	
	--VERY ugly workaround: __newindex won't detect an existing indexed value change, but calling
	--this twice will cause it to fire, as the second time, the index doesn't exist.
	--Engine.Services.NotificationService.CurrentFrame.Notifications[self.LayoutPriority] = nil
	Engine.Services.NotificationService.CurrentFrame.Notifications[self.LayoutPriority] = nil
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
	subject, iconLink, duration, timerVisible, isDismissable, content, priority, callback
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
	local function timeUp()
		newNotification:Destroy()
	end

	newNotification.Timer = Timer.new(newNotification)
	newNotification.Timer:SetTimer(newNotification.Duration)
	newNotification.Timer:StartTimer(timeUp)
	
	--Make the cancel button destroy the notification when pressed. 
	newNotification.ButtonConnection = 
		newNotification.CancelButton.MouseButton1Click:Connect(function()
		newNotification:Destroy()
	end)

	return newNotification
end

return Notification

