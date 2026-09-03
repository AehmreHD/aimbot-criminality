-- // AEHMRE ULTIMATE HUB - JJSPLOIT SYNTAX FIX //
-- MADE BY: Emre_31er
local Lighting = game:GetService("Lighting")

--// Cross-Script Hot-Reload State Transfer Engine
local CurrentScriptID = "Aehmre_AimHub_v1"
local env = nil

pcall(function()
	if typeof(getgenv) == "function" then
		env = getgenv()
	end
end)

if typeof(env) ~= "table" then
	if typeof(shared) == "table" then
		env = shared
	else
		env = _G
	end
end
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

local UI = {}

UI.BootGui = Instance.new("ScreenGui")
UI.BootGui.Name = "AehmreHubBoot"
UI.BootGui.ResetOnSpawn = false
UI.BootGui.DisplayOrder = 1000000
UI.BootGui.Parent = PlayerGui

UI.BootLabel = Instance.new("TextLabel")
UI.BootLabel.AnchorPoint = Vector2.new(0.5, 0.5)
UI.BootLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
UI.BootLabel.Size = UDim2.new(0, 300, 0, 48)
UI.BootLabel.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
UI.BootLabel.BackgroundTransparency = 0.12
UI.BootLabel.BorderSizePixel = 0
UI.BootLabel.Font = Enum.Font.GothamBold
UI.BootLabel.TextSize = 13
UI.BootLabel.TextColor3 = Color3.fromRGB(245, 245, 248)
UI.BootLabel.Text = "Aehmre Ultimate Hub\nLoading core..."
UI.BootLabel.Parent = UI.BootGui
Instance.new("UICorner", UI.BootLabel).CornerRadius = UDim.new(0, 8)

local function SetBootStatus(message)
	if UI.BootLabel and UI.BootLabel.Parent then
	\tUI.BootLabel.Text = "Aehmre Ultimate Hub\n" .. tostring(message)
	end
	print("[HubBoot] " .. tostring(message))
end

SetBootStatus("Loading systems...")

local Compat = {
	Executor = "Unknown",
	Version = "",
	Capabilities = {},
	Warned = {},
	BootStarted = os.clock()
}

function Compat.Log(stage, message)
	print(string.format("[HubDebug][%s] %s", tostring(stage), tostring(message)))
end

function Compat.WarnOnce(key, message)
	if Compat.Warned[key] then return end
	Compat.Warned[key] = true
	print(string.format("[HubDebug][COMPAT-WARN] %s", tostring(message)))
end

function Compat.Detect()
	pcall(function()
		if typeof(identifyexecutor) == "function" then
			local name, version = identifyexecutor()
			Compat.Executor = tostring(name or "Unknown")
			Compat.Version = tostring(version or "")
		elseif typeof(getexecutorname) == "function" then
			Compat.Executor = tostring(getexecutorname() or "Unknown")
		end
	end)

	Compat.Capabilities.Drawing = typeof(Drawing) == "table" and typeof(Drawing.new) == "function"
	Compat.Capabilities.MousePress = typeof(mouse1press) == "function"
	Compat.Capabilities.MouseRelease = typeof(mouse1release) == "function"
	Compat.Capabilities.Clipboard = typeof(setclipboard) == "function"
	Compat.Capabilities.GetGenv = typeof(getgenv) == "function"

	Compat.Log("EXECUTOR", Compat.Executor .. (Compat.Version ~= "" and (" " .. Compat.Version) or ""))

	for name, available in pairs(Compat.Capabilities) do
		Compat.Log("CAPABILITY", name .. "=" .. (available and "OK" or "MISSING"))
	end
end

function Compat.NewDrawing(className)
	if Compat.Capabilities.Drawing then
		local ok, object = pcall(function()
			return Drawing.new(className)
		end)

		if ok and object then
			return object
		end

		Compat.WarnOnce("DrawingCreate", "Drawing.new failed. Drawing visuals will be disabled.")
	else
		Compat.WarnOnce("DrawingMissing", "Drawing API is unavailable. Drawing visuals will be disabled.")
	end

	local dummy = {
		Visible = false
	}

	function dummy:Remove()
		self.Visible = false
	end

	return dummy
end

function Compat.MouseDown()
	if Compat.Capabilities.MousePress then
		local ok = pcall(mouse1press)
		if ok then return true end
		Compat.WarnOnce("MousePressFailed", "mouse1press exists but failed.")
	end

	return false
end

function Compat.MouseUp()
	if Compat.Capabilities.MouseRelease then
		local ok = pcall(mouse1release)
		if ok then return true end
		Compat.WarnOnce("MouseReleaseFailed", "mouse1release exists but failed.")
	end

	return false
end

function Compat.Trace(label, callback, ...)
	local args = table.pack(...)
	local results = table.pack(xpcall(function()
		return callback(table.unpack(args, 1, args.n))
	end, function(err)
		local trace = debug and debug.traceback and debug.traceback(tostring(err), 2) or tostring(err)
		Compat.Log("ERROR", label .. " | " .. trace)
		return trace
	end))

	if not results[1] then
		return false, results[2]
	end

	return true, table.unpack(results, 2, results.n)
end

Compat.Detect()
Compat.Log("BOOT", "Services initialized")

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
	ShowMarkedPlayerESP = false,
	KillMarkedWithFireAxe = false,
	FireAxeTeleportDelay = 0.5,
	ShowESPUsername = false,
	ESPUsernameSize = 14,
	OffscreenWarning = true,
	WarningIMGSize = 58,
	ShowFOV = true,
	FOVPulse = true,
	TargetIndicator = true,
	Fullbright = false,
	ShowFPS = false,
	EnableRemoteSpy = false,
	WallCheckDebug = false,
	TargetInfo = false,
	DetectPlayers = true,
	DetectNPCs = false,
	FarmEnabled = false,
	FarmAutoMoney = false,
	FarmInvisibility = false,
	InvisibilityMode = "Air",
	FarmInvisSpeed = 12,
	ExploitSimDamage = false,
	ExploitSimDamageAmount = 25,
	PanicMode = false,
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
	FarmInvisToggleKey = Enum.KeyCode.X,
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
local ConfigUIUpdaters = {}
local UpdateLeftPanelShortcuts = function() end

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

local StrokePalette = {
	Color3.fromRGB(235, 45, 60),
	Color3.fromRGB(70, 235, 120),
	Color3.fromRGB(245, 245, 248)
}

local StrokePaletteCursor = 0

