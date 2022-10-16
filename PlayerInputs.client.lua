local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local PunchingEvent = ReplicatedStorage.Signals.PunchingEvent

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = game:GetService("Players").LocalPlayer
local char = player.Character or player.CharacterAdded:wait()
repeat wait() until char:FindFirstChild("Humanoid")
local humanoid = char.Humanoid


local crawlAnim = script.crawlAnim
local jabAnim = script.jabAnim
local punchAnim = script.punchAnim
local crawlAnimTrack = humanoid:LoadAnimation(crawlAnim)
local jabAnimTrack = humanoid:LoadAnimation(jabAnim)
local punchAnimTrack = humanoid:LoadAnimation(punchAnim)


--debounces
local crawling = false
local sprinting = false
local punching = false
local jabbed = false
local punched = true


local function handleCrawl()
	if crawling == false then
		-- if not crawling then set crawling on animation
		
		crawlAnimTrack:Play()
		crawlAnimTrack:AdjustSpeed(0)
		crawling = true
	else
		-- if crawling then uncrawl
		crawlAnimTrack:Stop()
		crawling = false
	end
end


local function handleSprint()
	
	if sprinting == false then
		-- run faster
		humanoid.WalkSpeed = 24
		sprinting = true
	else
		-- run normal
		humanoid.WalkSpeed = 16
		sprinting = false
	end
	
end


local function handlePunch()
	if punching == false then
		-- alternate punches
		local anim
		if jabbed == false then
			-- begin punch anim
			anim = jabAnimTrack
			jabbed = true
		else
			anim = punchAnimTrack
			jabbed = false
		end
		
		anim:Play()
		--PunchingEvent:FireServer()
		punching = true
		-- on animation end then do punching false
		anim.Stopped:Wait()
		punching = false
	end

end


local function launchPlayer()

	local humanoidRootPart = game:GetService('Players').LocalPlayer.Character.HumanoidRootPart

	local rand1 = math.random(-1,1)
	local rand2 = math.random(-1,1)
	if rand1 == 0 then
		rand1 = 1
	end
	if rand2 == 0 then
		rand2 = 1
	end
	local dir1 = humanoidRootPart.AssemblyMass * 500 * rand1
	local dir2 = humanoidRootPart.AssemblyMass * 500 * rand2

	humanoidRootPart:ApplyImpulse(Vector3.new(dir1, humanoidRootPart.AssemblyMass * 100, dir2))
end


local function onInputBegan(inputObject, gameProcessedEvent)
	
	if gameProcessedEvent then return end
	
	--print("inputObject.UserInputType: " .. tostring(inputObject.UserInputType))
	--print("inputObject.KeyCode.Name: " .. tostring(inputObject.KeyCode.Name))
		
	-- Next, check that the input was a keyboard event
	if inputObject.UserInputType == Enum.UserInputType.Keyboard then
		if inputObject.KeyCode.Name == "C" then
			handleCrawl()
		elseif inputObject.KeyCode.Name == "LeftShift" then
			handleSprint()
		elseif inputObject.KeyCode.Name == "F" then
			handlePunch()
		end
	end
	
	-- Next, check that the input was a controller event
	if inputObject.UserInputType == Enum.UserInputType.Gamepad1 then
		if inputObject.KeyCode.Name == "ButtonY" then
			handleCrawl()
		elseif inputObject.KeyCode.Name == "ButtonX" then
			handleSprint()
		elseif inputObject.KeyCode.Name == "ButtonB" then
			handlePunch()
		end
	end
end



local function onInputEnded(inputObject, gameProcessedEvent)
	-- First check if the "gameProcessedEvent" is true
	-- This indicates that another script had already processed the input, so this one is ignored.
	if gameProcessedEvent then return end
	
	if inputObject.UserInputType == Enum.UserInputType.Keyboard then
		if inputObject.KeyCode.Name == "LeftShift" then
			if sprinting == false then
				sprinting = true
			end
			handleSprint()
		end
	end
	
	-- Next, check that the input was a controller event
	if inputObject.UserInputType == Enum.UserInputType.Gamepad1 then
		if inputObject.KeyCode.Name == "ButtonX" then
			if sprinting == false then
				sprinting = true
			end
			handleSprint()
		end
	end
end


local function handleRunning(speed)
	if speed > 0 and crawling == true then
		crawlAnimTrack:AdjustSpeed(1)
	else
		crawlAnimTrack:AdjustSpeed(0)
	end
end


local function handleMobileInput(inputType, inputState)
	if inputState == Enum.UserInputState.Begin then
		if inputType == "Sprint" then
			handleSprint()
		elseif inputType == "Punch" then
			handlePunch()
		elseif inputType == "Crawl" then
			handleCrawl()
		end
	elseif inputState == Enum.UserInputState.End then
		if inputType == "Sprint" then
			if sprinting == false then
				sprinting = true
			end
			handleSprint()
		end
	end
	
end


local function initContexts()
	-- Bind action to function
	ContextActionService:BindAction("Sprint", handleMobileInput, true)
	ContextActionService:BindAction("Punch", handleMobileInput, true)
	ContextActionService:BindAction("Crawl", handleMobileInput, true)

	ContextActionService:SetTitle("Sprint", "Sprint")
	ContextActionService:SetTitle("Punch", "Punch")
	ContextActionService:SetTitle("Crawl", "Crawl")

	-- Set button position
	ContextActionService:SetPosition("Sprint", UDim2.new(1, -180, 0, 50))
	ContextActionService:SetPosition("Punch", UDim2.new(1, -100, 0, 10))
	ContextActionService:SetPosition("Crawl", UDim2.new(1, -150, 0, 10))
end


humanoid.Running:Connect(handleRunning)
initContexts()
UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)
