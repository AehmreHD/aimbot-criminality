local Lighting = game:GetService("Lighting")

--// Cross-Script Hot-Reload State Transfer Engine
local CurrentScriptID = "Aehmre_AimHub_v1"
local env = (getgenv and getgenv()) or shared
local SavedState = nil

local DiscordInvite = "https://discord.gg/hjjrsKJ8AA"
local AccessNoticeDismissed = false


if env[CurrentScriptID] then
	pcall(env[CurrentScriptID])
	env[CurrentScriptID] = nil
	if env[CurrentScriptID .. "_DataPacket"] then
		SavedState = env[CurrentScriptID .. "_DataPacket"]
		env[CurrentScriptID .. "_DataPacket"] = nil
	end
end

local LegacyIDs = {
	"TestEnvironmentGui",
	"TestEnv_GlobalAimSystem_v2",
	"TestEnv_GlobalAimSystem_v3",
	"TestEnv_GlobalAimSystem_v4",
	"TestEnv_ProUI_v5",
	"Ligia_Premium_UI_v6",
	"Ligia_Premium_UI_v7",
	"Ligia_Premium_UI_v8",
	"Ligia_Premium_UI_v8_Final",
	"Ligia_Premium_UI_v8_Final_v2",
	"Ligia_Premium_Engine_v9",
	"Ligia_Premium_Engine_v10",
	"Ligia_Premium_Engine_v11",
	"Ligia_Premium_Engine_v12",
	"Ligia_Premium_Engine_v13",
	"Ligia_Premium_Engine_v14",
	"Ligia_Premium_Engine_v15",
	"Ligia_Premium_Engine_v16",
	"Ligia_Premium_Engine_v17",
	"Ligia_Premium_Engine_v18",
	"Ligia_Premium_Engine_v19",
	"Ligia_Premium_Engine_v20",
	"Ligia_Premium_Engine_v21",
	"Ligia_Premium_Engine_v22",
	"Ligia_Premium_Engine_v23",
	"Ligia_Premium_Engine_v24",
	"Ligia_Premium_Engine_v25",
	"Ligia_Premium_Engine_v26",
	"Ligia_Premium_Engine_v27",
	"Ligia_Premium_Engine_v28",
	"Ligia_Premium_Engine_v29",
	"Ligia_Premium_Engine_v30",
	"Ligia_Premium_Engine_v31",
	"Ligia_Premium_Engine_v32",
	"Ligia_Premium_Engine_v33",
	"Ligia_Premium_Engine_v34",
	"Ligia_Premium_Engine_v35",
	"Ligia_Premium_Engine_v36",
	"Ligia_Premium_Engine_v37"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local IsTouchDevice = UserInputService.TouchEnabled
local HasKeyboard = UserInputService.KeyboardEnabled

pcall(function() RunService:UnbindFromRenderStep("AimLockCameraUpdate") end)
for _, id in ipairs(LegacyIDs) do
	if env[id] then pcall(env[id]) env[id] = nil end
	local oldGui = PlayerGui:FindFirstChild(id)
	if oldGui then pcall(function() oldGui:Destroy() end) end
end

local Settings = {
	Enabled = true,
	WallCheck = true,
	AutoShoot = true,
	ESPEnabled = true,
	ShowFOV = true,
	FOVPulse = true,
	TargetIndicator = true,
	Fullbright = false,
	ShowFPS = false,
	WallCheckDebug = false,
	TargetInfo = false,
	DetectPlayers = true,
	DetectNPCs = false,
	FarmEnabled = false,
	FarmAutoMoney = false,
	FarmInvisibility = false,
	FarmAntiAFK = false,
	FarmSafeESP = false,
	FarmESPTextSize = 20,
	TargetPart = "Head", 
	ShootMode = "Normal", 
	Smoothness = 15,      
	FOVRadius = 120,
	ESPTransparency = 0.4,
	MaxDistance = 1000,
	AimKey = Enum.KeyCode.B,
	ToggleUiKey = Enum.KeyCode.L,
	MenuTransparency = 0,
	BorderThickness = 1.5,
	AccentColorIndex = 1
}

local DefaultSettings = {}
for k, v in pairs(Settings) do DefaultSettings[k] = v end

if SavedState and SavedState.Settings then
	for key, value in pairs(SavedState.Settings) do
		if Settings[key] ~= nil then
			Settings[key] = value
		end
	end
end

local UIUpdaters = {}

local Aiming = false
local Target = nil
local LastLoggedTarget = nil
local LastTargetHealth = 0
local IsShooting = false
local GlobalConnections = {} 

local FireRates = {
	Normal = { press = 0.15, release = 0.15 },
	Fast   = { press = 0.06, release = 0.06 },
	Uzi    = { press = 0.01, release = 0.01 }
}

local AccentPresets = {
	Color3.fromRGB(220, 35, 45),
	Color3.fromRGB(255, 65, 75),
	Color3.fromRGB(170, 20, 30),
	Color3.fromRGB(255, 110, 110),
	Color3.fromRGB(120, 15, 20)
}

local Styles = {
	Bg = Color3.fromRGB(7, 7, 9),
	SidebarBg = Color3.fromRGB(11, 11, 14),
	Accent = AccentPresets[Settings.AccentColorIndex] or AccentPresets[1],
	CardBg = Color3.fromRGB(16, 16, 20),
	CardHover = Color3.fromRGB(26, 18, 21),
	Border = Color3.fromRGB(55, 24, 28),
	TextMain = Color3.fromRGB(245, 245, 248),
	TextDark = Color3.fromRGB(145, 145, 155)
}

local OriginalLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	GlobalShadows = Lighting.GlobalShadows
}

local function UpdateFullbright(enabled)
	if enabled then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.Ambient = Color3.new(1, 1, 1)
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
		Lighting.GlobalShadows = false
	else
		Lighting.Brightness = OriginalLighting.Brightness
		Lighting.ClockTime = OriginalLighting.ClockTime
		Lighting.Ambient = OriginalLighting.Ambient
		Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
		Lighting.GlobalShadows = OriginalLighting.GlobalShadows
	end
end

local function SafeConnect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(GlobalConnections, connection)
	return connection
end

local function TweenObj(obj, goal, duration, style, dir)
	local info = TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local tween = TweenService:Create(obj, info, goal)
	tween:Play()
	return tween
end


