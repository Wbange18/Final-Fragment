local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)

local NotificationTimer = {}

NotificationTimer.__index = NotificationTimer

--METHODS=====================================================================

--[[SetTimer
Sets the time the timer will start at, or is currently running at.
@class
@param (number) time - The time to set the timer to.
]]
function NotificationTimer:SetTimer(timerTime)
	
	self.Instance.Text = timerTime
end

--[[StartTimer
Starts the timer for the notification.
@class
@param {function} callOver - Callback for the timer
@return (number) time - Time the timer has started from.
]]
function NotificationTimer:StartTimer(callOver)
	
	coroutine.wrap(function()
		pcall(function()
			while self.Instance.Visible == true and tonumber(self.Instance.Text) > 0 do
				task.wait(1)
				self.Instance.Text = self.Instance.Text - 1
			end
			callOver()
		end)
	end)()
end

----[[Stop Timer
--Stops the timer for the notification.
--@class
--@return (number) time - Time the timer was stopped at.
--]]
--function NotificationTimer:StopTimer()
--	--self.Notification.TimeEnded.Value = self
--	--self.Instance.Visible = false
--	self.Notification:Destroy()
--end

function NotificationTimer:Destroy()
	--self:StopTimer()
	self = nil
end

--CONSTRUCTOR================================================================

--[[new
Create a new timer for the parent notification.

@param {object} notification - Notification object to make the timer for. Note that this is an
object parameter, which is unusual for single parameter constructors.

@return {object} newTimer - The new timer for the notification.
]]
function NotificationTimer.new(notification)
	
	local newTimer = {}
	setmetatable(newTimer, NotificationTimer)
	
	newTimer.Instance = notification.Frame.Time
	newTimer.Notification = notification
	
	--If the timer property is false, hide the timer. Otherwise, start the timer.
	
	--Set the transparency to the timerVisible parameter in the notification object.
	--Must be flipped since transparency is backwards
	newTimer.Instance.TextTransparency = EngineTools.Flip(
		EngineTools.BoolToNumber(
			newTimer.Notification.timerVisible
		)
	)
	
	return newTimer
end

return NotificationTimer