local function ApplyPaletteStroke(stroke, forcedIndex)
	local index = forcedIndex
	if not index then
		StrokePaletteCursor = (StrokePaletteCursor % #StrokePalette) + 1
		index = StrokePaletteCursor
	end
	stroke:SetAttribute("AehmreStrokePaletteIndex", index)
	stroke.Color = StrokePalette[index]
	return StrokePalette[index]
end

local function GetPaletteStrokeColor(stroke)
	local index = stroke:GetAttribute("AehmreStrokePaletteIndex")
	return StrokePalette[index] or StrokePalette[3]
end

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

SetBootStatus("Loading Remote Spy...")

local RemoteSpy = (function()
	local State = {
		MaxLines = 80,
		WindowSeconds = 45,
		LineTimes = {},
		CallID = 0,
		MaxStringLength = 140,
		MaxTableItems = 10,
		MaxTableDepth = 2
	}

	local function TrimOldLines(now)
		local firstValid = 1

		while firstValid <= #State.LineTimes and now - State.LineTimes[firstValid] >= State.WindowSeconds do
			firstValid += 1
		end

		if firstValid > 1 then
			local remaining = {}

			for index = firstValid, #State.LineTimes do
				remaining[#remaining + 1] = State.LineTimes[index]
			end

			State.LineTimes = remaining
		end
	end

	local function CanEmit()
		if not Settings.EnableRemoteSpy then return false end

		local now = os.clock()
		TrimOldLines(now)

		if #State.LineTimes >= State.MaxLines then
			return false
		end

		State.LineTimes[#State.LineTimes + 1] = now
		return true
	end

	local function Emit(message)
		if CanEmit() then
			print("[RemoteSpy] " .. tostring(message))
		end
	end

	local function SafeInstancePath(object)
		if typeof(object) ~= "Instance" then return tostring(object) end

		local ok, fullName = pcall(function()
			return object:GetFullName()
		end)

		if ok then
			return fullName
		end

		return object.Name
	end

	local function FormatValue(value, depth, visited)
		local valueType = typeof(value)
		depth = depth or 0
		visited = visited or {}

		if valueType == "nil" then return "nil" end
		if valueType == "boolean" or valueType == "number" then return tostring(value) end

		if valueType == "string" then
			local result = value

			if #result > State.MaxStringLength then
				result = result:sub(1, State.MaxStringLength) .. "..."
			end

			return string.format("%q", result)
		end

		if valueType == "Instance" then
			return string.format("<%s> %s", value.ClassName, SafeInstancePath(value))
		end

		if valueType == "EnumItem" then
			return tostring(value)
		end

		if valueType == "Vector2" then
			return string.format("Vector2(%.2f, %.2f)", value.X, value.Y)
		end

		if valueType == "Vector3" then
			return string.format("Vector3(%.2f, %.2f, %.2f)", value.X, value.Y, value.Z)
		end

		if valueType == "CFrame" then
			local position = value.Position
			return string.format("CFrame(Position=%.2f, %.2f, %.2f)", position.X, position.Y, position.Z)
		end

		if valueType == "Color3" then
			return string.format("Color3(%.3f, %.3f, %.3f)", value.R, value.G, value.B)
		end

		if valueType == "UDim2" then
			return tostring(value)
		end

		if valueType == "table" then
			if visited[value] then return "<recursive table>" end
			if depth >= State.MaxTableDepth then return "{...}" end

			visited[value] = true

			local entries = {}
			local count = 0

			for key, item in pairs(value) do
				count += 1

				if count > State.MaxTableItems then
					entries[#entries + 1] = "..."
					break
				end

				entries[#entries + 1] = string.format(
					"[%s]=%s",
					FormatValue(key, depth + 1, visited),
					FormatValue(item, depth + 1, visited)
				)
			end

			visited[value] = nil
			return "{" .. table.concat(entries, ", ") .. "}"
		end

		return string.format("<%s> %s", valueType, tostring(value))
	end

	local function LogCall(remote, method, args)
		if not Settings.EnableRemoteSpy then return end

		State.CallID += 1
		local id = State.CallID
		local remotePath = SafeInstancePath(remote)
		local remoteClass = remote and remote.ClassName or "Unknown"

		Emit(string.format(
			"#%d %s | %s | Class=%s | Args=%d",
			id,
			method,
			remotePath,
			remoteClass,
			args.n
		))

		for index = 1, args.n do
			if not Settings.EnableRemoteSpy then break end

			Emit(string.format(
				"#%d ARG[%d] | Type=%s | %s",
				id,
				index,
				typeof(args[index]),
				FormatValue(args[index])
			))
		end
	end

	local function LogReturns(id, packedReturns)
		if not Settings.EnableRemoteSpy then return end

		for index = 1, packedReturns.n do
			Emit(string.format(
				"#%d RETURN[%d] | Type=%s | %s",
				id,
				index,
				typeof(packedReturns[index]),
				FormatValue(packedReturns[index])
			))
		end
	end

	local function Fire(remote, ...)
		if not remote or not remote:IsA("RemoteEvent") then
			Emit("Fire blocked: invalid RemoteEvent")
			return nil
		end

		local args = table.pack(...)
		LogCall(remote, "FireServer", args)
		return remote:FireServer(table.unpack(args, 1, args.n))
	end

	local function Invoke(remote, ...)
		if not remote or not remote:IsA("RemoteFunction") then
			Emit("Invoke blocked: invalid RemoteFunction")
			return nil
		end

		local args = table.pack(...)
		State.CallID += 1
		local id = State.CallID

		if Settings.EnableRemoteSpy then
			local remotePath = SafeInstancePath(remote)
			Emit(string.format(
				"#%d InvokeServer | %s | Class=%s | Args=%d",
				id,
				remotePath,
				remote.ClassName,
				args.n
			))

			for index = 1, args.n do
				Emit(string.format(
					"#%d ARG[%d] | Type=%s | %s",
					id,
					index,
					typeof(args[index]),
					FormatValue(args[index])
				))
			end
		end

		local packedReturns = table.pack(remote:InvokeServer(table.unpack(args, 1, args.n)))
		LogReturns(id, packedReturns)

		return table.unpack(packedReturns, 1, packedReturns.n)
	end

	local function ResetWindow()
		State.LineTimes = {}
		State.CallID = 0
	end

	local function PrintStatus()
		if not Settings.EnableRemoteSpy then return end

		Emit(string.format(
			"ENABLED | Hub-owned remotes only | Limit=%d lines / %ds",
			State.MaxLines,
			State.WindowSeconds
		))
	end

	local IncomingConnections = {}
	local DescendantConnection = nil

	local function DisconnectIncoming()
		for remote, connection in pairs(IncomingConnections) do
			if connection then
				pcall(function() connection:Disconnect() end)
			end
			IncomingConnections[remote] = nil
		end

		if DescendantConnection then
			DescendantConnection:Disconnect()
			DescendantConnection = nil
		end
	end

	local function WatchIncomingRemote(remote)
		if not remote or not remote:IsA("RemoteEvent") or IncomingConnections[remote] then return end

		IncomingConnections[remote] = remote.OnClientEvent:Connect(function(...)
			if not Settings.EnableRemoteSpy then return end

			local args = table.pack(...)
			State.CallID += 1
			local id = State.CallID

			Emit(string.format(
				"#%d OnClientEvent | %s | Class=%s | Args=%d",
				id,
				SafeInstancePath(remote),
				remote.ClassName,
				args.n
			))

			for index = 1, args.n do
				Emit(string.format(
					"#%d ARG[%d] | Type=%s | %s",
					id,
					index,
					typeof(args[index]),
					FormatValue(args[index])
				))
			end
		end)
	end

	local function EnableIncomingSpy()
		DisconnectIncoming()

		for _, object in ipairs(game:GetDescendants()) do
			if object:IsA("RemoteEvent") then
				WatchIncomingRemote(object)
			end
		end

		DescendantConnection = game.DescendantAdded:Connect(function(object)
			if object:IsA("RemoteEvent") then
				WatchIncomingRemote(object)
			end
		end)
	end

	local API = {
		Fire = Fire,
		Invoke = Invoke,
		ResetWindow = ResetWindow,
		PrintStatus = PrintStatus,
		EnableIncomingSpy = EnableIncomingSpy,
		DisableIncomingSpy = DisconnectIncoming
	}

	return API
end)()

env.AehmreRemoteSpy = RemoteSpy


Compat.Log("BOOT", "Initializing Farm system")

SetBootStatus("Loading Farm...")

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
	local FarmPanicHealthConnection = nil
	local FarmPanicDiedConnection = nil
	local FarmPanicCharacterConnection = nil
	local FarmPanicBoundCharacter = nil
	local FarmPanicTriggeredForLife = false
	local FarmPanicActivatedInvisibility = false
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

		local destination = GetFarmPositionInFront(targetPart, hrp.Position)
		if not destination then return false end

		FarmStatus = "Pathfinding"

		local waypoints = ComputeFarmPath(hrp.Position, destination)
		if not waypoints then
			FarmStatus = "Path failed"
			return false
		end

		for _, waypoint in ipairs(waypoints) do
			if not Settings.FarmEnabled then
				FarmStatus = "Idle"
				return false
			end

			character, humanoid, hrp = GetFarmCharacter()
			if not character or not humanoid or humanoid.Health <= 0 or not hrp then
				FarmStatus = "Idle"
				return false
			end

			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid.Jump = true
			end

			humanoid:MoveTo(waypoint.Position)

			local finished = false
			local reached = false
			local connection

			connection = humanoid.MoveToFinished:Connect(function(didReach)
				reached = didReach
				finished = true
			end)

			local started = tick()

			while not finished and tick() - started < 4 do
				if not Settings.FarmEnabled or humanoid.Health <= 0 then
					break
				end
				task.wait(0.05)
			end

			if connection then
				connection:Disconnect()
			end

			if not reached then
				FarmStatus = "Path blocked"
				return false
			end
		end

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
			RemoteSpy.Fire(openRemote, true, "shop", mainPart, "IllegalStore")
		end)
		task.wait(0.8)
		pcall(function()
			RemoteSpy.Invoke(buyRemote, "IllegalStore", "Melees", "Crowbar", mainPart, nil, true)
		end)
		task.wait(2)
		pcall(function()
			RemoteSpy.Fire(openRemote, false)
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
				return RemoteSpy.Invoke(remote1, "🍞", tick(), crowbar, "DZDRRRKI", targetObject, "Register")
			end)
			if success and result then
				pcall(function()
					RemoteSpy.Fire(remote2, "🍞", tick(), crowbar, "2389ZFX34", result, false, arm, mainPart, targetObject, mainPart.Position, mainPart.Position)
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
					RemoteSpy.Fire(pickupRemote, money)
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
							RemoteSpy.Fire(pickupRemote, nearest)
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

	local FarmInvisWarningGui = nil
	local FarmInvisWarningLabel = nil
	local FarmInvisCharacter = nil
	local FarmInvisHumanoid = nil
	local FarmInvisHrp = nil
	local FarmInvisPossible = true
	local FarmInvisActiveMode = nil
	local FarmBottomDepth = 3.25
	local FarmBottomLastGroundY = nil

	local FarmBottomRaycastParams = RaycastParams.new()
	FarmBottomRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	FarmBottomRaycastParams.IgnoreWater = true

	local function UpdateFarmInvisCharacter()
		FarmInvisCharacter = LocalPlayer.Character

		if FarmInvisCharacter then
			FarmInvisHrp = FarmInvisCharacter:FindFirstChild("HumanoidRootPart")
			FarmInvisHumanoid = FarmInvisCharacter:FindFirstChildOfClass("Humanoid")
		else
			FarmInvisHrp = nil
			FarmInvisHumanoid = nil
		end
	end

	local function EnsureFarmInvisWarning()
		if FarmInvisWarningGui and FarmInvisWarningGui.Parent then return end

		FarmInvisWarningGui = Instance.new("UI.ScreenGui")
		FarmInvisWarningGui.Name = "AehmreInvisWarningGUI"
		FarmInvisWarningGui.ResetOnSpawn = false
		FarmInvisWarningGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		FarmInvisWarningGui.Parent = PlayerGui

		FarmInvisWarningLabel = Instance.new("TextLabel")
		FarmInvisWarningLabel.Text = "⚠️ YOU ARE VISIBLE ⚠️"
		FarmInvisWarningLabel.Visible = false
		FarmInvisWarningLabel.Size = UDim2.new(0, 260, 0, 30)
		FarmInvisWarningLabel.Position = UDim2.new(0.5, -130, 0.85, 0)
		FarmInvisWarningLabel.BackgroundTransparency = 1
		FarmInvisWarningLabel.Font = Enum.Font.GothamSemibold
		FarmInvisWarningLabel.TextSize = 24
		FarmInvisWarningLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
		FarmInvisWarningLabel.TextStrokeTransparency = 0.5
		FarmInvisWarningLabel.ZIndex = 10
		FarmInvisWarningLabel.Parent = FarmInvisWarningGui
	end

	local function IsFarmInvisGrounded()
		return FarmInvisHumanoid
			and FarmInvisHumanoid:IsDescendantOf(workspace)
			and FarmInvisHumanoid.FloorMaterial ~= Enum.Material.Air
	end

	local function LoadFarmInvisAnimation()
		if FarmInvisAnimTrack then
			pcall(function()
				FarmInvisAnimTrack:Stop()
			end)

			FarmInvisAnimTrack = nil
		end

		if not FarmInvisHumanoid then return end

		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://215384594"

		local success, track = pcall(function()
			return FarmInvisHumanoid:LoadAnimation(animation)
		end)

		if success then
			FarmInvisAnimTrack = track
			FarmInvisAnimTrack.Priority = Enum.AnimationPriority.Action4
		end
	end

	local function GetFarmBottomGroundY(position)
		if not FarmInvisCharacter then return nil end

		FarmBottomRaycastParams.FilterDescendantsInstances = {FarmInvisCharacter}

		local origin = Vector3.new(position.X, position.Y + 10, position.Z)
		local result = workspace:Raycast(origin, Vector3.new(0, -30, 0), FarmBottomRaycastParams)

		if result then
			return result.Position.Y
		end

		return nil
	end

	local function StartFarmBottomInvisibility()
		FarmInvisActiveMode = "Bottom"
		FarmInvisPossible = true
		FarmBottomLastGroundY = nil

		if FarmInvisAnimTrack then
			pcall(function()
				FarmInvisAnimTrack:Stop()
			end)
			FarmInvisAnimTrack = nil
		end

		if FarmInvisWarningLabel then
			FarmInvisWarningLabel.Visible = false
		end

		Camera.CameraSubject = FarmInvisHumanoid

		FarmInvisConnection = RunService.Heartbeat:Connect(function(dt)
			if not Settings.FarmInvisibility or Settings.InvisibilityMode ~= "Bottom" then return end

			local currentCharacter = LocalPlayer.Character

			if currentCharacter ~= FarmInvisCharacter then
				task.wait()
				UpdateFarmInvisCharacter()
				FarmBottomLastGroundY = nil
			end

			if not FarmInvisCharacter
				or not FarmInvisHumanoid
				or not FarmInvisHrp
				or not FarmInvisHumanoid:IsDescendantOf(workspace)
				or FarmInvisHumanoid.Health <= 0 then
				return
			end

			local position = FarmInvisHrp.Position
			local moveDirection = FarmInvisHumanoid.MoveDirection

			if moveDirection.Magnitude > 0 then
				position += moveDirection.Unit * Settings.FarmInvisSpeed * dt
			end

			local groundY = GetFarmBottomGroundY(position)
			if groundY then
				FarmBottomLastGroundY = groundY
				position = Vector3.new(position.X, groundY - FarmBottomDepth, position.Z)
			elseif FarmBottomLastGroundY then
				position = Vector3.new(position.X, FarmBottomLastGroundY - FarmBottomDepth, position.Z)
			end

			local lookVec = Camera.CFrame.LookVector
			local flatLook = Vector3.new(lookVec.X, 0, lookVec.Z)

			if flatLook.Magnitude < 0.1 then
				flatLook = Vector3.new(0, 0, -1)
			else
				flatLook = flatLook.Unit
			end

			FarmInvisHrp.CFrame = CFrame.new(position, position + flatLook)
			FarmInvisHrp.AssemblyLinearVelocity = Vector3.zero
			FarmInvisHrp.AssemblyAngularVelocity = Vector3.zero
		end)

		FarmLog("Invisibility enabled (Bottom)")
	end

	local function DisableFarmInvisibility()
		local activeMode = FarmInvisActiveMode
		Settings.FarmInvisibility = false

		if FarmInvisConnection then
			FarmInvisConnection:Disconnect()
			FarmInvisConnection = nil
		end

		if activeMode == "Bottom" and FarmInvisHrp and FarmInvisHrp:IsDescendantOf(workspace) and FarmBottomLastGroundY then
			local position = FarmInvisHrp.Position
			local restorePosition = Vector3.new(position.X, FarmBottomLastGroundY + 3, position.Z)
			FarmInvisHrp.CFrame = CFrame.new(restorePosition) * (FarmInvisHrp.CFrame - FarmInvisHrp.CFrame.Position)
			FarmInvisHrp.AssemblyLinearVelocity = Vector3.zero
			FarmInvisHrp.AssemblyAngularVelocity = Vector3.zero
		end

		FarmBottomLastGroundY = nil
		FarmInvisActiveMode = nil

		if FarmInvisAnimTrack then
			pcall(function()
				FarmInvisAnimTrack:Stop()
			end)

			FarmInvisAnimTrack = nil
		end

		UpdateFarmInvisCharacter()

		if FarmInvisHumanoid then
			Camera.CameraSubject = FarmInvisHumanoid
		end

		if FarmInvisCharacter then
			for _, part in pairs(FarmInvisCharacter:GetDescendants()) do
				if part:IsA("BasePart") and part.Transparency == 0.5 then
					part.Transparency = 0
				end
			end
		end

		if FarmInvisWarningLabel then
			FarmInvisWarningLabel.Visible = false
		end

		FarmLog("Invisibility disabled")
	end

	local function EnableFarmInvisibility()
		if FarmInvisConnection then return end

		UpdateFarmInvisCharacter()
		EnsureFarmInvisWarning()

		if not FarmInvisCharacter or not FarmInvisHumanoid or not FarmInvisHrp then
			Settings.FarmInvisibility = false
			return
		end

		if Settings.InvisibilityMode == "Bottom" then
			StartFarmBottomInvisibility()
			return
		end

		FarmInvisActiveMode = "Air"

		if not FarmInvisCharacter:FindFirstChild("Torso") or FarmInvisHumanoid.RigType ~= Enum.HumanoidRigType.R6 then
			Settings.FarmInvisibility = false
			FarmInvisPossible = false

			pcall(function()
				game:GetService("StarterGui"):SetCore("SendNotification", {
					UI.Title = "Invisibility unavailable",
					Text = "R6 avatar required",
					Duration = 5
				})
			end)

			FarmLog("Invisibility requires R6")
			return
		end

		FarmInvisPossible = true
		Camera.CameraSubject = FarmInvisHrp
		LoadFarmInvisAnimation()

		FarmInvisConnection = RunService.Heartbeat:Connect(function(dt)
			if not Settings.FarmInvisibility or Settings.InvisibilityMode ~= "Air" or not FarmInvisPossible then
				if FarmInvisWarningLabel then
					FarmInvisWarningLabel.Visible = false
				end

				return
			end

			local currentCharacter = LocalPlayer.Character

			if currentCharacter ~= FarmInvisCharacter then
				if FarmInvisAnimTrack then
					pcall(function()
						FarmInvisAnimTrack:Stop()
					end)

					FarmInvisAnimTrack = nil
				end

				task.wait()
				UpdateFarmInvisCharacter()

				if not FarmInvisCharacter or not FarmInvisHumanoid or not FarmInvisHrp then
					return
				end

				if FarmInvisHumanoid.RigType ~= Enum.HumanoidRigType.R6 or not FarmInvisCharacter:FindFirstChild("Torso") then
					FarmInvisPossible = false
					Settings.FarmInvisibility = false

					if FarmInvisWarningLabel then
						FarmInvisWarningLabel.Visible = false
					end

					return
				end

				FarmInvisPossible = true
				Camera.CameraSubject = FarmInvisHrp
				LoadFarmInvisAnimation()
			end

			if not FarmInvisCharacter
				or not FarmInvisHumanoid
				or not FarmInvisHrp
				or not FarmInvisHumanoid:IsDescendantOf(workspace)
				or FarmInvisHumanoid.Health <= 0 then

				if FarmInvisWarningLabel then
					FarmInvisWarningLabel.Visible = false
				end

				return
			end

			if FarmInvisWarningLabel then
				FarmInvisWarningLabel.Visible = not IsFarmInvisGrounded()
			end

			local speed = Settings.FarmInvisSpeed

			if FarmInvisHumanoid.MoveDirection.Magnitude > 0 then
				local move = FarmInvisHumanoid.MoveDirection * speed * dt
				FarmInvisHrp.CFrame = FarmInvisHrp.CFrame + move
			end

			local originalCF = FarmInvisHrp.CFrame
			local originalCamOffset = FarmInvisHumanoid.CameraOffset
			local _, cameraYaw = Camera.CFrame:ToOrientation()

			FarmInvisHrp.CFrame = CFrame.new(FarmInvisHrp.CFrame.Position) * CFrame.fromOrientation(0, cameraYaw, 0)
			FarmInvisHrp.CFrame = FarmInvisHrp.CFrame * CFrame.Angles(math.rad(90), 0, 0)
			FarmInvisHumanoid.CameraOffset = Vector3.new(0, 1.44, 0)

			if FarmInvisAnimTrack then
				local success = pcall(function()
					if not FarmInvisAnimTrack.IsPlaying then
						FarmInvisAnimTrack:Play()
					end

					FarmInvisAnimTrack:AdjustSpeed(0)
					FarmInvisAnimTrack.TimePosition = 0.3
				end)

				if not success then
					LoadFarmInvisAnimation()
				end
			elseif FarmInvisHumanoid.Health > 0 then
				LoadFarmInvisAnimation()
			end

			RunService.RenderStepped:Wait()

			if FarmInvisHumanoid and FarmInvisHumanoid:IsDescendantOf(workspace) then
				FarmInvisHumanoid.CameraOffset = originalCamOffset
			end

			if FarmInvisHrp and FarmInvisHrp:IsDescendantOf(workspace) then
				FarmInvisHrp.CFrame = originalCF
			end

			if FarmInvisAnimTrack then
				pcall(function()
					FarmInvisAnimTrack:Stop()
				end)
			end

			if FarmInvisHrp and FarmInvisHrp:IsDescendantOf(workspace) then
				local lookVec = Camera.CFrame.LookVector
				local flatLook = Vector3.new(lookVec.X, 0, lookVec.Z)

				if flatLook.Magnitude > 0.1 then
					flatLook = flatLook.Unit
					FarmInvisHrp.CFrame = CFrame.new(FarmInvisHrp.Position, FarmInvisHrp.Position + flatLook)
				end
			end

			if FarmInvisCharacter then
				for _, part in pairs(FarmInvisCharacter:GetDescendants()) do
					if part:IsA("BasePart") and part.Transparency ~= 1 then
						part.Transparency = 0.5
					end
				end
			end
		end)

		FarmLog("Invisibility enabled (Air)")
	end

	local function RefreshFarmInvisibilityUI()
		if ConfigUIUpdaters.FarmInvisibility then
			ConfigUIUpdaters.FarmInvisibility()
		end

		UpdateLeftPanelShortcuts()
	end

	local function TriggerFarmPanicInvisibility()
		if FarmPanicTriggeredForLife then return end

		FarmPanicTriggeredForLife = true

		if Settings.FarmInvisibility then
			FarmLog("PanicMode triggered, invisibility was already enabled")
			return
		end

		Settings.FarmInvisibility = true
		FarmPanicActivatedInvisibility = true
		EnableFarmInvisibility()

		if not Settings.FarmInvisibility then
			FarmPanicActivatedInvisibility = false
			FarmLog("PanicMode could not enable invisibility")
		else
			FarmLog("PanicMode triggered below 15 HP")
		end

		RefreshFarmInvisibilityUI()
	end

	local function CheckFarmPanicHealth(humanoid)
		if not Settings.PanicMode or FarmPanicTriggeredForLife then return end
		if not humanoid or humanoid.Health <= 0 then return end

		if humanoid.Health < 15 then
			TriggerFarmPanicInvisibility()
		end
	end

	local function DisconnectFarmPanicHumanoid()
		if FarmPanicHealthConnection then
			FarmPanicHealthConnection:Disconnect()
			FarmPanicHealthConnection = nil
		end

		if FarmPanicDiedConnection then
			FarmPanicDiedConnection:Disconnect()
			FarmPanicDiedConnection = nil
		end

		FarmPanicBoundCharacter = nil
	end

	local function BindFarmPanicCharacter(character)
		DisconnectFarmPanicHumanoid()
		if not Settings.PanicMode or not character then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
		if not humanoid then return end

		FarmPanicBoundCharacter = character

		FarmPanicHealthConnection = humanoid.HealthChanged:Connect(function()
			CheckFarmPanicHealth(humanoid)
		end)

		FarmPanicDiedConnection = humanoid.Died:Connect(function()
			FarmLog("PanicMode detected death, waiting for respawn")
		end)

		CheckFarmPanicHealth(humanoid)
	end

	local function EnsureFarmPanicRespawnConnection()
		if FarmPanicCharacterConnection then return end

		FarmPanicCharacterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
			FarmPanicTriggeredForLife = false

			if FarmPanicActivatedInvisibility then
				FarmPanicActivatedInvisibility = false
				DisableFarmInvisibility()
				RefreshFarmInvisibilityUI()
			end

			if Settings.PanicMode then
				task.defer(BindFarmPanicCharacter, character)
			else
				DisconnectFarmPanicHumanoid()
			end
		end)
	end

	local function EnableFarmPanicMode()
		Settings.PanicMode = true
		EnsureFarmPanicRespawnConnection()

		local character = LocalPlayer.Character
		if character ~= FarmPanicBoundCharacter then
			BindFarmPanicCharacter(character)
		else
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			CheckFarmPanicHealth(humanoid)
		end

		FarmLog("PanicMode enabled")
	end

	local function DisableFarmPanicMode(fullCleanup)
		Settings.PanicMode = false
		DisconnectFarmPanicHumanoid()

		if fullCleanup and FarmPanicCharacterConnection then
			FarmPanicCharacterConnection:Disconnect()
			FarmPanicCharacterConnection = nil
			FarmPanicTriggeredForLife = false
			FarmPanicActivatedInvisibility = false
		end

		FarmLog("PanicMode disabled")
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

	local function FarmCleanup()
		FarmLoopRunning = false
		FarmAutoMoneyRunning = false
		FarmSafeESPRunning = false
		Settings.FarmEnabled = false
		Settings.FarmAutoMoney = false
		Settings.FarmSafeESP = false
		Settings.PanicMode = false
		DisableFarmAntiAFK()
		DisableFarmPanicMode(true)
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
		EnablePanicMode = EnableFarmPanicMode,
		DisablePanicMode = DisableFarmPanicMode,
		EnableSafeESP = EnableFarmSafeESP,
		DisableSafeESP = DisableFarmSafeESP,
		Cleanup = FarmCleanup,
		SetLogHook = function(callback)
			FarmLogHook = callback
		end
	}
end)()

Compat.Log("BOOT", "Farm system initialized")

SetBootStatus("Loading Aim / ESP...")

--// Drawing Vector FOV Crosshair & Target Indicator Framework
local FOVIdleColor = Color3.fromRGB(220, 35, 45)

local FOVCircle = Compat.NewDrawing("Circle")
FOVCircle.Color = FOVIdleColor
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Visible = false

local TargetDot = Compat.NewDrawing("Circle")
TargetDot.Color = Styles.Accent
TargetDot.Thickness = 1
TargetDot.Filled = true
TargetDot.Radius = 4
TargetDot.Visible = false
TargetDot.ZIndex = 2

local FPSDisplay = Compat.NewDrawing("Text")
FPSDisplay.Text = "FPS: 0"
FPSDisplay.Size = 16
FPSDisplay.Position = Vector2.new(12, 12)
FPSDisplay.Color = Styles.Accent
FPSDisplay.Outline = true
FPSDisplay.Visible = false
FPSDisplay.ZIndex = 3

local WallDebugLine = Compat.NewDrawing("Line")
WallDebugLine.Thickness = 2
WallDebugLine.Color = Color3.fromRGB(80, 255, 120)
WallDebugLine.Visible = false
WallDebugLine.ZIndex = 3

local TargetInfoText = Compat.NewDrawing("Text")
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
local AimTargetRefreshTimer = 0
local AimTargetRefreshInterval = 0.08

local TrackedNPCs = {}
local MarkedESP = {
	SelectedPlayer = nil,
	DropdownAddOrUpdate = nil,
	DropdownRemove = nil,
	DropdownUpdateSelection = nil,
	Color = Color3.fromRGB(255, 235, 45)
}

local OffscreenIndicators = {}
local OffscreenThreatCache = {}
local OffscreenOverlay = nil
local OffscreenFarColor = Color3.fromRGB(255, 210, 45)
local OffscreenNearColor = Color3.fromRGB(255, 45, 45)
local OffscreenLookDotThreshold = 0.92
local OffscreenThreatCheckInterval = 0.10

local OffscreenLookRaycastParams = RaycastParams.new()
OffscreenLookRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
OffscreenLookRaycastParams.IgnoreWater = true

local function IsSelfCharacter(character)
	if not character or not character:IsA("Model") then return false end
	if character == LocalPlayer.Character then return true end
	local owner = Players:GetPlayerFromCharacter(character)
	return owner == LocalPlayer
end

local function IsNPCModel(model)
	if not model or not model:IsA("Model") then return false end
	if IsSelfCharacter(model) then return false end
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
		if object:IsA("Highlight") and (object.Name == "TestESP_Highlight" or object.Name == "Ligia_Premium_ESP" or object.Name == "AehmreMarkedPlayerESP") then
			pcall(function() object:Destroy() end)
		elseif object:IsA("BillboardGui") and object.Name == "TestESP_Username" then
			pcall(function() object:Destroy() end)
		end
	end

	for player, indicator in pairs(OffscreenIndicators) do
		if indicator then pcall(function() indicator:Destroy() end) end
		OffscreenIndicators[player] = nil
		OffscreenThreatCache[player] = nil
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

local function UpdateMarkedPlayerESP(player)
	if player == LocalPlayer then return end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local highlight = character:FindFirstChild("AehmreMarkedPlayerESP")
	local shouldShow = AccessNoticeDismissed
		and Settings.Enabled
		and Settings.ShowMarkedPlayerESP
		and player == MarkedESP.SelectedPlayer
		and humanoid
		and humanoid.Health > 0

	if shouldShow then
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "AehmreMarkedPlayerESP"
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = character
		end

		highlight.FillColor = MarkedESP.Color
		highlight.OutlineColor = Color3.fromRGB(255, 255, 190)
		highlight.FillTransparency = 0.12
		highlight.OutlineTransparency = 0
	elseif highlight then
		highlight:Destroy()
	end
end

local function UpdatePlayerUsernameESP(player, color)
	if player == LocalPlayer then return end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local adornee = character:FindFirstChild("Head") or GetCharacterRoot(character)
	local billboard = character:FindFirstChild("TestESP_Username")
	local isMarked = Settings.ShowMarkedPlayerESP and player == MarkedESP.SelectedPlayer
	local showNormalUsername = Settings.ESPEnabled and Settings.DetectPlayers and Settings.ShowESPUsername
	local shouldShow = AccessNoticeDismissed
		and Settings.Enabled
		and (showNormalUsername or isMarked)
		and humanoid
		and humanoid.Health > 0
		and adornee

	if shouldShow then
		if not billboard then
			billboard = Instance.new("BillboardGui")
			billboard.Name = "TestESP_Username"
			billboard.Size = UDim2.new(0, 220, 0, 44)
			billboard.StudsOffset = Vector3.new(0, 3, 0)
			billboard.AlwaysOnTop = true
			billboard.Parent = character

			local label = Instance.new("TextLabel")
			label.Name = "Username"
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.GothamBold
			label.Parent = billboard
		end

		billboard.Adornee = adornee

		local label = billboard:FindFirstChild("Username")
		if label then
			label.Text = player.Name
			label.TextSize = Settings.ESPUsernameSize
			label.TextColor3 = isMarked and MarkedESP.Color or color
			label.TextStrokeColor3 = isMarked and MarkedESP.Color or Color3.new(0, 0, 0)
			label.TextStrokeTransparency = isMarked and 0.15 or 0.35
		end
	elseif billboard then
		billboard:Destroy()
	end
end

local function UpdatePlayerESP(player)
	if player == LocalPlayer then return end

	local character = player.Character
	if not character then return end

	local color = player.TeamColor and player.TeamColor.Color or Styles.Accent
	UpdateCharacterESP(character, color, Settings.DetectPlayers)
	UpdateMarkedPlayerESP(player)
	UpdatePlayerUsernameESP(player, color)
end

local function SetMarkedPlayer(player)
	local previous = MarkedESP.SelectedPlayer
	MarkedESP.SelectedPlayer = player

	if previous and previous ~= player then
		UpdatePlayerESP(previous)
	end

	if player then
		UpdatePlayerESP(player)
	end

	if MarkedESP.DropdownUpdateSelection then
		MarkedESP.DropdownUpdateSelection()
	end
end

local function ResetMarkedPlayerSelection()
	local previous = MarkedESP.SelectedPlayer
	MarkedESP.SelectedPlayer = nil

	if previous then
		UpdatePlayerESP(previous)
	end

	if MarkedESP.DropdownUpdateSelection then
		MarkedESP.DropdownUpdateSelection()
	end
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

		if MarkedESP.SelectedPlayer == player then
			ResetMarkedPlayerSelection()
		end

		if MarkedESP.DropdownAddOrUpdate then
			task.defer(MarkedESP.DropdownAddOrUpdate, player)
		end

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

	if not model then return end

	if IsSelfCharacter(model) or Players:GetPlayerFromCharacter(model) then
		TrackedNPCs[model] = nil
		return
	end

	RegisterNPC(model)
end

local function RefreshAllESP()
	for _, player in ipairs(Players:GetPlayers()) do
		UpdatePlayerESP(player)
	end

	for model in pairs(TrackedNPCs) do
		if not model.Parent or IsSelfCharacter(model) or Players:GetPlayerFromCharacter(model) then
			TrackedNPCs[model] = nil
		else
			UpdateNPCESP(model)
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

SafeConnect(Players.PlayerAdded, function(player)
	SetupESPPlayer(player)
	if MarkedESP.DropdownAddOrUpdate then
		task.defer(MarkedESP.DropdownAddOrUpdate, player)
	end
end)

SafeConnect(Players.PlayerRemoving, function(player)
	if MarkedESP.SelectedPlayer == player then
		ResetMarkedPlayerSelection()
	end

	if MarkedESP.DropdownRemove then
		MarkedESP.DropdownRemove(player)
	end

	local indicator = OffscreenIndicators[player]
	if indicator then
		indicator:Destroy()
		OffscreenIndicators[player] = nil
	end

	OffscreenThreatCache[player] = nil
end)

SafeConnect(LocalPlayer.CharacterAdded, function(character)
	Target = nil
	LastLoggedTarget = nil
	LastTargetHealth = 0
	TrackedNPCs[character] = nil
end)

SafeConnect(LocalPlayer.CharacterRemoving, function(character)
	Target = nil
	TrackedNPCs[character] = nil
end)

SafeConnect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
	if workspace.CurrentCamera then
		Camera = workspace.CurrentCamera
		Target = nil
	end
end)

