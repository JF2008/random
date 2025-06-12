
-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

-- PLAYER & CHARACTER
local localPlayer = Players.LocalPlayer
local character
local humanoid
local humanoidRootPart
local defaultWalkSpeed = 16
local currentWalkSpeed = 16
local camera = Workspace.CurrentCamera

-- GUI INSTANCES
local mainScreenGui
local mainFrame
local tabsFrame, contentFrame
local teleportPage, characterPage, visualsPage, miscPage
local playerTeleportFrame -- Frame for player teleport buttons
local espContainer -- For 2D ESP elements

-- STATE VARIABLES
local guiVisible = true
local spawnPoint = nil
local flySpeed = 50
local isTeleporting = false
local isFlying = false
local isNoclipping = false
local isEspOn = false
local isAntiAfkOn = false
local isPlayerJoinKickOn = false
local isWalkSpeedOn = false
local activeTab = nil
local espElements = {} -- Stores all ESP related GUI elements for cleanup

-- CONNECTIONS & THREADS
local teleportConnection, flyConnection, noclipConnection, espConnection, antiAfkConnection

-- CONFIG
local ACCENT_COLOR = Color3.fromRGB(0, 120, 255)
local BG_COLOR = Color3.fromRGB(35, 37, 41)
local BG_LIGHTER_COLOR = Color3.fromRGB(47, 49, 54)
local FONT = Enum.Font.GothamSemibold

-- =============================================================================
-- ||                             GUI CREATION                                ||
-- =============================================================================

local function createToggleSwitch(parent, text, callback)
    local container = Instance.new("Frame")
    container.BackgroundColor3 = BG_COLOR
    container.BorderSizePixel = 0
    container.Size = UDim2.new(1, -20, 0, 30)
    container.Position = UDim2.new(0.5, 0, 0, 0)
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.BackgroundColor3 = BG_COLOR
    label.BorderSizePixel = 0
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Font = FONT
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 16
    label.Parent = container

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0.3, 0, 1, 0)
    switch.Position = UDim2.new(1, 0, 0.5, 0)
    switch.AnchorPoint = Vector2.new(1, 0.5)
    switch.BackgroundColor3 = BG_LIGHTER_COLOR
    switch.BorderSizePixel = 0
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = container

    local switchNub = Instance.new("Frame")
    switchNub.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    switchNub.BorderSizePixel = 0
    switchNub.Size = UDim2.new(0.4, 0, 0.8, 0)
    switchNub.Position = UDim2.new(0.05, 0, 0.5, 0)
    switchNub.AnchorPoint = Vector2.new(0, 0.5)
    switchNub.Parent = switch

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = switchNub
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0.1, 0)
    corner2.Parent = switch

    local enabled = false
    switch.MouseButton1Click:Connect(function()
        enabled = not enabled
        local nubPos = enabled and UDim2.new(0.95, 0, 0.5, 0) or UDim2.new(0.05, 0, 0.5, 0)
        local nubAnchor = enabled and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
        local nubColor = enabled and ACCENT_COLOR or Color3.fromRGB(180, 180, 180)
        
        TweenService:Create(switchNub, TweenInfo.new(0.15), { Position = nubPos, AnchorPoint = nubAnchor, BackgroundColor3 = nubColor }):Play()
        
        if callback then
            callback(enabled)
        end
    end)
    return switch
end

