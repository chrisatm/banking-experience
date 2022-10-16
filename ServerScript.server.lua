local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateRobbing = ReplicatedStorage.Signals.UpdateRobbing

local DataStore2 = require(script.Parent.DataStore2)
-- Always "combine" any key you use! To understand why, read the "Gotchas" page.
DataStore2.Combine("DATA", "money")


local function handlePlayerData(plr)
	-- get money storage
	local moneyStore = DataStore2("money", plr)

	-- create leaderstats folder
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = plr
	
	-- create money leaderstats value
	local money = Instance.new("NumberValue")
	money.Name = "Money"
	money.Value = moneyStore:Get(500) -- The "0" means that by default, they'll have 0 points
	money.Parent = leaderstats
	
	-- when money updates, this function runs
	moneyStore:OnUpdate(function(newMoney)
		money.Value = newMoney
	end)
end


local function addRobbingBoolValue(player)
	local robbingBool = Instance.new("BoolValue")
	robbingBool.Name = "Robbing"
	robbingBool.Parent = player
	robbingBool.Value = false
end


local function SetCollisionGroup(char)
	for _, child in ipairs(char:GetChildren()) do
		if child:IsA("BasePart") then
			PhysicsService:RemoveCollisionGroup(child, "hasKey")
		end
	end
	char.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			PhysicsService:RemoveCollisionGroup(descendant, "hasKey")
		end
	end)
end

local function onPlayerDead(player, char)
	player.Robbing.Value = false
	UpdateRobbing:FireClient(player, false)
	SetCollisionGroup(char)
end

local function listenPlayerDied(plr, char)
	char:WaitForChild("Humanoid").Died:Connect(function()
		onPlayerDead(plr)
	end)
end

Players.PlayerAdded:Connect(function(player)
	
	-- bools
	addRobbingBoolValue(player)
	
	-- on character added stuff
	player.CharacterAdded:Connect(function(character)
		listenPlayerDied(player, character)
	end)

	-- handle player data
	handlePlayerData(player)

end)

Players.PlayerRemoving:Connect(function(player)
	print(player.Name .. " left the game!")
end)
