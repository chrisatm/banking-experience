local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateRobbing = ReplicatedStorage.Signals.UpdateRobbing
local SendNotif = ReplicatedStorage.Signals.SendNotif

local PhysicsService = game:GetService("PhysicsService")

local DataStore2 = require(script.Parent.DataStore2)

local MoneyPart = game.Workspace.MoneyPart

local EmitterModule = require(script.Parent.Emitter)

local MoneyPartBindEvent = Instance.new("BindableEvent")
MoneyPartBindEvent.Parent = script.Parent
local PlayersTable = {}


local function CheckTouchingParts()
	-- get part
	local touchingParts = MoneyPart:GetTouchingParts()
	if #touchingParts > 0 then
		for i,partTouched in pairs(touchingParts) do
			MoneyPartBindEvent:Fire(partTouched)
		end
	end
end


local function removePlayerFromTable(plr)
	for i,v in pairs(PlayersTable) do
		if plr.UserId == v then
			table.remove(PlayersTable, i)
		end
	end
end


local function addPlayerToTable(plr)
	local tableRemoveDelay = 5
	table.insert(PlayersTable, plr.UserId)
	task.delay(tableRemoveDelay, function()
		removePlayerFromTable(plr)
	end)
	task.delay(tableRemoveDelay+1, CheckTouchingParts)
end


local function searchTable(plr)
	local value = false
	for i,v in pairs(PlayersTable) do
		if plr.UserId == v then
			value = true
		end
	end
	return value
end


local function checkPlrTable(player, humanoid, partTouched)
	local isOnTable = false

	if #PlayersTable ~= 0 then
		-- check table to see if humanoid exists
		local isOnTableAlready = searchTable(player)
		if isOnTableAlready == true then
			isOnTable = true
		else
			-- player is NOT on table
			addPlayerToTable(player)
			isOnTable = false
		end
	else
		-- no players are on the table
		addPlayerToTable(player)
		isOnTable = false
	end

	return isOnTable
end


local function removeDuffleBag(partParent)
	local duffleBag = partParent:FindFirstChild("DuffleBag")
	if duffleBag then
		duffleBag:Destroy()
	end
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

local function EmitPart(char)
	local colorKeypoints = {
		-- API: ColorSequenceKeypoint.new(time, color)
		ColorSequenceKeypoint.new( 0, Color3.new(0.666667, 1, 0.498039)),  -- At t=0, White
		ColorSequenceKeypoint.new(.1, Color3.new(0.333333, 0.666667, 0)), -- At t=.25, Orange
		ColorSequenceKeypoint.new(.2, Color3.new(0.333333, 0.666667, 0)), -- At t=.5, Red
		ColorSequenceKeypoint.new(1, Color3.new(0.333333, 0.666667, 0))   -- At t=1, Red
	}
	local colorSeq = ColorSequence.new(colorKeypoints)
	EmitterModule.new(char, colorSeq)
end

local function giveMoney(partTouched)
	
	local partParent = partTouched.Parent

	local humanoid = partParent:FindFirstChildWhichIsA("Humanoid")
	
	if humanoid then
		removeDuffleBag(partParent)
		local player = game.Players:GetPlayerFromCharacter(partTouched.Parent)
		local isOnTable = checkPlrTable(player, humanoid, partTouched)
		if isOnTable == false then
			if player.Robbing.Value == true then
				-- play money get sound
				MoneyPart.Sound:Play()
				EmitPart(partParent)
				local msg = "You got $1,000!"
				local isError = false
				SendNotif:FireClient(player, msg, isError)
				-- give money
				local moneyStore = DataStore2("money", player)
				moneyStore:Increment(1000) -- Give them 1000 money
				--player.leaderstats.Money.Value += 1000
				SetCollisionGroup(partParent)
				UpdateRobbing:FireClient(player, false)
				player.Robbing.Value = false
			else
				local msg = "You need to rob the bank first!"
				local isError = true
				SendNotif:FireClient(player, msg, isError)
			end
		end
	end	
end

MoneyPart.Touched:Connect(giveMoney)
MoneyPartBindEvent.Event:Connect(giveMoney)
