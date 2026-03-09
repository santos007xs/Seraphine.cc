-- Destroy old UI if exists --
if _G.CompkillerWindow then
    pcall(function()
        _G.CompkillerWindow:Destroy()
    end)
    _G.CompkillerWindow = nil
end

if _G.CompkillerFovCircle then
    pcall(function()
        _G.CompkillerFovCircle:Remove()
    end)
    _G.CompkillerFovCircle = nil
end

if _G.CompkillerTargetGui then
    pcall(function()
        _G.CompkillerTargetGui:Destroy()
    end)
    _G.CompkillerTargetGui = nil
end

if _G.CompkillerConnections then
    for _, c in pairs(_G.CompkillerConnections) do
        pcall(function() c:Disconnect() end)
    end
end
_G.CompkillerConnections = {}

local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();

local Notifier = Compkiller.newNotify();

local ConfigManager = Compkiller:ConfigManager({
    Directory = "Compkiller-UI",
    Config = "Example-Configs"
});

Compkiller:Loader("rbxassetid://73816318844109", 1.5).yield();

local MenuKey = "Insert";

local Window = Compkiller.new({
    Name = "Victory",
    Keybind = MenuKey,
    Logo = "rbxassetid://73816318844109",
    Scale = Compkiller.Scale.Window,
    TextSize = 15,
});

Compkiller:SetTheme("Purple Rose")

_G.CompkillerWindow = Window

-- Services --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Target GUI --
local ShowTarget = false

local TargetGui = Instance.new("ScreenGui")
TargetGui.Name = "TargetGui"
TargetGui.ResetOnSpawn = false
TargetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TargetGui.Parent = game:GetService("CoreGui")
_G.CompkillerTargetGui = TargetGui

local TargetFrame = Instance.new("Frame")
TargetFrame.Size = UDim2.new(0, 200, 0, 80)
TargetFrame.Position = UDim2.new(1, -220, 0.5, -40)
TargetFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TargetFrame.BackgroundTransparency = 0.2
TargetFrame.BorderSizePixel = 0
TargetFrame.Visible = false
TargetFrame.Parent = TargetGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = TargetFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(180, 80, 180)
FrameStroke.Thickness = 1.5
FrameStroke.Parent = TargetFrame

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(0, 56, 0, 56)
AvatarImage.Position = UDim2.new(0, 12, 0.5, -28)
AvatarImage.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AvatarImage.BorderSizePixel = 0
AvatarImage.Image = ""
AvatarImage.Parent = TargetFrame

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 6)
AvatarCorner.Parent = AvatarImage

local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(0, 118, 0, 20)
NameLabel.Position = UDim2.new(0, 76, 0, 10)
NameLabel.BackgroundTransparency = 1
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.TextSize = 13
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
NameLabel.Text = ""
NameLabel.Parent = TargetFrame

local HealthBg = Instance.new("Frame")
HealthBg.Size = UDim2.new(0, 118, 0, 10)
HealthBg.Position = UDim2.new(0, 76, 0, 38)
HealthBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HealthBg.BorderSizePixel = 0
HealthBg.Parent = TargetFrame

local HealthBgCorner = Instance.new("UICorner")
HealthBgCorner.CornerRadius = UDim.new(0, 4)
HealthBgCorner.Parent = HealthBg

local HealthFill = Instance.new("Frame")
HealthFill.Size = UDim2.new(1, 0, 1, 0)
HealthFill.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
HealthFill.BorderSizePixel = 0
HealthFill.Parent = HealthBg

local HealthFillCorner = Instance.new("UICorner")
HealthFillCorner.CornerRadius = UDim.new(0, 4)
HealthFillCorner.Parent = HealthFill

local HealthText = Instance.new("TextLabel")
HealthText.Size = UDim2.new(0, 118, 0, 14)
HealthText.Position = UDim2.new(0, 76, 0, 52)
HealthText.BackgroundTransparency = 1
HealthText.TextColor3 = Color3.fromRGB(200, 200, 200)
HealthText.TextSize = 11
HealthText.Font = Enum.Font.Gotham
HealthText.TextXAlignment = Enum.TextXAlignment.Left
HealthText.Text = ""
HealthText.Parent = TargetFrame

local lastAvatarId = nil

local function UpdateTargetGui(player)
    if not ShowTarget or not player then
        TargetFrame.Visible = false
        return
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum then
        TargetFrame.Visible = false
        return
    end

    TargetFrame.Visible = true
    NameLabel.Text = player.DisplayName or player.Name

    local hp = hum.Health
    local maxHp = hum.MaxHealth
    local ratio = math.clamp(hp / maxHp, 0, 1)

    HealthFill.Size = UDim2.new(ratio, 0, 1, 0)
    HealthText.Text = string.format("HP: %d / %d", math.floor(hp), math.floor(maxHp))

    local r = math.floor(255 * (1 - ratio))
    local g = math.floor(255 * ratio)
    HealthFill.BackgroundColor3 = Color3.fromRGB(r, g, 0)

    if lastAvatarId ~= player.UserId then
        lastAvatarId = player.UserId
        pcall(function()
            local content = Players:GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
            AvatarImage.Image = content
        end)
    end
end

local function HideTargetGui()
    TargetFrame.Visible = false
    lastAvatarId = nil
end

-- Aimbot Variables --
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
_G.CompkillerFovCircle = FovCircle

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
    -- KO check: considera morto apenas se health for exatamente 0
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

local aimbotConn = RunService.Heartbeat:Connect(function()
    local screenCenter = GetScreenCenter()
    FovCircle.Visible = CamlockFovEnabled
    FovCircle.Position = screenCenter
    FovCircle.Radius = CamlockFovSize

    if not CamlockEnabled then
        CamlockTarget = nil
        HideTargetGui()
        return
    end

    if CamlockKoCheck and CamlockTarget and not IsAlive(CamlockTarget) then
        CamlockTarget = nil
        HideTargetGui()
        return
    end

    local target = GetClosestPlayerInFov()
    if not target then
        HideTargetGui()
        return
    end

    local char = target.Character
    local part = GetTargetPart(char)
    if not part then return end

    pcall(function() UpdateTargetGui(target) end)

    local targetCFrame = CFrame.new(camera.CFrame.Position, part.Position)
    camera.CFrame = camera.CFrame:Lerp(targetCFrame, 1 / CamlockSmooth)
end)
table.insert(_G.CompkillerConnections, aimbotConn)

-- Walkspeed --
local WalkspeedEnabled = false
local WalkspeedConnection = nil
getgenv().WalkSpeedValue = 16

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
        hum.WalkSpeed = getgenv().WalkSpeedValue
        WalkspeedConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            hum.WalkSpeed = getgenv().WalkSpeedValue
        end)
    else
        hum.WalkSpeed = 16
    end
end

local wsCharConn = LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if WalkspeedEnabled then ApplyWalkspeed(true) end
end)
table.insert(_G.CompkillerConnections, wsCharConn)

-- Jump Variables --
local NoCooldownEnabled = false
local BhopEnabled = false
local BhopSpeed = 1.2
local NoCooldownConnection = nil
local BhopConnection = nil

