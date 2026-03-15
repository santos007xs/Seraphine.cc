--// Services 
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IsStudio = RunService:IsStudio()

--// Fetch library
local ImGui
if IsStudio then
	ImGui = require(ReplicatedStorage.ImGui)
else
	local SourceURL = 'https://github.com/depthso/Roblox-ImGUI/raw/main/ImGui.lua'
	ImGui = loadstring(game:HttpGet(SourceURL))()
end

--// Services para Silent Aim
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

--// Window 
local Window = ImGui:CreateWindow({
	Title = "seraphine.cc",
	Size = UDim2.new(0, 350, 0, 400),
	Position = UDim2.new(0.5, 0, 0, 70),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	TitleBarColor3 = Color3.fromRGB(0, 0, 0)
})
Window:Center()

-- Toggle UI com Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		Window:SetVisible(not Window.Visible)
	end
end)

--// AIMBOT TAB
local AimbotTab = Window:CreateTab({
	Name = "Aimbot"
})

local SilentAimSection = AimbotTab:Separator({
	Text = "Silent Aim"
})

--// VISUAL TAB
local VisualTab = Window:CreateTab({
	Name = "Visual"
})

local ESPSection = VisualTab:TreeNode({
	Title = "ESP",
	Open = true
})

local ChamsSection = VisualTab:TreeNode({
	Title = "Chams",
	Open = true
})

--// MISC TAB
local MiscTab = Window:CreateTab({
	Name = "Misc"
})

local WalkspeedSection = MiscTab:TreeNode({
	Title = "Walkspeed",
	Open = true
})

Window:ShowTab(AimbotTab)

--// SILENT AIM SETUP
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/RapperDeluxe/scripts/main/silent%20aim%20module"))()
Aiming.TeamCheck(false)
Aiming.FOV = 90 
Aiming.ShowFOV = false

function Aiming.Check()
    if not (Aiming.Enabled == true and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart ~= nil) then
        return false
    end
    local Character = Aiming.Character(Aiming.Selected)
    if not Character then return false end
    
    local BodyEffects = Character:FindFirstChild("BodyEffects")
    if BodyEffects then
        local KO = BodyEffects:FindFirstChild("K.O")
        if KO and KO.Value then return false end
    end
    return true
end

local __index
__index = hookmetamethod(game, "__index", newcclosure(function(t, k)
    if (t:IsA("Mouse") and (k == "Hit" or k == "Target") and Aiming.Check()) then
        local SelectedPart = Aiming.SelectedPart
        
        if (k == "Hit") then
            return SelectedPart.CFrame
        else
            return SelectedPart
        end
    end
    
    return __index(t, k)
end))

print("Silent Aim carregado!")

-- Bypass Adonis
local getinfo = getinfo or debug.getinfo
local Hooked = {}
local Detected, Kill
setthreadidentity(2)
for i, v in getgc(true) do
    if typeof(v) == "table" then
        local DetectFunc = rawget(v, "Detected")
        local KillFunc = rawget(v, "Kill")
    
        if typeof(DetectFunc) == "function" and not Detected then
            Detected = DetectFunc
            
            local Old; Old = hookfunction(Detected, function(Action, Info, NoCrash)
                return true
            end)
            table.insert(Hooked, Detected)
        end
        if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
            Kill = KillFunc
            local Old; Old = hookfunction(Kill, function(Info)
            end)
            table.insert(Hooked, Kill)
        end
    end
end
local Old; Old = hookfunction(getrenv().debug.info, newcclosure(function(...)
    local LevelOrFunc, Info = ...
    if Detected and LevelOrFunc == Detected then
        return coroutine.yield(coroutine.running())
    end
    
    return Old(...)
end))
setthreadidentity(7)
warn("[Adonis Bypass]: Ativado!")

--// SILENT AIM SECTION
local SilentAimToggle = AimbotTab:Checkbox({
	Label = "Silent Aim",
	Value = false,
	Callback = function(self, Value)
		Aiming.Enabled = Value
	end,
})

local FOVSlider = AimbotTab:ProgressSlider({
	Label = "FOV Size",
	Value = 90,
	MinValue = 10,
	MaxValue = 500,
	Callback = function(self, Value)
		Aiming.FOV = Value
	end,
})

local HitChanceSlider = AimbotTab:ProgressSlider({
	Label = "Hit Chance",
	Value = 100,
	MinValue = 0,
	MaxValue = 100,
	Callback = function(self, Value)
		Aiming.HitChance = Value
	end,
})

local TargetPartCombo = AimbotTab:Combo({
	Selected = "Head",
	Label = "Target Part",
	Items = {
		"Head",
		"Neck",
		"Torso",
		"UpperTorso",
		"LowerTorso",
		"Left Arm",
		"Right Arm",
		"Left Leg",
		"Right Leg",
	},
	Callback = function(self, Value)
		Aiming.TargetPart = {Value}
	end,
})

--// CAMLOCK SECTION
local CamlockSection = AimbotTab:TreeNode({
	Title = "Camlock",
	Open = true
})

