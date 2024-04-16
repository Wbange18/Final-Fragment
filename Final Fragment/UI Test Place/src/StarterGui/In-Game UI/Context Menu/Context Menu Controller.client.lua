local TweenService = game:GetService("TweenService")

local Frame = script.Parent.Frame

local OpenButton = Frame.OpenButton
local CloseButton = Frame.CloseButton
local LeftButton = Frame.LeftButton
local RightButton = Frame.RightButton
local RingSpinner = Frame["Ring Spinner"]
local NowPlaying = Frame["Now Playing"]
local ShardsCount = Frame["Shards Count"]
local PhaseFolder = Frame.Phases
local ExtraSpeedValue = RingSpinner.RingAnim.AdditionalSpeed

local DefaultPhase = script.Parent.DefaultPhase
local MountedPhase = script.Parent.MountedPhase
local LastPiece = script.Parent.LastPiece

local Player = game.Players.LocalPlayer

local NextPhase
local PreviousPhase

local centerPosition = UDim2.new(0.5,0,0.5,0)

local white = Color3.fromRGB(255,255,255)

local black = Color3.fromRGB(0,0,0)

local inputDebounce = false

local hoverDebounce = false

local phaseChangeDebounce = false

local pieceHoverConnections = {}

--[CONFIG VALUES]
local uiMaxSize = .75
local uiMinSize = .5

--InfoBasic - Common tween info to be used by several functions
function InfoBasic(t, direction, style)
	if not style then style = "Sine" end
	local info = TweenInfo.new(t, Enum.EasingStyle[style], Enum.EasingDirection[direction])
	return info
end

--Create a tween given parameters
function CustomTween(item, t, d, g, style)
	local tween = TweenService:Create(item, InfoBasic(t, d, style), g)
	tween:Play()
end

--Sort values in a table by their included numbers
local function TableSort(folder, sortIdentifier)
	local contents = folder:GetChildren()
	
	table.sort(contents, function(a, b)
		return a[sortIdentifier]:gsub("%D", "") < b[sortIdentifier]:gsub("%D", "")
	end)
	
	return contents
end

--Get names of a folders' children and convert them into a string for data matching
--INPUT: folder with named children
--OUTPUT: numerically sorted string of names perfect for data matches
local function NamesToString(folder)
	local contents = TableSort(folder, "Name")
	local outputString = ""
	
	for i, child in ipairs(contents) do
		outputString ..= child.Name .. ","
	end
	return outputString
end

--Function that returns a table of spaced radial coordinates for a given set of UI elements
local function GetPiecePositions(folder, radius, angle, offsetAngle)
	local offset = offsetAngle or 0
	
	--Find inner angle of arc using offset and reference angle
	local innerAngle = angle - (offset * 2)
	local pieces = {}
	local numPieces = #folder:GetChildren()
	
	--Calculate and insert into the pieces table the coordinates of each piece
	for piece = 1, numPieces do
		
		--Calculate ratio value given current piece and total
		local alpha = (numPieces - piece)/(numPieces - 1)
		
		--Calculate current angle using alpha ratio and applying the offset
		local instanceAngle = (innerAngle * alpha) + (offset)
		
		print(instanceAngle)
		
		--Calculate x and y coordinates using x=r*cos(theta) and y=r*sin(theta)
		local x = radius * math.cos(math.rad(90 - instanceAngle))
		local y = -1 * (radius * math.sin(math.rad(90 - instanceAngle)))
		
		--Using uiMaxSize value assuming the pieces will NEVER be radially cast when minimized
		table.insert(pieces, UDim2.new(.5 + x, 0, .5 + y, 0))
	end
	return pieces
end