local Farm = (function()
	local FarmMoveSpeed = 22
	local FarmPickupDistance = 8
	local FarmIgnoreDuration = 60
	local FarmLogHook = nil
	local FarmLoopRunning = false
	local FarmAutoMoneyRunning = false
	local FarmAntiAFKConnection = nil
	local FarmInvisConnection = nil
	local FarmInvisAnimTrack = nil
	local FarmInvisOriginalTransparency = {}
	local FarmInvisParts = {}
	local FarmSafeESPRunning = false
	local FarmSafeESPElements = {}
	local FarmProcessed = {}
	local FarmTempIgnored = {}
	local FarmFolderCache = nil
	local FarmFolderLastSearch = 0
	local FarmStatus = "Idle"

	local function FarmLog(message)
		print("[Farm]", message)
		if FarmLogHook then
			FarmLogHook("Farm: " .. message)
		end
	end

	local function GetFarmCharacter()
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		return character, humanoid, hrp
	end

	local function HasFarmTool(toolName)
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		local character = LocalPlayer.Character
		return (backpack and backpack:FindFirstChild(toolName)) or (character and character:FindFirstChild(toolName))
	end

	local function EquipFarmTool(toolName)
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		local tool = backpack and backpack:FindFirstChild(toolName)
		local character, humanoid = GetFarmCharacter()
		if not tool or not character or not humanoid then return false end
		local success = pcall(function()
			humanoid:EquipTool(tool)
		end)
		if success then task.wait(0.5) end
		return success
	end

	local function FindFarmFolder()
		if FarmFolderCache and FarmFolderCache.Parent then return FarmFolderCache end
		if tick() - FarmFolderLastSearch < 2 then return nil end
		FarmFolderLastSearch = tick()
		local map = workspace:FindFirstChild("Map")
		local filter = workspace:FindFirstChild("Filter")
		local folder = (map and map:FindFirstChild("BredMakurz")) or (filter and filter:FindFirstChild("BredMakurz"))
		if not folder then
			for _, object in ipairs(workspace:GetDescendants()) do
				if object:IsA("Folder") and object.Name == "BredMakurz" then
					folder = object
					break
				end
			end
		end
		FarmFolderCache = folder
		return folder
	end

	local function IsFarmTargetAvailable(object)
		if not object or not object.Parent then return false end
		if FarmProcessed[object] then return false end
		local ignoredUntil = FarmTempIgnored[object]
		if ignoredUntil then
			if tick() < ignoredUntil then return false end
			FarmTempIgnored[object] = nil
		end
		local name = object.Name:lower()
		if not name:find("safe") and not name:find("register") then return false end
		local values = object:FindFirstChild("Values")
		local broken = values and values:FindFirstChild("Broken")
		if not broken or broken.Value then return false end
		local mainPart = object:FindFirstChild("MainPart") or object.PrimaryPart or object:FindFirstChildOfClass("BasePart")
		if not mainPart or mainPart.Position.Y < 4.8 then return false end
		return true, mainPart
	end

	local function GetNearestFarmTarget()
		local folder = FindFarmFolder()
		local _, humanoid, hrp = GetFarmCharacter()
		if not folder or not humanoid or humanoid.Health <= 0 or not hrp then return nil end
		local closestObject = nil
		local closestPart = nil
		local closestDistance = math.huge
		for _, object in ipairs(folder:GetChildren()) do
			local available, mainPart = IsFarmTargetAvailable(object)
			if available then
				local distance = (mainPart.Position - hrp.Position).Magnitude
				if distance < closestDistance then
					closestDistance = distance
					closestObject = object
					closestPart = mainPart
				end
			end
		end
		return closestObject, closestPart
	end

	local function GetFarmPositionInFront(targetPart, fromPosition)
		if not targetPart then return nil end
		local look = targetPart.CFrame.LookVector
		look = Vector3.new(look.X, 0, look.Z)
		if look.Magnitude < 0.1 then
			look = fromPosition - targetPart.Position
			look = Vector3.new(look.X, 0, look.Z)
		end
		if look.Magnitude < 0.1 then look = Vector3.new(1, 0, 0) end
		return targetPart.Position + look.Unit * 4
	end

	local function ComputeFarmPath(startPosition, endPosition)
		local presets = {
			{AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, AgentCanClimb = true, WaypointSpacing = 3},
			{AgentRadius = 1.5, AgentHeight = 5, AgentCanJump = true, AgentCanClimb = true, WaypointSpacing = 2.5},
			{AgentRadius = 2.5, AgentHeight = 6, AgentCanJump = true, AgentCanClimb = true, WaypointSpacing = 4}
		}
		for _, params in ipairs(presets) do
			local path = PathfindingService:CreatePath(params)
			local success = pcall(function()
				path:ComputeAsync(startPosition, endPosition)
			end)
			if success and path.Status == Enum.PathStatus.Success then
				return path:GetWaypoints()
			end
		end
		return nil
	end

	local function RiseFarmCharacter()
		local _, humanoid, hrp = GetFarmCharacter()
		if not humanoid or humanoid.Health <= 0 or not hrp or hrp.Position.Y >= 4.7 then return end
		local start = hrp.Position
		local target = Vector3.new(start.X, 4.8, start.Z)
		local duration = math.clamp((target - start).Magnitude / 10, 0.15, 0.8)
		local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target) * (hrp.CFrame - hrp.CFrame.Position)})
		tween:Play()
		tween.Completed:Wait()
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end

	local function MoveToFarmTarget(targetPart)
		local character, humanoid, hrp = GetFarmCharacter()
		if not character or not humanoid or humanoid.Health <= 0 or not hrp or not targetPart or not targetPart:IsA("BasePart") then return false end
		RiseFarmCharacter()
		local destination = GetFarmPositionInFront(targetPart, hrp.Position)
		if not destination then return false end
		local waypoints = ComputeFarmPath(hrp.Position, destination)
		if not waypoints then return false end
		FarmStatus = "Moving"
		for _, waypoint in ipairs(waypoints) do
			if not Settings.FarmEnabled or humanoid.Health <= 0 or not hrp.Parent then return false end
			local targetPosition = waypoint.Position + Vector3.new(0, 2.5, 0)
			local distance = (targetPosition - hrp.Position).Magnitude
			if distance > 0.2 then
				local currentRotation = hrp.CFrame - hrp.CFrame.Position
				local tween = TweenService:Create(hrp, TweenInfo.new(distance / FarmMoveSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPosition) * currentRotation})
				tween:Play()
				tween.Completed:Wait()
			end
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid.Jump = true
				task.wait(0.05)
			end
		end
		local finalPosition = destination + Vector3.new(0, 2.5, 0)
		hrp.CFrame = CFrame.new(finalPosition) * (hrp.CFrame - hrp.CFrame.Position)
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
		FarmStatus = "Idle"
		return true
	end

	local function FindCrowbarDealer()
		local map = workspace:FindFirstChild("Map")
		local shops = map and map:FindFirstChild("Shopz")
		local _, _, hrp = GetFarmCharacter()
		if not shops or not hrp then return nil end
		local closestDealer = nil
		local closestDistance = math.huge
		for _, shop in ipairs(shops:GetChildren()) do
			local stocks = shop:FindFirstChild("CurrentStocks")
			local stock = stocks and stocks:FindFirstChild("Crowbar")
			local mainPart = shop:FindFirstChild("MainPart")
			if stock and stock.Value > 0 and mainPart then
				local distance = (hrp.Position - mainPart.Position).Magnitude
				if distance < closestDistance then
					closestDistance = distance
					closestDealer = shop
				end
			end
		end
		return closestDealer
	end

	local function BuyFarmCrowbar()
		local dealer = FindCrowbarDealer()
		local mainPart = dealer and dealer:FindFirstChild("MainPart")
		if not mainPart then return false end
		FarmStatus = "Buying Crowbar"
		if not MoveToFarmTarget(mainPart) then return false end
		local events = ReplicatedStorage:FindFirstChild("Events")
		if not events then return false end
		local openRemote = events:FindFirstChild("BYZERSPROTEC")
		local buyRemote = events:FindFirstChild("SSHPRMTE1")
		if not openRemote or not buyRemote then return false end
		pcall(function()
			openRemote:FireServer(true, "shop", mainPart, "IllegalStore")
		end)
		task.wait(0.8)
		pcall(function()
			buyRemote:InvokeServer("IllegalStore", "Melees", "Crowbar", mainPart, nil, true)
		end)
		task.wait(2)
		pcall(function()
			openRemote:FireServer(false)
		end)
		task.wait(0.5)
		FarmStatus = "Idle"
		return HasFarmTool("Crowbar") ~= nil
	end

	local function HackFarmTarget(targetObject)
		if not HasFarmTool("Crowbar") and not BuyFarmCrowbar() then return false end
		if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("Crowbar") then EquipFarmTool("Crowbar") end
		local events = ReplicatedStorage:FindFirstChild("Events")
		local remote1 = events and events:FindFirstChild("XMHH.2")
		local remote2 = events and events:FindFirstChild("XMHH2.2")
		local mainPart = targetObject and (targetObject:FindFirstChild("MainPart") or targetObject.PrimaryPart)
		if not remote1 or not remote2 or not mainPart then return false end
		FarmStatus = "Opening Target"
		local startTime = tick()
		local hits = 0
		while Settings.FarmEnabled and targetObject.Parent and tick() - startTime < 25 do
			local values = targetObject:FindFirstChild("Values")
			local broken = values and values:FindFirstChild("Broken")
			if broken and broken.Value then break end
			local character = LocalPlayer.Character
			local crowbar = character and character:FindFirstChild("Crowbar")
			if not crowbar then
				EquipFarmTool("Crowbar")
				character = LocalPlayer.Character
				crowbar = character and character:FindFirstChild("Crowbar")
			end
			local arm = character and (character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand"))
			if not crowbar or not arm then return false end
			local success, result = pcall(function()
				return remote1:InvokeServer("🍞", tick(), crowbar, "DZDRRRKI", targetObject, "Register")
			end)
			if success and result then
				pcall(function()
					remote2:FireServer("🍞", tick(), crowbar, "2389ZFX34", result, false, arm, mainPart, targetObject, mainPart.Position, mainPart.Position)
				end)
				hits += 1
			end
			task.wait(hits % 4 == 0 and 0.7 or 0.4)
		end
		FarmStatus = "Idle"
		local values = targetObject:FindFirstChild("Values")
		local broken = values and values:FindFirstChild("Broken")
		return broken and broken.Value or hits > 0
	end

	local function GetMoneyNearFarmTarget(targetObject)
		local mainPart = targetObject and (targetObject:FindFirstChild("MainPart") or targetObject.PrimaryPart)
		local filter = workspace:FindFirstChild("Filter")
		local spawned = filter and filter:FindFirstChild("SpawnedBread")
		if not mainPart or not spawned then return {} end
		local result = {}
		for _, money in ipairs(spawned:GetChildren()) do
			if money:IsA("BasePart") and money.Transparency < 1 and (money.Position - mainPart.Position).Magnitude <= 25 then
				table.insert(result, money)
			end
		end
		return result
	end

	local function CollectFarmMoney(targetObject)
		local events = ReplicatedStorage:FindFirstChild("Events")
		local pickupRemote = events and events:FindFirstChild("CZDPZUS")
		if not pickupRemote then return end
		FarmStatus = "Collecting Money"
		for _, money in ipairs(GetMoneyNearFarmTarget(targetObject)) do
			if not Settings.FarmEnabled then break end
			if money.Parent and MoveToFarmTarget(money) then
				pcall(function()
					pickupRemote:FireServer(money)
				end)
				task.wait(0.2)
			end
		end
		FarmStatus = "Idle"
	end

	local function StartFarm()
		if FarmLoopRunning then return end
		FarmProcessed = {}
		FarmTempIgnored = {}
		FarmLoopRunning = true
		FarmLog("Auto farm enabled")
		task.spawn(function()
			while FarmLoopRunning and Settings.FarmEnabled do
				local character, humanoid = GetFarmCharacter()
				if not character or not humanoid or humanoid.Health <= 0 then
					FarmStatus = "Waiting for respawn"
					task.wait(2)
					continue
				end
				if not HasFarmTool("Crowbar") then
					if not BuyFarmCrowbar() then
						FarmStatus = "Crowbar unavailable"
						task.wait(4)
						continue
					end
				end
				local targetObject, targetPart = GetNearestFarmTarget()
				if not targetObject or not targetPart then
					FarmStatus = "No targets"
					task.wait(3)
					continue
				end
				if MoveToFarmTarget(targetPart) then
					if HackFarmTarget(targetObject) then
						CollectFarmMoney(targetObject)
						FarmProcessed[targetObject] = true
					else
						FarmTempIgnored[targetObject] = tick() + FarmIgnoreDuration
					end
				else
					FarmTempIgnored[targetObject] = tick() + FarmIgnoreDuration
				end
				task.wait(0.5)
			end
			FarmLoopRunning = false
			FarmStatus = "Idle"
		end)
	end

	local function StopFarm()
		Settings.FarmEnabled = false
		FarmLoopRunning = false
		FarmStatus = "Idle"
		FarmLog("Auto farm disabled")
	end

	local function StartFarmAutoMoney()
		if FarmAutoMoneyRunning then return end
		FarmAutoMoneyRunning = true
		FarmLog("Auto money enabled")
		task.spawn(function()
			while FarmAutoMoneyRunning and Settings.FarmAutoMoney do
				local filter = workspace:FindFirstChild("Filter")
				local spawned = filter and filter:FindFirstChild("SpawnedBread")
				local events = ReplicatedStorage:FindFirstChild("Events")
				local pickupRemote = events and events:FindFirstChild("CZDPZUS")
				local _, humanoid, hrp = GetFarmCharacter()
				if spawned and pickupRemote and humanoid and humanoid.Health > 0 and hrp then
					local nearest = nil
					local nearestDistance = FarmPickupDistance
					for _, money in ipairs(spawned:GetChildren()) do
						if money:IsA("BasePart") then
							local distance = (money.Position - hrp.Position).Magnitude
							if distance <= nearestDistance then
								nearest = money
								nearestDistance = distance
							end
						end
					end
					if nearest then
						pcall(function()
							pickupRemote:FireServer(nearest)
						end)
						task.wait(0.35)
					else
						task.wait(0.15)
					end
				else
					task.wait(0.4)
				end
			end
			FarmAutoMoneyRunning = false
		end)
	end

	local function StopFarmAutoMoney()
		Settings.FarmAutoMoney = false
		FarmAutoMoneyRunning = false
		FarmLog("Auto money disabled")
	end

	local function EnableFarmAntiAFK()
		if FarmAntiAFKConnection then return end
		FarmAntiAFKConnection = LocalPlayer.Idled:Connect(function()
			if not Settings.FarmAntiAFK then return end
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end)
		end)
		FarmLog("Anti-AFK enabled")
	end

	local function DisableFarmAntiAFK()
		Settings.FarmAntiAFK = false
		if FarmAntiAFKConnection then
			FarmAntiAFKConnection:Disconnect()
			FarmAntiAFKConnection = nil
		end
		FarmLog("Anti-AFK disabled")
	end

	local function CacheFarmInvisParts(character)
		FarmInvisParts = {}
		FarmInvisOriginalTransparency = {}
		if not character then return end
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				table.insert(FarmInvisParts, object)
				FarmInvisOriginalTransparency[object] = object.Transparency
			end
		end
	end

	local function LoadFarmInvisAnimation(humanoid)
		if FarmInvisAnimTrack then
			pcall(function() FarmInvisAnimTrack:Stop() end)
			FarmInvisAnimTrack = nil
		end
		if not humanoid then return end
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://215384594"
		local success, track = pcall(function()
			return humanoid:LoadAnimation(animation)
		end)
		if success then
			FarmInvisAnimTrack = track
			FarmInvisAnimTrack.Priority = Enum.AnimationPriority.Action4
		end
	end

	local function DisableFarmInvisibility()
		Settings.FarmInvisibility = false
		if FarmInvisConnection then
			FarmInvisConnection:Disconnect()
			FarmInvisConnection = nil
		end
		if FarmInvisAnimTrack then
			pcall(function() FarmInvisAnimTrack:Stop() end)
			FarmInvisAnimTrack = nil
		end
		for part, transparency in pairs(FarmInvisOriginalTransparency) do
			if part and part.Parent then part.Transparency = transparency end
		end
		FarmInvisParts = {}
		FarmInvisOriginalTransparency = {}
		local _, humanoid = GetFarmCharacter()
		if humanoid then Camera.CameraSubject = humanoid end
		FarmLog("Invisibility disabled")
	end

	local function EnableFarmInvisibility()
		if FarmInvisConnection then return end
		local character, humanoid, hrp = GetFarmCharacter()
		if not character or not humanoid or not hrp then return end
		if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
			Settings.FarmInvisibility = false
			FarmLog("Invisibility requires R6")
			return
		end
		CacheFarmInvisParts(character)
		LoadFarmInvisAnimation(humanoid)
		Camera.CameraSubject = hrp
		FarmInvisConnection = RunService.Heartbeat:Connect(function()
			if not Settings.FarmInvisibility then return end
			local currentCharacter, currentHumanoid, currentHrp = GetFarmCharacter()
			if currentCharacter ~= character then
				character = currentCharacter
				humanoid = currentHumanoid
				hrp = currentHrp
				if not character or not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 or not hrp then return end
				CacheFarmInvisParts(character)
				LoadFarmInvisAnimation(humanoid)
				Camera.CameraSubject = hrp
			end
			if not humanoid or humanoid.Health <= 0 or not hrp then return end
			if FarmInvisAnimTrack then
				pcall(function()
					if not FarmInvisAnimTrack.IsPlaying then FarmInvisAnimTrack:Play() end
					FarmInvisAnimTrack:AdjustSpeed(0)
					FarmInvisAnimTrack.TimePosition = 0.3
				end)
			end
			for _, part in ipairs(FarmInvisParts) do
				if part and part.Parent and part.Transparency < 1 then part.Transparency = 0.5 end
			end
		end)
		FarmLog("Invisibility enabled")
	end

	local function ClearFarmSafeESP()
		for object, data in pairs(FarmSafeESPElements) do
			pcall(function()
				if data.billboard then data.billboard:Destroy() end
				if data.highlight then data.highlight:Destroy() end
			end)
			FarmSafeESPElements[object] = nil
		end
	end

	local function UpdateFarmSafeESP()
		local folder = FindFarmFolder()
		if not folder then return end
		for _, object in ipairs(folder:GetChildren()) do
			local name = object.Name:lower()
			if name:find("safe") or name:find("register") then
				local mainPart = object:FindFirstChild("MainPart") or object.PrimaryPart or object:FindFirstChildOfClass("BasePart")
				if mainPart and mainPart.Position.Y >= 4.8 then
					local values = object:FindFirstChild("Values")
					local broken = values and values:FindFirstChild("Broken")
					local isBroken = broken and broken.Value or false
					local color = isBroken and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
					local data = FarmSafeESPElements[object]
					if not data then
						local billboard = Instance.new("BillboardGui")
						billboard.Name = "AehmreFarmESP_Billboard"
						billboard.Adornee = mainPart
						billboard.Size = UDim2.new(0, 200, 0, 50)
						billboard.StudsOffset = Vector3.new(0, 4, 0)
						billboard.AlwaysOnTop = true
						billboard.MaxDistance = 1000
						billboard.Parent = object
						local label = Instance.new("TextLabel", billboard)
						label.Size = UDim2.new(1, 0, 1, 0)
						label.BackgroundTransparency = 1
						label.Font = Enum.Font.SourceSansBold
						label.Text = object.Name
						label.TextStrokeTransparency = 0
						label.TextStrokeColor3 = Color3.new(0, 0, 0)
						local highlight = Instance.new("Highlight")
						highlight.Name = "AehmreFarmESP_Highlight"
						highlight.Adornee = object
						highlight.FillTransparency = 0.5
						highlight.OutlineColor = Color3.new(1, 1, 1)
						highlight.OutlineTransparency = 0
						highlight.Parent = object
						data = {billboard = billboard, label = label, highlight = highlight}
						FarmSafeESPElements[object] = data
					end
					data.label.TextSize = Settings.FarmESPTextSize
					data.label.TextColor3 = color
					data.highlight.FillColor = color
				end
			end
		end
		for object, data in pairs(FarmSafeESPElements) do
			if not object or not object.Parent then
				pcall(function()
					if data.billboard then data.billboard:Destroy() end
					if data.highlight then data.highlight:Destroy() end
				end)
				FarmSafeESPElements[object] = nil
			end
		end
	end

	local function EnableFarmSafeESP()
		if FarmSafeESPRunning then return end
		FarmSafeESPRunning = true
		FarmLog("Safe/Register ESP enabled")
		task.spawn(function()
			while FarmSafeESPRunning and Settings.FarmSafeESP do
				UpdateFarmSafeESP()
				task.wait(0.4)
			end
			FarmSafeESPRunning = false
		end)
	end

	local function DisableFarmSafeESP()
		Settings.FarmSafeESP = false
		FarmSafeESPRunning = false
		ClearFarmSafeESP()
		FarmLog("Safe/Register ESP disabled")
	end

	local function Farm.Cleanup()
		FarmLoopRunning = false
		FarmAutoMoneyRunning = false
		FarmSafeESPRunning = false
		Settings.FarmEnabled = false
		Settings.FarmAutoMoney = false
		Settings.FarmSafeESP = false
		DisableFarmAntiAFK()
		DisableFarmInvisibility()
		ClearFarmSafeESP()
	end

	return {
		Start = StartFarm,
		Stop = StopFarm,
		StartAutoMoney = StartFarmAutoMoney,
		StopAutoMoney = StopFarmAutoMoney,
		EnableAntiAFK = EnableFarmAntiAFK,
		DisableAntiAFK = DisableFarmAntiAFK,
		EnableInvisibility = EnableFarmInvisibility,
		DisableInvisibility = DisableFarmInvisibility,
		EnableSafeESP = EnableFarmSafeESP,
		DisableSafeESP = DisableFarmSafeESP,
		Cleanup = FarmCleanup,
		SetLogHook = function(callback)
			FarmLogHook = callback
		end
	}
end)()

--// Drawing Vector FOV Crosshair & Target Indicator Framework
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Styles.Accent
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Visible = false