local function createSliderWithInput(parent, text, min, max, initialValue, callback)
    local container = Instance.new("Frame")
    container.BackgroundColor3 = BG_COLOR
    container.BorderSizePixel = 0
    container.Size = UDim2.new(1, -20, 0, 60)
    container.Position = UDim2.new(0.5, 0, 0, 0)
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.BackgroundColor3 = BG_COLOR
    label.BorderSizePixel = 0
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = FONT
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 16
    label.Parent = container
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, 60, 0, 30)
    input.Position = UDim2.new(1, 0, 0, 25)
    input.AnchorPoint = Vector2.new(1, 0)
    input.BackgroundColor3 = BG_LIGHTER_COLOR
    input.Font = FONT
    input.Text = tostring(initialValue)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = input

    -- Custom Slider Implementation
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -70, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 36)
    track.BackgroundColor3 = BG_LIGHTER_COLOR
    track.BorderSizePixel = 0
    track.Parent = container
    local trackCorner = Instance.new("UICorner")
    trackCorner.Parent = track

    local progress = Instance.new("Frame")
    progress.BackgroundColor3 = ACCENT_COLOR
    progress.BorderSizePixel = 0
    progress.Parent = track
    local progressCorner = Instance.new("UICorner")
    progressCorner.Parent = progress
    
    local handle = Instance.new("TextButton")
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(0, 0, 0.5, 0)
    handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    handle.Text = ""
    handle.Parent = track
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1,0)
    handleCorner.Parent = handle

    local currentValue = initialValue
    
    local function updateSlider(value)
        currentValue = math.clamp(value, min, max)
        local percentage = (currentValue - min) / (max - min)
        handle.Position = UDim2.new(percentage, 0, 0.5, 0)
        progress.Size = UDim2.new(percentage, 0, 1, 0)
        input.Text = tostring(math.floor(currentValue + 0.5))
        if callback then
            callback(currentValue)
        end
    end

    updateSlider(initialValue)

    local function onInput(inputObject)
        local percentage = math.clamp((inputObject.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * percentage
        updateSlider(value)
    end
    
    handle.InputBegan:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = UserInputService.InputChanged:Connect(function(changedInput)
                if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
                    onInput(changedInput)
                end
            end)
            
            local upConnection 
            upConnection = UserInputService.InputEnded:Connect(function(endedInput)
                if endedInput.UserInputType == Enum.UserInputType.MouseButton1 or endedInput.UserInputType == Enum.UserInputType.Touch then
                    connection:Disconnect()
                    upConnection:Disconnect()
                end
            end)
        end
    end)
    
    track.InputBegan:Connect(onInput)

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local value = tonumber(input.Text)
            if value then
                updateSlider(value)
            else
                input.Text = tostring(math.floor(currentValue + 0.5))
            end
        end
    end)
    return container
end

local function createButton(parent, text)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0.5, 0, 0, 0)
    button.AnchorPoint = Vector2.new(0.5, 0)
    button.BackgroundColor3 = BG_LIGHTER_COLOR
    button.Font = FONT
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.1, 0)
    corner.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(80, 82, 87) }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), { BackgroundColor3 = BG_LIGHTER_COLOR }):Play()
    end)
    
    return button
end

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.BackgroundColor3 = BG_COLOR
    page.BorderSizePixel = 0
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new(0, 0, 2, 0)
    page.ScrollBarImageColor3 = ACCENT_COLOR
    page.ScrollBarThickness = 5
    page.Visible = false
    page.Parent = contentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.Parent = page

    return page
end


