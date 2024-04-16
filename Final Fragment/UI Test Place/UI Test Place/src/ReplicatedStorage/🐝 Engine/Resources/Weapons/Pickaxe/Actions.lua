local Engine = _G.Engine

local AnimationService = Engine.Services.AnimationService
local Weapon = Engine.Classes.Weapon

local Actions = {}
setmetatable(Actions, Actions)
Actions.__index = Actions

--[[This code is NOT redundant or improper. It is intentionally consistent to allow for customization
As future weapons will have different features.
]]

--[[Swing 1

]]
Actions["Swing 1"] = function()
	while Actions.Class.Instance:GetAttribute("Swing") == true do
		task.wait()
	end
	--This determines the timing of the combo sequence.
	local functionTimes = {
		
		--1 Is the delay immediately after the first click, for events before the swing begins.
		[1] = 0,
		
		--2 Is the wait time for the duration of the weapon being drawn.
		[2] = Actions.Class.waitTimes["Swing1PreAnimationTime"],
		
		--3 Is the time during which the weapon is swinging.
		[3] = (Actions.Class.waitTimes["Swing1Duration"]
			- Actions.Class.waitTimes["GraceTime"])
			+ Actions.Class.waitTimes["Swing1PreAnimationTime"],
		
		--4 Is the duration of the draw time and weapon swing combined.
		[4] = Actions.Class.waitTimes["Swing1Duration"]
			+ Actions.Class.waitTimes["Swing1PreAnimationTime"],
		
		--5 Is the time it takes for the combo to fully end.
		[5] = Actions.Class.waitTimes["ComboEndTime"]
			+ Actions.Class.waitTimes["Swing1Duration"]
			+ Actions.Class.waitTimes["Swing1PreAnimationTime"]
	}
	local ID = os.clock()
	Actions.Class.Instance:SetAttribute("SwingID", ID)
	for i = 1, #functionTimes do
		task.delay(functionTimes[i], function()
			if i == 1 then
				
				--PRE-SWING EVENTS
				
			elseif i == 2 then
				
				--DURING SWING EVENTS
				Actions:SwingToggle(true)
				if Actions.Class.State ~= "Forming" then
					PlayAnimation("Swing1")
				end
				Actions.Class.State = "Swing 1"
				Actions.Class.Instance:SetAttribute("Swing", true)
				
			elseif i == 3 then
				
				--AFTER GRACE EVENTS
				--Clicks for new swings are now allowed.
				Actions.Class.CanClick = true
				
			elseif i == 4 then
				
				--AFTER SWING EVENTS
				Actions:SwingToggle(false)
				Actions.Class.Instance:SetAttribute("Swing", false)
				
			elseif i == 5 then
				
				--IDLE EVENTS
				--Idle if the ID has not changed, implying no new inputs or swings have occurred.
				if Actions.Class.Instance:GetAttribute("SwingID") == ID then
					PlayAnimation("Swing1Idle")
					Actions["Idle"](ID)
				end
			end
		end)
	end
	return
end

--[[Swing 2

]]
Actions["Swing 2"] = function()
	while Actions.Class.Instance:GetAttribute("Swing") == true do
		task.wait()
	end
	local functionTimes = {
		
		--1 Is the delay immediately after the first click, for events before the swing begins.
		[1] = 0,
		
		--2 Is the wait time for the duration of the weapon being drawn.
		[2] = Actions.Class.waitTimes["Swing2PreAnimationTime"],
		
		--3 Is the time during which the weapon is swinging.
		[3] = (Actions.Class.waitTimes["Swing2Duration"]
			- Actions.Class.waitTimes["GraceTime"])
			+ Actions.Class.waitTimes["Swing2PreAnimationTime"],
		
		--4 Is the duration of the draw time and weapon swing combined.
		[4] = Actions.Class.waitTimes["Swing2Duration"]
			+ Actions.Class.waitTimes["Swing2PreAnimationTime"],
		
		--5 Is the time it takes for the combo to fully end.
		[5] = Actions.Class.waitTimes["ComboEndTime"]
			+ Actions.Class.waitTimes["Swing2Duration"]
			+ Actions.Class.waitTimes["Swing2PreAnimationTime"]
	}
	
	local ID = os.clock()
	Actions.Class.Instance:SetAttribute("SwingID", ID)


	for i = 1, #functionTimes do
		task.delay(functionTimes[i], function()
			if i == 1 then

				--PRE-SWING EVENTS

			elseif i == 2 then

				--DURING SWING EVENTS
				Actions:SwingToggle(true)
				PlayAnimation("Swing2")
				Actions.Class.State = "Swing 2"
				Actions.Class.Instance:SetAttribute("Swing", true)

			elseif i == 3 then

				--AFTER GRACE EVENTS
				Actions.Class.CanClick = true

			elseif i == 4 then

				--AFTER SWING EVENTS
				Actions:SwingToggle(false)
				Actions.Class.Instance:SetAttribute("Swing", false)

			elseif i == 5 then

				--IDLE EVENTS
				if Actions.Class.Instance:GetAttribute("SwingID") == ID then
					PlayAnimation("Swing2Idle")
					Actions["Idle"](ID)
				end
			end
		end)
	end
	return
