
--[[ SERVICES ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")

local DataStore2 = require(script.Parent.DataStore2)


--[[ SIGNALS ]]
local SignalsFolder = ReplicatedStorage.Signals
local GaveItem = SignalsFolder.GaveItem
local SendNotif = SignalsFolder.SendNotif
local UpdateRobbing = SignalsFolder.UpdateRobbing


--[[ MODULES ]]
local VaultDoor = require(script.Parent.VaultDoor).new(game.Workspace.VaultDoor)


--[[ PROMPTS FUNCTIONS ]]
local function findItem(plr, itemName)
	local itemFound
	-- check backpack and hand
	local backpack = plr:FindFirstChildOfClass("Backpack")
	-- check if player has backpack
	if backpack then
		-- check if player has item
		local hasItem = backpack:FindFirstChild(itemName)
		local holdingItem = plr.Character:FindFirstChildOfClass("Tool")
		local item = hasItem or holdingItem
		if item and item.Name == itemName then
			itemFound = item
		else
			itemFound = false
		end
	end
	return itemFound
end

local function giveItem(plr, clonedItem)
	local backpack = plr:FindFirstChildOfClass("Backpack")
	if backpack then
		-- give player item
		clonedItem.Parent = backpack
	end
end


local function giveATMCard(plr)
	local itemName = "ATMCard"
	local foundItem = findItem(plr, itemName)
	if foundItem == nil then return end
	if foundItem == false then
		-- player does not have so give item
		local atmCard = ReplicatedStorage.Assets.ATMCard:Clone()
		giveItem(plr, atmCard)
		--send notif
		local msg = "You received an ATM Card!"
		local isError = false
		SendNotif:FireClient(plr, msg, isError)
	else
		-- has the item
		local msg = "You already have an ATM Card!"
		local isError = true
		SendNotif:FireClient(plr, msg, isError)
	end
end

local function giveSecurityCard(plr)
	
	local itemName = "SecurityCard"
	local foundItem = findItem(plr, itemName)
	if foundItem == nil then return end
	if foundItem == false then
		-- player does not have so give item
		local atmCard = ReplicatedStorage.Assets.SecurityCard:Clone()
		giveItem(plr, atmCard)
		--send notif
		local msg = "You received an Security Card!"
		local isError = false
		SendNotif:FireClient(plr, msg, isError)
	else
		-- has the item
		local msg = "You already have a Security Card!"
		local isError = true
		SendNotif:FireClient(plr, msg, isError)
	end
end


local function changeScreen(isError, promptObject)
	
	local errorColor = BrickColor.new("Really red")
	local successColor = BrickColor.new("Neon green")
	
	local atmScreen = promptObject.Parent.Parent.ATMScreen
	
	if isError == true then
		atmScreen.BrickColor = errorColor
	else
		atmScreen.BrickColor = successColor
	end
	atmScreen.Material = Enum.Material.Neon
	task.delay(1.5, function()
		atmScreen.Material = Enum.Material.Plastic
		atmScreen.BrickColor = BrickColor.new("Black")
	end)
	
end



local function giveCash(plr, promptObject)
	
	local itemName = "ATMCard"
	local foundItem = findItem(plr, itemName)
	
	if foundItem == nil then return end
	if foundItem == false then
		-- does not have ATM Card
		changeScreen(true, promptObject)
		local msg = "You need an ATM Card to access this terminal!"
		local isError = true
		SendNotif:FireClient(plr, msg, isError)
	else
		-- check if cash
		local foundCash = findItem(plr, "Cash")
		if foundCash == nil then return end
		if foundCash == false then
			-- give item
			local backpack = plr:FindFirstChildOfClass("Backpack")
			if backpack then
				-- clone item from replicated storage
				local cashItem = ReplicatedStorage.Assets.Cash:Clone()
				-- give player item
				cashItem.Parent = backpack
				-- send event to player to show gui notif
				changeScreen(false, promptObject)
				local msg = "You received cash!"
				local isError = false
				SendNotif:FireClient(plr, msg, isError)
			end
		else
			-- player already has cash
			changeScreen(true, promptObject)
			local msg = "You already have cash!"
			local isError = true
			SendNotif:FireClient(plr, msg, isError)
		end
	end
end


local function openVault()
	-- fire all clients - player opened the bank vault door!
	VaultDoor:Open()
end

local goldBarDebounce = false
local function giveGold(player, promptObject)
	local goldStand = promptObject.Parent.Parent
	if goldBarDebounce == false then
		-- deactivate prox prompt
		promptObject.Enabled = false
		-- give duffle bag
		local char = player.Character
		-- model made by Creeperzombie2024
		local hasDuffle = char:FindFirstChild("DuffleBag")
		
		if player.Robbing.Value == true then
			-- tell player they already have gold
			local msg = "You have already taken enough gold."
			local isError = true
			SendNotif:FireClient(player, msg, isError)
		else
			-- remove gold bars
			for i,goldBar in pairs(goldStand.GoldBars:GetChildren()) do
				goldBar.CanCollide = false
				goldBar.Transparency = 1
			end
			if not hasDuffle then
				-- give duffle
				local newDuffle = ReplicatedStorage.Assets.DuffleBag:Clone()
				newDuffle.Parent = char
			end
			player.Robbing.Value = true
			local msg = "You got some gold!"
			local isError = false
			SendNotif:FireClient(player, msg, isError)
			UpdateRobbing:FireClient(player, true)
		end

		goldBarDebounce = true
		task.delay(3,function()
			goldBarDebounce = false
			-- add gold bars
			for i,goldBar in pairs(goldStand.GoldBars:GetChildren()) do
				goldBar.CanCollide = true
				goldBar.Transparency = 0
			end
			promptObject.Enabled = true
		end)
	end
end

local function telePlayer(plr)
	--local msg = "Escaping now!"
	--local isError = false
	--SendNotif:FireClient(plr, msg, isError)
	if plr.Character then
		plr.Character.HumanoidRootPart.CFrame = game.Workspace.MoneyPart.CFrame
	end
end

local function grabCash(plr, promptObject)
	promptObject.Parent:Destroy()
	-- give money
	local moneyStore = DataStore2("money", plr)
	moneyStore:Increment(100) -- Give them 100 money
	
	local msg = "You picked up $100!"
	local isError = false
	SendNotif:FireClient(plr, msg, isError)
end



--[[ PROMPT EVENTS ]]
-- Detect when prompt is triggered
local function onPromptTriggered(promptObject, player)
	--print("onPromptTriggered")
	--print(promptObject)
	if promptObject.Name == "BankAccount" then
		-- give player atm card
		giveATMCard(player)
	elseif promptObject.Name == "SecurityGuard" then
		-- give player atm card
		giveSecurityCard(player)
	elseif promptObject.Name == "ATMMachine" then
		-- give player cash
		giveCash(player, promptObject)
	elseif promptObject.Name == "VaultDoor" then
		-- give player cash
		openVault()
	elseif promptObject.Name == "StealGold" then
		-- give player money
		giveGold(player, promptObject)
	elseif promptObject.Name == "SecretEscape" then
		-- teleport player to money spot
		telePlayer(player)
	elseif promptObject.Name == "GrabCash" then
		-- teleport player to money spot
		grabCash(player, promptObject)
	end
end


-- Detect when prompt hold begins
local function onPromptHoldBegan(promptObject, player)
	--print("onPromptHoldBegan")
	--print(promptObject)
end


-- Detect when prompt hold ends
local function onPromptHoldEnded(promptObject, player)
	--print("onPromptHoldBegan")
	--print(promptObject)
end


-- Connect prompt events to handling functions
ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)
ProximityPromptService.PromptButtonHoldBegan:Connect(onPromptHoldBegan)
ProximityPromptService.PromptButtonHoldEnded:Connect(onPromptHoldEnded)