SafeConnect(workspace.DescendantAdded, function(descendant)
	if descendant:IsA("Humanoid") or descendant.Name == "HumanoidRootPart" or descendant.Name == "UpperTorso" or descendant.Name == "Torso" then
		task.defer(TryRegisterNPCFromInstance, descendant)
	end
end)

local SystemLogEvent = function(msg)
	print("[Aehmre Ultimate Hub]", msg)
end

local function ControlClick(press)
	local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")

	if press then
		if Compat.MouseDown() then return end
		if tool then pcall(function() tool:Activate() end) end
	else
		if Compat.MouseUp() then return end
		if tool then pcall(function() tool:Deactivate() end) end
	end
end

local ToolEquipSpy = {
	CharacterConnection = nil,
	BoundCharacter = nil,
	MaxDescendants = 20,
	MaxOutputLength = 1800
}

local function GetRelativeToolPath(tool, object)
	local names = {}
	local current = object

	while current and current ~= tool do
		table.insert(names, 1, current.Name)
		current = current.Parent
	end

	return table.concat(names, ".")
end

local function PrintEquippedToolSnapshot(tool)
	if not tool or not tool:IsA("Tool") or tool.Parent ~= LocalPlayer.Character then return end

	task.delay(0.15, function()
		if not tool or not tool.Parent or tool.Parent ~= LocalPlayer.Character then return end

		local descendants = tool:GetDescendants()
		local shown = math.min(#descendants, ToolEquipSpy.MaxDescendants)
		local parts = {}

		for index = 1, shown do
			local object = descendants[index]
			parts[#parts + 1] = string.format(
				"%02d:%s<%s>",
				index,
				GetRelativeToolPath(tool, object),
				object.ClassName
			)
		end

		if #descendants > shown then
			parts[#parts + 1] = string.format("+%d more", #descendants - shown)
		end

		local message = string.format(
			"[ToolEquipSpy] EQUIPPED | Name=%s | ToolTip=%s | Descendants=%d | %s",
			tool.Name,
			tostring(tool.ToolTip),
			#descendants,
			table.concat(parts, " ; ")
		)

		if #message > ToolEquipSpy.MaxOutputLength then
			message = message:sub(1, ToolEquipSpy.MaxOutputLength) .. " ..."
		end

		print(message)
	end)
end
local function BindToolEquipSpy(character)
	if ToolEquipSpy.CharacterConnection then
		ToolEquipSpy.CharacterConnection:Disconnect()
		ToolEquipSpy.CharacterConnection = nil
	end

	ToolEquipSpy.BoundCharacter = character
	if not character then return end

	for _, object in ipairs(character:GetChildren()) do
		if object:IsA("Tool") then
			PrintEquippedToolSnapshot(object)
		end
	end

	ToolEquipSpy.CharacterConnection = character.ChildAdded:Connect(function(object)
		if object:IsA("Tool") then
			PrintEquippedToolSnapshot(object)
		end
	end)
end

BindToolEquipSpy(LocalPlayer.Character)

SafeConnect(LocalPlayer.CharacterAdded, function(character)
	task.defer(BindToolEquipSpy, character)
end)

local KillMarkedFireAxeRunning = false

local function FireAxeLog(message)
	print("[FireAxe]", message)
	SystemLogEvent(message)
end

local function ActivateFireAxe(axe)
	if axe and axe:IsA("Tool") then
		local ok = pcall(function()
			axe:Activate()
		end)

		if ok then
			return true
		end
	end

	ControlClick(true)
	task.wait(0.04)
	ControlClick(false)
	return true
end

local function UpdateKillMarkedFireAxeUI()
	Settings.KillMarkedWithFireAxe = false

	if ConfigUIUpdaters.KillMarkedWithFireAxe then
		ConfigUIUpdaters.KillMarkedWithFireAxe()
	end
end

local function NormalizeToolText(value)
	return tostring(value or ""):gsub("%s+", ""):lower()
end

local function IsFireAxeTool(object)
	if not object or not object:IsA("Tool") then return false end

	local name = NormalizeToolText(object.Name)
	local toolTip = NormalizeToolText(object.ToolTip)

	return name == "fireaxe"
		or name:find("fireaxe", 1, true) ~= nil
		or toolTip:find("fireaxe", 1, true) ~= nil
		or name:find("axe", 1, true) ~= nil
		or toolTip:find("axe", 1, true) ~= nil
end

local function FindFireAxe(container)
	if not container then return nil end

	for _, object in ipairs(container:GetChildren()) do
		if IsFireAxeTool(object) then
			return object
		end
	end

	return nil
end

local function GetSingleEquippedTool(character)
	if not character then return nil end

	local found = nil

	for _, object in ipairs(character:GetChildren()) do
		if object:IsA("Tool") then
			if found then
				return nil
			end

			found = object
		end
	end

	return found
end

local function GetFireAxe()
	local character = LocalPlayer.Character
	local backpack = LocalPlayer:FindFirstChild("Backpack")

	local namedAxe = FindFireAxe(character) or FindFireAxe(backpack)
	if namedAxe then return namedAxe end

	return GetSingleEquippedTool(character)
end

local function KillMarkedPlayerWithFireAxe()
	if KillMarkedFireAxeRunning then
		UpdateKillMarkedFireAxeUI()
		return
	end

	KillMarkedFireAxeRunning = true

	local targetPlayer = MarkedESP.SelectedPlayer

	if not targetPlayer or targetPlayer == LocalPlayer or targetPlayer.Parent ~= Players then
		FireAxeLog("Fire Axe action cancelled: no marked player selected.")
		KillMarkedFireAxeRunning = false
		UpdateKillMarkedFireAxeUI()
		return
	end

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local localRoot = character and GetCharacterRoot(character)

	local targetCharacter = targetPlayer.Character
	local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
	local targetRoot = targetCharacter and GetCharacterRoot(targetCharacter)

	if not character or not humanoid or humanoid.Health <= 0 or not localRoot then
		FireAxeLog("Fire Axe action cancelled: local character unavailable.")
		KillMarkedFireAxeRunning = false
		UpdateKillMarkedFireAxeUI()
		return
	end

	if not targetCharacter or not targetHumanoid or targetHumanoid.Health <= 0 or not targetRoot then
		FireAxeLog("Fire Axe action cancelled: marked player unavailable.")
		KillMarkedFireAxeRunning = false
		UpdateKillMarkedFireAxeUI()
		return
	end

	local axe = GetFireAxe()

	if not axe then
		local equipped = GetSingleEquippedTool(character)
		local equippedName = equipped and equipped.Name or "none"

		FireAxeLog("Fire Axe action cancelled: Fire Axe not found. Equipped Tool=" .. equippedName)
		KillMarkedFireAxeRunning = false
		UpdateKillMarkedFireAxeUI()
		return
	end

	if axe.Parent ~= character then
		pcall(function()
			humanoid:EquipTool(axe)
		end)
		task.wait(0.15)
	end

	axe = character:FindFirstChild("Fire Axe") or axe

	if not axe or axe.Parent ~= character then
		FireAxeLog("Fire Axe action cancelled: Fire Axe could not be equipped.")
		KillMarkedFireAxeRunning = false
		UpdateKillMarkedFireAxeUI()
		return
	end

	FireAxeLog("Fire Axe equipped. Starting attack before teleport.")
	ActivateFireAxe(axe)

	local delayTime = math.clamp(Settings.FireAxeTeleportDelay, 0.1, 5)
	FireAxeLog(string.format("Waiting %.1fs before teleport.", delayTime))
	task.wait(delayTime)

	character = LocalPlayer.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	localRoot = character and GetCharacterRoot(character)

	targetCharacter = targetPlayer.Character
	targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
	targetRoot = targetCharacter and GetCharacterRoot(targetCharacter)

	if not humanoid or humanoid.Health <= 0 or not localRoot or not targetHumanoid or targetHumanoid.Health <= 0 or not targetRoot then
		FireAxeLog("Fire Axe action cancelled during delay: character or target unavailable.")
		KillMarkedFireAxeRunning = false
		UpdateKillMarkedFireAxeUI()
		return
	end

	localRoot.CFrame = targetRoot.CFrame
	localRoot.AssemblyLinearVelocity = Vector3.zero
	localRoot.AssemblyAngularVelocity = Vector3.zero

	FireAxeLog(string.format("Teleported to marked player during Fire Axe attack: %s (delay %.1fs)", targetPlayer.Name, delayTime))

	KillMarkedFireAxeRunning = false
	UpdateKillMarkedFireAxeUI()
end

local function GetExploitSimHitRemote()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local remote = remotes and remotes:FindFirstChild("ExploitHit")
	if remote and remote:IsA("RemoteEvent") then return remote end
	return nil
end

local function ExploitSimHitTarget(target)
	if not Settings.ExploitSimDamage then return false end
	if not target or target == LocalPlayer or not target:IsA("Player") then return false end

	local character = target.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and GetCharacterRoot(character)
	if not humanoid or humanoid.Health <= 0 or not root then return false end

	local remote = GetExploitSimHitRemote()
	if not remote then return false end

	RemoteSpy.Fire(remote, target, Settings.ExploitSimDamageAmount)
	return true
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
	pcall(function()
		if OffscreenOverlay then OffscreenOverlay:Destroy() end
	end)
	pcall(function()
		if RemoteSpy and RemoteSpy.DisableIncomingSpy then
			RemoteSpy.DisableIncomingSpy()
		end
	end)

	if env.AehmreRemoteSpy == RemoteSpy then
		env.AehmreRemoteSpy = nil
	end

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
		if IsSelfCharacter(target) or Players:GetPlayerFromCharacter(target) then return false end
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
	if Settings.ExploitSimDamage then return true end
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
		if target == LocalPlayer or IsSelfCharacter(character) then return end
		local owner = Players:GetPlayerFromCharacter(character)
		if owner == LocalPlayer then return end

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
		local visible = Settings.ExploitSimDamage or not Settings.WallCheck or hasLineOfSight

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
			if not model.Parent or IsSelfCharacter(model) or Players:GetPlayerFromCharacter(model) then
				TrackedNPCs[model] = nil
			else
				EvaluateTarget(model, model)
			end
		end
	end

	return closestTarget
end

local function IsTargetValid(target)
	if not target or not IsTargetTypeEnabled(target) then return false end
	if target == LocalPlayer then return false end

	local localCharacter = LocalPlayer.Character
	local character = GetTargetCharacter(target)

	if not localCharacter or not character then return false end
	if IsSelfCharacter(character) then return false end
	local owner = Players:GetPlayerFromCharacter(character)
	if owner == LocalPlayer then return false end

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

--// Protected Render Loop Connection Array
RunService:BindToRenderStep("AimLockCameraUpdate", Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
	pcall(function()
		deltaTime = deltaTime or 0.016 

		FPSUpdateTimer += deltaTime
		DebugInfoTimer += deltaTime
		DebugTargetRefreshTimer += deltaTime
		AimTargetRefreshTimer += deltaTime

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
			FOVCircle.Color = FOVIdleColor
			FOVCircle.Radius = Settings.FOVRadius
			FOVCircle.Transparency = 1
		end

		FOVCircle.Visible = AccessNoticeDismissed and Settings.Enabled and Settings.ShowFOV

		if AccessNoticeDismissed and Settings.Enabled and Aiming then
			TargetBlocked = false

			if not IsTargetValid(Target) or AimTargetRefreshTimer >= AimTargetRefreshInterval then
				Target = GetClosestTarget()
				AimTargetRefreshTimer = 0
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

			if TargetCharacter and IsSelfCharacter(TargetCharacter) then
				Target = nil
				TargetCharacter = nil
			end

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
								if Settings.ExploitSimDamage and Target:IsA("Player") then
									ExploitSimHitTarget(Target)
								else
									ControlClick(true)
								end

								task.wait(rate.press)
								if not (Aiming and Target and Settings.AutoShoot) then break end

								if not Settings.ExploitSimDamage then
									ControlClick(false)
								end

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

Compat.Log("BOOT", "Aim/ESP runtime initialized")

--// UI Allocation Elements
UI.MainMenuUI = nil
UI.ShortcutList = nil
UI.KeybindCapture = nil
UI.KeybindValueButtons = {}
UI.MobileControls = nil
UI.MobileAimButton = nil
UI.MobileMenuButton = nil
UI.MainUIScale = nil
UI.AuthUIScale = nil

local function GetKeybindName(keyCode)
	if not keyCode or keyCode == Enum.KeyCode.Unknown then
		return "NONE"
	end

	return keyCode.Name
end

local function UpdateKeybindValueButtons()
	for configKey, button in pairs(UI.KeybindValueButtons) do
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
	if UI.MobileAimButton then
		UI.MobileAimButton.Text = Aiming and "AIM\nON" or "AIM\nOFF"
		UI.MobileAimButton.BackgroundColor3 = Aiming and Styles.Accent or Color3.fromRGB(30, 32, 40)
		UI.MobileAimButton.TextColor3 = Aiming and Color3.fromRGB(10, 10, 12) or Styles.TextMain
	end

	if UI.MobileMenuButton then
		UI.MobileMenuButton.Text = UI.MainMenuUI and UI.MainMenuUI.Visible and "HIDE\nUI" or "SHOW\nUI"
	end
end

UpdateLeftPanelShortcuts = function()
	if UI.ShortcutList then
		local statusText = Aiming and "ON" or "OFF"

		if IsTouchDevice then
			UI.ShortcutList.Text = string.format("[TOUCH] Aim Lock: %s\n[TOUCH] Toggle UI", statusText)
		else
			local invisStatus = Settings.FarmInvisibility and "ON" or "OFF"
			UI.ShortcutList.Text = string.format(
				"[%s] Aim Lock: %s\n[%s] Toggle UI\n[%s] Invisibility: %s",
				GetKeybindName(Settings.AimKey),
				statusText,
				GetKeybindName(Settings.ToggleUiKey),
				GetKeybindName(Settings.FarmInvisToggleKey),
				invisStatus
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
	if not AccessNoticeDismissed or not UI.MainMenuUI then return end

	if IsTouchDevice then
		UI.MainMenuUI.Visible = not UI.MainMenuUI.Visible
		UpdateMobileControlButtons()
		return
	end

	local isVis = UI.MainMenuUI.Size.Y.Offset > 40
	local container = UI.MainMenuUI:FindFirstChild("UI.WindowContainerFrame")

	if container then
		if isVis then
			TweenObj(UI.MainMenuUI, { Size = UDim2.new(0, 540, 0, 40) }, 0.4, Enum.EasingStyle.Quint)
			container.Visible = false
		else
			container.Visible = true
			TweenObj(UI.MainMenuUI, { Size = UDim2.new(0, 540, 0, 415) }, 0.4, Enum.EasingStyle.Quint)
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
	if UI.KeybindCapture then
		if input.UserInputType ~= Enum.UserInputType.Keyboard or input.KeyCode == Enum.KeyCode.Unknown then
			return
		end

		local capture = UI.KeybindCapture
		UI.KeybindCapture = nil

		if input.KeyCode == Enum.KeyCode.Escape then
			UpdateKeybindValueButtons()
			return
		end

		local configKey = capture.ConfigKey
		local previousKey = Settings[configKey]
		local keybindConfigKeys = {"AimKey", "ToggleUiKey", "FarmInvisToggleKey"}

		for _, otherConfigKey in ipairs(keybindConfigKeys) do
			if otherConfigKey ~= configKey and Settings[otherConfigKey] == input.KeyCode then
				Settings[otherConfigKey] = previousKey
				break
			end
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

	if AccessNoticeDismissed and input.KeyCode == Settings.FarmInvisToggleKey then
		Settings.FarmInvisibility = not Settings.FarmInvisibility

		if Settings.FarmInvisibility then
			Farm.EnableInvisibility()
		else
			Farm.DisableInvisibility()
		end

		for _, updater in ipairs(UIUpdaters) do
			updater()
		end

		UpdateLeftPanelShortcuts()
		SystemLogEvent("Invisibility toggled " .. (Settings.FarmInvisibility and "ON" or "OFF") .. ".")
	end
end)

Compat.Log("BOOT", "Input/runtime controls initialized")

SetBootStatus("Building main UI...")

--// Structural Premium Interface Generation Layer
UI.ScreenGui = Instance.new("UI.ScreenGui", PlayerGui)
UI.ScreenGui.Name = CurrentScriptID
UI.ScreenGui.ResetOnSpawn = false
UI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.ScreenGui.DisplayOrder = 999999

OffscreenOverlay = Instance.new("Frame", UI.ScreenGui)
OffscreenOverlay.Name = "OffscreenWarningOverlay"
OffscreenOverlay.Size = UDim2.new(1, 0, 1, 0)
OffscreenOverlay.BackgroundTransparency = 1
OffscreenOverlay.BorderSizePixel = 0
OffscreenOverlay.Active = false
OffscreenOverlay.ZIndex = 40

local function ApplyOffscreenIndicatorSize(indicator)
	if not indicator then return end

	local size = math.floor(Settings.WarningIMGSize + 0.5)
	local warning = indicator:FindFirstChild("WarningLogo")
	local nameLabel = indicator:FindFirstChild("PlayerName")

	indicator.Size = UDim2.fromOffset(size, size)

	if warning then
		warning.Size = UDim2.new(1, 0, 0, math.floor(size * 0.68))
		warning.TextSize = math.max(16, math.floor(size * 0.59))
	end

	if nameLabel then
		nameLabel.Size = UDim2.new(1, 30, 0, 16)
		nameLabel.Position = UDim2.new(0, -15, 1, -17)
	end
end

local function UpdateOffscreenIndicatorSizes()
	for _, indicator in pairs(OffscreenIndicators) do
		ApplyOffscreenIndicatorSize(indicator)
	end
end

local function GetOffscreenIndicator(player)
	local existing = OffscreenIndicators[player]
	if existing and existing.Parent then
		ApplyOffscreenIndicatorSize(existing)
		return existing
	end

	local indicator = Instance.new("Frame")
	indicator.Name = "Offscreen_" .. player.UserId
	indicator.AnchorPoint = Vector2.new(0.5, 0.5)
	indicator.BackgroundTransparency = 1
	indicator.Visible = false
	indicator.ZIndex = 41
	indicator.Parent = OffscreenOverlay

	local warning = Instance.new("TextLabel")
	warning.Name = "WarningLogo"
	warning.BackgroundTransparency = 1
	warning.Text = "⚠"
	warning.Font = Enum.Font.GothamBold
	warning.TextColor3 = OffscreenFarColor
	warning.TextStrokeColor3 = Color3.fromRGB(120, 35, 0)
	warning.TextStrokeTransparency = 0.15
	warning.ZIndex = 42
	warning.Parent = indicator

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "PlayerName"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.Name
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 10
	nameLabel.TextColor3 = Color3.fromRGB(255, 245, 210)
	nameLabel.TextStrokeTransparency = 0.25
	nameLabel.ZIndex = 42
	nameLabel.Parent = indicator

	ApplyOffscreenIndicatorSize(indicator)

	OffscreenIndicators[player] = indicator
	return indicator
end

local function HideAllOffscreenIndicators()
	for _, indicator in pairs(OffscreenIndicators) do
		if indicator then indicator.Visible = false end
	end
end

local function IsPlayerLookingAtLocal(player, character)
	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and GetCharacterRoot(localCharacter)
	local sourcePart = character and (character:FindFirstChild("Head") or GetCharacterRoot(character))

	if not localCharacter or not localRoot or not sourcePart then return false end

	local toLocal = localRoot.Position - sourcePart.Position
	if toLocal.Magnitude < 0.1 then return false end

	local lookVector = sourcePart.CFrame.LookVector
	local dot = lookVector:Dot(toLocal.Unit)
	if dot < OffscreenLookDotThreshold then return false end

	OffscreenLookRaycastParams.FilterDescendantsInstances = {character}

	local result = workspace:Raycast(sourcePart.Position, toLocal, OffscreenLookRaycastParams)

	if result and not result.Instance:IsDescendantOf(localCharacter) then
		return false
	end

	return true
end

local function GetOffscreenThreatState(player, character)
	local cached = OffscreenThreatCache[player]
	local now = time()

	if cached and now - cached.Time < OffscreenThreatCheckInterval then
		return cached.Threat
	end

	local threat = IsPlayerLookingAtLocal(player, character)

	OffscreenThreatCache[player] = {
		Time = now,
		Threat = threat
	}

	return threat
end

local function UpdateOffscreenWarnings()
	if not OffscreenOverlay or not AccessNoticeDismissed or not Settings.Enabled or not Settings.DetectPlayers or not Settings.OffscreenWarning then
		HideAllOffscreenIndicators()
		return
	end

	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and GetCharacterRoot(localCharacter)

	if not localRoot then
		HideAllOffscreenIndicators()
		return
	end

	local viewport = Camera.ViewportSize
	local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	local margin = math.max(30, Settings.WarningIMGSize * 0.65)
	local halfWidth = math.max(1, center.X - margin)
	local halfHeight = math.max(1, center.Y - margin)
	local seen = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and IsEnemy(player) then
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and GetCharacterRoot(character)

			if character and not IsSelfCharacter(character) and humanoid and humanoid.Health > 0 and root then
				local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
				local visibleInCamera = onScreen and screenPos.Z > 0
					and screenPos.X >= 0 and screenPos.X <= viewport.X
					and screenPos.Y >= 0 and screenPos.Y <= viewport.Y

				local indicator = GetOffscreenIndicator(player)
				local warning = indicator:FindFirstChild("WarningLogo")
				local nameLabel = indicator:FindFirstChild("PlayerName")
				seen[player] = true

				if visibleInCamera then
					indicator.Visible = false
				else
					local direction = Vector2.new(screenPos.X - center.X, screenPos.Y - center.Y)

					if screenPos.Z < 0 then direction = -direction end

					if direction.Magnitude < 0.001 then
						direction = Vector2.new(0, 1)
					else
						direction = direction.Unit
					end

					local scaleX = math.abs(direction.X) > 0.001 and halfWidth / math.abs(direction.X) or math.huge
					local scaleY = math.abs(direction.Y) > 0.001 and halfHeight / math.abs(direction.Y) or math.huge
					local edgeScale = math.min(scaleX, scaleY)
					local edgePosition = center + direction * edgeScale
					local distance = (root.Position - localRoot.Position).Magnitude
					local closeFactor = 1 - math.clamp(distance / math.max(Settings.MaxDistance, 1), 0, 1)
					local warningColor = OffscreenFarColor:Lerp(OffscreenNearColor, closeFactor)
					local isThreat = GetOffscreenThreatState(player, character)
					local blinkVisible = not isThreat or math.floor(time() / 0.16) % 2 == 0

					indicator.Position = UDim2.fromOffset(edgePosition.X, edgePosition.Y)
					indicator.Visible = blinkVisible

					if warning then
						warning.TextColor3 = warningColor
						warning.TextStrokeColor3 = Color3.fromRGB(
							math.floor(80 + 80 * closeFactor),
							math.floor(28 - 12 * closeFactor),
							math.floor(12 - 6 * closeFactor)
						)
					end

					if nameLabel then
						nameLabel.TextColor3 = warningColor:Lerp(Color3.new(1, 1, 1), 0.35)
					end
				end
			end
		end
	end

	for player, indicator in pairs(OffscreenIndicators) do
		if not seen[player] then
			indicator.Visible = false
			OffscreenThreatCache[player] = nil
		end
	end
end
SafeConnect(RunService.RenderStepped, UpdateOffscreenWarnings)

UI.MainFrame = Instance.new("Frame", UI.ScreenGui)
UI.MainFrame.Name = "UI.MainFrame"
UI.MainFrame.BackgroundColor3 = Styles.Bg
UI.MainFrame.BackgroundTransparency = Settings.MenuTransparency
UI.MainFrame.BorderSizePixel = 0
UI.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
UI.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
UI.MainFrame.Size = UDim2.new(0, 540, 0, 415)
UI.MainFrame.Active = true
UI.MainFrame.ClipsDescendants = true
UI.MainFrame.Visible = false
Instance.new("UICorner", UI.MainFrame).CornerRadius = UDim.new(0, 10)
UI.MainMenuUI = UI.MainFrame

UI.MainUIScale = Instance.new("UIScale", UI.MainFrame)

UI.MobileControls = Instance.new("Frame", UI.ScreenGui)
UI.MobileControls.Name = "UI.MobileControls"
UI.MobileControls.Size = UDim2.new(0, 64, 0, 146)
UI.MobileControls.Position = UDim2.new(1, -76, 0.5, -73)
UI.MobileControls.BackgroundTransparency = 1
UI.MobileControls.Visible = false
UI.MobileControls.ZIndex = 50
UI.MobileControls.Active = true

UI.MobileDragHandle = Instance.new("TextButton", UI.MobileControls)
UI.MobileDragHandle.Size = UDim2.new(0, 60, 0, 18)
UI.MobileDragHandle.Position = UDim2.new(0, 2, 0, 0)
UI.MobileDragHandle.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
UI.MobileDragHandle.BorderSizePixel = 0
UI.MobileDragHandle.Text = "≡"
UI.MobileDragHandle.TextColor3 = Styles.TextDark
UI.MobileDragHandle.TextSize = 14
UI.MobileDragHandle.Font = Enum.Font.GothamBold
UI.MobileDragHandle.AutoButtonColor = false
UI.MobileDragHandle.ZIndex = 51
Instance.new("UICorner", UI.MobileDragHandle).CornerRadius = UDim.new(0, 7)

UI.MobileAimButton = Instance.new("TextButton", UI.MobileControls)
UI.MobileAimButton.Size = UDim2.new(0, 60, 0, 56)
UI.MobileAimButton.Position = UDim2.new(0, 2, 0, 24)
UI.MobileAimButton.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
UI.MobileAimButton.BorderSizePixel = 0
UI.MobileAimButton.Text = "AIM\nOFF"
UI.MobileAimButton.TextColor3 = Styles.TextMain
UI.MobileAimButton.TextSize = 11
UI.MobileAimButton.Font = Enum.Font.GothamBold
UI.MobileAimButton.AutoButtonColor = false
UI.MobileAimButton.ZIndex = 51
Instance.new("UICorner", UI.MobileAimButton).CornerRadius = UDim.new(0, 10)

UI.MobileAimStroke = Instance.new("UIStroke", UI.MobileAimButton)
ApplyPaletteStroke(UI.MobileAimStroke, 1)
UI.MobileAimStroke.Thickness = 1.5

UI.MobileMenuButton = Instance.new("TextButton", UI.MobileControls)
UI.MobileMenuButton.Size = UDim2.new(0, 60, 0, 56)
UI.MobileMenuButton.Position = UDim2.new(0, 2, 0, 90)
UI.MobileMenuButton.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
UI.MobileMenuButton.BorderSizePixel = 0
UI.MobileMenuButton.Text = "SHOW\nUI"
UI.MobileMenuButton.TextColor3 = Styles.TextMain
UI.MobileMenuButton.TextSize = 10
UI.MobileMenuButton.Font = Enum.Font.GothamBold
UI.MobileMenuButton.AutoButtonColor = false
UI.MobileMenuButton.ZIndex = 51
Instance.new("UICorner", UI.MobileMenuButton).CornerRadius = UDim.new(0, 10)

UI.MobileMenuStroke = Instance.new("UIStroke", UI.MobileMenuButton)
ApplyPaletteStroke(UI.MobileMenuStroke, 3)
UI.MobileMenuStroke.Thickness = 1.5

HookButtonAnimations(UI.MobileAimButton, Color3.fromRGB(30, 32, 40), Styles.CardHover)
HookButtonAnimations(UI.MobileMenuButton, Color3.fromRGB(30, 32, 40), Styles.CardHover)

UI.MobileAimButton.Activated:Connect(function()
	ToggleAiming()
end)

UI.MobileMenuButton.Activated:Connect(function()
	ToggleMainMenu()
end)

UI.MobileDragState = {
	Dragging = false,
	Input = nil,
	Start = nil,
	StartPosition = nil
}

UI.MobileDragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		UI.MobileDragState.Dragging = true
		UI.MobileDragState.Start = input.Position
		UI.MobileDragState.StartPosition = UI.MobileControls.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				UI.MobileDragState.Dragging = false
			end
		end)
	end
end)

UI.MobileDragHandle.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		UI.MobileDragState.Input = input
	end
end)

SafeConnect(UserInputService.InputChanged, function(input)
	if input == UI.MobileDragState.Input and UI.MobileDragState.Dragging then
		local delta = input.Position - UI.MobileDragState.Start
		local startPosition = UI.MobileDragState.StartPosition

		UI.MobileControls.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UI.MainStroke = Instance.new("UIStroke", UI.MainFrame)
UI.MainStroke.Thickness = Settings.BorderThickness
ApplyPaletteStroke(UI.MainStroke, 1)
UI.MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

UI.HeaderBar = Instance.new("Frame", UI.MainFrame)
UI.HeaderBar.Name = "UI.HeaderBar"
UI.HeaderBar.Size = UDim2.new(1, 0, 0, 40)
UI.HeaderBar.BackgroundColor3 = Styles.SidebarBg
UI.HeaderBar.BackgroundTransparency = Settings.MenuTransparency
UI.HeaderBar.BorderSizePixel = 0

UI.MainDragState = {
	Dragging = false,
	Input = nil,
	Start = nil,
	StartPosition = nil,
	TargetPosition = UI.MainFrame.Position
}

UI.HeaderBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		UI.MainDragState.Dragging = true
		UI.MainDragState.Start = input.Position
		UI.MainDragState.StartPosition = UI.MainFrame.Position
		UI.MainDragState.TargetPosition = UI.MainDragState.StartPosition

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				UI.MainDragState.Dragging = false
			end
		end)
	end
end)

