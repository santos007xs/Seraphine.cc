-- =============================================
--  LINORIA UI - seraphine.cc
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
    Title        = 'seraphine.cc',
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
    Ragebot         = Window:AddTab('Ragebot'),
    Visual          = Window:AddTab('Visual'),
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
--  BYPASS ADONIS
-- =============================================

local Hooked = {}
local Detected, Kill
setthreadidentity(2)
for i, v in getgc(true) do
    if typeof(v) == 'table' then
        local DetectFunc = rawget(v, 'Detected')
        local KillFunc   = rawget(v, 'Kill')
        if typeof(DetectFunc) == 'function' and not Detected then
            Detected = DetectFunc
            local Old; Old = hookfunction(Detected, function() return true end)
            table.insert(Hooked, Detected)
        end
        if rawget(v, 'Variables') and rawget(v, 'Process') and typeof(KillFunc) == 'function' and not Kill then
            Kill = KillFunc
            local Old; Old = hookfunction(Kill, function() end)
            table.insert(Hooked, Kill)
        end
    end
end
local OldDebug; OldDebug = hookfunction(getrenv().debug.info, newcclosure(function(...)
    local LevelOrFunc = ...
    if Detected and LevelOrFunc == Detected then
        return coroutine.yield(coroutine.running())
    end
    return OldDebug(...)
end))
setthreadidentity(7)
warn('[Adonis Bypass]: Ativado!')

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
pcall(function() syn.protect_gui(SilentAimFovGui) SilentAimFovGui.Parent = game:GetService('CoreGui') end)

-- Circulo feito de frames
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
--  ABA AIMBOT - CAMLOCK
-- =============================================
local AimbotTabBox = Tabs.Aimbot:AddRightTabbox()
local Tab1 = AimbotTabBox:AddTab('Camlock')
local Tab2 = AimbotTabBox:AddTab('Triggerbot')
local CamlockBox = Tab1

local CamlockEnabled      = false
local CamlockFovEnabled   = false
local CamlockSmooth       = 10
local CamlockFovSize      = 100
local CamlockTarget       = nil
local CamlockBodyPart     = 'HumanoidRootPart'
local CamlockKoCheck      = false
local CamlockVisibleCheck = false

-- FOV Circle via ScreenGui (funciona no Velocity)
local CamlockFovGui = Instance.new('ScreenGui')
CamlockFovGui.Name         = 'CamlockFov'
CamlockFovGui.ResetOnSpawn = false
pcall(function() CamlockFovGui.Parent = game:GetService('CoreGui') end)
pcall(function() syn.protect_gui(CamlockFovGui) CamlockFovGui.Parent = game:GetService('CoreGui') end)

local CamlockFovFrames   = {}
local CamlockFovSegments = 256

for i = 1, CamlockFovSegments do
    local seg = Instance.new('Frame')
    seg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    seg.BorderSizePixel  = 0
    seg.Size             = UDim2.fromOffset(2, 2)
    seg.AnchorPoint      = Vector2.new(0.5, 0.5)
    seg.Visible          = false
    seg.Parent           = CamlockFovGui
    table.insert(CamlockFovFrames, seg)
end

RunService.RenderStepped:Connect(function()
    if not CamlockFovEnabled then
        for _, seg in pairs(CamlockFovFrames) do seg.Visible = false end
        return
    end

    local mouse  = LocalPlayer:GetMouse()
    local cx     = mouse.X
    local cy     = mouse.Y
    local radius = CamlockFovSize
    local needed = math.clamp(math.floor(2 * math.pi * radius / 4), 32, 256)

    for i, seg in pairs(CamlockFovFrames) do
        if i > needed then
            seg.Visible = false
            continue
        end
        local angle = (i / needed) * math.pi * 2
        local x     = cx + math.cos(angle) * radius
        local y     = cy + math.sin(angle) * radius
        seg.Position = UDim2.fromOffset(x, y)
        seg.Visible  = true
    end
end)

local function GetScreenCenter()
    return Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end

local function GetTargetPart(char)
    if not char then return nil end
    return char:FindFirstChild(CamlockBodyPart) or char:FindFirstChild('HumanoidRootPart')
end

local function IsAlive(player)
    if not player then return false end
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass('Humanoid')
    if not hum then return false end
    if hum:GetState() == Enum.HumanoidStateType.Dead then return false end
    return hum.Health > 0
end

local function IsVisible(part)
    if not part then return false end
    local rayOrigin    = camera.CFrame.Position
    local rayDirection = part.Position - rayOrigin
    local rayParams    = RaycastParams.new()
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
    if result then
        local hitChar   = result.Instance:FindFirstAncestorOfClass('Model')
        local hitPlayer = hitChar and Players:GetPlayerFromCharacter(hitChar)
        return hitPlayer ~= nil
    end
    return true
end

local function GetClosestPlayerInFov()
    if CamlockTarget then
        local char = CamlockTarget.Character
        local part = GetTargetPart(char)
        local hum  = char and char:FindFirstChildOfClass('Humanoid')
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

    local closest      = nil
    local closestDist  = math.huge
    local mouse        = LocalPlayer:GetMouse()
    local mousePos     = Vector2.new(mouse.X, mouse.Y)

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if CamlockKoCheck and not IsAlive(player) then continue end
        local char = player.Character
        local part = GetTargetPart(char)
        local hum  = char and char:FindFirstChildOfClass('Humanoid')
        if not part or not hum or hum.Health <= 0 then continue end
        local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if screenDist < CamlockFovSize and screenDist < closestDist then
            if CamlockVisibleCheck and not IsVisible(part) then continue end
            closestDist = screenDist
            closest     = player
        end
    end

    CamlockTarget = closest
    return closest
end