end

--[[Form

]]
Actions["Form"] = function()
	Actions.Class.State = "Forming"
	PlayAnimation("FormSwing")
	
	Engine.Tools:QuickTween(Actions.Class.Instance.Handle, .25, {Transparency = 0})
	Engine.Tools:QuickTween(Actions.Class.Instance.Handle.Binding, .25, {Transparency = 0})
	Engine.Tools:QuickTween(Actions.Class.Instance.Handle.Blade, .25, {Transparency = 0})
	Engine.Tools:QuickTween(Actions.Class.Instance.Handle.Nut, .25, {Transparency = 0})
	Engine.Tools:QuickTween(Actions.Class.Instance.Handle.Rod, .25, {Transparency = 0})
	
	return
end

--[[Deform

]]
Actions["Deform"] = function()
	Actions.Class.State = "Deforming"
	PlayAnimation("Deform")

	Engine.Tools:QuickTween(Actions.Class.Instance.Handle, .25, {Transparency = 1})
	Engine.Tools:QuickTween(Actions.Class.Instance.Handle.Binding, .25, {Transparency = 1})
	Engine.Tools:QuickTween(Actions.Class.Instance.Handle.Blade, .25, {Transparency = 1})
	Engine.Tools:QuickTween(Actions.Class.Instance.Handle.Nut, .25, {Transparency = 1})
	Engine.Tools:QuickTween(Actions.Class.Instance.Handle.Rod, .25, {Transparency = 1})




	task.wait(Actions.Class.waitTimes["DeformationTime"])
	if Actions.Class.State == "Deforming" then
		AnimationService:StopSplice(Actions.Class.Animations)
		Actions.Class.State = "None"
		return
	end
	return
end

--[[Idle

]]
Actions["Idle"] = function(ID)
	Actions.Class.State = "Idle"
	Actions.Class.CanClick = true
	task.wait(Actions.Class.waitTimes["IdleTime"])
	if Actions.Class.State == "Idle" and Actions.Class.Instance:GetAttribute("SwingID") == ID then
		Actions["Deform"]()
		return
	end
	return
end

function Actions:SwingToggle(Toggle)	
	if Toggle == true then
		Actions.Class.Instance.Handle.Blade.CanTouch = Actions.Class.CanKill
		Actions.Class.Instance.Handle.Blade.Trail.Enabled = true
		Actions.Class.Instance.Handle.Blade.Material = "Neon"
	elseif Toggle == false then
		Actions.Class.Instance.Handle.Blade.CanTouch = false
		Actions.Class.Instance.Handle.Blade.Trail.Enabled = false
		Actions.Class.Instance.Handle.Blade.Material = "SmoothPlastic"
	end
end

function PlayAnimation(AnimationName)
	
	local AnimationTimes = Actions.Class.Animations:GetAttributes()
	
	local PositionArray = Engine.Tools:CSVToArray(AnimationTimes[AnimationName])
	
	local startPosition = PositionArray[1]
	
	local endPosition = PositionArray[2]
	
	AnimationService:PlaySplice(Actions.Class.Animations,
		startPosition,
		endPosition,
		Actions.Class.Player
	)
	return
end

return Actions