--Fade in or out new pieces, wrap in a coroutine to do simultaneous swap
local function PieceFade(folder, direction)
	
	if direction == "Out" then
		
		--Sort the pieces by name using a definitive function
		local pieces = TableSort(folder, "Name")
		
		--Retrieve list of piece locations
		local positions = GetPiecePositions(folder, .58, 76, 10)
		
		--Loop through each piece, start from center position and tween size and position
		for i, piece in ipairs(pieces) do
			piece.Position = centerPosition
			
			--Separate the string for simultaneous action
			CustomTween(piece, .25, "Out", {Position = positions[i], GroupTransparency = 0}, "Back")
			--CustomTween(piece, .15, "Out", {GroupTransparency = .25})
		end
		
		return
	end
	
	if direction == "In" then
		
		--Loop through each piece, assuming their initial position to be correct and tweening size
		--and position
		for i, piece in ipairs(folder:GetChildren()) do
			CustomTween(piece, .25, "In", {Position = centerPosition, GroupTransparency = 1}, "Back")
		end
		
		return
	end
end

--Speed up the circle in a particular direction for menu toggling
local function SpeedAdjust(speedAdditive, t)
	coroutine.wrap(function()
		local tween1 = TweenService:Create(ExtraSpeedValue, InfoBasic(t, "Out"), {Value = speedAdditive})
		tween1:Play()
		tween1.Completed:Wait()
		local tween2 = TweenService:Create(ExtraSpeedValue, InfoBasic(t, "In"), {Value = 0})
		tween2:Play()
	end)()

end

local function NewPiece(Piece)
	Piece.Position = centerPosition
	PieceFade(MountedPhase.Value.Pieces, "Out")
end

--MAIN FUNCTIONS
------------------------------------------------------------------------

--Returns an updated data set of collected fragments, pieces, and shards
local function UpdateData()
	local mountedPhaseInstance = MountedPhase.Value
	local phaseFragments = NamesToString(mountedPhaseInstance.Fragments)
	local phasePieces = NamesToString(mountedPhaseInstance.Pieces)
	local phaseHiddenPieces = NamesToString(mountedPhaseInstance.HiddenPieces)
	local phaseShards = mountedPhaseInstance.Shards.Value
	
	local currentFragments = ""
	local currentPieces = ""
	local currentShards = ""
	local focusedCollectible = ""

	local playerDataStream = Player.PlayerScripts.Data.CollectibleIDs.Value
	
	--Use the second returned value of gsub to count the number of IDs
	local _, playerCollectibleCount = string.gsub(
		playerDataStream, "%u%d+,", "")
	
	--Per collectible, match the string and complete cosmetic actions if so
	for i = 0, playerCollectibleCount do 
		focusedCollectible = string.match(playerDataStream, "%u%d+,")
		if focusedCollectible == nil then break end
		
		playerDataStream = string.gsub(playerDataStream, focusedCollectible, "")
		
		if string.match(phaseFragments, focusedCollectible) then
			currentFragments ..= focusedCollectible
			MountedPhase.Value.Fragments[string.gsub(focusedCollectible, "%p", "")].ImageColor3 = white
		end

		if string.match(phasePieces, focusedCollectible) then
			currentPieces ..= focusedCollectible
			MountedPhase.Value.Pieces[string.gsub(focusedCollectible, "%p", "")].Piece.ImageColor3 = white
		end
		
		if string.match(phaseHiddenPieces, focusedCollectible) then
			currentPieces ..= focusedCollectible
			do
				local NewPiece = MountedPhase.Value.HiddenPieces[string.gsub(focusedCollectible, "%p", "")]
				NewPiece:Clone()
				NewPiece.Parent = mountedPhaseInstance.Pieces
				NewPiece(NewPiece)
				MountedPhase.Value.Pieces.NewPiece.Piece.ImageColor3 = white
			end
		end

		if string.match(phaseShards, focusedCollectible) then
			currentShards ..= focusedCollectible
		end
		local _, numShards = string.gsub(currentShards, "S%d+,", "")
		local _, totalShards = string.gsub(phaseShards, "S%d+,", "")
		ShardsCount.Content.Text = "Shards: " .. numShards .. "/" .. totalShards
	end
	
	return currentFragments, currentPieces, currentShards
end