RunService.Heartbeat:Connect(function()
    -- Sincroniza keybind do Camlock
    if Options.CamlockKeybind then
        local state = Options.CamlockKeybind:GetState()
        if state ~= CamlockEnabled then
            CamlockEnabled = state
            Toggles.CamlockToggle:SetValue(state)
            if not state then CamlockTarget = nil end
        end
    end

    if not CamlockEnabled then CamlockTarget = nil return end
    if CamlockKoCheck and CamlockTarget and not IsAlive(CamlockTarget) then
        CamlockTarget = nil return
    end

    local target = GetClosestPlayerInFov()
    if not target then return end
    local part = GetTargetPart(target.Character)
    if not part then return end

    if CamlockVisibleCheck and not IsVisible(part) then
        CamlockTarget = nil return
    end

    camera.CFrame = camera.CFrame:Lerp(
        CFrame.new(camera.CFrame.Position, part.Position),
        1 / CamlockSmooth
    )
end)

CamlockBox:AddToggle('CamlockToggle', {
    Text    = 'Camlock',
    Default = false,
    Callback = function(Value)
        CamlockEnabled = Value
        if not Value then CamlockTarget = nil end
    end,
})

CamlockBox:AddToggle('CamlockFovCircle', {
    Text    = 'FOV Circle',
    Default = false,
    Callback = function(Value) CamlockFovEnabled = Value end,
})

CamlockBox:AddToggle('CamlockKoCheck', {
    Text    = 'KO Check',
    Default = false,
    Callback = function(Value)
        CamlockKoCheck = Value
        if Value and CamlockTarget and not IsAlive(CamlockTarget) then
            CamlockTarget = nil
        end
    end,
})

CamlockBox:AddToggle('CamlockVisibleCheck', {
    Text    = 'Visible Check',
    Default = false,
    Tooltip = 'Não trava em players atrás de paredes',
    Callback = function(Value)
        CamlockVisibleCheck = Value
    end,
})

CamlockBox:AddSlider('CamlockSmooth', {
    Text     = 'Smooth',
    Default  = 10,
    Min      = 1,
    Max      = 50,
    Rounding = 0,
    Callback = function(Value) CamlockSmooth = Value end,
})

CamlockBox:AddSlider('CamlockFovSize', {
    Text     = 'FOV Size',
    Default  = 100,
    Min      = 10,
    Max      = 500,
    Rounding = 0,
    Callback = function(Value) CamlockFovSize = Value end,
})