UI.HeaderBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		UI.MainDragState.Input = input
	end
end)

SafeConnect(UserInputService.InputChanged, function(input)
	if input == UI.MainDragState.Input and UI.MainDragState.Dragging then
		local delta = input.Position - UI.MainDragState.Start
		local startPosition = UI.MainDragState.StartPosition

		UI.MainDragState.TargetPosition = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

SafeConnect(RunService.RenderStepped, function(dt)
	local targetPosition = UI.MainDragState.TargetPosition
	if UI.MainFrame.Position ~= targetPosition then
		UI.MainFrame.Position = UI.MainFrame.Position:Lerp(targetPosition, math.clamp(dt * 12, 0, 1))
	end
end)

UI.Title = Instance.new("TextLabel", UI.HeaderBar)
UI.Title.Size = UDim2.new(0.3, 0, 1, 0)
UI.Title.Position = UDim2.new(0.03, 0, 0, 0)
UI.Title.BackgroundTransparency = 1
UI.Title.TextColor3 = Styles.TextMain
UI.Title.Text = "Aehmre Ultimate Hub"
UI.Title.TextSize = 13
UI.Title.Font = Enum.Font.GothamBold
UI.Title.TextXAlignment = Enum.TextXAlignment.Left

UI.SubTitle = Instance.new("TextLabel", UI.HeaderBar)
UI.SubTitle.Name = "CreatorTag"
UI.SubTitle.Size = UDim2.new(0.4, 0, 1, 0)
UI.SubTitle.Position = UDim2.new(0.32, 0, 0, 0) 
UI.SubTitle.BackgroundTransparency = 1
UI.SubTitle.TextColor3 = Styles.Accent
UI.SubTitle.Text = "Made by @Emre_31er"
UI.SubTitle.TextSize = 11
UI.SubTitle.Font = Enum.Font.Arimo
UI.SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local HeaderControlSize = IsTouchDevice and 30 or 20
local HeaderControlHalf = HeaderControlSize * 0.5

UI.CloseBtn = Instance.new("TextButton", UI.HeaderBar)
UI.CloseBtn.Size = UDim2.new(0, HeaderControlSize, 0, HeaderControlSize)
UI.CloseBtn.Position = UDim2.new(1, -(IsTouchDevice and 36 or 26), 0.5, -HeaderControlHalf)
UI.CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
UI.CloseBtn.TextColor3 = Color3.fromRGB(240, 90, 90)
UI.CloseBtn.Text = "X" 
UI.CloseBtn.TextSize = 11
UI.CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", UI.CloseBtn).CornerRadius = UDim.new(0, 5)
HookButtonAnimations(UI.CloseBtn, Color3.fromRGB(40, 20, 25), Color3.fromRGB(60, 25, 32))

UI.MinimizeBtn = Instance.new("TextButton", UI.HeaderBar)
UI.MinimizeBtn.Size = UDim2.new(0, HeaderControlSize, 0, HeaderControlSize)
UI.MinimizeBtn.Position = UDim2.new(1, -(IsTouchDevice and 72 or 52), 0.5, -HeaderControlHalf)
UI.MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
UI.MinimizeBtn.TextColor3 = Styles.TextDark
UI.MinimizeBtn.Text = "—"
UI.MinimizeBtn.TextSize = 9
UI.MinimizeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", UI.MinimizeBtn).CornerRadius = UDim.new(0, 5)
HookButtonAnimations(UI.MinimizeBtn, Color3.fromRGB(30, 32, 40), Color3.fromRGB(42, 45, 56))

UI.WindowContainerFrame = Instance.new("Frame", UI.MainFrame)
UI.WindowContainerFrame.Name = "UI.WindowContainerFrame"
UI.WindowContainerFrame.Size = UDim2.new(1, 0, 1, -40)
UI.WindowContainerFrame.Position = UDim2.new(0, 0, 0, 40)
UI.WindowContainerFrame.BackgroundTransparency = 1

UI.Sidebar = Instance.new("Frame", UI.WindowContainerFrame)
UI.Sidebar.Name = "UI.Sidebar"
UI.Sidebar.Size = UDim2.new(0, 165, 1, 0)
UI.Sidebar.BackgroundColor3 = Styles.SidebarBg
UI.Sidebar.BackgroundTransparency = Settings.MenuTransparency
UI.Sidebar.BorderSizePixel = 0

UI.SidebarContainer = Instance.new("ScrollingFrame", UI.Sidebar)
UI.SidebarContainer.Size = UDim2.new(1, 0, 1, -170)
UI.SidebarContainer.Position = UDim2.new(0, 0, 0, 60)
UI.SidebarContainer.BackgroundTransparency = 1
UI.SidebarContainer.BorderSizePixel = 0
UI.SidebarContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
UI.SidebarContainer.ScrollBarThickness = 2
UI.SidebarContainer.ScrollBarImageColor3 = Styles.Accent
UI.SidebarContainer.ScrollingDirection = Enum.ScrollingDirection.Y
UI.SidebarContainer.ClipsDescendants = true

UI.ProfileContainer = Instance.new("Frame", UI.Sidebar)
UI.ProfileContainer.Size = UDim2.new(1, 0, 0, 60)
UI.ProfileContainer.BackgroundTransparency = 1

UI.DummyAvatar = Instance.new("ImageLabel", UI.ProfileContainer)
UI.DummyAvatar.Size = UDim2.new(0, 34, 0, 34)
UI.DummyAvatar.Position = UDim2.new(0.08, 0, 0.5, -17)
UI.DummyAvatar.BackgroundColor3 = Color3.fromRGB(35, 36, 45)
UI.DummyAvatar.BorderSizePixel = 0
UI.DummyAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", UI.DummyAvatar).CornerRadius = UDim.new(1, 0)

UI.DevName = Instance.new("TextLabel", UI.ProfileContainer)
UI.DevName.Size = UDim2.new(0.65, 0, 0, 16)
UI.DevName.Position = UDim2.new(0.34, 0, 0.28, 0)
UI.DevName.BackgroundTransparency = 1
UI.DevName.Text = LocalPlayer.DisplayName
UI.DevName.Font = Enum.Font.GothamSemibold
UI.DevName.TextSize = 11
UI.DevName.TextColor3 = Styles.TextDark
UI.DevName.TextXAlignment = Enum.TextXAlignment.Left
UI.DevName.TextTruncate = Enum.TextTruncate.AtEnd

UI.ActiveDotLabel = Instance.new("TextLabel", UI.ProfileContainer)
UI.ActiveDotLabel.Size = UDim2.new(0.65, 0, 0, 14)
UI.ActiveDotLabel.Position = UDim2.new(0.34, 0, 0.52, 0)
UI.ActiveDotLabel.BackgroundTransparency = 1
UI.ActiveDotLabel.Text = "* Active"
UI.ActiveDotLabel.Font = Enum.Font.GothamBold
UI.ActiveDotLabel.TextSize = 10
UI.ActiveDotLabel.TextColor3 = Color3.fromRGB(70, 235, 120)
UI.ActiveDotLabel.TextXAlignment = Enum.TextXAlignment.Left

UI.SideLayout = Instance.new("UIListLayout", UI.SidebarContainer)
UI.SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
UI.SideLayout.Padding = UDim.new(0, 6)
UI.SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

UI.SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	UI.SidebarContainer.CanvasSize = UDim2.new(0, 0, 0, UI.SideLayout.AbsoluteContentSize.Y + 12)
end)