--Adjust piece cosmetic states
local function PieceHover(state, piece)
	if state == "On" then
		
		if LastPiece.Value ~= nil then
			PieceHover("Off", LastPiece.Value)
		end
		
		LastPiece.Value = piece
		
		local folderContents = MountedPhase.Value.Pieces:GetChildren()
		table.remove(folderContents, table.find(folderContents, piece))
		for i, child in ipairs(folderContents) do
			CustomTween(child, .1, "Out", {GroupTransparency = .8})
		end
		CustomTween(piece, .15, "In", {Size = UDim2.new(0.8, 0,0.125, 0)})
		CustomTween(piece.TextLabel, .15, "In", {TextTransparency = 0})
		CustomTween(piece.Frame, .15, "In", {BackgroundTransparency = 0})
		
	elseif state == "Off" and piece == LastPiece.Value then
		local folderContents = MountedPhase.Value.Pieces:GetChildren()
		for i, child in ipairs(folderContents) do
			CustomTween(child, .1, "In", {GroupTransparency = 0})
		end
		CustomTween(piece, .15, "Out", {Size = UDim2.new(0.62, 0,0.1, 0)})
		CustomTween(piece.TextLabel, .15, "Out", {TextTransparency = 1})
		CustomTween(piece.Frame, .15, "Out", {BackgroundTransparency = 1})
		LastPiece.Value = nil
	end
end

local function SetPieceHoverStates()
	local connectionsCount = 0
	for i, child in ipairs(MountedPhase.Value.Pieces:GetChildren()) do
		pieceHoverConnections[connectionsCount] = child.Piece.MouseEnter:Connect(function()
			PieceHover("On", child)
		end)
		pieceHoverConnections[connectionsCount + 1] = child.Piece.MouseLeave:Connect(function()
			PieceHover("Off", child)
		end)
		connectionsCount += 2
	end
end

local function DissolveHoverConnections()
	for i, child in ipairs(pieceHoverConnections) do
		child:Disconnect()
	end
end

--Switch all cosmetics for the new phase
local function SwapPhaseDetails(oldFolder, newFolder)
	
	--Update the mounted phase and clarify its data immediately
	MountedPhase.Value = newFolder
	UpdateData()
	
	PieceFade(oldFolder.Pieces, "In")
	
	PieceFade(MountedPhase.Value.Pieces, "Out")
	
	SpeedAdjust(10, .15)
	
	--Swap in new preview
	CustomTween(MountedPhase.Value.Preview, .25, "Out", {ImageTransparency = 0})
	
	--Tag out old preview
	CustomTween(oldFolder.Preview, .25, "In", {ImageTransparency = 1})
	
	--Swap in new fragments
	for i, child in ipairs(MountedPhase.Value.Fragments:GetChildren()) do
		CustomTween(child, .25, "Out", {ImageTransparency = 0.2})
	end
	
	
	--Tag out old fragments
	for i, child in ipairs(oldFolder.Fragments:GetChildren()) do
		CustomTween(child, .25, "In", {ImageTransparency = 1})
	end
	
	ShardsCount.Header.Text = string.upper(MountedPhase.Value.Name)
	
	--Remove previous hover states
	DissolveHoverConnections()
	
	--Add new hover states
	SetPieceHoverStates()
	phaseChangeDebounce = false
end