local function ApplyJump()
    if NoCooldownConnection then NoCooldownConnection:Disconnect() NoCooldownConnection = nil end
    if BhopConnection then BhopConnection:Disconnect() BhopConnection = nil end

    if NoCooldownEnabled then
        -- Metodo via metamethod para maxima compatibilidade
        pcall(function()
            local gmt = getrawmetatable(game)
            setreadonly(gmt, false)
            local old = gmt.__newindex
            gmt.__newindex = newcclosure(function(t, i, v)
                if i == "JumpPower" then
                    return old(t, i, 50)
                end
                return old(t, i, v)
            end)
            setreadonly(gmt, true)
        end)

        NoCooldownConnection = RunService.Heartbeat:Connect(function()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if not h then return end
            if h.JumpCooldown ~= 0 then
                h.JumpCooldown = 0
            end
        end)
    end

    if BhopEnabled then
        BhopConnection = UserInputService.JumpRequest:Connect(function()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if not h or not r then return end
            h:ChangeState(Enum.HumanoidStateType.Jumping)
            task.defer(function()
                if r and r.Parent then
                    r.AssemblyLinearVelocity = Vector3.new(
                        r.AssemblyLinearVelocity.X * BhopSpeed,
                        math.max(r.AssemblyLinearVelocity.Y, 30),
                        r.AssemblyLinearVelocity.Z * BhopSpeed
                    )
                end
            end)
        end)
    end
end

local jumpCharConn = LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplyJump()
end)
table.insert(_G.CompkillerConnections, jumpCharConn)

-- Fly --
local FlySpeed = 50
local FlyActive = false
local FlyBodyVelocity = nil
local FlyBodyGyro = nil

local function StopFly()
    FlyActive = false
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
    if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function StartFly()
    FlyActive = true
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    hum.PlatformStand = true

    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.zero
    FlyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    FlyBodyVelocity.Parent = root

    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    FlyBodyGyro.D = 100
    FlyBodyGyro.Parent = root

    local flyConn
    flyConn = RunService.Heartbeat:Connect(function()
        if not FlyActive then flyConn:Disconnect() return end
        if not root or not root.Parent then StopFly() return end

        local direction = Vector3.zero
        local cf = camera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end

        FlyBodyGyro.CFrame = cf
        FlyBodyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * FlySpeed or Vector3.zero
    end)
end

-- Unload --
local function UnloadScript()
    CamlockEnabled = false
    CamlockTarget = nil
    WalkspeedEnabled = false
    BhopEnabled = false
    NoCooldownEnabled = false

    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end)

    pcall(function() StopFly() end)

    if NoCooldownConnection then pcall(function() NoCooldownConnection:Disconnect() end) NoCooldownConnection = nil end
    if BhopConnection then pcall(function() BhopConnection:Disconnect() end) BhopConnection = nil end
    if WalkspeedConnection then pcall(function() WalkspeedConnection:Disconnect() end) WalkspeedConnection = nil end

    for _, c in pairs(_G.CompkillerConnections) do
        pcall(function() c:Disconnect() end)
    end
    _G.CompkillerConnections = {}

    if _G.CompkillerFovCircle then
        pcall(function() _G.CompkillerFovCircle:Remove() end)
        _G.CompkillerFovCircle = nil
    end

    if _G.CompkillerTargetGui then
        pcall(function() _G.CompkillerTargetGui:Destroy() end)
        _G.CompkillerTargetGui = nil
    end

    task.delay(0.1, function()
        if _G.CompkillerWindow then
            pcall(function() _G.CompkillerWindow:Destroy() end)
            _G.CompkillerWindow = nil
        end
    end)
end

-- COMBAT --
Window:DrawCategory({ Name = "COMBAT" });

local AimbotTab = Window:DrawTab({
    Name = "Aimbot", Icon = "crosshair", Type = "Double", EnableScrolling = true
});
local AimbotSection = AimbotTab:DrawSection({ Name = "Aimbot", Position = "left" });
local AimbotConfigSection = AimbotTab:DrawSection({ Name = "Aimbot Configurations", Position = "right" });

AimbotSection:AddToggle({
    Name = "Camlock", Flag = "Camlock_Toggle", Default = false,
    Callback = function(v)
        if v and CamlockVisibleCheck then
            local target = GetClosestPlayerInFov()
            if target then
                local char = target.Character
                local part = GetTargetPart(char)
                if part and not IsVisible(part) then
                    CamlockEnabled = false
                    return
                end
            end
        end
        CamlockEnabled = v
        if not v then
            CamlockTarget = nil
            HideTargetGui()
        end
    end,
});

AimbotSection:AddToggle({
    Name = "FOV Circle", Flag = "Camlock_Fov", Default = false,
    Callback = function(v) CamlockFovEnabled = v end,
});

AimbotSection:AddToggle({
    Name = "Visible Check", Flag = "Camlock_Visible", Default = false,
    Callback = function(v)
        CamlockVisibleCheck = v
        if v then
            CamlockTarget = nil
            CamlockEnabled = false
        end
    end,
});

AimbotSection:AddToggle({
    Name = "Distance Limit", Flag = "Camlock_DistToggle", Default = false,
    Callback = function(v)
        CamlockDistanceEnabled = v
        CamlockTarget = nil
    end,
});

AimbotSection:AddToggle({
    Name = "KO Check", Flag = "Camlock_KoCheck", Default = false,
    Callback = function(v)
        CamlockKoCheck = v
        if v and CamlockTarget and not IsAlive(CamlockTarget) then
            CamlockTarget = nil
        end
    end,
});

AimbotSection:AddToggle({
    Name = "Show Target", Flag = "AimAssist_ShowTarget", Default = false,
    Callback = function(v)
        ShowTarget = v
        if not v then HideTargetGui() end
    end,
});

AimbotConfigSection:AddDropdown({
    Name = "Target Part",
    Default = "HumanoidRootPart",
    Flag = "Camlock_BodyPart",
    Values = {
        "HumanoidRootPart",
        "Head",
        "UpperTorso",
        "LowerTorso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg",
    },
    Callback = function(v)
        CamlockBodyPart = v
        CamlockTarget = nil
    end,
});

AimbotConfigSection:AddSlider({
    Name = "Smooth", Min = 1, Max = 50, Default = 10, Round = 0, Flag = "Camlock_Smooth",
    Callback = function(v) CamlockSmooth = v end,
});

AimbotConfigSection:AddSlider({
    Name = "FOV Size", Min = 10, Max = 500, Default = 100, Round = 0, Flag = "Camlock_FovSize",
    Callback = function(v) CamlockFovSize = v end,
});

AimbotConfigSection:AddSlider({
    Name = "Max Distance", Min = 50, Max = 5000, Default = 500, Round = 0, Flag = "Camlock_MaxDist",
    Callback = function(v) CamlockMaxDistance = v end,
});

local SilentTab = Window:DrawTab({
    Name = "Silent", Icon = "ghost", Type = "Double", EnableScrolling = true
});
local SilentSection = SilentTab:DrawSection({ Name = "Silent", Position = "left" });
local SilentConfigSection = SilentTab:DrawSection({ Name = "Silent Configurations", Position = "right" });

local AimAssistTab = Window:DrawTab({
    Name = "Aim Assist", Icon = "target", Type = "Double", EnableScrolling = true
});
local AimAssistSection = AimAssistTab:DrawSection({ Name = "Aim Assist", Position = "left" });
local AimAssistConfigSection = AimAssistTab:DrawSection({ Name = "Aim Assist Configurations", Position = "right" });

SilentSection:AddParagraph({
    Name = "Silent Aim",
    Content = "Silent aim is not available.",
});

-- Aim Assist Variables --
local AimAssistEnabled = false
local AimAssistFovEnabled = false
local AimAssistKoCheck = false
local AimAssistDistanceEnabled = false
local AimAssistVisibleCheck = false
local AimAssistFovSize = 100
local AimAssistSmooth = 10
local AimAssistMaxDistance = 500
local AimAssistBodyPart = "HumanoidRootPart"

local AimAssistFovCircle = Drawing.new("Circle")
AimAssistFovCircle.Visible = false
AimAssistFovCircle.Thickness = 1
AimAssistFovCircle.Filled = false
AimAssistFovCircle.Color = Color3.fromRGB(255, 200, 0)