UI.RightContentWindow = Instance.new("Frame", UI.WindowContainerFrame)
UI.RightContentWindow.Name = "UI.RightContentWindow"
UI.RightContentWindow.Size = UDim2.new(1, -165, 1, 0)
UI.RightContentWindow.Position = UDim2.new(0, 165, 0, 0)
UI.RightContentWindow.BackgroundTransparency = 1

UI.ShortcutsFrame = Instance.new("Frame", UI.Sidebar)
UI.ShortcutsFrame.Size = UDim2.new(0.84, 0, 0, 50)
UI.ShortcutsFrame.Position = UDim2.new(0.08, 0, 1, -95)
UI.ShortcutsFrame.BackgroundTransparency = 1

UI.ShortcutTitle = Instance.new("TextLabel", UI.ShortcutsFrame)
UI.ShortcutTitle.Size = UDim2.new(1, 0, 0, 14)
UI.ShortcutTitle.BackgroundTransparency = 1
UI.ShortcutTitle.Text = "SHORTCUTS"
UI.ShortcutTitle.Font = Enum.Font.GothamBold
UI.ShortcutTitle.TextSize = 10
UI.ShortcutTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
UI.ShortcutTitle.TextXAlignment = Enum.TextXAlignment.Left

UI.ShortcutList = Instance.new("TextLabel", UI.ShortcutsFrame)
UI.ShortcutList.Size = UDim2.new(1, 0, 1, -14)
UI.ShortcutList.Position = UDim2.new(0, 0, 0, 14)
UI.ShortcutList.BackgroundTransparency = 1
UI.ShortcutList.Font = Enum.Font.GothamSemibold
UI.ShortcutList.TextSize = 10
UI.ShortcutList.TextColor3 = Styles.TextDark
UI.ShortcutList.TextXAlignment = Enum.TextXAlignment.Left
UpdateLeftPanelShortcuts()