local function DefineNeighborPhases()
	local Phases = PhaseFolder:GetChildren()

	local closestNext = Phases[#Phases]:GetAttribute("ID")
	local closestPrevious = Phases[1]:GetAttribute("ID")



	table.sort(Phases, function(a, b)
		return a:GetAttribute("ID") < b:GetAttribute("ID")
	end)

	for i, child in ipairs(Phases) do
		if not string.match(Player.PlayerScripts.Data.GameFlags.Value, child:GetAttribute("GameFlag")) then
			table.remove(Phases, table.find(Phases, child))
		end
	end

	NextPhase = Phases[table.find(Phases, MountedPhase.Value) + 1]
	PreviousPhase = Phases[table.find(Phases, MountedPhase.Value) - 1]
end

local function ChangePhase(direction)
	if phaseChangeDebounce == true then return end
	
	phaseChangeDebounce = true
	local oldFolder = MountedPhase.Value
	
	if direction == "Left" and PreviousPhase ~= nil then
		SwapPhaseDetails(oldFolder, PreviousPhase)
	else
		phaseChangeDebounce = false
	end

	if direction == "Right" and NextPhase ~= nil then
		SwapPhaseDetails(oldFolder, NextPhase)
	else
		phaseChangeDebounce = false
	end
	
	DefineNeighborPhases()
	
end

local function MenuToggle(direction)
	if direction == "Out" and inputDebounce == false then
		inputDebounce = true
		
		CustomTween(RightButton, .25, "Out", {
			ImageTransparency = 0,
			Visible = true,
			Active = true
		})
		
		CustomTween(LeftButton, .25, "Out", {
			ImageTransparency = 0,
			Visible = true,
			Active = true
		})
		
		--Remove the open button
		OpenButton.Visible = false
		OpenButton.Active = false
		
		--Instate the close button
		CloseButton.Visible = true
		CloseButton.Active = true
		
		--Change the size of the frame for the main animation	
		CustomTween(Frame, .25, "Out", {Size = UDim2.new(uiMaxSize, 0, uiMaxSize, 0)})
		
		--Move the pieces outward to their radial coordinates per scenario
		PieceFade(MountedPhase.Value.Pieces, "Out")
		
		--Add the preview
		
		CustomTween(MountedPhase.Value.Preview, .25, "Out", {ImageTransparency = 0})
		
		--Make the ring spin for detail
		SpeedAdjust(10, .15)
		
		CustomTween(NowPlaying, .25, "Out", {
			GroupTransparency = 1, 
			Position = NowPlaying.Position + UDim2.new(.15, 0, 0, 0)
		})
		
		CustomTween(ShardsCount, .25, "In", {
			GroupTransparency = 0,
			Position = ShardsCount.Position - UDim2.new(.15, 0, 0, 0)
		})
		
		SetPieceHoverStates()
		task.wait(.25)
		inputDebounce = false
		return
	end
	
	if direction == "In" and inputDebounce == false then
		inputDebounce = true
		DissolveHoverConnections()
		if MountedPhase.Value ~= DefaultPhase.Value then
			SwapPhaseDetails(MountedPhase.Value, DefaultPhase.Value)
			DefineNeighborPhases()
			DissolveHoverConnections()
		end

		--Remove the close button
		CloseButton.Visible = false
		CloseButton.Active = false
		
		CustomTween(RightButton, .25, "In", {
			ImageTransparency = 1,
			Visible = false,
			Active = false
		})

		CustomTween(LeftButton, .25, "In", {
			ImageTransparency = 1,
			Visible = false,
			Active = false
		})

		--Instate the open button
		OpenButton.Visible = true
		OpenButton.Active = true
		
		--Change the size of the frame for the main animation
		CustomTween(Frame, .25, "In", {Size = UDim2.new(uiMinSize, 0, uiMinSize, 0)})
		
		--Move the pieces
		PieceFade(MountedPhase.Value.Pieces, "In")
		
		--Remove the preview
		CustomTween(MountedPhase.Value.Preview, .25, "In", {ImageTransparency = 1})

		--Make the ring spin for detail
		SpeedAdjust(10, .15)
		
		CustomTween(NowPlaying, .25, "In", {
			GroupTransparency = 0, 
			Position = NowPlaying.Position - UDim2.new(.15, 0, 0, 0)
		})

		CustomTween(ShardsCount, .25, "Out", {
			GroupTransparency = 1,
			Position = ShardsCount.Position + UDim2.new(.15, 0, 0, 0)
		})
		
		task.wait(.25)
		inputDebounce = false
		return
	end
end

local function Main()
	UpdateData()
	DefineNeighborPhases()
end

Main()

--Create button connections
OpenButton.MouseButton1Click:Connect(function()
	MenuToggle("Out")
end)

CloseButton.MouseButton1Click:Connect(function()
	MenuToggle("In")
end)

LeftButton.MouseButton1Click:Connect(function()
	ChangePhase("Left")
end)

RightButton.MouseButton1Click:Connect(function()
	ChangePhase("Right")
end)