local function AimAssistGetTargetPart(char)
    if not char then return nil end
    local part = char:FindFirstChild(AimAssistBodyPart)
    if not part then part = char:FindFirstChild("HumanoidRootPart") end
    return part
end

local function AimAssistIsAlive(player)
    if not player then return false end
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if hum:GetState() == Enum.HumanoidStateType.Dead then return false end
    if hum.Health <= 0 then return false end
    return true
end

local function AimAssistIsVisible(targetPart)
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

local function AimAssistGetClosest()
    local closest = nil
    local closestDist = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if AimAssistKoCheck and not AimAssistIsAlive(player) then continue end

        local char = player.Character
        local part = AimAssistGetTargetPart(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not part or not hum or hum.Health <= 0 then continue end

        if AimAssistDistanceEnabled then
            local worldDist = (camera.CFrame.Position - part.Position).Magnitude
            if worldDist > AimAssistMaxDistance then continue end
        end

        if AimAssistVisibleCheck and not AimAssistIsVisible(part) then continue end

        local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if screenDist < AimAssistFovSize and screenDist < closestDist then
            closestDist = screenDist
            closest = player
        end
    end

    return closest
end

local aimAssistConn = RunService.Heartbeat:Connect(function()
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    AimAssistFovCircle.Visible = AimAssistFovEnabled
    AimAssistFovCircle.Position = screenCenter
    AimAssistFovCircle.Radius = AimAssistFovSize

    if not AimAssistEnabled then return end

    local target = AimAssistGetClosest()
    if not target then return end

    local char = target.Character
    local part = AimAssistGetTargetPart(char)
    if not part then return end

    local mode = getgenv().AimAssistMode or "Aiming"

    if mode == "Aiming" then
        local targetCFrame = CFrame.new(camera.CFrame.Position, part.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 1 / AimAssistSmooth)
    elseif mode == "Shooting" then
        -- so mira se o botao esquerdo do mouse estiver pressionado
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
        local targetCFrame = CFrame.new(camera.CFrame.Position, part.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 1 / AimAssistSmooth)
    end
end)
table.insert(_G.CompkillerConnections, aimAssistConn)

-- Toggles --
AimAssistSection:AddToggle({
    Name = "Aim Assist", Flag = "AimAssist_Enable", Default = false,
    Callback = function(v) AimAssistEnabled = v end,
});

AimAssistSection:AddToggle({
    Name = "FOV Circle", Flag = "AimAssist_Fov", Default = false,
    Callback = function(v) AimAssistFovEnabled = v end,
});

AimAssistSection:AddToggle({
    Name = "KO Check", Flag = "AimAssist_Ko", Default = false,
    Callback = function(v) AimAssistKoCheck = v end,
});

AimAssistSection:AddToggle({
    Name = "Distance Limit", Flag = "AimAssist_Dist", Default = false,
    Callback = function(v) AimAssistDistanceEnabled = v end,
});

AimAssistSection:AddToggle({
    Name = "Visible Check", Flag = "AimAssist_Visible", Default = false,
    Callback = function(v) AimAssistVisibleCheck = v end,
});

AimAssistConfigSection:AddDropdown({
    Name = "Aim Assist Mode",
    Default = "Aiming",
    Flag = "AimAssist_Mode",
    Values = {"Aiming", "Shooting"},
    Callback = function(v)
        getgenv().AimAssistMode = v
    end,
});

-- Configs --
AimAssistConfigSection:AddDropdown({
    Name = "Target Part",
    Default = "HumanoidRootPart",
    Flag = "AimAssist_BodyPart",
    Values = {
        "HumanoidRootPart",
        "Head",
        "UpperTorso",
        "LowerTorso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg",
    },
    Callback = function(v) AimAssistBodyPart = v end,
});

AimAssistConfigSection:AddSlider({
    Name = "Smooth", Min = 1, Max = 50, Default = 10, Round = 0, Flag = "AimAssist_Smooth",
    Callback = function(v) AimAssistSmooth = v end,
});

AimAssistConfigSection:AddSlider({
    Name = "FOV Size", Min = 10, Max = 500, Default = 100, Round = 0, Flag = "AimAssist_FovSize",
    Callback = function(v) AimAssistFovSize = v end,
});

AimAssistConfigSection:AddSlider({
    Name = "Max Distance", Min = 50, Max = 5000, Default = 500, Round = 0, Flag = "AimAssist_MaxDist",
    Callback = function(v) AimAssistMaxDistance = v end,
});

local TriggerbotTab = Window:DrawTab({
    Name = "Triggerbot", Icon = "target", Type = "Double", EnableScrolling = true
});
local TriggerbotSection = TriggerbotTab:DrawSection({ Name = "Triggerbot", Position = "left" });
local TriggerbotConfigSection = TriggerbotTab:DrawSection({ Name = "Triggerbot Configurations", Position = "right" });

-- Hitbox Variables --
local HitboxEnabled = false
local HitboxVisualizer = false
local HitboxSize = 10
local HitboxColor = Color3.fromRGB(255, 0, 0)
local HitboxTransparency = 0.5
local HitboxData = {}

local function RemoveHitbox(player)
    local data = HitboxData[player]
    if not data then return end
    if data.part then pcall(function() data.part:Destroy() end) end
    HitboxData[player] = nil
end

local function CreateHitbox(player)
    if player == LocalPlayer then return end
    RemoveHitbox(player)

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local data = {}

    local part = Instance.new("Part")
    part.Name = "HitboxExpander"
    part.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
    part.Anchored = false
    part.CanCollide = false
    part.Massless = true
    part.Transparency = HitboxVisualizer and HitboxTransparency or 1
    part.Color = HitboxColor
    part.Material = Enum.Material.ForceField
    part.CastShadow = false

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = part
    weld.Parent = part

    part.CFrame = root.CFrame
    part.Parent = root

    local selBox = Instance.new("SelectionBox")
    selBox.Adornee = part
    selBox.Color3 = HitboxColor
    selBox.LineThickness = 0.03
    selBox.SurfaceTransparency = 1
    selBox.Visible = HitboxVisualizer
    selBox.Parent = part

    data.part = part
    data.selBox = selBox
    HitboxData[player] = data
end

local function RefreshAllHitboxes()
    for player, data in pairs(HitboxData) do
        if data.part then
            data.part.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
            data.part.Transparency = HitboxVisualizer and HitboxTransparency or 1
            data.part.Color = HitboxColor
        end
        if data.selBox then
            data.selBox.Color3 = HitboxColor
            data.selBox.Visible = HitboxVisualizer
        end
    end
end

local function SetupHitboxPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then
        if HitboxEnabled then CreateHitbox(player) end
    end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if HitboxEnabled then CreateHitbox(player) end
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

-- Triggerbot Variables --
local TriggerbotEnabled = false
local TriggerbotDelay = 0.1
local TriggerbotFovSize = 10
local TriggerbotVisibleCheck = false
local TriggerbotKoCheck = false
local TriggerbotFireJump = false
local TriggerbotFiring = false

local function TriggerbotFire()
    if TriggerbotFiring then return end
    TriggerbotFiring = true
    task.delay(TriggerbotDelay, function()
        if not TriggerbotEnabled then
            TriggerbotFiring = false
            return
        end
        mouse1press()
        task.wait(0.05)
        mouse1release()
        TriggerbotFiring = false
    end)
end

local function TriggerbotIsVisible(targetPart)
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

local triggerbotConn = RunService.Heartbeat:Connect(function()
    if not TriggerbotEnabled then return end

    -- so funciona se camlock ou aim assist estiver ativo
    if not CamlockEnabled and not AimAssistEnabled then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if TriggerbotFireJump then
    -- so atira quando o ALVO estiver pulando, nao eu
    local pChar = target and target.Character
    local pHum = pChar and pChar:FindFirstChildOfClass("Humanoid")
    if not pHum then return end
    if pHum.FloorMaterial ~= Enum.Material.Air then return end
end

    -- se camlock ativo usa o target do camlock
    -- se aim assist ativo usa o target do aim assist
    local target = CamlockEnabled and CamlockTarget or AimAssistGetClosest()
    if not target then return end

    local pChar = target.Character
    local pHum = pChar and pChar:FindFirstChildOfClass("Humanoid")
    local root = pChar and pChar:FindFirstChild("HumanoidRootPart")
    if not pChar or not pHum or not root then return end

    if TriggerbotKoCheck and pHum.Health <= 0 then return end

    local checkPart = root
    if HitboxEnabled then
        local hitboxPart = root:FindFirstChild("HitboxExpander")
        if hitboxPart then checkPart = hitboxPart end
    end

    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local screenPos, onScreen = camera:WorldToViewportPoint(checkPart.Position)
    if not onScreen then return end

    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
    if screenDist > TriggerbotFovSize then return end

    if TriggerbotVisibleCheck and not TriggerbotIsVisible(checkPart) then return end

    TriggerbotFire()
end)

-- Toggles --
TriggerbotSection:AddToggle({
    Name = "Triggerbot", Flag = "Triggerbot_Toggle", Default = false,
    Callback = function(v) TriggerbotEnabled = v end,
});

TriggerbotSection:AddToggle({
    Name = "Fire Jump", Flag = "Triggerbot_FireJump", Default = false,
    Callback = function(v) TriggerbotFireJump = v end,
});

TriggerbotSection:AddToggle({
    Name = "Visible Check", Flag = "Triggerbot_VisibleCheck", Default = false,
    Callback = function(v) TriggerbotVisibleCheck = v end,
});

TriggerbotSection:AddToggle({
    Name = "KO Check", Flag = "Triggerbot_KoCheck", Default = false,
    Callback = function(v) TriggerbotKoCheck = v end,
});

TriggerbotSection:AddToggle({
    Name = "Hitbox Expander", Flag = "Triggerbot_Hitbox", Default = false,
    Callback = function(v)
        HitboxEnabled = v
        if v then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then CreateHitbox(player) end
            end
        else
            for player, _ in pairs(HitboxData) do
                RemoveHitbox(player)
            end
        end
    end,
});

TriggerbotSection:AddToggle({
    Name = "Hitbox Visualizer", Flag = "Triggerbot_HitboxVisualizer", Default = false,
    Callback = function(v)
        HitboxVisualizer = v
        RefreshAllHitboxes()
    end,
});

-- Configs --
TriggerbotConfigSection:AddSlider({
    Name = "Trigger Delay", Min = 0, Max = 10, Default = 1, Round = 0, Flag = "Triggerbot_Delay",
    Callback = function(v)
        TriggerbotDelay = v / 10
    end,
});

TriggerbotConfigSection:AddSlider({
    Name = "FOV Size", Min = 1, Max = 100, Default = 10, Round = 0, Flag = "Triggerbot_Fov",
    Callback = function(v)
        TriggerbotFovSize = v
    end,
});

TriggerbotConfigSection:AddColorPicker({
    Name = "Hitbox Color", Default = Color3.fromRGB(255, 0, 0), Flag = "Triggerbot_HitboxColor",
    Callback = function(v)
        HitboxColor = v
        RefreshAllHitboxes()
    end,
});

TriggerbotConfigSection:AddSlider({
    Name = "Hitbox Size", Min = 1, Max = 50, Default = 10, Round = 0, Flag = "Triggerbot_HitboxSize",
    Callback = function(v)
        HitboxSize = v
        RefreshAllHitboxes()
    end,
});

TriggerbotConfigSection:AddSlider({
    Name = "Hitbox Transparency", Min = 0, Max = 10, Default = 5, Round = 0, Flag = "Triggerbot_HitboxTransparency",
    Callback = function(v)
        HitboxTransparency = v / 10
        RefreshAllHitboxes()
    end,
});

local RagebotTarget = nil
local RagebotPlayerNames = {}

local RagebotTab = Window:DrawTab({
    Name = "Ragebot", Icon = "flame", Type = "Double", EnableScrolling = true
});
local RagebotSection1 = RagebotTab:DrawSection({ Name = "Ragebot", Position = "left" });
local RagebotSection2 = RagebotTab:DrawSection({ Name = "Players", Position = "right" });
local RagebotSection3 = RagebotTab:DrawSection({ Name = "Target", Position = "left" });
local RagebotSection4 = RagebotTab:DrawSection({ Name = "Target Configurations", Position = "right" });

-- Toggles --
RagebotSection1:AddToggle({
    Name = "Auto Fire", Flag = "Ragebot_AutoFire", Default = false,
    Callback = function(v)
        if v then
            if not getgenv().StartAutoFire then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/santos007xs/script/refs/heads/main/autofire.lua"))()
            end
            getgenv().StartAutoFire(RagebotTarget)
        else
            if getgenv().StopAutoFire then
                getgenv().StopAutoFire()
            end
        end
    end,
});

local RagebotStrafeEnabled = false
local RagebotStrafeRadius = 5
local RagebotStrafeSpeed = 1
local RagebotStrafeAngle = 0

local strafeConn = RunService.Heartbeat:Connect(function(dt)
    if not RagebotStrafeEnabled or not RagebotTarget then return end

    local char = RagebotTarget.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    if not char or not hum or not root or not myRoot then return end
    if hum.Health <= 0 then return end

    RagebotStrafeAngle = RagebotStrafeAngle + (RagebotStrafeSpeed * dt)

    local targetPos = root.Position
    local offsetX = math.cos(RagebotStrafeAngle) * RagebotStrafeRadius
    local offsetZ = math.sin(RagebotStrafeAngle) * RagebotStrafeRadius
    
    local positionOffset = 0
local pos = getgenv().RagebotStrafePosition or "Normal"
if pos == "Above" then
    positionOffset = getgenv().RagebotStrafeOffsetValue or 5
elseif pos == "Below" then
    positionOffset = -(getgenv().RagebotStrafeOffsetValue or 3)
end

    local newPos = Vector3.new(
       targetPos.X + offsetX,
       targetPos.Y + positionOffset,
       targetPos.Z + offsetZ
    )

    local dist = (myRoot.Position - newPos).Magnitude

    if dist > 1 then
        -- se longe teleporta direto
        myRoot.CFrame = CFrame.new(newPos, targetPos)
    else
        -- se perto usa velocidade pra girar suave
        myRoot.CFrame = CFrame.new(newPos, targetPos)
        myRoot.AssemblyLinearVelocity = Vector3.zero
    end
end)
table.insert(_G.CompkillerConnections, strafeConn)

RagebotSection1:AddToggle({
    Name = "Target Strafe", Flag = "Ragebot_Strafe", Default = false,
    Callback = function(v)
        RagebotStrafeEnabled = v
        RagebotStrafeAngle = 0
    end,
});

RagebotSection4:AddDropdown({
    Name = "Strafe Position",
    Default = "Normal",
    Flag = "Ragebot_StrafePosition",
    Values = {
        "Normal",
        "Above",
        "Below",
    },
    Callback = function(v)
        getgenv().RagebotStrafePosition = v
    end,
});

RagebotSection4:AddSlider({
    Name = "Position Offset", Min = 1, Max = 20, Default = 5, Round = 0, Flag = "Ragebot_PosOffset",
    Callback = function(v)
        getgenv().RagebotStrafeOffsetValue = v
    end,
});

RagebotSection1:AddToggle({
    Name = "No Clip", Flag = "Ragebot_NoClip", Default = false,
    Callback = function(v)
        RagebotNoClipEnabled = v
        ApplyNoClip(v)
    end,
});

local RagebotNoClipEnabled = false
local RagebotNoClipConn = nil

local function ApplyNoClip(enabled)
    if RagebotNoClipConn then
        RagebotNoClipConn:Disconnect()
        RagebotNoClipConn = nil
    end

    if not enabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        return
    end

    RagebotNoClipConn = RunService.Heartbeat:Connect(function()
        -- so funciona se strafe estiver ativo
        if not RagebotStrafeEnabled then return end

        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    table.insert(_G.CompkillerConnections, RagebotNoClipConn)
end

RagebotSection4:AddSlider({
    Name = "Strafe Speed", Min = 1, Max = 20, Default = 5, Round = 0, Flag = "Ragebot_StrafeSpeed",
    Callback = function(v)
        RagebotStrafeSpeed = v
    end,
});

RagebotSection4:AddSlider({
    Name = "Strafe Radius", Min = 2, Max = 30, Default = 5, Round = 0, Flag = "Ragebot_StrafeRadius",
    Callback = function(v)
        RagebotStrafeRadius = v
    end,
});

RagebotSection1:AddToggle({
    Name = "Show Target", Flag = "Ragebot_ShowTarget", Default = false,
    Callback = function(v)
        RagebotShowTarget = v
        if not v then
            RagebotTargetFrame.Visible = false
            lastRagebotAvatarId = nil
        end
    end,
});

local RagebotTargetGui = Instance.new("ScreenGui")
RagebotTargetGui.Name = "RagebotTargetGui"
RagebotTargetGui.ResetOnSpawn = false
RagebotTargetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
RagebotTargetGui.Parent = game:GetService("CoreGui")

-- Frame principal --
local RagebotTargetFrame = Instance.new("Frame")
RagebotTargetFrame.Size = UDim2.new(0, 220, 0, 100)
RagebotTargetFrame.Position = UDim2.new(0, 20, 0.5, -50)
RagebotTargetFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
RagebotTargetFrame.BackgroundTransparency = 0.1
RagebotTargetFrame.BorderSizePixel = 0
RagebotTargetFrame.Visible = false
RagebotTargetFrame.Parent = RagebotTargetGui

Instance.new("UICorner", RagebotTargetFrame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 50, 200)
stroke.Thickness = 2
stroke.Parent = RagebotTargetFrame

-- Header --
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 24)
Header.BackgroundColor3 = Color3.fromRGB(180, 50, 180)
Header.BorderSizePixel = 0
Header.Parent = RagebotTargetFrame

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size = UDim2.new(1, 0, 1, 0)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text = "RAGEBOT TARGET"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLabel.TextSize = 12
HeaderLabel.Font = Enum.Font.GothamBold
HeaderLabel.Parent = Header

-- Avatar --
local RagebotAvatar = Instance.new("ImageLabel")
RagebotAvatar.Size = UDim2.new(0, 60, 0, 60)
RagebotAvatar.Position = UDim2.new(0, 10, 0, 30)
RagebotAvatar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RagebotAvatar.BorderSizePixel = 0
RagebotAvatar.Image = ""
RagebotAvatar.Parent = RagebotTargetFrame

Instance.new("UICorner", RagebotAvatar).CornerRadius = UDim.new(0, 8)

local avatarStroke = Instance.new("UIStroke")
avatarStroke.Color = Color3.fromRGB(200, 50, 200)
avatarStroke.Thickness = 1.5
avatarStroke.Parent = RagebotAvatar

-- Nome --
local RagebotNameLabel = Instance.new("TextLabel")
RagebotNameLabel.Size = UDim2.new(0, 130, 0, 18)
RagebotNameLabel.Position = UDim2.new(0, 80, 0, 30)
RagebotNameLabel.BackgroundTransparency = 1
RagebotNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RagebotNameLabel.TextSize = 13
RagebotNameLabel.Font = Enum.Font.GothamBold
RagebotNameLabel.TextXAlignment = Enum.TextXAlignment.Left
RagebotNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
RagebotNameLabel.Text = ""
RagebotNameLabel.Parent = RagebotTargetFrame

-- Username --
local RagebotUserLabel = Instance.new("TextLabel")
RagebotUserLabel.Size = UDim2.new(0, 130, 0, 14)
RagebotUserLabel.Position = UDim2.new(0, 80, 0, 50)
RagebotUserLabel.BackgroundTransparency = 1
RagebotUserLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
RagebotUserLabel.TextSize = 11
RagebotUserLabel.Font = Enum.Font.Gotham
RagebotUserLabel.TextXAlignment = Enum.TextXAlignment.Left
RagebotUserLabel.TextTruncate = Enum.TextTruncate.AtEnd
RagebotUserLabel.Text = ""
RagebotUserLabel.Parent = RagebotTargetFrame

-- Health bar bg --
local RagebotHealthBg = Instance.new("Frame")
RagebotHealthBg.Size = UDim2.new(0, 130, 0, 10)
RagebotHealthBg.Position = UDim2.new(0, 80, 0, 72)
RagebotHealthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
RagebotHealthBg.BorderSizePixel = 0
RagebotHealthBg.Parent = RagebotTargetFrame

Instance.new("UICorner", RagebotHealthBg).CornerRadius = UDim.new(0, 4)

-- Health bar fill --
local RagebotHealthFill = Instance.new("Frame")
RagebotHealthFill.Size = UDim2.new(1, 0, 1, 0)
RagebotHealthFill.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
RagebotHealthFill.BorderSizePixel = 0
RagebotHealthFill.Parent = RagebotHealthBg

Instance.new("UICorner", RagebotHealthFill).CornerRadius = UDim.new(0, 4)

-- Health text --
local RagebotHealthText = Instance.new("TextLabel")
RagebotHealthText.Size = UDim2.new(0, 130, 0, 12)
RagebotHealthText.Position = UDim2.new(0, 80, 0, 84)
RagebotHealthText.BackgroundTransparency = 1
RagebotHealthText.TextColor3 = Color3.fromRGB(180, 180, 180)
RagebotHealthText.TextSize = 10
RagebotHealthText.Font = Enum.Font.Gotham
RagebotHealthText.TextXAlignment = Enum.TextXAlignment.Left
RagebotHealthText.Text = ""
RagebotHealthText.Parent = RagebotTargetFrame

local lastRagebotAvatarId = nil

local ragebotShowConn = RunService.Heartbeat:Connect(function()
    if not RagebotShowTarget or not RagebotTarget then
        RagebotTargetFrame.Visible = false
        return
    end

    local char = RagebotTarget.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum then
        RagebotTargetFrame.Visible = false
        return
    end

    RagebotTargetFrame.Visible = true
    RagebotNameLabel.Text = RagebotTarget.DisplayName
    RagebotUserLabel.Text = "@" .. RagebotTarget.Name

    local hp = hum.Health
    local maxHp = hum.MaxHealth
    local ratio = math.clamp(hp / maxHp, 0, 1)

    RagebotHealthFill.Size = UDim2.new(ratio, 0, 1, 0)
    RagebotHealthText.Text = string.format("HP: %d / %d", math.floor(hp), math.floor(maxHp))

    local r = math.floor(255 * (1 - ratio))
    local g = math.floor(255 * ratio)
    RagebotHealthFill.BackgroundColor3 = Color3.fromRGB(r, g, 0)

    if lastRagebotAvatarId ~= RagebotTarget.UserId then
        lastRagebotAvatarId = RagebotTarget.UserId
        pcall(function()
            local content = Players:GetUserThumbnailAsync(
                RagebotTarget.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
            RagebotAvatar.Image = content
        end)
    end
end)
table.insert(_G.CompkillerConnections, ragebotShowConn)

-- Player List --
local RagebotDropdown = nil

local function RefreshPlayerList()
    RagebotPlayerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        table.insert(RagebotPlayerNames, player.Name)
    end

    if RagebotDropdown then
        pcall(function()
            RagebotDropdown:SetValues(RagebotPlayerNames)
        end)
    end
end

RefreshPlayerList()

RagebotDropdown = RagebotSection2:AddDropdown({
    Name = "Select Target",
    Default = "",
    Flag = "Ragebot_Target",
    Values = RagebotPlayerNames,
    Callback = function(v)
        for _, player in pairs(Players:GetPlayers()) do
            if player.Name == v then
                RagebotTarget = player
                Notifier:Notify({
                    Title = "Ragebot",
                    Content = "Target: " .. player.Name,
                    Duration = 2,
                })
                break
            end
        end
    end,
});

RagebotSection2:AddButton({
    Name = "Refresh",
    Callback = function()
        RefreshPlayerList()
    end,
});

Players.PlayerAdded:Connect(function()
    task.wait(1)
    RefreshPlayerList()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    RefreshPlayerList()
end)

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)

local RagebotTraceEnabled = false
local RagebotTraceLine = Drawing.new("Line")
RagebotTraceLine.Visible = false
RagebotTraceLine.Thickness = 2
RagebotTraceLine.Color = Color3.fromRGB(255, 0, 0)
RagebotTraceLine.Transparency = 1

local traceConn = RunService.Heartbeat:Connect(function()
    if not RagebotTraceEnabled or not RagebotTarget then
        RagebotTraceLine.Visible = false
        return
    end

    local char = RagebotTarget.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        RagebotTraceLine.Visible = false
        return
    end

    -- usa WorldToScreenPoint em vez de WorldToViewportPoint
    local screenPos, onScreen = camera:WorldToScreenPoint(root.Position)
    if not onScreen then
        RagebotTraceLine.Visible = false
        return
    end

    local mousePos = UserInputService:GetMouseLocation()

    RagebotTraceLine.Visible = true
    RagebotTraceLine.From = Vector2.new(screenPos.X, screenPos.Y)
    RagebotTraceLine.To = mousePos
end)
table.insert(_G.CompkillerConnections, traceConn)

RagebotSection1:AddToggle({
    Name = "Target Trace", Flag = "Ragebot_TargetTrace", Default = false,
    Callback = function(v)
        RagebotTraceEnabled = v
        if not v then RagebotTraceLine.Visible = false end
    end,
});

RagebotSection4:AddColorPicker({
    Name = "Trace Color", Default = Color3.fromRGB(255, 0, 0), Flag = "Ragebot_TraceColor",
    Callback = function(v)
        RagebotTraceLine.Color = v
    end,
});

RagebotSection4:AddSlider({
    Name = "Trace Thickness", Min = 1, Max = 10, Default = 2, Round = 0, Flag = "Ragebot_TraceThickness",
    Callback = function(v)
        RagebotTraceLine.Thickness = v
    end,
});

local AutoStompEnabled = false
local AutoStompDone = false

RagebotSection3:AddToggle({
    Name = "Auto Stomp", Flag = "Ragebot_AutoStomp", Default = false,
    Callback = function(v)
        AutoStompEnabled = v
        AutoStompDone = false
        if not v then return end

        task.spawn(function()
            while AutoStompEnabled do
                task.wait(0.05)
                if not RagebotTarget then continue end

                local char = RagebotTarget.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")

                if not char or not hum or not root then continue end

                -- detecta KO
                local isKO = hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead

                if not isKO then
                    AutoStompDone = false
                    continue
                end

                if AutoStompDone then continue end

                -- para o strafe imediatamente
                RagebotStrafeEnabled = false

                -- espera o strafe parar de facto
                task.wait(0.3)

                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myRoot then continue end

                -- teleporta em cima
                myRoot.CFrame = CFrame.new(
                    root.Position + Vector3.new(0, 3, 0),
                    root.Position
                )

                task.wait(0.15)

                -- aperta E
                pcall(function() keypress(0x45) end)
                task.wait(0.2)
                pcall(function() keyrelease(0x45) end)

                AutoStompDone = true

                Notifier:Notify({ Title = "Ragebot", Content = "Stomped " .. RagebotTarget.Name, Duration = 2 })
            end
        end)
    end,
});


-- VISUALS --
Window:DrawCategory({ Name = "VISUALS" });

local EspTab = Window:DrawTab({
    Name = "ESP", Icon = "eye", Type = "Double", EnableScrolling = true
});
local EspSection = EspTab:DrawSection({ Name = "ESP", Position = "left" });
local EspConfigSection = EspTab:DrawSection({ Name = "ESP Configurations", Position = "right" });

EspSection:AddToggle({
    Name = "ESP Name", Flag = "Esp_Name", Default = false,
    Callback = function(v)
        if v then
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/santos007xs/script/refs/heads/main/espname.lua", true))()
            end)
        else
            for _, player in pairs(Players:GetPlayers()) do
                local char = player.Character
                if not char then continue end
                local head = char:FindFirstChild("Head")
                if not head then continue end
                local billboard = head:FindFirstChild("NameESP")
                if billboard then billboard:Destroy() end
            end
        end
    end,
});