--// CAMLOCK VARIABLES
local CamlockEnabled = false
local CamlockFovEnabled = false
local CamlockSmooth = 10
local CamlockFovSize = 100
local CamlockTarget = nil
local CamlockVisibleCheck = false
local CamlockDistanceEnabled = false
local CamlockMaxDistance = 500
local CamlockBodyPart = "HumanoidRootPart"
local CamlockKoCheck = false

local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 1
FovCircle.Filled = false
FovCircle.Color = Color3.fromRGB(255, 255, 255)

local function GetScreenCenter()
	return Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end

local function GetTargetPart(char)
	if not char then return nil end
	local part = char:FindFirstChild(CamlockBodyPart)
	if not part then
		part = char:FindFirstChild("HumanoidRootPart")
	end
	return part
end

local function IsVisible(targetPart)
	if not targetPart then return false end
	local rayOrigin = camera.CFrame.Position
	local rayDirection = targetPart.Position - rayOrigin
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	if result then
		local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
		local hitPlayer = hitChar and Players:GetPlayerFromCharacter(hitChar)
		if hitPlayer then return true else return false end
	end
	return true
end

local function IsAlive(player)
	if not player then return false end
	local char = player.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return false end
	if hum:GetState() == Enum.HumanoidStateType.Dead then return false end
	if hum.Health <= 0 then return false end
	return true
end

local function GetClosestPlayerInFov()
	if CamlockTarget then
		local char = CamlockTarget.Character
		local part = GetTargetPart(char)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if part and hum and hum.Health > 0 then
			if CamlockKoCheck and not IsAlive(CamlockTarget) then
				CamlockTarget = nil
			else
				return CamlockTarget
			end
		else
			CamlockTarget = nil
		end
	end

	local closest = nil
	local closestDist = math.huge
	local screenCenter = GetScreenCenter()

	for _, player in pairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		if CamlockKoCheck and not IsAlive(player) then continue end

		local char = player.Character
		local part = GetTargetPart(char)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not part or not hum or hum.Health <= 0 then continue end

		if CamlockDistanceEnabled then
			local worldDist = (camera.CFrame.Position - part.Position).Magnitude
			if worldDist > CamlockMaxDistance then continue end
		end

		local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
		if not onScreen then continue end

		local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
		if screenDist < CamlockFovSize and screenDist < closestDist then
			closestDist = screenDist
			closest = player
		end
	end

	CamlockTarget = closest
	return closest
end

local camlockConn = RunService.Heartbeat:Connect(function()
	local screenCenter = GetScreenCenter()
	FovCircle.Visible = CamlockFovEnabled
	FovCircle.Position = screenCenter
	FovCircle.Radius = CamlockFovSize

	if not CamlockEnabled then
		CamlockTarget = nil
		return
	end

	if CamlockKoCheck and CamlockTarget and not IsAlive(CamlockTarget) then
		CamlockTarget = nil
		return
	end

	local target = GetClosestPlayerInFov()
	if not target then
		return
	end

	local char = target.Character
	local part = GetTargetPart(char)
	if not part then return end

	local targetCFrame = CFrame.new(camera.CFrame.Position, part.Position)
	camera.CFrame = camera.CFrame:Lerp(targetCFrame, 1 / CamlockSmooth)
end)

--// CAMLOCK UI SECTION
CamlockSection:Checkbox({
	Label = "Camlock",
	Value = false,
	Callback = function(self, Value)
		CamlockEnabled = Value
		if not Value then
			CamlockTarget = nil
		end
	end,
})

CamlockSection:Checkbox({
	Label = "FOV Circle",
	Value = false,
	Callback = function(self, Value)
		CamlockFovEnabled = Value
	end,
})

CamlockSection:Checkbox({
	Label = "KO Check",
	Value = false,
	Callback = function(self, Value)
		CamlockKoCheck = Value
		if Value and CamlockTarget and not IsAlive(CamlockTarget) then
			CamlockTarget = nil
		end
	end,
})

CamlockSection:ProgressSlider({
	Label = "Smooth",
	Value = 10,
	MinValue = 1,
	MaxValue = 50,
	Callback = function(self, Value)
		CamlockSmooth = Value
	end,
})

CamlockSection:ProgressSlider({
	Label = "FOV Size",
	Value = 100,
	MinValue = 10,
	MaxValue = 500,
	Callback = function(self, Value)
		CamlockFovSize = Value
	end,
})

CamlockSection:Combo({
	Selected = "HumanoidRootPart",
	Label = "Target Part",
	Items = {
		"HumanoidRootPart",
		"Head",
		"UpperTorso",
		"LowerTorso",
		"Left Arm",
		"Right Arm",
		"Left Leg",
		"Right Leg",
	},
	Callback = function(self, Value)
		CamlockBodyPart = Value
		CamlockTarget = nil
	end,
})

--// CAMLOCK KEYBIND VARIABLES
local CamlockKeybindMode = "Toggle"
local CamlockKeybind = Enum.KeyCode.X
local CamlockKeyPressed = false