local TargetDot = Drawing.new("Circle")
TargetDot.Color = Styles.Accent
TargetDot.Thickness = 1
TargetDot.Filled = true
TargetDot.Radius = 4
TargetDot.Visible = false
TargetDot.ZIndex = 2

local FPSDisplay = Drawing.new("Text")
FPSDisplay.Text = "FPS: 0"
FPSDisplay.Size = 16
FPSDisplay.Position = Vector2.new(12, 12)
FPSDisplay.Color = Styles.Accent
FPSDisplay.Outline = true
FPSDisplay.Visible = false
FPSDisplay.ZIndex = 3

local WallDebugLine = Drawing.new("Line")
WallDebugLine.Thickness = 2
WallDebugLine.Color = Color3.fromRGB(80, 255, 120)
WallDebugLine.Visible = false
WallDebugLine.ZIndex = 3

local TargetInfoText = Drawing.new("Text")
TargetInfoText.Size = 14
TargetInfoText.Color = Styles.Accent
TargetInfoText.Outline = true
TargetInfoText.Visible = false
TargetInfoText.ZIndex = 3

local FPSUpdateTimer = 0
local DebugInfoTimer = 0
local DebugTargetRefreshTimer = 0
local TargetBlocked = false
local DebugTargetPart = nil
local DebugTargetBlocked = false
local AimFOVColor = Color3.fromRGB(0, 160, 255)
local FOVPulseSpeed = 6
local FOVSizePulseAmount = 8

local TrackedNPCs = {}

local function IsNPCModel(model)
	if not model or not model:IsA("Model") then return false end
	if model == LocalPlayer.Character then return false end
	if Players:GetPlayerFromCharacter(model) then return false end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end

	return true
end

local function GetCharacterRoot(character)
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
end

local function WispAllESPRemnants()
	for _, object in ipairs(workspace:GetDescendants()) do
		if object:IsA("Highlight") and (object.Name == "TestESP_Highlight" or object.Name == "Ligia_Premium_ESP") then
			pcall(function() object:Destroy() end)
		end
	end
end

local function UpdateCharacterESP(character, color, allowed)
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local highlight = character:FindFirstChild("TestESP_Highlight")
	local shouldShow = AccessNoticeDismissed and Settings.Enabled and Settings.ESPEnabled and allowed and humanoid and humanoid.Health > 0

	if shouldShow then
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "TestESP_Highlight"
			highlight.OutlineTransparency = 0.2
			highlight.Parent = character
		end

		if highlight.FillTransparency ~= Settings.ESPTransparency then
			highlight.FillTransparency = Settings.ESPTransparency
		end

		if highlight.FillColor ~= color then
			highlight.FillColor = color
		end

		if highlight.OutlineColor ~= color then
			highlight.OutlineColor = color
		end
	elseif highlight then
		highlight:Destroy()
	end
end

local function UpdatePlayerESP(player)
	if player == LocalPlayer then return end

	local character = player.Character
	if not character then return end

	local color = player.TeamColor and player.TeamColor.Color or Styles.Accent
	UpdateCharacterESP(character, color, Settings.DetectPlayers)
end

local function UpdateNPCESP(model)
	if not model then return end

	if not IsNPCModel(model) then
		local highlight = model:FindFirstChild("TestESP_Highlight")
		if highlight then highlight:Destroy() end
		return
	end

	UpdateCharacterESP(model, Styles.Accent, Settings.DetectNPCs)
end

local function SetupESPPlayer(player)
	if player == LocalPlayer then return end

	local function CharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not humanoid then return end

		UpdatePlayerESP(player)

		SafeConnect(humanoid.HealthChanged, function()
			UpdatePlayerESP(player)
		end)
	end

	if player.Character then
		task.spawn(CharacterAdded, player.Character)
	end

	SafeConnect(player.CharacterAdded, CharacterAdded)

	SafeConnect(player:GetPropertyChangedSignal("TeamColor"), function()
		UpdatePlayerESP(player)
	end)
end

local function RegisterNPC(model)
	if not IsNPCModel(model) or TrackedNPCs[model] then return end

	TrackedNPCs[model] = true

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		SafeConnect(humanoid.HealthChanged, function()
			UpdateNPCESP(model)
		end)
	end

	SafeConnect(model.AncestryChanged, function(_, parent)
		if not parent then
			TrackedNPCs[model] = nil
		end
	end)

	UpdateNPCESP(model)
end

local function TryRegisterNPCFromInstance(instance)
	local model = nil

	if instance:IsA("Model") then
		model = instance
	else
		model = instance:FindFirstAncestorOfClass("Model")
	end

	if model then
		RegisterNPC(model)
	end
end

local function RefreshAllESP()
	for _, player in ipairs(Players:GetPlayers()) do
		UpdatePlayerESP(player)
	end

	for model in pairs(TrackedNPCs) do
		if model.Parent then
			UpdateNPCESP(model)
		else
			TrackedNPCs[model] = nil
		end
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	SetupESPPlayer(player)
end

for _, descendant in ipairs(workspace:GetDescendants()) do
	if descendant:IsA("Humanoid") then
		TryRegisterNPCFromInstance(descendant)
	end
end

SafeConnect(Players.PlayerAdded, SetupESPPlayer)

SafeConnect(workspace.DescendantAdded, function(descendant)
	if descendant:IsA("Humanoid") or descendant.Name == "HumanoidRootPart" or descendant.Name == "UpperTorso" or descendant.Name == "Torso" then
		task.defer(TryRegisterNPCFromInstance, descendant)
	end
end)

local function ControlClick(press)
	if press then
		if mouse1press then mouse1press() 
		elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate() end
	else
		if mouse1release then mouse1release() 
		elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then LocalPlayer.Character:FindFirstChildOfClass("Tool"):Deactivate() end
	end
end

--// Structural Execution Lifecycle Cleanup Core
local function UniversalDestruct()
	pcall(function() RunService:UnbindFromRenderStep("AimLockCameraUpdate") end)
	for _, con in ipairs(GlobalConnections) do if con and con.Disconnect then pcall(function() con:Disconnect() end) end end
	ControlClick(false)
	pcall(function() FOVCircle:Remove() end)
	pcall(function() TargetDot:Remove() end)
	pcall(function()
		local OldGui = PlayerGui:FindFirstChild(CurrentScriptID)
		if OldGui then OldGui:Destroy() end
	end)
	pcall(function() FPSDisplay:Remove() end)
	pcall(function() WallDebugLine:Remove() end)
	pcall(function() TargetInfoText:Remove() end)
	UpdateFullbright(false)
	Farm.Cleanup()
	WispAllESPRemnants()
end
env[CurrentScriptID] = UniversalDestruct 

local AimRaycastParams = RaycastParams.new()
AimRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
AimRaycastParams.IgnoreWater = true

local RaycastIgnore = table.create(2)

local function GetTargetPart(character)
	if Settings.TargetPart == "Torso" then
		return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("HumanoidRootPart")
	end

	return character:FindFirstChild(Settings.TargetPart) or character:FindFirstChild("HumanoidRootPart")
end

local function IsEnemy(player)
	if player == LocalPlayer then return false end

	if LocalPlayer.Team and player.Team then
		return player.Team ~= LocalPlayer.Team
	end

	return true
end

local function GetTargetCharacter(target)
	if not target or typeof(target) ~= "Instance" then return nil end

	if target:IsA("Player") then
		return target.Character
	end

	if target:IsA("Model") then
		return target
	end

	return nil
end

local function GetTargetDisplayName(target)
	if not target or typeof(target) ~= "Instance" then
		return "Unknown"
	end

	if target:IsA("Player") then
		return target.DisplayName
	end

	return target.Name
end

local function IsTargetTypeEnabled(target)
	if not target or typeof(target) ~= "Instance" then return false end

	if target:IsA("Player") then
		return Settings.DetectPlayers and IsEnemy(target)
	end

	if target:IsA("Model") then
		return Settings.DetectNPCs and IsNPCModel(target)
	end

	return false
end

local function HasLineOfSight(character, targetPart)
	local localCharacter = LocalPlayer.Character
	if not localCharacter then return false end

	RaycastIgnore[1] = localCharacter
	RaycastIgnore[2] = character
	AimRaycastParams.FilterDescendantsInstances = RaycastIgnore

	local origin = Camera.CFrame.Position
	local direction = targetPart.Position - origin
	local result = workspace:Raycast(origin, direction, AimRaycastParams)

	return result == nil
end

local function IsTargetVisible(character, targetPart)
	if not Settings.WallCheck then return true end
	return HasLineOfSight(character, targetPart)
end

local function GetAimScreenPosition()
	if IsTouchDevice then
		local viewport = Camera.ViewportSize
		return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	end

	return UserInputService:GetMouseLocation()
end

local function GetClosestTarget()
	local localCharacter = LocalPlayer.Character
	if not localCharacter then return nil end

	local localRoot = GetCharacterRoot(localCharacter)
	if not localRoot then return nil end

	local aimPosition = GetAimScreenPosition()
	local closestTarget = nil
	local closestScreenDistance = Settings.FOVRadius
	local closestDebugDistance = Settings.FOVRadius

	DebugTargetPart = nil
	DebugTargetBlocked = false

	local function EvaluateTarget(target, character)
		if not target or not character or not IsTargetTypeEnabled(target) then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = GetCharacterRoot(character)
		local targetPart = GetTargetPart(character)

		if not humanoid or humanoid.Health <= 0 or not root or not targetPart then return end

		local worldDistance = (root.Position - localRoot.Position).Magnitude
		if worldDistance > Settings.MaxDistance then return end

		local screenPosition, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
		if not onScreen or screenPosition.Z <= 0 then return end

		local targetScreenPosition = Vector2.new(screenPosition.X, screenPosition.Y)
		local screenDistance = (targetScreenPosition - aimPosition).Magnitude

		if screenDistance > Settings.FOVRadius then return end

		local hasLineOfSight = HasLineOfSight(character, targetPart)
		local visible = not Settings.WallCheck or hasLineOfSight

		if screenDistance < closestDebugDistance then
			closestDebugDistance = screenDistance
			DebugTargetPart = targetPart
			DebugTargetBlocked = not hasLineOfSight
		end

		if not visible or screenDistance >= closestScreenDistance then return end

		closestScreenDistance = screenDistance
		closestTarget = target
	end

	if Settings.DetectPlayers then
		for _, player in ipairs(Players:GetPlayers()) do
			if IsEnemy(player) then
				EvaluateTarget(player, player.Character)
			end
		end
	end

	if Settings.DetectNPCs then
		for model in pairs(TrackedNPCs) do
			if model.Parent then
				EvaluateTarget(model, model)
			else
				TrackedNPCs[model] = nil
			end
		end
	end

	return closestTarget
end

local function IsTargetValid(target)
	if not target or not IsTargetTypeEnabled(target) then return false end

	local localCharacter = LocalPlayer.Character
	local character = GetTargetCharacter(target)

	if not localCharacter or not character then return false end

	local localRoot = GetCharacterRoot(localCharacter)
	local root = GetCharacterRoot(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local targetPart = GetTargetPart(character)

	if not localRoot or not root or not humanoid or humanoid.Health <= 0 or not targetPart then
		return false
	end

	local worldDistance = (root.Position - localRoot.Position).Magnitude
	if worldDistance > Settings.MaxDistance then return false end

	local screenPosition, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
	if not onScreen or screenPosition.Z <= 0 then return false end

	local aimPosition = GetAimScreenPosition()
	local targetScreenPosition = Vector2.new(screenPosition.X, screenPosition.Y)
	local screenDistance = (targetScreenPosition - aimPosition).Magnitude

	if screenDistance > Settings.FOVRadius then return false end
	if not IsTargetVisible(character, targetPart) then return false end

	return true
end

-- Temporary logger hook (defined completely lower down, stubbed here)
local SystemLogEvent = function(msg) end

--// Protected Render Loop Connection Array
RunService:BindToRenderStep("AimLockCameraUpdate", Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
	pcall(function()
		deltaTime = deltaTime or 0.016 

		FPSUpdateTimer += deltaTime
		DebugInfoTimer += deltaTime
		DebugTargetRefreshTimer += deltaTime

		if Settings.WallCheckDebug and DebugTargetRefreshTimer >= 0.1 then
			GetClosestTarget()
			DebugTargetRefreshTimer = 0
		end

		if AccessNoticeDismissed and Settings.ShowFPS then
			if FPSUpdateTimer >= 0.25 then
				FPSDisplay.Text = "FPS: " .. tostring(math.floor((1 / deltaTime) + 0.5))
				FPSUpdateTimer = 0
			end

			FPSDisplay.Visible = true
		else
			FPSDisplay.Visible = false
		end

		FOVCircle.Position = GetAimScreenPosition()

		if AccessNoticeDismissed and Settings.Enabled and Aiming then
			FOVCircle.Color = AimFOVColor

			if Settings.FOVPulse then
				local pulse = math.sin(time() * FOVPulseSpeed)

				FOVCircle.Radius = Settings.FOVRadius + pulse * FOVSizePulseAmount
				FOVCircle.Transparency = 0.65 + pulse * 0.35
			else
				FOVCircle.Radius = Settings.FOVRadius
				FOVCircle.Transparency = 1
			end
		else
			FOVCircle.Color = Styles.Accent
			FOVCircle.Radius = Settings.FOVRadius
			FOVCircle.Transparency = 1
		end

		FOVCircle.Visible = AccessNoticeDismissed and Settings.Enabled and Settings.ShowFOV

		if AccessNoticeDismissed and Settings.Enabled and Aiming then
			TargetBlocked = false

			if not IsTargetValid(Target) then
				Target = GetClosestTarget()
			end

			if Settings.WallCheckDebug and DebugTargetPart then
				local debugPos, debugOnScreen = Camera:WorldToScreenPoint(DebugTargetPart.Position)

				if debugOnScreen and debugPos.Z > 0 then
					local mousePosition = GetAimScreenPosition()

					WallDebugLine.From = mousePosition
					WallDebugLine.To = Vector2.new(debugPos.X, debugPos.Y)
					WallDebugLine.Color = DebugTargetBlocked and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 255, 120)
					WallDebugLine.Visible = true
				else
					WallDebugLine.Visible = false
				end
			else
				WallDebugLine.Visible = false
			end

			local TargetCharacter = GetTargetCharacter(Target)

			if Target and TargetCharacter then
				local HitPart = GetTargetPart(TargetCharacter)
				if HitPart then
					-- NEW: Draw Target Indicator Module
					local pos, onScreen = Camera:WorldToScreenPoint(HitPart.Position)

					if Settings.TargetInfo and onScreen then
						TargetInfoText.Position = Vector2.new(pos.X + 12, pos.Y + 12)
						TargetInfoText.Visible = true

						if DebugInfoTimer >= 0.1 then
							local humanoid = TargetCharacter:FindFirstChildOfClass("Humanoid")
							local root = GetCharacterRoot(TargetCharacter)
							local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

							local health = humanoid and math.floor(humanoid.Health) or 0
							local distance = root and localRoot and math.floor((root.Position - localRoot.Position).Magnitude) or 0

							TargetInfoText.Text = string.format(
								"%s\nHP: %d\nDistance: %d studs\nPart: %s",
								GetTargetDisplayName(Target),
								health,
								distance,
								Settings.TargetPart
							)

							DebugInfoTimer = 0
						end
					else
						TargetInfoText.Visible = false
					end

					if Settings.TargetIndicator then
						local pos, onScreen = Camera:WorldToScreenPoint(HitPart.Position)

						if onScreen then
							TargetDot.Position = Vector2.new(pos.X, pos.Y)
							TargetDot.Visible = true
						else
							TargetDot.Visible = false
						end
					else
						TargetDot.Visible = false
					end

					-- NEW: Kill Feed Logger Hooks
					if Target ~= LastLoggedTarget then
						SystemLogEvent("Acquired Target Lock: " .. GetTargetDisplayName(Target))
						LastLoggedTarget = Target
					end

					local currentHp = TargetCharacter:FindFirstChildOfClass("Humanoid") and TargetCharacter:FindFirstChildOfClass("Humanoid").Health or 0
					if currentHp <= 0 and LastTargetHealth > 0 then
						SystemLogEvent("Target Eliminated: " .. GetTargetDisplayName(Target))
						LastLoggedTarget = nil 
					end
					LastTargetHealth = currentHp

					local TargetLook = CFrame.lookAt(Camera.CFrame.Position, HitPart.Position)
					local rawSmoothness = math.clamp(Settings.Smoothness / 100, 0.001, 1)
					local fpsAdjustedAlpha = 1 - math.pow(1 - rawSmoothness, deltaTime * 60)
					Camera.CFrame = Camera.CFrame:Lerp(TargetLook, fpsAdjustedAlpha)

					if Settings.AutoShoot and not IsShooting then
						IsShooting = true
						task.spawn(function()
							local rate = FireRates[Settings.ShootMode] or FireRates.Normal
							while Aiming and Target and Settings.AutoShoot do
								ControlClick(true)
								task.wait(rate.press)
								if not (Aiming and Target and Settings.AutoShoot) then break end
								ControlClick(false)
								task.wait(rate.release)
							end
							ControlClick(false)
							IsShooting = false
						end)
					end
				end
			else
				TargetDot.Visible = false
				TargetInfoText.Visible = false
				if IsShooting then IsShooting = false ControlClick(false) end
			end
		else
			Target = nil
			WallDebugLine.Visible = false
			TargetInfoText.Visible = false
			TargetDot.Visible = false
			LastLoggedTarget = nil
			if IsShooting then IsShooting = false ControlClick(false) end
		end
	end)
end)