EspConfigSection:AddColorPicker({
    Name = "ESP Name Color", Default = Color3.fromRGB(255, 255, 255), Flag = "Esp_NameColor",
    Callback = function(v)
        for _, player in pairs(Players:GetPlayers()) do
            local char = player.Character
            if not char then continue end
            local head = char:FindFirstChild("Head")
            if not head then continue end
            local billboard = head:FindFirstChild("NameESP")
            if not billboard then continue end
            local text = billboard:FindFirstChildOfClass("TextLabel")
            if text then
                text.TextColor3 = v
            end
        end
    end,
});

EspConfigSection:AddSlider({
    Name = "ESP Name Size", Min = 1, Max = 100, Default = 14, Round = 0, Flag = "Esp_NameSize",
    Callback = function(v)
        for _, player in pairs(Players:GetPlayers()) do
            local char = player.Character
            if not char then continue end
            local head = char:FindFirstChild("Head")
            if not head then continue end
            local billboard = head:FindFirstChild("NameESP")
            if not billboard then continue end
            local text = billboard:FindFirstChildOfClass("TextLabel")
            if text then
                text.TextSize = v
                text.TextScaled = false
            end
        end
    end,
});

local WorldTab = Window:DrawTab({
    Name = "World", Icon = "globe", Type = "Double", EnableScrolling = true
});
local WorldSection = WorldTab:DrawSection({ Name = "World", Position = "left" });
local WorldConfigSection = WorldTab:DrawSection({ Name = "World Configurations", Position = "right" });

