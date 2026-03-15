local player = game:GetService("Players").LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")




local TI = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut) -- TweenInfo for smooth transitions

local renderconnection = nil --used to track the players camera
local Shiftlockenable = false --used to track if the player is shiftlocked or not

local activeKeys = {
	W = false,
	A = false,
	S = false,
	D = false	
}

local isInAir = false 
-- EVENTS FOR LANDING
local LandingEvent = game.ReplicatedStorage.MovementVfxEvents.LandingVfxEvent
local SoundEvent = game.ReplicatedStorage.MovementVfxEvents.SoundEvent
local animplaytime = 0.3
-- ANIMS HOLDER
local runAnim = hum:LoadAnimation(game.ReplicatedStorage.MoveAnimHolder.Run)
local landed1 = hum:LoadAnimation(game.ReplicatedStorage.MoveAnimHolder.Landed1)
local landed2 = hum:LoadAnimation(game.ReplicatedStorage.MoveAnimHolder.Landed2)
-- local frontwalk = ---hum:LoadAnimation(game.ReplicatedStorage.MoveAnimHolder.FrontWalk) -- this is how u would set up custom anims for like moveing right and left
-- local leftwalk = --hum:LoadAnimation(game.ReplicatedStorage.MoveAnimHolder.LeftWalk)
-- local rightwalk = --hum:LoadAnimation(game.ReplicatedStorage.MoveAnimHolder.RightWalk)
-- local backwalk = --hum:LoadAnimation(game.ReplicatedStorage.MoveAnimHolder.BackWalk)



-- UIS.MouseIcon = "rbxassetid://129875024" USED FOR CUSTOM MOUSE ICONS

local function shiftLockWithCamera()
	local characrer = player.Character
	local camera = game.Workspace.CurrentCamera
	local rootpart = characrer:FindFirstChild("HumanoidRootPart")

	if rootpart then
		local lookVector =  camera.CFrame.LookVector
		local flatLookVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit -- This code is used for shift lock as it makes the player look in the direction of the camera
		
		local targetCframe = CFrame.new(rootpart.Position, rootpart. Position + flatLookVector)
		rootpart.CFrame = targetCframe
	end
end



local function TweenOffSet(bool)
	local camera = workspace.CurrentCamera
	local rootpart = char:FindFirstChild("HumanoidRootPart")
	if bool then
		UIS.MouseIcon = "rbxassetid://16481167971"
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		
		--Tween Our Camera Offset
		local tg = {CameraOffset = Vector3.new(0.5,0.75,0)}
		local tween = TS:Create(char.Humanoid, TI, tg)
		tween:Play()
		
		if renderconnection then renderconnection:Disconnect() end
		
		renderconnection = RS.RenderStepped:Connect(function()
			shiftLockWithCamera()
		end)
	else     -- Disable shift lock: unlock the mouse, reset camera offset back to default, and disconnect the render loop

		UIS.MouseIcon = "rbxassetid://"
		UIS.MouseBehavior = Enum.MouseBehavior.Default -- SO bassicly this lets u go back to free roam mouse mode after u exit shift lock. 

		--Tween Our Camera Offset
		local tg = {CameraOffset = Vector3.new(0,0,0)}
		local tween = TS:Create(char.Humanoid, TI, tg)
		tween:Play()

		if renderconnection then renderconnection:Disconnect() end
	end
end
-- sprint varibales and stuff 
local timelimit = 0.3 -- if the user presses W in this time span theyll sprint
local lastimepressed = 0 
local canSprint = true -- used for stuns and etc
local issprinting = false
local currentime = tick()
local Sprintrenderconnection

local function Camerabobbing(bool)
	-- disconnect any existing camera bob loop before starting a new one
	if Sprintrenderconnection then
		Sprintrenderconnection:Disconnect()
	end
	if not bool then return end 
	if bool then
		Sprintrenderconnection = RS.RenderStepped:Connect(function()
		local ct = tick() -- get current time for sine/cosine wave calculation

		if hum.MoveDirection.Magnitude > 0 then -- player is moving
			local bobbleX = math.cos(ct+10)*0.35 -- horizontal sway
			local bobbley = math.abs(math.sin(ct+10))*0.35 -- vertical bounce (always positive so camera bobs up not down)
			local bobble = Vector3.new(bobbleX*2, bobbley, 0.35)
			hum.CameraOffset = hum.CameraOffset:Lerp(bobble,0.35) -- smoothly interpolate to the bobble position
		else
			-- player is idle, reset camera offset back to default position
			print()
			hum.CameraOffset = hum.CameraOffset:Lerp(Vector3.new(0, 0, 0), 0.1)
		end
		end)
	end