CamlockBox:AddDropdown('CamlockPart', {
    Text    = 'Target Part',
    Values  = { 'HumanoidRootPart', 'Head', 'UpperTorso', 'LowerTorso', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg' },
    Default = 1,
    Callback = function(Value)
        CamlockBodyPart = Value
        CamlockTarget   = nil
    end,
})

CamlockBox:AddLabel('Keybind'):AddKeyPicker('CamlockKeybind', {
    Default = 'None',
    Mode    = 'Toggle',
    Text    = 'Camlock',
    NoUI    = false,
    Callback = function(Value) end,
})

-- =============================================
--  TRIGGERBOT
-- =============================================

local TriggerbotEnabled  = false
local TriggerbotDelay    = 0.1
local TriggerbotBodyPart = 'HumanoidRootPart'

RunService.Heartbeat:Connect(function()
    -- Sincroniza todos os modos da keybind do Camlock
    if Options.CamlockKeybind then
        local state = Options.CamlockKeybind:GetState()
        if state ~= CamlockEnabled then
            CamlockEnabled = state
            Toggles.CamlockToggle:SetValue(state)
            if not state then CamlockTarget = nil end
        end
    end

    -- Triggerbot
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

Tab2:AddToggle('TriggerbotToggle', {
    Text    = 'Triggerbot',
    Default = false,
    Callback = function(Value)
        TriggerbotEnabled = Value
    end,
})

Tab2:AddSlider('TriggerbotDelay', {
    Text     = 'Delay (s)',
    Default  = 10,
    Min      = 0,
    Max      = 100,
    Rounding = 0,
    Callback = function(Value)
        TriggerbotDelay = Value / 100
    end,
})

Tab2:AddDropdown('TriggerbotPart', {
    Text    = 'Target Part',
    Values  = { 'HumanoidRootPart', 'Head', 'UpperTorso', 'LowerTorso' },
    Default = 1,
    Callback = function(Value)
        TriggerbotBodyPart = Value
    end,
})

Tab2:AddToggle('TriggerbotTeamCheck', {
    Text    = 'Team Check',
    Default = false,
    Tooltip = 'Ignora jogadores do mesmo time',
    Callback = function(Value) end,
})

-- =============================================
--  ABA AIMBOT - PLAYER
-- =============================================

local PlayerBox = Tabs.Aimbot:AddLeftGroupbox('Player')

local AutoStompEnabled = false

local function TryStomping()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild('HumanoidRootPart')
    if not root then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local targetChar = player.Character
        if not targetChar then continue end

        -- Checa se o player está KO
        local BodyEffects = targetChar:FindFirstChild('BodyEffects')
        if not BodyEffects then continue end
        local KO = BodyEffects:FindFirstChild('K.O')
        if not KO or not KO.Value then continue end

        local targetRoot = targetChar:FindFirstChild('HumanoidRootPart')
        if not targetRoot then continue end

        -- Checa se está perto o suficiente
        local dist = (root.Position - targetRoot.Position).Magnitude
        if dist <= 8 then
            -- Pressiona E
            local args = {
                [1] = 'stomp',
                [2] = targetChar
            }
            -- Tenta via VirtualInputManager (funciona na maioria dos executores)
            pcall(function()
                game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not AutoStompEnabled then return end
    TryStomping()
end)

PlayerBox:AddToggle('AutoStompToggle', {
    Text    = 'Auto Stomp Legit',
    Default = false,
    Callback = function(Value)
        AutoStompEnabled = Value
    end,
})

-- =============================================
--  ABA RAGEBOT
-- =============================================

local RagebotSettings = Tabs.Ragebot:AddLeftGroupbox('Settings')
local RagebotBox            = Tabs.Ragebot:AddRightGroupbox('Ragebot')
local RagebotTarget   = Tabs.Ragebot:AddRightGroupbox('Target')

-- RAGEBOT
local RagebotEnabled = false

RagebotBox:AddToggle('RagebotEnabled', {
    Text    = 'Enable Ragebot',
    Default = false,
    Callback = function(Value)
        RagebotEnabled = Value
    end,
}):AddKeyPicker('RagebotKeybind', {
    Default = 'None',
    Mode    = 'Hold',
    Text    = 'Ragebot',
    NoUI    = false,
    Callback = function(Value) end,
})

RunService.Heartbeat:Connect(function()
    if Options.RagebotKeybind then
        local state = Options.RagebotKeybind:GetState()
        if state and RagebotEnabled then
            local mouse = LocalPlayer:GetMouse()
            local target = mouse.Target
            if target then
                local targetChar = target:FindFirstAncestorOfClass('Model')
                local targetPlayer = targetChar and Players:GetPlayerFromCharacter(targetChar)
                if targetPlayer and targetPlayer ~= LocalPlayer then
                    local hum = targetChar:FindFirstChildOfClass('Humanoid')
                    if hum and hum.Health > 0 then
                        local part = targetChar:FindFirstChild(Aiming.TargetPart[1] or 'Head')
                            or targetChar:FindFirstChild('HumanoidRootPart')
                        if part then
                            Aiming.Selected     = targetPlayer
                            Aiming.SelectedPart = part
                            mouse1click()
                        end
                    end
                end
            end
        end
    end
end)

local AutoFireEnabled = false

RagebotBox:AddToggle('AutoFireToggle', {
    Text    = 'Auto Fire',
    Default = false,
    Tooltip = 'Atira automaticamente no target selecionado',
    Callback = function(Value)
        AutoFireEnabled = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if not AutoFireEnabled then return end
    if not Aiming.Selected or not Aiming.SelectedPart then return end

    local targetChar = Aiming.Selected.Character
    if not targetChar then return end
    local hum = targetChar:FindFirstChildOfClass('Humanoid')
    if not hum or hum.Health <= 0 then return end

    mouse1click()
end)

-- RAGE STOMP
local RageStompEnabled = false

local RageStompEnabled = false

RagebotSettings:AddToggle('RageStompToggle', {
    Text    = 'Rage Stomp',
    Default = false,
    Tooltip = 'Teleporta até o target selecionado em KO, stompa e volta',
    Callback = function(Value)
        RageStompEnabled = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if not RageStompEnabled then return end
    if not Aiming.Selected then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild('HumanoidRootPart')
    if not root then return end

    local targetChar = Aiming.Selected.Character
    if not targetChar then return end

    local BodyEffects = targetChar:FindFirstChild('BodyEffects')
    if not BodyEffects then return end
    local KO = BodyEffects:FindFirstChild('K.O')
    if not KO or not KO.Value then return end

    local targetRoot = targetChar:FindFirstChild('HumanoidRootPart')
    if not targetRoot then return end

    local originalCFrame = root.CFrame
    root.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
    task.wait(0.1)

    pcall(function()
        game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)

    task.wait(0.2)
    root.CFrame = originalCFrame
end)

local SpinBox = RagebotSettings

local SpinEnabled    = false
local SpinSpeed      = 10
local SpinConnection = nil

local function StartSpin()
    if SpinConnection then SpinConnection:Disconnect() SpinConnection = nil end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild('HumanoidRootPart')
    if not root then return end

    SpinConnection = RunService.Heartbeat:Connect(function()
        if not SpinEnabled then
            SpinConnection:Disconnect()
            SpinConnection = nil
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild('HumanoidRootPart')
        if not root then return end
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
    end)
end

local SpinFromKeybind = false

SpinBox:AddToggle('SpinToggle', {
    Text    = 'Spin Bot',
    Default = false,
    Callback = function(Value)
        if not SpinFromKeybind then
            SpinEnabled = Value
            if Value then StartSpin() else
                if SpinConnection then SpinConnection:Disconnect() SpinConnection = nil end
            end
        end
    end,
})

SpinBox:AddSlider('SpinSpeed', {
    Text     = 'Speed',
    Default  = 10,
    Min      = 1,
    Max      = 50,
    Rounding = 0,
    Callback = function(Value)
        SpinSpeed = Value
    end,
})

SpinBox:AddLabel('Spin Keybind'):AddKeyPicker('SpinKeybind', {
    Default = 'None',
    Mode    = 'Toggle',
    Text    = 'Spin Bot',
    NoUI    = false,
    Callback = function(Value) end,
})

RunService.Heartbeat:Connect(function()
    if Options.SpinKeybind then
        local state = Options.SpinKeybind:GetState()
        if state ~= SpinEnabled then
            SpinFromKeybind = true
            SpinEnabled = state
            Toggles.SpinToggle:SetValue(state)
            if state then StartSpin() else
                if SpinConnection then SpinConnection:Disconnect() SpinConnection = nil end
            end
            SpinFromKeybind = false
        end
    end
end)

local AutoReloadEnabled = false

RagebotSettings:AddToggle('AutoReloadToggle', {
    Text    = 'Auto Reload',
    Default = false,
    Tooltip = 'Recarrega automaticamente quando Ragebot está ativo',
    Callback = function(Value)
        AutoReloadEnabled = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if not AutoReloadEnabled then return end
    if not RagebotEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass('Humanoid')
    if not hum or hum.Health <= 0 then return end

    local tool = char:FindFirstChildOfClass('Tool')
    if not tool then return end

    pcall(function()
        game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.R, false, game)
        task.wait(0.1)
        game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.R, false, game)
    end)
    task.wait(0.5)
end)

local TargetInfoGui = Instance.new('ScreenGui')
TargetInfoGui.Name         = 'TargetInfo'
TargetInfoGui.ResetOnSpawn = false
pcall(function() TargetInfoGui.Parent = game:GetService('CoreGui') end)
pcall(function() syn.protect_gui(TargetInfoGui) TargetInfoGui.Parent = game:GetService('CoreGui') end)

-- Frame principal estilo Linoria
local TargetFrame = Instance.new('Frame')
TargetFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TargetFrame.BorderColor3     = Color3.fromRGB(50, 50, 50)
TargetFrame.Size             = UDim2.fromOffset(200, 90)
TargetFrame.Position         = UDim2.fromOffset(10, 10)
TargetFrame.Visible          = false
TargetFrame.Parent           = TargetInfoGui

-- Barra colorida no topo (estilo Linoria)
local TopBar = Instance.new('Frame')
TopBar.BackgroundColor3 = Color3.fromRGB(0, 85, 255)
TopBar.BorderSizePixel  = 0
TopBar.Size             = UDim2.new(1, 0, 0, 2)
TopBar.Parent           = TargetFrame

-- Foto do player (thumbnail)
local Avatar = Instance.new('ImageLabel')
Avatar.BackgroundTransparency = 1
Avatar.Size                   = UDim2.fromOffset(50, 50)
Avatar.Position               = UDim2.fromOffset(8, 10)
Avatar.Image                  = ''
Avatar.Parent                 = TargetFrame

local AvatarCorner = Instance.new('UICorner')
AvatarCorner.CornerRadius = UDim.new(0, 4)
AvatarCorner.Parent       = Avatar

-- Nome
local NameLabel = Instance.new('TextLabel')
NameLabel.BackgroundTransparency = 1
NameLabel.Size                   = UDim2.fromOffset(130, 16)
NameLabel.Position               = UDim2.fromOffset(65, 8)
NameLabel.Font                   = Enum.Font.GothamBold
NameLabel.TextSize               = 13
NameLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
NameLabel.TextXAlignment         = Enum.TextXAlignment.Left
NameLabel.TextStrokeTransparency = 0
NameLabel.Text                   = ''
NameLabel.Parent                 = TargetFrame

-- HP Label
local HPLabel = Instance.new('TextLabel')
HPLabel.BackgroundTransparency = 1
HPLabel.Size                   = UDim2.fromOffset(130, 14)
HPLabel.Position               = UDim2.fromOffset(65, 28)
HPLabel.Font                   = Enum.Font.Code
HPLabel.TextSize               = 12
HPLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
HPLabel.TextXAlignment         = Enum.TextXAlignment.Left
HPLabel.Text                   = ''
HPLabel.Parent                 = TargetFrame

-- Barra de HP
local HPBarBg = Instance.new('Frame')
HPBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
HPBarBg.BorderSizePixel  = 0
HPBarBg.Size             = UDim2.fromOffset(130, 6)
HPBarBg.Position         = UDim2.fromOffset(65, 44)
HPBarBg.Parent           = TargetFrame

local HPBar = Instance.new('Frame')
HPBar.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
HPBar.BorderSizePixel  = 0
HPBar.Size             = UDim2.new(1, 0, 1, 0)
HPBar.Parent           = HPBarBg

-- Armor Label
local ArmorLabel = Instance.new('TextLabel')
ArmorLabel.BackgroundTransparency = 1
ArmorLabel.Size                   = UDim2.fromOffset(130, 14)
ArmorLabel.Position               = UDim2.fromOffset(65, 54)
ArmorLabel.Font                   = Enum.Font.Code
ArmorLabel.TextSize               = 12
ArmorLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
ArmorLabel.TextXAlignment         = Enum.TextXAlignment.Left
ArmorLabel.Text                   = ''
ArmorLabel.Parent                 = TargetFrame

-- Barra de Armor
local ArmorBarBg = Instance.new('Frame')
ArmorBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ArmorBarBg.BorderSizePixel  = 0
ArmorBarBg.Size             = UDim2.fromOffset(130, 6)
ArmorBarBg.Position         = UDim2.fromOffset(65, 70)
ArmorBarBg.Parent           = TargetFrame

local ArmorBar = Instance.new('Frame')
ArmorBar.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
ArmorBar.BorderSizePixel  = 0
ArmorBar.Size             = UDim2.new(1, 0, 1, 0)
ArmorBar.Parent           = ArmorBarBg

-- Draggable
local dragging, dragStart, startPos
TargetFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = TargetFrame.Position
    end
end)
TargetFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        TargetFrame.Position = UDim2.fromOffset(
            startPos.X.Offset + delta.X,
            startPos.Y.Offset + delta.Y
        )
    end
end)
TargetFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Atualiza a janela
local lastTarget = nil
RunService.Heartbeat:Connect(function()
    local target = nil

    if Options.RagebotKeybind and RagebotEnabled then
        local state = Options.RagebotKeybind:GetState()
        if state then
            local mouse = LocalPlayer:GetMouse()
            local t = mouse.Target
            if t then
                local targetChar   = t:FindFirstAncestorOfClass('Model')
                local targetPlayer = targetChar and Players:GetPlayerFromCharacter(targetChar)
                if targetPlayer and targetPlayer ~= LocalPlayer then
                    target = targetPlayer
                end
            end
        end
    end

    if not target then
        TargetFrame.Visible = false
        lastTarget = nil
        return
    end

    TargetFrame.Visible = true

    if target ~= lastTarget then
        lastTarget = target
        pcall(function()
            Avatar.Image = game:GetService('Players'):GetUserThumbnailAsync(
                target.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)
        NameLabel.Text = target.Name
    end

    local char = target.Character
    local hum  = char and char:FindFirstChildOfClass('Humanoid')
    if hum then
        local hp  = math.floor(hum.Health)
        local max = math.floor(hum.MaxHealth)
        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        HPLabel.Text = 'HP: ' .. hp .. ' / ' .. max
        HPBar.Size   = UDim2.new(pct, 0, 1, 0)
        if pct > 0.6 then
            HPBar.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        elseif pct > 0.3 then
            HPBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        else
            HPBar.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        end
    end

    if char then
        local armor = char:FindFirstChild('Armor') or char:FindFirstChild('Shield') or char:FindFirstChild('ArmorValue')
        if armor then
            local pct = math.clamp(armor.Value / 100, 0, 1)
            ArmorLabel.Text = 'Armor: ' .. math.floor(armor.Value)
            ArmorBar.Size   = UDim2.new(pct, 0, 1, 0)
        else
            ArmorLabel.Text = 'Armor: 0'
            ArmorBar.Size   = UDim2.new(0, 0, 1, 0)
        end
    end
end)

-- =============================================
--  ABA RAGEBOT - TARGET
-- =============================================

RagebotTarget:AddDropdown('TargetPlayer', {
    Text        = 'Select Player',
    SpecialType = 'Player',
    Callback    = function(Value)
        if Value then
            local target = Players:FindFirstChild(Value)
            if target then
                Aiming.Selected     = target
                local char = target.Character
                if char then
                    Aiming.SelectedPart = char:FindFirstChild(Aiming.TargetPart[1] or 'Head')
                        or char:FindFirstChild('HumanoidRootPart')
                end
            end
        end
    end,
})

RagebotTarget:AddButton({
    Text = 'Teleport to Target',
    Func = function()
        if not Options.TargetPlayer.Value then
            print('Nenhum player selecionado!')
            return
        end
        local target = Players:FindFirstChild(Options.TargetPlayer.Value)
        if not target then return end
        local targetChar = target.Character
        if not targetChar then return end
        local targetRoot = targetChar:FindFirstChild('HumanoidRootPart')
        if not targetRoot then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild('HumanoidRootPart')
        if not root then return end
        root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
    end,
    Tooltip = 'Teleporta até o target selecionado',
})

local SpectateEnabled  = false
local SpectateFromKeybind = false
local SpectateConnection = nil

local function StartSpectate()
    if SpectateConnection then SpectateConnection:Disconnect() SpectateConnection = nil end

    SpectateConnection = RunService.RenderStepped:Connect(function()
        if not SpectateEnabled then
            SpectateConnection:Disconnect()
            SpectateConnection = nil
            return
        end
        if not Options.TargetPlayer.Value then return end
        local target = Players:FindFirstChild(Options.TargetPlayer.Value)
        if not target then return end
        local targetChar = target.Character
        if not targetChar then return end
        local targetRoot = targetChar:FindFirstChild('HumanoidRootPart')
        if not targetRoot then return end

        camera.CFrame = CFrame.new(
            targetRoot.Position + Vector3.new(0, 5, 8),
            targetRoot.Position
        )
    end)
end

local function StopSpectate()
    if SpectateConnection then SpectateConnection:Disconnect() SpectateConnection = nil end
    camera.CameraType = Enum.CameraType.Custom
end

RagebotTarget:AddToggle('SpectateToggle', {
    Text    = 'Spectate',
    Default = false,
    Callback = function(Value)
        if not SpectateFromKeybind then
            SpectateEnabled = Value
            if Value then StartSpectate() else StopSpectate() end
        end
    end,
}):AddKeyPicker('SpectateKeybind', {
    Default = 'None',
    Mode    = 'Toggle',
    Text    = 'Spectate',
    NoUI    = false,
    Callback = function(Value) end,
})

RunService.Heartbeat:Connect(function()
    if Options.SpectateKeybind then
        local state = Options.SpectateKeybind:GetState()
        if state ~= SpectateEnabled then
            SpectateFromKeybind = true
            SpectateEnabled = state
            Toggles.SpectateToggle:SetValue(state)
            if state then StartSpectate() else StopSpectate() end
            SpectateFromKeybind = false
        end
    end
end)

-- =============================================
--  ABA VISUAL - HITBOX
-- =============================================

local ESPToggles = Tabs.Visual:AddLeftGroupbox('ESP Toggles')
local ESPConfig  = Tabs.Visual:AddRightGroupbox('ESP Config')

local BoxESPEnabled = false
local BoxESPColor   = Color3.fromRGB(255, 0, 0)
local BoxESPData    = {}
local BoxESPGui     = Instance.new('ScreenGui')
BoxESPGui.Name         = 'BoxESP'
BoxESPGui.ResetOnSpawn = false
pcall(function() BoxESPGui.Parent = game:GetService('CoreGui') end)
pcall(function() syn.protect_gui(BoxESPGui) BoxESPGui.Parent = game:GetService('CoreGui') end)

local function CreateBoxFrame(player)
    if player == LocalPlayer then return end
    if BoxESPData[player] then return end

    local frame = Instance.new('Frame')
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel        = 0
    frame.Size                   = UDim2.fromOffset(0, 0)
    frame.Position               = UDim2.fromOffset(0, 0)
    frame.Visible                = false
    frame.Parent                 = BoxESPGui

    local borders = {}
    for i = 1, 4 do
        local border = Instance.new('Frame')
        border.BackgroundColor3 = BoxESPColor
        border.BorderSizePixel  = 0
        border.Parent           = frame
        table.insert(borders, border)
    end

    -- Top
    borders[1].Size     = UDim2.new(1, 0, 0, 1)
    borders[1].Position = UDim2.new(0, 0, 0, 0)
    -- Bottom
    borders[2].Size     = UDim2.new(1, 0, 0, 1)
    borders[2].Position = UDim2.new(0, 0, 1, -1)
    -- Left
    borders[3].Size     = UDim2.new(0, 1, 1, 0)
    borders[3].Position = UDim2.new(0, 0, 0, 0)
    -- Right
    borders[4].Size     = UDim2.new(0, 1, 1, 0)
    borders[4].Position = UDim2.new(1, -1, 0, 0)

    BoxESPData[player] = { frame = frame, borders = borders }
end

local function RemoveBoxFrame(player)
    local data = BoxESPData[player]
    if not data then return end
    data.frame:Destroy()
    BoxESPData[player] = nil
end

local function UpdateBoxESP()
    for player, data in pairs(BoxESPData) do
        local char = player.Character
        local hum  = char and char:FindFirstChildOfClass('Humanoid')
        local root = char and char:FindFirstChild('HumanoidRootPart')

        if not BoxESPEnabled or not char or not hum or not root or hum.Health <= 0 then
            data.frame.Visible = false
            continue
        end

        local topPos    = root.Position + Vector3.new(0, 2.8, 0)
        local bottomPos = root.Position - Vector3.new(0, 3, 0)

        local top,    topVis    = camera:WorldToViewportPoint(topPos)
        local bottom, bottomVis = camera:WorldToViewportPoint(bottomPos)

        if not topVis or not bottomVis or top.Z < 0 or bottom.Z < 0 then
            data.frame.Visible = false
            continue
        end

        local height = math.abs(bottom.Y - top.Y)
        local width  = height * 0.45 -- proporção fixa baseada na altura

        if height <= 0 then
            data.frame.Visible = false
            continue
        end

        local centerX = (top.X + bottom.X) / 2

        data.frame.Position = UDim2.fromOffset(centerX - width / 2, top.Y)
        data.frame.Size     = UDim2.fromOffset(width, height)
        data.frame.Visible  = true

        for _, border in pairs(data.borders) do
            border.BackgroundColor3 = BoxESPColor
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do CreateBoxFrame(p) end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5) CreateBoxFrame(p) end)
    CreateBoxFrame(p)
