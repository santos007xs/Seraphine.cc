-- MouseLock Configuration
-- Aim lock baseado em posição do mouse

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variáveis
local MouseLockEnabled = false
local MouseLockFovEnabled = false
local AimRadius = 100
local TargetPlayer = nil
local Smoothness = 0.2
local MouseLockConnection = nil

-- Função para obter jogador mais próximo
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimRadius
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local character = player.Character
            local head = character:FindFirstChild("Head")
            local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(head.Position)
            
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    
    return closestPlayer
end

-- Função para ativar MouseLock
local function StartMouseLock()
    if MouseLockConnection then
        MouseLockConnection:Disconnect()
    end
    
    TargetPlayer = GetClosestPlayer()
    if not TargetPlayer then
        MouseLockEnabled = false
        return false
    end
    
    MouseLockEnabled = true
    
    MouseLockConnection = RunService.RenderStepped:Connect(function()
        if not MouseLockEnabled or not TargetPlayer or not TargetPlayer.Character then
            MouseLockEnabled = false
            if MouseLockConnection then
                MouseLockConnection:Disconnect()
                MouseLockConnection = nil
            end
            return
        end
        
        local head = TargetPlayer.Character:FindFirstChild("Head")
        if not head then
            MouseLockEnabled = false
            return
        end
        
        local screenPos = workspace.CurrentCamera:WorldToScreenPoint(head.Position)
        local targetX = (screenPos.X - Mouse.X) * Smoothness
        local targetY = (screenPos.Y - Mouse.Y) * Smoothness
        
        mousemoverel(targetX, targetY)
    end)
    
    return true
end

-- Função para desativar MouseLock
local function StopMouseLock()
    MouseLockEnabled = false
    TargetPlayer = nil
    if MouseLockConnection then
        MouseLockConnection:Disconnect()
        MouseLockConnection = nil
    end
end

-- Exportar para uso global
getgenv().MouseLockConfig = {
    Enabled = false,
    FovEnabled = false,
    AimRadius = 100,
    Smoothness = 0.2,
    TargetPlayer = nil,
    
    Start = StartMouseLock,
    Stop = StopMouseLock,
    SetRadius = function(radius)
        AimRadius = radius
    end,
    SetSmoothness = function(smoothness)
        Smoothness = smoothness
    end,
    GetTarget = function()
        return TargetPlayer
    end,
}