end

local function SprintStartAuraDora()
	hum.WalkSpeed = 24
	runAnim:Play(animplaytime)
	issprinting = true
	Camerabobbing()
end
local function SprintStopAuraDora()
	hum.WalkSpeed = 16
	runAnim:Stop(animplaytime)
	issprinting = false
end
local function ResumeAndPauseSprinting() -- A use case for this is if the player is js done sliding they dont have to hold shift and W again if they never let go yk?
	if issprinting then
		Camerabobbing(true)
		hum.WalkSpeed = 24
		runAnim:Play(animplaytime)
	else
		Camerabobbing(false)
		hum.WalkSpeed = 16
		runAnim:Stop(animplaytime)
	end
end


UIS.InputBegan:Connect(function(input, gps)
    if gps then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Shiftlockenable = not Shiftlockenable  -- toggle on each Ctrl press
        TweenOffSet(Shiftlockenable)
    end
    if input.KeyCode == Enum.KeyCode.W and UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
        SprintStartAuraDora()
    end
	if input.KeyCode == Enum.KeyCode.LeftShift and UIS:IsKeyDown(Enum.KeyCode.W) then
		SprintStartAuraDora()
	end
	if Shiftlockenable then -- makes it so the custom Left or right anims only work when in shift lock
		if input.KeyCode == Enum.KeyCode.W then
		activeKeys.W = true
		-- frontwalk:Play(animplaytime) -- animplaytime makes it so it takes that many seconds for the anim to fully pkay
		end
		if input.KeyCode == Enum.KeyCode.S then
		activeKeys.S = true
		--backwalk:Play(animplaytime)
		end
		if input.KeyCode == Enum.KeyCode.D then
		activeKeys.D = true
		-- rightwalk:Play(animplaytime)
		end
		if input.KeyCode == Enum.KeyCode.A then
		activeKeys.A = true
		-- leftwalk:Play(animplaytime)
		end
	end 

	if activeKeys.A and activeKeys.D then --Used so the custom anims for right and left do play when pressed together
		-- leftwalk:Stop()
		-- rightwalk:Stop()
	elseif activeKeys.W and activeKeys.S then
		-- frontwalk:Stop()
		-- backwalk:Stop()
	end
end)

UIS.InputEnded:Connect(function(input, gps)
	if gps then return end

    if input.KeyCode == Enum.KeyCode.W and Enum.KeyCode.LeftShift then
        SprintStopAuraDora()
    end
	if input.KeyCode == Enum.KeyCode.LeftShift and Enum.KeyCode.W then
        SprintStopAuraDora()
    end
	if input.KeyCode == Enum.KeyCode.W then  --set up so when the key is let go the custom anim is stopped AND player stops running
		activeKeys.W = false
	-- frontwalk:Stop()
	end
	if input.KeyCode == Enum.KeyCode.S then	
		activeKeys.S = false
	-- backwalk:Stop()
	end
	if input.KeyCode == Enum.KeyCode.D then
		activeKeys.D = false
	-- rightwalk:Stop()
	end
	if input.KeyCode == Enum.KeyCode.A then
		activeKeys.A = false
	-- leftwalk:Stop()
	end

end)
local function landed()
	Camerabobbing(false)
	landed1:Play()
	hum.WalkSpeed = 2
	hum.JumpPower = 0	
end
landed1.Ended:Connect(function()
	hum.JumpPower = 50
	ResumeAndPauseSprinting()
end)

hum.StateChanged:Connect(function(newState, oldState)
	if newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Freefall then
		isInAir = true
	elseif newState == Enum.HumanoidStateType.Landed then
		landed()
		isInAir = false
	end	
end)