end)
Players.PlayerRemoving:Connect(RemoveBoxFrame)

RunService.RenderStepped:Connect(UpdateBoxESP)

ESPToggles:AddToggle('BoxESPToggle', {
    Text    = 'Box ESP',
    Default = false,
    Callback = function(Value)
        BoxESPEnabled = Value
    end,
})

ESPConfig:AddLabel('Box Color'):AddColorPicker('BoxESPColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        BoxESPColor = Value
    end,
})

local NameESPEnabled  = false
local NameESPColor    = Color3.fromRGB(255, 255, 255)
local NameESPPosition = 'Top'
local NameESPData     = {}

local function CreateNameESP(player)
    if player == LocalPlayer then return end
    if NameESPData[player] then return end

    local label = Instance.new('BillboardGui')
    label.Name            = 'NameESP'
    label.AlwaysOnTop     = true
    label.Size            = UDim2.fromOffset(100, 20)
    label.StudsOffset     = Vector3.new(0, 3.5, 0)
    label.Enabled         = false

    local text = Instance.new('TextLabel')
    text.BackgroundTransparency = 1
    text.Size                   = UDim2.fromScale(1, 1)
    text.TextColor3             = NameESPColor
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3       = Color3.new(0, 0, 0)
    text.Font                   = Enum.Font.GothamBold
    text.TextSize               = 12
    text.Text                   = player.Name
    text.Parent                 = label

    NameESPData[player] = { gui = label, text = text }