--// UI Allocation Elements
local MainMenuUI = nil
local ShortcutList = nil
local KeybindCapture = nil
local KeybindValueButtons = {}
local MobileControls = nil
local MobileAimButton = nil
local MobileMenuButton = nil
local MainUIScale = nil
local AuthUIScale = nil

local function GetKeybindName(keyCode)
	if not keyCode or keyCode == Enum.KeyCode.Unknown then
		return "NONE"
	end

	return keyCode.Name
end

local function UpdateKeybindValueButtons()
	for configKey, button in pairs(KeybindValueButtons) do
		if button then
			if IsTouchDevice and not HasKeyboard then
				button.Text = "PC ONLY"
			else
				button.Text = GetKeybindName(Settings[configKey])
			end
		end
	end
end

local function UpdateMobileControlButtons()
	if MobileAimButton then
		MobileAimButton.Text = Aiming and "AIM\nON" or "AIM\nOFF"
		MobileAimButton.BackgroundColor3 = Aiming and Styles.Accent or Color3.fromRGB(30, 32, 40)
		MobileAimButton.TextColor3 = Aiming and Color3.fromRGB(10, 10, 12) or Styles.TextMain
	end

	if MobileMenuButton then
		MobileMenuButton.Text = MainMenuUI and MainMenuUI.Visible and "HIDE\nUI" or "SHOW\nUI"
	end
end

local function UpdateLeftPanelShortcuts()
	if ShortcutList then
		local statusText = Aiming and "ON" or "OFF"

		if IsTouchDevice then
			ShortcutList.Text = string.format("[TOUCH] Aim Lock: %s\n[TOUCH] Toggle UI", statusText)
		else
			ShortcutList.Text = string.format(
				"[%s] Aim Lock: %s\n[%s] Toggle UI",
				GetKeybindName(Settings.AimKey),
				statusText,
				GetKeybindName(Settings.ToggleUiKey)
			)
		end
	end

	UpdateMobileControlButtons()
end

local function ToggleAiming()
	if not AccessNoticeDismissed or not Settings.Enabled then return end

	Aiming = not Aiming

	if not Aiming then
		ControlClick(false)
	end

	UpdateLeftPanelShortcuts()
end

local function ToggleMainMenu()
	if not AccessNoticeDismissed or not MainMenuUI then return end

	if IsTouchDevice then
		MainMenuUI.Visible = not MainMenuUI.Visible
		UpdateMobileControlButtons()
		return
	end

	local isVis = MainMenuUI.Size.Y.Offset > 40
	local container = MainMenuUI:FindFirstChild("WindowContainerFrame")

	if container then
		if isVis then
			TweenObj(MainMenuUI, { Size = UDim2.new(0, 540, 0, 40) }, 0.4, Enum.EasingStyle.Quint)
			container.Visible = false
		else
			container.Visible = true
			TweenObj(MainMenuUI, { Size = UDim2.new(0, 540, 0, 415) }, 0.4, Enum.EasingStyle.Quint)
		end
	end
end

local function HookButtonAnimations(btn, baseColor, hoverColor)
	local uiScale = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", btn)
	uiScale.Scale = 1

	btn.MouseEnter:Connect(function() TweenObj(btn, { BackgroundColor3 = hoverColor }, 0.2) end)
	btn.MouseLeave:Connect(function()
		TweenObj(btn, { BackgroundColor3 = baseColor }, 0.2)
		TweenObj(uiScale, { Scale = 1 }, 0.2)
	end)
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			TweenObj(uiScale, { Scale = 0.94 }, 0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	end)
	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			TweenObj(uiScale, { Scale = 1 }, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	end)
end

SafeConnect(UserInputService.InputBegan, function(input, processed)
	if KeybindCapture then
		if input.UserInputType ~= Enum.UserInputType.Keyboard or input.KeyCode == Enum.KeyCode.Unknown then
			return
		end

		local capture = KeybindCapture
		KeybindCapture = nil

		if input.KeyCode == Enum.KeyCode.Escape then
			UpdateKeybindValueButtons()
			return
		end

		local configKey = capture.ConfigKey
		local otherConfigKey = configKey == "AimKey" and "ToggleUiKey" or "AimKey"
		local previousKey = Settings[configKey]

		if Settings[otherConfigKey] == input.KeyCode then
			Settings[otherConfigKey] = previousKey
		end

		Settings[configKey] = input.KeyCode
		UpdateKeybindValueButtons()
		UpdateLeftPanelShortcuts()
		SystemLogEvent(string.format("%s changed to %s.", capture.DisplayName, GetKeybindName(input.KeyCode)))
		return
	end

	if processed then return end

	if AccessNoticeDismissed and input.KeyCode == Settings.AimKey then
		ToggleAiming()
	end

	if AccessNoticeDismissed and input.KeyCode == Settings.ToggleUiKey then
		ToggleMainMenu()
	end
end)

--// Structural Premium Interface Generation Layer
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = CurrentScriptID
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Styles.Bg
MainFrame.BackgroundTransparency = Settings.MenuTransparency
MainFrame.BorderSizePixel = 0
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 540, 0, 415)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
MainMenuUI = MainFrame

MainUIScale = Instance.new("UIScale", MainFrame)

MobileControls = Instance.new("Frame", ScreenGui)
MobileControls.Name = "MobileControls"
MobileControls.Size = UDim2.new(0, 64, 0, 146)
MobileControls.Position = UDim2.new(1, -76, 0.5, -73)
MobileControls.BackgroundTransparency = 1
MobileControls.Visible = false
MobileControls.ZIndex = 50
MobileControls.Active = true

local MobileDragHandle = Instance.new("TextButton", MobileControls)
MobileDragHandle.Size = UDim2.new(0, 60, 0, 18)
MobileDragHandle.Position = UDim2.new(0, 2, 0, 0)
MobileDragHandle.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
MobileDragHandle.BorderSizePixel = 0
MobileDragHandle.Text = "≡"
MobileDragHandle.TextColor3 = Styles.TextDark
MobileDragHandle.TextSize = 14
MobileDragHandle.Font = Enum.Font.GothamBold
MobileDragHandle.AutoButtonColor = false
MobileDragHandle.ZIndex = 51
Instance.new("UICorner", MobileDragHandle).CornerRadius = UDim.new(0, 7)

MobileAimButton = Instance.new("TextButton", MobileControls)
MobileAimButton.Size = UDim2.new(0, 60, 0, 56)
MobileAimButton.Position = UDim2.new(0, 2, 0, 24)
MobileAimButton.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
MobileAimButton.BorderSizePixel = 0
MobileAimButton.Text = "AIM\nOFF"
MobileAimButton.TextColor3 = Styles.TextMain
MobileAimButton.TextSize = 11
MobileAimButton.Font = Enum.Font.GothamBold
MobileAimButton.AutoButtonColor = false
MobileAimButton.ZIndex = 51
Instance.new("UICorner", MobileAimButton).CornerRadius = UDim.new(0, 10)

local MobileAimStroke = Instance.new("UIStroke", MobileAimButton)
MobileAimStroke.Color = Styles.Accent
MobileAimStroke.Thickness = 1.5

MobileMenuButton = Instance.new("TextButton", MobileControls)
MobileMenuButton.Size = UDim2.new(0, 60, 0, 56)
MobileMenuButton.Position = UDim2.new(0, 2, 0, 90)
MobileMenuButton.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
MobileMenuButton.BorderSizePixel = 0
MobileMenuButton.Text = "SHOW\nUI"
MobileMenuButton.TextColor3 = Styles.TextMain
MobileMenuButton.TextSize = 10
MobileMenuButton.Font = Enum.Font.GothamBold
MobileMenuButton.AutoButtonColor = false
MobileMenuButton.ZIndex = 51
Instance.new("UICorner", MobileMenuButton).CornerRadius = UDim.new(0, 10)

local MobileMenuStroke = Instance.new("UIStroke", MobileMenuButton)
MobileMenuStroke.Color = Styles.Border
MobileMenuStroke.Thickness = 1.5

HookButtonAnimations(MobileAimButton, Color3.fromRGB(30, 32, 40), Styles.CardHover)
HookButtonAnimations(MobileMenuButton, Color3.fromRGB(30, 32, 40), Styles.CardHover)

MobileAimButton.Activated:Connect(function()
	ToggleAiming()
end)

MobileMenuButton.Activated:Connect(function()
	ToggleMainMenu()
end)

local mobileDragging = false
local mobileDragInput = nil
local mobileDragStart = nil
local mobileStartPosition = nil

MobileDragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		mobileDragging = true
		mobileDragStart = input.Position
		mobileStartPosition = MobileControls.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				mobileDragging = false
			end
		end)
	end
end)

MobileDragHandle.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		mobileDragInput = input
	end
end)

SafeConnect(UserInputService.InputChanged, function(input)
	if input == mobileDragInput and mobileDragging then
		local delta = input.Position - mobileDragStart
		MobileControls.Position = UDim2.new(
			mobileStartPosition.X.Scale,
			mobileStartPosition.X.Offset + delta.X,
			mobileStartPosition.Y.Scale,
			mobileStartPosition.Y.Offset + delta.Y
		)
	end
end)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = Settings.BorderThickness
MainStroke.Color = Styles.Border
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local HeaderBar = Instance.new("Frame", MainFrame)
HeaderBar.Name = "HeaderBar"
HeaderBar.Size = UDim2.new(1, 0, 0, 40)
HeaderBar.BackgroundColor3 = Styles.SidebarBg
HeaderBar.BackgroundTransparency = Settings.MenuTransparency
HeaderBar.BorderSizePixel = 0

local dragging, dragInput, dragStart, startPos
local targetPos = MainFrame.Position

HeaderBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true 
		dragStart = input.Position 
		startPos = MainFrame.Position
		targetPos = startPos
		input.Changed:Connect(function() 
			if input.UserInputState == Enum.UserInputState.End then dragging = false end 
		end)
	end
end)

HeaderBar.InputChanged:Connect(function(input) 
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end 
end)