--// CAMLOCK MODE DROPDOWN
CamlockSection:Combo({
	Selected = "Toggle",
	Label = "Mode",
	Items = {
		"Toggle",
		"Hold"
	},
	Callback = function(self, Value)
		CamlockKeybindMode = Value
	end,
})

--// CAMLOCK KEYBIND
CamlockSection:Keybind({
	Label = "Keybind",
	Value = Enum.KeyCode.X,
	Callback = function(self, KeyCode)
		CamlockKeybind = KeyCode
	end,
})

--// HANDLE CAMLOCK KEYBIND INPUT
local function HandleCamlockKeybind(input, began)
	if input.KeyCode == CamlockKeybind then
		if began then
			CamlockKeyPressed = true
			if CamlockKeybindMode == "Toggle" then
				CamlockEnabled = not CamlockEnabled
			elseif CamlockKeybindMode == "Hold" then
				CamlockEnabled = true
			end
		else
			CamlockKeyPressed = false
			if CamlockKeybindMode == "Hold" then
				CamlockEnabled = false
			end
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	HandleCamlockKeybind(input, true)
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	HandleCamlockKeybind(input, false)
end)



--// ESP HITBOX VARIABLES
local HitboxEnabled = false
local HitboxColor = Color3.fromRGB(128, 128, 128)
local HitboxSize = 5
local HitboxData = {}

local function RemoveHitbox(player)
	local data = HitboxData[player]
	if not data then return end
	if data.part then
		pcall(function() data.part:Destroy() end)
	end
	if data.highlight then
		pcall(function() data.highlight:Destroy() end)
	end
	HitboxData[player] = nil
end

local function CreateHitbox(player)
	if player == LocalPlayer then return end
	RemoveHitbox(player)
	
	local char = player.Character
	if not char then return end
	
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local data = {}
	
	-- Criar Part invisível para o box
	local part = Instance.new("Part")
	part.Name = "HitboxBox"
	part.Shape = Enum.PartType.Block
	part.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
	part.Anchored = false
	part.CanCollide = false
	part.Massless = true
	part.Transparency = 1
	part.CanQuery = false
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = part
	weld.Parent = part
	
	part.CFrame = root.CFrame
	part.Parent = root
	
	-- Highlight para ver através de paredes
	local hl = Instance.new("Highlight")
	hl.FillColor = HitboxColor
	hl.FillTransparency = 0.4
	hl.OutlineColor = HitboxColor
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Enabled = HitboxEnabled
	hl.Parent = char
	
	data.part = part
	data.highlight = hl
	HitboxData[player] = data
end

local function RefreshAllHitboxes()
	for player, data in pairs(HitboxData) do
		if data.highlight then
			data.highlight.Enabled = HitboxEnabled
			data.highlight.FillColor = HitboxColor
			data.highlight.OutlineColor = HitboxColor
		end
	end
end

local function SetupHitboxPlayer(player)
	if player == LocalPlayer then return end
	if player.Character then
		CreateHitbox(player)
	end
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		if HitboxEnabled then
			CreateHitbox(player)
		end
	end)
end

for _, player in pairs(Players:GetPlayers()) do
	SetupHitboxPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Wait()
	task.wait(0.5)
	SetupHitboxPlayer(player)
end)

Players.PlayerRemoving:Connect(RemoveHitbox)

--// ESP HITBOX UI
ESPSection:Checkbox({
	Label = "Hitbox",
	Value = false,
	Callback = function(self, Value)
		HitboxEnabled = Value
		if Value then
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					CreateHitbox(player)
				end
			end
		else
			for player, _ in pairs(HitboxData) do
				RemoveHitbox(player)
			end
		end
		RefreshAllHitboxes()
	end,
})

--// WALKSPEED VARIABLES
local WalkspeedEnabled = false
local WalkspeedValue = 16
local WalkspeedConnection = nil

local function ApplyWalkspeed(enabled)
	if WalkspeedConnection then
		WalkspeedConnection:Disconnect()
		WalkspeedConnection = nil
	end
	
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	
	if enabled then
		hum.WalkSpeed = WalkspeedValue
		WalkspeedConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if hum then
				hum.WalkSpeed = WalkspeedValue
			end
		end)
	else
		hum.WalkSpeed = 16
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.3)
	if WalkspeedEnabled then
		ApplyWalkspeed(true)
	end
end)

--// WALKSPEED UI
WalkspeedSection:Checkbox({
	Label = "Walkspeed",
	Value = false,
	Callback = function(self, Value)
		WalkspeedEnabled = Value
		ApplyWalkspeed(Value)
	end,
})

WalkspeedSection:ProgressSlider({
	Label = "Velocity",
	Value = 16,
	MinValue = 16,
	MaxValue = 1000,
	Callback = function(self, Value)
		WalkspeedValue = Value
		if WalkspeedEnabled then
			ApplyWalkspeed(true)
		end
	end,
})

WalkspeedSection:Keybind({
	Label = "Toggle Walkspeed",
	Value = Enum.KeyCode.V,
	Callback = function(self, KeyCode)
		WalkspeedEnabled = not WalkspeedEnabled
		ApplyWalkspeed(WalkspeedEnabled)
	end,
})

print("UI carregada com sucesso!")