end

local function RemoveNameESP(player)
    local data = NameESPData[player]
    if not data then return end
    data.gui:Destroy()
    NameESPData[player] = nil
end

local function UpdateNameESP()
    for player, data in pairs(NameESPData) do
        local char = player.Character
        local hum  = char and char:FindFirstChildOfClass('Humanoid')
        local root = char and char:FindFirstChild('HumanoidRootPart')

        if not NameESPEnabled or not char or not hum or not root or hum.Health <= 0 then
            data.gui.Enabled = false
            continue
        end

        -- Posição baseada no dropdown
        if NameESPPosition == 'Top' then
            data.gui.StudsOffset = Vector3.new(0, 3.5, 0)
        else
            data.gui.StudsOffset = Vector3.new(0, -3.5, 0)
        end

        if data.gui.Parent ~= root then
            data.gui.Parent = root
        end

        data.text.TextColor3 = NameESPColor
        data.text.Text       = player.Name
        data.gui.Enabled     = true
    end
end

for _, p in pairs(Players:GetPlayers()) do CreateNameESP(p) end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        RemoveNameESP(p)
        CreateNameESP(p)
    end)
    CreateNameESP(p)
end)
Players.PlayerRemoving:Connect(RemoveNameESP)

RunService.RenderStepped:Connect(UpdateNameESP)

