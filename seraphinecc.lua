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

-- =============================================
--  ABA AIMBOT - CAMLOCK
-- =============================================

local AimbotTabBox = Tabs.Aimbot:AddRightTabbox()
local Tab1 = AimbotTabBox:AddTab('Camlock')
local Tab2 = AimbotTabBox:AddTab('Triggerbot')
local CamlockBox = Tab1

local CamlockEnabled         = false
local CamlockFovEnabled      = false
local CamlockSmooth          = 10
local CamlockFovSize         = 100
local CamlockTarget          = nil
local CamlockDistanceEnabled = false
local CamlockMaxDistance     = 500
local CamlockBodyPart        = 'HumanoidRootPart'
local CamlockKoCheck         = false
local CamlockKeybindMode     = 'Toggle'
local CamlockKeybind         = Enum.KeyCode.X
local CamlockVisibleCheck = false

local FovCircle       = Drawing.new('Circle')
FovCircle.Visible     = false
FovCircle.Thickness   = 1
FovCircle.Filled      = false
FovCircle.Color       = Color3.fromRGB(255, 255, 255)

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
    local screenCenter = GetScreenCenter()

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if CamlockKoCheck and not IsAlive(player) then continue end
        local char = player.Character
        local part = GetTargetPart(char)
        local hum  = char and char:FindFirstChildOfClass('Humanoid')
        if not part or not hum or hum.Health <= 0 then continue end
        if CamlockDistanceEnabled then
            if (camera.CFrame.Position - part.Position).Magnitude > CamlockMaxDistance then continue end
        end
        local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if screenDist < CamlockFovSize and screenDist < closestDist then
            closestDist = screenDist
            closest     = player
        end
    end

    CamlockTarget = closest
    return closest
end

RunService.Heartbeat:Connect(function()
    local screenCenter = GetScreenCenter()
    FovCircle.Visible  = CamlockFovEnabled
    FovCircle.Position = screenCenter
    FovCircle.Radius   = CamlockFovSize

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

    -- Visible check no alvo atual
    if CamlockVisibleCheck and not IsVisible(part) then
        CamlockTarget = nil return
    end

    camera.CFrame = camera.CFrame:Lerp(
        CFrame.new(camera.CFrame.Position, part.Position),
        1 / CamlockSmooth
    )
end)

local function IsVisible(part)
    if not part then return false end
    local rayOrigin = camera.CFrame.Position
    local rayDirection = part.Position - rayOrigin
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
    if result then
        local hitChar = result.Instance:FindFirstAncestorOfClass('Model')
        local hitPlayer = hitChar and Players:GetPlayerFromCharacter(hitChar)
        return hitPlayer ~= nil
    end
    return true
end

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


-- =============================================
--  ABA VISUAL - HITBOX
-- =============================================

local HitboxBox = Tabs.Visual:AddLeftGroupbox('ESP')

local HitboxEnabled = false
local HitboxColor   = Color3.fromRGB(128, 128, 128)
local HitboxSize    = 5
local HitboxData    = {}

local function RemoveHitbox(player)
    local data = HitboxData[player]
    if not data then return end
    if data.part      then pcall(function() data.part:Destroy() end) end
    if data.highlight then pcall(function() data.highlight:Destroy() end) end
    HitboxData[player] = nil
end

local function CreateHitbox(player)
    if player == LocalPlayer then return end
    RemoveHitbox(player)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild('HumanoidRootPart')
    if not root then return end

    local data = {}
    local part = Instance.new('Part')
    part.Name         = 'HitboxBox'
    part.Shape        = Enum.PartType.Block
    part.Size         = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
    part.Anchored     = false
    part.CanCollide   = false
    part.Massless     = true
    part.Transparency = 1
    part.CanQuery     = false

    local weld  = Instance.new('WeldConstraint')
    weld.Part0  = root
    weld.Part1  = part
    weld.Parent = part
    part.CFrame = root.CFrame
    part.Parent = root

    local hl               = Instance.new('Highlight')
    hl.FillColor           = HitboxColor
    hl.FillTransparency    = 0.4
    hl.OutlineColor        = HitboxColor
    hl.OutlineTransparency = 0
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled             = HitboxEnabled
    hl.Parent              = char

    data.part      = part
    data.highlight = hl
    HitboxData[player] = data
end

local function RefreshAllHitboxes()
    for player, data in pairs(HitboxData) do
        if data.highlight then
            data.highlight.Enabled      = HitboxEnabled
            data.highlight.FillColor    = HitboxColor
            data.highlight.OutlineColor = HitboxColor
        end
    end
end

local function SetupHitboxPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then CreateHitbox(player) end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if HitboxEnabled then CreateHitbox(player) end
    end)
end

for _, p in pairs(Players:GetPlayers()) do SetupHitboxPlayer(p) end
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Wait()
    task.wait(0.5)
    SetupHitboxPlayer(player)
end)
Players.PlayerRemoving:Connect(RemoveHitbox)

HitboxBox:AddToggle('HitboxToggle', {
    Text    = 'Hitbox',
    Default = false,
    Callback = function(Value)
        HitboxEnabled = Value
        if Value then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then CreateHitbox(p) end
            end
        else
            for p in pairs(HitboxData) do RemoveHitbox(p) end
        end
        RefreshAllHitboxes()
    end,
})

HitboxBox:AddSlider('HitboxSize', {
    Text     = 'Hitbox Size',
    Default  = 5,
    Min      = 1,
    Max      = 20,
    Rounding = 0,
    Callback = function(Value)
        HitboxSize = Value
        if HitboxEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then CreateHitbox(p) end
            end
        end
    end,
})

HitboxBox:AddLabel('Hitbox Color'):AddColorPicker('HitboxColor', {
    Default = Color3.fromRGB(128, 128, 128),
    Callback = function(Value)
        HitboxColor = Value
        RefreshAllHitboxes()
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
