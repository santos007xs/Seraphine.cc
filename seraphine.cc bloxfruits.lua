-- =============================================
--  LINORIA UI - seraphine.cc #bloxfruits
-- =============================================

local repo = 'https://raw.githubusercontent.com/santos007xs/linoria/main/'

local Library      = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'ThemeManager.lua'))()
local SaveManager  = loadstring(game:HttpGet(repo .. 'SaveManager.lua'))()

-- =============================================
--  SERVICES
-- =============================================

local Players          = game:GetService('Players')
local RunService       = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local LocalPlayer      = Players.LocalPlayer
local camera           = workspace.CurrentCamera

-- =============================================
--  JANELA
-- =============================================

local Window = Library:CreateWindow({
    Title        = 'seraphine.cc  #bloxfruits',
    Center       = true,
    AutoShow     = true,
    TabPadding   = 8,
    MenuFadeTime = 0.2,
    UseCursor    = false,
})

local OldToggle = Library.Toggle
Library.Toggle = function(...)
    OldToggle(...)
    game:GetService('UserInputService').MouseIconEnabled = true
end

-- =============================================
--  ABAS
-- =============================================

local Tabs = {
    Aimbot          = Window:AddTab('Aimbot'),
    Misc            = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- =============================================
--  SILENT AIM
-- =============================================

local Aiming = loadstring(game:HttpGet('https://raw.githubusercontent.com/RapperDeluxe/scripts/main/silent%20aim%20module'))()
Aiming.TeamCheck(false)
Aiming.FOV        = 90
Aiming.ShowFOV    = false
Aiming.Enabled    = false
Aiming.HitChance  = 100
Aiming.TargetPart = { 'Head' }

function Aiming.Check()
    if not (Aiming.Enabled and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart ~= nil) then
        return false
    end
    local char = Aiming.Character(Aiming.Selected)
    if not char then return false end
    local BodyEffects = char:FindFirstChild('BodyEffects')
    if BodyEffects then
        local KO = BodyEffects:FindFirstChild('K.O')
        if KO and KO.Value then return false end
    end
    return true
end

local __index
__index = hookmetamethod(game, '__index', newcclosure(function(t, k)
    if t:IsA('Mouse') and (k == 'Hit' or k == 'Target') and Aiming.Check() then
        local part = Aiming.SelectedPart
        if k == 'Hit' then return part.CFrame
        else return part end
    end
    return __index(t, k)
end))

-- =============================================
--  ABA AIMBOT - SILENT AIM
-- =============================================

local SilentBox = Tabs.Aimbot:AddLeftGroupbox('Silent Aim')

SilentBox:AddToggle('SilentAimEnabled', {
    Text    = 'Silent Aim',
    Default = false,
    Tooltip = 'Ativa/desativa o silent aim',
    Callback = function(Value)
        Aiming.Enabled = Value
    end,
})

SilentBox:AddSlider('SilentAimFOV', {
    Text     = 'FOV',
    Default  = 90,
    Min      = 10,
    Max      = 500,
    Rounding = 0,
    Callback = function(Value)
        Aiming.FOV = Value
    end,
})

SilentBox:AddSlider('SilentHitChance', {
    Text     = 'Hit Chance',
    Default  = 100,
    Min      = 0,
    Max      = 100,
    Rounding = 0,
    Callback = function(Value)
        Aiming.HitChance = Value
    end,
})

SilentBox:AddDropdown('SilentTargetPart', {
    Text    = 'Target Part',
    Values  = { 'Head', 'Neck', 'Torso', 'UpperTorso', 'LowerTorso', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg' },
    Default = 1,
    Callback = function(Value)
        Aiming.TargetPart = { Value }
    end,
})

SilentBox:AddToggle('SilentTeamCheck', {
    Text    = 'Team Check',
    Default = false,
    Tooltip = 'Ignora jogadores do mesmo time',
    Callback = function(Value)
        Aiming.TeamCheck(Value)
    end,
})

local SilentAimFovVisible = false
local SilentAimFovGui     = Instance.new('ScreenGui')
SilentAimFovGui.Name         = 'SilentAimFov'
SilentAimFovGui.ResetOnSpawn = false
pcall(function() SilentAimFovGui.Parent = game:GetService('CoreGui') end)

local FovFrames = {}
local FovSegments = 64

for i = 1, FovSegments do
    local seg = Instance.new('Frame')
    seg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    seg.BorderSizePixel  = 0
    seg.Size             = UDim2.fromOffset(2, 2)
    seg.AnchorPoint      = Vector2.new(0.5, 0.5)
    seg.Visible          = false
    seg.Parent           = SilentAimFovGui
    table.insert(FovFrames, seg)
end

RunService.RenderStepped:Connect(function()
    if not SilentAimFovVisible then
        for _, seg in pairs(FovFrames) do seg.Visible = false end
        return
    end

    local mouse  = LocalPlayer:GetMouse()
    local cx     = mouse.X
    local cy     = mouse.Y
    local radius = Aiming.FOV or 90

    for i, seg in pairs(FovFrames) do
        local angle = (i / FovSegments) * math.pi * 2
        local x     = cx + math.cos(angle) * radius
        local y     = cy + math.sin(angle) * radius
        seg.Position = UDim2.fromOffset(x, y)
        seg.Visible  = true
    end
end)

SilentBox:AddToggle('SilentAimFovToggle', {
    Text    = 'FOV Circle',
    Default = false,
    Callback = function(Value)
        SilentAimFovVisible = Value
    end,
})

-- =============================================
--  TRIGGERBOT
-- =============================================

local TriggerbotBox = Tabs.Aimbot:AddRightGroupbox('Triggerbot')

local TriggerbotEnabled  = false
local TriggerbotDelay    = 0.1

RunService.Heartbeat:Connect(function()
    if TriggerbotEnabled then
        local char = LocalPlayer.Character
        if char then
            local mouse = LocalPlayer:GetMouse()
            local target = mouse.Target
            if target then
                local targetChar = target:FindFirstAncestorOfClass('Model')
                local targetPlayer = targetChar and Players:GetPlayerFromCharacter(targetChar)
                if targetPlayer and targetPlayer ~= LocalPlayer then
                    local hum = targetChar:FindFirstChildOfClass('Humanoid')
                    if hum and hum.Health > 0 then
                        task.wait(TriggerbotDelay)
                        mouse1click()
                    end
                end
            end
        end
    end
end)

TriggerbotBox:AddToggle('TriggerbotToggle', {
    Text    = 'Triggerbot',
    Default = false,
    Callback = function(Value)
        TriggerbotEnabled = Value
    end,
})

TriggerbotBox:AddSlider('TriggerbotDelay', {
    Text     = 'Delay (s)',
    Default  = 10,
    Min      = 0,
    Max      = 100,
    Rounding = 0,
    Callback = function(Value)
        TriggerbotDelay = Value / 100
    end,
})

-- =============================================
--  ABA MISC - WALKSPEED
-- =============================================

local WalkspeedBox = Tabs.Misc:AddLeftGroupbox('Walkspeed')

local WalkspeedFromKeybind = false
local WalkspeedEnabled    = false
local WalkspeedValue      = 16
local WalkspeedConnection = nil

local function ApplyWalkspeed(enabled)
    if WalkspeedConnection then
        WalkspeedConnection:Disconnect()
        WalkspeedConnection = nil
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass('Humanoid')
    if not hum then return end
    if enabled then
        hum.WalkSpeed = WalkspeedValue
        WalkspeedConnection = hum:GetPropertyChangedSignal('WalkSpeed'):Connect(function()
            if hum and WalkspeedEnabled then hum.WalkSpeed = WalkspeedValue end
        end)
    else
        hum.WalkSpeed = 16
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    if WalkspeedEnabled then ApplyWalkspeed(true) end
end)

WalkspeedBox:AddToggle('WalkspeedToggle', {
    Text    = 'Walkspeed',
    Default = false,
    Callback = function(Value)
        if not WalkspeedFromKeybind then
            WalkspeedEnabled = Value
            ApplyWalkspeed(Value)
        end
    end,
})

WalkspeedBox:AddSlider('WalkspeedValue', {
    Text     = 'Velocity',
    Default  = 16,
    Min      = 16,
    Max      = 1000,
    Rounding = 0,
    Callback = function(Value)
        WalkspeedValue = Value
        if WalkspeedEnabled then ApplyWalkspeed(true) end
    end,
})

WalkspeedBox:AddLabel('Toggle Walkspeed'):AddKeyPicker('WalkspeedKeybind', {
    Default = 'V',
    Mode    = 'Toggle',
    Text    = 'Walkspeed',
    NoUI    = false,
})

RunService.Heartbeat:Connect(function()
    if Options.WalkspeedKeybind then
        local state = Options.WalkspeedKeybind:GetState()
        if state ~= WalkspeedEnabled then
            WalkspeedFromKeybind = true
            WalkspeedEnabled = state
            ApplyWalkspeed(state)
            Toggles.WalkspeedToggle:SetValue(state)
            WalkspeedFromKeybind = false
        end
    end
end)

-- =============================================
--  FLY
-- =============================================

local FlyBox = Tabs.Misc:AddRightGroupbox('Fly')

local FlyFromKeybind = false
local FlyEnabled    = false
local FlySpeed      = 50
local FlyMode       = 'Normal'
local FlyConnection = nil
local BodyVelocity  = nil
local BodyGyro     = nil

local function StopFly()
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass('Humanoid')
        if hum then hum.PlatformStand = false end
    end
end

local function StartFly()
    StopFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild('HumanoidRootPart')
    local hum  = char:FindFirstChildOfClass('Humanoid')
    if not root or not hum then return end

    if FlyMode == 'CFrame' then
        hum.PlatformStand = true
        FlyConnection = RunService.Heartbeat:Connect(function()
            if not FlyEnabled then StopFly() return end
            local moveDir = Vector3.new(
                (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0),
                (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
            )
            local cf = camera.CFrame
            root.CFrame = root.CFrame:Lerp(
                CFrame.new(root.Position + (cf.RightVector * moveDir.X + Vector3.new(0,1,0) * moveDir.Y + cf.LookVector * -moveDir.Z) * FlySpeed * 0.1),
                0.3
            )
        end)
    else
        BodyVelocity = Instance.new('BodyVelocity')
        BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyVelocity.Velocity = Vector3.zero
        BodyVelocity.Parent   = root

        BodyGyro = Instance.new('BodyGyro')
        BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        BodyGyro.P         = 1e4
        BodyGyro.CFrame    = root.CFrame
        BodyGyro.Parent    = root

        hum.PlatformStand = true

        FlyConnection = RunService.Heartbeat:Connect(function()
            if not FlyEnabled then StopFly() return end
            local cf = camera.CFrame
            local moveDir = Vector3.new(
                (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0),
                (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
            )
            BodyVelocity.Velocity = (cf.RightVector * moveDir.X + Vector3.new(0,1,0) * moveDir.Y + cf.LookVector * -moveDir.Z) * FlySpeed
            BodyGyro.CFrame = cf
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    if FlyEnabled then StartFly() end
end)

FlyBox:AddToggle('FlyToggle', {
    Text    = 'Fly',
    Default = false,
    Callback = function(Value)
        if not FlyFromKeybind then
            FlyEnabled = Value
            if Value then StartFly() else StopFly() end
        end
    end,
})

FlyBox:AddSlider('FlySpeed', {
    Text     = 'Speed',
    Default  = 50,
    Min      = 5,
    Max      = 300,
    Rounding = 0,
    Callback = function(Value)
        FlySpeed = Value
    end,
})

FlyBox:AddDropdown('FlyMode', {
    Text    = 'Mode',
    Values  = { 'Normal', 'CFrame' },
    Default = 1,
    Callback = function(Value)
        FlyMode = Value
        if FlyEnabled then StartFly() end
    end,
})

FlyBox:AddLabel('Fly Keybind'):AddKeyPicker('FlyKeybind', {
    Default = 'F',
    Mode    = 'Toggle',
    Text    = 'Fly',
    NoUI    = false,
})

RunService.Heartbeat:Connect(function()
    if Options.FlyKeybind then
        local state = Options.FlyKeybind:GetState()
        if state ~= FlyEnabled then
            FlyFromKeybind = true
            FlyEnabled = state
            if state then StartFly() else StopFly() end
            Toggles.FlyToggle:SetValue(state)
            FlyFromKeybind = false
        end
    end
end)

-- =============================================
--  JUMP POWER
-- =============================================

local JumpBox = Tabs.Misc:AddLeftGroupbox('Jump Power')

local JumpEnabled    = false
local JumpPower      = 50
local JumpConnection = nil

local function ApplyJump(enabled)
    if JumpConnection then JumpConnection:Disconnect() JumpConnection = nil end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass('Humanoid')
    if not hum then return end
    if enabled then
        hum.JumpPower = JumpPower
        JumpConnection = hum:GetPropertyChangedSignal('JumpPower'):Connect(function()
            if hum then hum.JumpPower = JumpPower end
        end)
    else
        hum.JumpPower = 50
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    if JumpEnabled then ApplyJump(true) end
end)

JumpBox:AddToggle('JumpToggle', {
    Text    = 'Jump Power',
    Default = false,
    Callback = function(Value)
        JumpEnabled = Value
        ApplyJump(Value)
    end,
})

JumpBox:AddSlider('JumpPowerValue', {
    Text     = 'Force',
    Default  = 50,
    Min      = 50,
    Max      = 500,
    Rounding = 0,
    Callback = function(Value)
        JumpPower = Value
        if JumpEnabled then ApplyJump(true) end
    end,
})

-- =============================================
--  ABA UI SETTINGS
-- =============================================

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    NoUI    = true,
    Text    = 'Menu keybind',
})

Library.ToggleKeybind = Options.MenuKeybind

Library:SetWatermarkVisibility(true)

local FrameTimer   = tick()
local FrameCounter = 0
local FPS          = 60

local WatermarkConnection = RunService.RenderStepped:Connect(function()
    FrameCounter += 1
    if (tick() - FrameTimer) >= 1 then
        FPS          = FrameCounter
        FrameTimer   = tick()
        FrameCounter = 0
    end
    Library:SetWatermark(('seraphine.cc  #bloxfruits | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

MenuGroup:AddToggle('WatermarkToggle', {
    Text    = 'Watermark',
    Default = true,
    Callback = function(Value)
        Library:SetWatermarkVisibility(Value)
    end,
})

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    Aiming.Enabled = false
    Library.Unloaded = true
end)

-- =============================================
--  SAVE / THEME MANAGER
-- =============================================

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('seraphine')
SaveManager:SetFolder('seraphine/configs')

ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:BuildConfigSection(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()

warn('[seraphine.cc #bloxfruits] Carregado com sucesso!')
