-- ============================================
-- SILENT AIM MODULE
-- ============================================

local SilentAim = {}

-- Config padrão
SilentAim.Enabled = false
SilentAim.FOV = 90
SilentAim.HitChance = 100

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ============================================
-- FUNÇÕES AUXILIARES
-- ============================================

function SilentAim:GetPlayers()
    local playerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player)
        end
    end
    return playerList
end

function SilentAim:GetCharacter(player)
    if not player then return nil end
    local char = player.Character
    if not char or not char.Parent then return nil end
    return char
end

function SilentAim:GetHumanoid(char)
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

function SilentAim:GetHead(char)
    if not char then return nil end
    return char:FindFirstChild("Head")
end

function SilentAim:GetRootPart(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

function SilentAim:IsPlayerAlive(player)
    if not player then return false end
    local char = self:GetCharacter(player)
    if not char then return false end
    local hum = self:GetHumanoid(char)
    if not hum then return false end
    return hum.Health > 0
end

function SilentAim:GetClosestPlayerInFOV()
    local closestPlayer = nil
    local closestDistance = self.FOV
    
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, player in pairs(self:GetPlayers()) do
        if not self:IsPlayerAlive(player) then continue end
        
        local char = self:GetCharacter(player)
        local head = self:GetHead(char)
        if not head then continue end
        
        -- Calcula distância na tela
        local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end
        
        local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        
        if screenDistance < closestDistance then
            closestDistance = screenDistance
            closestPlayer = player
        end
    end
    
    return closestPlayer
end

function SilentAim:GetTargetPart(player)
    local char = self:GetCharacter(player)
    if not char then return nil end
    return self:GetHead(char) or self:GetRootPart(char)
end

-- ============================================
-- HOOK
-- ============================================

local oldIndex

function SilentAim:Hook()
    if oldIndex then return end
    
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(t, k)
        if not SilentAim.Enabled then
            return oldIndex(t, k)
        end
        
        if t:IsA("Mouse") and (k == "Hit" or k == "Target") then
            local target = SilentAim:GetClosestPlayerInFOV()
            
            if target then
                local targetPart = SilentAim:GetTargetPart(target)
                if targetPart then
                    -- Hit chance
                    local chance = math.random(1, 100)
                    if chance > SilentAim.HitChance then
                        return oldIndex(t, k)
                    end
                    
                    if k == "Hit" then
                        return targetPart.CFrame
                    else
                        return targetPart
                    end
                end
            end
        end
        
        return oldIndex(t, k)
    end))
end

-- Ativar hook
SilentAim:Hook()

return SilentAim
