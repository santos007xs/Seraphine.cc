-- Custom Cursor Configuration
-- Este arquivo deve ser colocado no GitHub e referenciado como RAW

-- Definir as opções de cursor disponíveis
local CursorOptions = {
    Default = "",
    Drag = "rbxasset://textures/Cursors/DragCursor.png",
    DragClosed = "rbxasset://textures/Cursors/DragClosedCursor.png",
    Forbidden = "rbxasset://textures/Cursors/Forbidden.png",
    Heart = "rbxasset://textures/Cursors/Heart.png",
    OpenHand = "rbxasset://textures/Cursors/OpenHand.png",
    PointingHand = "rbxasset://textures/Cursors/PointingHand.png",
    ResizeNESW = "rbxasset://textures/Cursors/ResizeNESW.png",
    ResizeNS = "rbxasset://textures/Cursors/ResizeNS.png",
    ResizeNWSE = "rbxasset://textures/Cursors/ResizeNWSE.png",
    ResizeEW = "rbxasset://textures/Cursors/ResizeEW.png",
    Rotate = "rbxasset://textures/Cursors/Rotate.png",
    RotateCW = "rbxasset://textures/Cursors/RotateCW.png",
    Wait = "rbxasset://textures/Cursors/Wait.png",
    WaitArrow = "rbxasset://textures/Cursors/WaitArrow.png",
}

-- Aplicar cursor padrão ao carregar
local mouse = game:GetService("Players").LocalPlayer:GetMouse()

-- Função para aplicar cursor
local function ApplyCursor(cursorName)
    local cursorImage = CursorOptions[cursorName]
    if cursorImage then
        mouse.Icon = cursorImage
        return true
    end
    return false
end

-- Função para obter lista de cursores disponíveis
local function GetAvailableCursors()
    local list = {}
    for name, _ in pairs(CursorOptions) do
        table.insert(list, name)
    end
    return list
end

-- Exportar para uso global
getgenv().CustomCursorConfig = {
    Options = CursorOptions,
    ApplyCursor = ApplyCursor,
    GetAvailableCursors = GetAvailableCursors,
    CurrentCursor = "Default",
}

-- Aplicar cursor padrão
ApplyCursor("Default")