UI.SystemStatusBtn = Instance.new("TextButton", UI.Sidebar)
UI.SystemStatusBtn.Size = UDim2.new(0.84, 0, 0, 32)
UI.SystemStatusBtn.Position = UDim2.new(0.08, 0, 1, -38)
UI.SystemStatusBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
UI.SystemStatusBtn.Font = Enum.Font.GothamBold
UI.SystemStatusBtn.Text = "SYSTEM WORKING"
UI.SystemStatusBtn.TextColor3 = Color3.fromRGB(10, 10, 12)
UI.SystemStatusBtn.TextSize = 10
UI.SystemStatusBtn.BorderSizePixel = 0
UI.SystemStatusBtn.AutoButtonColor = false
Instance.new("UICorner", UI.SystemStatusBtn).CornerRadius = UDim.new(0, 6)
HookButtonAnimations(UI.SystemStatusBtn, Color3.fromRGB(255, 255, 255), Color3.fromRGB(225, 225, 230))

UI.SearchBarFrame = Instance.new("Frame", UI.RightContentWindow)
UI.SearchBarFrame.Size = UDim2.new(0.94, 0, 0, 30)
UI.SearchBarFrame.Position = UDim2.new(0.03, 0, 0, 10)
UI.SearchBarFrame.BackgroundColor3 = Color3.fromRGB(22, 23, 29)
UI.SearchBarFrame.BorderSizePixel = 0
Instance.new("UICorner", UI.SearchBarFrame).CornerRadius = UDim.new(0, 6)
UI.SearchStroke = Instance.new("UIStroke", UI.SearchBarFrame)
ApplyPaletteStroke(UI.SearchStroke, 2)

UI.SearchPlaceholder = Instance.new("TextBox", UI.SearchBarFrame)
UI.SearchPlaceholder.Size = UDim2.new(0.95, 0, 1, 0)
UI.SearchPlaceholder.Position = UDim2.new(0.03, 0, 0, 0)
UI.SearchPlaceholder.BackgroundTransparency = 1
UI.SearchPlaceholder.Text = ""
UI.SearchPlaceholder.PlaceholderText = "Search features..."
UI.SearchPlaceholder.PlaceholderColor3 = Color3.fromRGB(70, 72, 85)
UI.SearchPlaceholder.Font = Enum.Font.Gotham
UI.SearchPlaceholder.TextSize = 11
UI.SearchPlaceholder.TextColor3 = Styles.TextMain
UI.SearchPlaceholder.TextXAlignment = Enum.TextXAlignment.Left

UI.Tabs = {}
local function RegisterTabContainerPage(tabName)
	local PageFrame = Instance.new("ScrollingFrame", UI.RightContentWindow)
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

	local TabBtn = Instance.new("TextButton", UI.SidebarContainer)
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
		for _, tData in pairs(UI.Tabs) do
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

	UI.Tabs[tabName] = {Page = PageFrame, Btn = TabBtn}
	return PageFrame
end

UI.AimPage = RegisterTabContainerPage("Aim Lock")
UI.VisPage = RegisterTabContainerPage("Visuals / ESP")
UI.LogPage = RegisterTabContainerPage("System Logs")
UI.CustPage = RegisterTabContainerPage("Customization")
UI.KeybindPage = RegisterTabContainerPage("Keybinds")
UI.TestPage = RegisterTabContainerPage("Lighting & Enviroment")
UI.FarmPage = RegisterTabContainerPage("Farm")
UI.SettPage = RegisterTabContainerPage("Settings")

UI.SystemLogEntries = {}

-- NEW: Logger Write Hook Function
SystemLogEvent = function(msg)
	local timeStr = os.date("%H:%M:%S")
	local LogCard = Instance.new("Frame", UI.LogPage)

	table.insert(UI.SystemLogEntries, LogCard)

	if #UI.SystemLogEntries > 100 then
		local oldest = table.remove(UI.SystemLogEntries, 1)
		if oldest then
			oldest:Destroy()
		end
	end

	LogCard.Size = UDim2.new(0.94, 0, 0, 28)
	LogCard.BackgroundColor3 = Styles.CardBg
	LogCard.BorderSizePixel = 0
	Instance.new("UICorner", LogCard).CornerRadius = UDim.new(0, 4)
	ApplyPaletteStroke(Instance.new("UIStroke", LogCard))

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
	local container = UI.LogPage:FindFirstChild("UIListLayout")
	if container then
		UI.LogPage.CanvasPosition = Vector2.new(0, container.AbsoluteContentSize.Y + 100)
	end
end
SystemLogEvent("Engine Core Initialized Successfully.")
Farm.SetLogHook(SystemLogEvent)

if Settings.PanicMode then
	Farm.EnablePanicMode()
end

UI.Tabs["Aim Lock"].Page.Visible = true
UI.Tabs["Aim Lock"].Btn.TextColor3 = Styles.TextMain
UI.Tabs["Aim Lock"].Btn.BackgroundColor3 = Color3.fromRGB(26, 27, 35)
UI.Tabs["Aim Lock"].Btn.BackgroundTransparency = 0
UI.Tabs["Aim Lock"].Btn.IndicatorStrip.Visible = true

UI.IsMin = false
UI.MinimizeBtn.MouseButton1Click:Connect(function()
	UI.IsMin = not UI.IsMin
	local container = UI.WindowContainerFrame

	if UI.IsMin then
		TweenObj(UI.MainFrame, { Size = UDim2.new(0, 540, 0, 40) }, 0.4, Enum.EasingStyle.Quint)
		container.Visible = false
		UI.MinimizeBtn.Text = "+"
	else
		container.Visible = true
		TweenObj(UI.MainFrame, { Size = UDim2.new(0, 540, 0, 415) }, 0.4, Enum.EasingStyle.Quint)
		UI.MinimizeBtn.Text = "—"
	end

	UpdateMobileControlButtons()
end)