-- World Variables --
local Lighting = game:GetService("Lighting")

WorldSection:AddToggle({
    Name = "Custom Sky Color", Flag = "World_SkyToggle", Default = false,
    Callback = function(v)
        if not v then
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
    end,
});

WorldSection:AddToggle({
    Name = "Fullbright", Flag = "World_Fullbright", Default = false,
    Callback = function(v)
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end,
});

WorldSection:AddToggle({
    Name = "No Fog", Flag = "World_NoFog", Default = false,
    Callback = function(v)
        if v then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
        else
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        end
    end,
});

WorldSection:AddToggle({
    Name = "Custom Time", Flag = "World_TimeToggle", Default = false,
    Callback = function(v)
        if not v then
            Lighting.ClockTime = 14
        end
    end,
});

-- Configs --
WorldConfigSection:AddColorPicker({
    Name = "Sky Color", Default = Color3.fromRGB(128, 128, 128), Flag = "World_SkyColor",
    Callback = function(v)
        Lighting.OutdoorAmbient = v
        Lighting.Ambient = v
    end,
});

WorldConfigSection:AddColorPicker({
    Name = "Fog Color", Default = Color3.fromRGB(192, 192, 192), Flag = "World_FogColor",
    Callback = function(v)
        Lighting.FogColor = v
    end,
});

