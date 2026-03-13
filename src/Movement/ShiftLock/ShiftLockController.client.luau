local player = game:GetService("Players").LocalPlayer
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local char = player.Character or player.CharacterAdded:Wait()



local TI = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut) -- TweenInfo for smooth transitions

local renderconnection = nil --used to track the players camera
local Shiftlockenable = false --used to track if the player is shiftlocked or not

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

UIS.InputBegan:Connect(function(input, gps)
    if gps then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Shiftlockenable = not Shiftlockenable  -- toggle on each Ctrl press
        TweenOffSet(Shiftlockenable)
    end
end)