SafeConnect(UserInputService.InputChanged, function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

SafeConnect(RunService.RenderStepped, function(dt)
	if MainFrame.Position ~= targetPos then MainFrame.Position = MainFrame.Position:Lerp(targetPos, math.clamp(dt * 12, 0, 1)) end
end)

local Title = Instance.new("TextLabel", HeaderBar)
Title.Size = UDim2.new(0.3, 0, 1, 0)
Title.Position = UDim2.new(0.03, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Styles.TextMain
Title.Text = "Aehmre's Aimbot Hub"
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", HeaderBar)
SubTitle.Name = "CreatorTag"
SubTitle.Size = UDim2.new(0.4, 0, 1, 0)
SubTitle.Position = UDim2.new(0.32, 0, 0, 0) 
SubTitle.BackgroundTransparency = 1
SubTitle.TextColor3 = Styles.Accent
SubTitle.Text = "Made by @Emre_31er"
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.Arimo
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local HeaderControlSize = IsTouchDevice and 30 or 20
local HeaderControlHalf = HeaderControlSize * 0.5

local CloseBtn = Instance.new("TextButton", HeaderBar)
CloseBtn.Size = UDim2.new(0, HeaderControlSize, 0, HeaderControlSize)
CloseBtn.Position = UDim2.new(1, -(IsTouchDevice and 36 or 26), 0.5, -HeaderControlHalf)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
CloseBtn.TextColor3 = Color3.fromRGB(240, 90, 90)
CloseBtn.Text = "X" 
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
HookButtonAnimations(CloseBtn, Color3.fromRGB(40, 20, 25), Color3.fromRGB(60, 25, 32))

local MinimizeBtn = Instance.new("TextButton", HeaderBar)
MinimizeBtn.Size = UDim2.new(0, HeaderControlSize, 0, HeaderControlSize)
MinimizeBtn.Position = UDim2.new(1, -(IsTouchDevice and 72 or 52), 0.5, -HeaderControlHalf)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
MinimizeBtn.TextColor3 = Styles.TextDark
MinimizeBtn.Text = "—"
MinimizeBtn.TextSize = 9
MinimizeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 5)
HookButtonAnimations(MinimizeBtn, Color3.fromRGB(30, 32, 40), Color3.fromRGB(42, 45, 56))

local WindowContainerFrame = Instance.new("Frame", MainFrame)
WindowContainerFrame.Name = "WindowContainerFrame"
WindowContainerFrame.Size = UDim2.new(1, 0, 1, -40)
WindowContainerFrame.Position = UDim2.new(0, 0, 0, 40)
WindowContainerFrame.BackgroundTransparency = 1

local Sidebar = Instance.new("Frame", WindowContainerFrame)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 165, 1, 0)
Sidebar.BackgroundColor3 = Styles.SidebarBg
Sidebar.BackgroundTransparency = Settings.MenuTransparency
Sidebar.BorderSizePixel = 0

local SidebarContainer = Instance.new("ScrollingFrame", Sidebar)
SidebarContainer.Size = UDim2.new(1, 0, 1, -170)
SidebarContainer.Position = UDim2.new(0, 0, 0, 60)
SidebarContainer.BackgroundTransparency = 1
SidebarContainer.BorderSizePixel = 0
SidebarContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
SidebarContainer.ScrollBarThickness = 2
SidebarContainer.ScrollBarImageColor3 = Styles.Accent
SidebarContainer.ScrollingDirection = Enum.ScrollingDirection.Y
SidebarContainer.ClipsDescendants = true

local ProfileContainer = Instance.new("Frame", Sidebar)
ProfileContainer.Size = UDim2.new(1, 0, 0, 60)
ProfileContainer.BackgroundTransparency = 1

local DummyAvatar = Instance.new("ImageLabel", ProfileContainer)
DummyAvatar.Size = UDim2.new(0, 34, 0, 34)
DummyAvatar.Position = UDim2.new(0.08, 0, 0.5, -17)
DummyAvatar.BackgroundColor3 = Color3.fromRGB(35, 36, 45)
DummyAvatar.BorderSizePixel = 0
DummyAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", DummyAvatar).CornerRadius = UDim.new(1, 0)

local DevName = Instance.new("TextLabel", ProfileContainer)
DevName.Size = UDim2.new(0.65, 0, 0, 16)
DevName.Position = UDim2.new(0.34, 0, 0.28, 0)
DevName.BackgroundTransparency = 1
DevName.Text = LocalPlayer.DisplayName
DevName.Font = Enum.Font.GothamSemibold
DevName.TextSize = 11
DevName.TextColor3 = Styles.TextDark
DevName.TextXAlignment = Enum.TextXAlignment.Left
DevName.TextTruncate = Enum.TextTruncate.AtEnd

local ActiveDotLabel = Instance.new("TextLabel", ProfileContainer)
ActiveDotLabel.Size = UDim2.new(0.65, 0, 0, 14)
ActiveDotLabel.Position = UDim2.new(0.34, 0, 0.52, 0)
ActiveDotLabel.BackgroundTransparency = 1
ActiveDotLabel.Text = "● Active"
ActiveDotLabel.Font = Enum.Font.GothamBold
ActiveDotLabel.TextSize = 10
ActiveDotLabel.TextColor3 = Styles.Accent
ActiveDotLabel.TextXAlignment = Enum.TextXAlignment.Left

local SideLayout = Instance.new("UIListLayout", SidebarContainer)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	SidebarContainer.CanvasSize = UDim2.new(0, 0, 0, SideLayout.AbsoluteContentSize.Y + 12)
end)

local RightContentWindow = Instance.new("Frame", WindowContainerFrame)
RightContentWindow.Name = "RightContentWindow"
RightContentWindow.Size = UDim2.new(1, -165, 1, 0)
RightContentWindow.Position = UDim2.new(0, 165, 0, 0)
RightContentWindow.BackgroundTransparency = 1

local ShortcutsFrame = Instance.new("Frame", Sidebar)
ShortcutsFrame.Size = UDim2.new(0.84, 0, 0, 50)
ShortcutsFrame.Position = UDim2.new(0.08, 0, 1, -95)
ShortcutsFrame.BackgroundTransparency = 1

local ShortcutTitle = Instance.new("TextLabel", ShortcutsFrame)
ShortcutTitle.Size = UDim2.new(1, 0, 0, 14)
ShortcutTitle.BackgroundTransparency = 1
ShortcutTitle.Text = "SHORTCUTS"
ShortcutTitle.Font = Enum.Font.GothamBold
ShortcutTitle.TextSize = 10
ShortcutTitle.TextColor3 = Styles.Accent
ShortcutTitle.TextXAlignment = Enum.TextXAlignment.Left

ShortcutList = Instance.new("TextLabel", ShortcutsFrame)
ShortcutList.Size = UDim2.new(1, 0, 1, -14)
ShortcutList.Position = UDim2.new(0, 0, 0, 14)
ShortcutList.BackgroundTransparency = 1
ShortcutList.Font = Enum.Font.GothamSemibold
ShortcutList.TextSize = 10
ShortcutList.TextColor3 = Styles.TextDark
ShortcutList.TextXAlignment = Enum.TextXAlignment.Left
UpdateLeftPanelShortcuts()

local SystemStatusBtn = Instance.new("TextButton", Sidebar)
SystemStatusBtn.Size = UDim2.new(0.84, 0, 0, 32)
SystemStatusBtn.Position = UDim2.new(0.08, 0, 1, -38)
SystemStatusBtn.BackgroundColor3 = Styles.Accent
SystemStatusBtn.Font = Enum.Font.GothamBold
SystemStatusBtn.Text = "SYSTEM WORKING"
SystemStatusBtn.TextColor3 = Color3.fromRGB(12, 15, 13)
SystemStatusBtn.TextSize = 10
SystemStatusBtn.BorderSizePixel = 0
SystemStatusBtn.AutoButtonColor = false
Instance.new("UICorner", SystemStatusBtn).CornerRadius = UDim.new(0, 6)
HookButtonAnimations(SystemStatusBtn, Styles.Accent, Styles.Accent:Lerp(Color3.fromRGB(255,255,255), 0.15))

local SearchBarFrame = Instance.new("Frame", RightContentWindow)
SearchBarFrame.Size = UDim2.new(0.94, 0, 0, 30)
SearchBarFrame.Position = UDim2.new(0.03, 0, 0, 10)
SearchBarFrame.BackgroundColor3 = Color3.fromRGB(22, 23, 29)
SearchBarFrame.BorderSizePixel = 0
Instance.new("UICorner", SearchBarFrame).CornerRadius = UDim.new(0, 6)
local SearchStroke = Instance.new("UIStroke", SearchBarFrame)
SearchStroke.Color = Styles.Border

local SearchPlaceholder = Instance.new("TextBox", SearchBarFrame)
SearchPlaceholder.Size = UDim2.new(0.95, 0, 1, 0)
SearchPlaceholder.Position = UDim2.new(0.03, 0, 0, 0)
SearchPlaceholder.BackgroundTransparency = 1
SearchPlaceholder.Text = ""
SearchPlaceholder.PlaceholderText = "Search features..."
SearchPlaceholder.PlaceholderColor3 = Color3.fromRGB(70, 72, 85)
SearchPlaceholder.Font = Enum.Font.Gotham
SearchPlaceholder.TextSize = 11
SearchPlaceholder.TextColor3 = Styles.TextMain
SearchPlaceholder.TextXAlignment = Enum.TextXAlignment.Left

local Tabs = {}
local function RegisterTabContainerPage(tabName)
	local PageFrame = Instance.new("ScrollingFrame", RightContentWindow)
	PageFrame.Name = tabName .. "_Page"
	PageFrame.Size = UDim2.new(1, 0, 1, -55)
	PageFrame.Position = UDim2.new(0, 0, 0, 55)
	PageFrame.BackgroundTransparency = 1
	PageFrame.BorderSizePixel = 0
	PageFrame.ScrollBarThickness = 2
	PageFrame.ScrollBarImageColor3 = Styles.Accent
	PageFrame.Visible = false

	local PLayout = Instance.new("UIListLayout", PageFrame)
	PLayout.SortOrder = Enum.SortOrder.LayoutOrder
	PLayout.Padding = UDim.new(0, 8)
	PLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local PPadding = Instance.new("UIPadding", PageFrame)
	PPadding.PaddingTop = UDim.new(0, 6)
	PPadding.PaddingBottom = UDim.new(0, 15)

	PLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		PageFrame.CanvasSize = UDim2.new(0, 0, 0, PLayout.AbsoluteContentSize.Y + 25)
	end)

	local TabBtn = Instance.new("TextButton", SidebarContainer)
	TabBtn.Size = UDim2.new(1, 0, 0, 32)
	TabBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
	TabBtn.BackgroundTransparency = 1
	TabBtn.Font = Enum.Font.GothamSemibold
	TabBtn.Text = "      " .. tabName
	TabBtn.TextColor3 = Styles.TextDark
	TabBtn.TextSize = 11
	TabBtn.BorderSizePixel = 0
	TabBtn.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 5)

	local IndicatorStrip = Instance.new("Frame", TabBtn)
	IndicatorStrip.Name = "IndicatorStrip"
	IndicatorStrip.Size = UDim2.new(0, 2, 1, 0)
	IndicatorStrip.BackgroundColor3 = Styles.Accent
	IndicatorStrip.BorderSizePixel = 0
	IndicatorStrip.Visible = false

	TabBtn.MouseEnter:Connect(function() if not PageFrame.Visible then TweenObj(TabBtn, { TextColor3 = Styles.TextMain }, 0.2) end end)
	TabBtn.MouseLeave:Connect(function() if not PageFrame.Visible then TweenObj(TabBtn, { TextColor3 = Styles.TextDark }, 0.2) end end)

	TabBtn.MouseButton1Click:Connect(function()
		for _, tData in pairs(Tabs) do
			if tData.Page.Visible then tData.Page.Visible = false end
			TweenObj(tData.Btn, { TextColor3 = Styles.TextDark }, 0.25)
			tData.Btn.BackgroundTransparency = 1
			tData.Btn.IndicatorStrip.Visible = false
		end
		PageFrame.Position = UDim2.new(0, 15, 0, 55)
		PageFrame.Visible = true
		TweenObj(PageFrame, { Position = UDim2.new(0, 0, 0, 55) }, 0.4, Enum.EasingStyle.Quint)

		TweenObj(TabBtn, { TextColor3 = Styles.TextMain }, 0.25)
		TabBtn.BackgroundColor3 = Color3.fromRGB(26, 27, 35)
		TabBtn.BackgroundTransparency = 0
		IndicatorStrip.Visible = true
	end)

	Tabs[tabName] = {Page = PageFrame, Btn = TabBtn}
	return PageFrame
end

local AimPage = RegisterTabContainerPage("Aim Lock")
local VisPage = RegisterTabContainerPage("Visuals / ESP")
local LogPage = RegisterTabContainerPage("System Logs")
local CustPage = RegisterTabContainerPage("Customization")
local KeybindPage = RegisterTabContainerPage("Keybinds")
local TestPage = RegisterTabContainerPage("Lighting & Enviroment")
local FarmPage = RegisterTabContainerPage("Farm")
local SettPage = RegisterTabContainerPage("Settings")

local SystemLogEntries = {}

-- NEW: Logger Write Hook Function
SystemLogEvent = function(msg)
	local timeStr = os.date("%H:%M:%S")
	local LogCard = Instance.new("Frame", LogPage)

	table.insert(SystemLogEntries, LogCard)

	if #SystemLogEntries > 100 then
		local oldest = table.remove(SystemLogEntries, 1)
		if oldest then
			oldest:Destroy()
		end
	end

	LogCard.Size = UDim2.new(0.94, 0, 0, 28)
	LogCard.BackgroundColor3 = Styles.CardBg
	LogCard.BorderSizePixel = 0
	Instance.new("UICorner", LogCard).CornerRadius = UDim.new(0, 4)
	Instance.new("UIStroke", LogCard).Color = Styles.Border

	local LogText = Instance.new("TextLabel", LogCard)
	LogText.Size = UDim2.new(0.96, 0, 1, 0)
	LogText.Position = UDim2.new(0.02, 0, 0, 0)
	LogText.BackgroundTransparency = 1
	LogText.Text = string.format("[%s]  %s", timeStr, msg)
	LogText.Font = Enum.Font.GothamSemibold
	LogText.TextSize = 10
	LogText.TextColor3 = Styles.TextDark
	LogText.TextXAlignment = Enum.TextXAlignment.Left

	-- Auto-scroll trick layout logic
	local container = LogPage:FindFirstChild("UIListLayout")
	if container then
		LogPage.CanvasPosition = Vector2.new(0, container.AbsoluteContentSize.Y + 100)
	end
end
SystemLogEvent("Engine Core Initialized Successfully.")
Farm.SetLogHook(SystemLogEvent)

Tabs["Aim Lock"].Page.Visible = true
Tabs["Aim Lock"].Btn.TextColor3 = Styles.TextMain
Tabs["Aim Lock"].Btn.BackgroundColor3 = Color3.fromRGB(26, 27, 35)
Tabs["Aim Lock"].Btn.BackgroundTransparency = 0
Tabs["Aim Lock"].Btn.IndicatorStrip.Visible = true

