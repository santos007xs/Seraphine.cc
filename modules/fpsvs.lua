-- FPS Display Configuration
-- Altera o FPS visual exibido (Shift + F5)

local Stats = game:FindFirstChild("Stats")
if not Stats then
    Stats = Instance.new("Folder")
    Stats.Name = "Stats"
    Stats.Parent = game
end

local ClientStats = Stats:FindFirstChild("ClientStats")
if not ClientStats then
    ClientStats = Instance.new("Folder")
    ClientStats.Name = "ClientStats"
    ClientStats.Parent = Stats
end

local FrameRateLabel = ClientStats:FindFirstChild("FrameRateLabel")
if not FrameRateLabel then
    FrameRateLabel = Instance.new("StringValue")
    FrameRateLabel.Name = "FrameRateLabel"
    FrameRateLabel.Parent = ClientStats
end

-- Função para atualizar o FPS exibido
local function UpdateFpsDisplay(fpsValue)
    pcall(function()
        FrameRateLabel.Value = "FPS: " .. tostring(fpsValue)
    end)
end

-- Exportar para uso global
getgenv().FpsDisplayConfig = {
    UpdateDisplay = UpdateFpsDisplay,
    CurrentFps = 60,
}
