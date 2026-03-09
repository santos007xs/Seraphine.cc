-- Adicione este código APÓS as seções do Misc

-- URL do RAW no GitHub (substitua pela sua URL)
local CURSOR_CONFIG_URL = "https://raw.githubusercontent.com/seu-usuario/seu-repo/refs/heads/main/cursor_raw_config.lua"

local CustomCursorEnabled = false
local mouse = game:GetService("Players").LocalPlayer:GetMouse()

-- Carregar configuração do RAW com proteção
local function LoadCursorConfig()
    local success, result = pcall(function()
        return game:HttpGet(CURSOR_CONFIG_URL)
    end)
    
    if success and result then
        local loadSuccess = pcall(function()
            loadstring(result)()
        end)
        return loadSuccess
    else
        warn("Erro ao carregar config de cursor: " .. tostring(result))
        return false
    end
end

-- Carregar config em thread separada
task.spawn(function()
    task.wait(1)
    LoadCursorConfig()
end)

-- Toggle para ativar/desativar
MiscSection:AddToggle({
    Name = "Custom Cursor", Flag = "Misc_CustomCursor", Default = false,
    Callback = function(v)
        CustomCursorEnabled = v
        pcall(function()
            if not v then
                mouse.Icon = ""
            elseif getgenv().CustomCursorConfig then
                local current = getgenv().CustomCursorConfig.CurrentCursor or "Default"
                getgenv().CustomCursorConfig.ApplyCursor(current)
            end
        end)
    end,
});

-- Dropdown para selecionar cursor
MiscConfigSection:AddDropdown({
    Name = "Cursor Style",
    Default = "Default",
    Flag = "Misc_CursorStyle",
    Values = {
        "Default",
        "Drag",
        "DragClosed",
        "Forbidden",
        "Heart",
        "OpenHand",
        "PointingHand",
        "ResizeNESW",
        "ResizeNS",
        "ResizeNWSE",
        "ResizeEW",
        "Rotate",
        "RotateCW",
        "Wait",
        "WaitArrow",
    },
    Callback = function(v)
        pcall(function()
            if CustomCursorEnabled and getgenv().CustomCursorConfig then
                getgenv().CustomCursorConfig.CurrentCursor = v
                getgenv().CustomCursorConfig.ApplyCursor(v)
            end
        end)
    end,
});

-- Botão para recarregar do RAW
MiscConfigSection:AddButton({
    Name = "Reload from RAW",
    Callback = function()
        if LoadCursorConfig() then
            Notifier:Notify({
                Title = "Custom Cursor",
                Content = "Config recarregada com sucesso!",
                Duration = 2,
            })
        else
            Notifier:Notify({
                Title = "Custom Cursor",
                Content = "Erro ao recarregar config",
                Duration = 3,
            })
        end
    end,
});
