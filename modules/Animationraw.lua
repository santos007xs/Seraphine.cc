-- Animation Changer Configuration
-- Animações customizáveis por ação

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Lista de animações disponíveis
local AnimationList = {
    "None",
    "Ninja",
    "Robot",
    "Default",
    "Rthro",
    "Levitate",
    "Mage",
    "Stylish",
    "Hero",
    "Toy",
    "Astronaut",
    "Bubbly",
    "Cartoony",
    "Elder",
    "Ghost",
    "Knight",
    "Vampire",
    "Werewolf",
    "Zombie",
    "Bold",
    "Adidas",
    "Catwalk",
    "Walmart",
    "Wicked",
    "NFL",
    "Pirate",
    "Adidas2",
    "Oldschool",
    "Unboxed",
    "Aura",
    "Wicked2",
    "Ud",
    "Toilet"
}

-- Configurações padrão
local AnimSettings = {
    run = "None",
    walk = "None",
    jump = "None",
    idle1 = "None",
    idle2 = "None",
    fall = "None",
    climb = "None",
    swim = "None",
    swimidle = "None"
}

-- Função para aplicar animações
local function ApplyAnimations()
    -- Verificar se alguma animação está ativa
    local hasAnimation = false
    for _, anim in pairs(AnimSettings) do
        if anim ~= "None" then
            hasAnimation = true
            break
        end
    end
    
    if not hasAnimation then
        -- Se todas estão None, não fazer nada
        return
    end
    
    -- Aplicar configurações
    pcall(function()
        getgenv().HybridSettings = {
            run = AnimSettings.run == "None" and "Default" or AnimSettings.run,
            walk = AnimSettings.walk == "None" and "Default" or AnimSettings.walk,
            jump = AnimSettings.jump == "None" and "Default" or AnimSettings.jump,
            idle1 = AnimSettings.idle1 == "None" and "Default" or AnimSettings.idle1,
            idle2 = AnimSettings.idle2 == "None" and "Default" or AnimSettings.idle2,
            fall = AnimSettings.fall == "None" and "Default" or AnimSettings.fall,
            climb = AnimSettings.climb == "None" and "Default" or AnimSettings.climb,
            swim = AnimSettings.swim == "None" and "Default" or AnimSettings.swim,
            swimidle = AnimSettings.swimidle == "None" and "Default" or AnimSettings.swimidle
        }
        
        getgenv().ChosenBundleName = "Mage"
        getgenv().EnableHybridCustom = true
        
        -- Carregar o script de animações
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Mautiku/Animation/refs/heads/main/Animation%20Changer%20v3%20Stable"))()
    end)
end

-- Exportar para uso global
getgenv().AnimationConfig = {
    AnimationList = AnimationList,
    Settings = AnimSettings,
    Apply = ApplyAnimations,
    SetAnimation = function(type, anim)
        if AnimSettings[type] then
            AnimSettings[type] = anim
            ApplyAnimations()
        end
    end,
    GetAnimation = function(type)
        return AnimSettings[type] or "None"
    end,
}