local function CinematicClose()
	TweenObj(UI.MainStroke, { Transparency = 1 }, 0.15)
	local closeTween = TweenObj(UI.MainFrame, { 
		Size = UDim2.new(0, 540, 0, 0), 
		Position = UI.MainFrame.Position + UDim2.new(0, 0, 0, 207.5), 
		BackgroundTransparency = 1 
	}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	closeTween.Completed:Wait()
	env[CurrentScriptID] = nil 
	env[CurrentScriptID .. "_DataPacket"] = nil 
	UniversalDestruct()
end
UI.CloseBtn.MouseButton1Click:Connect(CinematicClose)

Compat.Log("BOOT", "Main UI structure initialized")

local function AddDashboardButton(parentPage, configKey, displayTitle, desc, subDesc, customCallback)
	local state = Settings[configKey]

	local Card = Instance.new("Frame", parentPage)
	Card.Size = UDim2.new(0.94, 0, 0, 56)
	Card.BackgroundColor3 = Styles.CardBg
	Card.BorderSizePixel = 0
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
	local Stroke = Instance.new("UIStroke", Card)
	ApplyPaletteStroke(Stroke)

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
		TweenObj(Stroke, { Color = GetPaletteStrokeColor(Stroke) }, 0.2) 
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

	local function UpdateToggleFromSetting()
		local current = Settings[configKey]
		TweenObj(ToggleHousing, { BackgroundColor3 = current and Styles.Accent or Color3.fromRGB(40, 42, 52) }, 0.25, Enum.EasingStyle.Quint)
		TweenObj(ToggleCore, { Position = current and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }, 0.25, Enum.EasingStyle.Quint)
	end

	ConfigUIUpdaters[configKey] = UpdateToggleFromSetting
	table.insert(UIUpdaters, UpdateToggleFromSetting)
end

local function AddDashboardSlider(parentPage, configKey, displayTitle, min, max, desc, subDesc, customCallback, decimalPlaces)
	local initial = Settings[configKey]

	local Card = Instance.new("Frame", parentPage)
	Card.Size = UDim2.new(0.94, 0, 0, 68)
	Card.BackgroundColor3 = Styles.CardBg
	Card.BorderSizePixel = 0
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
	local Stroke = Instance.new("UIStroke", Card)
	ApplyPaletteStroke(Stroke)

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
	ApplyPaletteStroke(KnobStroke)
	KnobStroke.Thickness = 2

	Card.MouseEnter:Connect(function() 
		TweenObj(Stroke, { Color = Styles.Accent }, 0.2) 
		TweenObj(Card, { BackgroundColor3 = Styles.CardHover }, 0.2) 
	end)
	Card.MouseLeave:Connect(function() 
		TweenObj(Stroke, { Color = GetPaletteStrokeColor(Stroke) }, 0.2) 
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

local function AddDashboardDropdown(parentPage, configKey, displayTitle, options, desc, customCallback)
	local Card = Instance.new("Frame", parentPage)
	Card.Size = UDim2.new(0.94, 0, 0, 56)
	Card.BackgroundColor3 = Styles.CardBg
	Card.BorderSizePixel = 0
	Card.ClipsDescendants = true
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

	local Stroke = Instance.new("UIStroke", Card)
	ApplyPaletteStroke(Stroke)

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
		TweenObj(Stroke, { Color = open and Styles.Accent or GetPaletteStrokeColor(Stroke) }, 0.2)
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

			if customCallback then
				customCallback(option)
			end
		end)
	end

	DropdownButton.MouseButton1Click:Connect(function()
		SetOpen(not isOpen)
	end)

	Card.MouseEnter:Connect(function()
		if not isOpen then TweenObj(Stroke, { Color = Styles.Accent }, 0.2) end
	end)

	Card.MouseLeave:Connect(function()
		if not isOpen then TweenObj(Stroke, { Color = GetPaletteStrokeColor(Stroke) }, 0.2) end
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
	ApplyPaletteStroke(Stroke)

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
	ApplyPaletteStroke(ValueStroke)

	UI.KeybindValueButtons[configKey] = ValueButton

	Card.MouseEnter:Connect(function()
		TweenObj(Stroke, { Color = Styles.Accent }, 0.2)
		TweenObj(Card, { BackgroundColor3 = Styles.CardHover }, 0.2)
	end)

	Card.MouseLeave:Connect(function()
		TweenObj(Stroke, { Color = GetPaletteStrokeColor(Stroke) }, 0.2)
		TweenObj(Card, { BackgroundColor3 = Styles.CardBg }, 0.2)
	end)

	ValueButton.MouseEnter:Connect(function()
		TweenObj(ValueStroke, { Color = Styles.Accent }, 0.15)
	end)

	ValueButton.MouseLeave:Connect(function()
		if not UI.KeybindCapture or UI.KeybindCapture.ConfigKey ~= configKey then
			TweenObj(ValueStroke, { Color = GetPaletteStrokeColor(ValueStroke) }, 0.15)
		end
	end)

	ValueButton.MouseButton1Click:Connect(function()
		if IsTouchDevice and not HasKeyboard then
			ValueButton.Text = "PC ONLY"
			return
		end

		if UI.KeybindCapture then
			UpdateKeybindValueButtons()
		end

		UI.KeybindCapture = {
			ConfigKey = configKey,
			DisplayName = displayTitle
		}

		ValueButton.Text = ".."
		TweenObj(ValueStroke, { Color = Styles.Accent }, 0.15)
	end)

	table.insert(UIUpdaters, function()
		if UI.KeybindCapture and UI.KeybindCapture.ConfigKey == configKey then
			UI.KeybindCapture = nil
		end

		if IsTouchDevice and not HasKeyboard then
			ValueButton.Text = "PC ONLY"
		else
			ValueButton.Text = GetKeybindName(Settings[configKey])
		end

		ValueStroke.Color = GetPaletteStrokeColor(ValueStroke)
	end)
end

local function AddMarkedPlayerDropdown(parentPage)
	local Card = Instance.new("Frame", parentPage)
	Card.Size = UDim2.new(0.94, 0, 0, 60)
	Card.BackgroundColor3 = Styles.CardBg
	Card.BorderSizePixel = 0
	Card.ClipsDescendants = true
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

	local Stroke = Instance.new("UIStroke", Card)
	ApplyPaletteStroke(Stroke)

	local TitleLabel = Instance.new("TextLabel", Card)
	TitleLabel.Size = UDim2.new(0.42, 0, 0, 18)
	TitleLabel.Position = UDim2.new(0.03, 0, 0, 9)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = "Marked Player"
	TitleLabel.Font = Enum.Font.GothamSemibold
	TitleLabel.TextSize = 12
	TitleLabel.TextColor3 = Styles.TextMain
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local DescLabel = Instance.new("TextLabel", Card)
	DescLabel.Size = UDim2.new(0.42, 0, 0, 16)
	DescLabel.Position = UDim2.new(0.03, 0, 0, 31)
	DescLabel.BackgroundTransparency = 1
	DescLabel.Text = "Select one player to mark."
	DescLabel.Font = Enum.Font.Gotham
	DescLabel.TextSize = 9
	DescLabel.TextColor3 = Styles.TextDark
	DescLabel.TextXAlignment = Enum.TextXAlignment.Left

	local DropdownButton = Instance.new("TextButton", Card)
	DropdownButton.Size = UDim2.new(0, 178, 0, IsTouchDevice and 36 or 30)
	DropdownButton.Position = UDim2.new(0.97, -178, 0, IsTouchDevice and 12 or 15)
	DropdownButton.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
	DropdownButton.BorderSizePixel = 0
	DropdownButton.Font = Enum.Font.GothamSemibold
	DropdownButton.TextColor3 = Styles.TextMain
	DropdownButton.TextSize = 10
	DropdownButton.AutoButtonColor = false
	Instance.new("UICorner", DropdownButton).CornerRadius = UDim.new(0, 5)

	local OptionsFrame = Instance.new("Frame", Card)
	OptionsFrame.Size = UDim2.new(0.94, 0, 0, 0)
	OptionsFrame.Position = UDim2.new(0.03, 0, 0, 66)
	OptionsFrame.BackgroundTransparency = 1
	OptionsFrame.Visible = false

	local OptionsLayout = Instance.new("UIListLayout", OptionsFrame)
	OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	OptionsLayout.Padding = UDim.new(0, 5)

	local isOpen = false
	local PlayerEntries = {}

	local function GetEntryCount()
		local count = 0
		for player, data in pairs(PlayerEntries) do
			if player.Parent == Players and data.Entry and data.Entry.Parent then
				count += 1
			end
		end
		return count
	end

	local function UpdateCardHeight()
		local count = GetEntryCount()
		OptionsFrame.Size = UDim2.new(0.94, 0, 0, count * 51)
		Card.Size = UDim2.new(0.94, 0, 0, isOpen and (72 + count * 51) or 60)
	end

	local function UpdateButtonText()
		local selected = MarkedESP.SelectedPlayer
		if selected and selected.Parent == Players then
			DropdownButton.Text = selected.Name .. (isOpen and "  ▲" or "  ▼")
			DropdownButton.TextColor3 = MarkedESP.Color
		else
			DropdownButton.Text = "Select Player" .. (isOpen and "  ▲" or "  ▼")
			DropdownButton.TextColor3 = Styles.TextMain
		end
	end

	local function ReorderEntries()
		local players = {}
		for player, data in pairs(PlayerEntries) do
			if player.Parent == Players and data.Entry and data.Entry.Parent then
				table.insert(players, player)
			end
		end

		table.sort(players, function(a, b)
			return a.Name:lower() < b.Name:lower()
		end)

		for index, player in ipairs(players) do
			PlayerEntries[player].Entry.LayoutOrder = index
		end

		UpdateCardHeight()
	end

	local function UpdateSelectionUI()
		for player, data in pairs(PlayerEntries) do
			if data.NameLabel and data.NameLabel.Parent then
				data.NameLabel.TextColor3 = player == MarkedESP.SelectedPlayer and MarkedESP.Color or Styles.TextMain
			end
		end

		UpdateButtonText()
	end

	local function RemoveEntry(player)
		local data = PlayerEntries[player]
		if not data then return end

		if data.Entry then
			data.Entry:Destroy()
		end

		PlayerEntries[player] = nil
		ReorderEntries()
		UpdateSelectionUI()
	end

	local function AddOrUpdateEntry(player)
		if not player or player == LocalPlayer or player.Parent ~= Players then return end

		local oldData = PlayerEntries[player]
		if oldData and oldData.Entry then
			oldData.Entry:Destroy()
		end

		local Entry = Instance.new("TextButton", OptionsFrame)
		Entry.Size = UDim2.new(1, 0, 0, 46)
		Entry.BackgroundColor3 = Color3.fromRGB(26, 27, 35)
		Entry.BorderSizePixel = 0
		Entry.Text = ""
		Entry.AutoButtonColor = false
		Instance.new("UICorner", Entry).CornerRadius = UDim.new(0, 6)

		local EntryStroke = Instance.new("UIStroke", Entry)
		ApplyPaletteStroke(EntryStroke)

		local Avatar = Instance.new("ImageLabel", Entry)
		Avatar.Size = UDim2.new(0, 34, 0, 34)
		Avatar.Position = UDim2.new(0, 7, 0.5, -17)
		Avatar.BackgroundColor3 = Color3.fromRGB(35, 36, 45)
		Avatar.BorderSizePixel = 0
		Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

		local NameLabel = Instance.new("TextLabel", Entry)
		NameLabel.Size = UDim2.new(1, -54, 1, 0)
		NameLabel.Position = UDim2.new(0, 48, 0, 0)
		NameLabel.BackgroundTransparency = 1
		NameLabel.Text = player.Name
		NameLabel.Font = Enum.Font.GothamBold
		NameLabel.TextSize = 11
		NameLabel.TextColor3 = player == MarkedESP.SelectedPlayer and MarkedESP.Color or Styles.TextMain
		NameLabel.TextXAlignment = Enum.TextXAlignment.Left

		PlayerEntries[player] = {
			Entry = Entry,
			Avatar = Avatar,
			NameLabel = NameLabel
		}

		task.spawn(function()
			local success, image = pcall(function()
				local content = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
				return content
			end)

			local currentData = PlayerEntries[player]
			if success and currentData and currentData.Avatar == Avatar and Avatar.Parent then
				Avatar.Image = image
			end
		end)

		Entry.MouseEnter:Connect(function()
			TweenObj(Entry, { BackgroundColor3 = Styles.CardHover }, 0.15)
			TweenObj(EntryStroke, { Color = MarkedESP.Color }, 0.15)
		end)

		Entry.MouseLeave:Connect(function()
			TweenObj(Entry, { BackgroundColor3 = Color3.fromRGB(26, 27, 35) }, 0.15)
			TweenObj(EntryStroke, { Color = GetPaletteStrokeColor(EntryStroke) }, 0.15)
		end)

		Entry.MouseButton1Click:Connect(function()
			SetMarkedPlayer(player)
			isOpen = false
			OptionsFrame.Visible = false
			UpdateCardHeight()
			UpdateSelectionUI()
			TweenObj(Stroke, { Color = GetPaletteStrokeColor(Stroke) }, 0.2)
		end)

		ReorderEntries()
		UpdateSelectionUI()
	end

	local function SetOpen(open)
		isOpen = open
		OptionsFrame.Visible = open
		UpdateCardHeight()
		UpdateButtonText()
		TweenObj(Stroke, { Color = open and MarkedESP.Color or GetPaletteStrokeColor(Stroke) }, 0.2)
	end

	DropdownButton.MouseButton1Click:Connect(function()
		SetOpen(not isOpen)
	end)

	Card.MouseEnter:Connect(function()
		if not isOpen then TweenObj(Stroke, { Color = MarkedESP.Color }, 0.2) end
	end)

	Card.MouseLeave:Connect(function()
		if not isOpen then TweenObj(Stroke, { Color = GetPaletteStrokeColor(Stroke) }, 0.2) end
	end)

	MarkedESP.DropdownAddOrUpdate = AddOrUpdateEntry
	MarkedESP.DropdownRemove = RemoveEntry
	MarkedESP.DropdownUpdateSelection = UpdateSelectionUI

	for _, player in ipairs(Players:GetPlayers()) do
		AddOrUpdateEntry(player)
	end

	table.insert(UIUpdaters, function()
		ResetMarkedPlayerSelection()
		UpdateSelectionUI()
	end)
end

--// Map Interface Elements Across Target Tab Frames
AddDashboardButton(UI.AimPage, "Enabled", "System Master Processing", "★ Optimal Placement: Core Hub Active On Screen", "Enables global calculation thread loops across physics steps.")
AddDashboardButton(UI.AimPage, "DetectPlayers", "Detect Players", "Target Detection: Roblox Players", "Allows Aim Lock and ESP to detect player characters.", function()
	Target = nil
	RefreshAllESP()
end)
AddDashboardButton(UI.AimPage, "DetectNPCs", "Detect NPCs", "Target Detection: NPC Humanoids", "Allows Aim Lock and ESP to detect NPC models with a Humanoid.", function()
	Target = nil
	RefreshAllESP()
end)
AddDashboardButton(UI.AimPage, "WallCheck", "Raycast Wall Protection", "★ Optimal Placement: Critical Layer Protection", "Prevents engine cross-snapping onto targets located behind solid structures.")
AddDashboardButton(UI.AimPage, "AutoShoot", "Auto-Trigger Mechanism", "★ Optimal Placement: Micro-Weapons Testing Engine", "Automatically handles tool activation parameters during tracking.")
AddDashboardDropdown(UI.AimPage, "TargetPart", "Target Part", {"Head", "HumanoidRootPart", "Torso"}, "Select the body part used for target locking.")

AddDashboardButton(UI.AimPage, "ShowESPUsername", "Show ESP Username", "Shows each detected player's username above their ESP highlight.", "Uses the player's real Roblox username.", function()
	RefreshAllESP()
end)

AddDashboardSlider(UI.AimPage, "ESPUsernameSize", "ESP Username Size", 8, 32, "Controls the username text size above highlighted players.", "Default size: 14.", function(value)
	Settings.ESPUsernameSize = math.floor(value + 0.5)
	RefreshAllESP()
end, 0)

-- NEW: Configurable Visual Enhancements Hooked to UI
AddDashboardButton(UI.AimPage, "TargetIndicator", "Draw Target Indicator", "★ Aimbot Customization: Realtime Tracking UI", "Spawns a highly responsive neon circle exactly over the enemy hit-part.")
AddDashboardButton(UI.AimPage, "FOVPulse", "FOV Pulse Animation", "★ Aimbot Customization: Action Feedback Response", "Pulses the main threat boundary ring smoothly when target acquisition is active.")

AddDashboardSlider(UI.AimPage, "Smoothness", "Tracking Camera Smoothness", 1, 100, "★ Optimal Placement: Low-Medium (Natural Damping) (0.15)", "Alters tracking dampening alignment latency to emulate natural aim.")
AddDashboardSlider(UI.AimPage, "MaxDistance", "Target Maximum Distance", 50, 5000, "★ Optimal Placement: Low (Safe Render Limit) (1000)", "Calculates the ultimate cut-off barrier stud threshold for lock acquisition.")

AddDashboardButton(UI.VisPage, "ShowMarkedPlayerESP", "Show Marked Player ESP", "Marks one selected player with a bright yellow ESP.", "Selection resets if that player respawns or leaves.", function()
	RefreshAllESP()
end)

AddMarkedPlayerDropdown(UI.VisPage)

AddDashboardButton(UI.VisPage, "KillMarkedWithFireAxe", "Kill Marked Player with Fire Axe", "Equips Fire Axe, starts the click/ability, waits, then teleports to the marked player's HumanoidRootPart.", "Requires a marked player. Runs once, then switches OFF.", function(enabled)
	if enabled then
		task.spawn(KillMarkedPlayerWithFireAxe)
	end
end)

AddDashboardSlider(UI.VisPage, "FireAxeTeleportDelay", "Fire Axe Teleport Delay", 0.1, 5, "Delay after the click starts before teleporting to the marked player.", "Default: 0.5 seconds. Range: 0.1 - 5.0 seconds.", function(value)
	Settings.FireAxeTeleportDelay = math.clamp(value, 0.1, 5)
end, 1)

AddDashboardButton(UI.VisPage, "OffscreenWarning", "Off-Screen Player Warning", "Shows a warning icon at the screen edge for enemy players outside the camera view.", "Blinks when that player is looking at you with a clear raycast.", function()
	UpdateOffscreenWarnings()
end)

AddDashboardSlider(UI.VisPage, "WarningIMGSize", "Warning IMG Size", 24, 100, "Controls the size of the off-screen warning logo.", "Default size: 58.", function(value)
	Settings.WarningIMGSize = math.floor(value + 0.5)
	UpdateOffscreenIndicatorSizes()
end, 0)

AddDashboardButton(UI.VisPage, "ESPEnabled", "Highlight Player ESP Outlines", "★ Optimal Placement: Traditional Outline Overlay Engine", "Renders precise direct screen boundary overlays on top of live enemies.")
AddDashboardButton(UI.VisPage, "ShowFOV", "Draw Screen Field of View", "★ Optimal Placement: Center Axis Display", "Toggles the crosshair peripheral validation threat boundary ring visibility.")
AddDashboardSlider(UI.VisPage, "FOVRadius", "Crosshair Threat Radius", 20, 500, "★ Optimal Placement: Low-Medium (Zero-Lag Filtering) (120)", "Adjusts the width scale boundary of your screen targeting frame ring.")
AddDashboardSlider(UI.VisPage, "ESPTransparency", "ESP Elements Opacity Alpha", 0.0, 1.0, "★ Optimal Placement: Medium High Density Fill (0.4)", "Modulates internal card outline overlay drawing opacity visibility scales.", function()
	RefreshAllESP()
end)

AddDashboardButton(UI.TestPage, "Fullbright", "Enable Fullbright", "Makes dark areas fully visible.", "Toggle enhanced lighting visibility.", function(enabled)
	UpdateFullbright(enabled)
end)

AddDashboardButton(UI.TestPage, "ShowFPS", "Show FPS", "Displays your current frame rate.", "Useful for performance and lag testing.")

AddDashboardButton(UI.TestPage, "WallCheckDebug", "WallCheck Debug", "Draws a line to the current aim target.", "Green = visible, red = blocked by geometry.")

AddDashboardButton(UI.TestPage, "TargetInfo", "Target Info", "Shows information about the current target.", "Displays health, distance and selected body part.")


AddDashboardButton(UI.FarmPage, "FarmEnabled", "Start Farm", "Automatically finds and processes nearby safes/registers.", "Game-specific farm logic using the existing target/remotes.", function(enabled)
	if enabled then Farm.Start() else Farm.Stop() end
end)

AddDashboardButton(UI.FarmPage, "FarmAutoMoney", "Auto Money", "Automatically picks up nearby money drops.", "Optimized interval scan instead of RenderStepped.", function(enabled)
	if enabled then Farm.StartAutoMoney() else Farm.StopAutoMoney() end
end)

AddDashboardDropdown(UI.FarmPage, "InvisibilityMode", "Invisibility Mode", {"Air", "Bottom"}, "Air = current R6 animation mode. Bottom = keeps the HumanoidRootPart below the floor.", function()
	if Settings.FarmInvisibility then
		Farm.DisableInvisibility()
		Settings.FarmInvisibility = true
		Farm.EnableInvisibility()
	end
end)

AddDashboardButton(UI.FarmPage, "FarmInvisibility", "Invisibility", "Enables the selected invisibility mode.", "Air requires R6. Bottom uses the HumanoidRootPart and no invis animation.", function(enabled)
	if enabled then Farm.EnableInvisibility() else Farm.DisableInvisibility() end
end)

AddDashboardSlider(UI.FarmPage, "FarmInvisSpeed", "Invisibility Speed", 1, 40, "Controls movement speed while invisibility is active.", "12 is the default speed.", function(value)
	Settings.FarmInvisSpeed = math.floor(value + 0.5)
end, 0)

AddDashboardButton(UI.FarmPage, "ExploitSimDamage", "Exploit Simulator Damage", "Uses your own game's ReplicatedStorage.Remotes.ExploitHit RemoteEvent.", "When enabled, WallCheck is ignored for simulator damage so Bottom targets can still be hit.", function()
	Target = nil
end)

AddDashboardSlider(UI.FarmPage, "ExploitSimDamageAmount", "Exploit Sim Damage", 1, 100, "Damage requested from your own simulator server.", "The server still validates and clamps the value.", function(value)
	Settings.ExploitSimDamageAmount = math.floor(value + 0.5)
end, 0)

AddDashboardButton(UI.FarmPage, "PanicMode", "PanicMode", "Automatically enables the selected Invisibility Mode when your health drops below 15 HP.", "Triggers once per life. Invisibility stays enabled until you disable it manually or respawn.", function(enabled)
	if enabled then
		Farm.EnablePanicMode()
	else
		Farm.DisablePanicMode()
	end
end)

AddDashboardButton(UI.FarmPage, "FarmAntiAFK", "Anti-AFK", "Prevents the idle kick while enabled.", "Uses one Idled connection instead of a frame loop.", function(enabled)
	if enabled then Farm.EnableAntiAFK() else Farm.DisableAntiAFK() end
end)

AddDashboardButton(UI.VisPage, "FarmSafeESP", "Safe / Register ESP", "Highlights farm safes and registers.", "Green = available, red = broken.", function(enabled)
	if enabled then Farm.EnableSafeESP() else Farm.DisableSafeESP() end
end)

AddDashboardSlider(UI.VisPage, "FarmESPTextSize", "Farm ESP Text Size", 10, 40, "Controls the Safe/Register ESP label size.", "No movement-speed control is included.", function(value)
	Settings.FarmESPTextSize = math.floor(value + 0.5)
end, 0)

AddDashboardButton(UI.CustPage, "EnableRemoteSpy", "Enable Remote Spy", "Logs Ultimate Hub remote calls plus incoming RemoteEvent traffic.", "80 console lines per 45 seconds. Shared API is exposed as getgenv().AehmreRemoteSpy / shared.AehmreRemoteSpy.", function(enabled)
	RemoteSpy.ResetWindow()

	if enabled then
		RemoteSpy.EnableIncomingSpy()
		RemoteSpy.PrintStatus()
		print("[RemoteSpy] Shared API ready: env.AehmreRemoteSpy.Fire / Invoke")
	else
		RemoteSpy.DisableIncomingSpy()
		print("[RemoteSpy] DISABLED")
	end
end)

UI.CycleColorBtn = Instance.new("TextButton", UI.CustPage)
UI.CycleColorBtn.Size = UDim2.new(0.94, 0, 0, 36)
UI.CycleColorBtn.BackgroundColor3 = Styles.CardBg
UI.CycleColorBtn.Font = Enum.Font.GothamBold
UI.CycleColorBtn.TextColor3 = Styles.TextMain
UI.CycleColorBtn.Text = "SWAP ACCENT PALETTE CREATIVE MATRIX"
UI.CycleColorBtn.TextSize = 10
UI.CycleColorBtn.BorderSizePixel = 0
Instance.new("UICorner", UI.CycleColorBtn).CornerRadius = UDim.new(0, 6)
UI.CycleStroke = Instance.new("UIStroke", UI.CycleColorBtn)
ApplyPaletteStroke(UI.CycleStroke)
HookButtonAnimations(UI.CycleColorBtn, Styles.CardBg, Styles.CardHover)

UI.CycleColorBtn.MouseButton1Click:Connect(function()
	Settings.AccentColorIndex = Settings.AccentColorIndex + 1
	if Settings.AccentColorIndex > #AccentPresets then Settings.AccentColorIndex = 1 end
	local currentAccent = AccentPresets[Settings.AccentColorIndex]

	Styles.Accent = currentAccent
	FOVCircle.Color = FOVIdleColor
	TargetDot.Color = currentAccent
	FPSDisplay.Color = currentAccent
	TargetInfoText.Color = currentAccent
	UI.SidebarContainer.ScrollBarImageColor3 = currentAccent
	TweenObj(UI.CycleStroke, { Color = currentAccent }, 0.25)
	TweenObj(UI.SystemStatusBtn, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }, 0.25)
	TweenObj(UI.ActiveDotLabel, { TextColor3 = Color3.fromRGB(70, 235, 120) }, 0.25)
	TweenObj(UI.ShortcutTitle, { TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.25)
	TweenObj(UI.SubTitle, { TextColor3 = currentAccent }, 0.25)
	for _, tData in pairs(UI.Tabs) do
		tData.Btn.IndicatorStrip.BackgroundColor3 = currentAccent
		tData.Page.ScrollBarImageColor3 = currentAccent
	end
end)

AddDashboardSlider(UI.CustPage, "MenuTransparency", "Background Canvas Alpha Opacity", 0, 100, "★ Configuration Layer: Realtime Glass Damping Modulator", "Blends the main user interface frames seamlessly into the background layers.", function(val)
	local calculatedAlpha = val / 100
	UI.MainFrame.BackgroundTransparency = calculatedAlpha
	UI.HeaderBar.BackgroundTransparency = calculatedAlpha
	UI.Sidebar.BackgroundTransparency = calculatedAlpha
end)

AddDashboardSlider(UI.CustPage, "BorderThickness", "User Interface Structural Thickness", 1, 5, "★ Configuration Layer: Outer Boundary Vector Frame Line Scaling", "Alters the pixel width dimensions of all highlighted main outer boundaries.", function(val)
	UI.MainStroke.Thickness = val
end)

AddKeybindControl(UI.KeybindPage, "AimKey", "Set Aimbot Keybind", "Click the key frame, then press any keyboard key.")
AddKeybindControl(UI.KeybindPage, "ToggleUiKey", "Set Menu Keybind", "Click the key frame, then press any keyboard key.")
AddKeybindControl(UI.KeybindPage, "FarmInvisToggleKey", "Set Invisibility Toggle Keybind", "Toggles the R6 invisibility system on or off.")

-- PAGE 4: SETTINGS (Now Contains the Config Module)

-- NEW: Config Save Button
UI.SaveConfigBtn = Instance.new("TextButton", UI.SettPage)
UI.SaveConfigBtn.Size = UDim2.new(0.94, 0, 0, 36)
UI.SaveConfigBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
UI.SaveConfigBtn.Font = Enum.Font.GothamBold
UI.SaveConfigBtn.TextColor3 = Styles.TextMain
UI.SaveConfigBtn.Text = "SAVE CONFIGURATION PRESETS"
UI.SaveConfigBtn.TextSize = 10
UI.SaveConfigBtn.BorderSizePixel = 0
Instance.new("UICorner", UI.SaveConfigBtn).CornerRadius = UDim.new(0, 6)
UI.SaveStroke = Instance.new("UIStroke", UI.SaveConfigBtn)
ApplyPaletteStroke(UI.SaveStroke)
HookButtonAnimations(UI.SaveConfigBtn, Color3.fromRGB(35, 40, 50), Color3.fromRGB(45, 50, 65))

UI.SaveConfigBtn.MouseButton1Click:Connect(function()
	env[CurrentScriptID .. "_DataPacket"] = {
		Settings = table.clone(Settings)
	}
	TweenObj(UI.SaveConfigBtn, { BackgroundColor3 = Color3.fromRGB(50, 200, 100) }, 0.15)
	UI.SaveConfigBtn.Text = "CONFIGURATION SAVED SUCCESSFULLY"
	SystemLogEvent("Configuration Profile Saved.")
	task.wait(1.5)
	TweenObj(UI.SaveConfigBtn, { BackgroundColor3 = Color3.fromRGB(35, 40, 50) }, 0.25)
	UI.SaveConfigBtn.Text = "SAVE CONFIGURATION PRESETS"
end)

-- NEW: Config Reset Button
UI.ResetConfigBtn = Instance.new("TextButton", UI.SettPage)
UI.ResetConfigBtn.Size = UDim2.new(0.94, 0, 0, 36)
UI.ResetConfigBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 35)
UI.ResetConfigBtn.Font = Enum.Font.GothamBold
UI.ResetConfigBtn.TextColor3 = Color3.fromRGB(250, 180, 100)
UI.ResetConfigBtn.Text = "RESET ALL SYSTEMS TO FACTORY DEFAULTS"
UI.ResetConfigBtn.TextSize = 10
UI.ResetConfigBtn.BorderSizePixel = 0
Instance.new("UICorner", UI.ResetConfigBtn).CornerRadius = UDim.new(0, 6)
HookButtonAnimations(UI.ResetConfigBtn, Color3.fromRGB(50, 40, 35), Color3.fromRGB(65, 50, 45))

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
	ResetMarkedPlayerSelection()
	RefreshAllESP()

	FOVCircle.Visible = false
	TargetDot.Visible = false
	FPSDisplay.Visible = false
	WallDebugLine.Visible = false
	TargetInfoText.Visible = false

	local currentAccent = AccentPresets[Settings.AccentColorIndex]
	Styles.Accent = currentAccent
	FOVCircle.Color = FOVIdleColor
	TargetDot.Color = currentAccent
	FPSDisplay.Color = currentAccent
	TargetInfoText.Color = currentAccent
	UI.SidebarContainer.ScrollBarImageColor3 = currentAccent
	TweenObj(UI.CycleStroke, { Color = currentAccent }, 0.25)
	TweenObj(UI.SystemStatusBtn, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }, 0.25)
	TweenObj(UI.ActiveDotLabel, { TextColor3 = Color3.fromRGB(70, 235, 120) }, 0.25)
	TweenObj(UI.ShortcutTitle, { TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.25)
	TweenObj(UI.SubTitle, { TextColor3 = currentAccent }, 0.25)

	for _, tData in pairs(UI.Tabs) do
		tData.Btn.IndicatorStrip.BackgroundColor3 = currentAccent
		tData.Page.ScrollBarImageColor3 = currentAccent
	end

	UpdateKeybindValueButtons()
	UpdateLeftPanelShortcuts()
end

UI.ResetConfigBtn.MouseButton1Click:Connect(function()
	FactoryResetSettings()
	SystemLogEvent("Engine Reverted to Factory Configuration.")
end)

UI.KillEngineBtn = Instance.new("TextButton", UI.SettPage)
UI.KillEngineBtn.Size = UDim2.new(0.94, 0, 0, 36)
UI.KillEngineBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 25)
UI.KillEngineBtn.Font = Enum.Font.GothamBold
UI.KillEngineBtn.TextColor3 = Color3.fromRGB(240, 110, 110)
UI.KillEngineBtn.Text = "UNLOAD ENGINE MATRIX AND WIPE GUI"
UI.KillEngineBtn.TextSize = 10
UI.KillEngineBtn.BorderSizePixel = 0
Instance.new("UICorner", UI.KillEngineBtn).CornerRadius = UDim.new(0, 6)
HookButtonAnimations(UI.KillEngineBtn, Color3.fromRGB(45, 20, 25), Color3.fromRGB(60, 25, 30))

