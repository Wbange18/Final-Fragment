--local PhysService = game:GetService("PhysicsService")
local Player = game.Players.LocalPlayer

function NoCollide(model)
	for k,v in ipairs(model:GetChildren()) do
		if v:IsA"BasePart" then
         v.CollisionGroup = "OtherPlayers"
			--PhysService:SetPartCollisionGroup(v,"Player")
		end
	end
end

function NoCollideLocalPlayer(localmodel)
	for k,v in ipairs(localmodel:GetChildren()) do
		if v:IsA"BasePart" then
         v.CollisionGroup = "Player"
			--PhysService:SetPartCollisionGroup(v,"OtherPlayers")
		end
	end
end

game.Players.PlayerAdded:connect(function(player)
	player.CharacterAdded:connect(function(char)
		char:WaitForChild("HumanoidRootPart")
		char:WaitForChild("Head")
		char:WaitForChild("Humanoid")
		wait(0.1)
		NoCollide(char)
	end)

	if player.Character then
		NoCollide(player.Character)
	end
end)

game.Players:WaitForChild(Player.Name)
Player.CharacterAdded:connect(function(localchar)
	localchar:WaitForChild("HumanoidRootPart")
	localchar:WaitForChild("Head")
	localchar:WaitForChild("Humanoid")
	wait(0.1)
	NoCollideLocalPlayer(localchar)
end)