local function createAdminPanel()
    mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.ResetOnSpawn = false

    espContainer = Instance.new("Frame")
    espContainer.Name = "ESP_Container"
    espContainer.BackgroundTransparency = 1
    espContainer.Size = UDim2.new(1,0,1,0)
    espContainer.Parent = mainScreenGui

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 40, 0, 40)
    toggleButton.Position = UDim2.new(0.5, 0, 0, 10)
    toggleButton.AnchorPoint = Vector2.new(0.5, 0)
    toggleButton.BackgroundColor3 = BG_LIGHTER_COLOR
    toggleButton.Font = FONT
    toggleButton.Text = ">"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 24
    toggleButton.Draggable = true
    toggleButton.Active = true
    toggleButton.Parent = mainScreenGui
    local cornerToggle = Instance.new("UICorner")
    cornerToggle.CornerRadius = UDim.new(0, 8)
    cornerToggle.Parent = toggleButton

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 350)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = BG_COLOR
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = guiVisible
    mainFrame.Active = true -- Make the frame active to receive input
    mainFrame.Draggable = true -- Make the frame itself draggable
    mainFrame.Parent = mainScreenGui

    toggleButton.MouseButton1Click:Connect(function()
        guiVisible = not guiVisible
        mainFrame.Visible = guiVisible
        toggleButton.Text = guiVisible and ">" or "<"
    end)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local shadow = Instance.new("ImageLabel")
    shadow.Image = "rbxassetid://10372365419"
    shadow.BackgroundTransparency = 1
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 50, 50)
    shadow.Size = UDim2.new(1, 12, 1, 12)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = BG_COLOR
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundColor3 = BG_COLOR
    titleLabel.Font = FONT
    titleLabel.Text = "Admin Panel"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Parent = titleBar

    tabsFrame = Instance.new("Frame")
    tabsFrame.Size = UDim2.new(0, 120, 1, -30)
    tabsFrame.Position = UDim2.new(0, 0, 0, 30)
    tabsFrame.BackgroundColor3 = BG_LIGHTER_COLOR
    tabsFrame.BorderSizePixel = 0
    tabsFrame.Parent = mainFrame
    
    local cornerTabs = Instance.new("UICorner")
    cornerTabs.CornerRadius = UDim.new(0, 8)
    cornerTabs.Parent = tabsFrame
    
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Padding = UDim.new(0, 5)
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Parent = tabsFrame

    local tabsPadding = Instance.new("UIPadding")
    tabsPadding.PaddingTop = UDim.new(0, 10)
    tabsPadding.Parent = tabsFrame

    contentFrame = Instance.new("Frame")
    contentFrame.Position = UDim2.new(0, 120, 0, 30)
    contentFrame.Size = UDim2.new(1, -120, 1, -30)
    contentFrame.BackgroundColor3 = Color3.new()
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    
    teleportPage = createPage("Teleports")
    characterPage = createPage("Character")
    visualsPage = createPage("Visuals")
    miscPage = createPage("Misc")
    
    local pages = {teleportPage, characterPage, visualsPage, miscPage}

    local function activateTab(tabToActivate, pageToActivate)
        if activeTab == tabToActivate then return end
        
        if activeTab then
            local oldIndicator = activeTab:FindFirstChild("TabIndicator")
            if oldIndicator then oldIndicator.Visible = false end
            TweenService:Create(activeTab, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(180, 180, 180) }):Play()
        end
        
        for _,p in pairs(pages) do
            p.Visible = false
        end

        pageToActivate.Visible = true
        local newIndicator = tabToActivate:FindFirstChild("TabIndicator")
        if newIndicator then newIndicator.Visible = true end
        TweenService:Create(tabToActivate, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
        
        activeTab = tabToActivate
    end
    
    local function createTab(name, page)
        local tab = Instance.new("TextButton")
        tab.Size = UDim2.new(1, -10, 0, 35)
        tab.BackgroundColor3 = BG_LIGHTER_COLOR
        tab.BorderSizePixel = 0
        tab.AutoButtonColor = false
        tab.Text = name
        tab.TextColor3 = Color3.fromRGB(180, 180, 180)
        tab.Font = FONT
        tab.TextSize = 16
        tab.Parent = tabsFrame

        local indicator = Instance.new("Frame")
        indicator.Name = "TabIndicator"
        indicator.BackgroundColor3 = ACCENT_COLOR
        indicator.BorderSizePixel = 0
        indicator.Size = UDim2.new(0, 3, 0.8, 0)
        indicator.Position = UDim2.new(0, 0, 0.5, 0)
        indicator.AnchorPoint = Vector2.new(0, 0.5)
        indicator.Visible = false
        indicator.Parent = tab
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = indicator

        tab.MouseButton1Click:Connect(function()
            activateTab(tab, page)
        end)
        
        tab.MouseEnter:Connect(function() if activeTab ~= tab then tab.TextColor3 = Color3.fromRGB(255, 255, 255) end end)
        tab.MouseLeave:Connect(function() if activeTab ~= tab then tab.TextColor3 = Color3.fromRGB(180, 180, 180) end end)

        return tab
    end

    local firstTab = createTab("Teleports", teleportPage)
    createTab("Character", characterPage)
    createTab("Visuals", visualsPage)
    createTab("Misc", miscPage)
    
    activateTab(firstTab, teleportPage)

    mainScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end

-- =============================================================================
-- ||                          FEATURE LOGIC                                  ||
-- =============================================================================

-- TELEPORTS
local function setSpawn()
    if not humanoidRootPart then return end
    spawnPoint = humanoidRootPart.CFrame
end

local function startTeleport()
    if isTeleporting or not spawnPoint then return end
    isTeleporting = true
    teleportConnection = RunService.RenderStepped:Connect(function()
        if isTeleporting and humanoidRootPart and humanoidRootPart.Parent then
            humanoidRootPart.CFrame = spawnPoint
        end
    end)
end

local function stopTeleport()
    if not isTeleporting then return end
    isTeleporting = false
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
end

local function teleportToPlayer(targetPlayer)
    if not humanoidRootPart or not humanoidRootPart.Parent then return end
    if not targetPlayer then return end

    local targetCharacter = targetPlayer.Character
    if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
        local targetRoot = targetCharacter.HumanoidRootPart
        humanoidRootPart.CFrame = targetRoot.CFrame
    end
end

local function updatePlayerTeleportList()
    if not playerTeleportFrame then return end
    playerTeleportFrame:ClearAllChildren()
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = playerTeleportFrame

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local playerButton = createButton(playerTeleportFrame, player.Name)
            playerButton.Size = UDim2.new(1, 0, 0, 30)
            playerButton.AnchorPoint = Vector2.new(0.5, 0)
            playerButton.Position = UDim2.new(0.5, 0, 0, 0)
            playerButton.MouseButton1Click:Connect(function()
                teleportToPlayer(player)
            end)
        end
    end
end


-- CHARACTER
local function setWalkSpeed(speed)
    currentWalkSpeed = speed
    if humanoid and isWalkSpeedOn then
        humanoid.WalkSpeed = currentWalkSpeed
    elseif humanoid and not isWalkSpeedOn then
        humanoid.WalkSpeed = defaultWalkSpeed
    end
end

local function toggleWalkSpeed(enabled)
    isWalkSpeedOn = enabled
    if enabled then
        setWalkSpeed(currentWalkSpeed)
    else
        setWalkSpeed(defaultWalkSpeed)
    end
end

local function setFlySpeed(speed)
    flySpeed = speed
end

local function toggleFly(enabled)
    isFlying = enabled
    if not humanoid or not humanoidRootPart then return end

    if enabled then
        humanoid.PlatformStand = true
        
        local gyro = Instance.new("BodyGyro")
        gyro.Name = "AdminFlyGyro"
        gyro.P = 500000
        gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        gyro.CFrame = humanoidRootPart.CFrame
        gyro.Parent = humanoidRootPart
        
        local velocity = Instance.new("BodyVelocity")
        velocity.Name = "AdminFlyVelocity"
        velocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        velocity.Velocity = Vector3.new(0, 0, 0)
        velocity.Parent = humanoidRootPart
        
        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.RenderStepped:Connect(function()
            if not isFlying or not gyro.Parent or not velocity.Parent then return end
            
            local camCF = Workspace.CurrentCamera.CFrame
            gyro.CFrame = camCF
            
            local moveVector = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0,0,-1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0,0,1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1,0,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Vector3.new(1,0,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0,1,0) end
            
            if moveVector.Magnitude > 0 then
                velocity.Velocity = (CFrame.new(Vector3.new(), camCF.LookVector) * CFrame.new(moveVector.Unit * flySpeed)).Position
            else
                velocity.Velocity = Vector3.new()
            end
        end)
    else
        humanoid.PlatformStand = false
        if humanoidRootPart:FindFirstChild("AdminFlyGyro") then humanoidRootPart.AdminFlyGyro:Destroy() end
        if humanoidRootPart:FindFirstChild("AdminFlyVelocity") then humanoidRootPart.AdminFlyVelocity:Destroy() end
        
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
    end
end

local function toggleNoclip(enabled)
    isNoclipping = enabled
    if not character then return end
    
    if enabled then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if character and isNoclipping then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        if character then
             for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- VISUALS
local function cleanupEsp(player)
    if espElements[player] then
        for _, obj in pairs(espElements[player]) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        espElements[player] = nil
    end
end

local function toggleEsp(enabled)
    isEspOn = enabled
    if enabled then
        if espConnection then espConnection:Disconnect() end
        espConnection = RunService.RenderStepped:Connect(function()
            -- Cleanup for players who left
            for player, _ in pairs(espElements) do
                if not player.Parent then
                    cleanupEsp(player)
                end
            end
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local targetChar = player.Character
                    local targetRoot = targetChar.HumanoidRootPart
                    local targetHumanoid = targetChar.Humanoid
                    
                    if targetHumanoid.Health <= 0 then 
                        cleanupEsp(player)
                        continue
                    end

                    local screenPos, onScreen = camera:WorldToViewportPoint(targetRoot.Position)
                    if onScreen then
                        if not espElements[player] then espElements[player] = {} end
                        
                        -- Cham
                        if not espElements[player].Cham then
                            local cham = targetChar:Clone()
                            cham.Name = "ESP_Cham"
                            cham.Parent = espContainer
                            for _, child in ipairs(cham:GetDescendants()) do
                                if child:IsA("BasePart") or child:IsA("MeshPart") then
                                    child.Material = Enum.Material.ForceField
                                    child.Color = ACCENT_COLOR
                                    child.Transparency = 0.5
                                    child.CanCollide = false
                                    child.Anchored = true
                                end
                                if child:IsA("Decal") then child:Destroy() end
                            end
                            espElements[player].Cham = cham
                        end
                        espElements[player].Cham:SetPrimaryPartCFrame(targetChar.PrimaryPart.CFrame)

                        -- Box and Info
                        local boxSize = Vector2.new(
                            camera.ViewportSize.Y / screenPos.Z * 3,
                            camera.ViewportSize.Y / screenPos.Z * 5
                        )
                        local boxPos = Vector2.new(screenPos.X, screenPos.Y) - (boxSize / 2)

                        if not espElements[player].Box then
                            espElements[player].Box = Instance.new("Frame", espContainer)
                            espElements[player].Box.BackgroundTransparency = 1
                            espElements[player].Box.BorderSizePixel = 1
                            espElements[player].Box.BorderColor3 = ACCENT_COLOR
                        end
                        espElements[player].Box.Position = UDim2.fromOffset(boxPos.X, boxPos.Y)
                        espElements[player].Box.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)
                        
                        if not espElements[player].Info then
                            espElements[player].Info = Instance.new("TextLabel", espContainer)
                            espElements[player].Info.BackgroundTransparency = 1
                            espElements[player].Info.Font = Enum.Font.SourceSans
                            espElements[player].Info.TextSize = 14
                            espElements[player].Info.TextColor3 = Color3.new(1,1,1)
                            espElements[player].Info.TextStrokeTransparency = 0
                        end
                        local distance = (camera.CFrame.Position - targetRoot.Position).Magnitude
                        espElements[player].Info.Position = UDim2.fromOffset(boxPos.X + boxSize.X, boxPos.Y)
                        espElements[player].Info.Text = string.format("%s\nHealth: %d\nDist: %d", player.Name, targetHumanoid.Health, distance)

                        -- Tracer
                        if not espElements[player].Tracer then
                            espElements[player].Tracer = Instance.new("Frame", espContainer)
                            espElements[player].Tracer.AnchorPoint = Vector2.new(0.5, 1)
                            espElements[player].Tracer.BackgroundColor3 = ACCENT_COLOR
                        end
                        local startPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        local lineVector = Vector2.new(screenPos.X, screenPos.Y) - startPos
                        espElements[player].Tracer.Size = UDim2.fromOffset(1, lineVector.Magnitude)
                        espElements[player].Tracer.Position = UDim2.fromOffset(startPos.X, startPos.Y)
                        espElements[player].Tracer.Rotation = math.atan2(lineVector.Y, lineVector.X) * (180 / math.pi) + 90
                    else
                         cleanupEsp(player)
                    end
                else
                    cleanupEsp(player)
                end
            end
        end)
    else
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        for player, _ in pairs(espElements) do
            cleanupEsp(player)
        end
        espElements = {}
    end