ESPToggles:AddToggle('NameESPToggle', {
    Text    = 'Name ESP',
    Default = false,
    Callback = function(Value)
        NameESPEnabled = Value
    end,
})

ESPConfig:AddDropdown('NameESPPosition', {
    Text    = 'Name Position',
    Values  = { 'Top', 'Bottom' },
    Default = 1,
    Callback = function(Value)
        NameESPPosition = Value
    end,
})

ESPConfig:AddLabel('Name Color'):AddColorPicker('NameESPColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        NameESPColor = Value
    end,
})

local SkeletonESPEnabled = false
local SkeletonESPColor   = Color3.fromRGB(255, 255, 255)
local SkeletonESPData    = {}
local SkeletonESPGui     = Instance.new('ScreenGui')
SkeletonESPGui.Name         = 'SkeletonESP'
SkeletonESPGui.ResetOnSpawn = false
pcall(function() SkeletonESPGui.Parent = game:GetService('CoreGui') end)
pcall(function() syn.protect_gui(SkeletonESPGui) SkeletonESPGui.Parent = game:GetService('CoreGui') end)

-- Conexões do esqueleto
local SkeletonBones = {
    { 'Head',          'UpperTorso'    },
    { 'UpperTorso',    'LowerTorso'    },
    { 'UpperTorso',    'LeftUpperArm'  },
    { 'LeftUpperArm',  'LeftLowerArm'  },
    { 'LeftLowerArm',  'LeftHand'      },
    { 'UpperTorso',    'RightUpperArm' },
    { 'RightUpperArm', 'RightLowerArm' },
    { 'RightLowerArm', 'RightHand'     },
    { 'LowerTorso',    'LeftUpperLeg'  },
    { 'LeftUpperLeg',  'LeftLowerLeg'  },
    { 'LeftLowerLeg',  'LeftFoot'      },
    { 'LowerTorso',    'RightUpperLeg' },
    { 'RightUpperLeg', 'RightLowerLeg' },
    { 'RightLowerLeg', 'RightFoot'     },
}