WorldConfigSection:AddColorPicker({
    Name = "Ambient Color", Default = Color3.fromRGB(0, 0, 0), Flag = "World_AmbientColor",
    Callback = function(v)
        Lighting.Ambient = v
    end,
});

WorldConfigSection:AddSlider({
    Name = "Brightness", Min = 0, Max = 10, Default = 1, Round = 0, Flag = "World_Brightness",
    Callback = function(v)
        Lighting.Brightness = v
    end,
});

WorldConfigSection:AddSlider({
    Name = "Time of Day", Min = 0, Max = 24, Default = 14, Round = 0, Flag = "World_Time",
    Callback = function(v)
        Lighting.ClockTime = v
    end,
});

WorldSection:AddToggle({
    Name = "Fog", Flag = "World_Fog", Default = false,
    Callback = function(v)
        if v then
            Lighting.FogEnd = 100
            Lighting.FogStart = 0
        else
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        end
    end,
});

WorldConfigSection:AddSlider({
    Name = "Fog Distance", Min = 1, Max = 1000, Default = 100, Round = 0, Flag = "World_FogDist",
    Callback = function(v)
        Lighting.FogEnd = v
    end,
});

WorldConfigSection:AddColorPicker({
    Name = "Fog Color", Default = Color3.fromRGB(192, 192, 192), Flag = "World_FogColor",
    Callback = function(v)
        Lighting.FogColor = v
    end,
});