local IsMin = false
MinimizeBtn.MouseButton1Click:Connect(function()
	IsMin = not IsMin
	local container = WindowContainerFrame

	if IsMin then
		TweenObj(MainFrame, { Size = UDim2.new(0, 540, 0, 40) }, 0.4, Enum.EasingStyle.Quint)
		container.Visible = false
		MinimizeBtn.Text = "+"
	else
		container.Visible = true
		TweenObj(MainFrame, { Size = UDim2.new(0, 540, 0, 415) }, 0.4, Enum.EasingStyle.Quint)
		MinimizeBtn.Text = "—"
	end

	UpdateMobileControlButtons()
end)

local function CinematicClose()
	TweenObj(MainStroke, { Transparency = 1 }, 0.15)
	local closeTween = TweenObj(MainFrame, { 
		Size = UDim2.new(0, 540, 0, 0), 
		Position = MainFrame.Position + UDim2.new(0, 0, 0, 207.5), 
		BackgroundTransparency = 1 
	}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	closeTween.Completed:Wait()
	env[CurrentScriptID] = nil 
	env[CurrentScriptID .. "_DataPacket"] = nil 
	UniversalDestruct()
end
CloseBtn.MouseButton1Click:Connect(CinematicClose)

local function AddDashboardButton(parentPage, configKey, displayTitle, desc, subDesc, customCallback)
	local state = Settings[configKey]

	local Card = Instance.new("Frame", parentPage)
	Card.Size = UDim2.new(0.94, 0, 0, 56)
	Card.BackgroundColor3 = Styles.CardBg
	Card.BorderSizePixel = 0
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
	local Stroke = Instance.new("UIStroke", Card)
	Stroke.Color = Styles.Border

	local TitleLabel = Instance.new("TextLabel", Card)
	TitleLabel.Size = UDim2.new(0.7, 0, 0, 18)
	TitleLabel.Position = UDim2.new(0.03, 0, 0.08, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = displayTitle
	TitleLabel.Font = Enum.Font.GothamSemibold
	TitleLabel.TextSize = 12
	TitleLabel.TextColor3 = Styles.TextMain
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local DescLabel = Instance.new("TextLabel", Card)
	DescLabel.Size = UDim2.new(0.9, 0, 0, 14)
	DescLabel.Position = UDim2.new(0.03, 0, 0.38, 0)
	DescLabel.BackgroundTransparency = 1
	DescLabel.Text = desc
	DescLabel.Font = Enum.Font.Gotham
	DescLabel.TextSize = 9
	DescLabel.TextColor3 = Styles.TextDark
	DescLabel.TextXAlignment = Enum.TextXAlignment.Left

	local SubLabel = Instance.new("TextLabel", Card)
	SubLabel.Size = UDim2.new(0.9, 0, 0, 14)
	SubLabel.Position = UDim2.new(0.03, 0, 0.64, 0)
	SubLabel.BackgroundTransparency = 1
	SubLabel.Text = subDesc
	SubLabel.Font = Enum.Font.Gotham
	SubLabel.RichText = true
	SubLabel.TextSize = 9
	SubLabel.TextColor3 = Styles.Accent
	SubLabel.TextXAlignment = Enum.TextXAlignment.Left

	local ToggleHousing = Instance.new("TextButton", Card)
	ToggleHousing.Size = UDim2.new(0, 38, 0, 20)
	ToggleHousing.Position = UDim2.new(0.97, -38, 0.5, -10)
	ToggleHousing.BackgroundColor3 = state and Styles.Accent or Color3.fromRGB(40, 42, 52)
	ToggleHousing.Text = ""
	ToggleHousing.BorderSizePixel = 0
	Instance.new("UICorner", ToggleHousing).CornerRadius = UDim.new(1, 0)

	local ToggleCore = Instance.new("Frame", ToggleHousing)
	ToggleCore.Size = UDim2.new(0, 14, 0, 14)
	ToggleCore.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	ToggleCore.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
	ToggleCore.BorderSizePixel = 0
	Instance.new("UICorner", ToggleCore).CornerRadius = UDim.new(1, 0)

	Card.MouseEnter:Connect(function() 
		TweenObj(Stroke, { Color = Styles.Accent }, 0.2) 
		TweenObj(Card, { BackgroundColor3 = Styles.CardHover }, 0.2) 
	end)
	Card.MouseLeave:Connect(function() 
		TweenObj(Stroke, { Color = Styles.Border }, 0.2) 
		TweenObj(Card, { BackgroundColor3 = Styles.CardBg }, 0.2) 
	end)

	local buttonScale = Instance.new("UIScale", ToggleHousing)
	ToggleHousing.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then TweenObj(buttonScale, { Scale = 0.88 }, 0.1) end
	end)
	ToggleHousing.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then TweenObj(buttonScale, { Scale = 1 }, 0.1) end
	end)

	ToggleHousing.MouseButton1Click:Connect(function()
		Settings[configKey] = not Settings[configKey]
		local current = Settings[configKey]

		TweenObj(ToggleHousing, { BackgroundColor3 = current and Styles.Accent or Color3.fromRGB(40, 42, 52) }, 0.25, Enum.EasingStyle.Quint)
		TweenObj(ToggleCore, { Position = current and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }, 0.25, Enum.EasingStyle.Quint)

		if customCallback then
			customCallback(current)
		end

		if configKey == "ESPEnabled" or configKey == "Enabled" or configKey == "DetectPlayers" or configKey == "DetectNPCs" then
			RefreshAllESP()
		end
	end)

	-- Hook for Defaults System Reset Update
	table.insert(UIUpdaters, function()
		local current = Settings[configKey]
		TweenObj(ToggleHousing, { BackgroundColor3 = current and Styles.Accent or Color3.fromRGB(40, 42, 52) }, 0.25, Enum.EasingStyle.Quint)
		TweenObj(ToggleCore, { Position = current and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }, 0.25, Enum.EasingStyle.Quint)
	end)
end

local function AddDashboardSlider(parentPage, configKey, displayTitle, min, max, desc, subDesc, customCallback, decimalPlaces)
	local initial = Settings[configKey]

	local Card = Instance.new("Frame", parentPage)
	Card.Size = UDim2.new(0.94, 0, 0, 68)
	Card.BackgroundColor3 = Styles.CardBg
	Card.BorderSizePixel = 0
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
	local Stroke = Instance.new("UIStroke", Card)
	Stroke.Color = Styles.Border

	local TitleLabel = Instance.new("TextLabel", Card)
	TitleLabel.Size = UDim2.new(0.7, 0, 0, 16)
	TitleLabel.Position = UDim2.new(0.03, 0, 0.06, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = displayTitle
	TitleLabel.Font = Enum.Font.GothamSemibold
	TitleLabel.TextSize = 12
	TitleLabel.TextColor3 = Styles.TextMain
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local ValLabel = Instance.new("TextLabel", Card)
	ValLabel.Size = UDim2.new(0.2, 0, 0, 16)
	ValLabel.Position = UDim2.new(0.97, -40, 0.06, 0)
	ValLabel.BackgroundTransparency = 1

	if decimalPlaces then
		ValLabel.Text = string.format("%." .. decimalPlaces .. "f", initial)
	elseif max == 100 then
		ValLabel.Text = tostring(math.floor(initial) / 100)
	elseif max == 5000 then
		ValLabel.Text = tostring(math.floor(initial))
	else
		ValLabel.Text = tostring(initial)
	end

	ValLabel.Font = Enum.Font.GothamBold
	ValLabel.TextSize = 11
	ValLabel.TextColor3 = Styles.Accent
	ValLabel.TextXAlignment = Enum.TextXAlignment.Right

	local DescLabel = Instance.new("TextLabel", Card)
	DescLabel.Size = UDim2.new(0.9, 0, 0, 12)
	DescLabel.Position = UDim2.new(0.03, 0, 0.28, 0)
	DescLabel.BackgroundTransparency = 1
	DescLabel.Text = desc
	DescLabel.Font = Enum.Font.Gotham
	DescLabel.TextSize = 9
	DescLabel.TextColor3 = Styles.TextDark
	DescLabel.TextXAlignment = Enum.TextXAlignment.Left

	local SubLabel = Instance.new("TextLabel", Card)
	SubLabel.Size = UDim2.new(0.9, 0, 0, 12)
	SubLabel.Position = UDim2.new(0.03, 0, 0.46, 0)
	SubLabel.BackgroundTransparency = 1
	SubLabel.Text = subDesc
	SubLabel.Font = Enum.Font.Gotham
	SubLabel.TextSize = 9
	SubLabel.TextColor3 = Styles.Accent
	SubLabel.TextXAlignment = Enum.TextXAlignment.Left

	local Track = Instance.new("Frame", Card)
	Track.Size = UDim2.new(0.94, 0, 0, 6)
	Track.Position = UDim2.new(0.03, 0, 0.78, 0)
	Track.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
	Track.BorderSizePixel = 0
	Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

	local Fill = Instance.new("Frame", Track)
	Fill.Size = UDim2.new((initial - min)/(max - min), 0, 1, 0)
	Fill.BackgroundColor3 = Styles.Accent
	Fill.BorderSizePixel = 0
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

	local Knob = Instance.new("Frame", Track)
	Knob.Size = UDim2.new(0, 16, 0, 16)
	Knob.Position = UDim2.new((initial - min)/(max - min), -8, 0.5, -8)
	Knob.BackgroundColor3 = Styles.TextMain
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
	local KnobStroke = Instance.new("UIStroke", Knob)
	KnobStroke.Color = Styles.Accent
	KnobStroke.Thickness = 2

	Card.MouseEnter:Connect(function() 
		TweenObj(Stroke, { Color = Styles.Accent }, 0.2) 
		TweenObj(Card, { BackgroundColor3 = Styles.CardHover }, 0.2) 
	end)
	Card.MouseLeave:Connect(function() 
		TweenObj(Stroke, { Color = Styles.Border }, 0.2) 
		TweenObj(Card, { BackgroundColor3 = Styles.CardBg }, 0.2) 
	end)

	local function UpdateValue(rawPercentage, animate)
		local percentage = math.clamp(rawPercentage, 0, 1)
		local currentVal = min + (percentage * (max - min))
		local rounded

		if decimalPlaces then
			local factor = 10 ^ decimalPlaces
			rounded = math.floor(currentVal * factor + 0.5) / factor
		else
			rounded = (max == 100 or max == 5000 or max == 5) and math.floor(currentVal) or math.floor(currentVal * 100) / 100
		end

		if decimalPlaces then
			ValLabel.Text = string.format("%." .. decimalPlaces .. "f", rounded)
		elseif max == 100 then
			ValLabel.Text = tostring(rounded / 100)
		else
			ValLabel.Text = tostring(rounded)
		end

		Settings[configKey] = decimalPlaces and rounded or currentVal
		if customCallback then customCallback(currentVal) end

		if animate then
			TweenObj(Knob, { Position = UDim2.new(percentage, -8, 0.5, -8) }, 0.1, Enum.EasingStyle.Quint)
			TweenObj(Fill, { Size = UDim2.new(percentage, 0, 1, 0) }, 0.1, Enum.EasingStyle.Quint)
		else
			Knob.Position = UDim2.new(percentage, -8, 0.5, -8)
			Fill.Size = UDim2.new(percentage, 0, 1, 0)
		end
	end

	local activeDrag = false
	local function ProcessSliderInput(input)
		local percentage = (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
		UpdateValue(percentage, false)
	end

	Card.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			activeDrag = true
			ProcessSliderInput(input)
		end
	end)

	SafeConnect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then activeDrag = false end
	end)

	SafeConnect(UserInputService.InputChanged, function(input)
		if activeDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			ProcessSliderInput(input)
		end
	end)

	-- Hook for Defaults System Reset Update
	table.insert(UIUpdaters, function()
		local percent = (Settings[configKey] - min)/(max - min)
		UpdateValue(percent, true)
	end)
end