UI.KillEngineBtn.MouseButton1Click:Connect(CinematicClose)

Compat.Log("BOOT", "Dashboard controls initialized")

UI.AuthFrame = Instance.new("Frame", UI.ScreenGui)
UI.AuthFrame.Name = "AccessFrame"
UI.AuthFrame.Size = UDim2.new(0, 390, 0, 250)
UI.AuthFrame.AnchorPoint = Vector2.new(0.5, 0.5)
UI.AuthFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
UI.AuthFrame.BackgroundColor3 = Styles.Bg
UI.AuthFrame.BorderSizePixel = 0
UI.AuthFrame.Active = true
UI.AuthFrame.Visible = true
Instance.new("UICorner", UI.AuthFrame).CornerRadius = UDim.new(0, 10)

UI.AuthUIScale = Instance.new("UIScale", UI.AuthFrame)

UI.AuthStroke = Instance.new("UIStroke", UI.AuthFrame)
ApplyPaletteStroke(UI.AuthStroke, 1)
UI.AuthStroke.Thickness = 1.5

UI.AuthHeader = Instance.new("Frame", UI.AuthFrame)
UI.AuthHeader.Size = UDim2.new(1, 0, 0, 44)
UI.AuthHeader.BackgroundColor3 = Styles.SidebarBg
UI.AuthHeader.BorderSizePixel = 0
Instance.new("UICorner", UI.AuthHeader).CornerRadius = UDim.new(0, 10)

UI.AuthHeaderMask = Instance.new("Frame", UI.AuthHeader)
UI.AuthHeaderMask.Size = UDim2.new(1, 0, 0, 10)
UI.AuthHeaderMask.Position = UDim2.new(0, 0, 1, -10)
UI.AuthHeaderMask.BackgroundColor3 = Styles.SidebarBg
UI.AuthHeaderMask.BorderSizePixel = 0

UI.AuthTitle = Instance.new("TextLabel", UI.AuthHeader)
UI.AuthTitle.Size = UDim2.new(1, -28, 0, 20)
UI.AuthTitle.Position = UDim2.new(0, 14, 0, 7)
UI.AuthTitle.BackgroundTransparency = 1
UI.AuthTitle.Text = "AEHMRE // WELCOME"
UI.AuthTitle.Font = Enum.Font.GothamBold
UI.AuthTitle.TextSize = 13
UI.AuthTitle.TextColor3 = Styles.TextMain
UI.AuthTitle.TextXAlignment = Enum.TextXAlignment.Left

UI.AuthSubTitle = Instance.new("TextLabel", UI.AuthHeader)
UI.AuthSubTitle.Size = UDim2.new(1, -28, 0, 14)
UI.AuthSubTitle.Position = UDim2.new(0, 14, 0, 25)
UI.AuthSubTitle.BackgroundTransparency = 1
UI.AuthSubTitle.Text = "ULTIMATE HUB"
UI.AuthSubTitle.Font = Enum.Font.GothamSemibold
UI.AuthSubTitle.TextSize = 9
UI.AuthSubTitle.TextColor3 = Styles.Accent
UI.AuthSubTitle.TextXAlignment = Enum.TextXAlignment.Left

UI.AuthInfo = Instance.new("TextLabel", UI.AuthFrame)
UI.AuthInfo.Size = UDim2.new(1, -32, 0, 38)
UI.AuthInfo.Position = UDim2.new(0, 16, 0, 62)
UI.AuthInfo.BackgroundTransparency = 1
UI.AuthInfo.Text = "Join the Discord for updates, announcements and future access-system information."
UI.AuthInfo.Font = Enum.Font.Gotham
UI.AuthInfo.TextSize = 10
UI.AuthInfo.TextWrapped = true
UI.AuthInfo.TextColor3 = Styles.TextDark
UI.AuthInfo.TextXAlignment = Enum.TextXAlignment.Left
UI.AuthInfo.TextYAlignment = Enum.TextYAlignment.Top

UI.KeyInput = Instance.new("TextBox", UI.AuthFrame)
UI.KeyInput.Size = UDim2.new(1, -32, 0, 38)
UI.KeyInput.Position = UDim2.new(0, 16, 0, 108)
UI.KeyInput.BackgroundColor3 = Styles.CardBg
UI.KeyInput.BorderSizePixel = 0
UI.KeyInput.ClearTextOnFocus = false
UI.KeyInput.TextEditable = false
UI.KeyInput.Text = "KEY SYSTEM DISABLED FOR NOW"
UI.KeyInput.TextColor3 = Styles.TextDark
UI.KeyInput.Font = Enum.Font.Code
UI.KeyInput.TextSize = 11
UI.KeyInput.TextXAlignment = Enum.TextXAlignment.Center
UI.KeyInput.Active = false
UI.KeyInput.Selectable = false
Instance.new("UICorner", UI.KeyInput).CornerRadius = UDim.new(0, 6)

UI.KeyStroke = Instance.new("UIStroke", UI.KeyInput)
ApplyPaletteStroke(UI.KeyStroke, 3)

UI.CopyDiscordBtn = Instance.new("TextButton", UI.AuthFrame)
UI.CopyDiscordBtn.Size = UDim2.new(0.5, -20, 0, 36)
UI.CopyDiscordBtn.Position = UDim2.new(0, 16, 0, 158)
UI.CopyDiscordBtn.BackgroundColor3 = Styles.Accent
UI.CopyDiscordBtn.BorderSizePixel = 0
UI.CopyDiscordBtn.Text = "COPY DISCORD INVITE"
UI.CopyDiscordBtn.TextColor3 = Color3.fromRGB(10, 10, 12)
UI.CopyDiscordBtn.Font = Enum.Font.GothamBold
UI.CopyDiscordBtn.TextSize = 9
UI.CopyDiscordBtn.AutoButtonColor = false
Instance.new("UICorner", UI.CopyDiscordBtn).CornerRadius = UDim.new(0, 6)

UI.IgnoreBtn = Instance.new("TextButton", UI.AuthFrame)
UI.IgnoreBtn.Size = UDim2.new(0.5, -20, 0, 36)
UI.IgnoreBtn.Position = UDim2.new(0.5, 4, 0, 158)
UI.IgnoreBtn.BackgroundColor3 = Styles.CardBg
UI.IgnoreBtn.BorderSizePixel = 0
UI.IgnoreBtn.Text = "IGNORE"
UI.IgnoreBtn.TextColor3 = Styles.TextMain
UI.IgnoreBtn.Font = Enum.Font.GothamBold
UI.IgnoreBtn.TextSize = 10
UI.IgnoreBtn.AutoButtonColor = false
Instance.new("UICorner", UI.IgnoreBtn).CornerRadius = UDim.new(0, 6)

UI.AuthStatus = Instance.new("TextLabel", UI.AuthFrame)
UI.AuthStatus.Size = UDim2.new(1, -32, 0, 30)
UI.AuthStatus.Position = UDim2.new(0, 16, 0, 204)
UI.AuthStatus.BackgroundTransparency = 1
UI.AuthStatus.Text = "Discord access is optional."
UI.AuthStatus.Font = Enum.Font.GothamSemibold
UI.AuthStatus.TextSize = 9
UI.AuthStatus.TextWrapped = true
UI.AuthStatus.TextColor3 = Styles.TextDark

HookButtonAnimations(UI.CopyDiscordBtn, Styles.Accent, Styles.Accent:Lerp(Color3.fromRGB(255, 255, 255), 0.15))
HookButtonAnimations(UI.IgnoreBtn, Styles.CardBg, Styles.CardHover)

UI.AuthDragState = {
	Dragging = false,
	Input = nil,
	Start = nil,
	StartPosition = nil
}

UI.AuthHeader.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		UI.AuthDragState.Dragging = true
		UI.AuthDragState.Start = input.Position
		UI.AuthDragState.StartPosition = UI.AuthFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				UI.AuthDragState.Dragging = false
			end
		end)
	end
end)

UI.AuthHeader.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		UI.AuthDragState.Input = input
	end
end)

SafeConnect(UserInputService.InputChanged, function(input)
	if input == UI.AuthDragState.Input and UI.AuthDragState.Dragging then
		local delta = input.Position - UI.AuthDragState.Start
		local startPosition = UI.AuthDragState.StartPosition

		UI.AuthFrame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

local function SetAuthStatus(text, color)
	UI.AuthStatus.Text = text
	UI.AuthStatus.TextColor3 = color or Styles.TextDark
end

UI.CopyDiscordBtn.MouseButton1Click:Connect(function()
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

UI.IgnoreBtn.MouseButton1Click:Connect(function()
	AccessNoticeDismissed = true
	UI.AuthFrame.Visible = false
	UI.MainFrame.Visible = true

	if UI.MobileControls then
		UI.MobileControls.Visible = IsTouchDevice
	end

	UpdateMobileControlButtons()
	RefreshAllESP()
	SystemLogEvent("Welcome screen ignored. Hub unlocked.")
end)

local function UpdateResponsiveScale()
	local viewport = Camera.ViewportSize

	if UI.MainUIScale then
		local widthScale = (viewport.X * 0.92) / 540
		local heightScale = (viewport.Y * 0.86) / 415
		UI.MainUIScale.Scale = math.clamp(math.min(widthScale, heightScale), 0.55, 1)
	end

	if UI.AuthUIScale then
		local authWidthScale = (viewport.X * 0.92) / 390
		local authHeightScale = (viewport.Y * 0.86) / 250
		UI.AuthUIScale.Scale = math.clamp(math.min(authWidthScale, authHeightScale), 0.62, 1)
	end
end

Compat.Log("BOOT", "Auth UI initialized")
UpdateResponsiveScale()
SafeConnect(Camera:GetPropertyChangedSignal("ViewportSize"), UpdateResponsiveScale)

UI.MainFrame.Visible = false
UI.AuthFrame.Visible = true
UI.MobileControls.Visible = false
UpdateKeybindValueButtons()
UpdateLeftPanelShortcuts()
SetBootStatus("Ready")
task.defer(function()
	task.wait(0.15)
	if UI.BootGui then
	\tUI.BootGui:Destroy()
	\tUI.BootGui = nil
	\tUI.BootLabel = nil
	end
end)
Compat.Log("READY", string.format("Hub initialized in %.2fs", os.clock() - Compat.BootStarted))