local function CreateLine()
    local frame = Instance.new('Frame')
    frame.BackgroundColor3    = SkeletonESPColor
    frame.BorderSizePixel     = 0
    frame.AnchorPoint         = Vector2.new(0, 0.5)
    frame.Size                = UDim2.fromOffset(0, 1)
    frame.Visible             = false
    frame.Parent              = SkeletonESPGui
    return frame
end

local function UpdateLine(frame, from, to)
    local dx    = to.X - from.X
    local dy    = to.Y - from.Y
    local length = math.sqrt(dx * dx + dy * dy)
    local angle  = math.atan2(dy, dx)

    frame.Position = UDim2.fromOffset(from.X, from.Y)
    frame.Size     = UDim2.fromOffset(length, 1)
    frame.Rotation = math.deg(angle)
    frame.BackgroundColor3 = SkeletonESPColor
    frame.Visible = true
end

local function CreateSkeletonESP(player)
    if player == LocalPlayer then return end
    if SkeletonESPData[player] then return end

    local lines = {}
    for i = 1, #SkeletonBones do
        table.insert(lines, CreateLine())
    end

    SkeletonESPData[player] = { lines = lines }
end

local function RemoveSkeletonESP(player)
    local data = SkeletonESPData[player]
    if not data then return end
    for _, line in pairs(data.lines) do
        line:Destroy()
    end
    SkeletonESPData[player] = nil
end

local function UpdateSkeletonESP()
    for player, data in pairs(SkeletonESPData) do
        local char = player.Character
        local hum  = char and char:FindFirstChildOfClass('Humanoid')

        if not SkeletonESPEnabled or not char or not hum or hum.Health <= 0 then
            for _, line in pairs(data.lines) do line.Visible = false end
            continue
        end

        for i, bone in pairs(SkeletonBones) do
            local partA = char:FindFirstChild(bone[1])
            local partB = char:FindFirstChild(bone[2])
            local line  = data.lines[i]

            if not partA or not partB then
                line.Visible = false
                continue
            end

            local screenA, visA = camera:WorldToViewportPoint(partA.Position)
            local screenB, visB = camera:WorldToViewportPoint(partB.Position)

            if not visA or not visB or screenA.Z < 0 or screenB.Z < 0 then
                line.Visible = false
                continue
            end

            UpdateLine(line,
                Vector2.new(screenA.X, screenA.Y),
                Vector2.new(screenB.X, screenB.Y)
            )
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do CreateSkeletonESP(p) end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5) RemoveSkeletonESP(p) CreateSkeletonESP(p) end)
    CreateSkeletonESP(p)
end)
Players.PlayerRemoving:Connect(RemoveSkeletonESP)

RunService.RenderStepped:Connect(UpdateSkeletonESP)

ESPToggles:AddToggle('SkeletonESPToggle', {
    Text    = 'Skeleton ESP',
    Default = false,
    Callback = function(Value)
        SkeletonESPEnabled = Value
    end,
})

ESPConfig:AddLabel('Skeleton Color'):AddColorPicker('SkeletonESPColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        SkeletonESPColor = Value
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
    Callback = function(Value) end,
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

------------------------------------

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
    Callback = function(Value) end,
})