local function AddDashboardDropdown(parentPage, configKey, displayTitle, options, desc)
	local Card = Instance.new("Frame", parentPage)
	Card.Size = UDim2.new(0.94, 0, 0, 56)
	Card.BackgroundColor3 = Styles.CardBg
	Card.BorderSizePixel = 0
	Card.ClipsDescendants = true
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

	local Stroke = Instance.new("UIStroke", Card)
	Stroke.Color = Styles.Border

	local TitleLabel = Instance.new("TextLabel", Card)
	TitleLabel.Size = UDim2.new(0.5, 0, 0, 18)
	TitleLabel.Position = UDim2.new(0.03, 0, 0.12, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = displayTitle
	TitleLabel.Font = Enum.Font.GothamSemibold
	TitleLabel.TextSize = 12
	TitleLabel.TextColor3 = Styles.TextMain
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local DescLabel = Instance.new("TextLabel", Card)
	DescLabel.Size = UDim2.new(0.6, 0, 0, 14)
	DescLabel.Position = UDim2.new(0.03, 0, 0.48, 0)
	DescLabel.BackgroundTransparency = 1
	DescLabel.Text = desc
	DescLabel.Font = Enum.Font.Gotham
	DescLabel.TextSize = 9
	DescLabel.TextColor3 = Styles.TextDark
	DescLabel.TextXAlignment = Enum.TextXAlignment.Left

	local DropdownButton = Instance.new("TextButton", Card)
	DropdownButton.Size = UDim2.new(0, 145, 0, IsTouchDevice and 34 or 28)
	DropdownButton.Position = UDim2.new(0.97, -145, 0.5, IsTouchDevice and -17 or -14)
	DropdownButton.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
	DropdownButton.BorderSizePixel = 0
	DropdownButton.Font = Enum.Font.GothamSemibold
	DropdownButton.TextColor3 = Styles.TextMain
	DropdownButton.TextSize = 10
	DropdownButton.AutoButtonColor = false
	Instance.new("UICorner", DropdownButton).CornerRadius = UDim.new(0, 5)

	local OptionsFrame = Instance.new("Frame", Card)
	OptionsFrame.Size = UDim2.new(0.94, 0, 0, #options * 30)
	OptionsFrame.Position = UDim2.new(0.03, 0, 0, 60)
	OptionsFrame.BackgroundTransparency = 1
	OptionsFrame.Visible = false

	local OptionsLayout = Instance.new("UIListLayout", OptionsFrame)
	OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	OptionsLayout.Padding = UDim.new(0, 4)

	local isOpen = false

	local function UpdateDropdownText()
		DropdownButton.Text = tostring(Settings[configKey]) .. (isOpen and "  ▲" or "  ▼")
	end

	local function SetOpen(open)
		isOpen = open
		OptionsFrame.Visible = open
		UpdateDropdownText()

		local height = open and (64 + (#options * 30)) or 56
		TweenObj(Card, { Size = UDim2.new(0.94, 0, 0, height) }, 0.2, Enum.EasingStyle.Quint)
		TweenObj(Stroke, { Color = open and Styles.Accent or Styles.Border }, 0.2)
	end

	for index, option in ipairs(options) do
		local OptionButton = Instance.new("TextButton", OptionsFrame)
		OptionButton.Size = UDim2.new(1, 0, 0, 26)
		OptionButton.LayoutOrder = index
		OptionButton.BackgroundColor3 = Color3.fromRGB(26, 27, 35)
		OptionButton.BorderSizePixel = 0
		OptionButton.Font = Enum.Font.GothamSemibold
		OptionButton.Text = option
		OptionButton.TextColor3 = Styles.TextDark
		OptionButton.TextSize = 10
		OptionButton.AutoButtonColor = false
		Instance.new("UICorner", OptionButton).CornerRadius = UDim.new(0, 5)

		OptionButton.MouseEnter:Connect(function()
			TweenObj(OptionButton, { BackgroundColor3 = Styles.CardHover, TextColor3 = Styles.TextMain }, 0.15)
		end)

		OptionButton.MouseLeave:Connect(function()
			TweenObj(OptionButton, { BackgroundColor3 = Color3.fromRGB(26, 27, 35), TextColor3 = Styles.TextDark }, 0.15)
		end)

		OptionButton.MouseButton1Click:Connect(function()
			Settings[configKey] = option
			Target = nil
			SetOpen(false)
		end)
	end

	DropdownButton.MouseButton1Click:Connect(function()
		SetOpen(not isOpen)
	end)

	Card.MouseEnter:Connect(function()
		if not isOpen then TweenObj(Stroke, { Color = Styles.Accent }, 0.2) end
	end)

	Card.MouseLeave:Connect(function()
		if not isOpen then TweenObj(Stroke, { Color = Styles.Border }, 0.2) end
	end)

	UpdateDropdownText()

	table.insert(UIUpdaters, function()
		SetOpen(false)
		UpdateDropdownText()
	end)
end

local function AddKeybindControl(parentPage, configKey, displayTitle, desc)
	local Card = Instance.new("Frame", parentPage)
	Card.Size = UDim2.new(0.94, 0, 0, 58)
	Card.BackgroundColor3 = Styles.CardBg
	Card.BorderSizePixel = 0
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

	local Stroke = Instance.new("UIStroke", Card)
	Stroke.Color = Styles.Border

	local TitleLabel = Instance.new("TextLabel", Card)
	TitleLabel.Size = UDim2.new(0.62, 0, 0, 18)
	TitleLabel.Position = UDim2.new(0.03, 0, 0, 9)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = displayTitle
	TitleLabel.Font = Enum.Font.GothamSemibold
	TitleLabel.TextSize = 12
	TitleLabel.TextColor3 = Styles.TextMain
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local DescLabel = Instance.new("TextLabel", Card)
	DescLabel.Size = UDim2.new(0.62, 0, 0, 16)
	DescLabel.Position = UDim2.new(0.03, 0, 0, 31)
	DescLabel.BackgroundTransparency = 1
	DescLabel.Text = desc
	DescLabel.Font = Enum.Font.Gotham
	DescLabel.TextSize = 9
	DescLabel.TextColor3 = Styles.TextDark
	DescLabel.TextXAlignment = Enum.TextXAlignment.Left

	local ValueButton = Instance.new("TextButton", Card)
	ValueButton.Size = UDim2.new(0, 82, 0, IsTouchDevice and 36 or 30)
	ValueButton.Position = UDim2.new(0.97, -82, 0.5, IsTouchDevice and -18 or -15)
	ValueButton.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
	ValueButton.BorderSizePixel = 0
	ValueButton.Text = GetKeybindName(Settings[configKey])
	ValueButton.Font = Enum.Font.GothamBold
	ValueButton.TextSize = 11
	ValueButton.TextColor3 = Styles.TextMain
	ValueButton.AutoButtonColor = false
	Instance.new("UICorner", ValueButton).CornerRadius = UDim.new(0, 5)

	local ValueStroke = Instance.new("UIStroke", ValueButton)
	ValueStroke.Color = Styles.Border

	KeybindValueButtons[configKey] = ValueButton

	Card.MouseEnter:Connect(function()
		TweenObj(Stroke, { Color = Styles.Accent }, 0.2)
		TweenObj(Card, { BackgroundColor3 = Styles.CardHover }, 0.2)
	end)

	Card.MouseLeave:Connect(function()
		TweenObj(Stroke, { Color = Styles.Border }, 0.2)
		TweenObj(Card, { BackgroundColor3 = Styles.CardBg }, 0.2)
	end)

	ValueButton.MouseEnter:Connect(function()
		TweenObj(ValueStroke, { Color = Styles.Accent }, 0.15)
	end)

	ValueButton.MouseLeave:Connect(function()
		if not KeybindCapture or KeybindCapture.ConfigKey ~= configKey then
			TweenObj(ValueStroke, { Color = Styles.Border }, 0.15)
		end
	end)

	ValueButton.MouseButton1Click:Connect(function()
		if IsTouchDevice and not HasKeyboard then
			ValueButton.Text = "PC ONLY"
			return
		end

		if KeybindCapture then
			UpdateKeybindValueButtons()
		end

		KeybindCapture = {
			ConfigKey = configKey,
			DisplayName = displayTitle
		}

		ValueButton.Text = ".."
		TweenObj(ValueStroke, { Color = Styles.Accent }, 0.15)
	end)

	table.insert(UIUpdaters, function()
		if KeybindCapture and KeybindCapture.ConfigKey == configKey then
			KeybindCapture = nil
		end

		if IsTouchDevice and not HasKeyboard then
			ValueButton.Text = "PC ONLY"
		else
			ValueButton.Text = GetKeybindName(Settings[configKey])
		end

		ValueStroke.Color = Styles.Border
	end)
end

--// Map Interface Elements Across Target Tab Frames
AddDashboardButton(AimPage, "Enabled", "System Master Processing", "★ Optimal Placement: Core Hub Active On Screen", "Enables global calculation thread loops across physics steps.")
AddDashboardButton(AimPage, "DetectPlayers", "Detect Players", "Target Detection: Roblox Players", "Allows Aim Lock and ESP to detect player characters.", function()
	Target = nil
	RefreshAllESP()
end)
AddDashboardButton(AimPage, "DetectNPCs", "Detect NPCs", "Target Detection: NPC Humanoids", "Allows Aim Lock and ESP to detect NPC models with a Humanoid.", function()
	Target = nil
	RefreshAllESP()
end)
AddDashboardButton(AimPage, "WallCheck", "Raycast Wall Protection", "★ Optimal Placement: Critical Layer Protection", "Prevents engine cross-snapping onto targets located behind solid structures.")
AddDashboardButton(AimPage, "AutoShoot", "Auto-Trigger Mechanism", "★ Optimal Placement: Micro-Weapons Testing Engine", "Automatically handles tool activation parameters during tracking.")
AddDashboardDropdown(AimPage, "TargetPart", "Target Part", {"Head", "HumanoidRootPart", "Torso"}, "Select the body part used for target locking.")
-- NEW: Configurable Visual Enhancements Hooked to UI
AddDashboardButton(AimPage, "TargetIndicator", "Draw Target Indicator", "★ Aimbot Customization: Realtime Tracking UI", "Spawns a highly responsive neon circle exactly over the enemy hit-part.")
AddDashboardButton(AimPage, "FOVPulse", "FOV Pulse Animation", "★ Aimbot Customization: Action Feedback Response", "Pulses the main threat boundary ring smoothly when target acquisition is active.")

AddDashboardSlider(AimPage, "Smoothness", "Tracking Camera Smoothness", 1, 100, "★ Optimal Placement: Low-Medium (Natural Damping) (0.15)", "Alters tracking dampening alignment latency to emulate natural aim.")
AddDashboardSlider(AimPage, "MaxDistance", "Target Maximum Distance", 50, 5000, "★ Optimal Placement: Low (Safe Render Limit) (1000)", "Calculates the ultimate cut-off barrier stud threshold for lock acquisition.")

AddDashboardButton(VisPage, "ESPEnabled", "Highlight Player ESP Outlines", "★ Optimal Placement: Traditional Outline Overlay Engine", "Renders precise direct screen boundary overlays on top of live enemies.")
AddDashboardButton(VisPage, "ShowFOV", "Draw Screen Field of View", "★ Optimal Placement: Center Axis Display", "Toggles the crosshair peripheral validation threat boundary ring visibility.")
AddDashboardSlider(VisPage, "FOVRadius", "Crosshair Threat Radius", 20, 500, "★ Optimal Placement: Low-Medium (Zero-Lag Filtering) (120)", "Adjusts the width scale boundary of your screen targeting frame ring.")
AddDashboardSlider(VisPage, "ESPTransparency", "ESP Elements Opacity Alpha", 0.0, 1.0, "★ Optimal Placement: Medium High Density Fill (0.4)", "Modulates internal card outline overlay drawing opacity visibility scales.", function()
	RefreshAllESP()
end)

AddDashboardButton(TestPage, "Fullbright", "Enable Fullbright", "Makes dark areas fully visible.", "Toggle enhanced lighting visibility.", function(enabled)
	UpdateFullbright(enabled)
end)

AddDashboardButton(TestPage, "ShowFPS", "Show FPS", "Displays your current frame rate.", "Useful for performance and lag testing.")

AddDashboardButton(TestPage, "WallCheckDebug", "WallCheck Debug", "Draws a line to the current aim target.", "Green = visible, red = blocked by geometry.")

AddDashboardButton(TestPage, "TargetInfo", "Target Info", "Shows information about the current target.", "Displays health, distance and selected body part.")


AddDashboardButton(FarmPage, "FarmEnabled", "Start Farm", "Automatically finds and processes nearby safes/registers.", "Game-specific farm logic using the existing target/remotes.", function(enabled)
	if enabled then Farm.Start() else Farm.Stop() end
end)

AddDashboardButton(FarmPage, "FarmAutoMoney", "Auto Money", "Automatically picks up nearby money drops.", "Optimized interval scan instead of RenderStepped.", function(enabled)
	if enabled then Farm.StartAutoMoney() else Farm.StopAutoMoney() end
end)

AddDashboardButton(FarmPage, "FarmInvisibility", "Invisibility (R6)", "Enables the R6 invisibility mode from the farm hub.", "Only runs while enabled and caches character parts.", function(enabled)
	if enabled then Farm.EnableInvisibility() else Farm.DisableInvisibility() end
end)

AddDashboardButton(FarmPage, "FarmAntiAFK", "Anti-AFK", "Prevents the idle kick while enabled.", "Uses one Idled connection instead of a frame loop.", function(enabled)
	if enabled then Farm.EnableAntiAFK() else Farm.DisableAntiAFK() end
end)

AddDashboardButton(VisPage, "FarmSafeESP", "Safe / Register ESP", "Highlights farm safes and registers.", "Green = available, red = broken.", function(enabled)
	if enabled then Farm.EnableSafeESP() else Farm.DisableSafeESP() end
end)

AddDashboardSlider(VisPage, "FarmESPTextSize", "Farm ESP Text Size", 10, 40, "Controls the Safe/Register ESP label size.", "No movement-speed control is included.", function(value)
	Settings.FarmESPTextSize = math.floor(value + 0.5)
end, 0)

local CycleColorBtn = Instance.new("TextButton", CustPage)
CycleColorBtn.Size = UDim2.new(0.94, 0, 0, 36)
CycleColorBtn.BackgroundColor3 = Styles.CardBg
CycleColorBtn.Font = Enum.Font.GothamBold
CycleColorBtn.TextColor3 = Styles.TextMain
CycleColorBtn.Text = "SWAP ACCENT PALETTE CREATIVE MATRIX"
CycleColorBtn.TextSize = 10
CycleColorBtn.BorderSizePixel = 0
Instance.new("UICorner", CycleColorBtn).CornerRadius = UDim.new(0, 6)
local CycleStroke = Instance.new("UIStroke", CycleColorBtn)
CycleStroke.Color = Styles.Accent
HookButtonAnimations(CycleColorBtn, Styles.CardBg, Styles.CardHover)

CycleColorBtn.MouseButton1Click:Connect(function()
	Settings.AccentColorIndex = Settings.AccentColorIndex + 1
	if Settings.AccentColorIndex > #AccentPresets then Settings.AccentColorIndex = 1 end
	local currentAccent = AccentPresets[Settings.AccentColorIndex]

	Styles.Accent = currentAccent
	FOVCircle.Color = currentAccent
	TargetDot.Color = currentAccent
	FPSDisplay.Color = currentAccent
	TargetInfoText.Color = currentAccent
	SidebarContainer.ScrollBarImageColor3 = currentAccent
	TweenObj(CycleStroke, { Color = currentAccent }, 0.25)
	TweenObj(SystemStatusBtn, { BackgroundColor3 = currentAccent }, 0.25)
	TweenObj(ActiveDotLabel, { TextColor3 = currentAccent }, 0.25)
	TweenObj(ShortcutTitle, { TextColor3 = currentAccent }, 0.25)
	TweenObj(SubTitle, { TextColor3 = currentAccent }, 0.25)
	for _, tData in pairs(Tabs) do
		tData.Btn.IndicatorStrip.BackgroundColor3 = currentAccent
		tData.Page.ScrollBarImageColor3 = currentAccent
	end
end)

AddDashboardSlider(CustPage, "MenuTransparency", "Background Canvas Alpha Opacity", 0, 100, "★ Configuration Layer: Realtime Glass Damping Modulator", "Blends the main user interface frames seamlessly into the background layers.", function(val)
	local calculatedAlpha = val / 100
	MainFrame.BackgroundTransparency = calculatedAlpha
	HeaderBar.BackgroundTransparency = calculatedAlpha
	Sidebar.BackgroundTransparency = calculatedAlpha
end)

AddDashboardSlider(CustPage, "BorderThickness", "User Interface Structural Thickness", 1, 5, "★ Configuration Layer: Outer Boundary Vector Frame Line Scaling", "Alters the pixel width dimensions of all highlighted main outer boundaries.", function(val)
	MainStroke.Thickness = val
end)

AddKeybindControl(KeybindPage, "AimKey", "Set Aimbot Keybind", "Click the key frame, then press any keyboard key.")
AddKeybindControl(KeybindPage, "ToggleUiKey", "Set Menu Keybind", "Click the key frame, then press any keyboard key.")

-- PAGE 4: SETTINGS (Now Contains the Config Module)

-- NEW: Config Save Button
local SaveConfigBtn = Instance.new("TextButton", SettPage)
SaveConfigBtn.Size = UDim2.new(0.94, 0, 0, 36)
SaveConfigBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
SaveConfigBtn.Font = Enum.Font.GothamBold
SaveConfigBtn.TextColor3 = Styles.TextMain
SaveConfigBtn.Text = "SAVE CONFIGURATION PRESETS"
SaveConfigBtn.TextSize = 10
SaveConfigBtn.BorderSizePixel = 0
Instance.new("UICorner", SaveConfigBtn).CornerRadius = UDim.new(0, 6)
local SaveStroke = Instance.new("UIStroke", SaveConfigBtn)
SaveStroke.Color = Styles.Accent
HookButtonAnimations(SaveConfigBtn, Color3.fromRGB(35, 40, 50), Color3.fromRGB(45, 50, 65))

SaveConfigBtn.MouseButton1Click:Connect(function()
	env[CurrentScriptID .. "_DataPacket"] = {
		Settings = table.clone(Settings)
	}
	TweenObj(SaveConfigBtn, { BackgroundColor3 = Color3.fromRGB(50, 200, 100) }, 0.15)
	SaveConfigBtn.Text = "CONFIGURATION SAVED SUCCESSFULLY"
	SystemLogEvent("Configuration Profile Saved.")
	task.wait(1.5)
	TweenObj(SaveConfigBtn, { BackgroundColor3 = Color3.fromRGB(35, 40, 50) }, 0.25)
	SaveConfigBtn.Text = "SAVE CONFIGURATION PRESETS"
end)

-- NEW: Config Reset Button
local ResetConfigBtn = Instance.new("TextButton", SettPage)
ResetConfigBtn.Size = UDim2.new(0.94, 0, 0, 36)
ResetConfigBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 35)
ResetConfigBtn.Font = Enum.Font.GothamBold
ResetConfigBtn.TextColor3 = Color3.fromRGB(250, 180, 100)
ResetConfigBtn.Text = "RESET ALL SYSTEMS TO FACTORY DEFAULTS"
ResetConfigBtn.TextSize = 10
ResetConfigBtn.BorderSizePixel = 0
Instance.new("UICorner", ResetConfigBtn).CornerRadius = UDim.new(0, 6)
HookButtonAnimations(ResetConfigBtn, Color3.fromRGB(50, 40, 35), Color3.fromRGB(65, 50, 45))

local function FactoryResetSettings()
	for key, value in pairs(DefaultSettings) do Settings[key] = value end
	for _, updater in ipairs(UIUpdaters) do updater() end

	Aiming = false
	Target = nil
	LastLoggedTarget = nil
	LastTargetHealth = 0
	IsShooting = false
	ControlClick(false)

	UpdateFullbright(false)
	Farm.Cleanup()
	RefreshAllESP()

	FOVCircle.Visible = false
	TargetDot.Visible = false
	FPSDisplay.Visible = false
	WallDebugLine.Visible = false
	TargetInfoText.Visible = false

	local currentAccent = AccentPresets[Settings.AccentColorIndex]
	Styles.Accent = currentAccent
	FOVCircle.Color = currentAccent
	TargetDot.Color = currentAccent
	FPSDisplay.Color = currentAccent
	TargetInfoText.Color = currentAccent
	SidebarContainer.ScrollBarImageColor3 = currentAccent
	TweenObj(CycleStroke, { Color = currentAccent }, 0.25)
	TweenObj(SystemStatusBtn, { BackgroundColor3 = currentAccent }, 0.25)
	TweenObj(ActiveDotLabel, { TextColor3 = currentAccent }, 0.25)
	TweenObj(ShortcutTitle, { TextColor3 = currentAccent }, 0.25)
	TweenObj(SubTitle, { TextColor3 = currentAccent }, 0.25)

	for _, tData in pairs(Tabs) do
		tData.Btn.IndicatorStrip.BackgroundColor3 = currentAccent
		tData.Page.ScrollBarImageColor3 = currentAccent
	end

	UpdateKeybindValueButtons()
	UpdateLeftPanelShortcuts()
end

ResetConfigBtn.MouseButton1Click:Connect(function()
	FactoryResetSettings()
	SystemLogEvent("Engine Reverted to Factory Configuration.")
end)

local KillEngineBtn = Instance.new("TextButton", SettPage)
KillEngineBtn.Size = UDim2.new(0.94, 0, 0, 36)
KillEngineBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 25)
KillEngineBtn.Font = Enum.Font.GothamBold
KillEngineBtn.TextColor3 = Color3.fromRGB(240, 110, 110)
KillEngineBtn.Text = "UNLOAD ENGINE MATRIX AND WIPE GUI"
KillEngineBtn.TextSize = 10
KillEngineBtn.BorderSizePixel = 0
Instance.new("UICorner", KillEngineBtn).CornerRadius = UDim.new(0, 6)
HookButtonAnimations(KillEngineBtn, Color3.fromRGB(45, 20, 25), Color3.fromRGB(60, 25, 30))

KillEngineBtn.MouseButton1Click:Connect(CinematicClose)

local AuthFrame = Instance.new("Frame", ScreenGui)
AuthFrame.Name = "AccessFrame"
AuthFrame.Size = UDim2.new(0, 390, 0, 250)
AuthFrame.AnchorPoint = Vector2.new(0.5, 0.5)
AuthFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
AuthFrame.BackgroundColor3 = Styles.Bg
AuthFrame.BorderSizePixel = 0
AuthFrame.Active = true
AuthFrame.Visible = true
Instance.new("UICorner", AuthFrame).CornerRadius = UDim.new(0, 10)

AuthUIScale = Instance.new("UIScale", AuthFrame)

local AuthStroke = Instance.new("UIStroke", AuthFrame)
AuthStroke.Color = Styles.Accent
AuthStroke.Thickness = 1.5

local AuthHeader = Instance.new("Frame", AuthFrame)
AuthHeader.Size = UDim2.new(1, 0, 0, 44)
AuthHeader.BackgroundColor3 = Styles.SidebarBg
AuthHeader.BorderSizePixel = 0
Instance.new("UICorner", AuthHeader).CornerRadius = UDim.new(0, 10)

local AuthHeaderMask = Instance.new("Frame", AuthHeader)
AuthHeaderMask.Size = UDim2.new(1, 0, 0, 10)
AuthHeaderMask.Position = UDim2.new(0, 0, 1, -10)
AuthHeaderMask.BackgroundColor3 = Styles.SidebarBg
AuthHeaderMask.BorderSizePixel = 0

local AuthTitle = Instance.new("TextLabel", AuthHeader)
AuthTitle.Size = UDim2.new(1, -28, 0, 20)
AuthTitle.Position = UDim2.new(0, 14, 0, 7)
AuthTitle.BackgroundTransparency = 1
AuthTitle.Text = "AEHMRE // WELCOME"
AuthTitle.Font = Enum.Font.GothamBold
AuthTitle.TextSize = 13
AuthTitle.TextColor3 = Styles.TextMain
AuthTitle.TextXAlignment = Enum.TextXAlignment.Left

local AuthSubTitle = Instance.new("TextLabel", AuthHeader)
AuthSubTitle.Size = UDim2.new(1, -28, 0, 14)
AuthSubTitle.Position = UDim2.new(0, 14, 0, 25)
AuthSubTitle.BackgroundTransparency = 1
AuthSubTitle.Text = "AIMBOT HUB"
AuthSubTitle.Font = Enum.Font.GothamSemibold
AuthSubTitle.TextSize = 9
AuthSubTitle.TextColor3 = Styles.Accent
AuthSubTitle.TextXAlignment = Enum.TextXAlignment.Left

local AuthInfo = Instance.new("TextLabel", AuthFrame)
AuthInfo.Size = UDim2.new(1, -32, 0, 38)
AuthInfo.Position = UDim2.new(0, 16, 0, 62)
AuthInfo.BackgroundTransparency = 1
AuthInfo.Text = "Join the Discord for updates, announcements and future access-system information."
AuthInfo.Font = Enum.Font.Gotham
AuthInfo.TextSize = 10
AuthInfo.TextWrapped = true
AuthInfo.TextColor3 = Styles.TextDark
AuthInfo.TextXAlignment = Enum.TextXAlignment.Left
AuthInfo.TextYAlignment = Enum.TextYAlignment.Top

local KeyInput = Instance.new("TextBox", AuthFrame)
KeyInput.Size = UDim2.new(1, -32, 0, 38)
KeyInput.Position = UDim2.new(0, 16, 0, 108)
KeyInput.BackgroundColor3 = Styles.CardBg
KeyInput.BorderSizePixel = 0
KeyInput.ClearTextOnFocus = false
KeyInput.TextEditable = false
KeyInput.Text = "KEY SYSTEM DISABLED FOR NOW"
KeyInput.TextColor3 = Styles.TextDark
KeyInput.Font = Enum.Font.Code
KeyInput.TextSize = 11
KeyInput.TextXAlignment = Enum.TextXAlignment.Center
KeyInput.Active = false
KeyInput.Selectable = false
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

local KeyStroke = Instance.new("UIStroke", KeyInput)
KeyStroke.Color = Styles.Border

local CopyDiscordBtn = Instance.new("TextButton", AuthFrame)
CopyDiscordBtn.Size = UDim2.new(0.5, -20, 0, 36)
CopyDiscordBtn.Position = UDim2.new(0, 16, 0, 158)
CopyDiscordBtn.BackgroundColor3 = Styles.Accent
CopyDiscordBtn.BorderSizePixel = 0
CopyDiscordBtn.Text = "COPY DISCORD INVITE"
CopyDiscordBtn.TextColor3 = Color3.fromRGB(10, 10, 12)
CopyDiscordBtn.Font = Enum.Font.GothamBold
CopyDiscordBtn.TextSize = 9
CopyDiscordBtn.AutoButtonColor = false
Instance.new("UICorner", CopyDiscordBtn).CornerRadius = UDim.new(0, 6)

local IgnoreBtn = Instance.new("TextButton", AuthFrame)
IgnoreBtn.Size = UDim2.new(0.5, -20, 0, 36)
IgnoreBtn.Position = UDim2.new(0.5, 4, 0, 158)
IgnoreBtn.BackgroundColor3 = Styles.CardBg
IgnoreBtn.BorderSizePixel = 0
IgnoreBtn.Text = "IGNORE"
IgnoreBtn.TextColor3 = Styles.TextMain
IgnoreBtn.Font = Enum.Font.GothamBold
IgnoreBtn.TextSize = 10
IgnoreBtn.AutoButtonColor = false
Instance.new("UICorner", IgnoreBtn).CornerRadius = UDim.new(0, 6)

local AuthStatus = Instance.new("TextLabel", AuthFrame)
AuthStatus.Size = UDim2.new(1, -32, 0, 30)
AuthStatus.Position = UDim2.new(0, 16, 0, 204)
AuthStatus.BackgroundTransparency = 1
AuthStatus.Text = "Discord access is optional."
AuthStatus.Font = Enum.Font.GothamSemibold
AuthStatus.TextSize = 9
AuthStatus.TextWrapped = true
AuthStatus.TextColor3 = Styles.TextDark

HookButtonAnimations(CopyDiscordBtn, Styles.Accent, Styles.Accent:Lerp(Color3.fromRGB(255, 255, 255), 0.15))
HookButtonAnimations(IgnoreBtn, Styles.CardBg, Styles.CardHover)

local authDragging = false
local authDragInput = nil
local authDragStart = nil
local authStartPos = nil

AuthHeader.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		authDragging = true
		authDragStart = input.Position
		authStartPos = AuthFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				authDragging = false
			end
		end)
	end
end)