local ChamsContainerTab = Window:DrawContainerTab({
    Name = "Chams", Icon = "box",
});

local ChamsTab = ChamsContainerTab:DrawTab({
    Name = "Chams", Type = "Double", EnableScrolling = true
});
local ChamsSection = ChamsTab:DrawSection({ Name = "Chams", Position = "left" });
local ChamsConfigSection = ChamsTab:DrawSection({ Name = "Chams Configurations", Position = "right" });

local GhostTab = ChamsContainerTab:DrawTab({
    Name = "Ghost", Type = "Double", EnableScrolling = true
});
local GhostSection = GhostTab:DrawSection({ Name = "Ghost", Position = "left" });
local GhostConfigSection = GhostTab:DrawSection({ Name = "Ghost Configurations", Position = "right" });

-- Chams Variables --
local ChamsEnabled = false
local ChamsTeamCheck = false
local ChamsWallCheck = false
local ChamsColor = Color3.fromRGB(255, 0, 0)
local ChamsTransparency = 0.5
local ChamsOutlineColor = Color3.fromRGB(255, 255, 255)
local ChamsData = {}

local function RemoveChamsForPlayer(player)
    local data = ChamsData[player]
    if not data then return end
    if data.highlight then pcall(function() data.highlight:Destroy() end) end
    ChamsData[player] = nil
end

local function CreateChamsForPlayer(player)
    if player == LocalPlayer then return end
    RemoveChamsForPlayer(player)

    local char = player.Character
    if not char then return end

    local data = {}

    local hl = Instance.new("Highlight")
    hl.FillColor = ChamsColor
    hl.FillTransparency = ChamsTransparency
    hl.OutlineColor = ChamsOutlineColor
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = ChamsEnabled
    hl.Parent = char
    data.highlight = hl

    ChamsData[player] = data
end

local function RefreshAllChams()
    for player, data in pairs(ChamsData) do
        if data.highlight then
            if ChamsTeamCheck and player.Team == LocalPlayer.Team then
                data.highlight.Enabled = false
            else
                data.highlight.Enabled = ChamsEnabled
            end
            data.highlight.FillColor = ChamsColor
            data.highlight.FillTransparency = ChamsTransparency
            data.highlight.OutlineColor = ChamsOutlineColor
            if ChamsWallCheck then
                data.highlight.DepthMode = Enum.HighlightDepthMode.Occluded
            else
                data.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
        end
    end
end

local function SetupChamsPlayer(player)
    if player == LocalPlayer then return end
    CreateChamsForPlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        CreateChamsForPlayer(player)
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    SetupChamsPlayer(player)
end

Players.PlayerAdded:Connect(SetupChamsPlayer)
Players.PlayerRemoving:Connect(RemoveChamsForPlayer)

ChamsSection:AddToggle({
    Name = "Chams", Flag = "Chams_Toggle", Default = false,
    Callback = function(v)
        ChamsEnabled = v
        RefreshAllChams()
    end,
});

ChamsSection:AddToggle({
    Name = "Team Check", Flag = "Chams_TeamCheck", Default = false,
    Callback = function(v)
        ChamsTeamCheck = v
        RefreshAllChams()
    end,
});

ChamsSection:AddToggle({
    Name = "Wall Check", Flag = "Chams_WallCheck", Default = false,
    Callback = function(v)
        ChamsWallCheck = v
        RefreshAllChams()
    end,
});

ChamsConfigSection:AddColorPicker({
    Name = "Fill Color", Default = Color3.fromRGB(255, 0, 0), Flag = "Chams_FillColor",
    Callback = function(v)
        ChamsColor = v
        RefreshAllChams()
    end,
});

ChamsConfigSection:AddColorPicker({
    Name = "Outline Color", Default = Color3.fromRGB(255, 255, 255), Flag = "Chams_OutlineColor",
    Callback = function(v)
        ChamsOutlineColor = v
        RefreshAllChams()
    end,
});

ChamsConfigSection:AddSlider({
    Name = "Fill Transparency", Min = 0, Max = 10, Default = 5, Round = 0, Flag = "Chams_Transparency",
    Callback = function(v)
        ChamsTransparency = v / 10
        RefreshAllChams()
    end,
});

ChamsConfigSection:AddSlider({
    Name = "Outline Transparency", Min = 0, Max = 10, Default = 0, Round = 0, Flag = "Chams_OutlineTransparency",
    Callback = function(v)
        for player, data in pairs(ChamsData) do
            if data.highlight then
                data.highlight.OutlineTransparency = v / 10
            end
        end
    end,
});

ChamsSection:AddToggle({
    Name = "Outline", Flag = "Chams_Outline", Default = false,
    Callback = function(v)
        for player, data in pairs(ChamsData) do
            if data.highlight then
                data.highlight.OutlineTransparency = v and 0 or 1
            end
        end
    end,
});

-- Ghost Variables --
local GhostEnabled = false
local GhostTransparency = 0.5
local GhostOutlineEnabled = false
local GhostData = {}

local function RemoveGhostForPlayer(player)
    local data = GhostData[player]
    if not data then return end
    if data.highlight then pcall(function() data.highlight:Destroy() end) end
    GhostData[player] = nil
end

local function CreateGhostForPlayer(player)
    if player == LocalPlayer then return end
    RemoveGhostForPlayer(player)

    local char = player.Character
    if not char then return end

    local data = {}

    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = GhostTransparency
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = GhostOutlineEnabled and 0 or 1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = GhostEnabled
    hl.Parent = char
    data.highlight = hl

    GhostData[player] = data
end

local function RefreshAllGhost()
    for player, data in pairs(GhostData) do
        if data.highlight then
            data.highlight.Enabled = GhostEnabled
            data.highlight.FillTransparency = GhostTransparency
            data.highlight.OutlineTransparency = GhostOutlineEnabled and 0 or 1
        end
    end
end

local function SetupGhostPlayer(player)
    if player == LocalPlayer then return end

    -- se ja tem personagem cria agora
    if player.Character then
        CreateGhostForPlayer(player)
    end

    -- quando spawnar novo personagem
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if GhostEnabled then
            CreateGhostForPlayer(player)
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    SetupGhostPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    -- espera o personagem carregar
    player.CharacterAdded:Wait()
    task.wait(0.5)
    SetupGhostPlayer(player)