RunService.Heartbeat:Connect(function()
    if Options.FlyKeybind then
        local state = Options.FlyKeybind:GetState()
        print('FlyKeybind state:', state, '| FlyEnabled:', FlyEnabled, '| Mode:', Options.FlyKeybind.Mode)
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
--  ABA MISC - JUMPPOWER
-- =============================================

local JumpBox = Tabs.Misc:AddRightGroupbox('Jump Power')

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

local PlayerSettings = Tabs.Misc:AddLeftGroupbox('Player')

local NoclipEnabled    = false
local NoclipConnection = nil

PlayerSettings:AddToggle('NoclipToggle', {
    Text    = 'Noclip',
    Default = false,
    Callback = function(Value)
        NoclipEnabled = Value
        if not Value then
            if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA('BasePart') then
                        part.CanCollide = true
                    end
                end
            end
        else
            NoclipConnection = RunService.Heartbeat:Connect(function()
                if not NoclipEnabled then return end
                local char = LocalPlayer.Character
                if not char then return end
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA('BasePart') then
                        part.CanCollide = false
                    end
                end
            end)
        end
    end,
})


local NoSlowdownMinSpeed = 16
local NoSlowdownEnabled = false
local NoSlowdownHook    = nil
local mt                = getrawmetatable(game)

PlayerSettings:AddToggle('NoSlowdownToggle', {
    Text    = 'No Slowdown',
    Default = false,
    Callback = function(Value)
        NoSlowdownEnabled = Value
        if Value and not NoSlowdownHook then
            NoSlowdownHook = hookfunction(mt.__newindex, newcclosure(function(self, key, value)
                if NoSlowdownEnabled and key == 'WalkSpeed' and value < NoSlowdownMinSpeed then
                    value = NoSlowdownMinSpeed
                end
                return NoSlowdownHook(self, key, value)
            end))
        end
    end,
})

PlayerSettings:AddSlider('NoSlowdownSpeed', {
    Text     = 'Min Speed',
    Default  = 16,
    Min      = 16,
    Max      = 20,
    Rounding = 0,
    Callback = function(Value)
        NoSlowdownMinSpeed = Value
    end,
})

local NoJumpCooldownBox = PlayerSettings

local NoJumpCooldownEnabled = false
local gmt = getrawmetatable(game)
local oldNewindex

NoJumpCooldownBox:AddToggle('NoJumpCooldownToggle', {
    Text    = 'No Jump Cooldown',
    Default = false,
    Callback = function(Value)
        NoJumpCooldownEnabled = Value
        if Value and not oldNewindex then
            setreadonly(gmt, false)
            oldNewindex = gmt.__newindex
            gmt.__newindex = newcclosure(function(t, i, v)
                if NoJumpCooldownEnabled and i == 'JumpPower' then
                    return oldNewindex(t, i, 50)
                end
                return oldNewindex(t, i, v)
            end)
        end
    end,
})


local KillSoundBox = Tabs.Misc:AddLeftGroupbox('Kill Sound')

local KillSoundEnabled  = false
local KillSoundSelected = 'Cod'
local LastKOState       = {}

local KillSounds = {
    ['SSG-08']    = 'rbxassetid://2476571739',
    ['SCAR20']    = 'rbxassetid://1112856880',
    ['G3SG1']     = 'rbxassetid://1112950864',
    ['USP-S']     = 'rbxassetid://1112952739',
    ['AWP']       = 'rbxassetid://1112948895',
    ['RIFK7']     = 'rbxassetid://9102080552',
    ['Bubble']    = 'rbxassetid://9102092728',
    ['Minecraft'] = 'rbxassetid://5869422451',
    ['Cod']       = 'rbxassetid://160432334',
    ['Bameware']  = 'rbxassetid://6565367558',
    ['Neverlose'] = 'rbxassetid://6565370984',
    ['Gamesense'] = 'rbxassetid://4817809188',
    ['Rust']      = 'rbxassetid://6565371338',
}

local function PlayKillSound()
    local soundId = KillSounds[KillSoundSelected]
    if not soundId then return end
    local sound = Instance.new('Sound')
    sound.SoundId = soundId
    sound.Volume  = 1
    sound.Parent  = workspace
    sound:Play()
    game:GetService('Debris'):AddItem(sound, 5)
end

RunService.Heartbeat:Connect(function()
    if not KillSoundEnabled then return end
    if not Aiming.Selected then return end

    local target = Aiming.Selected
    local char   = target.Character
    if not char then return end

    local BodyEffects = char:FindFirstChild('BodyEffects')
    if not BodyEffects then return end

    local KO = BodyEffects:FindFirstChild('K.O')
    if not KO then return end

    local prev = LastKOState[target]
    if KO.Value and prev == false then
        PlayKillSound()
    end
    LastKOState[target] = KO.Value
end)

KillSoundBox:AddToggle('KillSoundToggle', {
    Text    = 'Kill Sound',
    Default = false,
    Callback = function(Value)
        KillSoundEnabled = Value
    end,
})

local soundNames = {}
for name in pairs(KillSounds) do
    table.insert(soundNames, name)
end
table.sort(soundNames)

KillSoundBox:AddDropdown('KillSoundDropdown', {
    Text    = 'Sound',
    Values  = soundNames,
    Default = 1,
    Callback = function(Value)
        KillSoundSelected = Value
    end,
})

local ServerBox = Tabs.Misc:AddLeftGroupbox('Server')

local TeleportService = game:GetService('TeleportService')


-- Input + botao pra entrar num Job ID
ServerBox:AddInput('JobIdInput', {
    Default     = '',
    Numeric     = false,
    Finished    = false,
    Text        = 'Job ID',
    Placeholder = 'Cole o Job ID aqui',
})

-- Copiar Job ID
ServerBox:AddButton({
    Text = 'Copy Job ID',
    Func = function()
        pcall(function()
            setclipboard(game.JobId)
        end)
        Library:Notify('Job ID copiado!', 3)
    end,
})

ServerBox:AddButton({
    Text = 'Join Job ID',
    Func = function()
        local jobId = Options.JobIdInput.Value
        if jobId == '' then
            Library:Notify('Digite um Job ID!', 3)
            return
        end
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
        end)
    end,
})

-- Rejoin
ServerBox:AddButton({
    Text = 'Rejoin',
    Func = function()
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end,
})

-- Hop Server
ServerBox:AddButton({
    Text = 'Hop Server',
    Func = function()
        pcall(function()
            local HttpService = game:GetService('HttpService')
            local servers = {}
            local url = 'https://games.roblox.com/v1/games/' .. game.PlaceId .. '/servers/Public?sortOrder=Asc&limit=100'
            local result = HttpService:JSONDecode(game:HttpGet(url))
            for _, server in pairs(result.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end
            if #servers == 0 then
                Library:Notify('Nenhum servidor disponível!', 3)
                return
            end
            local picked = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, picked, LocalPlayer)
        end)
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

-- Watermark
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
    Library:SetWatermark(('seraphine.cc | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

MenuGroup:AddToggle('WatermarkToggle', {
    Text    = 'Watermark',
    Default = false,
    Callback = function(Value)
        Library:SetWatermarkVisibility(Value)
    end,
})

MenuGroup:AddToggle('KeybindFrameToggle', {
    Text    = 'Keybind Menu',
    Default = false,
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end,
})

Library.KeybindFrame.Visible = true

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    FovCircle:Remove()
    Aiming.Enabled = false
    print('[seraphine.cc] Descarregado!')
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

warn('[seraphine.cc] Carregado com sucesso!')