AuthHeader.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		authDragInput = input
	end
end)

SafeConnect(UserInputService.InputChanged, function(input)
	if input == authDragInput and authDragging then
		local delta = input.Position - authDragStart
		AuthFrame.Position = UDim2.new(
			authStartPos.X.Scale,
			authStartPos.X.Offset + delta.X,
			authStartPos.Y.Scale,
			authStartPos.Y.Offset + delta.Y
		)
	end
end)

local function SetAuthStatus(text, color)
	AuthStatus.Text = text
	AuthStatus.TextColor3 = color or Styles.TextDark
end

CopyDiscordBtn.MouseButton1Click:Connect(function()
	if DiscordInvite:find("YOUR_INVITE", 1, true) then
		SetAuthStatus("Set your Discord invite in DiscordInvite first.", Color3.fromRGB(255, 190, 90))
		return
	end

	if setclipboard then
		setclipboard(DiscordInvite)
		SetAuthStatus("Discord invite copied.", Color3.fromRGB(90, 255, 130))
	else
		SetAuthStatus("Clipboard is unavailable: " .. DiscordInvite, Styles.TextMain)
	end
end)

IgnoreBtn.MouseButton1Click:Connect(function()
	AccessNoticeDismissed = true
	AuthFrame.Visible = false
	MainFrame.Visible = true

	if MobileControls then
		MobileControls.Visible = IsTouchDevice
	end

	UpdateMobileControlButtons()
	RefreshAllESP()
	SystemLogEvent("Welcome screen ignored. Hub unlocked.")
end)

local function UpdateResponsiveScale()
	local viewport = Camera.ViewportSize

	if MainUIScale then
		local widthScale = (viewport.X * 0.92) / 540
		local heightScale = (viewport.Y * 0.86) / 415
		MainUIScale.Scale = math.clamp(math.min(widthScale, heightScale), 0.55, 1)
	end

	if AuthUIScale then
		local authWidthScale = (viewport.X * 0.92) / 390
		local authHeightScale = (viewport.Y * 0.86) / 250
		AuthUIScale.Scale = math.clamp(math.min(authWidthScale, authHeightScale), 0.62, 1)
	end
end

UpdateResponsiveScale()
SafeConnect(Camera:GetPropertyChangedSignal("ViewportSize"), UpdateResponsiveScale)

MainFrame.Visible = false
AuthFrame.Visible = true
MobileControls.Visible = false
UpdateKeybindValueButtons()
UpdateLeftPanelShortcuts()