end)

Players.PlayerRemoving:Connect(RemoveGhostForPlayer)

GhostSection:AddToggle({
    Name = "Outline", Flag = "Ghost_Outline", Default = false,
    Callback = function(v)
        GhostOutlineEnabled = v
        RefreshAllGhost()
    end,
});

GhostConfigSection:AddColorPicker({
    Name = "Ghost Color", Default = Color3.fromRGB(255, 255, 255), Flag = "Ghost_Color",
    Callback = function(v)
        for player, data in pairs(GhostData) do
            if data.highlight then
                data.highlight.FillColor = v
            end
        end
    end,
});

GhostConfigSection:AddSlider({
    Name = "Ghost Transparency", Min = 0, Max = 10, Default = 5, Round = 0, Flag = "Ghost_Transparency",
    Callback = function(v)
        GhostTransparency = v / 10
        RefreshAllGhost()
    end,
});



local HudTab = Window:DrawTab({
    Name = "Hud", Icon = "monitor", Type = "Double", EnableScrolling = true
});
local HudSection = HudTab:DrawSection({ Name = "Hud", Position = "left" });
local HudConfigSection = HudTab:DrawSection({ Name = "Hud Configurations", Position = "right" });

-- Hud Variables --
local AspectRatioEnabled = false
local AspectRatioConnection = nil
local AspectRatioResolution = 1.0

HudSection:AddToggle({
    Name = "Aspect Ratio", Flag = "Hud_AspectRatio", Default = false,
    Callback = function(v)
        AspectRatioEnabled = v
        if AspectRatioConnection then
            AspectRatioConnection:Disconnect()
            AspectRatioConnection = nil
        end
        if v then
            AspectRatioConnection = game:GetService("RunService").RenderStepped:Connect(function()
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, AspectRatioResolution, 0, 0, 0, 1)
            end)
        end
    end,
});

-- salva o fov ANTES de qualquer coisa
local DefaultFov = 70
pcall(function()
    DefaultFov = workspace.CurrentCamera.FieldOfView
end)

local CustomFovEnabled = false

HudSection:AddToggle({
    Name = "Custom FOV", Flag = "Hud_FovToggle", Default = false,
    Callback = function(v)
        CustomFovEnabled = v
        if not v then
            workspace.CurrentCamera.FieldOfView = DefaultFov
        end
    end,
});

-- Configs --
HudConfigSection:AddSlider({
    Name = "Aspect Ratio",
    Min = 50,
    Max = 130,
    Default = 100,
    Round = 0,
    Flag = "Hud_AspectRatioValue",
    Callback = function(v)
        AspectRatioResolution = v / 100
    end,
});

HudConfigSection:AddSlider({
    Name = "Player FOV",
    Min = 1,
    Max = 120,
    Default = 70,
    Round = 0,
    Flag = "Hud_FovValue",
    Callback = function(v)
        -- so aplica se o toggle estiver ligado
        if not CustomFovEnabled then return end
        workspace.CurrentCamera.FieldOfView = v
    end,
});

-- PLAYER --
Window:DrawCategory({ Name = "PLAYER" });

local WalkspeedTab = Window:DrawTab({
    Name = "Walkspeed", Icon = "plane", Type = "Double", EnableScrolling = true
});
local WalkspeedSection = WalkspeedTab:DrawSection({ Name = "Walkspeed", Position = "left" });
local WalkspeedConfigSection = WalkspeedTab:DrawSection({ Name = "Walkspeed Configurations", Position = "right" });

local WalkspeedToggle = WalkspeedSection:AddToggle({
    Name = "Walkspeed", Flag = "Walkspeed_Toggle", Default = false,
    Callback = function(v)
        WalkspeedEnabled = v
        ApplyWalkspeed(v)
    end,
});

WalkspeedConfigSection:AddSlider({
    Name = "Walkspeed", Min = 16, Max = 500, Default = 16, Round = 0, Flag = "Walkspeed_Value",
    Callback = function(v)
        getgenv().WalkSpeedValue = v
        if WalkspeedEnabled then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = v end
            end
        end
    end
});

local FlyTab = Window:DrawTab({
    Name = "Fly", Icon = "plane", Type = "Double", EnableScrolling = true
});
local FlySection = FlyTab:DrawSection({ Name = "Fly", Position = "left" });
local FlyConfigSection = FlyTab:DrawSection({ Name = "Fly Configurations", Position = "right" });

local FlyToggle = FlySection:AddToggle({
    Name = "Fly", Flag = "Fly_Toggle", Default = false,
    Callback = function(v)
        if v then StartFly() else StopFly() end
    end,
});

FlyConfigSection:AddSlider({
    Name = "Fly Speed", Min = 10, Max = 500, Default = 50, Round = 0, Flag = "Fly_Speed",
    Callback = function(v) FlySpeed = v end
});

local JumpTab = Window:DrawTab({
    Name = "Jump", Icon = "arrow-up", Type = "Double", EnableScrolling = true
});
local JumpSection = JumpTab:DrawSection({ Name = "Jump", Position = "left" });
local JumpConfigSection = JumpTab:DrawSection({ Name = "Jump Configurations", Position = "right" });

JumpSection:AddToggle({
    Name = "No Jump Cooldown", Flag = "Jump_NoCooldown", Default = false,
    Callback = function(v)
        NoCooldownEnabled = v
        ApplyJump()
    end,
});

JumpSection:AddToggle({
    Name = "Jump Force", Flag = "Jump_Force", Default = false,
    Callback = function(v)
        getgenv().JumpForceEnabled = v
        if not v then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end,
});

JumpConfigSection:AddSlider({
    Name = "Jump Force", Min = 50, Max = 500, Default = 50, Round = 0, Flag = "Jump_ForceValue",
    Callback = function(v)
        getgenv().JumpForceValue = v
    end,
});

local jumpForceConn = RunService.Heartbeat:Connect(function()
    if not getgenv().JumpForceEnabled then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.JumpPower ~= getgenv().JumpForceValue then
        hum.JumpPower = getgenv().JumpForceValue
    end
end)
table.insert(_G.CompkillerConnections, jumpForceConn)

JumpSection:AddToggle({
    Name = "Bunny Hop", Flag = "Jump_Bhop", Default = false,
    Callback = function(v)
        BhopEnabled = v
        ApplyJump()
    end,
});

JumpConfigSection:AddSlider({
    Name = "Bunny Hop Speed", Min = 10, Max = 20, Default = 12, Round = 0, Flag = "Jump_BhopSpeed",
    Callback = function(v)
        BhopSpeed = v / 10
    end,
});

-- MISC --
Window:DrawCategory({ Name = "MISC" });

local MiscTab = Window:DrawTab({
    Name = "Misc", Icon = "settings", Type = "Double", EnableScrolling = true
});
local MiscSection = MiscTab:DrawSection({ Name = "Misc", Position = "left" });
local MiscConfigSection = MiscTab:DrawSection({ Name = "Misc Configurations", Position = "right" });

local LuaTab = Window:DrawTab({
    Name = ".lua", Icon = "code", Type = "Single", EnableScrolling = true
});
local LuaSection = LuaTab:DrawSection({ Name = "Executor", Position = "left" });

LuaSection:AddToggle({
    Name = "Load Script", Flag = "Lua_LoadScript", Default = false,
    Callback = function(v)
        if v then
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/santos007xs/script/refs/heads/main/executor.lua", true))()
            end)
        end
    end,
});

-- PROFILE --
Window:DrawCategory({ Name = "PROFILE" });

local ConfigUI = Window:DrawConfig({
    Name = "Config", Icon = "folder", Config = ConfigManager
});

ConfigUI:Init();