end

-- MISC
local function toggleAntiAfk(enabled)
    isAntiAfkOn = enabled
    if enabled then
        antiAfkConnection = task.spawn(function()
            while isAntiAfkOn do
                task.wait(60)
                if isAntiAfkOn then
                   VirtualUser:ClickButton2(Vector2.new())
                end
            end
        end)
    else
        if antiAfkConnection then
            task.cancel(antiAfkConnection)
            antiAfkConnection = nil
        end
    end
end

local function reduceLag()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
        end
    end
end

local function togglePlayerJoinKick(enabled)
    isPlayerJoinKickOn = enabled
end


-- =============================================================================
-- ||                           INITIALIZATION                                ||
-- =============================================================================

local function initializeFeatures()
    -- Teleports Page
    createButton(teleportPage, "Set Spawn").MouseButton1Click:Connect(setSpawn)
    createButton(teleportPage, "Start Teleport").MouseButton1Click:Connect(startTeleport)
    createButton(teleportPage, "Stop Teleport").MouseButton1Click:Connect(stopTeleport)
    
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, -20, 0, 2)
    separator.BackgroundColor3 = BG_LIGHTER_COLOR
    separator.BorderSizePixel = 0
    separator.Parent = teleportPage
    
    playerTeleportFrame = Instance.new("Frame")
    playerTeleportFrame.Size = UDim2.new(1, -20, 0, 100)
    playerTeleportFrame.BackgroundTransparency = 1
    playerTeleportFrame.Parent = teleportPage

    -- Character Page
    createToggleSwitch(characterPage, "Fly", toggleFly)
    createSliderWithInput(characterPage, "Fly Speed", 1, 500, flySpeed, setFlySpeed)
    
    createToggleSwitch(characterPage, "Noclip", toggleNoclip)
    
    createToggleSwitch(characterPage, "Modify Walkspeed", toggleWalkSpeed)
    local speedSlider = createSliderWithInput(characterPage, "Walk Speed", 1, 200, defaultWalkSpeed, setWalkSpeed)
    speedSlider.LayoutOrder = 5

    -- Visuals Page
    createToggleSwitch(visualsPage, "ESP", toggleEsp)

    -- Misc Page
    createToggleSwitch(miscPage, "Anti-AFK", toggleAntiAfk)
    createToggleSwitch(miscPage, "Player Join Kick", togglePlayerJoinKick)
    createButton(miscPage, "Reduce Lag").MouseButton1Click:Connect(reduceLag)
end

local function onCharacterAdded(newCharacter)
    -- Disconnect any active loops that depend on the old character
    if isFlying then toggleFly(false) end
    if isNoclipping then toggleNoclip(false) end
    if isTeleporting then stopTeleport() end
    
    isFlying = false
    isNoclipping = false
    isTeleporting = false
    
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    if humanoid then
        defaultWalkSpeed = humanoid.WalkSpeed
        currentWalkSpeed = defaultWalkSpeed
        if isWalkSpeedOn then
            humanoid.WalkSpeed = currentWalkSpeed
        end

        humanoid.Died:Connect(function()
            if isFlying then toggleFly(false) end
            if isNoclipping then toggleNoclip(false) end
        end)
    end
end

local function onPlayerAdded(player)
    if isPlayerJoinKickOn and player ~= localPlayer then
        localPlayer:Kick("Kicked by admin panel: A new player joined.")
    end
    updatePlayerTeleportList()
end

-- MAIN EXECUTION
createAdminPanel()
initializeFeatures()
updatePlayerTeleportList()

localPlayer.CharacterAdded:Connect(onCharacterAdded)
if localPlayer.Character then
    onCharacterAdded(localPlayer.Character)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    cleanupEsp(player)
    updatePlayerTeleportList()
end)
