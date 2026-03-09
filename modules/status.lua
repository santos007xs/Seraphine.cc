-- Kill Switch - Fecha o Roblox se status for offline

local RunService = game:GetService("RunService")

local STATUS_URL = "https://raw.githubusercontent.com/santos007xs/Victory/refs/heads/main/status.json"
local LastCheckTime = 0
local CheckInterval = 10 -- Verificar a cada 10 segundos

-- Função para fechar o Roblox
local function CloseRoblox()
    pcall(function()
        -- Método 1: Fechar via script
        local function closeGame()
            game:Shutdown()
        end
        
        -- Tentar fechar
        pcall(closeGame)
        
        -- Se não funcionar, tenta alternativa
        task.wait(1)
        os.exit(0)
    end)
end

-- Função para verificar status
local function CheckKillSwitch()
    local currentTime = tick()
    if currentTime - LastCheckTime < CheckInterval then
        return
    end
    
    LastCheckTime = currentTime
    
    pcall(function()
        local response = game:HttpGet(STATUS_URL)
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(response)
        end)
        
        if success and data then
            local status = string.lower(data.Status or "online")
            
            if status == "offline" then
                -- Status está offline, fechar o jogo
                CloseRoblox()
            end
        end
    end)
end

-- Monitorar kill switch
local killSwitchConn = RunService.Heartbeat:Connect(function()
    CheckKillSwitch()
end)

-- Exportar para uso global
getgenv().KillSwitchConfig = {
    CheckKillSwitch = CheckKillSwitch,
    CloseRoblox = CloseRoblox,
}
